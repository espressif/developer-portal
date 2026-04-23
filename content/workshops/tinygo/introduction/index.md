---
title: "TinyGo Embedded Workshop - Introduction"
date: 2026-04-22T00:00:00+01:00
lastmod: 2026-04-22
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

1. **Wi-Fi Support**: Native Wi-Fi on ESP32-C3 and ESP32-S3
2. **espradio Package**: New package for wireless communication
3. **espflasher Package**: Direct flashing without external tools
4. **Improved Performance**: Better optimization and smaller binaries
5. **Enhanced Drivers**: More sensors and displays supported

### What Can You Do with TinyGo?

- **GPIO Control**: Read buttons, control LEDs, drive motors
- **Sensors**: Temperature, humidity, accelerometer, GPS
- **Displays**: OLED, LCD, TFT, e-paper
- **Communication**: I2C, SPI, UART, Wi-Fi, Bluetooth
- **Networking**: HTTP servers, MQTT, WebSocket
- **Storage**: Flash memory, SD cards
- **USB**: Human Interface Devices (HID), serial communication

## Introduction to ESP32

The ESP32 series are low-cost, low-power system on a chip microcontrollers with integrated Wi-Fi and dual-mode Bluetooth. They are widely used in IoT projects, wearables, and smart home devices.

**Choosing the Right MCU:**
Espressif offers a [Product Selector](https://products.espressif.com/) to help you choose the proper MCU for your project based on requirements like Wi-Fi, Bluetooth, memory, peripherals, and packaging.

### ESP32 Family Overview

**ESP32 (Original)**
- Dual-core Xtensa LX7 processor @ 240MHz
- 520KB SRAM, up to 4MB flash
- Wi-Fi + Bluetooth Classic + BLE
- Rich peripheral set
- Used in: M5Stack Core2

**ESP32-C3**
- Single-core RISC-V processor @ 160MHz
- 400KB SRAM, up to 16MB flash
- Wi-Fi + BLE
- Ultra-low power
- Used in: M5Stack StampC3, XIAO-ESP32C3

**ESP32-S3**
- Dual-core Xtensa LX7 processor @ 240MHz
- 512KB SRAM, up to 8MB flash
- Wi-Fi + Bluetooth 5 LE
- AI acceleration instructions
- Used in: M5Stack CoreS3, XIAO-ESP32S3

### Key Features

- **Wireless connectivity**: Wi-Fi and Bluetooth
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
- **Radio**: Wi-Fi and Bluetooth modules
- **Power Management**: Sleep modes, voltage regulation

## M5Stack Core2 Development Board

The M5Stack Core2 is a powerful development board based on the ESP32, featuring a built-in display, touchscreen, battery, and sensors.

### Features

- **ESP32**: Dual-core Xtensa LX7 @ 240MHz
- **Display**: 2.0" ILI9342C LCD, 320x240 pixels
- **Touchscreen**: Capacitive touch, I2C interface
- **Battery**: 390mAh LiPo with USB-C charging
- **Sensors**: Accelerometer (BMI260), gyroscope, microphone
- **Connectivity**: Wi-Fi, Bluetooth, GPIO port
- **Power Management**: AXP192 PMIC
- **Audio**: Built-in speaker and microphone
- **Buttons**: 3 face buttons, 1 side power button

### Pin Layout and Simulation

For interactive pin layout visualization and simulation, visit [Wokwi ESP32 Simulator](https://wokwi.com/esp32). Wokwi provides an online simulator where you can visualize ESP32 pin connections and test code without hardware.

## M5Stack StampC3 Development Board

The M5Stack StampC3 is a compact development board based on the ESP32-C3, designed for IoT projects requiring Wi-Fi in a small form factor.

### Features

- **ESP32-C3**: Single-core RISC-V @ 160MHz
- **Wi-Fi**: 802.11 b/g/n, 2.4GHz
- **Bluetooth**: BLE 5.0
- **USB-C**: Power, programming, and serial
- **LEDs**: RGB LED, status LED
- **GPIO**: 8 accessible pins
- **Form Factor**: Small, breadboard-compatible

### Key Differences from Core2

- **Smaller**: Compact design, no display
- **Lower Cost**: Budget-friendly
- **Wi-Fi**: Built-in Wi-Fi (unlike some ESP32 boards)
- **USB**: Native USB (no external USB-serial chip)
- **Power**: Lower power consumption

## TinyGo Development Workflow

### 1. Initialize Project

```bash
mkdir gopher-blink
cd gopher-blink
go mod init gopher-blink
```

### 2. Write Code

Create a `main.go` file:

{{< tabs groupId="board" >}}
  {{% tab name="ESP32" %}}
```go
package main

import (
    "machine"
    "time"
)

func main() {
    // Initialize serial for output
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})

    // Initialize LED
    led := machine.GPIO2
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    serial.Write([]byte("LED Blink Example\r\n"))

    for {
        serial.Write([]byte("LED ON\r\n"))
        led.High()
        time.Sleep(time.Millisecond * 500)

        serial.Write([]byte("LED OFF\r\n"))
        led.Low()
        time.Sleep(time.Millisecond * 500)
    }
}
```
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
```go
package main

import (
    "machine"
    "time"
)

func main() {
    // Initialize serial for output
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})

    // Initialize LED
    led := machine.GPIO2
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    serial.Write([]byte("LED Blink Example\r\n"))

    for {
        serial.Write([]byte("LED ON\r\n"))
        led.High()
        time.Sleep(time.Millisecond * 500)

        serial.Write([]byte("LED OFF\r\n"))
        led.Low()
        time.Sleep(time.Millisecond * 500)
    }
}
```
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
```go
package main

import (
    "machine"
    "time"
)

func main() {
    // Initialize serial for output
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})

    // Initialize LED
    led := machine.GPIO8
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    serial.Write([]byte("LED Blink Example\r\n"))

    for {
        serial.Write([]byte("LED ON\r\n"))
        led.High()
        time.Sleep(time.Millisecond * 500)

        serial.Write([]byte("LED OFF\r\n"))
        led.Low()
        time.Sleep(time.Millisecond * 500)
    }
}
```
  {{% /tab %}}
{{< /tabs >}}

### 3. Build

{{< tabs groupId="board" >}}
  {{% tab name="ESP32" %}}
```bash
tinygo build -target m5stack-core2 -o firmware.bin .
```
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
```bash
tinygo build -target esp32s3-generic -o firmware.bin .
```
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
```bash
tinygo build -target m5stack-stampc3 -o firmware.bin .
```
  {{% /tab %}}
{{< /tabs >}}

### 4. Flash

{{< tabs groupId="board" >}}
  {{% tab name="ESP32" %}}
```bash
tinygo flash -target m5stack-core2 .
```
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
```bash
tinygo flash -target esp32s3-generic .
```
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
```bash
tinygo flash -target m5stack-stampc3 .
```
  {{% /tab %}}
{{< /tabs >}}

**Tip:** TinyGo can auto-detect the port and baudrate, so you don't need to specify them manually.

### 5. Monitor

```bash
tinygo monitor
```

You should see:
```
LED Blink Example
LED ON
LED OFF
LED ON
LED OFF
...
```

**Tip:** Press `Ctrl+C` to stop the monitor.

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
