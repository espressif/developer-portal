---
title: "ESP-IDF Basics: Your First Project with ESP32-C3 and Components"
date: "2025-08-05"
summary: "This workshop explores the basics of the ESP-IDF. You will build and flash basic programs, create your own components and build a REST API HTTP server."
---

Welcome to Espressif's ESP-IDF Basics Workshop!

## Introduction

In this hands-on workshop, you'll develop a solid understanding of the ESP-IDF framework, along with how to effectively use Visual Studio Code (VSCode) and Espressif’s official VSCode Extension. You'll also gain practical experience working with ESP-IDF components.

In the first part, we’ll begin by verifying that your development environment is correctly set up, using the classic `hello world` example as our starting point. From there, we'll walk through the structure of an ESP-IDF project, explore the build system, and set up a basic access point (__SoftAP__).

As we move to the second part, we’ll take a closer look at the network stack protocol and guide you through building a simple __HTTP server__.

The third part focuses on working with two commonly used peripherals, namely __GPIO__ and __I2C__. We will explore the component system and the component registry, for using common libraries without worrying about managing dependencies or build system settings. After that, we’ll bring everything together to build a basic sensor gateway, combining networking and peripheral control into one cohesive project.

By the end of this session, you’ll have the foundational skills and confidence to start developing your own Espressif-based applications using ESP-IDF.


