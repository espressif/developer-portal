---
title: "esparagus: ESP32 flashing with structured output for CI and coding agents"
date: "2026-07-21"
summary: "esparagus is an ESP32-family flasher written in Rust — a behavioral port of esptool's protocol, sync, reset, and stub-loader paths, wrapped in an observability layer built for programs rather than humans: NDJSON events, a machine-readable report file, stable exit codes, and an expect-style serial monitor with built-in crash detection. This article explains why that layer exists, how the flash-test-fix feedback loop works, and the three ways to integrate it — direct CLI, an Agent Skill, and an MCP server."
featureAsset: "img/featured/featured-rust.webp"
authors:
    - sylwester-sosnowski
tags: ["Rust", "esptool", "Flashing", "CI/CD", "AI Agents", "MCP", "ESP32"]
---

## Introduction

esptool is the canonical way to flash an ESP32, and nothing in this article
argues against that. It's maintained by Espressif, it supports every chip
and every corner case, and `idf.py flash` is built on it.

What changed for me is *who reads the flasher's output*. On my bench it
used to be me, scanning a progress bar. Now it's increasingly a program: a
GitHub Actions job deciding whether a hardware-in-the-loop test passed, or
an LLM coding agent running a flash-test-fix loop that needs to know *why*
a boot failed — panic, watchdog, brownout, reboot loop — so it can decide
what to try next. Programs are bad at parsing English written for humans.
"A fatal error occurred" followed by a stack trace is perfectly clear to a
person and nearly opaque to a script, which ends up matching on fragile
substrings and breaking when the wording changes.

