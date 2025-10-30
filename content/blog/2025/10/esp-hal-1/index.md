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

We've spent many years researching and experimenting to get to this stage (checkout the [esp-hal 1.0 beta] blog post for the longer story!). However, to get a stable foundation to build from, the experimentation eventually needs to make way for stability. To achieve this, we've decided to limit the scope of 1.0 stabilization to:

- Initializing the hal, `esp_hal::init` and the relevant configuration associated with that.
- Four "core" drivers to start:
  - GPIO
  - UART
  - SPI
  - I2C
- `Async` and `Blocking` modes for the aforementioned drivers.
- The `time` module, which provides `Instant`, `Duration`, and `Rate`.
- A couple of miscellaneous system APIs (SoC reset, etc.).
- `#[main]` macro.
- Additional configuration mechanism beyond feature flags ([esp-config]).

With the exception of the list above, everything else in `esp-hal` is now feature gated behind the `unstable` feature. With the scope limited, post 1.0 we can incrementally stabilize drivers, much like the Rust project itself does, building on 1.0's foundation.

### What Does Unstable Mean for Drivers?

Unstable in this case refers to API stability. There is varying levels of functionality for unstable drivers, however they are suitable for most common use cases. Using them, reporting feedback, and/or contributing to improving them will aid their stabilization.

### What About the Other `esp-*` Crates?

`esp-hal` is the foundation of many of the ecosystem crates. [`esp-radio`] (previously known as `esp-wifi`) is our next stabilization target, which will enable the use of WiFi, Bluetooth, ESP-NOW and IEEE802.15.4 on the ESP32 family of devices. The end goal is of course to have every `esp-*` crate with a 1.0+ release eventually.

### Getting Started

The first step is to read our specially curated [book], which explains the ecosystem, tooling and some key embedded concepts for `esp-hal`.

As part of getting to 1.0, we've created our own project generation tool, [esp-generate] to bootstrap starting a project. This is explained fully in the [book], but getting something running today should be as simple as:

```bash
cargo install esp-generate --locked
```

then run

```bash
esp-generate
```

to launch the interactive project generation terminal user interface.

Once you've generated your project, connect your ESP32 and run `cargo run --release` from your new project directory!

### What’s Next?

This is just the start. We plan on stabilizing all `esp-hal` related crates, next up is [`esp-radio`]. We'll continue developing [`esp-hal`], overtime we'll stabilize more drivers beyond the core set that we're starting with today. We'll continue to add support for new devices, such as the newly released ESP32-C5, as they go into mass production.

This release would not have been possible without the help from the Rust community, the embedded working group, and of course the esp community and contributors which have heavily impacted how we’ve developed our Rust offering. I would also like to thank Espressif, and in particular the Rust team for their hard work in getting us to where we are today!

If you're a company using (or considering using) Rust on our devices, please do contact sales@espressif.com, we'd love to hear from you!

[Espressif]: https://www.espressif.com/
[espflash]: https://github.com/esp-rs/espflash
[embassy]: https://github.com/embassy-rs/embassy
[`esp-hal`]: https://github.com/esp-rs/esp-hal/tree/main/esp-hal
[`esp-radio`]: https://github.com/esp-rs/esp-hal/tree/main/esp-radio
[ESP-NOW]: https://www.espressif.com/en/solutions/low-power-solutions/esp-now
[xtensa-lx and xtensa-lx-rt]: https://github.com/esp-rs/esp-hal/tree/main/xtensa-lx-rt
[esp-generate]: https://github.com/esp-rs/esp-generate
[book]: https://github.com/esp-rs/book
[esp-config]: https://crates.io/crates/esp-config
[docs.espressif.com/projects/rust]: https://docs.espressif.com/projects/rust/index.html
[esp-hal 1.0 beta]: https://developer.espressif.com/blog/2025/02/rust-esp-hal-beta/
[semver experiments]: https://github.com/MabezDev/semver-playground