{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Estimated time: 3 hours.
{{< /alert >}}


## Agenda

The workshop is divided into three parts, each lasting approximately one hour. Here's the outline:

- Part 1: __Welcome and getting started__
  - __Lecture 1__ -- ESP-IDF & VSCode Extension introduction
  - __Assignment 1.1__ -- Test ESP-IDF and VSCode installation by compiling and flashing the `hello_world` example. Change the text of the example and check on the terminal.
  - __Assignment 1.2__ -- Start a new project from the `blink` example and check that the LED on the board is flashing.

- Part 2: __HTTP connectivity__
  - __Lecture 2__ -- Connectivity layers, HTTP and MQTT, HTML, REST API
  - __Assignment 2.1__ -- Create an HTTP server which processes the request `GET /index.html/` and returns `<h1>Hello LED Control</h1>`.
  - __Assignment 2.2__ -- Add to the HTTP server the routes
       - `GET /led/on` &rarr; turns the LED on and returns JSON {"led": "on"}
       - `GET /led/off`&rarr; turns the LED off and returns JSON {"led": "off"}
       - `POST /led/blink` &rarr; accepts JSON `{ "times": int, "interval_ms": int }` to blink the LED the specified number of times at the given interval, and returns JSON `{"blink": "done"}`
  - __Assignment 2.3__ -- (Optional) Add to the HTTP server the route
       - `POST /led/flash` &rarr; accepts JSON `{"periods": [int], "duty_cycles": [int]}` and for each element, calculates the on-time and off-time and drives the LED accordingly.

- Part 3: __Peripherals and putting it all together__
   - __Lecture 3__ -- GPIO, I2C and use of component registry. Reading the sensor.
   - __Assignment 3.1__ -- Create a new component to toggle the LED.
   - __Assignment 3.2__ -- Refactor previous code to use the component.
   - __Assignment 3.3__ -- Add component for reading the environment sensor onboard.
   - __Assignment 3.4__ -- (Optional) Add route:
        - `GET /environment/` &rarr;  returns a sensor reading. Choose the best json format for this task.


## Prerequisites

To follow this workshop, make sure you meet the prerequisites given below.

### Basic knowledge

* Basic electronics
   * Resistors, capacitors, dc/dc supply
   * Reading a schematic
* Basic embedded programming
   * Flash memory
   * Compile vs flash
   * Basic knowledge of standard MCU peripherals, at least GPIO, and I2C.
* C programming language basics
   * header files
   * compiler / linker
   * `define`s
   * `struct`s and `typedef`s
* [JSON](https://en.wikipedia.org/wiki/JSON) and [YAML](https://en.wikipedia.org/wiki/YAML) format
* HTML and its main tags (`<html>`, `<body>`, `<h1>`, `<h2>`, `<p>`)
* Basic knowledge of HTTP request methods (`GET`, `POST`) and the concept of URI and routes
* Reference materials (distributed prior to workshop)

### Required software

* VSCode installed on your machine
* [ESP-IDF extension](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/installation.html) added to your VSCode.
* ESP-IDF installed on your machine<br>
   _You can install it via VSCode or using [ESP-IDF installer manager](https://docs.espressif.com/projects/idf-im-cli/en/latest/index.html)_

### Required hardware

* The ESP-C3-DevKit-RUST-2 (it will be provided at the workshop). <br>
   _You could also use an ESP32-C3-Devkit board, but you would need to adjust gpio pin accordingly_

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
We strongly recommend installing VSCode and the ESP-IDF plugin __before__ the workshop begins. If you run into any issues, there will be some time during the first assignment to complete the installation.
{{< /alert >}}


#### Reference table

| Prerequisite | Description | Reference |
|---|---|---|
|MCU memory types|Difference between Flash, RAM and EEPROM|[L. Harvie (Medium)](https://medium.com/@lanceharvieruntime/embedded-systems-memory-types-flash-vs-sram-vs-eeprom-93d0eed09086)|
|MCU serial peripherals|Difference between SPI, I2C, UART|[nextpcb.com](https://www.nextpcb.com/blog/spi-i2c-uart)|
|Header files and linker|What are headers file for and what's the linker's job|[CBootCamp](https://gribblelab.org/teaching/CBootCamp/12_Compiling_linking_Makefile_header_files.html), [themewaves](https://themewaves.com/understanding-linkers-in-c-programming/)|
|JSON|Language-independent data format derived from JavaScript. Backbone of REST APIs|[Wikipedia](https://en.wikipedia.org/wiki/JSON)|
|YAML|Human readable data serialization format used for dependency management through `idf_component.yml`|[Wikipedia](https://en.wikipedia.org/wiki/YAML), [datacamp.com](https://www.datacamp.com/blog/what-is-yaml)|
|HTML tags|Basic HTML tags introduction|[Freecodecamp](https://www.freecodecamp.org/news/introduction-to-html-basics/)|
|HTTP Request method|HTTP request (GET, POST, etc.) introduction and differences|[Restfulapi.net](https://restfulapi.net/http-methods/)|
|ESP-IDF VSCode Plugin|Espressif official VSCode Extension|[vscode-esp-idf-extension installation](https://github.com/espressif/vscode-esp-idf-extension?tab=readme-ov-file#how-to-use)|


## Workshop

Without further ado, let's start! You can find a link to each workshop part below. Your next step is __[Lecture 1](lecture-1/)__.

* __Part 1__
   * [Lecture 1](lecture-1/)
   * [Assignment 1.1](assignment-1-1/)
   * [Assignment 1.2](assignment-1-2/)
* __Part 2__
   * [Lecture 2](lecture-2/)
   * [Assignment 2.1](assignment-2-1/)
   * [Assignment 2.2](assignment-2-2/)
   * [Assignment 2.3](assignment-2-3/) (Optional)
* __Part 3__
   * [Lecture 3](lecture-3/)
   * [Assignment 3.1](assignment-3-1/)
   * [Assignment 3.2](assignment-3-2/)
   * [Assignment 3.3](assignment-3-3/)


## Conclusion

Congratulations! You just arrived at the end of this workshop. We hope it was a fruitful experience and the start of a longer journey. Thank you for participating in Espressif's 2025 Brazilian Summit workshop!

You are now able to create, build and flash new projects, use external libraries and components, create your own components, and control everything via an HTTP interface. You have now the basic foundation for an IoT application.

We hope this workshop has provided you with the foundational knowledge and confidence to start building your own Espressif-based applications. Keep experimenting, keep learning—and don't forget to explore the rich ecosystem of tools and resources that Espressif offers.
