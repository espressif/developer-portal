---
title: "Introducing ESP LowCode Matter: Simplified Device Development"
date: 2025-02-27
showAuthor: false
authors:
  - chirag-atal
  - amey-inamdar
  - kedar-sovani
tags:
  - Low Code
  - Matter
  - Espressif
  - ESP32
---

At Espressif Systems, we are continuously striving to make device development easier for device makers. For Matter devices, we [launched](https://developer.espressif.com/blog/announcing-esp-zerocode/) the [ESP ZeroCode](https://zerocode.espressif.com/) solution, simplifying the device development by removing the software development efforts. Allowing product customizations to a limited extent, ESP ZeroCode is well-suited for those who want to launch connected products without having to build them from scratch using the [ESP Matter](https://github.com/espressif/esp-matter) or the [Connectedhomeip (CHIP)](https://github.com/project-chip/connectedhomeip) SDK.

Today, we announce our [ESP LowCode Matter](https://github.com/espressif/esp-lowcode-matter) solution that achieves the best of both worlds by continuing to retain simplicity of ESP ZeroCode and providing the ability to customize, with ease, the typical parts of an application.

{{< figure
    default=true
    src="img/esp-lowcode-flexibility-simplicity.webp"
    >}}

## What is ESP LowCode Matter?

ESP LowCode Matter is a solution that splits firmware into two parts for a single chip:

- **System Firmware**: Developed and maintained by Espressif, it wraps the complexity of the Matter protocol, OTA upgrades, and security management.
- **Application Firmware**: Developed by a device maker, it implements hardware interfacing, hardware communication protocols and other business and device logic.

{{< figure
    default=true
    src="img/esp-lowcode-firmware-split.webp"
    caption="[Zoom Image](img/esp-lowcode-firmware-split.webp)"
    >}}

ESP LowCode Matter is a culmination of learnings and efforts along multiple dimensions to ensure that the development experience is truly great. Let's look at some of the key advantages of this solution.

### Simplified Development

ESP LowCode Matter makes the application code development intuitive, easy to understand and customize. It provides the simplicity and the flexibility to create any device with all the features of Matter (even custom ones), while isolating all the system level complexities from the application developer.

* The generated application firmware is quite small, making the **build-flash-debug** cycle extremely fast
* Development is exposed through a simplified **setup-loop style** of programming

One of the goals is to incorporate the production scenarios in the development workflow itself, with the following Matter specific features:

* **Unique QR code** generation and flashing
* **Unique DAC certificate** generation and flashing

For development, the devices get a test DAC certificate. But for production, with Espressif's Matter manufacturing service, the modules will be pre-programmed with the production certificates.

### Simplified Maintenance

**Espressif maintains the System Firmware**. The complexities of the Matter protocol, OTA upgrades, and security management are all happening internally. This isolates device makers from individually incorporating security fixes and other bug fixes that are provided in other base SDKs, such as ESP-IDF, ESP Matter, CHIP. This in turn helps to maintain the best security for in-field devices.

It leaves the application developer to focus on:

* Driver interfacing
* Event and state indication
* User interaction

This is something that the device makers always wanted: the ability to write, create, and modify just the part that affects them and the end user, without having to deal with the complexities of what is happening internally. With that out of the way, the device makers can focus on the above three areas, in which they already have vast experience.

Device makers can modify the data model as per their device and application requirements. This Matter data model is interpreted by the system firmware but it is still outside the system firmware like a pluggable component.

### Simplified Certification

The ESP LowCode Matter system firmware undergoes regular and rigorous testing to meet the high quality bar that we have set for ourselves. This ensures that the various certifications and the tests required by them are done efficiently and smoothly.

* **Matter Certification**
  * ESP LowCode Matter products need to undergo full certification and testing. But, the Matter functionality is largely handled by Espressif in the system firmware itself, which ensures Matter compatibility. Additionally, Espressif will assist manufacturers in certifying their products and keeping the certification up to date in the most efficient manner.
  * You can use this badge on your product packaging and marketing materials once the product is certified.

  {{< figure
      default=true
      src="img/esp-lowcode-matter-badge.webp"
      width="60%"
      >}}

* **Product Security Certification**
  * The Product Security Certification from [CSA](https://csa-iot.org) (Connectivity Standards Alliance) is recommended for all devices. All the security measures are already in place and taken care of in ESP LowCode Matter.
  * You can use this badge on your product packaging and marketing materials once the product is certified.

  {{< figure
      default=true
      src="img/esp-lowcode-product-security-badge.webp"
      width="60%"
      >}}

* **"Works with" Badges and programs by various other Ecosystems**
  * Similar to ESP ZeroCode, with ESP LowCode Matter, you can easily get certified for various other ecosystems, and get the "Works with" badges.
  * Espressif is closely working with the Ecosystem providers to get the best experience for the device makers and the end users.

### Everything in the browser

We have built VS Code IDE plugins for ESP LowCode Matter, and integrated those with GitHub Codespaces. This provides a first-class development experience from the browser itself. It integrates the entire development workflow within the VS Code IDE loaded in your browser. No need to install any additional software on the development host. All development operations, edit, build, flash, and monitoring the console are available through the browser, in the familiar VS Code interface.

You can simply connect the device to your own laptop and access it through the browser.

{{< figure
    default=true
    src="img/esp-lowcode-codespaces.webp"
    alt="ESP LowCode Codespaces"
    caption="[Zoom Image](img/esp-lowcode-codespaces.webp)"
    link="img/esp-lowcode-codespaces.webp"
    >}}

Instead of using the browser-based IDE, you can also use your local VS Code IDE or your preferred editors. These workflows are also fully supported.

## First SoC: ESP32-C6

The [ESP32-C6](https://www.espressif.com/en/products/socs/esp32-c6) is the first SoC that is supported by ESP LowCode Matter. It is a 32-bit dual-core SoC with a High-Performance Core and a Low-Power Core. It is a great fit for the Matter protocol and the ESP LowCode Matter solution.

For ESP32-C6, ESP LowCode Matter completely **partitions CPU and memory** across system and application firmware. The High-Performance Core (and its associated memory) is dedicated to the system firmware while the Low-Power Core (and its associated memory) is dedicated to the application firmware. This split ensures that the application firmware is compartmentalized, and a developer doesn't have to deal with the complexities of the system firmware.

The application firmware is a **single-threaded** application that runs on the Low Power Core without an OS.

{{< figure
    default=true
    src="img/esp-lowcode-hp-lp.webp"
    >}}

This provides multiple benefits:

* Development and debugging are contained, hence much simpler, as opposed to a fully multi-threaded FreeRTOS/IDF application.
* The partitioned memory ensures that the application firmware is stable and doesn't affect the system firmware.
* The firmware is ~20KB for a typical application, making this a very small footprint.
* Simplified HAL drivers (RTOS independent low-level peripheral drivers) help to directly interface with the hardware peripherals.

The ESP LowCode Matter platform uses the [ESP-AMP](https://github.com/espressif/esp-amp) project for facilitating this partitioning. You may read more about ESP-AMP [here](https://github.com/espressif/esp-amp).

## Try

Try ESP LowCode Matter today by following the [README](https://github.com/espressif/esp-lowcode-matter).

ESP LowCode Matter represents a significant step forward in making Matter device development more accessible. Whether you're building smart plugs, lights, appliances or custom Matter devices, ESP LowCode Matter provides the tools and simplicity you need to bring your ideas to life and launch products faster.

Let us know what you think by joining the [discussions](https://github.com/espressif/esp-lowcode-matter/discussions) and becoming a part of the growing ESP LowCode Matter community.

**Disclaimer:** All trademarks and copyrights are property of their respective owners.
