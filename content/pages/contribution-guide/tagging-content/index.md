---
title: "Tagging content"
date: 2026-01-13
tags: ["Contribute"]
showTableOfContents: true
showAuthor: false
authors:
  - "kirill-chalov"
---

This article is split into the following parts:

- **Guidelines for assigning tags** -- gives you some background information
- **Assign tags** -- instructs you on how to assign tags
- **Recommended tags** -- gives you a list of tags to choose from


## Guidelines for assigning tags

In this section, you will find the following guidelines:

- [Choosing tags](#choosing-tags)
- [Spelling tags](#spelling-tags)

Once you familiarize yourself with these guidelines, go to [Assign tags](#assign-tags).

### Choosing tags

- **Carefully choose tags** and make sure they give a rough idea of **who the article is for** and **what it is about**.
  If the current tagging system does not cover important aspects, please share your feedback.
- To **avoid unnecessary specificity**, prefer broader taxonomy terms, or omit tags entirely, when the content applies across multiple items in the same classification:
  - For content applicable to both `Zephyr` and `NuttX`, consider using the broader tag `RTOS`.
  - Do not add a specific SoC tag, such as `ESP32`, to content applicable to `ESP32-C3` or other Espressif SoCs.
- To avoid **overly granular tagging**, use only widely known hardware and software product names as tags. For lesser known hardware or software, use higher-level taxonomy terms instead:
  - :x: (`ESP32-C3-DevKit-RUST-1` &rarr; :white_check_mark: `DevKit`
  - :x: `Esp-Audio-Effects` &rarr; :white_check_mark: `ESP-IDF component`
  - If a higher-level term is too broad and multiple articles fit a more specific tag, feel free to introduce such a tag (for example, use `face recognition` instead of the broader `machine vision`).

### Spelling tags

- Use lower case letters.<br>
  **Exceptions**: Capitalize proper nouns and established terms, such as:
  - Product names: `ESP32-P4`, `ESP-IDF`, `NuttX`
  - Terms, protocols, and features: `SoC`, `Ethernet`, `WebRTC`
  - Abbreviations: `IDE`, `LED`, `LLVM`
- Use tags in singular.<br>
  **Exceptions**: Singular (uncountable) words that end in `s`:
  - Mass nouns: `graphics`, `robotics`
  - Established terms: `ESP Insights`, `DevOps`
- Use spaces to separate words.<br>
  **Exceptions**: Use hyphens only in established terms:
  - Compound terms: `ESP32-C3`, `esp-idf-kconfig`, `Wi-Fi`


## Assign tags

Take the following steps:

- From the tag categories listed below, choose around **four to six** tags that apply to your content. The recommended tags are marked in `monospace`, the rest is taxonomy words and notes to assist in choosing tags.
- In your article's YAML frontmatter, add these tags as follows:
  ```sh
  tags:
    - tag1
    - tag2
    - ...
  ```

The tag categories below refer to the respective sections in [Recommended tags](#recommended-tags).

<!-- no toc -->
- [Hardware type / Software framework / OS / IDE](#hardware-type--software-framework--os--ide)
- [Complexity](#complexity) (mostly for learning materials)
- [Content type](#content-type)
- [Community involvement](#community-involvement)
- [Additional hardware information](#additional-hardware-information)
- [Additional software information](#additional-software-information)
- [Security](#security)
- [Application domains](#application-domains)
- [Industry keywords](#industry-keywords)
- [Third-party products and titles](#third-party-products-and-titles)
- [Other](#other)


## Recommended tags

### Hardware type / Software framework / OS / IDE

- hardware type
  - SoC
  - module
  - `DevKit` -- use for Espressif boards
  - `development board` -- use for 3rd party boards
  - `M5Stack`
  - BSP
- software framework
  - `ESP-IDF`
  - `ESP RainMaker`
  - `ESP-ADF`
  - `Arduino`
- OS
  - `bare metal`
  - `Linux` (POSIX?)
  - `Windows`
  - `RTOS`
    - `FreeRTOS`
    - `NuttX`
    - `Zephyr`
- `IDE`
  - `Espressif-IDE`
  - `ESP-IDF Extension for VS Code`

### Complexity

- `beginner` -- assumes no prior domain knowledge
- `practitioner` -- assumes familiarity with core concepts
- `expert` -- assumes strong domain knowledge

### Content type

- `new product` (NPI))
- `announcement` (news, newsletter)
- `release` (software releases)
- `overview`
- `how-to`
- `tutorial`
- `workshop`
- roadmap
- benchmarks / performance
- product development
- DIY project
- debugging

### Community involvement

- `community software` -- overview of community software for Espressif products
- `community hardware` -- overview of community hardware based on Espressif products
- `community contribution` -- contribution from outside Espressif
- `community event` -- announcement or overview of a community event

### Additional hardware information

- Hardware peripheral
  - `display`: `LCD`, `MIPI-CSI`
  - communication bus: `I2C`, `SPI`, `USB`, `Ethernet`, `CAN`
  - debug interface: `JTAG`, `UART`
  - `ADC`
  - `camera`
  - `LED`
  - `motor`
  - `IMU`
  - `PIE`
- Hardware concept
  - CPU architecture: `RISC-V`, `Xtensa`
  - `driver`
  - `memory` (PSRAM, flash)
  - `low power` (power efficiency, low power core, deep sleep)
  - `memory management`
  - `bootloader`
  - `MCUboot`

### Additional software information

- Programming language
  - `Assembly`
  - `Python`
  - `MicroPython`
  - `Lua`
  - `Rust`
  - `Swift`
  - `C`
  - `C++`
- ESP-IDF tool or part
  - `build system`
  - `ESP-IDF component`
  - `ESP-IDF tool`
  - `idf.py`
  - `esp-idf-kconfig`
  - `EIM`
  - `esptool`
  - `sdkconfig`
- Communication protocol (Wireless)
  - `Wi-Fi` (Wi-Fi 6?)
  - `Bluetooth`
  - `BLE`
  - `BLE Mesh`
  - `MQTT`
  - `Matter`
  - `Thread`
  - `ESP-NOW`
  - `Zigbee`
  - `WebRTC`
- `Compiling`
  - `GCC`
  - `CMake`
  - `LLVM`
  - `partition table`
  - `cross-compilation`
- Software concepts
  - `simulation`
    - `QEMU`
    - `Wokwi`
  - `graphics`
  - `GUI`
    - `Qt`
    - `lvgl`
  - `HTTP server`
  - `porting`
  - `library` -- use for 3rd party libraries
  - `zero-code`
  - `low-code`
  - `CLI`
  - `multimedia processing` (multimedia)
    - `video processing` (H.264, H.265, motion detection)
    - `image processing` (JPEG)
    - `audio processing` (speech recognition, voice assistant)

### Security

- `Secure Boot`
- `Flash Encryption`
- `ESP-TEE`
- `NVS encryption`
- `ESP Privilege Separation`

### Application domains

- `IoT`
- `smart home`
- `industrial automation`
- `wearables`
- `smart agriculture`
- `programming`
- `robotics`
- `machine vision`
- `audio`

### Industry keywords

- `HMI`
- `deep learning`
- `AI`
- `LLM`
- `MCP`
- `edge computing` (neural networks)
- `AIoT`

### Third-party products and titles

- `OpenOCD`
- `ChatGPT`
- `GitHub CoPilot`
- `KiCad`
- `CLion`
- `Jupyter Notebooks` (Jupyter)
- `WLED`
- `Eclipse`
- `VS Code`
- `Alexa`
- `Home Assistant`

### Other

- `infrastructure`
  - `CI/CD`
  - `embedded DevOps`
  - `API`
  - `Cloud`
  - `phone app`
  - `OTA`
- Artifact
  - `book`
  - `example code`
  - `reference design`
- `Event`
  - `DevCon`
- `Documentation`
  - `datasheet`
  - `TRM`
  - `ESP Insights`
