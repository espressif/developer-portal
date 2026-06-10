---
title: "Rust smoltcp as an alternative TCP/IP stack for ESP-IDF"
date: "2026-06-11"
summary: "A set of ESP-IDF components that run the Rust smoltcp stack as the IPv4/IPv6 data plane, while keeping esp_http_server, esp-tls and esp-mqtt working without source changes. This article explains the linker --wrap shim that makes it compatible, the single-task poll architecture, the throughput I measured on an ESP32-P4 (91.15 Mbit/s on a 100 Mbit link), and the limitations to be aware of."
featureAsset: "img/featured/featured-rust.webp"
authors:
    - sylwester-sosnowski
tags: ["Rust", "smoltcp", "Networking", "TCP/IP", "ESP-IDF", "ESP32-P4", "lwIP"]
---

## Why a second TCP/IP stack

ESP-IDF ships with lwIP, and for most projects that's the right choice. It's
mature, well documented, and every networking component in IDF is built and
tested against it. Nothing below is an argument to replace it by default.

Still, there are two reasons you might want an alternative. The first is the
implementation language: the IP stack is the part of your firmware that
parses bytes arriving from machines you don't control, and lwIP is written
in C. The second is the concurrency model — lwIP runs several tasks and
takes a fair number of mutexes, which is harder to reason about when you
need confidence that a device will stay up for months without intervention.

