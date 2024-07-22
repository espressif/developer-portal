---
title: "Build Embedded Swift Application for ESP32-C6"
date: 2024-06-21
showAuthor: false
authors:
    - "juraj-michalek"
tags: ["Embedded Systems", "ESP32-C6", "Espressif", "Swift"]
---

## Introduction

Embedded Swift brings the power and expressivity of the Swift programming language to constrained environments such as microcontrollers and other embedded systems. Announced during [WWDC24](https://developer.apple.com/videos/play/wwdc2024/10197/), Embedded Swift aims to provide a lightweight, efficient subset of Swift that maintains the language's core features while significantly reducing its footprint and dependencies. This makes Swift a viable option for developers working in resource-constrained environments, allowing them to leverage Swift's modern syntax and safety features in new and exciting ways.

## What is Embedded Swift?

Embedded Swift is a specialized compilation mode of Swift designed to produce small, freestanding binaries suitable for embedded systems and bare-metal programming. It strips down unnecessary features and focuses on essential functionality to generate minimal and efficient code. Key goals include eliminating the large code size associated with the full Swift runtime, simplifying the generated code, and allowing effective dead-code stripping.

Embedded Swift is not a complete SDK or HAL; rather, it provides the tools to compile Swift code into object files that can be integrated with existing embedded development workflows. It supports environments with and without a dynamic heap and aims to remain a subset of Swift, ensuring code compatibility with regular Swift projects.

## Getting Started with Swift for ESP32-C6

The following example covers steps for building Embedded Swift application for ESP32-C6.

### Hardware Setup

Ensure you have the following hardware:

- [ESP32-C6](https://www.espressif.com/en/products/socs/esp32-c6) development board.
- USB-C Cable for power and programming.

### Prerequisites

Before you begin, make sure you have the following:

- [ESP-IDF v5.3](https://docs.espressif.com/projects/esp-idf/en/release-v5.3/esp32/get-started/index.html): The official development framework for the ESP32, properly installed and sourced in your shell.
- Swift 6 - nightly toolchain ([macOS download](https://www.swift.org/install/macos/#development-snapshots) / [Linux download](https://www.swift.org/install/linux))
  - Note: the article was written using Apple Swift version 6.0-dev (LLVM 3bba20e27a3bcf9, Swift 8e8e486fb05209f)

### Building an Example Project

First, let's see the whole build process in Asciinema recording:
{{< asciinema key="build-swift-app-for-esp32c6" cols="80" rows="24" poster="npt:0:08" >}}

1. **Clone Sample Project**:

   Let's clone the project and configure `TOOLCHAINS` environment variable with the version of the installed Swift 6.


   - Linux:
   ```bash
   git clone git@github.com:apple/swift-embedded-examples.git --single-branch --branch main
   cd swift-embedded-examples/esp32-led-strip-sdk
   ```

   - macOS
   ```bash
   git clone git@github.com:apple/swift-embedded-examples.git --single-branch --branch main
   #export TOOLCHAINS=org.swift.600202406111a
   export TOOLCHAINS=$(plutil -extract CFBundleIdentifier raw /Library/Developer/Toolchains/swift-latest.xctoolchain/Info.plist)
   cd swift-embedded-examples/esp32-led-strip-sdk
   ```


2. **Set the Target**:

   Ensure the correct target is set for your project:

   ```bash
   idf.py set-target esp32c6
   ```

   Note: It's possible to build the project also for other RISC-V based targets, like ESP32-C3.

3. **Build and Flash the Project**:

   Compile and flash your application to the ESP32-C6-DevKit:

   ```bash
   idf.py build flash monitor
   ```

   Note: Use `Ctrl+]` to quit the monitor application.

   Note: If the build fails with linking error, please follow instructions at [swift-embedded-examples repository](https://github.com/apple/swift-embedded-examples/issues/17#issuecomment-2174606877)

### Exploring the Example

Let's look at the source code of the example: [Main.swift](https://github.com/apple/swift-embedded-examples/blob/main/esp32-led-strip-sdk/main/Main.swift)
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

## Conclusion

Embedded Swift represents a significant advancement in bringing Swift's powerful features to embedded systems and constrained environments. By focusing on reducing runtime dependencies and optimizing code size, Embedded Swift allows developers to leverage Swift's modern programming paradigms even on MCUs.

## Useful Links

- [WWDC24 - Go small with Embedded Swift](https://developer.apple.com/videos/play/wwdc2024/10197/)
- [Embedded Swift Example Projects](https://github.com/apple/swift-embedded-examples/tree/main/esp32-led-strip-sdk)
- [A Vision for Embedded Swift](https://github.com/apple/swift-evolution/blob/main/visions/embedded-swift.md)
- [Embedded Swift User Manual](https://github.com/apple/swift/tree/main/docs/EmbeddedSwift/UserManual.md)
- [Blog Post Introducing Embedded Swift Examples](https://www.swift.org/blog/embedded-swift-examples/)
- [Swift Development Snapshots](https://www.swift.org/download/#snapshots)
