---
title: "ESP-IDF Workshop: ESP32-C5"
date: "2026-07-29"
lastmod: "2026-07-29"
featureAsset: "img/featured/featured-esp-idf-chip-workshop.webp"
series: ["WS00C"]
series_order: 1
showAuthor: false
summary: "This workshop covers Wi-Fi 5 connectivity, partition tables, OTA updates, and the Extra ULP coprocessor on the ESP32-C5."
---

Welcome to the ESP32-C5 ESP-IDF workshop!

## Introduction

In this workshop, you will get hands-on experience with the `ESP32-C5`, Espressif's first SoC to support dual-band Wi-Fi 6, and learn how to put its new features to work in a real application.

The workshop is divided into four parts.

In the first part, we'll connect to a Wi-Fi access point on the 5 GHz band and see how dual-band support improves throughput and reduces interference compared to the more crowded 2.4 GHz band.

In the second part, we'll look at partition tables and how they let you organize the SoC's flash memory into independent regions for your application, filesystem, and OTA data.

Building on that, the third part covers Over-The-Air (OTA) updates, so you can update your firmware remotely without a physical connection to the board.

The fourth part introduces the low-power modes and the ULP, a low-power RISC-V coprocessor that can handle simple tasks on its own while the main CPU stays in deep sleep, helping you save power in battery-operated designs.

By the end of the workshop, you will be able to build an application that connects over Wi-Fi 6, manages its own partitions, updates itself remotely through OTA, and offloads background work to the Extra ULP coprocessor.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Estimated duration: 3 hours.
{{< /alert >}}


## Prerequisites

To follow this workshop, make sure you meet the prerequisites listed below.

### Required Software

* **VS Code** installed on your computer (v1.108+)
* **[ESP-IDF extension for VS Code](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/)** added to VS Code (v1.11+)
* **ESP-IDF** installed on your machine (__>v5.5,<6__)
  *It can be installed via VS Code or by using the [ESP-IDF Installation Manager](https://docs.espressif.com/projects/idf-im-ui/en/latest/index.html)*


To install everything, you can follow the [ESP-IDF Setup guide](/workshops/esp-idf-setup/).

### Required Hardware

* An [`ESP32-C5-DevKitC-1`](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c5/esp32-c5-devkitc-1/index.html) development board. <br>
  *If the activity is in person, the board will be provided during the workshop.*


### About the ESP32-C5-DevKitC-1

The `ESP32-C5-DevKitC-1` is an entry-level development board built around the `ESP32-C5-WROOM-1` module. It breaks out most of the SoC's GPIO pins to headers on both sides of the board, so you can easily connect it to a breadboard or to peripherals using jumper wires.

The board includes a USB Type-C to UART port, used both to power the board and to flash and monitor your application, and a second, dedicated USB Type-C port wired directly to the SoC for native USB communication and JTAG debugging.

#### ESP32-C5 SoC Main Characteristics

The `ESP32-C5` is the SoC at the heart of this development board. Its main characteristics are:

* __CPU__: 32-bit single-core RISC-V processor, clocked up to 240 MHz, plus a low-power (LP) RISC-V core for always-on tasks.
* __Memory__: 384 KB of on-chip HP SRAM, 16 KB of LP SRAM, and 320 KB of ROM, with support for external flash and PSRAM.
* __Wireless connectivity__:
  * Dual-band Wi-Fi 6 (802.11ax), supporting both 2.4 GHz and 5 GHz, with backward compatibility for 802.11a/b/g/n/ac.
  * Bluetooth 5 (LE), including Bluetooth mesh.
  * IEEE 802.15.4, used by the Thread and Zigbee protocols.
* __GPIOs__: up to 29 programmable GPIOs, supporting common peripherals such as SPI, I2C, I2S, UART, ADC, and CAN FD.
* __Security features__: secure boot, flash and PSRAM encryption, cryptographic hardware accelerators, and Physical Memory Protection (PMP).

You will explore the Wi-Fi 6 dual-band capabilities of the `ESP32-C5` in more detail in [Lecture 1](lecture-1/).


## Agenda

The workshop is divided into four parts.

* Part 1: **Connect to Wi-Fi 5**

  * [Lecture 1](lecture-1/) – The ESP32-C5's dual-band Wi-Fi 6 radio and how to select the 2.4 GHz or 5 GHz band with `esp_wifi_set_band_mode()`
  * [Assignment 1.1](assignment-1-1/) – Connect the ESP32-C5 DevKit to a 5 GHz Wi-Fi network
  * [Assignment 1.2](assignment-1-2/) – Modify the station so the ESP32-C5 chooses the Wi-Fi band automatically, connecting on 5 GHz when available and falling back to 2.4 GHz otherwise

* Part 2: **Partition Table**

  * [Lecture 2](lecture-2/) – The ESP-IDF partition table, its typical entries, and how to select a built-in scheme through `menuconfig`
  * [Assignment 2.1](assignment-2-1/) – Read the current partition table and switch to a scheme with two OTA app partitions
  * [Assignment 2.2](assignment-2-2/) – Build a custom partition table that adds a `spiffs` filesystem partition, then flash and verify it

* Part 3: **OTA**

  * [Lecture 3](lecture-3/) – How Over-The-Air updates work on Espressif devices using the `app_update` and `esp_https_ota` components
  * [Assignment 3.1](assignment-3-1/) – Configure the partition table for OTA and perform a single OTA update by downloading new firmware from a fixed URL with `esp_https_ota`
  * [Assignment 3.2](assignment-3-2/) – (Optional) Add app rollback support, so a broken firmware update is automatically reverted to the last working version
  * [Assignment 3.3](assignment-3-3/) – Check a remote version file before updating, so the device only downloads new firmware when it is actually newer

* Part 4: **Extra ULP**

  * [Lecture 4](lecture-4/) – The ESP32-C5's sleep modes and the Ultra Low Power (ULP) LP core coprocessor
  * [Assignment 4.1](assignment-4-1/) – Build a Deep-sleep example that wakes on the RTC timer and keeps a boot counter in RTC memory
  * [Assignment 4.2](assignment-4-2/) – Run a program on the LP core that counts while the main CPU sleeps and wakes it at a threshold




## Next Step

> The next step is **[Lecture 1](lecture-1/)**.

## Conclusion

Throughout this workshop, you worked hands-on with the key features that make the `ESP32-C5` stand out. You connected the board to a 5 GHz Wi-Fi 6 network, organized its flash memory with custom partition tables, updated its firmware remotely through OTA, and offloaded background work to the Extra ULP coprocessor while the main CPU stayed in Deep-sleep. With these building blocks, you are ready to design applications that are connected, updatable, and power-efficient.
