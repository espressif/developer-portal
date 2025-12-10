---
title: "Slint with Rust on ESP32 Workshop - no_std and std"
date: 2025-06-03T00:00:00+01:00
tags: ["Workshop", "Slint", "Rust", "ESP32", "no_std", "std", "Embedded UI"]
---

Welcome to the **Slint with Rust on ESP32** workshop!

## About this workshop

This hands-on workshop is designed to introduce embedded developers to designing modern graphical user interfaces using the [Slint UI Toolkit](https://slint.dev) in Rust for the ESP32 platform. The workshop supports **both `no_std` (bare-metal) and `std` (ESP-IDF) approaches**, with **`no_std` as the primary and recommended path** due to its simplicity, better performance, and official Espressif support.

Unlike traditional workflows that start directly on embedded hardware, this training emphasizes a **desktop-first** approach: you begin by developing and testing the UI on your desktop, then port the same code to an embedded platform. This is made possible thanks to Slint's cross-platform design and support for Rust in both `no_std` and `std` environments.

While Slint supports other languages such as C++ or Python, this workshop is focused entirely on **pure Rust**.

> Although the examples run on the ESP32-S3, the concepts can be ported to other [ESP32 targets with display capability](https://github.com/espressif/esp-bsp).

## Choosing Your Development Approach

This workshop supports both development approaches with **`no_std` (bare-metal) as the primary recommendation**:

### `no_std` (Bare-Metal) - **RECOMMENDED** ✅

**Why choose `no_std`:**
- **Much simpler setup** - No C/C++ toolchain required
- **Pure Rust** - No ESP-IDF complexity  
- **Official Espressif support** - First-class citizen in esp-hal ecosystem
- Smaller binary size and memory footprint
- Better performance and lower latency
- Direct hardware control with esp-hal
- Faster compilation times
- More predictable behavior
- **Highly portable code** - Works across different embedded platforms

**When to choose `no_std`:** Recommended for most embedded projects, especially when you want a pure Rust experience.

### `std` (ESP-IDF) - Alternative Approach

**When to choose `std`:**
- You specifically need existing ESP-IDF C/C++ components
- You have a large existing C/C++ codebase to integrate
- You require std-only crates that don't have no_std alternatives

**Considerations with `std`:**
- **Complex setup** - Requires full C/C++ ESP-IDF toolchain
- Larger binary size and higher memory usage
- Slower compilation times
- Platform-specific code - harder to port to other embedded platforms

**Default Choice:** Start with **`no_std`** for the best embedded Rust experience. Only switch to `std` if you have specific requirements that necessitate it.

## Agenda

With the prerequisites in place, follow the assignments in order:

- [Assignment 1: Environment Setup](assignment-1) — install Rust toolchain, dependencies, and tools for Slint and ESP32.
- [Assignment 2: Run GUI on Desktop](assignment-2) — create a simple two-tab UI with the Slint logo and a placeholder for Wi-Fi list.
- [Assignment 3: Run GUI on ESP32-S3](assignment-3) — port the same app to embedded hardware such as M5Stack CoreS3, ESoPe Board (SLD_C_W_S3), ESP32-S3-BOX-3, or ESP32-S3-LCD-EV-Board.
- [Assignment 4: Add Wi-Fi list on Desktop](assignment-4) — populate the placeholder list with available networks using the OS backend.
- [Assignment 5: Add Wi-Fi scan on ESP32](assignment-5) — replace the desktop data source with live Wi-Fi scan results from the ESP32.
- [Assignment 6: Explore more Slint examples](assignment-6) — interactive demos and links to advanced usage patterns.

## Prerequisites

**Hardware:**

- **[M5Stack CoreS3](https://shop.m5stack.com/products/m5stack-cores3-esp32s3-lotdevelopment-kit)** (recommended - touchscreen, speakers, microphone)
- [ESoPe Board SLD_C_W_S3 with Schukat Smartwin display-concept](https://esope.de) (RGB interface) 
- Alternative boards: [ESP32-S3-BOX-3](https://github.com/espressif/esp-bsp/tree/master/bsp/esp32_s3_box_3), [ESP32-S3-LCD-EV-Board](https://github.com/espressif/esp-bsp/tree/master/bsp/esp32_s3_lcd_ev_board)
- USB-C cable for M5Stack CoreS3 and ESP32-S3-BOX-3, or USB micro cable with [ESP-Prog](https://docs.espressif.com/projects/esp-iot-solution/en/latest/hw-reference/ESP-Prog_guide.html) for ESoPe board

**Software:**

- [Rust toolchain](https://rustup.rs) (stable channel is sufficient)
- [`espup`](https://github.com/esp-rs/espup) to install and configure `esp-rust` toolchain (**recommended method**)
- `espflash` for flashing firmware
- `cargo-generate` for creating project templates
- [JetBrains RustRover](https://www.jetbrains.com/rust/) or [CLion](https://www.jetbrains.com/clion/) — **recommended IDEs**, available free for students and open source projects
- Alternatively, VS Code with Rust Analyzer, or any terminal-based Rust development setup

JetBrains IDEs (CLion or RustRover) are highly recommended and provide excellent Rust tooling out of the box. These tools are available free of charge for students and open source contributors.

Follow [Slint Embedded Setup Instructions](https://docs.slint.dev/latest/docs/slint/) for more details.

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

This workshop was created in collaboration between [Espressif Systems](https://www.espressif.com), [Slint](https://slint.dev/esp32), [M5Stack](https://m5stack.com), [ESoPe](https://esope.de), and [Schukat](https://shop.schukat.com/de/de/EUR/search/esope).

If you are interested in organizing a workshop or need support, we recommend reaching out to the trainer: [Michael Winkelmann](https://winkelmann.site/).

Let's get started: [Assignment 1](assignment-1)
