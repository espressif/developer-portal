---
title: "Espressif part numbers explained: A complete guide - Modules"
date: 2025-03-19
showAuthor: false
authors:
  - francesco-bez 
tags: ["ESP32", "ESP32-S2", "ESP32-S3", "ESP32-H2", "ESP32-C3"]
---

> This article clarifies Espressif's SoC series, module types, memory options, antenna versions, and versioning.. It also explains why modules like WROOM and MINI are among Espressif's most popular products. After reading the article, developers should be able to confidently select the right hardware for their projects.

Espressif offers a wide range of Systems-on-Chip (SoCs) and modules, continually expanding its product lineup with new offerings while refining existing ones with each revision. However, keeping up with these changes and understanding the naming conventions can be challenging, particularly for newcomers to Espressif's ecosystem.

This guide aims to simplify the process by breaking down the part numbers of Espressif modules into their key components and explaining how they correspond to module specifications. We will briefly cover the SoC series, module types, memory options, and versioning, to help you make informed decisions when selecting the right hardware for your project.

Let's start by briefly going through what the terms *SoC* and *module* mean:

- **SoC** is a chip containing integrated circuits, usually in a small package (QFN).
- **Module** is a solution integrated in a single package that includes an SoC along with passive components typically required by the SoC, such as a crystal oscillator for timekeeping, antenna impedance matching network, antenna, etc. Such components cannot be included in an SoC due to extremely limited space.

This guide focuses on the Espressif's module conventions and SoC naming conventions are explained to the extent needed to clarify the parts relevant to module naming conventions.

The next article will dive into SoC naming conventions.

<!-- TODO[Link to an article once written]
Owner: Francesco Bez
Note: Write an article about SoC part number
Context: Developer Portal's GitLab MR `26#note_1948368`
Tags: ESP32 
-->

## SoC series

Espressif SoCs are divided into different SoC series. At the time of writing this article, the most common SoC series are:

- ESP32
- ESP32-C2 / ESP32-C3 / ESP32-C5 / ESP32-C6 / ESP32-C61
- ESP32-H2 / ESP32-H4
- ESP32-P4
- ESP32-S2 / ESP32-S3

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
You can also come across the names ESP8684 and ESP8685. These are members of the ESP32-C2 and ESP32-C3 series respectively.
{{< /alert >}}

