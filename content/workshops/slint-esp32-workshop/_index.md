---
title: "Slint with Rust no_std on ESP32 Workshop"
date: 2025-06-03T00:00:00+01:00
tags: ["Workshop", "Slint", "Rust", "ESP32", "no_std", "Embedded UI"]
---

Welcome to the **Slint with Rust no_std on ESP32** workshop!

## About this workshop

This hands-on workshop is designed to introduce embedded developers to designing modern graphical user interfaces using the [Slint UI Toolkit](https://slint.dev) in Rust for the ESP32 platform, specifically in a `no_std` context.

Unlike traditional workflows that start directly on embedded hardware, this training emphasizes a **desktop-first** approach: you begin by developing and testing the UI on your desktop, then port the same code to an embedded platform. This is made possible thanks to Slint’s cross-platform design and support for Rust in both `std` and `no_std` environments.

While Slint supports other languages such as C++ or Python, this workshop is focused entirely on **pure Rust**.

> Although the examples run on the ESP32-S3, the concepts can be ported to other ESP32 targets with display capability.

## Agenda

With the prerequisites in place, follow the assignments in order:

- [Assignment 1: Environment Setup](assignment-1) — install Rust toolchain, dependencies, and tools for Slint and ESP32.
- [Assignment 2: Run GUI on Desktop](assignment-2) — create a simple two-tab UI with the Slint logo and a placeholder for Wi-Fi list.
- [Assignment 3: Run GUI on ESP32-S3](assignment-3) — port the same app to embedded hardware such as ESoPe Board (SLD_C_W_S3), ESP32-S3-BOX-3, or ESP32-S3-LCD-Ev-Board.
- [Assignment 4: Add Wi-Fi list on Desktop](assignment-4) — populate the placeholder list with available networks using the OS backend.
- [Assignment 5: Add Wi-Fi scan on ESP32](assignment-5) — replace the desktop data source with live Wi-Fi scan results from the ESP32.
- [Assignment 6: Explore more Slint examples](assignment-6) — interactive demos and links to advanced usage patterns.

## Prerequisites

**Hardware:**

- ESoPe Board SLD_C_W_S3 with Schukat Smartwin display-concept (RGB interface)
- Alternative boards: ESP32-S3-BOX-3, ESP32-S3-LCD-Ev-Board
- USB-C or USB micro cable

**Software:**

- [Rust toolchain](https://rustup.rs) (stable channel is sufficient)
- [`espup`](https://github.com/esp-rs/espup) to install and configure `esp-rust` toolchain (**recommended method**)
- `espflash` for flashing firmware
- `cargo-generate` for creating project templates
- [JetBrains RustRover](https://www.jetbrains.com/rust/) or [CLion](https://www.jetbrains.com/clion/) — **recommended IDEs**, available free for students and open source projects
- Alternatively, VS Code with Rust Analyzer, or any terminal-based Rust development setup

JetBrains IDEs (CLion or RustRover) are highly recommended and provide excellent Rust tooling out of the box. These tools are available free of charge for students and open source contributors.

Follow [Slint Embedded Setup Instructions](https://slint.dev/docs/rust/esp32.html) for more details.

## Time Estimate

{{< alert icon="mug-hot">}}
**Estimated time: 2–3 hours**
{{< /alert >}}

Pacing depends on your experience with embedded Rust and Slint.

## Target Audience

This workshop is suitable for:

- Embedded developers with C/C++ background exploring Rust
- Rust developers curious about no_std embedded development
- Anyone interested in building fast, modern GUIs for microcontrollers

Basic knowledge of embedded systems and Rust syntax is helpful but not required.

## Support and Feedback

If you get stuck or have feedback, please open a [discussion on GitHub](https://github.com/espressif/developer-portal/discussions) or reach out to the [Slint Discord](https://slint.dev/community.html).

## Feedback and Contributions

This workshop is available on GitHub and welcomes contributions and improvements. If you encounter issues or want to propose updates, feel free to [open a discussion or pull request](https://github.com/espressif/developer-portal/discussions).

## Goals

By the end of this workshop, you will:

- Be able to create a UI with Slint in Rust using `no_std`
- Deploy graphical apps to ESP32-S3 boards with display and optional touch
- Understand how to separate logic from presentation with properties and callbacks
- Integrate the Slint runtime with an embedded framebuffer and event loop

---


## Credits

This workshop was created in collaboration between [Espressif Systems](https://www.espressif.com), [Slint](https://slint.dev), [ESoPe](https://esope.de), and [Schukat](https://www.schukat.com).

If you are interested in organizing a workshop or need support, we recommend reaching out to the trainer: [Michael Winkelmann](https://winkelmann.site/).

Let's get started: [Assignment 1](assignment-1)