---
title: "TinyGo Embedded Workshop - Introduction"
date: 2026-04-22T00:00:00+01:00
showTableOfContents: false
series: ["WS002EN"]
series_order: 1
showAuthor: false
---

## Introduction to TinyGo

TinyGo is a compiler for Go designed for small places. It brings the Go programming language to microcontrollers and embedded systems, making embedded development accessible to developers who already know Go while providing a modern alternative to C/C++.

### Why TinyGo?

**Go Language Benefits:**
- **Type safety**: Catch errors at compile time, not runtime
- **Memory safety**: Garbage collection prevents memory leaks
- **Concurrency**: Goroutines for managing multiple tasks
- **Simplicity**: Clean syntax, easy to read and maintain
- **Standard library**: Rich set of packages for common tasks

**Embedded-Optimized:**
- **Small binaries**: Optimized for flash-constrained devices (as small as 10KB)
- **Low overhead**: Efficient runtime, minimal memory footprint
- **Hardware support**: Drivers for sensors, displays, communication protocols
- **Cross-platform**: Works on ARM, AVR, RISC-V, ESP32, and more
- **Modern tooling**: Fast compilation, excellent VS Code integration

### TinyGo 0.41 - The Big Release

TinyGo 0.41 brings significant improvements for ESP32 development:

1. **WiFi Support**: Native WiFi on ESP32-C3 and ESP32-S3
2. **espradio Package**: New package for wireless communication
3. **espflasher Package**: Direct flashing without external tools
4. **Improved Performance**: Better optimization and smaller binaries
5. **Enhanced Drivers**: More sensors and displays supported

### What Can You Do with TinyGo?

- **GPIO Control**: Read buttons, control LEDs, drive motors
- **Sensors**: Temperature, humidity, accelerometer, GPS
- **Displays**: OLED, LCD, TFT, e-paper
- **Communication**: I2C, SPI, UART, WiFi, Bluetooth
- **Networking**: HTTP servers, MQTT, WebSocket
- **Storage**: Flash memory, SD cards
- **USB**: Human Interface Devices (HID), serial communication

## Introduction to ESP32

The ESP32 series are low-cost, low-power system on a chip microcontrollers with integrated Wi-Fi and dual-mode Bluetooth. They are widely used in IoT projects, wearables, and smart home devices.

### ESP32 Family Overview

**ESP32 (Original)**
- Dual-core Xtensa LX7 processor @ 240MHz
- 520KB SRAM, up to 4MB flash
- WiFi + Bluetooth Classic + BLE
- Rich peripheral set
- Used in: M5Stack Core2

**ESP32-C3**
- Single-core RISC-V processor @ 160MHz
- 400KB SRAM, up to 16MB flash
- WiFi + BLE
- Ultra-low power
- Used in: M5Stack StampC3, XIAO-ESP32C3

**ESP32-S3**
- Dual-core Xtensa LX7 processor @ 240MHz
- 512KB SRAM, up to 8MB flash
- WiFi + Bluetooth 5 LE
- AI acceleration instructions
- Used in: XIAO-ESP32S3, ESP-SensairShuttle

### Key Features

- **Wireless connectivity**: WiFi and Bluetooth
- **Low power consumption**: Deep sleep, light sleep
- **Rich peripherals**: GPIO, ADC, DAC, PWM, I2C, SPI, UART
- **Development support**: Arduino, ESP-IDF, TinyGo, MicroPython
- **Community**: Large ecosystem, extensive documentation
- **Cost-effective**: Boards starting from $5

### Architecture

The ESP32 architecture consists of:

- **CPUs**: One or more processor cores
- **Memory**: SRAM for data, Flash for code/storage
- **Peripherals**: GPIO, ADC, communication interfaces
- **Radio**: WiFi and Bluetooth modules
- **Power Management**: Sleep modes, voltage regulation

## M5Stack Core2 Development Board

The M5Stack Core2 is a powerful development board based on the ESP32, featuring a built-in display, touchscreen, battery, and sensors.

### Features

- **ESP32**: Dual-core Xtensa LX7 @ 240MHz
- **Display**: 2.0" ILI9342C LCD, 320x240 pixels
- **Touchscreen**: Capacitive touch, I2C interface
- **Battery**: 390mAh LiPo with USB-C charging
- **Sensors**: Accelerometer (BMI260), gyroscope, microphone
- **Connectivity**: WiFi, Bluetooth, GPIO port
- **Power Management**: AXP192 PMIC
- **Audio**: Built-in speaker and microphone
- **Buttons**: 3 face buttons, 1 side power button

### Pin Layout

{{< figure
    default=true
    src="assets/m5stack-core2-pinout.webp"
    caption="M5Stack Core2 Pin Layout"
    height=300
    >}}

### Block Diagram

{{< figure
    default=true
    src="assets/m5stack-core2-block-diagram.webp"
    caption="M5Stack Core2 Block Diagram"
    height=300
    >}}

## M5Stack StampC3 Development Board

The M5Stack StampC3 is a compact development board based on the ESP32-C3, designed for IoT projects requiring WiFi in a small form factor.

### Features

- **ESP32-C3**: Single-core RISC-V @ 160MHz
- **WiFi**: 802.11 b/g/n, 2.4GHz
- **Bluetooth**: BLE 5.0
- **USB-C**: Power, programming, and serial
- **LEDs**: RGB LED, status LED
- **GPIO**: 8 accessible pins
- **Form Factor**: Small, breadboard-compatible

### Key Differences from Core2

- **Smaller**: Compact design, no display
- **Lower Cost**: Budget-friendly
- **WiFi**: Built-in WiFi (unlike some ESP32 boards)
- **USB**: Native USB (no external USB-serial chip)
- **Power**: Lower power consumption

## TinyGo Development Workflow

### 1. Write Code

Create a `main.go` file:

```go
package main

import (
    "machine"
    "time"
)

func main() {
    led := machine.GPIO25
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    for {
        led.High()
        time.Sleep(time.Millisecond * 500)
        led.Low()
        time.Sleep(time.Millisecond * 500)
    }
}
```

### 2. Build

```bash
tinygo build -target m5stack-core2 -o firmware.bin .
```

### 3. Flash

```bash
tinygo flash -target m5stack-core2 -port /dev/ttyUSB0 .
```

### 4. Monitor

```bash
tinygo monitor -port /dev/ttyUSB0 -baudrate 115200
```

## ESP32 Pin Modes

GPIO pins can be configured in different modes:

- **Input**: Read digital state (HIGH/LOW)
- **Output**: Control digital state (HIGH/LOW)
- **ADC**: Read analog voltage (0-3.3V)
- **PWM**: Output PWM signal
- **I2C**: Serial communication (SDA, SCL)
- **SPI**: Serial communication (SCK, MOSI, MISO, CS)
- **UART**: Serial communication (TX, RX)

## Memory Constraints

Microcontrollers have limited memory:

- **Flash**: Stores program code and static data (typically 4MB-16MB)
- **SRAM**: Runtime memory (typically 300KB-520KB)
- **Heap**: Dynamic memory allocation (limited)
- **Stack**: Function call stack (limited)

TinyGo optimizes for small size:
- Minimal runtime overhead
- No garbage collection pauses (for embedded targets)
- Efficient code generation
- Dead code elimination

## Next Steps

Now that you understand the basics of TinyGo and ESP32, let's set up the development environment:

[Assignment 1: Install TinyGo](../assignment-1/)
