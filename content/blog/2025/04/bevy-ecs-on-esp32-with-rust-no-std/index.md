---
title: "Bevy Entity Component System on ESP32 with Rust no_std"
date: "2025-04-09"
showAuthor: false
authors:
  - "juraj-michalek"
tags: ["Embedded Systems", "ESP32", "ESP32-S3", "ESP32-C3", "Rust", "Bevy", "no_std", "ECS", "WASM"]
---

## Introduction

Embedded development in Rust is rapidly evolving, and one of exciting new developments is the introduction
of [**no_std** support](https://www.youtube.com/live/Ao2gXd_CgUc?si=emIdJlz5fbGJQAx6&t=236)
into the [Bevy Entity Component System (ECS)](https://bevyengine.org/learn/quick-start/getting-started/ecs/).
This improvement allows developers to leverage the powerful and modular design of Bevy ECS
on resource‑constrained devices like the ESP32.

In this article, we demonstrate how to build an embedded application using Rust no_std and Bevy ECS
on an ESP32 device, using a simulation of [Conway’s Game of Life](https://github.com/georgik/esp32-conways-game-of-life-rs) and
[ESP32 Spooky Maze Game](https://github.com/georgik/esp32-spooky-maze-game) as our examples.

<div style="display: flex; justify-content: center; margin: 20px 0;">
  <iframe
    src="https://developer.espressif.com/persist/rust/esp32-conways-game-of-life-rs/"
    width="640"
    height="480"
    style="border: none; overflow: hidden;"
    scrolling="no"
    title="Conway's Game of Life WASM Demo">
  </iframe>
</div>

Although Conway’s Game of Life is a classic cellular automaton, our primary focus is on structuring embedded applications using Bevy ECS principles.

This approach helps organize code into clean, modular systems, ideal for interactive and data-intensive applications.

{{< youtube BeDaT9ydHU0 >}}

The second example, the Spooky Maze Game, is more complex, demonstrating an event-based approach to integrate peripherals like accelerometers with application logic.

{{< youtube JdYz991F9S8 >}}

## What is Bevy ECS?

Bevy ECS is the core data‑oriented architecture of the Bevy game engine. It provides a way to structure programs by breaking them into:

 - **Entities** which represent objects
 - **Components** which hold data
 - **Systems** which operate on entities with specific components

With the introduction of [no_std support](https://www.youtube.com/live/Ao2gXd_CgUc?si=emIdJlz5fbGJQAx6&t=236), Bevy ECS can now be used in bare‑metal environments where the standard library is not available—making it a compelling choice for embedded
[Rust development for ESP32](https://developer.espressif.com/blog/2025/02/rust-esp-hal-beta/).

## Advantages for Embedded Rust Developers

Many advantages of Rust for embedded development were described in the article [Rust + Embedded: A Development Power Duo](https://developer.espressif.com/blog/rust-embedded-a-development-power-duo/).

Here are some specific advantages of using ECS in Rust applications:

- **Modularity and Maintainability:** ECS encourages the separation of data and behavior into independent systems, which leads to clearer, easier-to-maintain code.
- **Efficient Resource Management:** The data‑oriented design can lead to better cache utilization and efficient processing, critical for devices with limited memory and processing power.
- **Scalability:** Even on microcontrollers, ECS allows you to extend your application with additional features or behaviors without significant restructuring.
- **Familiarity:** Developers experienced with ECS on desktop or game development can leverage similar patterns on embedded platforms.

## Hardware and Software Setup

### Hardware Requirements

- **ESP32 Development Board:** ESP32-S3, ESP32-C3, or similar variants.
- **Display Module:** For example, an ILI9486-based display connected via SPI.

If you're uncertain which hardware to choose, we recommend the [ESP32-S3-BOX-3](https://github.com/espressif/esp-box?tab=readme-ov-file#esp-box-aiot-development-framework) featuring ESP32-S3 with PSRAM and a display with touch control.

### Software Requirements

- [Rust Toolchain](https://github.com/esp-rs/espup) Use upstream Rust toolchain (version 1.85.0.0 or later) for RISC-V targets (ESP32-C, ESP32-P, ESP32-H) or installation via [espup](https://github.com/esp-rs/espup) for Xtensa targets (ESP32, ESP32-S).

```sh
cargo install espup
espup install # For ESP32, ESP32-S
```

- [espflash](https://github.com/esp-rs/espflash): Rust implementation of flashing tool for ESP32.

```sh
cargo install espflash
```
Note: The Rust tooling could be also installed by [`cargo binstall`](https://github.com/cargo-bins/cargo-binstall).

### Crates Used in the Project

- [ESP‑HAL](https://github.com/esp-rs/esp-hal) and [mipidsi](https://github.com/almindor/mipidsi): These crates provide the hardware abstraction and display support for ESP32 devices.
- [Bevy ECS (no_std)](https://github.com/bevyengine/bevy/issues/15460) The latest no_std support in Bevy ECS lets you use its powerful ECS model on bare‑metal targets.

## Building the Application

The Conway’s Game of Life example manages a simulation grid as an ECS resource. Systems update the game state and render to an off-screen framebuffer, which is then output to a physical display. A WASM version also simulates the display using an HTML canvas in a web browser.

Flashing the binary onto your hardware is done using [espflash](https://github.com/esp-rs/espflash) or [probe-rs](https://github.com/probe-rs/probe-rs) configured in [`.config/cargo.toml`](https://github.com/georgik/esp32-conways-game-of-life-rs/blob/main/esp32-c3-lcdkit/.cargo/config.toml).

## Running Applications - Conway's Game of Life

- [Source code](https://github.com/georgik/esp32-conways-game-of-life-rs)

### ESP32-S3-BOX-3 - Conway

```sh
cd esp32-s3-box-3
cargo run --release
```

### ESP32-C3 - Conway

Use the upstream Rust toolchain with the RISC‑V target:
```sh
cd esp32-c3-lcdkit
cargo run --release
```

### ESP32 Spooky Maze Game

In this small application, a player navigates a maze collecting coins while using special power‑ups to overcome obstacles. When collisions occur (with coins, NPCs, etc.), events are dispatched so that game logic remains decoupled from hardware‑specific input.

- [Source code](https://github.com/georgik/esp32-spooky-maze-game)

#### ESP32-S3-BOX-3 - Spooky

```sh
cd spooky-maze-esp32-s3-box-3
cargo run --release
```

#### Desktop - Spooky

```sh
cd spooky-maze-desktop
cargo run
```

### Structure of main.rs

Bevy has support for Builder pattern which greatly simplifies the way how the application needs to be structured and allows easy connection between different systems.

Here's sample code:

```rust
let mut app = App::new();
    app.add_plugins((DefaultPlugins,))
        .insert_non_send_resource(DisplayResource { display })
        .insert_non_send_resource(AccelerometerResource { sensor: icm_sensor })
        .insert_resource(FrameBufferResource::new())
        .add_systems(Startup, systems::setup::setup)
        .add_event::<PlayerInputEvent>()
        .add_event::<CoinCollisionEvent>()
        .add_event::<NpcCollisionEvent>()
        .add_systems(
            Update,
            (
                player_input::dispatch_accelerometer_input::<MyI2c, MyI2cError>,
                systems::process_player_input::process_player_input,
                collisions::npc::detect_npc_collision,
                collisions::npc::handle_npc_collision,
                systems::npc_logic::update_npc_movement,
                systems::game_logic::update_game,
                embedded_systems::render::render_system,
            ),
        )
        .run();

```



### Architecture of the Application

#### Shared ECS Core

The app’s core is implemented in the spooky-core crate using Bevy ECS. This core contains all app logic (maze generation, collision detection, event handling, etc.) and is compiled with no_std for embedded targets and with std for desktop.

Because Bevy’s built‑in rendering and UI systems aren’t available in no_std mode, we implemented a custom renderer using the Embedded Graphics crate. This renderer draws the maze, sprites, and HUD elements to an off‑screen framebuffer, then flushes the output to the physical display. In addition, a sprite filtering layer (implemented via a custom SpriteBuf wrapper) discards “magic pink” pixels that denote transparency in our sprite assets.


#### Custom Renderer for Embedded

On embedded devices, the demo uses a custom renderer that:

- Draws the maze background and sprites to an off‑screen framebuffer.

- Applies a filtering layer to skip “magic pink” pixels (which represent transparency). This technique is known from DOS games.

- Flushes the framebuffer to the physical display via SPI using the mipidsi crate.

#### Event‑Based Collision and Input

All input (keyboard or accelerometer) is dispatched as events into the ECS. Separate systems process these events to update game state (for example, moving the player or handling collisions with coins, NPCs, etc.). This design makes it easier to add new types of interactions without tightly coupling the game logic with the underlying hardware.

#### Resource Injection

Resources such as the maze, player position, HUD state and hardware peripherals like the ICM42670 accelerometer are injected as Bevy resources (using NonSend for non‑Sync hardware drivers). This allows our ECS systems to access sensor data seamlessly without directly coupling to hardware APIs.

## Conclusion

The integration of no_std support into Bevy ECS opens up exciting new possibilities for embedded development in Rust. By leveraging modern ECS design patterns on devices like the ESP32, developers can create modular, efficient, and scalable applications—even in resource‑constrained environments. Whether you’re a seasoned embedded developer or a game developer exploring new hardware, this approach demonstrates that you can build powerful applications with Rust and Bevy ECS on ESP32 devices.

## Recommended IDE for Development

[Rust Rover](https://www.jetbrains.com/rust/) or [CLion with Rust Rover plugin](https://developer.espressif.com/blog/clion/) are great tools for Rust Embedded Development.

Another great option is [VS Code](https://code.visualstudio.com/) with Rust plugins.

All IDEs mentioned above support simulation of ESP32 using [Wokwi simulator](https://plugins.jetbrains.com/plugin/23826-wokwi-simulator).

## Contributing

Contributions are welcome! If you’d like to help improve the demo, add new features, or extend hardware support, please submit a pull request. We especially encourage contributions that further refine the embedded no_std integration or improve the custom rendering pipeline.