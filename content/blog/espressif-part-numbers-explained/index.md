---
title: "Espressif Part Numbers Explained"
date: 2025-01-29
featureAsset: "img/featured/featured-storage.webp"
showAuthor: false
authors:
  - francesco-bez 
---

Espressif has developed a diverse range of cores and modules over the years, constantly expanding its lineup with new versions while refining existing ones. However, keeping up with these changes and understanding the naming conventions can be challenging, especially for those new to Espressif’s ecosystem.

This guide aims to simplify the process by breaking down how Espressif part numbers are structured and what they reveal about a component’s specifications. We’ll cover the different core families, module types, memory configurations, and versioning to help you make informed decisions when selecting the right hardware for your project.

## Cores Families

Espressif models are based on different cores, among which the most common are

- ESP32
- ESP32-C2 / ESP32-C3
- ESP32-S3
- ESP32-C6 / ESP32-C61
- ESP32-H2 / ESP32-H4
- ESP32-P4

The ESP32 was Espressif’s first Wi-Fi/BLE combo module and remains one of the most widely used cores. While it is still a viable option, it is a mature product and may not be the best choice for new projects unless you have specific requirements, such as needing both Ethernet and Wi-Fi in a single package or requiring classic Bluetooth (BLE Classic).

Newer cores can be categorized into four main families based on the letter following the first dash:

- "C" – Cost-optimized RISC-V cores with extensive connectivity options.
- "S" – High-performance components, based on the Cadence Tensilica architecture.
- "H" – BLE and 802.15.4 connectivity SoCs without Wi-Fi radio.
- "P" – High-performance Microcontrollers without wireless connectivity typically useful for HMI (such as display, camera) and edge processing applications.

Some cores also come with different embedded memory options, allowing them to function with minimal external components.

Although these SoCs can be integrated directly into custom PCBs, using pre-integrated modules is often the best approach unless there are strict space constraints.


For this reason, we'll now cover module nomenclature. You can find the specific part number designations for the cores and the SoC with integrated memory in their respective datasheets, e.g. [ESP32-S3](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf#page=13).

## Integrated Modules

An Espressif module integrates all the necessary passive components for operation, including the antenna filter and clock crystal. Additionally, these modules can incorporate extra memory chips (both flash and PSRAM), enabling more complex applications such as high-bandwidth connectivity or graphical interfaces.

A key advantage of using Espressif modules is that they come with multiple certifications, significantly simplifying and reducing the cost of the final product certification process.

Originally, Espressif offered two module types: WROOM and WROVER, with a smaller Mini variant introduced later. Today, the two main module form factors are WROOM and MINI:

- __MINI__: A compact module that does not include an additional memory chip. MINI modules are available only with smaller flash memory sizes (4MB or 8MB, depending on the core).
- __WROOM__: A larger module that can include additional memory. Available in different configurations with varying amounts of flash and PSRAM.
- __WROVER__: A legacy module used exclusively with ESP32 and ESP32-S2 cores. During the ESP32 era, WROOM modules only included extra flash memory, whereas WROVER modules integrated 8MB of PSRAM. This form factor is not used for newer cores, as modern WROOM modules now support both flash and PSRAM expansion.

{{< figure
    default=true
    src="img/module_form_factor.png"
    height=100
    caption="Module form factors. WROVER is limited to ESP32 core"
    >}}

## Memory Options

The available memory varies depending on the core itself and any additional memory chips included in the module. Therefore, to fully specify an Espressif component, you must also define its memory size.

Espressif modules can include two types of additional memory: flash and PSRAM. In part numbers, you can find the following letters denoting the memory size:
* N : flash memory with standard temperature range
* H : flash memory with high-temperature range 
* R : PSRAM 

## Antenna Options

Espressif modules are available with either an integrated PCB antenna or an IPEX connector, which requires an external antenna. The IPEX option is particularly useful when the module is enclosed in a metal case, as the antenna must be positioned outside for optimal signal reception.

Modules with an IPEX connector include a "-U" suffix in their part number. For example, the ESP32-C3-MINI-1U-N4 features an IPEX connector, while the ESP32-C3-MINI-1-N4 comes with an integrated PCB antenna

## Core Versions

Over the years, several new silicon revisions have been developed, typically offering improved performance or addressing security vulnerabilities. The core version can be specified by a letter (like the D and E in ESP32-WROOM-32D and ESP32-WROOM-32E) or a number. 


## Part Number

To summarize, specifying an Espressif component requires defining the core, the module package size, and the memory configuration (flash and PSRAM), as showed in the picture below. 
{{< figure
    default=true
    src="img/espressif_pn_img.png"
    >}}

### Examples

- ESP32-WROOM-32D-N8:
	- Core: ESP32
	- Module Format: WROOM
	- Version: D
	- Memory: 8MB flash
- ESP32-C3-Mini-1-N4
	- Core: ESP32-C3
	- Module Format: MINI
	- Version: x
	- Memory: 4MB (i.e. integrated memory in SoC)
- ESP32-S3-WROOM-1-N16R8
	- Core: ESP32-S3
	- Module: WROOM
	- Version: x
	- Memory: 16MB flash / 8MB PSRAM

__Note__: The PSRAM indicated by the letter after "R" refers to the _additional_ memory included in the module. All cores have integrated RAM, which is standard for each core and not part of the part number (PN).

## Conclusion

Espressif’s lineup of cores and modules continues to evolve, offering a wide range of options tailored to different applications. Understanding the naming conventions and key specifications—such as core type, module form factor, and memory configuration—ensures you can select the best component for your project.

By using integrated modules, you can simplify development, reduce certification costs, and take advantage of pre-validated designs. Whether you need a compact, low-power solution or a high-performance module with extensive connectivity, Espressif provides a well-structured naming system to guide your choice.

With this knowledge, you’ll be better equipped to navigate Espressif’s offerings and make informed decisions when selecting hardware for your next project.
