---
title: "Build Embedded Swift Application for ESP32-C6"
date: 2024-07-22
lastmod: 2025-09-03
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
    - "juraj-michalek"
tags: ["Embedded Systems", "ESP32-C6", "Espressif", "Swift", "experimental"]
---

## Introduction

Embedded Swift brings the power and expressivity of the Swift programming language to constrained environments such as microcontrollers and other embedded systems. Announced during [WWDC24](https://developer.apple.com/videos/play/wwdc2024/10197/), Embedded Swift aims to provide a lightweight, efficient subset of Swift that maintains the language's core features while significantly reducing its footprint and dependencies. This makes Swift a viable option for developers working in resource-constrained environments, allowing them to leverage Swift's modern syntax and safety features in new and exciting ways.

## What is Embedded Swift?

Embedded Swift is an **experimental** specialized compilation mode of Swift designed to produce small, freestanding binaries suitable for embedded systems and bare-metal programming. It strips down unnecessary features and focuses on essential functionality to generate minimal and efficient code. Key goals include eliminating the large code size associated with the full Swift runtime, simplifying the generated code, and allowing effective dead-code stripping.

Embedded Swift is not a complete SDK or HAL; rather, it provides the tools to compile Swift code into object files that can be integrated with existing embedded development workflows. It supports environments with and without a dynamic heap and aims to remain a subset of Swift, ensuring code compatibility with regular Swift projects.

## Getting Started with Swift for ESP32-C6

The following example covers steps for building Embedded Swift application for ESP32-C6.

### Hardware Setup

Ensure you have the following hardware:

- [ESP32-C6](https://www.espressif.com/en/products/socs/esp32-c6) development board.
- USB-C Cable for power and programming.

### Prerequisites

Before you begin, make sure you have the following:

- [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/index.html): The official development framework for the ESP32, properly installed and sourced in your shell. This tutorial has been tested with ESP-IDF v6.0.
- [Swiftly](https://www.swift.org/install/): The Swift toolchain installer and manager.
- Swift 6.2 development snapshot (installed via swiftly).
  - Note: This article has been updated and tested with Swift 6.2-dev snapshot from August 2025.

### Building an Example Project

First, let's see the whole build process in Asciinema recording:
{{< asciinema key="build-swift-app-for-esp32c6" cols="80" rows="24" poster="npt:0:08" >}}

1. **Install Swift toolchain**:

   First, install Swiftly by following the official installation guide at [swift.org/install](https://www.swift.org/install/), then install the Swift 6.2 development snapshot:

   ```bash
   # Install Swift 6.2 development snapshot
   swiftly install 6.2-snapshot
   ```

2. **Clone Sample Project**:

   The repository contains two ESP32 examples. Let's use the LED strip example which demonstrates more advanced functionality:

   ```shell
   git clone https://github.com/swiftlang/swift-embedded-examples.git --single-branch --branch main
   cd swift-embedded-examples/esp32-led-strip-sdk
   
   # Use the 6.2 snapshot for this project
   swiftly use 6.2-snapshot
   ```

   **Available ESP32 Examples:**
   - `esp32-led-blink-sdk`: Simple LED blinking example
   - `esp32-led-strip-sdk`: NeoPixel LED strip control example (used in this tutorial)


3. **Set the Target**:

   Ensure the correct target is set for your project:

   ```bash
   idf.py set-target esp32c6
   ```

   Note: It's possible to build the project also for other RISC-V based targets, like ESP32-C3.

4. **Build and Flash the Project**:

   Compile and flash your application to the ESP32-C6-DevKit:

   ```bash
   idf.py build flash monitor
   ```

   Note: Use `Ctrl+]` to quit the monitor application.

### Exploring the Example

Let's look at the source code of the example: [Main.swift](https://github.com/swiftlang/swift-embedded-examples/blob/main/esp32-led-strip-sdk/main/Main.swift)
```swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

@_cdecl("app_main")
func app_main() {
  print("Hello from Swift on ESP32-C6!")

  let n = 8
  let ledStrip = LedStrip(gpioPin: 0, maxLeds: n)
  ledStrip.clear()

  var colors: [LedStrip.Color] = .init(repeating: .off, count: n)
  while true {
    colors.removeLast()
    colors.insert(.lightRandom, at: 0)

    for index in 0 ..< n {
      ledStrip.setPixel(index: index, color: colors[index])
    }
    ledStrip.refresh()

    let blinkDelayMs: UInt32 = 500
    vTaskDelay(blinkDelayMs / (1000 / UInt32(configTICK_RATE_HZ)))
  }
}
```

This code initializes an LED strip connected to an ESP32-C6 microcontroller. The app_main function starts by printing a message, then sets up an LED strip on GPIO pin 0 with a maximum of 8 LEDs. It clears the strip and enters an infinite loop where it cycles a random light color through the LEDs. Each iteration updates the LED colors, refreshes the strip, and delays for 500 milliseconds.

## Simulation in Wokwi

The examples for ESP32-C6 could be easily simulated by Wokwi:

- [Embedded Swift - ESP32-C6 - Led Blink](https://wokwi.com/experimental/viewer?diagram=https://raw.githubusercontent.com/georgik/swift-embedded-examples/feature/wokwi/esp32-led-blink-sdk/diagram.json&firmware=https://github.com/georgik/swift-embedded-examples/releases/download/v0.1/embedded-swift-esp32-c6-led-blink-sdk.uf2.bin)
- [Embedded Swift - ESP32-C6 - Led Strip](https://wokwi.com/experimental/viewer?diagram=https://raw.githubusercontent.com/georgik/swift-embedded-examples/feature/wokwi/esp32-led-strip-sdk/diagram.json&firmware=https://github.com/georgik/swift-embedded-examples/releases/download/v0.1/embedded-swift-esp32-c6-led-strip-sdk.uf2.bin)

## Conclusion

Embedded Swift even in **experimental** stage represents a significant advancement in bringing Swift's powerful features to embedded systems and constrained environments. By focusing on reducing runtime dependencies and optimizing code size, Embedded Swift allows developers to leverage Swift's modern programming paradigms even on MCUs.

## What's New Since the Original Article (Updated September 2025)

Since the original publication in July 2024, several important improvements have been made to the Embedded Swift ecosystem:

### Toolchain Management
- **Swiftly Integration**: The recommended way to install and manage Swift toolchains is now through [Swiftly](https://www.swift.org/install/), which simplifies toolchain management significantly.
- **Swift 6.2 Development**: The examples now work with Swift 6.2 development snapshots, providing access to the latest language features and improvements.

### ESP-IDF Compatibility
- **ESP-IDF 6.0 Support**: The examples have been tested and work with ESP-IDF v6.0, which includes many improvements and new features.
- **Updated Dependencies**: All component dependencies are automatically managed and updated to their latest versions.

### Repository Changes
- **Organization Move**: The swift-embedded-examples repository has moved from `apple/swift-embedded-examples` to `swiftlang/swift-embedded-examples`.
- **Documentation Improvements**: Enhanced documentation with better installation guides and troubleshooting information.

## Useful Links

- [WWDC24 - Go small with Embedded Swift](https://developer.apple.com/videos/play/wwdc2024/10197/)
- [Embedded Swift Example Projects](https://github.com/swiftlang/swift-embedded-examples)
- [A Vision for Embedded Swift](https://github.com/swiftlang/swift-evolution/blob/main/visions/embedded-swift.md)
- [Embedded Swift Documentation](https://www.swift.org/get-started/embedded/)
- [Installing Embedded Swift](https://docs.swift.org/embedded/documentation/embedded/installembeddedswift/)
- [Blog Post Introducing Embedded Swift Examples](https://www.swift.org/blog/embedded-swift-examples/)
- [Swiftly - Swift Toolchain Manager](https://www.swift.org/install/)