The ESP32 was the first Wi-Fi/BLE combo module developed by Espressif, which remains one of the most widely used SoCs. While it is still a viable option, this SoC is slowly but sure approaching its [longevity commitment](https://www.espressif.com/en/products/longevity-commitment) deadline. Released almost a decade ago, it may not be the best choice for new projects unless you have specific requirements, such as needing both Ethernet and Wi-Fi in a single package or requiring classic Bluetooth.

Newer SoCs can be categorized into four main series based on the letter following the first dash:

- "C" -- Cost-optimized RISC-V cores with extensive connectivity options.
- "S" -- High-performance feature-rich SoCs.
- "H" -- BLE and 802.15.4 connectivity SoCs without Wi-Fi radio.
- "P" -- High-performance Microcontrollers without wireless connectivity typically used for HMI (such as display, camera) and edge processing applications.

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
You can find the specific part number designations for the SoCs and the SoC with integrated memory in their respective datasheets, e.g. [ESP32-S3](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf#cd-series-nomenclature).
{{< /alert >}}

## Modules

Although SoCs can be integrated directly into custom PCBs, modules could be a choice due to some technical points, including:

- They include all the required components around the SoC (including antenna filter, clock crystal, etc.).
- They provide optimized RF design for the PCB antenna.
- They can incorporate extra memory chips (both flash and PSRAM).
- Above all: Modules are certified. Check the certificates at https://www.espressif.com/en/support/documents/certificates

The last point is the most relevant, since it greatly reduces the end product's certification cost.

Now, we'll cover module nomenclature.

Originally, Espressif offered two module types: WROOM and WROVER, with a smaller MINI variant introduced later. Today, the two main module form factors are WROOM and MINI:

- __MINI__: A compact form factor, MINI modules are available only with smaller flash memory sizes (4MB or 8MB, depending on the SoC series).
- __WROOM__: A larger module that can include additional memory. Available in different configurations with varying amounts of flash and PSRAM. For ESP32 series, the complete module name is WROOM-32. For newer series it's called WROOM.
- __WROVER__: A legacy module used exclusively with ESP32 and ESP32-S2 SoCs. During the ESP32 era, WROOM modules only included extra flash memory, whereas WROVER modules integrated 8MB of PSRAM. This form factor is not used for newer SoCs as modern WROOM modules now support both flash and PSRAM expansion.

{{< figure
    default=true
    src="img/module_form_factor.webp"
    height=100
    caption="Module form factors."
    >}}

## Memory options

The available memory varies depending on the SoC itself and any additional memory chips included in the module. Therefore, to fully specify an Espressif component, you must also define its memory size.

When talking about Espressif products, you can encounter four types or memory:

- ROM: Internal memory, non-volatile and read-only. It stores the first-stage bootloader.
- RAM: Internal random-access memory, volatile. It's the primary memory of the chip
- Flash: Internal or external memory, non-volatile. It's the memory where the second stage bootloader, the code, and the data is stored.
- PSRAM: Internal or external memory, volatile. PSRAM stands for [pseudo-static RAM](https://en.wikipedia.org/wiki/Dynamic_random-access_memory#Pseudostatic_RAM). The PSRAM is an auxiliary memory to the internal RAM memory of the SoCs. Additional PSRAM can be useful for applications that require graphics or handling resource-intensive tasks.

In part numbers, you can find the following letters denoting the memory size for Flash and PSRAM:

- N : flash memory with _standard_ temperature range (-40/+85 ºC)
- H : flash memory with _high_ temperature range (-40/+105 ºC)
- R : PSRAM

These conventions are applicable to both SoCs (e.g. ESP32FN8, ESP32R2) and modules (e.g. ESP32-S3-WROOM-1-N16R8).

ROM and internal RAM are not present in the part number since their size is fixed for the whole series. However, you can always find it in a chip datasheet, for example see [ESP32-S3 Chip Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf#cd-overview-features) > _Features_ > _CPU and Memory_.

## Antenna options

Espressif modules are available with either an integrated PCB antenna or an external antenna connector. The external antenna option is particularly useful when the module is enclosed in a metal case, as the antenna must be positioned outside in such case for optimal signal reception.

Modules with an external antenna connector include a "-U" suffix in their part number. For example, the ESP32-C3-MINI-1U-N4 features an external antenna connector, while the ESP32-C3-MINI-1-N4 comes with an integrated PCB antenna.

## Silicon versions

Over the years, several new silicon revisions have been developed, typically offering improved performance or addressing security vulnerabilities. The version can be specified by a letter (like the D and E in ESP32-WROOM-32D and ESP32-WROOM-32E) or a number.
The versioning doesn't follow a specific rule. A couple of examples, from the oldest to the newest version:

* ESP32-WROOM-32-N4 -> ESP32-WROOM-32D-N4 -> ESP32-WROOM-32E-N4
* ESP32-WROVER-N8R8 -> ESP32-WROVER-B-N8R8 -> ESP32-WROVER-E-N8R8
* ESP32-C3-MINI-1-H4 -> ESP32-C3-MINI-1-H4X

## Part number

To summarize, specifying an Espressif component requires defining the SoC, the module package size, and the memory configuration (flash and PSRAM), as showed in the picture below.
{{< figure
    default=true
    src="img/espressif_pn_img.webp"
    >}}

To check which versions are available for a specific module or SoC, you can consult the _Series Comparison_ section of a respective module datasheet.

### Examples

- [ESP32-WROOM-32D-N8](https://www.espressif.com/sites/default/files/documentation/esp32-wroom-32d_esp32-wroom-32u_datasheet_en.pdf#subsection.1.2):
  - SoC: ESP32
  - Module Format: WROOM-32
  - Version: D
  - Memory: 8MB flash with normal temperature range
- [ESP32-C3-MINI-1-N4](https://www.espressif.com/sites/default/files/documentation/esp32-c3-mini-1_datasheet_en.pdf#subsection.1.2)
  - SoC: ESP32-C3
  - Module Format: MINI-1
  - Version: N/S - First release
  - Memory: 4MB (i.e. integrated memory in SoC)
- [ESP32-S3-WROOM-1-N16R8](https://www.espressif.com/sites/default/files/documentation/esp32-s3-wroom-1_wroom-1u_datasheet_en.pdf#subsection.1.2)
  - SoC: ESP32-S3
  - Module: WROOM-1
  - Version: N/S - First release
  - Memory: 16MB flash with normal temperature range / 8MB PSRAM

## Conclusion

Espressif's lineup of SoCs and modules continues to evolve, offering a wide range of options tailored to different applications. Understanding the naming conventions and key specifications—such as SoC type, module form factor, and memory configuration—ensures you can select the best module for your project.

By using integrated modules, you can simplify development, reduce certification costs, and take advantage of pre-validated designs. Whether you need a compact, low-power solution or a high-performance module with extensive connectivity, Espressif provides an extensive nomenclature to suit your requirements.

With this knowledge, you should be better equipped now to navigate Espressif's offerings and make informed decisions when selecting hardware for your next project.
