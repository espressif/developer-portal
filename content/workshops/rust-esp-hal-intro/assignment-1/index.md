---
title: "Getting started with esp-hal: Assignment 1"
date: 2026-11-13
showTableOfContents: true
series: ["WS-RUST-ESP-HAL"]
series_order: 3
showAuthor: false
---

In this assignment, you will generate your first esp-hal project, find your way around the generated files, and then extend the program so that the onboard RGB LED blinks red, green, and blue.

<!-- TODO: link to the solutions repository -->

## 1. Generate the project

`esp-generate` creates projects from a **template**. Its built-in template follows the latest released esp-hal crates. In this workshop you will use the template that lives in the [esp-hal repository](https://github.com/esp-rs/esp-hal/tree/main/template) instead: it pins every esp-rs crate to the exact esp-hal commit it was generated from, which gives you the newest chip support (including the ESP32-S31) with crates that are known to work together.

### Interactive mode

Run `esp-generate` with just the template and a project name:

```bash
esp-generate --template esp-rs/esp-hal blinky
```

`esp-generate` downloads the template and opens a terminal menu. Pick your chip, then look through the options. Each option has a short description at the bottom of the screen; the ones you will meet in this workshop are:

- **unstable-hal**: enables esp-hal's unstable drivers, including RMT, which you need for the LED
- **embassy**: adds the Embassy async framework and the `esp-rtos` scheduler (Assignments 2 and 3)
- **alloc**: adds a heap allocator (Assignments 2 and 3)
- **wifi**: adds the `esp-radio` Wi-Fi driver (Assignments 2 and 3)

For this assignment, enable only **unstable-hal**, then press `s` to save and generate the project. To quit without generating anything, press `q` and confirm with `y`.

### Headless mode

The same project can be generated without the menu by passing every option with `-o`. This is handy for scripts and for this workshop: if you got lost in the menu, delete the `blinky` folder and run the command for your board:

{{< tabs group="board" >}}
{{< tab label="S31-CoreBoard" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32s31 -o unstable-hal blinky
```
{{< /tab >}}
{{< tab label="S31-Korvo-1" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32s31 -o unstable-hal blinky
```
{{< /tab >}}
{{< tab label="C6-DevKitC-1" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32c6 -o unstable-hal blinky
```
{{< /tab >}}
{{< tab label="C5-DevKitC-1" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32c5 -o unstable-hal blinky
```
{{< /tab >}}
{{< tab label="C3-DevKit-RUST-1" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32c3 -o unstable-hal blinky
```
{{< /tab >}}
{{< tab label="C3-LCDkit" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32c3 -o unstable-hal blinky
```
{{< /tab >}}
{{< /tabs >}}

{{< alert icon="circle-info" >}}
`esp-generate` warns that you are generating from an external template. A template decides which code and dependencies end up in your project, so only use templates you trust. The esp-hal repository is maintained by Espressif.
{{< /alert >}}

## 2. Explore the generated project

Open the `blinky` folder in your editor. You'll find these files:

```
blinky/
├── .cargo/
│   ├── config.toml
│   └── esp-config.toml
├── src/
│   └── bin/
│       └── main.rs
├── build.rs
├── Cargo.toml
└── rust-toolchain.toml
```

### `Cargo.toml`

The package manifest. Every esp-rs dependency points to the same commit of the esp-hal repository, and the chip is selected with a Cargo feature (for example `esp32c6`):

```toml
[dependencies.esp-hal]
features = ["esp32c6", "log-04", "unstable"]
git      = "https://github.com/esp-rs/esp-hal"
rev      = "b95bd636877721655e986e287cc90df359d99978"
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
    let peripherals = esp_hal::init(config);
    let _ = peripherals;

    loop {
        info!("Hello world!");
        let delay_start = Instant::now();
        while delay_start.elapsed() < Duration::from_millis(500) {}
    }
}
```

Line by line:

- `#![no_std]`: don't link the Rust standard library, only `core`. There is no operating system to provide files, threads, or a heap.
- `#![no_main]`: there is no OS to call a regular `main`, so esp-hal provides the entry point. The `#[main]` attribute marks the function it calls after the chip has started.
- `use esp_backtrace as _;`: links in the panic handler. A `no_std` program must have exactly one.
- `esp_app_desc!()`: adds the application descriptor that the ESP-IDF bootloader checks before it starts your program.
- `fn main() -> !`: the return type `!` means "never returns". Firmware runs until the chip resets.
- `init_logger_from_env()`: connects the `log` crate (`info!`, `warn!`, ...) to the serial port. The log level comes from the `ESP_LOG` environment variable at build time and defaults to `info`.
- `esp_hal::init(config)`: sets up the clocks and returns `peripherals`, the struct that owns every peripheral and pin of the chip.

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

The RGB LED on your board isn't a plain LED. It's a **WS2812**-compatible *addressable* LED with a tiny controller inside, and it listens on a single data line for color values.

A color is 24 bits: 8 bits each of **green**, **red**, and **blue**, in that order, most significant bit first. Each bit is a high pulse followed by a low pulse, and the length of the high pulse decides the value:

| Bit | High | Low |
|-----|------|-----|
| `0` | about 0.4 µs | about 0.85 µs |
| `1` | about 0.8 µs | about 0.45 µs |

After the 24 bits, the line stays low for more than 50 µs, and the LED shows the new color.

Pulses this short are hard to make reliably by switching a GPIO from code. Instead, you'll use the **RMT** (Remote Control Transceiver) peripheral. RMT was designed to generate and receive infrared remote control signals, but it can produce any sequence of timed pulses: you give it a list of *pulse codes*, each a pair of (level, duration), and the hardware plays them out on a pin with exact timing while the CPU does something else.

## 4. Drive the LED

Now replace the contents of `src/bin/main.rs` step by step.

### 4.1 Imports

```rust
#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

esp_bootloader_esp_idf::esp_app_desc!();
```

### 4.2 Bit timing

RMT counts time in *ticks*. You will run it at 80 MHz, so one tick is 12.5 ns. A `PulseCode` holds two (level, ticks) pairs: exactly one WS2812 bit.

```rust
/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));
```

Because `ticks` and `PulseCode::new` are `const fn`, the compiler works out both pulse codes at compile time.

### 4.3 Encode a color

This function packs the color into one 24-bit number in green-red-blue order and turns each bit into a pulse code. The last entry stays an *end marker*, which tells RMT to stop.

```rust
/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}
```

### 4.4 Send a color

In blocking mode, `transmit()` takes the RMT channel **by value** and returns a transaction; `wait()` blocks until the pulses are out and gives the channel back. This is how esp-hal makes sure nobody touches the channel, or the `pulses` buffer, while the hardware is still reading it. Both calls return the channel together with the error if something goes wrong, so you never lose it.

```rust
/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}
```

### 4.5 Set up RMT in `main`

Here you meet the pattern that every esp-hal driver follows: take a peripheral out of `peripherals`, create the driver with a configuration, and connect it to a pin.

```rust
#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
```

- `Rmt::new()` takes ownership of the RMT peripheral and sets its clock to 80 MHz.
- `with_clk_divider(1)` keeps the full 80 MHz for the channel, so one tick is 12.5 ns.
- `with_idle_output_level(Level::Low)` and `with_idle_output(true)` keep the data line low between transmissions, which the WS2812 reads as "show the color".

Then configure channel 0 as a transmitter and connect it to the LED pin of your board:

{{< tabs group="board" >}}
{{< tab label="S31-CoreBoard" >}}
```rust
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO60);
```
{{< /tab >}}
{{< tab label="S31-Korvo-1" >}}
```rust
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO37);
```
{{< /tab >}}
{{< tab label="C6-DevKitC-1" >}}
```rust
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO8);
```
{{< /tab >}}
{{< tab label="C5-DevKitC-1" >}}
```rust
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO27);
```
{{< /tab >}}
{{< tab label="C3-DevKit-RUST-1" >}}
```rust
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO2);
```
{{< /tab >}}
{{< tab label="C3-LCDkit" >}}
```rust
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO8);
```
{{< /tab >}}
{{< /tabs >}}

Try using the same pin twice, for example by adding `let pin = peripherals.GPIO8;` (with your LED pin) before this code. The compiler refuses: the pin was moved into the variable, so it can't also be given to RMT. This is how esp-hal turns "two drivers fight over one pin" into a compile-time error.

### 4.6 Blink

Finally, cycle through a few colors. `Delay` is a simple busy-wait delay. The colors use 32 out of 255 because these LEDs are very bright at full power.

```rust
    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];

    loop {
        for (name, (r, g, b)) in colors {
            info!("LED: {name}");
            led = set_color(led, r, g, b);
            delay.delay_millis(500);
        }
    }
}
```

Note `led = set_color(led, ...)`: the channel goes into the function and comes back out, ready for the next color.

### 4.7 Build and flash

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

If the colors on the LED don't match the log (for example, red and green are swapped), check the bit order in `encode()`.

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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO60);

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];

    loop {
        for (name, (r, g, b)) in colors {
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO37);

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];

    loop {
        for (name, (r, g, b)) in colors {
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO8);

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];

    loop {
        for (name, (r, g, b)) in colors {
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO27);

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];

    loop {
        for (name, (r, g, b)) in colors {
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO2);

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];

    loop {
        for (name, (r, g, b)) in colors {
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO8);

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];

    loop {
        for (name, (r, g, b)) in colors {
            info!("LED: {name}");
            led = set_color(led, r, g, b);
            delay.delay_millis(500);
        }
    }
}
```
{{< /tab >}}
{{< /tabs >}}

</details>

## 5. Stretch goals

If you finish early, try one or both of these.

### 5.1 Rainbow

Make the LED fade smoothly through all the colors of the rainbow.

Hint: write a function `fn wheel(pos: u8) -> (u8, u8, u8)` that maps a position on a color wheel to a color: from red to green for 0-84, green to blue for 85-169, and blue back to red for 170-255. Then step `pos` by one every 20 ms with `wrapping_add`.

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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::warn;

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Maps a position on the color wheel (0-255) to a fully saturated color.
fn wheel(pos: u8) -> (u8, u8, u8) {
    match pos {
        0..=84 => (255 - pos * 3, pos * 3, 0),
        85..=169 => {
            let p = pos - 85;
            (0, 255 - p * 3, p * 3)
        }
        _ => {
            let p = pos - 170;
            (p * 3, 0, 255 - p * 3)
        }
    }
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO60);

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let (r, g, b) = wheel(hue);
        // Divide by 8 so the LED doesn't blind you.
        led = set_color(led, r / 8, g / 8, b / 8);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::warn;

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Maps a position on the color wheel (0-255) to a fully saturated color.
fn wheel(pos: u8) -> (u8, u8, u8) {
    match pos {
        0..=84 => (255 - pos * 3, pos * 3, 0),
        85..=169 => {
            let p = pos - 85;
            (0, 255 - p * 3, p * 3)
        }
        _ => {
            let p = pos - 170;
            (p * 3, 0, 255 - p * 3)
        }
    }
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO37);

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let (r, g, b) = wheel(hue);
        // Divide by 8 so the LED doesn't blind you.
        led = set_color(led, r / 8, g / 8, b / 8);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::warn;

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Maps a position on the color wheel (0-255) to a fully saturated color.
fn wheel(pos: u8) -> (u8, u8, u8) {
    match pos {
        0..=84 => (255 - pos * 3, pos * 3, 0),
        85..=169 => {
            let p = pos - 85;
            (0, 255 - p * 3, p * 3)
        }
        _ => {
            let p = pos - 170;
            (p * 3, 0, 255 - p * 3)
        }
    }
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO8);

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let (r, g, b) = wheel(hue);
        // Divide by 8 so the LED doesn't blind you.
        led = set_color(led, r / 8, g / 8, b / 8);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::warn;

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Maps a position on the color wheel (0-255) to a fully saturated color.
fn wheel(pos: u8) -> (u8, u8, u8) {
    match pos {
        0..=84 => (255 - pos * 3, pos * 3, 0),
        85..=169 => {
            let p = pos - 85;
            (0, 255 - p * 3, p * 3)
        }
        _ => {
            let p = pos - 170;
            (p * 3, 0, 255 - p * 3)
        }
    }
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO27);

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let (r, g, b) = wheel(hue);
        // Divide by 8 so the LED doesn't blind you.
        led = set_color(led, r / 8, g / 8, b / 8);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::warn;

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Maps a position on the color wheel (0-255) to a fully saturated color.
fn wheel(pos: u8) -> (u8, u8, u8) {
    match pos {
        0..=84 => (255 - pos * 3, pos * 3, 0),
        85..=169 => {
            let p = pos - 85;
            (0, 255 - p * 3, p * 3)
        }
        _ => {
            let p = pos - 170;
            (p * 3, 0, 255 - p * 3)
        }
    }
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO2);

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let (r, g, b) = wheel(hue);
        // Divide by 8 so the LED doesn't blind you.
        led = set_color(led, r / 8, g / 8, b / 8);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::Level,
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::warn;

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Maps a position on the color wheel (0-255) to a fully saturated color.
fn wheel(pos: u8) -> (u8, u8, u8) {
    match pos {
        0..=84 => (255 - pos * 3, pos * 3, 0),
        85..=169 => {
            let p = pos - 85;
            (0, 255 - p * 3, p * 3)
        }
        _ => {
            let p = pos - 170;
            (p * 3, 0, 255 - p * 3)
        }
    }
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO8);

    let delay = Delay::new();
    let mut hue: u8 = 0;

    loop {
        let (r, g, b) = wheel(hue);
        // Divide by 8 so the LED doesn't blind you.
        led = set_color(led, r / 8, g / 8, b / 8);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Level, Pull},
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO60);

    let button = Input::new(peripherals.GPIO61, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led = set_color(led, 32, 0, 0);
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, (r, g, b)) = colors[index];
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Level, Pull},
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO37);

    let button = Input::new(peripherals.GPIO61, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led = set_color(led, 32, 0, 0);
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, (r, g, b)) = colors[index];
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Level, Pull},
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO8);

    let button = Input::new(peripherals.GPIO9, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led = set_color(led, 32, 0, 0);
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, (r, g, b)) = colors[index];
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Level, Pull},
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO27);

    let button = Input::new(peripherals.GPIO28, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led = set_color(led, 32, 0, 0);
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, (r, g, b)) = colors[index];
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Level, Pull},
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO2);

    let button = Input::new(peripherals.GPIO9, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led = set_color(led, 32, 0, 0);
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, (r, g, b)) = colors[index];
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

use esp_backtrace as _;
use esp_hal::{
    Blocking,
    clock::CpuClock,
    delay::Delay,
    gpio::{Input, InputConfig, Level, Pull},
    main,
    rmt::{Channel, PulseCode, Rmt, Tx, TxChannelConfig, TxChannelCreator},
    time::Rate,
};
use log::{info, warn};

// This creates a default app-descriptor required by the esp-idf bootloader.
// For more information see: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html#application-description>
esp_bootloader_esp_idf::esp_app_desc!();

/// RMT tick rate: 80 MHz, so one tick is 12.5 ns.
const RMT_FREQ_MHZ: u32 = 80;

/// Converts nanoseconds to RMT ticks.
const fn ticks(ns: u32) -> u16 {
    (ns * RMT_FREQ_MHZ / 1000) as u16
}

/// WS2812 "0" bit: short high, long low.
const BIT_0: PulseCode = PulseCode::new(Level::High, ticks(400), Level::Low, ticks(850));
/// WS2812 "1" bit: long high, short low.
const BIT_1: PulseCode = PulseCode::new(Level::High, ticks(800), Level::Low, ticks(450));

/// Turns one color into the 24 pulses the WS2812 expects (green, red, blue;
/// most significant bit first), followed by an end marker.
fn encode(r: u8, g: u8, b: u8) -> [PulseCode; 25] {
    let mut pulses = [PulseCode::end_marker(); 25];
    let grb = (u32::from(g) << 16) | (u32::from(r) << 8) | u32::from(b);
    for (i, pulse) in pulses[..24].iter_mut().enumerate() {
        let bit = (grb >> (23 - i)) & 1;
        *pulse = if bit == 1 { BIT_1 } else { BIT_0 };
    }
    pulses
}

/// Sends one color to the LED and hands the RMT channel back.
fn set_color(
    channel: Channel<'static, Blocking, Tx>,
    r: u8,
    g: u8,
    b: u8,
) -> Channel<'static, Blocking, Tx> {
    let pulses = encode(r, g, b);
    let result = match channel.transmit(&pulses) {
        Ok(transaction) => transaction.wait(),
        Err(e) => Err(e),
    };
    match result {
        Ok(channel) => channel,
        Err((e, channel)) => {
            warn!("RMT error: {e:?}");
            channel
        }
    }
}

#[main]
fn main() -> ! {
    esp_println::logger::init_logger_from_env();

    let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
    let peripherals = esp_hal::init(config);

    let rmt = Rmt::new(peripherals.RMT, Rate::from_mhz(RMT_FREQ_MHZ)).unwrap();
    let tx_config = TxChannelConfig::default()
        .with_clk_divider(1)
        .with_idle_output_level(Level::Low)
        .with_idle_output(true);
    let mut led = rmt
        .channel0
        .configure_tx(&tx_config)
        .unwrap()
        .with_pin(peripherals.GPIO8);

    let button = Input::new(peripherals.GPIO9, InputConfig::default().with_pull(Pull::Up));

    let delay = Delay::new();
    let colors = [
        ("red", (32, 0, 0)),
        ("green", (0, 32, 0)),
        ("blue", (0, 0, 32)),
        ("off", (0, 0, 0)),
    ];
    let mut index = 0;
    let mut was_pressed = false;
    led = set_color(led, 32, 0, 0);
    info!("LED: red, press BOOT for the next color");

    loop {
        // The BOOT button connects the pin to ground, so pressed reads low.
        let pressed = button.is_low();
        if pressed && !was_pressed {
            index = (index + 1) % colors.len();
            let (name, (r, g, b)) = colors[index];
            info!("LED: {name}");
            led = set_color(led, r, g, b);
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

## What you learned

In this assignment, you:

- Generated an esp-hal project from the esp-hal template, interactively and headless
- Learned what each generated file does, and what `#![no_std]` and `#![no_main]` mean
- Took a peripheral and a pin out of `Peripherals` and saw the compiler stop you from using a pin twice
- Configured the RMT peripheral and used it to send WS2812 pulse codes
- Used blocking esp-hal APIs that pass ownership of a channel into a transfer and back

## Next step

[Assignment 2: Join the room over Wi-Fi](../assignment-2/)

[Return to the workshop main page](/workshops/rust-esp-hal-intro/)
