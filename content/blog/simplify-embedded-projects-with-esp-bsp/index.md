---
title: "Simplify Your Embedded Projects with ESP-BSP"
date: 2024-06-18
showAuthor: false
authors:
    - "juraj-michalek"
tags: ["Embedded Systems", "ESP32", "ESP32-S3", "Espressif", "BSP"]
---

# Simplify Your Embedded Projects with ESP-BSP

## Introduction

Are you a maker or an embedded systems enthusiast looking to create applications that work seamlessly across different ESP32 development boards? Whether you’re using the ESP-Wrover-Kit, M5Stack-CoreS3, ESP32-S3-BOX-3, or other compatible boards, the ESP Board Support Package (ESP-BSP) makes your life easier. In this article, we’ll walk you through how to get started with ESP-BSP, enabling you to focus on your project’s functionality without worrying about hardware differences.

## What is ESP-BSP?

ESP-BSP is a collection of Board Support Packages specifically designed for Espressif’s development boards. It provides a standardized interface, allowing you to develop applications that are easy to port between different boards. By using ESP-BSP, you can:

- **Streamline Hardware Integration**: Simplify code and reduce complexity.
- **Enhance Portability**: Easily adapt your application to different boards.
- **Access Standardized APIs**: Ensure consistency across your projects.

## Getting Started with ESP-BSP

### Hardware Setup

Ensure you have the following hardware:

- [ESP32-S3-BOX-3](https://github.com/espressif/esp-box) development board.
- USB-C Cable for power and programming.

### Prerequisites

Before you begin, make sure you have the following:

- [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/index.html#installation): The official development framework for the ESP32, properly installed and sourced in your shell.

### Creating Your First Project

Let’s create a simple project using the `display_audio_photo` example, which is available for the ESP32-S3-BOX-3. This example showcases how to use the display, touch, and audio features.

1. **Initialize a New Project**:

   Use the `idf.py` tool to create a new project from the example:

   ```bash
   idf.py create-project-from-example "espressif/esp-box-3^1.2.0:display_audio_photo"
   cd display_audio_photo
   ```

2. **Set the Target**:

   Ensure the correct target is set for your project:

   ```
   idf.py set-target esp32s3
   ```

3. **Build and Flash the Project**:

   Compile and flash your application to the ESP32-S3-BOX-3:

   ```
   idf.py build flash monitor
   ```

### Exploring the Example

Once the application is running, you’ll see the following features in action:

- **Display**: Shows images, text files, and more.
- **Touch**: Interacts with the display.
- **Audio**: Plays sound files.

## Conclusion

With ESP-BSP, you can quickly develop and port your applications across various ESP32 boards, saving time and effort. Whether you’re building a new project or upgrading an existing one, ESP-BSP simplifies your development process.

## Useful Links

- [Board Support Packages at Component Registry](https://components.espressif.com/components?q=Board+Support+Package)
- [ESP-BSP GitHub Repository](https://github.com/espressif/esp-bsp)
- [ESP-BSP Documentation](https://github.com/espressif/esp-bsp/blob/master/README.md)
- [ESP-BOX-3 BSP Example](https://components.espressif.com/components/espressif/esp-box-3/versions/1.2.0/examples?language=en)
- [ESP-IDF Installation Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html)
- [Wokwi - Online ESP32 Simulator](https://wokwi.com)
