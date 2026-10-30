---
title: "Introduction to the ESP32-S31 with Vision"
date: 2026-11-03
tags: ["Workshop", "ESP-IDF", "ESP32-S31", "AI", "ESP-DL", "ESP-Vision", "computer vision"]
summary: "Explore the ESP32-S31 and build edge computer vision applications with ESP-DL and ESP-Vision on the ESP32-S31-Korvo-1."
showTableOfContents: true
---

Welcome to the Introduction to the ESP32-S31 with Vision workshop!

## About this workshop

In this workshop, you will explore the ESP32-S31 system-on-chip (SoC) and build computer-vision applications that run entirely on the device. You will use the ESP32-S31-Korvo-1 multimedia development board, its Board Support Package (BSP), ESP-Vision, and [ESP-DL](https://github.com/espressif/esp-dl).

The workshop begins with the SoC and development board overviews. You’ll first use the ESP-VISION workflow to build camera and safety-zone applications in MicroPython—a lightweight implementation of Python designed for microcontrollers. Your Python code will run directly on ESP32-S31, rather than on your computer.

Then, you’ll contrast the ESP-VISION workflow with the traditional ESP-IDF workflow by using the ESP32-S31-Korvo-1 BSP and adding ESP-DL face detection to its camera example.

If you choose so, you will be able to use AI with the ESP-Vision MCP server for agent-assisted application development.

Inference remains local throughout the workshop. Camera frames do not need to be sent to a cloud service.

By the end of the workshop, you will know how to:

- Identify the processing, connectivity, multimedia, and security capabilities of the ESP32-S31.
- Use ESP-Vision and develop camera applications in Python.
- (optional) Connect an AI coding assistant to the ESP-Vision MCP server.
- Select an appropriate local model for an embedded vision task.
- Detect and track hands in camera frames.
- Detect when a hand enters a safety zone and generate a local warning.
- Use the ESP32-S31-Korvo-1 camera, display, touch, LED, audio, and storage hardware through its BSP.
- Load an ESP-DL model and run face detection from an ESP-IDF application.

## Prerequisites

### Required hardware

- Computer running Linux, Windows, or macOS.
- [ESP32-S31-Korvo-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-korvo-1/user_guide.html).
- USB Type-C data cable to connect your computer to the board's **UART** port.
- USB Type-A to Type-A data cable to connect the ESP32-S31-Korvo-1 to the ESP-Vision Web IDE.
- (optional) microSD card formatted as FAT32 for storing model files that are too large for the ESP-Vision internal flash filesystem.
- (optional) Another USB Type-C cable for the dedicated power port.


> [!IMPORTANT]
> When the board receives power through the USB Type-A connection, the board's power switch cannot turn it off. Disconnect the Type-A to Type-A cable to fully remove power.

### Required software

#### ESP-Vision

- A desktop browser with Web Serial support for the [ESP-Vision Web IDE and web flasher](https://vision.espressif.com/en): Google Chrome 89+, Microsoft Edge 89+, Opera 76+, or Firefox 151+. Other Chromium-based browsers, such as Brave, may also work. Safari is not supported; Chrome or Edge is recommended.
- [Cursor](https://www.cursor.com/) for the agent-assisted exercises. Other MCP-compatible agents can also be used, including Visual Studio Code with GitHub Copilot agent mode, Claude Code, and Claude Desktop.

#### ESP-DL and native ESP-IDF development

- ESP-IDF v6.1 or later; v6.1 is recommended
- `git` and a serial terminal
- Optional: [Visual Studio Code](https://code.visualstudio.com/) with the [ESP-IDF extension](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension)

> [!IMPORTANT]
> ESP32-S31 support is evolving. The commands and APIs in this workshop target ESP32-S31, BSP `espressif/esp32_s31_korvo_1` 1.0.x, and ESP-DL 3.3.x. If you intentionally use newer component versions, review their changelogs before adapting the examples.

## Agenda

- [Overview of the ESP32-S31 SoC](overview-soc)
- [Overview of the ESP32-S31-Korvo-1 devboard](overview-devboard)
- [Tooling: Getting started with ESP-Vision](tooling-esp-vision)
- [Tooling: Set up the ESP-Vision MCP server (optional)](tooling-mcp)
- [Assignment 1: LED blink with ESP-Vision](assignment-1)
- [Assignment 2: Your first camera application](assignment-2)
- [Lecture 1: Available models for ESP-Vision](lecture-1)
- [Assignment 3: Hand detection with ESPDet](assignment-3)
- [Assignment 4: Add a safety zone](assignment-4)
- [Assignment 5: Keep hands off!](assignment-5)
- [Assignment 6: Get started with the ESP32-S31-Korvo-1 BSP](assignment-6)
- [Assignment 7: Face detection with ESP-DL](assignment-7)
- [Conclusion](conclusion)

## Time requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 240 min**
{{< /alert >}}

## Next step

[Overview of the ESP32-S31](overview-soc)

## Feedback

If you have any feedback about this workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).
