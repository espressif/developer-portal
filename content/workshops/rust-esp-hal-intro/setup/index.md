---
title: "Getting started with esp-hal: Setup"
date: 2026-11-13
showTableOfContents: true
series: ["WS-RUST-ESP-HAL"]
series_order: 2
showAuthor: false
---

Please complete this setup **before the workshop**. Everything here downloads a lot of data, and a room full of people doing it over the same Wi-Fi is slow.

For the full background on each step, see the [Prerequisites](https://docs.espressif.com/projects/rust/no_std-training/prerequisites.html) chapter of the Embedded Rust Training and the [Setting up a development environment](https://docs.espressif.com/projects/rust/book/getting-started/index.html) chapter of the Rust on ESP Book.

## 1. Install Rust

Install Rust with [rustup](https://rustup.rs/), the official Rust toolchain installer.

{{< tabs group="os" >}}
{{< tab label="Linux / macOS" >}}
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Then restart your terminal, or run:

```bash
source "$HOME/.cargo/env"
```
{{< /tab >}}
{{< tab label="Windows" >}}
Download and run [rustup-init.exe](https://win.rustup.rs/x86_64). When it asks, let it install the Visual Studio C++ Build Tools: `cargo install` needs them to build `espflash` and `esp-generate`.
{{< /tab >}}
{{< /tabs >}}

Check that it works:

```bash
rustc --version
cargo --version
```

If you already had Rust installed, update it:

```bash
rustup update
```

### Xtensa chips: espup

{{< alert icon="circle-info" >}}
This workshop doesn't need it, but if you later want to use an **ESP32**, **ESP32-S2**, or **ESP32-S3**, you need `espup`.
{{< /alert >}}

These chips use the Xtensa architecture, which the upstream Rust compiler doesn't support yet. [`espup`](https://github.com/esp-rs/espup) installs Espressif's fork of the Rust compiler and LLVM as a separate `esp` toolchain:

```bash
cargo install espup --locked
espup install
```

On Linux and macOS, `espup` writes an `export-esp.sh` file to your home directory. Source it in each terminal where you build for Xtensa:

```bash
. $HOME/export-esp.sh
```

Projects generated for Xtensa chips select the `esp` toolchain in their `rust-toolchain.toml`.

## 2. Install espflash

[`espflash`](https://github.com/esp-rs/espflash) flashes firmware to the board and shows its serial output:

```bash
cargo install espflash --locked
```

Check that it works:

```bash
espflash --version
```

## 3. Install esp-generate

[`esp-generate`](https://github.com/esp-rs/esp-generate) creates new projects from templates:

```bash
cargo install esp-generate --locked
```

Check that it works:

```bash
esp-generate --version
```

## 4. Build a test project

This step checks the whole toolchain and downloads and compiles all the dependencies the workshop uses, so the builds during the workshop are quick. Run it in a directory where you want to keep your workshop projects.

{{< tabs group="board" >}}
{{< tab label="S31-CoreBoard" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32s31 -o unstable-hal setup_test
```
{{< /tab >}}
{{< tab label="S31-Korvo-1" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32s31 -o unstable-hal setup_test
```
{{< /tab >}}
{{< tab label="C6-DevKitC-1" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32c6 -o unstable-hal setup_test
```
{{< /tab >}}
{{< tab label="C5-DevKitC-1" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32c5 -o unstable-hal setup_test
```
{{< /tab >}}
{{< tab label="C3-DevKit-RUST-1" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32c3 -o unstable-hal setup_test
```
{{< /tab >}}
{{< tab label="C3-LCDkit" >}}
```bash
esp-generate --template esp-rs/esp-hal --headless -o esp32c3 -o unstable-hal setup_test
```
{{< /tab >}}
{{< /tabs >}}

Then build it:

```bash
cd setup_test
cargo build --release
```

The first build takes a few minutes. It should end with a line like:

```
Finished `release` profile [optimized + debuginfo] target(s) in 1m 12s
```

## Optional: editor support

Any editor with [rust-analyzer](https://rust-analyzer.github.io/) support works. In Visual Studio Code, install the [rust-analyzer extension](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer). Open the project folder itself (the one with `Cargo.toml`) so rust-analyzer picks up the target from `.cargo/config.toml`.

## Troubleshooting

### espflash can't find the serial port

{{< tabs group="os" >}}
{{< tab label="Linux / macOS" >}}
List the serial ports:

```bash
ls /dev/ttyUSB* /dev/ttyACM* /dev/cu.usb* 2>/dev/null
```

On Linux, if you get a permission error, add yourself to the `dialout` group (on Arch Linux, `uucp`), then log out and back in:

```bash
sudo usermod -a -G dialout $USER
```
{{< /tab >}}
{{< tab label="Windows" >}}
List the serial ports in PowerShell:

```powershell
Get-CimInstance Win32_SerialPort | Select-Object Name, DeviceID
```

If the board doesn't appear, install the driver for its USB-to-UART bridge chip; see [Establish Serial Connection with ESP32](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/establish-serial-connection.html).
{{< /tab >}}
{{< /tabs >}}

If nothing shows up at all, try another cable; many USB cables are charge-only.

### The board doesn't enter download mode

Hold the **BOOT** button, press and release **RESET**, then release **BOOT**. The chip is now in download mode; run `cargo run --release` again.

On the **ESP32-C3-LCDkit**, the rotary encoder knob is the BOOT button: hold the knob pressed, press and release **RESET**, then release the knob.

### The build fails while downloading dependencies

The test project depends on esp-hal straight from its Git repository. If you are behind a proxy or firewall, make sure `git` and `cargo` can reach `github.com`.

## Next step

[Assignment 1: Your first esp-hal project](../assignment-1/)

[Return to the workshop main page](/workshops/rust-esp-hal-intro/)
