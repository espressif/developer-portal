---
title: "AES67 audio-over-IP on the ESP32-P4"
date: "2026-06-22"
summary: "AES67/RAVENNA is the audio transport behind a lot of broadcast and live-sound infrastructure, and it normally runs on dedicated silicon or Linux boxes. This article is about getting a working, PTP-synchronized AES67 endpoint onto an ESP32-P4 — how the clock sync, the low-latency receive path, and the I2S playout fit together, what the measured latency is, and where the edges are."
featureAsset: "img/featured/featured-espressif-waves.webp"
authors:
    - sylwester-sosnowski
tags: ["AES67", "RAVENNA", "audio", "PTP", "RTP", "ESP-IDF", "ESP32-P4", "networking"]
---

## What AES67 is, and why this is an odd place to run it

AES67 is an interoperability standard for moving uncompressed audio over a
normal IP network: PCM samples in RTP, sessions described in SDP and
announced over SAP, and — the part that makes it hard — every device locked
to a shared clock by PTP (IEEE-1588) so that streams from different sources
stay sample-aligned. It is what a lot of broadcast trucks, studios, and
live-sound rigs use under the hood, and it interoperates with the RAVENNA
and Dante (AES67 mode) ecosystems.

The hardware that speaks it is usually a dedicated Dante chip, an FPGA, or a
Linux machine with a good NIC. None of those are a microcontroller. The
ESP32-P4 is interesting here because it has two things that make AES67
plausible on a device of this size: a RISC-V core fast enough to convert and move
audio samples in software, and an Ethernet MAC with **IEEE-1588 hardware
timestamping** — which is the one feature you cannot fake if you want real
PTP sync.

