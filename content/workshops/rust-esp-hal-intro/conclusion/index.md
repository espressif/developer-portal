---
title: "Getting started with esp-hal: Conclusion"
date: 2026-11-13
showTableOfContents: true
series: ["WS-RUST-ESP-HAL"]
series_order: 6
showAuthor: false
---

Congratulations, you made it to the end of the workshop!

## What you learned

In this workshop, you:

- Installed the Rust toolchain, `espflash`, and `esp-generate`, and learned when you would need `espup`
- Generated esp-hal projects from the esp-hal template and learned what each generated file does
- Drove a WS2812 RGB LED with the RMT peripheral, first with blocking code and then with async
- Wrote async firmware with Embassy and `esp-rtos`
- Connected your board to Wi-Fi with `esp-radio` and controlled it from a shared web app
- Exchanged messages between boards with ESP-NOW, without any network infrastructure

## Where to go next

- [esp-hal examples](https://github.com/esp-rs/esp-hal/tree/main/examples): working examples for most drivers, including Bluetooth LE, IEEE 802.15.4, and OTA updates
- [esp-hal documentation](https://docs.espressif.com/projects/rust/esp-hal/latest/): select your chip to see exactly which drivers it supports
- [Embedded Rust Training for ESP32-C3](https://docs.espressif.com/projects/rust/no_std-training/): build a data logger with sensors, MQTT, provisioning, and OTA updates
- [Learning Embedded Rust with uFerris](/workshops/embedded-rust-uferris/): learn to find your way around embedded Rust documentation
- [Embassy book](https://embassy.dev/book/): everything about async embedded Rust
- [awesome-esp-rust](https://github.com/esp-rs/awesome-esp-rust): a curated list of crates, projects, and learning resources

## Get help

The esp-rs community meets in the [esp-rs Matrix channel](https://matrix.to/#/#esp-rs:matrix.org). Questions are welcome, whatever your level.

## Feedback

If you have any feedback about this workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).

[Return to the workshop main page](/workshops/rust-esp-hal-intro/)
