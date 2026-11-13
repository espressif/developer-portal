---
title: "Getting started with esp-hal: Introduction"
date: 2026-11-13
showTableOfContents: true
series: ["WS-RUST-ESP-HAL"]
series_order: 1
showAuthor: false
---

Before you write any code, this page gives you a map of the pieces you will use during the workshop: what `no_std` means, what esp-hal is, and which crates sit around it.

## Two ways to run Rust on Espressif chips

Espressif chips can run Rust in two different ways:

- **`std` on top of ESP-IDF**: Rust code calls into the ESP-IDF C framework (FreeRTOS, lwIP, the Wi-Fi driver) through the [`esp-idf-hal`](https://github.com/esp-rs/esp-idf-hal) and [`esp-idf-svc`](https://github.com/esp-rs/esp-idf-svc) crates. You get the Rust standard library, threads, and the whole ESP-IDF ecosystem, at the cost of a C build system and a larger binary.
- **`no_std` bare metal**: Rust code runs directly on the hardware with no operating system underneath. You only have the [`core`](https://doc.rust-lang.org/core/) library (and optionally [`alloc`](https://doc.rust-lang.org/alloc/)), but the whole firmware is Rust, builds with plain `cargo`, and you control every byte of it.

This workshop uses the **`no_std`** approach with **esp-hal**.

## What is esp-hal?

[esp-hal](https://github.com/esp-rs/esp-hal) is a hardware abstraction layer (HAL) for Espressif chips, written in Rust and maintained by Espressif together with the esp-rs community. It gives you safe, typed drivers for the chip peripherals: GPIO, UART, SPI, I2C, RMT, LEDC, ADC, timers, DMA, and many more.

Three ideas show up all over esp-hal:

- **Peripherals are values.** `esp_hal::init()` returns a `Peripherals` struct with one field per peripheral and per pin, for example `peripherals.RMT` or `peripherals.GPIO8`. Passing a field into a driver moves it, so the compiler stops two drivers from using the same pin.
- **Drivers are configured with config structs.** Most drivers take a `Config` with builder-style setters, for example `InputConfig::default().with_pull(Pull::Up)`.
- **Blocking and async modes.** Many drivers come in a `Blocking` and an `Async` flavor. You will start with blocking code and switch to async in Assignment 2.

### Stable and unstable APIs

esp-hal 1.0 split its API into a **stable** part with semver guarantees and an **unstable** part that can still change between releases. Only a few drivers, such as GPIO, UART, SPI, and I2C, are stable so far. Everything this workshop needs beyond that, including RMT, Embassy support, and Wi-Fi, is behind the `unstable` feature, so all projects in this workshop enable it.

## The crates around esp-hal

esp-hal is the center of a group of crates that live in the same [repository](https://github.com/esp-rs/esp-hal):

| Crate | What it does | Used in |
|-------|--------------|---------|
| `esp-hal` | Peripheral drivers | All assignments |
| `esp-bootloader-esp-idf` | Adds the application descriptor that the ESP-IDF second-stage bootloader expects | All assignments |
| `esp-println` | `print!`/`println!` and a `log` backend over the serial port | All assignments |
| `esp-backtrace` | Panic handler that prints a backtrace | All assignments |
| `esp-alloc` | Heap allocator, needed by the radio drivers | Assignments 2 and 3 |
| `esp-rtos` | Scheduler and time driver for [Embassy](https://embassy.dev/) and the radio drivers | Assignments 2 and 3 |
| `esp-radio` | Wi-Fi, Bluetooth LE, and ESP-NOW drivers | Assignments 2 and 3 |

Two tools complete the picture:

- [`esp-generate`](https://github.com/esp-rs/esp-generate) creates a new project from a template, with the right dependencies, linker settings, and target for your chip.
- [`espflash`](https://github.com/esp-rs/espflash) flashes the firmware to the board and shows its serial output. Generated projects use it as the `cargo run` runner, so `cargo run` builds, flashes, and opens the monitor in one step.

## Async with Embassy

[Embassy](https://embassy.dev/) is a framework for writing embedded firmware with Rust `async`/`await`. Instead of threads, you write `async` tasks; while a task waits for a timer, a pin, or a network packet, the executor runs other tasks or puts the CPU to sleep. On Espressif chips, `esp-rtos` provides the time driver and starts the Embassy executor for you.

The first assignment uses plain blocking code so you can see every step. Assignments 2 and 3 use Embassy, because Wi-Fi and ESP-NOW are much easier to write with async.

## RISC-V and Xtensa

All the boards in this workshop use **RISC-V** chips, which are supported by the standard Rust toolchain from `rustup`. Older Espressif chips (ESP32, ESP32-S2, ESP32-S3) use the **Xtensa** architecture, which needs a forked Rust compiler installed with `espup`. The [Setup](../setup/) page shows both.

## Learn more

- [The esp-hal documentation](https://docs.espressif.com/projects/rust/esp-hal/latest/): API reference for each chip
- [The esp-hal examples](https://github.com/esp-rs/esp-hal/tree/main/examples): working examples for most drivers
- [Embedded Rust Training for ESP32-C3](https://docs.espressif.com/projects/rust/no_std-training/): a longer, self-paced course that builds a data logger with esp-hal
- [The Rust on ESP Book](https://docs.espressif.com/projects/rust/book/): the overview of the whole Rust on Espressif ecosystem

## Next step

[Setup](../setup/)

[Return to the workshop main page](/workshops/rust-esp-hal-intro/)