[smoltcp](https://github.com/smoltcp-rs/smoltcp) addresses both. It's a
`#![no_std]` TCP/IP stack written in Rust, with no heap requirement and a
single, explicit poll model: you give it the current time and a device to
read and write frames, it does one pass of work, and you call it again. The
packet parsing is safe Rust, and there's no background thread operating on
the stack behind your code.

Now, getting smoltcp to run on an ESP32 is not the hard part. The hard part
is running it *under ESP-IDF without giving up the IDF networking stack you
already depend on* — `esp_http_server`, `esp-tls`, `esp_http_client`,
`esp-mqtt`, mbedTLS. If switching stacks means forking all of that, it's a
toy. So the goal was source compatibility: keep those components, and the
application code that uses them, completely unchanged.

That turned out to be achievable, and verified on real hardware at roughly
wire-line speed. This article goes through how it works and where the edges
are.

## How compatibility works: a linker `--wrap` shim

Every IDF networking component eventually calls BSD sockets — `socket()`,
`bind()`, `listen()`, `accept()`, `send()`, `recv()`, `select()`,
`getaddrinfo()`. In the IDF, these come from `<lwip/sockets.h>`, and the
key detail is that they are defined as `static inline` wrappers:

```c
/* lwip/sockets.h, simplified */
static inline int socket(int domain, int type, int protocol) {
    return lwip_socket(domain, type, protocol);
}
static inline int bind(int s, const struct sockaddr *name, socklen_t len) {
    return lwip_bind(s, name, len);
}
```

So when `esp_http_server` calls `socket()`, the symbol that actually ends
up in the link is `lwip_socket()`. That's the seam the whole project hangs
on.

GNU `ld` provides `--wrap=symbol`: every reference to `symbol` is redirected
to `__wrap_symbol`, and the original remains reachable as `__real_symbol`.
The component adds one of these for each BSD-socket entry point:

```
-Wl,--wrap=lwip_socket
-Wl,--wrap=lwip_bind
-Wl,--wrap=lwip_listen
-Wl,--wrap=lwip_accept
-Wl,--wrap=lwip_send
-Wl,--wrap=lwip_recv
-Wl,--wrap=lwip_select
/* ... and so on for the full BSD-socket surface */
```

With that in place, every BSD-socket call site across the IDF — none of
which is modified — lands in a thin C shim that talks to smoltcp instead.
lwIP is still compiled into the image, because its headers define types the
IDF networking source needs, but its socket layer is never reached at
runtime. The application source change required to switch stacks is zero.

## Using it

The intended workflow is "install your own Ethernet driver, hand over the
handle, and let the component take it from there." You bring up `esp_eth`
the way your board requires — pins, PHY, clocks, all board-specific — and
then attach it:

```c
#include "esp_smoltcp.h"

void app_main(void)
{
    nvs_flash_init();
    esp_event_loop_create_default();

    /* Your driver, your pins. The stack does not need to know the details. */
    esp_eth_handle_t eth = my_install_eth_driver();

    esp_smoltcp_init();
    esp_smoltcp_attach_eth(eth);
    esp_smoltcp_wait_for_ip(ESP_SMOLTCP_IFACE_ETH, 15000);  /* DHCP by default */

    /* BSD sockets work from here, so unmodified IDF code works too: */
    httpd_handle_t server;
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();
    httpd_start(&server, &config);
    /* register handlers as usual */
}
```

`httpd_start()` and everything beneath it are stock IDF. They just happen
to be running on smoltcp now.

## Architecture

The implementation is three components stacked on top of each other:

```
  esp_http_server | esp-tls | esp-mqtt | mdns   (unchanged IDF source)
                         |
              BSD sockets: socket/bind/recv/select/getaddrinfo
                         |
   +---------------------v---------------------+
   |  esp_smoltcp_lwip_compat                  |  linker --wrap shim:
   |  FD table, select scan, getaddrinfo,      |  rewrites every lwip_* call
   |  esp_netif shim, in-RAM 127.0.0.0/8       |  to __wrap_lwip_*; provides
   |  loopback for httpd's control socket      |  an in-RAM loopback
   +---------------------+---------------------+
                         |
   +---------------------v---------------------+
   |  esp_smoltcp                              |  single poll task owns the
   |  poll loop, slab-allocated RX frame pool, |  stack; FreeRTOS event-group
   |  L2 frame tap, per-interface stats, SNTP  |  wakeups; per-iface counters
   +---------------------+---------------------+
                         |
   +---------------------v---------------------+
   |  esp_smoltcp_glue                         |  Rust no_std staticlib,
   |  smoltcp 0.12 + DNS resolver + C FFI      |  riscv32imafc-unknown-none-elf
   +---------------------+---------------------+
                         |
            esp_eth_handle_t  (your driver, attached above)
```

Three decisions shape how this behaves under load:

**A single task owns the stack.** There's one poll loop. It blocks on a
FreeRTOS event group, wakes when a frame arrives or a socket needs service,
runs exactly one `iface.poll()` pass, and goes back to sleep. Because
nothing else ever touches smoltcp, there are no locks protecting it. The
BSD shim marshals work onto that task instead of reaching into the stack
from arbitrary contexts.

**RX frames come from a slab pool, not the heap.** The pool is fixed in
size and count and allocated once. Under load that gives you bounded RAM
and an explicit drop counter (`esp_smoltcp_frame_pool_drops()`) instead of
heap fragmentation and a mystery. If the pool runs dry, that's a number you
can read, not a leak you have to hunt.

**The Rust side is `no_std`** with an internal-RAM-first allocator, built
for `riscv32imafc-unknown-none-elf` to match the ESP32-P4 high-performance
cores (hard float, compressed instructions). The TX scratch buffer is a
static pool. The pinned toolchain is recorded in a `rust-toolchain.toml`,
so `rustup` selects it automatically.

## Performance

The hardware is a Waveshare ESP32-P4-Nano with the built-in 100 Mbit/s
EMAC, ESP-IDF v6.0, MTU 1500. The example application serves a synthetic
download endpoint; the measurement is a 200 MB transfer pulled with `curl`
(curl reports it as 190M because it counts in MiB):

```bash
$ curl http://<ip>/dl/200000000 --output foo
100  190M    0  190M    0     0  10.8M     0  --:--:--  0:00:17  --:--:--  10.8M

# the server logs, after the transfer completes:
I (...) app: dl: 200000000 bytes in 17552922 us = 91.15 Mbit/s
```

That's **91.15 Mbit/s sustained.** The practical ceiling on a 100 Mbit
link at MTU 1500, after Ethernet, IP and TCP framing, is about 94.85
Mbit/s, so this is roughly 96% of the realistic maximum; the remaining
few percent is framing overhead that nothing can get back. Across the
200 MB transfer there were 0 TX failures and 0 frame-pool drops, and
round-trip ping on the wire sits at 0.4–0.7 ms.

To be clear, that number is the result of tuning, not the first run.
Getting there took a 1 kHz FreeRTOS tick so the poll loop is serviced often
enough, enabling the EMAC hardware flow control, and moving the hot path
into IRAM so it isn't stalled on flash access. A throughput figure without
its conditions isn't worth much, so those are the conditions.

The cost on the build is roughly +80 KiB of code and ~120 KiB of BSS (the
slab pool plus the Rust scratch). On a P4 that is negligible; on a smaller
part it is a real consideration.

## The `select()` problem, and how the RFC fixed it

The first release (v0.1.0) had one mandatory and unattractive constraint:
you had to set `CONFIG_VFS_SUPPORT_SELECT=n`.

The reason is that `select()` in the IDF doesn't only go through the BSD
symbol that `--wrap` can intercept. The VFS layer keeps its own per-FD-range
table of function pointers, and for sockets it points directly at lwIP's
select implementation. A linker `--wrap` rewrites *call sites*; it can't
reach a runtime function-pointer table that lwIP populates during init. So
`select()` would dispatch to lwIP, query lwIP's empty socket table, and the
smoltcp sockets were simply invisible to it. Disabling VFS select avoided
the table entirely — but "set this unrelated-looking Kconfig option or
nothing works" is not a constraint I wanted to ship long-term.

I posted the design as an
[RFC on the esp-idf tracker](https://github.com/espressif/esp-idf/issues/18549)
and asked whether there was a cleaner option. David Cermak from Espressif
pointed to `esp_vfs_register_fd_range()`.

The fix that came out of that: after lwIP registers its VFS, the component
claims the BSD-socket FD range `[LWIP_SOCKET_OFFSET, MAX_FDS)` for its own
VFS and supplies its own `esp_vfs_select_ops_t`. The IDF's `select()` then
dispatches through the proper VFS mechanism into the component — the
`__wrap_lwip_*` functions remain the implementation underneath, but FD
ownership and the select hook are now handled the way the IDF intends. On
the v0.2 development branch the `CONFIG_VFS_SUPPORT_SELECT=n` requirement
is gone and the IDF default just works. A considerably better answer than
the one I originally shipped.

## Current status and limitations

What is verified and in use:

- BSD sockets, `select()`/`poll()`, and the full `esp_http_server` stack
  including chunked encoding and WebSockets
- `esp_https_server` with mbedTLS, plus `esp-tls`, `esp_http_client` and
  `esp-mqtt`, all over BSD sockets and all unchanged
- An in-RAM `127.0.0.0/8` loopback (the httpd internal control socket needs
  one; it never reaches the wire)
- IGMPv2 multicast, ICMP echo, and IPv6 link-local with ping6 and
  NDP/ICMPv6
- A raw L2 frame tap for PTP, LLDP and custom EtherTypes, with the P4
  hardware timestamp wired up
- Per-interface statistics and the frame-pool drop counter

And what I'm not claiming:

- **Only the ESP32-P4 is hardware-verified.** Other RISC-V parts should
  work; the classic Xtensa ESP32 needs a different Rust target and hasn't
  been done.
- **The ESP-Hosted Wi-Fi path is scaffolded but not yet flashed.** The code
  exists; until it's proven on hardware it stays listed as untested.
- **No SLAAC and no DHCPv6.** IPv6 support is link-local plus the native
  socket API. smoltcp doesn't ship a Router-Solicitation client and I
  haven't written one yet.
- **The bundled DNS resolver is minimal** — single-shot, A-records only.
  Production use should bring its own resolver.

For a sense of how hard the working list has been exercised: the
socket-handle map used to run out of slots after about 24 connections until
it got proper recycling, and an early `select()` implementation spun on a
`vTaskDelay(1)` until it was made event-driven. Both are fixed — and
finding that class of bug is what separates "works" from "demo", which is
why I mention them.

## When to use it

Choose this if the safety properties of a Rust IP stack matter for your
project, or if a single predictable poll loop with bounded RAM and explicit
drop counters fits your reliability requirements better than lwIP's
threaded model. Those are the two cases it was built for.

Stay on lwIP otherwise. It integrates with the whole ecosystem, it's
thoroughly documented, and "already present and proven" is a strong
argument on its own. The aim here is to make the alternative exist, not to
argue that everyone should switch.

## Getting started

The three components are published on the
[ESP Component Registry](https://components.espressif.com/), so adding them
is a one-liner:

```bash
idf.py add-dependency "datanoisetv/esp_smoltcp^0.1.0"
idf.py add-dependency "datanoisetv/esp_smoltcp_lwip_compat^0.1.0"
```

- Source, the complete `eth_basic` example, and architecture notes:
  [github.com/DatanoiseTV/esp-smoltcp](https://github.com/DatanoiseTV/esp-smoltcp)
- Registry pages:
  [esp_smoltcp](https://components.espressif.com/components/datanoisetv/esp_smoltcp)
  and
  [esp_smoltcp_lwip_compat](https://components.espressif.com/components/datanoisetv/esp_smoltcp_lwip_compat)
- Design RFC and discussion:
  [esp-idf#18549](https://github.com/espressif/esp-idf/issues/18549)

If you run it on hardware I haven't tested — another RISC-V part, or the
ESP-Hosted Wi-Fi path — I'd genuinely like to hear how it went, working or
not. At this stage the failure reports are the more valuable ones.
