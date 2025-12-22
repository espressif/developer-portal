---
title: "ESP-IDF Workshop: Basic"
date: "2025-11-12"
lastmod: "2026-01-20"
summary: "This workshop explores the basics of the ESP-IDF. You will build and flash basic programs, create your own components and build a REST API HTTP server."
---

Welcome to the basic ESP-IDF workshop!

## Introduction

In this workshop, you will gain a solid understanding of the ESP-IDF framework, learning how to effectively use Visual Studio Code (VS Code) and Espressif’s official ESP-IDF extension for VS Code.

The workshop is divided into three parts. In the first part, we’ll verify that your development environment is properly set up by using the classic *hello world* example as a starting point. In the second part, we’ll dive into the network stack and build a simple HTTP server together. The third part will focus on two very common peripherals: GPIO and I2C.

We’ll also explore the component system and the [component registry](https://components.espressif.com/), which allows you to use libraries without manually managing dependencies or build system settings.

As a final exercise, we’ll combine everything to create a simple sensor gateway, integrating connectivity and peripheral control into a single project.

By the end of the workshop, you’ll have the basic skills needed to start developing your own applications based on ESP-IDF.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Estimated duration: 3 hours.
{{< /alert >}}

## Agenda

The workshop is divided into three parts, each lasting for about one hour.

* **Part 1**: Welcome and introduction

  * [Lesson 1](lecture-1/) – Introduction to ESP-IDF and the ESP-IDF extension for VS Code.
  * [Assignment 1.1](assignment-1-1/) – Verify your ESP-IDF and VS Code installation by compiling and flashing the *hello_world* example. Modify the example’s output text.
  * [Assignment 1.2](assignment-1-2/) – Create a new project starting from the *blink* example

* **Part 2**: HTTP Connectivity

  * [Lesson 2](lecture-2/) – Connectivity: HTTP protocol, HTML, and REST APIs
  * [Assignment 2.1](assignment-2-1/) – Create an HTTP server that handles the GET request `/index.html/` and returns `<h1>Hello LED Control</h1>`
  * [Assignment 2.2](assignment-2-2/) – Add the following routes to the HTTP server:

    * GET /led/on → turns on the LED and returns the JSON `{"led": "on"}`
    * GET /led/off → turns off the LED and returns the JSON `{"led": "off"}`
    * POST /led/blink → accepts a JSON `{ "times": int, "interval_ms": int }` and makes the LED blink the specified number of times at the given interval
  * [Assignment 2.3](assignment-2-3/) – *(Optional)* Add the following route:

    * POST /led/flash → accepts the JSON `{"periods": [int], "duty_cycles": [int]}` and, for each element, calculates on/off durations to drive the LED accordingly

* **Part 3**: Peripherals and Integration

  * [Lesson 3](lecture-3/) – GPIO, I2C, and the component registry
  * [Assignment 3.1](assignment-3-1/) – Create a new component to control the LED
  * [Assignment 3.2](assignment-3-2/) – Add a component to read the onboard environmental sensor
  * [Assignment 3.3](assignment-3-3/) – *(Optional)* Add the route:

    * GET /environment/ → returns the sensor reading. Choose the most appropriate JSON format to represent the data.

## Prerequisites

To follow this workshop, make sure you meet the prerequisites listed below.

### Required Software

* **VS Code** installed on your computer (v1.108+)
* **[ESP-IDF extension for VS Code](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/)** added to VS Code (v1.11+)
* **ESP-IDF** installed on your machine (v5.5+)
  *It can be installed via VS Code or by using the [ESP-IDF Installation Manager](https://docs.espressif.com/projects/idf-im-cli/en/latest/index.html)*

### Required Hardware

* [ESP-C3-DevKit-RUST-1](https://github.com/esp-rs/esp-rust-board) or [ESP-C3-DevKit-RUST-2](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c3/esp32-c3-devkit-rust-2/user_guide.html) board<br>
  (if the activity is in person, the board will be provided during the workshop)<br>
  *It’s also possible to use an ESP32-C3-DevKit-M/C board, but you’ll need to adapt the GPIO configuration accordingly.*

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
If the event is held in person, please complete the following __before__ the workshop:
* Install **VS Code** 
* Install **ESP-IDF externsion for VS COde**

If any issues arise, there will be a short window during the first exercise to complete the installation.
{{< /alert >}}

### Basic Knowledge

* Basic electronics
  * Resistors, capacitors, DC/DC power supplies
  * Reading an electrical schematic
* Basic embedded programming
  * Flash memory
  * Difference between compiling and flashing firmware
  * Understanding of common microcontroller peripherals (mainly GPIO and I2C)
* Basic C language knowledge
  * Header files
  * Compiler/linker concepts
  * Use of define, struct, and typedef
* [JSON](https://en.wikipedia.org/wiki/JSON) and [YAML](https://en.wikipedia.org/wiki/YAML) data formats
* HTML and its main tags (`<html>`, `<body>`, `<h1>`, `<h2>`, `<p>`)
* Basic understanding of HTTP request methods (GET, POST) and the concept of URI and *routes*

## Next Step

> The next step is **[Lesson 1](lecture-1/)**.

## Conclusion

Congratulations! You’ve reached the end of this workshop.
We hope it has been a valuable experience and the beginning of a deeper journey into Espressif’s tools.

You are now able to create, compile, and flash new projects, use external libraries and components, create your own components, and control everything through an HTTP interface.

You’ve therefore acquired the fundamental skills to develop an **IoT** application.