[esparagus](https://github.com/DatanoiseTV/esparagus) is my answer to
that: a flasher whose *hardware behavior is intended to be identical to
esptool's*, but whose observable behavior — events, reports, exit codes —
is designed to be branched on by machines.

## What it is

esparagus is written in Rust and is a faithful behavioral port of
esptool's protocol, sync, reset-strategy, and stub-loader paths. It
bundles the official
[esp-flasher-stub](https://github.com/espressif/esp-flasher-stub) blobs
and speaks the same SLIP-framed serial protocol, with the same on-wire
compression and per-block MD5 verification during writes. Because it
contains a derived translation of esptool's GPL-2.0+ code, the whole
project is licensed GPL-2.0-or-later to match upstream.

The chip registry covers the ESP32 family across both architectures:
ESP32, ESP32-S2, ESP32-S3, ESP32-C2, ESP32-C3, ESP32-C5, ESP32-C6,
ESP32-H2, and ESP32-P4 — with an honest caveat about validation depth
that I'll get to in the status section.

On top of the ported protocol sits the part that is new: the
observability layer.

## Structured output: events, report, exit codes

With `--json`, every run emits one JSON object per line (NDJSON) on
stdout — connection, chip detection, stub handshake, per-block write
progress, MD5 verification, completion:

```json
{"ts":"2026-05-19T12:34:55.998Z","level":"info","event":"run_start","tool":"esparagus 0.1.0","port":"/dev/cu.usbserial-XYZ","baud":460800}
{"ts":"2026-05-19T12:34:56.301Z","level":"info","event":"chip_detected","chip":"ESP32-C5","chip_id":23}
{"ts":"2026-05-19T12:34:56.523Z","level":"info","event":"stub_running","chip":"ESP32-C5","blob":"esp32c5","entry":"0x40800000"}
{"ts":"2026-05-19T12:34:57.115Z","level":"info","event":"write_progress","addr":"0x00010000","written":65536,"total":1048576,"pct":6.25}
{"ts":"2026-05-19T12:35:01.000Z","level":"info","event":"md5_verified","addr":"0x00010000","size":1048576,"md5":"f4af..."}
{"ts":"2026-05-19T12:35:01.420Z","level":"info","event":"run_complete","ok":true,"duration_ms":5422}
```

`--report path.json` additionally writes a structured summary at the end
of the run: which stages ran, which failed, how long each took, and — the
part I care most about — a `next_actions` array produced by a diagnostic
hint engine:

```json
{
  "ok": false,
  "chip": "ESP32-C5",
  "stages": [
    { "name": "connect", "ok": true, "ms": 320, "attempts": 1 },
    { "name": "stub_upload", "ok": false, "ms": 4200,
      "detail": "stub handshake failed (timeout)" }
  ],
  "errors": [{ "stage": "stub_upload", "class": "stub_handshake",
               "detail": "expected OHAI ..." }],
  "next_actions": [{
    "kind": "use_no_stub",
    "desc": "Stub failed to start. Retry with --no-stub for slower but more compatible operation."
  }]
}
```

The `class` and `next_actions[].kind` strings are stable identifiers. A
CI script or an agent branches on them; the English `detail` is there for
the human reading the archived artifact later.

Exit codes are stable per failure class, so the cheapest integration —
"check the return code" — already carries diagnostic information:

| Code | Meaning |
|------|---------|
| 0    | Success |
| 10   | Could not open serial port |
| 11   | Failed to sync with chip |
| 13   | Flash op failed (write/erase/read/MD5 mismatch) |
| 14   | Stub loader upload or handshake failed |
| 15   | Port held by another process |
| 30   | Monitor `--expect-not` pattern matched |
| 31   | Monitor timeout without an `--expect` match |
| 32   | Monitor detected an ESP crash (panic / WDT / abort / reboot loop / ...) |

(There are a few more — usage errors, image-header validation, expect-script
codes 40–43 — the full table is in the README.)

## The flash-test-fix loop

The single command the whole design converges on is `flash-monitor`: write
the image, reset into the app, and watch the boot log with a deadline and
patterns:

```sh
esparagus flash-monitor \
  --port /dev/cu.usbserial-XYZ \
  --monitor-baud 115200 \
  --expect "boot complete" --timeout 30 \
  0x10000 app.bin
```

Exit 0 means the marker appeared. Exit 31 means it didn't within the
timeout. Exit 32 means the monitor's built-in crash detectors fired first —
panic, watchdog, abort, assert, stack smashing, brownout, reboot loop,
chip stuck in download mode — and a structured `crash_context` event
carries the classification, so the consumer knows *what kind* of failure
it is without parsing a backtrace.

That closes the loop for both audiences. A CI job flashes a build on a
USB-attached board in the runner, checks the exit code, and archives the
report file as a pipeline artifact. A coding agent does the same thing
iteratively: flash, watch, branch on `crash_context`, edit the firmware,
repeat. In both cases the decision point is a stable code or a stable
string, not a regex over human-oriented log text.

(`--monitor-baud` exists because of a common real-world wrinkle: the
bootloader talks at 460800 during flashing while the firmware prints at
115200.)

## Scriptable serial automation: `expect`

For flows that need interaction rather than just watching — provisioning
consoles, factory tests, multi-step boot checks — there's an `expect`
subcommand that runs a TOML script of send/expect steps with regex
captures, named branches, and per-step timeouts. The same crash detectors
are active during every wait. A minimal boot smoke test:

```toml
# boot-smoke.toml
timeout_secs = 30

[[step]]
expect = "MAIN LOOP READY"
expect_not = "ASSERT|FATAL"
```

And a more realistic flow with branching and captures:

```toml
[[step]]
send = "wifi join {{env.WIFI_SSID}} {{env.WIFI_PSK}}\n"
expect_any = [
    { pattern = "GOT_IP (\\d+\\.\\d+\\.\\d+\\.\\d+)", goto = "have-ip" },
    { pattern = "AUTH_FAIL",                           goto = "fail"   },
]

[[step]]
name = "have-ip"
capture = { ip = "GOT_IP (\\d+\\.\\d+\\.\\d+\\.\\d+)" }
send = "ping {{ip}}\n"
expect = "64 bytes from {{ip}}"
```

Scripts can be linted without a chip attached (`--check` validates regex
compilation, `goto` targets, and template braces), which makes them
reasonable to keep in a repository and gate in CI.

## Three integration surfaces

The same underlying operations are exposed three ways, and the choice is
about what's driving the tool, not about capability — a flash done over
any of them is byte-identical on the wire:

- **Direct CLI** — the universal substrate. Shell scripts, Makefiles,
  GitHub Actions, Jenkins, and any agent that has a shell tool.
- **Agent Skill** — a folder of Markdown following the
  [agentskills.io](https://agentskills.io) spec that compatible coding
  agents load on demand. It's documentation, not runtime: it teaches the
  agent the exit-code semantics, the NDJSON event shapes, and the known
  pitfalls, and the agent still runs the CLI through its shell tool. If
  your agent can run a process, this adds context with zero extra
  infrastructure.
- **MCP server** — `esparagus mcp` speaks JSON-RPC 2.0 over stdio and
  exposes the subcommands as typed tools for MCP-aware clients that
  don't have shell access. During a long call like `flash_monitor`,
  every NDJSON event is forwarded live as an MCP notification. Each tool
  call spawns a fresh child process, so the serial port is held only for
  the duration of the call — `idf.py monitor` or a second client can use
  the port in between.

In practice these coexist: CI runs the CLI, a bench agent uses the Skill,
a desktop MCP client uses the server.

## Drop-in `esptool.py` compatibility

There's also a fourth, accidental-looking surface that I use daily: a
busybox-style compatibility layer. Symlink the binary as `esptool.py`
somewhere early on `$PATH` and existing ESP-IDF builds shell out to it
transparently:

```sh
ln -s "$(which esparagus)" ~/.local/bin/esptool.py
idf.py flash   # now runs esparagus under the hood
```

The compat layer translates esptool's argv conventions
(`write_flash` to `write-flash`, `default_reset` to `default-reset`,
positional `read_flash` arguments to flags) and warns about the few
overrides it doesn't support. This is how I validated protocol parity:
the same build, the same board, flashed through the same `idf.py`
invocation.

## The rest of the toolbox

A few subcommands exist because the feedback loop needs them nearby:

- **Name-addressed partition operations.** `write-partition --name ota_0
  app.bin`, `read-partition --name nvs`, `erase-partition --name nvs` —
  the partition table is read from the chip at 0x8000 (or from a CSV),
  so there's no offset arithmetic to get wrong.
- **Full-flash backup and restore.** `backup -o device.bin.gz` captures a
  working device (auto-sized from the JEDEC flash ID); `restore` replays
  it onto a replacement board. Useful for field service and for saving a
  known-good state before letting an automated loop write to a device.
- **NVS inspection.** A terminal UI viewer (`nvs view`) and a JSON
  exporter (`nvs export`) for the chip's key-value store, with blob
  entries base64-encoded and multi-chunk blobs coalesced.
- **eFuse reading.** `read-efuse --summary` decodes the fields from the
  bundled upstream YAML definitions — secure boot state, flash
  encryption counters, JTAG/USB lockdown, silicon revision — as one
  structured JSON event. Read-only by design; burning fuses is one-way
  and deliberately left to `espefuse.py`.
- **Offline image work.** `elf2image` builds a v2 firmware image from a
  32-bit ELF (Xtensa or RISC-V), and `merge-bin` combines bootloader,
  partition table, and app into one padded distributable blob. Neither
  needs a chip attached.
- **Port discovery.** `list-ports` enumerates ESP-likely USB devices
  (Espressif native USB plus the common CP210x/CH34x/FTDI bridges) with
  their USB descriptors, and `detect` auto-selects the port when exactly
  one candidate is present.

## Current status and limitations

The honest part. Hardware validation is a matrix, not a checkbox, and
mine currently looks like this:

- **ESP32-P4 is bench-validated end to end** — detect, stub handshake,
  compressed writes with MD5 verify, full-flash backup round-trip,
  reset into firmware.
- **ESP32-C5** has detect and full-flash backup validated on silicon.
- **Every other family** currently works via protocol parity: the
  protocol layer, stub handshake, reset strategies, and per-chip
  register tables are shared code with the validated rows, but I have
  not bench-run every (chip, operation) pair yet. The per-chip matrix
  lives in
  [docs/STATUS.md](https://github.com/DatanoiseTV/esparagus/blob/main/docs/STATUS.md)
  and gets updated as boards land on my bench.

Intentionally not implemented (and not planned to be quietly
half-implemented): eFuse burning, secure boot signing, flash encryption,
Secure Download Mode, UF2 generation, and NAND commands. If your workflow
needs those, you need esptool and its siblings — and for production
provisioning involving one-way operations, you want the canonical tool
anyway.

That's also the general recommendation: esptool remains the reference,
and if you flash by hand and read the output with your own eyes, it
already serves you well. esparagus is for the case where the thing
reading the output is a program.

## Getting started

esparagus requires Rust 1.88+ to build:

```sh
cargo install --git https://github.com/DatanoiseTV/esparagus
```

Then the two commands that show the shape of the tool:

```sh
esparagus detect            # auto-selects the port if one board is attached
esparagus --json --report report.json flash-monitor \
  --expect "boot complete" --timeout 30 \
  0x10000 app.bin
```

- Source, full README, and the expect-script grammar:
  [github.com/DatanoiseTV/esparagus](https://github.com/DatanoiseTV/esparagus)
- Per-chip validation matrix and unimplemented-features list:
  [docs/STATUS.md](https://github.com/DatanoiseTV/esparagus/blob/main/docs/STATUS.md)
- The bundled flasher stubs come from Espressif's
  [esp-flasher-stub](https://github.com/espressif/esp-flasher-stub)

If you run it against a chip outside the validated rows, I'd like to
hear the result either way — a failure report with the NDJSON stream
(`--json --log-file out.ndjson`) and the report file is exactly the
shape the tool was designed to produce, and it's the fastest way to turn
a `~` in the support matrix into an `OK`.
