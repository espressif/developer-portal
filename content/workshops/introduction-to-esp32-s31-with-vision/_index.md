---
title: "Introduction to the ESP32-S31 with Vision"
date: 2026-09-28
tags: ["Workshop", "ESP-IDF", "ESP32-S31", "AI", "ESP-DL", "ESP-Vision", "computer vision"]
summary: "Explore the ESP32-S31 and build edge computer vision applications with ESP-DL and ESP-Vision on the ESP32-S31-Korvo-1."
showTableOfContents: true
---

Welcome to the Introduction to the ESP32-S31 with Vision workshop!

## About this workshop

In this workshop, you will explore the ESP32-S31 and build computer-vision applications that run entirely on the device. You will use the ESP32-S31-Korvo-1 multimedia development board, its Board Support Package (BSP), [ESP-DL](https://github.com/espressif/esp-dl), and ESP-Vision.

The workshop starts with the SoC and board architecture. You will then run face detection from a native ESP-IDF application before moving to the Python-based ESP-Vision workflow. The final assignments combine hand detection, simple tracking, a configurable safety zone, display overlays, and an RGB LED warning into a "Keep hands off!" application.

Inference remains local throughout the workshop. Camera frames do not need to be sent to a cloud service.

By the end of the workshop, you will know how to:

- Identify the processing, connectivity, multimedia, and security capabilities of the ESP32-S31.
- Use the ESP32-S31-Korvo-1 camera, display, touch, LED, audio, and storage hardware through its BSP.
- Load an ESP-DL model and run face detection from an ESP-IDF application.
- Use ESP-Vision and develop camera applications in Python.
- Connect an AI coding assistant to the ESP-Vision MCP server.
- Select an appropriate local model for an embedded vision task.
- Detect and track hands in camera frames.
- Detect when a hand enters a safety zone and generate a local warning.

## Prerequisites

### Required hardware

- Computer running Linux, Windows, or macOS.
- [ESP32-S31-Korvo-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-korvo-1/user_guide.html).
- USB Type-C data cable connected to the board's **UART** port.
- USB Type-A to Type-A data cable for connecting the ESP32-S31-Korvo-1 to the ESP-Vision Web IDE.
- FAT32-formatted microSD card for ESP-Vision model files.
- Optional second USB Type-C cable for the dedicated power port.

### Required software

- ESP-IDF v6.1
- `git` and a serial terminal
- Chromium-based browser with Web Serial support for the ESP-Vision Web IDE and web flasher
- [Cursor](https://www.cursor.com/) for the agent-assisted exercises. Other MCP-compatible agents can also be used, including Visual Studio Code with GitHub Copilot agent mode, Claude Code, and Claude Desktop.
- Optional: [Visual Studio Code](https://code.visualstudio.com/) with the [ESP-IDF extension](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension) for native development and the ESP-Vision extension available from the [ESP-Vision website](https://vision.espressif.com/en) for the later Python exercises.

> [!IMPORTANT]
> ESP32-S31 support is evolving. The commands and APIs in this workshop target ESP32-S31, BSP `espressif/esp32_s31_korvo_1` 1.0.x, and ESP-DL 3.3.x. If you intentionally use newer component versions, review their changelogs before adapting the examples.

## Agenda

- [Introduction to the ESP32-S31](introduction)
- [Lecture 1: Introduction to the ESP32-S31-Korvo-1](lecture-1)
- [Assignment 1: Face detection with ESP-DL and the ESP32-S31-Korvo-1 BSP](assignment-1)
- [Assignment 2: Getting started with ESP-Vision](assignment-2)
- [Assignment 3: Set up the ESP-Vision MCP server](assignment-3)
- [Assignment 4: LED blink with ESP-Vision](assignment-4)
- [Assignment 5: Your first camera application](assignment-5)
- [Lecture 2: Available models for ESP-Vision](lecture-2)
- [Assignment 6: Hand detection with ESPDet](assignment-6)
- [Assignment 7: Add a safety zone](assignment-7)
- [Assignment 8: Keep hands off!](assignment-8)
- [Lecture 3: Conclusion](lecture-3)

## Time requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 240 min**
{{< /alert >}}

## Next step

[Introduction to the ESP32-S31](introduction)

## Feedback

If you have any feedback about this workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).
