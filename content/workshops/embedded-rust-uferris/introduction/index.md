---
title: "Introduction: Setup and Overview"
date: 2026-05-18T00:00:00+01:00
lastmod: 2026-06-15
showTableOfContents: true
series: ["WS-RUST-ESP"]
series_order: 1
showAuthor: false
---

## Workshop Overview

This workshop teaches embedded Rust development using the ESP32-C3 microcontroller and the `esp-hal` crate. Rather than following step-by-step tutorials, you'll learn to navigate the ecosystem, read documentation, and adapt examples independently.

### What You'll Learn

- **Navigate the embedded Rust ecosystem** — find the right abstractions and know where to look
- **Read embedded Rust documentation** — in crate docs, source code, and examples
- **Apply the Instantiate → Configure → Control pattern** — a mental model that works across all peripherals
- **Adapt existing examples** to new use cases using the documentation

### The Hardware

{{< figure
    default=true
    src="assets/uferris-board.webp"
    alt="uFerris Board"
    caption="The uFerris learning platform"
    >}}

The workshop uses the **Seeed Studio XIAO ESP32-C3**:

{{< figure
    default=true
    src="assets/xiao-esp32c3.webp"
    alt="Seeed Studio XIAO ESP32-C3"
    caption="XIAO ESP32-C3 module"
    >}}

- **Architecture:** 32-bit RISC-V (single core, 160 MHz)
- **Memory:** 400 KB SRAM, 4 MB Flash
- **Connectivity:** WiFi 802.11 b/g/n, Bluetooth 5 (LE)
- **Peripherals:** GPIO, I2C, SPI, UART, ADC, PWM
- **USB:** Native USB-C (no external programmer needed)

## Pre-Workshop Setup

Please complete this setup **before the workshop day**. The goal is zero time spent on toolchain issues during the workshop itself.

### 1. Install Rust

If you don't have Rust installed yet:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

After installation, restart your terminal or run:

```bash
source $HOME/.cargo/env
```

Verify:

```bash
rustc --version
cargo --version
```

### 2. Add the RISC-V Target

The ESP32-C3 uses a RISC-V architecture:

```bash
rustup target add riscv32imc-unknown-none-elf
```

### 3. Install espflash

`espflash` is used to flash firmware and monitor serial output:

```bash
cargo install espflash
```

Verify:

```bash
espflash --version
```

### 4. Install esp-generate

`esp-generate` creates new ESP32 Rust projects from templates:

```bash
cargo install esp-generate --locked
```

### 5. Generate and Build a Test Project

```bash
esp-generate --chip esp32c3 -o unstable-hal -o vscode -o esp-backtrace -o log --headless hello_test
cd hello_test
cargo build --release
```

{{< alert icon="circle-info" >}}
The first build will take a while as it downloads and compiles dependencies. Subsequent builds are fast.
{{< /alert >}}

### 6. Hardware Verification

Connect your ESP32-C3 board via USB-C and run:

```bash
cargo run
```

You should see the project build, flash to the board, and then serial output. Press `Ctrl+C` to exit the monitor.

### Troubleshooting

#### espflash can't find the serial port

{{< tabs groupId="os" >}}
{{% tab name="Linux" %}}
```bash
ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null
```

If no device appears, create `/etc/udev/rules.d/99-esp32.rules`:
```
SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0666"
```
Then reload:
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

For permission errors:
```bash
sudo usermod -a -G dialout $USER
```
Log out and back in.
{{% /tab %}}
{{% tab name="macOS" %}}
```bash
ls /dev/cu.usbmodem* /dev/cu.usbserial* 2>/dev/null
```
The ESP32-C3 uses a built-in USB-JTAG interface. If not recognized, try a different USB cable (some are charge-only).
{{% /tab %}}
{{% tab name="Windows" %}}
```powershell
Get-WMIObject Win32_SerialPort | Select-Object Name, DeviceID
```
Install the [USB-JTAG driver](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/get-started/establish-serial-connection.html) if the device isn't recognized.
{{% /tab %}}
{{< /tabs >}}

#### Board not responding

1. Try a different USB cable (must support data, not just charging)
2. Try a different USB port
3. Press and hold the BOOT button, then press RESET, then release BOOT — this forces download mode

### Simulation Fallback

If your hardware setup fails, you can use a **Wokwi simulation** as a fallback:

1. Go to the [Simplified Embedded Rust book project branch](https://github.com/theembeddedrustacean/ser-no-std/tree/project)
2. Click **Code → Codespaces → Create codespace on project**
3. Wait for the devcontainer to build
4. Replace the code in `src/main.rs` with your workshop exercise code

{{< alert >}}
The workshop is designed for real hardware. Use this fallback only if you cannot resolve hardware issues.
{{< /alert >}}
