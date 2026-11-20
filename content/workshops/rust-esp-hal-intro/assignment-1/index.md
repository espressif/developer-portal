---
title: "Getting started with esp-hal: Assignment 1"
date: 2026-11-13
showTableOfContents: true
series: ["WS-RUST-ESP-HAL"]
series_order: 3
showAuthor: false
---

In this assignment, you will generate your first esp-hal project, find your way around the generated files, and then add a driver crate so that the onboard RGB LED blinks red, green, and blue.

<!-- TODO: link to the solutions repository -->

## 1. Generate the project

`esp-generate` creates projects from a **template**. Its built-in template follows the latest released esp-hal crates. In this workshop you will use the template that lives in the [esp-hal repository](https://github.com/esp-rs/esp-hal/tree/main/template) instead: it pins every esp-rs crate to the exact esp-hal commit it was generated from, which gives you the newest chip support (including the ESP32-S31) with crates that are known to work together.

esp-hal changes every day, so for this workshop you'll generate from [`base48-workshop`](https://github.com/Hahihula/esp-hal/tree/base48-workshop), a branch with a snapshot of esp-hal that everything in this workshop was tested with. You select it with `--template <owner>/<repository>@<branch>`. Outside the workshop, use `--template esp-rs/esp-hal` to get the newest esp-hal.

### Interactive mode

Run `esp-generate` with just the template and a project name:

```bash
esp-generate --template Hahihula/esp-hal@base48-workshop blinky
```

`esp-generate` downloads the template and opens a terminal menu. Pick your chip, then look through the options. Each option has a short description at the bottom of the screen; the ones you will meet in this workshop are:

- **unstable-hal**: enables esp-hal's unstable drivers, including RMT, which you need for the LED
- **log**, under *Flashing, logging and debugging (espflash)*: prints messages to the serial monitor with the `log` crate
- **esp-backtrace**, in the same group: a panic handler that prints what went wrong and where
- **alloc**: adds a heap allocator (Assignments 2 and 3)
- **embassy**: adds the Embassy async framework and the `esp-rtos` scheduler (Assignments 2 and 3)
- **wifi**: adds the `esp-radio` Wi-Fi driver (Assignments 2 and 3)

For this assignment, enable **unstable-hal**, **log**, and **esp-backtrace**, then press `s` to save and generate the project. To quit without generating anything, press `q` and confirm with `y`.

### Headless mode

The same project can be generated without the menu by passing every option with `-o`. This is handy for scripts and for this workshop: if you got lost in the menu, delete the `blinky` folder and run the command for your board:

{{< tabs group="board" >}}
{{< tab label="S31-CoreBoard" >}}
```bash
esp-generate --template Hahihula/esp-hal@base48-workshop --headless -o esp32s31 -o unstable-hal -o log -o esp-backtrace blinky
```
{{< /tab >}}
{{< tab label="S31-Korvo-1" >}}
```bash
esp-generate --template Hahihula/esp-hal@base48-workshop --headless -o esp32s31 -o unstable-hal -o log -o esp-backtrace blinky
```
{{< /tab >}}
{{< tab label="C6-DevKitC-1" >}}
```bash
esp-generate --template Hahihula/esp-hal@base48-workshop --headless -o esp32c6 -o unstable-hal -o log -o esp-backtrace blinky
```
{{< /tab >}}
{{< tab label="C5-DevKitC-1" >}}
```bash
esp-generate --template Hahihula/esp-hal@base48-workshop --headless -o esp32c5 -o unstable-hal -o log -o esp-backtrace blinky
```
{{< /tab >}}
{{< tab label="C3-DevKit-RUST-1" >}}
```bash
esp-generate --template Hahihula/esp-hal@base48-workshop --headless -o esp32c3 -o unstable-hal -o log -o esp-backtrace blinky
```
{{< /tab >}}
{{< tab label="C3-LCDkit" >}}
```bash
esp-generate --template Hahihula/esp-hal@base48-workshop --headless -o esp32c3 -o unstable-hal -o log -o esp-backtrace blinky
```
{{< /tab >}}
{{< /tabs >}}

{{< alert icon="circle-info" >}}
`esp-generate` warns that you are generating from an external template. A template decides which code and dependencies end up in your project, so only use templates you trust. The workshop branch is an unchanged copy of the esp-hal repository, which is maintained by Espressif.
{{< /alert >}}

## 2. Explore the generated project

Open the `blinky` folder in your editor. You'll find these files:

```
blinky/
├── .cargo/
│   ├── config.toml
│   └── esp-config.toml
├── src/
│   ├── bin/
│   │   └── main.rs
│   └── lib.rs
├── .clippy.toml
├── build.rs
├── Cargo.toml
└── rust-toolchain.toml
```

### `Cargo.toml`

The package manifest. Every esp-rs dependency points to the same commit of the esp-hal repository, and the chip is selected with a Cargo feature (for example `esp32c6`):

```toml
[dependencies.esp-hal]
features = ["esp32c6", "log-04", "unstable"]
git      = "https://github.com/Hahihula/esp-hal"
rev      = "7306e1fbc8e6629b9437bc91289a2232f27e6c93"
```

The `unstable` feature comes from the **unstable-hal** option. At the bottom, the `[profile.*]` sections turn on optimizations even for debug builds, because unoptimized Rust is too slow and too big for a microcontroller.

### `rust-toolchain.toml`

Tells `rustup` which toolchain, components, and targets this project needs. `rustup` installs anything missing on the first build.

### `.cargo/config.toml`

Build settings for Cargo:

- `target`: the default compilation target, so a plain `cargo build` builds for your chip and not for your computer
- `runner`: the command `cargo run` uses to start the program. Here it's `espflash flash --monitor --chip <chip>`, so `cargo run` flashes the board and opens the serial monitor

### `.cargo/esp-config.toml`

Run-time and build-time settings of the esp-rs crates, such as the log level or driver options. You can browse all available settings with the `esp-config` TUI tool; you won't need to change any of them in this workshop.

### `build.rs`

A build script that passes the linker script (`linkall.x`) to the linker and prints friendlier hints for common linker errors.

### `.clippy.toml` and `src/lib.rs`

`.clippy.toml` configures [Clippy](https://doc.rust-lang.org/clippy/), the Rust linter: it warns about functions with large stack frames, which can overflow a microcontroller's small stack. `src/lib.rs` is an empty library crate next to your program, a place for code you want to share or unit-test later. You won't need either in this workshop.

### `src/bin/main.rs`

The program itself:

```rust
#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::clock::CpuClock;
use esp_hal::main;
use esp_hal::time::{Duration, Instant};
use log::info;

esp_bootloader_esp_idf::esp_app_desc!();

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let _peripherals = esp_hal::init(config);

    loop {
        info!("Hello world!");
        let delay_start = Instant::now();
        while delay_start.elapsed() < Duration::from_millis(500) {}
    }
}
```

The generated file also has a few `clippy` lint attributes and comments, left out here.

Line by line:

- `#![no_std]`: don't link the Rust standard library, only `core`. There is no operating system to provide files, threads, or a heap.
- `#![no_main]`: there is no OS to call a regular `main`, so esp-hal provides the entry point. The `#[main]` attribute marks the function it calls after the chip has started.
- `use esp_backtrace as _;`: links in the panic handler. A `no_std` program must have exactly one.
- `esp_app_desc!()`: adds the application descriptor that the ESP-IDF bootloader checks before it starts your program.
- `fn main() -> !`: the return type `!` means "never returns". Firmware runs until the chip resets.
- `init_logger_from_env()`: connects the `log` crate (`info!`, `warn!`, ...) to the serial port. The log level comes from the `ESP_LOG` environment variable at build time and defaults to `info`.
- `esp_hal::init(config)`: sets up the clocks and returns the `Peripherals` struct, which owns every peripheral and pin of the chip. The leading `_` in `_peripherals` tells the compiler the variable is unused for now; you'll rename it to `peripherals` when you start using it.

### Run it

Connect the board with a USB data cable:

- **ESP32-S31-Function-CoreBoard-1**, **ESP32-S31-Korvo-1**, **ESP32-C6-DevKitC-1**, and **ESP32-C5-DevKitC-1**: use the **UART** USB port.
- **ESP32-C3-DevKit-RUST-1** and **ESP32-C3-LCDkit**: use the only USB port.

Then run:

```bash
cd blinky
cargo run --release
```

`cargo run` builds the project, flashes it with `espflash`, and opens the serial monitor. After the bootloader output, you should see `Hello world!` printed twice a second. Press `Ctrl+C` to quit the monitor.

{{< alert icon="circle-info" >}}
If `espflash` finds more than one serial port, it asks you which one to use. Pick the one that appeared when you connected the board. If flashing fails, see [Troubleshooting](../setup/#troubleshooting).
{{< /alert >}}

## 3. How the RGB LED works

The RGB LED on your board isn't a plain LED. It's a **WS2812**-compatible *addressable* LED with a tiny controller inside, which listens on a single data line for color values.

A color is 24 bits: 8 bits each of **green**, **red**, and **blue**, in that order. Each bit is a high pulse followed by a low pulse, and the length of the high pulse, either about 0.4 µs or about 0.8 µs, decides whether the bit is a `0` or a `1`.

Pulses this short are hard to make reliably by switching a GPIO from code. Espressif chips have a peripheral that is very good at it: the **RMT** (Remote Control Transceiver). It was designed for infrared remote controls, but it can play any sequence of timed pulses on a pin while the CPU does something else.

You won't program RMT by hand. The [`esp-hal-smartled`](https://github.com/esp-rs/esp-hal-community/tree/main/esp-hal-smartled) crate does it for you: you give it a color, and it turns the color into RMT pulses. It implements the `SmartLedsWrite` trait from the [`smart-leds`](https://crates.io/crates/smart-leds) crate, which also gives you color types and helpers such as gamma correction and HSV colors.

## 4. Drive the LED

### 4.1 Add the dependencies

Rust libraries are called *crates*, and most of them are published on [crates.io](https://crates.io). You add one to your project as a dependency, and Cargo downloads and builds it for you. Add both crates with `cargo add`:

```bash
cargo add esp-hal-smartled@0.18 smart-leds@0.4
```

`cargo add` adds both crates to `[dependencies]` in `Cargo.toml`:

```toml
esp-hal-smartled = "0.18"
smart-leds = "0.4"
```

and then ends with an error like this one:

```
error: failed to select a version for `esp-rom-sys`.
...
package `esp-rom-sys` links to the native library `esp_rom_sys`, but it conflicts with a previous package which links to `esp_rom_sys` as well
```

The two lines stay in `Cargo.toml`; the error comes from the next step, where Cargo works out the exact version of every crate the project needs.

`esp-hal-smartled` comes from crates.io, and it depends on esp-hal **from crates.io**. Your project uses esp-hal **from a Git commit**: look at `[dependencies.esp-hal]` in `Cargo.toml`, which has a `git` URL and a `rev`. To Cargo, those are two different crates, and a firmware can't contain two copies of esp-hal: they would both try to own the same hardware.

The fix is a `[patch.crates-io]` section. It tells Cargo: wherever any crate asks for esp-hal from crates.io, use this Git commit instead. Add it at the end of `Cargo.toml`, with the same `git` URL and `rev` as in your `[dependencies.esp-hal]`:

```toml
[patch.crates-io]
esp-hal = { git = "https://github.com/Hahihula/esp-hal", rev = "7306e1fbc8e6629b9437bc91289a2232f27e6c93" }
```

{{< alert icon="circle-info" >}}
Copy the `rev` from your own `Cargo.toml`. If it doesn't match, Cargo sees two different commits, and you get the same error again.
{{< /alert >}}

Now build:

```bash
cargo build --release
```

This time it works. The patch can stand in for the crates.io release because esp-hal at this commit has version `1.2.0`, which matches the `~1.2` that `esp-hal-smartled` asks for.

A few more things worth knowing about Git dependencies:

- Besides a `rev`, a Git dependency can name a `branch` or a `tag`. Cargo resolves a branch to its newest commit on the first build and records that commit in `Cargo.lock`, so your build doesn't change when the branch moves. Run `cargo update` when you want the newest commit.
- `git` + `rev` and `git` + `branch` are different sources to Cargo, even when they point to the same commit. That is why the patch has to be written exactly like your esp-hal dependency.
- You don't select the chip for `esp-hal-smartled`: it uses esp-hal, and your project has already enabled your chip's feature on esp-hal. Cargo builds a single esp-hal for the whole firmware.

### 4.2 Imports

Replace the contents of `src/bin/main.rs` step by step. Start with the imports:

```rust
#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

esp_bootloader_esp_idf::esp_app_desc!();
```

`SmartLedsWrite` is a trait. Importing it brings its `write()` method into scope, so you can call it on the LED driver.

### 4.3 Create the LED driver

Here you meet the pattern that every esp-hal driver follows: take a peripheral out of `peripherals`, create the driver with a configuration, and connect it to a pin.

```rust
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);
```

Then set up RMT and the LED on your board's LED pin:

{{< tabs group="board" >}}
{{< tab label="S31-CoreBoard" >}}
```rust
    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO60,
        freq,
    )
    .unwrap();
```
{{< /tab >}}
{{< tab label="S31-Korvo-1" >}}
```rust
    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO37,
        freq,
    )
    .unwrap();
```
{{< /tab >}}
{{< tab label="C6-DevKitC-1" >}}
```rust
    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO8,
        freq,
    )
    .unwrap();
```
{{< /tab >}}
{{< tab label="C5-DevKitC-1" >}}
```rust
    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO27,
        freq,
    )
    .unwrap();
```
{{< /tab >}}
{{< tab label="C3-DevKit-RUST-1" >}}
```rust
    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO2,
        freq,
    )
    .unwrap();
```
{{< /tab >}}
{{< tab label="C3-LCDkit" >}}
```rust
    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO8,
        freq,
    )
    .unwrap();
```
{{< /tab >}}
{{< /tabs >}}

- `Rmt::new()` takes ownership of the RMT peripheral and runs it at 80 MHz.
- `RmtSmartLeds::new()` takes one RMT channel, the LED timing, and the pin. Its type parameters say what it drives:
  - `{ buffer_size::<RGB8>(1) }`: room for the pulses of **one** LED. The size is worked out at compile time, so the driver needs no heap.
  - `_`: blocking or async mode. Rust infers it from the channel, which is blocking here.
  - `RGB8`: one byte each of red, green, and blue.
  - `color_order::Grb`: the order in which the LED expects the colors.

Try using the same pin twice, for example by adding `let pin = peripherals.GPIO8;` (with your LED pin) before this code. The compiler refuses: the pin was moved into the variable, so it can't also be given to the LED driver. This is how esp-hal turns "two drivers fight over one pin" into a compile-time error.

### 4.4 Blink

Finally, cycle through a few colors. `Delay` is a simple busy-wait delay. The colors use 32 out of 255 because these LEDs are very bright at full power.

```rust
    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];

    loop {
        for (name, color) in colors {
            info!("LED: {name}");
            led.write([color]).unwrap();
            delay.delay_millis(500);
        }
    }
}
```

`write()` takes the colors of all the LEDs in a strip, one after another. Your board has a single LED, so you pass an array with one color.

### 4.5 Build and flash

```bash
cargo run --release
```

The LED cycles through red, green, blue, and off, and the monitor prints:

```
INFO - LED: red
INFO - LED: green
INFO - LED: blue
INFO - LED: off
```

If the colors on the LED don't match the log (for example, red and green are swapped), try another `color_order`.

<details><summary>Show the complete solution</summary>

{{< tabs group="board" >}}
{{< tab label="S31-CoreBoard" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO60,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];

    loop {
        for (name, color) in colors {
            info!("LED: {name}");
            led.write([color]).unwrap();
            delay.delay_millis(500);
        }
    }
}
```
{{< /tab >}}
{{< tab label="S31-Korvo-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO37,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];

    loop {
        for (name, color) in colors {
            info!("LED: {name}");
            led.write([color]).unwrap();
            delay.delay_millis(500);
        }
    }
}
```
{{< /tab >}}
{{< tab label="C6-DevKitC-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO8,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];

    loop {
        for (name, color) in colors {
            info!("LED: {name}");
            led.write([color]).unwrap();
            delay.delay_millis(500);
        }
    }
}
```
{{< /tab >}}
{{< tab label="C5-DevKitC-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO27,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];

    loop {
        for (name, color) in colors {
            info!("LED: {name}");
            led.write([color]).unwrap();
            delay.delay_millis(500);
        }
    }
}
```
{{< /tab >}}
{{< tab label="C3-DevKit-RUST-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO2,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];

    loop {
        for (name, color) in colors {
            info!("LED: {name}");
            led.write([color]).unwrap();
            delay.delay_millis(500);
        }
    }
}
```
{{< /tab >}}
{{< tab label="C3-LCDkit" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO8,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];

    loop {
        for (name, color) in colors {
            info!("LED: {name}");
            led.write([color]).unwrap();
            delay.delay_millis(500);
        }
    }
}
```
{{< /tab >}}
{{< /tabs >}}

</details>

## 5. Stretch goals

If you finish early, try any of these.

### 5.1 Rainbow

Make the LED fade smoothly through all the colors of the rainbow.

Hints:

- The [`smart_leds::hsv`](https://docs.rs/smart-leds/latest/smart_leds/hsv/index.html) module has an `Hsv` color and `hsv2rgb()`. Going around the rainbow is just counting the `hue` up from 0 to 255.
- `smart_leds` also has [`gamma()`](https://docs.rs/smart-leds/latest/smart_leds/fn.gamma.html), which makes fades look even to the eye, and [`brightness()`](https://docs.rs/smart-leds/latest/smart_leds/fn.brightness.html). Both take and return an iterator of colors, so you can chain them before `write()`.

<details><summary>Show the solution</summary>

{{< tabs group="board" >}}
{{< tab label="S31-CoreBoard" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use smart_leds::{
    RGB8, SmartLedsWrite, brightness, gamma,
    hsv::{Hsv, hsv2rgb},
};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO60,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let color = hsv2rgb(Hsv {
            hue,
            sat: 255,
            val: 255,
        });
        // Gamma-correct the color, then limit the brightness to 10 out of 255,
        // so the LED doesn't blind you.
        led.write(brightness(gamma([color].into_iter()), 10)).unwrap();
        hue = hue.wrapping_add(1);
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="S31-Korvo-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use smart_leds::{
    RGB8, SmartLedsWrite, brightness, gamma,
    hsv::{Hsv, hsv2rgb},
};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO37,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let color = hsv2rgb(Hsv {
            hue,
            sat: 255,
            val: 255,
        });
        // Gamma-correct the color, then limit the brightness to 10 out of 255,
        // so the LED doesn't blind you.
        led.write(brightness(gamma([color].into_iter()), 10)).unwrap();
        hue = hue.wrapping_add(1);
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="C6-DevKitC-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use smart_leds::{
    RGB8, SmartLedsWrite, brightness, gamma,
    hsv::{Hsv, hsv2rgb},
};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO8,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let color = hsv2rgb(Hsv {
            hue,
            sat: 255,
            val: 255,
        });
        // Gamma-correct the color, then limit the brightness to 10 out of 255,
        // so the LED doesn't blind you.
        led.write(brightness(gamma([color].into_iter()), 10)).unwrap();
        hue = hue.wrapping_add(1);
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="C5-DevKitC-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use smart_leds::{
    RGB8, SmartLedsWrite, brightness, gamma,
    hsv::{Hsv, hsv2rgb},
};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO27,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let color = hsv2rgb(Hsv {
            hue,
            sat: 255,
            val: 255,
        });
        // Gamma-correct the color, then limit the brightness to 10 out of 255,
        // so the LED doesn't blind you.
        led.write(brightness(gamma([color].into_iter()), 10)).unwrap();
        hue = hue.wrapping_add(1);
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="C3-DevKit-RUST-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use smart_leds::{
    RGB8, SmartLedsWrite, brightness, gamma,
    hsv::{Hsv, hsv2rgb},
};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO2,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let color = hsv2rgb(Hsv {
            hue,
            sat: 255,
            val: 255,
        });
        // Gamma-correct the color, then limit the brightness to 10 out of 255,
        // so the LED doesn't blind you.
        led.write(brightness(gamma([color].into_iter()), 10)).unwrap();
        hue = hue.wrapping_add(1);
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="C3-LCDkit" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{clock::CpuClock, delay::Delay, main, rmt::Rmt, time::Rate};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use smart_leds::{
    RGB8, SmartLedsWrite, brightness, gamma,
    hsv::{Hsv, hsv2rgb},
};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO8,
        freq,
    )
    .unwrap();

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let color = hsv2rgb(Hsv {
            hue,
            sat: 255,
            val: 255,
        });
        // Gamma-correct the color, then limit the brightness to 10 out of 255,
        // so the LED doesn't blind you.
        led.write(brightness(gamma([color].into_iter()), 10)).unwrap();
        hue = hue.wrapping_add(1);
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< /tabs >}}

</details>

### 5.2 BOOT button

Use the **BOOT** button to step to the next color instead of changing it on a timer.

Hints:

- Read the pin with [`esp_hal::gpio::Input`](https://docs.espressif.com/projects/rust/esp-hal/latest/esp32c6/esp_hal/gpio/struct.Input.html). Find your board's BOOT pin in the [Supported boards](/workshops/rust-esp-hal-intro/#supported-boards) table. On the ESP32-C3-LCDkit, the BOOT button is the rotary encoder knob.
- The button connects the pin to ground when pressed, so enable the internal pull-up with `InputConfig::default().with_pull(Pull::Up)`. Pressed reads low.
- Change the color only when the button *goes from released to pressed*, not for as long as it's held.

<details><summary>Show the solution</summary>

{{< tabs group="board" >}}
{{< tab label="S31-CoreBoard" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Pull},
    main,
    rmt::Rmt,
    time::Rate,
};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO60,
        freq,
    )
    .unwrap();

    let button = Input::new(peripherals.GPIO61, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led.write([colors[index].1]).unwrap();
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, color) = colors[index];
            info!("LED: {name}");
            led.write([color]).unwrap();
        }
        was_pressed = pressed;
        // Polling every 20 ms also debounces the button.
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="S31-Korvo-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Pull},
    main,
    rmt::Rmt,
    time::Rate,
};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO37,
        freq,
    )
    .unwrap();

    let button = Input::new(peripherals.GPIO61, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led.write([colors[index].1]).unwrap();
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, color) = colors[index];
            info!("LED: {name}");
            led.write([color]).unwrap();
        }
        was_pressed = pressed;
        // Polling every 20 ms also debounces the button.
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="C6-DevKitC-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Pull},
    main,
    rmt::Rmt,
    time::Rate,
};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO8,
        freq,
    )
    .unwrap();

    let button = Input::new(peripherals.GPIO9, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led.write([colors[index].1]).unwrap();
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, color) = colors[index];
            info!("LED: {name}");
            led.write([color]).unwrap();
        }
        was_pressed = pressed;
        // Polling every 20 ms also debounces the button.
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="C5-DevKitC-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Pull},
    main,
    rmt::Rmt,
    time::Rate,
};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO27,
        freq,
    )
    .unwrap();

    let button = Input::new(peripherals.GPIO28, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led.write([colors[index].1]).unwrap();
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, color) = colors[index];
            info!("LED: {name}");
            led.write([color]).unwrap();
        }
        was_pressed = pressed;
        // Polling every 20 ms also debounces the button.
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="C3-DevKit-RUST-1" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Pull},
    main,
    rmt::Rmt,
    time::Rate,
};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO2,
        freq,
    )
    .unwrap();

    let button = Input::new(peripherals.GPIO9, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led.write([colors[index].1]).unwrap();
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, color) = colors[index];
            info!("LED: {name}");
            led.write([color]).unwrap();
        }
        was_pressed = pressed;
        // Polling every 20 ms also debounces the button.
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< tab label="C3-LCDkit" >}}
```rust
#![no_std]
#![no_main]
#![deny(
    clippy::mem_forget,
    reason = "mem::forget is generally not safe to do with esp_hal types, especially those \
    holding buffers for the duration of a data transfer."
)]
#![deny(clippy::large_stack_frames)]

use esp_backtrace as _;
use esp_hal::{
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Pull},
    main,
    rmt::Rmt,
    time::Rate,
};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use log::info;
use smart_leds::{RGB8, SmartLedsWrite};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

#[allow(
    clippy::large_stack_frames,
    reason = "it's not unusual to allocate larger buffers etc. in main"
)]
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();
    let mut led = RmtSmartLeds::<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb>::new(
        WS2812B_TIMING,
        rmt.channel0,
        peripherals.GPIO8,
        freq,
    )
    .unwrap();

    let button = Input::new(peripherals.GPIO9, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", RGB8::new(32, 0, 0)),
        ("green", RGB8::new(0, 32, 0)),
        ("blue", RGB8::new(0, 0, 32)),
        ("off", RGB8::new(0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led.write([colors[index].1]).unwrap();
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, color) = colors[index];
            info!("LED: {name}");
            led.write([color]).unwrap();
        }
        was_pressed = pressed;
        // Polling every 20 ms also debounces the button.
        delay.delay_millis(20);
    }
}
```
{{< /tab >}}
{{< /tabs >}}

</details>

### 5.3 Look under the hood

Open the [source of `esp-hal-smartled`](https://docs.rs/crate/esp-hal-smartled/0.18.0/source/src/lib.rs) and find:

- where a color is turned into RMT `PulseCode`s, one per bit
- where `WS2812B_TIMING` is defined, and how nanoseconds become RMT clock ticks
- how `write()` sends the pulses with the RMT channel and waits until they are out

Reading the code of the crates you depend on is one of the best ways to learn embedded Rust: the source of most crates is a click away on [docs.rs](https://docs.rs) or GitHub.

## What you learned

In this assignment, you:

- Generated an esp-hal project from the esp-hal template, interactively and headless
- Learned what each generated file does, and what `#![no_std]` and `#![no_main]` mean
- Added dependencies from crates.io and used `[patch.crates-io]` to build them against esp-hal from Git, so the firmware has a single esp-hal
- Took a peripheral and a pin out of `Peripherals` and saw the compiler stop you from using a pin twice
- Drove the WS2812 RGB LED through the RMT peripheral with `esp-hal-smartled` and `smart-leds`

## Next step

Continue with [Assignment 2: Join the room over Wi-Fi](../assignment-2/).

---

[← Workshop overview](/workshops/rust-esp-hal-intro/)
