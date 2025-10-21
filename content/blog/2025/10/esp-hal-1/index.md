---
title: "esp-hal 1.0.0 release announcement"
date: 2025-10-30
featureAsset: "img/featured/featured-rust.webp"
authors:
  - scott-mabin
tags:
  - Esp32
  - Rust
  - Xtensa
  - RISCV
  - Announcement

---

In February this year, we announced the first [esp-hal 1.0 beta] release. Since then we've been hard at work, polishing and preparing for the full release. Today, the Rust team at Espressif is excited to announce the official `1.0.0` release for `esp-hal`, the _first_ vendor-backed Rust SDK!

### What We're Stabilizing Today

esp-hal is far from complete. We've spent many years researching and experimenting to get to this stage. However, to get a stable foundation to build from, the experimentation eventually needs to make way for stability. To achieve this, we've decided to limit the scope of 1.0 stabilization to:

- Initializing the hal, `esp_hal::init` and the relevant configuration associated with that.
- Four "core" drivers to start:
  - GPIO
  - UART
  - SPI
  - I2C
- The `time` module, which provides `Instant`, `Duration`, and `Rate`.
- A couple of miscellaneous system APIs (SoC reset, etc.).
- `#[main]` macro.
- Additional configuration parameters beyond feature flags.

With the exception of the list above, everything else in esp-hal is now feature gated behind the `unstable` feature. With the scope limited, post 1.0 we can incrementally stabilize drivers, much like the Rust project itself does, building on 1.0's foundation. 

### What About the Other `no_std` `esp-*` Crates?

esp-hal is the foundation of many of the esp-rs ecosystem crates, [esp-radio] (previously known as esp-wifi) is our next stabilization target, and builds directly on top of esp-hal. The end goal is of course to have every `esp-*` crate with a 1.0+ release eventually.

### Getting Started

The first step is to read our specially curated [book], which explains the ecosystem, tooling and some key embedded concepts for esp-hal.

As part of getting to 1.0, we've created our own project generation tool, [esp-generate] to bootstrap starting a project. This is explained fully in the [book], getting something building today should be as simple as:

```bash
cargo install esp-generate
```

then run

```bash
esp-generate
```

to launch the interactive project generation terminal user interface.

### What’s Next?

If you're a company using (or considering) Rust on our chips, please do contact rust.support@espressif.com, we'd love to hear from you!

[^1]: There are some binary blobs to run the Wi-Fi driver which we link to.


[Espressif]: https://www.espressif.com/
[Xtensa]: https://en.wikipedia.org/wiki/Tensilica
[ESP-IDF]: https://github.com/espressif/esp-idf
[probe-rs]: https://probe.rs/
[embedded-test]: https://github.com/probe-rs/embedded-test
[embassy]: https://github.com/embassy-rs
[official Rust embedded book]: https://docs.rust-embedded.org/book/static-guarantees/typestate-programming.html
[the tracking issue]: https://github.com/espressif/llvm-project/issues/4
[espflash]: https://github.com/esp-rs/espflash
[esp-hal]: https://github.com/esp-rs/esp-hal/tree/main/esp-hal
[esp-radio]: https://github.com/esp-rs/esp-hal/tree/main/esp-radio
[ESP-NOW]: https://www.espressif.com/en/solutions/low-power-solutions/esp-now
[xtensa-lx and xtensa-lx-rt]: https://github.com/esp-rs/esp-hal/tree/main/xtensa-lx-rt
[esp-generate]: https://github.com/esp-rs/esp-generate
[book]: https://github.com/esp-rs/book
[esp-config]: https://crates.io/crates/esp-config
[docs.espressif.com/projects/rust]: https://docs.espressif.com/projects/rust/index.html
[esp-hal 1.0 beta]: https://developer.espressif.com/blog/2025/02/rust-esp-hal-beta/


[@ivmarkov]: https://github.com/ivmarkov
[@jessebraham]: https://github.com/jessebraham
[@BjoernQ]: https://github.com/BjoernQ
[@arjanmels]: https://github.com/arjanmels
[@t-moe]: https://github.com/t-moe
[@bugadani]: https://github.com/bugadani
