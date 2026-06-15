---
title: "Empowered by the Ecosystem: Learning Embedded Rust with uFerris"
date: 2026-05-18T00:00:00+01:00
lastmod: 2026-06-15
tags: ["Workshop", "ESP32-C3", "Rust", "esp-hal", "Embedded", "GPIO", "I2C", "uFerris"]
summary: "A hands-on embedded Rust workshop using the uFerris learning platform and ESP32-C3."
---

Welcome to **Empowered by the Ecosystem: Learning Embedded Rust with uFerris**! This hands-on workshop teaches you how to navigate the embedded Rust ecosystem and write bare-metal Rust for the ESP32-C3 using `esp-hal`.

## About This Workshop

This workshop takes a different approach to learning embedded development. Instead of walking you through peripheral configurations step by step, you'll learn *how to teach yourself* — by navigating the embedded Rust ecosystem, reading documentation effectively, and adapting existing examples to your own needs.

By the end of this workshop, you will be able to:

- **Navigate the embedded Rust ecosystem** — find the right abstractions, understand the layers, and know where to look for answers
- **Read embedded Rust documentation** — in crate docs, source code, and example repositories
- **Apply the Instantiate → Configure → Control pattern** — a mental model that works for *every* peripheral, *every* HAL, *every* driver crate
- **Adapt existing examples** to new use cases by exploring configuration options and control methods in the documentation

## How This Workshop Works

Every hands-on module follows the same workflow:

1. **Read** — Start with a working example
2. **Understand** — Study the code and map it to the documentation
3. **Adapt** — Modify the example to do something *different* by discovering new options in the docs
4. **Extend** — Stretch goals push you to navigate unfamiliar documentation independently

## Agenda

- [Introduction: Setup and Overview](introduction/): Hardware overview, toolchain setup, and your first flash
- [Overview: The Embedded Rust Ecosystem](overview/): Understanding the abstraction layers and the Instantiate → Configure → Control mental model
- [Assignment 1: GPIO Exercises](assignment-2/): Blinky, button input, and cross-HAL comparison
- [Assignment 2: I2C Exercises](assignment-3/): Bus scanning, I/O expander control, and adaptation challenges
- [Assignment 3: Interrupt Exercises](assignment-4/): GPIO interrupts and I/O expander interrupt
- [Assignment 4: BSP Exercises](assignment-5/): Redoing exercises with the uFerris Board Support Package
- [Wrap-Up and Next Steps](assignment-6/): Mental model recap and where to go from here

## Prerequisites

Required hardware:

- Computer running Linux, Windows, or macOS
- ESP32-C3 development board (e.g., Seeed Studio XIAO ESP32-C3)
- USB-C cable (must support data, not just charging)

Required software:

- [Rust toolchain](https://rustup.rs/) with `riscv32imc-unknown-none-elf` target
- [espflash](https://github.com/esp-rs/espflash) for flashing firmware
- [esp-generate](https://github.com/esp-rs/esp-generate) for creating new projects
- [Visual Studio Code](https://code.visualstudio.com/) (recommended editor)

## Time Requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 360 min (full day)**
{{< /alert >}}

## Feedback

If you have any feedback about the workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).

---