So I built an AES67/RAVENNA endpoint as an ESP-IDF component for the P4. It
synchronizes to an external PTP grandmaster (or becomes one), sends and
receives multichannel RTP audio, discovers and is discovered over SAP/SDP,
and plays out through I2S to a DAC. It interoperates on real hardware with
Merging Technologies SIENNA, with the
[aes67-linux-daemon](https://github.com/bondagit/aes67-linux-daemon) running
on a Raspberry Pi, and with a standalone AES67 hardware speaker/amplifier.
End-to-end latency, best case, is about **0.7 ms**.

This article walks through the three parts that actually matter — the clock,
getting packets off the wire fast, and playing them out without jitter — and
is honest about what's solid and what isn't.

## The clock is the whole problem

When discussing network audio, latency is the key metric people quote. But the
thing that's genuinely hard is *agreement on time*. Every AES67 device has
to run its media clock from the same PTP grandmaster, to within
sub-microsecond accuracy, or audio from two sources drifts apart and you get
clicks at the seams.

PTP gets that accuracy by timestamping sync packets in hardware, at the MAC,
the instant they cross the wire — software timestamps carry too much jitter
from interrupt latency and scheduling. The ESP32-P4 EMAC has this unit, and
ESP-IDF exposes it through a clock abstraction (`esp_eth_clock_gettime`,
`esp_eth_clock_settime`). On top of that I run a small IEEE-1588 daemon
(a port of the NuttX `ptpd`) that does the protocol — best-master-clock
selection, sync/follow-up/delay-request exchange, and the servo that
disciplines the local clock to the master.

A couple of details worth pulling out:

- **The PTP identity comes from the MAC address.** A PTP clock needs a
  unique 64-bit identity; AES67 devices derive it from the 48-bit MAC by the
  standard EUI-64 expansion (insert `FF:FE` in the middle). The node also
  uses that to detect when *it* has been elected grandmaster — it compares
  the announced grandmaster ID against its own MAC-derived identity.
- **It can be master or slave.** If there's a better clock on the network,
  the node locks to it. If there isn't, best-master-clock selection promotes
  this node to grandmaster and it serves time to everyone else. That's not a
  mode switch you configure; it falls out of the protocol.

Once the clock is disciplined, RTP timestamps are just a projection of PTP
time onto the media rate: `rtp_ts = ptp_time_ns * sample_rate / 1e9`. Get
the clock right and the rest of the timing is arithmetic.

## Getting RTP off the wire without paying for the network stack

The receive path is where the latency budget is won or lost. A normal
sockets path — EMAC interrupt, into lwIP, IP/UDP demux, copy into a socket
buffer, wake the reader task — adds buffering and scheduling delay at every
hop, and on a device of this size that's a meaningful fraction of a millisecond
plus jitter you can't predict.

AES67 RTP is multicast UDP on a known port, which means you can recognize it
extremely early. The component reads frames at L2 (via `esp_vfs_l2tap`),
ahead of the socket layer. The example goes one step further and installs a
hook in the Ethernet driver's receive callback itself — the function that
runs in the driver before lwIP is ever called:

```c
/* Runs for EVERY Ethernet frame, in the driver, before lwIP.
 * RTP multicast on port 5004: handle it and free. Everything else:
 * hand back to lwIP untouched. */
static esp_err_t IRAM_ATTR eth_rtp_hook(esp_eth_handle_t eth, uint8_t *buf,
                                        uint32_t len, void *priv, void *info)
{
    if (len < 54) goto forward;                       /* too short for RTP   */
    if (buf[12] != 0x08 || buf[13] != 0x00) goto forward;  /* not IPv4       */
    if (buf[14 + 9] != 17) goto forward;              /* not UDP             */
    if ((buf[14 + 16] & 0xF0) != 0xE0) goto forward;  /* not multicast       */
    /* ... port 5004? RTP v2? then parse the header and convert the payload  */
    /* straight into the audio stream buffer, and return — lwIP never sees   */
    /* this frame. */
forward:
    return s_original_input(eth, buf, len, priv, info);  /* back to lwIP     */
}
```

The checks are ordered cheapest-first and the whole thing lives in IRAM so
it isn't waiting on flash. A non-audio frame pays only a handful of byte
comparisons before being handed back to lwIP, so the rest of the network
stack — DHCP, the web UI, mDNS — keeps working normally. An audio frame
never enters lwIP at all: its payload is converted (L16/L24/L32 to the
internal int32 format) and written to the playout buffer right there in the
driver callback.

To be precise about what's where: the L2-tap receive path is in the
component and portable; the in-driver hook above is example code in the
repository's `main/`, because it's tied to how you install your Ethernet
driver. It's the path that produces the lowest numbers, but it's wiring you
copy and adapt, not a component API.

## Playing it out without jitter

On the playback side the enemy is the same one but wearing different clothes:
anything that introduces scheduling jitter between "audio is ready" and
"sample reaches the DAC" turns into audible artifacts.

Two decisions handle that:

- **I2S runs from the APLL, not the default clock.** The audio PLL can hit
  an exact 48 kHz (via an 18.432 MHz MCLK) where the integer dividers off
  the main clock can't, and — more importantly — its sigma-delta modulator
  can be nudged in sub-ppm steps at runtime. That's the media-clock recovery
  knob: if the local playout is drifting against the PTP-disciplined sample
  count, you trim the APLL by a few ppb rather than dropping or repeating
  samples.
- **The DMA is driven from its own ISR, not a task.** When a DMA descriptor
  finishes, its interrupt reads the next chunk straight out of the audio
  stream buffer and refills the descriptor. There's no playback task to wake
  and schedule — going through a task instead cost about 10% of throughput
  in jitter and missed deadlines. On underrun the ISR holds the last sample
  instead of emitting silence, so a brief starvation decays smoothly rather
  than clicking.

## Latency, and the trade-off I didn't get to skip

The end-to-end latency depends on the source's packet time — how much audio
each RTP packet carries. Smaller packets mean lower latency and more packets
per second for the CPU to absorb. Measured on the P4:

| Source packet time | Packets/sec | End-to-end |
|---|---|---|
| 0.125 ms (6 frames @ 48 kHz) | 8000 | ~0.7 ms |
| 0.333 ms (16 frames) | 3000 | ~1.0 ms |
| 1 ms (48 frames) | 1000 | ~1.7 ms |
| 4 ms (192 frames) | 250 | ~2.7 ms |

The 0.7 ms case breaks down roughly as: 0.125 ms source buffering, ~0.1 ms
on the wire, ~0.1 ms to parse and convert in the hook, and ~0.33 ms in the
DMA ring — two descriptors of 16 frames each.

That DMA ring size is the trade-off I want to be honest about, because I
tried to cheat it and couldn't. Smaller descriptors mean lower latency, so I
took the ring down to 6 frames and got the ISR firing at 8000 Hz — and it
worked, right up until it didn't, dropping samples under sustained load. I
reverted to 16 frames (0.33 ms). The latency floor on this design is set by
how small a DMA descriptor you can service reliably at the worst-case
interrupt rate, not by how small a number you can get to flash once.

The other thing that didn't work until it did was multicast under load. The
ESP32-P4 EMAC would drop multicast frames once the packet rate got high
enough — about 8% loss — which on an audio stream is constant clicking.
Enabling **IEEE 802.3x flow control** so the MAC can pause the sender when
its buffers fill fixed it: zero loss across a 645,000-packet test, no
sequence gaps. Flow control is one Kconfig option and a line in the driver
config, and it's the difference between "demo" and "leave it running."

## Does it actually interoperate

This is the part that separates an AES67 implementation from a thing that
sends RTP packets. The standard exists so that gear from different vendors
locks together, so the only test that counts is against other vendors' gear.

I ran it against three reference points. The first is the
[aes67-linux-daemon](https://github.com/bondagit/aes67-linux-daemon) on a
Raspberry Pi — an open-source AES67 implementation — as both a source and a
sink, with the P4 discovering it over SAP and locking to its PTP. The second
is **Merging Technologies SIENNA**, a commercial RAVENNA implementation; the
P4 discovered its announced streams, parsed its SDP, synchronized to the
same grandmaster, and played its audio. The third is a standalone **AES67
hardware speaker/amplifier** — a dedicated network audio endpoint, not a
PC — which received and played the P4's source stream, confirming the TX
side against real-world playback gear rather than only software sinks.
Cross-checking the framing against the Linux daemon's source also turned up
a handful of real bugs in my SDP and SAP handling (wrong multicast address,
wrong SAP message-ID hashing, a TTL that didn't match the RFC) that no
amount of testing against my own code would have found.

## What it costs, and what isn't done

The whole thing — PTP daemon, RTP engine, codecs, I2S driver, SAP/SDP,
mDNS, and an embedded web UI — builds to about a 650 KB application image
and uses roughly 22% of the P4's internal RAM, leaving the rest for your
application and audio buffers. It's a component, not a whole-chip takeover.

What I'm not claiming:

- **ESP32-P4 only.** This leans on the P4's EMAC hardware timestamping and
  its I2S/APLL clocking. It does not port to the other ESP32s as-is.
- **44.1 and 48 kHz only.** 96 kHz is not done.
- **The lowest-latency receive hook is example wiring**, not a component
  API, because it's tied to how you bring up your Ethernet driver. The
  component's portable path is the L2 tap.
- It's an endpoint, not a full RAVENNA Advanced/ST 2110 stack — no video, no
  NMOS, and the discovery is SAP/mDNS rather than the full RAVENNA session
  management.

## Try it

The component is on the ESP Component Registry:

```bash
idf.py add-dependency "datanoisetv/aes67^2.6.0"
```

Source, the full ESP32-P4-Nano example (Ethernet + ES8311 codec bring-up,
the Rx hook, and the web UI), and the architecture notes are in the
[repository](https://github.com/DatanoiseTV/aes67-esp32p4). If you put it on
a network with other AES67 gear, I'd like to hear what it locked to and what
it didn't — interoperability reports are the useful ones.
