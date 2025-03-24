---
title: "Bevy Entity Component System on ESP32 with Rust no_std"
date: "2025-03-06"
showAuthor: false
authors:
  - "juraj-michalek"
tags: ["Embedded Systems", "ESP32", "Rust", "Bevy ECS", "no_std", "ECS", "WASM"]
---

## Introduction

Embedded development in Rust is rapidly evolving, and one of exciting new developments is the introduction
of [**no_std** support](https://www.youtube.com/live/Ao2gXd_CgUc?si=emIdJlz5fbGJQAx6&t=236)
into the [Bevy Entity Component System (ECS)](https://bevyengine.org/learn/quick-start/getting-started/ecs/).
This improvement allows developers to leverage the powerful and modular design of Bevy ECS
on resource‑constrained devices like the ESP32.
In this article, we demonstrate how to build an embedded application using Rust no_std and Bevy ECS
on an ESP32 device, using a simulation of [Conway’s Game of Life](https://github.com/georgik/esp32-conways-game-of-life-rs) as our example.

Although Conway’s Game of Life is a classic cellular automaton,
our focus is on showcasing how to structure an embedded application using Bevy ECS principles.
This approach not only helps organize code into clean, modular systems for interactive and data intensive appl;ications.

## What is Bevy ECS?

Bevy ECS is the core data‑oriented architecture of the Bevy game engine. It provides a way to structure programs by breaking them into entities (which represent objects), components (which hold data), and systems (which operate on entities with specific components). With the introduction of [no_std support](https://www.youtube.com/live/Ao2gXd_CgUc?si=emIdJlz5fbGJQAx6&t=236), Bevy ECS can now be used in bare‑metal environments where the standard library is not available—making it a compelling choice for embedded
[Rust development for ESP32](https://developer.espressif.com/blog/2025/02/rust-esp-hal-beta/).

## Advantages for Embedded Rust Developers

- **Modularity and Maintainability:** ECS encourages the separation of data and behavior into independent systems, which leads to clearer, easier-to-maintain code.
- **Efficient Resource Management:** The data‑oriented design can lead to better cache utilization and efficient processing, critical for devices with limited memory and processing power.
- **Scalability:** Even on microcontrollers, ECS allows you to extend your application with additional features or behaviors without significant restructuring.
- **Familiarity:** Developers experienced with ECS on desktop or game development can leverage similar patterns on embedded platforms.

## Hardware and Software Setup

### Hardware Requirements

- **ESP32 Development Board:** ESP32-S3, ESP32-C3, or similar variants.
- **Display Module:** For example, an ILI9486-based display connected via SPI.
- **Additional Peripherals:** Optional buttons, sensors, or LEDs depending on your project.

### Software Requirements

- **Rust Toolchain:** Use upstream Rust toolchain (version 1.85.0.0 or later) for RISC-V targets (ESP32-C, ESP32-P, ESP32-H) or installation via [espup](https://github.com/esp-rs/espup) for Xtensa targets (ESP32, ESP32-S).
- **ESP‑HAL and mipidsi:** These crates provide the hardware abstraction and display support for ESP32 devices.
- **Bevy ECS (no_std):** The latest no_std support in Bevy ECS lets you use its powerful ECS model on bare‑metal targets.

## Building the Application

Our example implements Conway’s Game of Life, where the simulation grid is managed as an ECS resource. The Bevy ECS world organizes systems for updating the game state and rendering to an off‑screen framebuffer, which is then flushed to a physical display. We will showcase also an option to use WASM for rendering the same application in the web browser.

For ESP32-based projects, the code is compiled as a bare‑metal Rust application using no_std. Flashing the binary onto your hardware is done using [espflash](https://github.com/esp-rs/espflash) or [probe-rs](https://github.com/probe-rs/probe-rs) configured in [`.config/cargo.toml`](https://github.com/georgik/esp32-conways-game-of-life-rs/blob/main/esp32-c3-lcdkit/.cargo/config.toml). For the WASM version, the application runs in the browser by simulating a display via an HTML canvas.

## Installing tooling

The tooling could be installed by [`cargo binstall`](https://github.com/cargo-bins/cargo-binstall) or simply from source code:

```sh
cargo install espup espflash
espup install # For ESP32, ESP32-S
```

## Running the Application

<video controls width="640">
    <source src="https://github.com/user-attachments/assets/e9d48ff7-b14c-4874-9521-fe59e915bc76" type="video/mp4">
    Your browser does not support the video tag. You can view the video <a href="https://github.com/user-attachments/assets/e9d48ff7-b14c-4874-9521-fe59e915bc76">here</a>.
</video>


ESP32-C3:
Use the upstream Rust toolchain with the RISC‑V target:
```sh
cd esp32-c3-lcdkit
cargo run --release
```

## Example Code Overview
Our application uses the following structure:

- FrameBufferResource: Manages an off‑screen framebuffer using the embedded-graphics-framebuf crate.
- GameOfLifeResource: Holds the simulation grid and generation counter.
- RngResource: Provides a random number generator seeded from the browser.
- DisplayResource: Wraps an HTML canvas 2D context for simulation output.
- ECS Systems:
  - `update_game_of_life_system`: Updates the game grid based on Conway’s rules.
  - `render_system`: Draws the game grid, overlays text, and updates the canvas.
These components come together in the ECS world, which is run in an animation loop using `requestAnimationFrame`.

## Conclusion
The integration of no_std support into Bevy ECS opens up exciting new possibilities for embedded development in Rust. By leveraging modern ECS design patterns on devices like the ESP32, developers can create modular, efficient, and scalable applications—even in resource‑constrained environments. Whether you’re a seasoned embedded developer or a game developer exploring new hardware, this approach demonstrates that you can build powerful applications with Rust and Bevy ECS on ESP32 devices.

## Recommended IDE for Development

[Rust Rover](https://www.jetbrains.com/rust/) or [CLion with Rust Rover plugin](https://developer.espressif.com/blog/clion/) are great tools for Rust Embedded Development.

Another great option is [VS Code](https://code.visualstudio.com/) with Rust plugins.

All IDEs mentioned above supports simulation of ESP32 using [Wokwi simulator](https://plugins.jetbrains.com/plugin/23826-wokwi-simulator).
