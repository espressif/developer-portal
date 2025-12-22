---
title: "ESP-IDF Workshop: Advanced"
date: "2025-11-12"
series: ["WS00B"]
series_order: 1
showAuthor: false
summary: "This workshop covers the advanced features of ESP-IDF and focuses on modular development, the event loop, core dumps, size analysis, and flash encryption."
---

Welcome to the advanced ESP-IDF workshop!

## Introduction

In this workshop, we’ll explore some of the more advanced aspects of the ESP-IDF framework, including modular development using components, the event loop, core dumps, and security features.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Estimated time: 3 hours.
{{< /alert >}}

## Agenda

The workshop is divided into four parts.

* Part 1: **Components**

  * [Lesson 1](lecture-1/) – What a component is, how to create one, and how to support multiple hardware versions through BSPs and multiple configurations
  * [Assignment 1.1](assignment-1-1/) – Refactor the code by creating the `alarm` component
  * [Assignment 1.2](assignment-1-2/) – Refactor the code by creating the `cloud_manager` component
  * [Assignment 1.3](assignment-1-3/) – Manage multiple configurations using `sdkconfig`

* Part 2: **Event Loop**

  * [Lesson 2](lecture-2/) – Basic information about event loops in ESP-IDF, using timer events, and separating responsibilities
  * [Assignment 2.1](assignment-2-1/) – Refactor the code to use the event loop
  * [Assignment 2.2](assignment-2-2/) – Add a GPIO event to the event loop

* Part 3: **Performance and Crash Analysis**

  * [Lesson 3](lecture-3/) – Size analysis and using core dumps for debugging
  * [Assignment 3.1](assignment-3-1/) – Analyze the application size and suggest optimizations
  * [Assignment 3.2](assignment-3-2/) – Analyze a crash using core dumps (guided)
  * [Assignment 3.3](assignment-3-3/) – Analyze a crash using core dumps (optional)

* Part 4: **OTA and Security Features**

  * [Lesson 4](lecture-4/) – Fundamentals of OTA, partition table configuration, secure bootloader, and flash encryption
  * [Assignment 4.1](assignment-4-1/) – Modify the partition table to support OTA
  * [Assignment 4.2](assignment-4-2/) – Use a custom partition table
  * [Assignment 4.3](assignment-4-3/) – Enable flash encryption

## Prerequisites

To follow this workshop, make sure you meet the prerequisites listed below.

### Required Software

* **VS Code** installed on your computer
* **[ESP-IDF extension for VS Code](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/)** added to VS Code
* **ESP-IDF** installed on your machine<br>
  *It can be installed via VS Code or by using the [ESP-IDF Installer Manager](https://docs.espressif.com/projects/idf-im-cli/en/latest/index.html)*

### Required Hardware

* ESP-C3-DevKit-RUST-1 or ESP-C3-DevKit-RUST-2 board (if the activity is in person, the board will be provided during the workshop)<br>
  *It is also possible to use an ESP32-C3-DevKit-M/C board, but you will need to adjust the GPIO configuration accordingly.*

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
If the event is held in person, it is strongly recommended to install **VS Code** and the **ESP-IDF plugin** **before** the start of the workshop.
If you encounter any issues, there will still be a short time during the first exercise to complete the installation.
{{< /alert >}}

### Basic Knowledge

* Good understanding of:
  * C programming and the linker
  * Callback functions and function pointers
  * MQTT protocol and its use
* Embedded programming
  * Flashing / Programming, linking
  * Familiarity with MCU peripherals such as GPIO and I2C
  * Basic experience with ESP-IDF
* Tool installation (VS Code + ESP-IDF extension)

> It is strongly recommended to install VS Code and the ESP-IDF plugin before the workshop begins. However, if you encounter any problems, there will be time during the first exercise to complete the setup.

## Next Step

The first lesson is based on the code in [`assignment_1_1_base`](https://github.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-idf-advanced/assignment_1_1_base).

If you are unable to complete an exercise during the session, you can continue by downloading the appropriate solution according to the following structure:

```goat
assignment_1_1_base ---> assignment_1_1 ---> assignment_1_2 -+-> assignment_1_3
                                                  |
                                                  +-> assignment_2_1 ---> assignment_2_2 ---> assignment_3_1

assignment_3_2_base --------------------------------> assignment_3_2 ---> assignment_4_1 ---> assignment_4_2
```

<br>

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Even if you successfully complete all exercises, you will still need to download at least `assignment_1_1_base` and `assignment_3_2_base`.
{{< /alert >}}

> Your next step is **[Lesson 1](lecture-1/)**.

## Conclusion

Congratulations! You have reached the end of this workshop.
We hope it has been a valuable experience and the start of a longer learning journey.
Thank you for participating in the advanced ESP-IDF workshop.
