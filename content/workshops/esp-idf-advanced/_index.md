---
title: "ESP-IDF Advanced Workshop"
date: "2025-08-05"
series: ["WS00B"]
series_order: 1
showAuthor: false
summary: "This workshop is about advanced features of ESP-IDF and focuses on modular development, event loops, core dumps, size analysis and flash encryption."

---

Welcome to Espressif's Advanced ESP-IDF Workshop!

## Introduction

In this hands-on workshop, you'll develop a solid understanding of the ESP-IDF framework, included modular development via components, event loops, core dumps, and security features.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Estimated time: 3 hours.
{{< /alert >}}

## Agenda

The workshop is divided into four parts. Here's the outline:

* Part 1: **Components**

  * Lecture 1 -- What is a component, how to create it, and how to support multiple hardware versions via BSPs and multi-config
  * Assignment 1.1 -- Refactor the code creating the alarm component
  * Assignment 1.2 -- Refactor the code creating the `cloud_manager` component
  * Assignment 1.3 -- Multiple configuration using `sdkconfig`

* Part 2: **Event Loops**

  * Lecture 2 -- Event loop basics in ESP-IDF, using timer events, and separation of concerns
  * Assignment 2.1 -- Refactor the code to use the event loop mechanism
  * Assignment 2.2 -- Add a gpio event to the event loop

* **Break** (15 minutes)

* Part 3: **Performance and crash analysis**

  * Lecture 3 -- Application size analysis and core dumps
  * Assignment 3.1 -- Analyze application size and suggest optimizations
  * Assignment 3.2 -- Analyze a crash using core dumps (guided)
  * Assignment 3.3 -- Analyze a crash using core dumps (optional)

* Part 4: **OTA and Security Features**

  * Lecture 4 -- OTA fundamentals, partition table configuration, secure bootloader, flash encryption
  * Assignment 4.1 -- Modify the partition table to support OTA
  * Assignment 4.2 -- Use a custom partition table
  * Assignment 4.3 -- Enable flash encryption
  <!-- * Assignment 4.4 -- Secure bootloader (optional - TBD) -->

## Prerequisites

To follow this workshop, make sure you meet the prerequisites listed below.

* Good knowledge of:

  * C programming and its linker
  * Call back functions and function pointers
  * MQTT protocol and usage

* Embedded programming

  * Flashing / Programming, linking
  * Familiarity with MCU peripherals such as GPIO and I2C
  * Basic experience with ESP-IDF
* Tools installation (VSCode + ESP-IDF extension)

> We strongly recommend installing VSCode and the ESP-IDF plugin before the workshop begins. If you run into any issues, there will be some time during the first assignment to complete the installation.


## Reference Table

| Prerequisite           | Description                                                                                         | Reference                                                                                                                       |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| MCU memory types       | Difference between Flash, RAM and EEPROM                                                            | [L. Harvie (Medium)](https://medium.com/@lanceharvieruntime/embedded-systems-memory-types-flash-vs-sram-vs-eeprom-93d0eed09086) |
| PSRAM                  | What is PSRAM                                                                                       | [M. Hawthorne (Technipages)](https://www.technipages.com/what-is-psdram-pseudo-static-ram/)                                     |
| MCU serial peripherals | Difference between SPI, I2C, UART                                                                   | [nextpcb.com](https://www.nextpcb.com/blog/spi-i2c-uart)                                                                        |
| ESP-IDF VSCode Plugin  | Espressif official VSCode Extension                                                                 | [vscode-esp-idf-extension installation](https://github.com/espressif/vscode-esp-idf-extension?tab=readme-ov-file#how-to-use)    |
| Partition table | What is partition table and why it's useful| [Wikipedia disk partitioning article](https://en.wikipedia.org/wiki/Disk_partitioning)

<!-- | YAML                   | Human-readable data serialization format used for dependency management through `idf_component.yml` | [Wikipedia](https://en.wikipedia.org/wiki/YAML), [datacamp.com](https://www.datacamp.com/blog/what-is-yaml)                     | -->


## Workshop

Without further delay, let’s get started! You’ll find links to each part of the workshop below.

The first lecture builds on the code in [`assignment_1_1_base`](https://github.com/FBEZ-docs-and-templates/devrel-advanced-workshop-code/tree/main/assignment_1_1_base).

If you’re unable to complete a particular assignment, please download its prerequisite as shown in the diagram below.

```goat
assignment_1_1_base ---> assignment_1_1 ---> assignment_1_2 -+-> assignment_1_3
                                                  |
                                                  +-> assignment_2_1 ---> assignment_2_2 ---> assignment_3_1

assignment_3_2_base --------------------------------> assignment 3_2 ---> assignment 4_1 ---> assignment 4_2
```
<br>


{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Even if you complete all assignments successfully, you’ll still need to download at least `assignment_1_1_base` and `assignment_3_2_base`.
{{< /alert >}}


> Your next step is __[Lecture 1](lecture-1/)__.

* __Part 1__
   * [Lecture 1](lecture-1/)
   * [assignment 1.1](assignment-1-1/)
   * [assignment 1.2](assignment-1-2/)
   * [assignment 1.3](assignment-1-3/)
* __Part 2__
   * [Lecture 2](lecture-2/)
   * [assignment 2.1](assignment-2-1/)
   * [assignment 2.2](assignment-2-2/)
* __Part 3__
   * [Lecture 3](lecture-3/)
   * [assignment 3.1](assignment-3-1/)
   * [assignment 3.2](assignment-3-2/)
   * [assignment 3.3](assignment-3-3/)
* __Part 4__
   * [Lecture 4](lecture-4/)
   * [assignment 4.1](assignment-4-1/)
   * [assignment 4.2](assignment-4-2/)
   * [assignment 4.3](assignment-4-3/)
   <!-- * [assignment 4.4](assignment-4-4/) -->


## Conclusion

Congratulations! You just arrived at the end of this workshop. We hope it was a fruitful experience and the start of a longer journey. Thank you for following the advanced ESP-IDF workshop.
