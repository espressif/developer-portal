---
title: "Build Embedded Swift Application for ESP32-C6"
date: 2024-06-21
showAuthor: false
authors:
    - "juraj-michalek"
tags: ["Embedded Systems", "ESP32-C6", "Espressif", "Swift"]
---

# Build Swift Application for ESP32-C6

## Introduction

## What is Embedded Swift?

## Getting Started with Swift for ESP32-C6

The following example covers steps for building Embedded Swift application for ESP32-C6.

### Hardware Setup

Ensure you have the following hardware:

- [ESP32-C6](https://www.espressif.com/en/products/socs/esp32-c6) development board.
- USB-C Cable for power and programming.

### Prerequisites

Before you begin, make sure you have the following:

- [ESP-IDF v5.3](https://docs.espressif.com/projects/esp-idf/en/release-v5.3/esp32/get-started/index.html): The official development framework for the ESP32, properly installed and sourced in your shell.
- [Swift 6](https://www.swift.org/install/macos/#development-snapshots)

### Building an Example Project

Let’s build example project.

First, let's see the whole build in Asciinema recording:
{{< asciinema key="build-swift-app-for-esp32c6" cols="80" rows="24" poster="npt:0:08" >}}

1. **Clone Sample Project**:

   Let's clone project and configure `TOOLCHAINS` environment variable with the version of the installed Swift 6.

   ```bash
   git clone git@github.com:apple/swift-embedded-examples.git --single-branch --branch main
   export TOOLCHAINS=org.swift.600202406111a
   cd swift-embedded-examples/esp32-led-strip-sdk
   ```

2. **Set the Target**:

   Ensure the correct target is set for your project:

   ```bash
   idf.py set-target esp32c6
   ```

3. **Build and Flash the Project**:

   Compile and flash your application to the ESP32-S3-BOX-3:

   ```bash
   idf.py build flash monitor
   ```

   Note: Use `Ctrl+]` to quit the monitor application.

   Note: If the build fails with linking error, please follow instructions at [swift-embedded-examples repository](https://github.com/apple/swift-embedded-examples/issues/17#issuecomment-2174606877)

### Exploring the Example


Let's look at the source code of the example: [Main.swift](https://github.com/apple/swift-embedded-examples/blob/main/esp32-led-strip-sdk/main/Main.swift)

## Conclusion


## Useful Links

- [Embedded Swift Example Projects](https://github.com/apple/swift-embedded-examples/tree/main/esp32-led-strip-sdk)
- [WWDC24 - Go small with Embedded Swift](https://developer.apple.com/videos/play/wwdc2024/10197/)
