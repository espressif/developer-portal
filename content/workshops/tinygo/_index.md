---
title: "TinyGo Embedded Workshop"
date: 2026-04-22T00:00:00+01:00
tags: ["Workshop", "TinyGo", "ESP32", "Embedded", "Go"]
---

Welcome to the TinyGo Embedded Workshop!

## About this workshop

By participating in this workshop, you will gain hands-on experience with embedded development using TinyGo on ESP32 microcontrollers. Through practical assignments, you will learn to create IoT applications using the Go programming language, from simple LED control to WiFi connectivity and edge AI concepts.

TinyGo brings the simplicity and safety of Go to microcontrollers, making embedded development accessible to Go developers while maintaining the performance needed for resource-constrained devices.

## Agenda

If you have met the [prerequisites](#prerequisites), we can start with the individual chapters:

- [Introduction: TinyGo and ESP32](introduction/): Overview of TinyGo, ESP32 architecture, and development boards
- [Assignment 1: Install TinyGo](assignment-1/): Setting up the development environment
- [Assignment 2: Blinky](assignment-2/): Your first embedded program - LED control
- [Assignment 3: Display](assignment-3/): Graphics, text, and images on LCD displays
- [Assignment 4: Sensors](assignment-4/): Reading data from I2C sensors
- [Assignment 5: WiFi Client](assignment-5/): Connecting to networks and fetching data
- [Assignment 6: WiFi Server](assignment-6/): Running a web server on ESP32
- [Assignment 7: AI Edge Models](assignment-7/): Introduction to edge AI and machine learning concepts

## Prerequisites

To follow this workshop, you will need both hardware and software equipment.

Required hardware:

- Computer running Linux, Windows or macOS operating system
- ESP32 development board:
  - **Recommended**: M5Stack Core2 (ESP32, 320x240 display, touchscreen, sensors)
  - **Alternative**: M5Stack StampC3 (ESP32-C3, compact, WiFi)
  - **Alternative**: XIAO-ESP32C3 or XIAO-ESP32S3
- USB-C cable (supporting power + data) compatible with your board

Required software:

- [Go 1.22+](https://go.dev/dl/)
- [TinyGo 0.41](https://tinygo.org/getting-started/install/)
- [Visual Studio Code](https://code.visualstudio.com/download) (recommended)
- [TinyGo extension for VS Code](https://marketplace.visualstudio.com/items?itemName=sebastiansthilaire.tinygo) (optional)

Recommended software:

- [Git](https://git-scm.com/downloads)
- Serial monitor tool (`screen`, `minicom`, or platform-specific alternatives)

## Time Requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 240 min (4 hours)**
{{< /alert >}}

## What makes TinyGo special?

TinyGo is a compiler for Go designed for small devices. Here's why it's great for embedded development:

1. **Go language benefits**: Memory safety, garbage collection, concise syntax
2. **Small binaries**: Optimized for flash-constrained devices
3. **Hardware support**: Drivers for common sensors, displays, and communication protocols
4. **WiFi and networking**: Built-in support for WiFi, HTTP, MQTT on ESP32
5. **Simplicity**: No build systems or complex toolchains like C/C++
6. **Modern tooling**: Excellent VS Code integration, fast compile times

## Workshop objectives

By the end of this workshop, you will be able to:

- Set up a TinyGo development environment
- Write embedded programs using Go
- Control GPIO pins, read sensors, and drive displays
- Connect to WiFi networks and implement network communication
- Understand edge AI concepts and explore machine learning on microcontrollers
- Build your own IoT projects using TinyGo

## Feedback

If you have any feedback about the workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).

## Resources

- [TinyGo Documentation](https://tinygo.org/)
- [TinyGo 0.41 Release Notes](https://tinygo.org/blog/2026/tinygo-0-41-the-big-release/)
- [TinyGo Drivers Repository](https://github.com/tinygo-org/drivers)
- [M5Stack Core2 Documentation](https://docs.m5stack.com/en/core/core2)
- [Espressif Developer Portal](https://developers.espressif.com/)

## Conclusion

We hope that this workshop will provide you with a solid foundation for embedded development using TinyGo. Thank you for your time and interest, and we look forward to seeing the projects you will create!

---

Next: [Introduction: TinyGo and ESP32](introduction/)
