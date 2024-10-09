---
title: "Memory Availability Comparison between ESP32 and ESP32-C3"
date: 2021-04-25
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - amey-inamdar
tags:
  - Esp32
  - IoT
  - Esp32 Programming

---
Espressif launched ESP32-C3 at the end of 2020. It’s very well received and now it’s already in the mass production state. ESP32-C3 provides Wi-Fi and Bluetooth LE connectivity for applications in the most cost-effective way. For the users of ESP32 who use it for Wi-Fi and/or BLE connectivity, ESP32-C3 is a possible upgrade option provided other requirements match. So let’s first take a look at the comparison of ESP32 and ESP32-C3 from that perspective.

{{< figure
    default=true
    src="img/memory-1.webp"
    >}}

The users who have used ESP32 have a common question about how does 400 KB SRAM compare against 520 KB SRAM of ESP32 as many of the times memory availability is a critical factor for embedded applications. In this article, I provide overview of enhancements done related to memory management in ESP32-C3 and show how __ESP32-C3 can provide better or the same memory headroom in comparison with ESP32__  for various application use-cases.

## Memory Subsystem Improvements and Optimisations

## Dynamic IRAM-DRAM Split

{{< figure
    default=true
    src="img/memory-2.webp"
    >}}

{{< figure
    default=true
    src="img/memory-3.webp"
    >}}

The above two diagrams show memory maps of ESP32 and ESP32-C3 respectively. As you can see, ESP32 has static IRAM-DRAM partitioning where 192KB SRAM is used as IRAM and then remaining 328KB SRAM is used as DRAM. Part of IRAM (32 or 64KB) is used as flash cache. Then linker script is used to fill IRAM with the code that can’t be in the flash memory due to functional or performance reasons. The unused IRAM beyond this, remains unused* by the application.

In case of ESP32-C3, there is no static partitioning of IRAM and DRAM. ESP32-C3 has 16KB flash cache at the beginning of SRAM. IRAM and DRAM addresses increment in the same direction unlike ESP32. Based on the application, the linker script allocates IRAM as required for the application. The DRAM begins right where IRAM ends. Hence the memory is used more efficiently in case of ESP32-C3 than ESP32.

## Reduced IRAM Utilisation

ESP32-C3 has reduced IRAM utilisation than ESP32. This is result of the following two efforts

## Improved Bluetooth Memory Management

ESP32’s Bluetooth subsystem requires a contiguous memory (56KB for dual-mode and 38KB for BLE) at a fixed location in the DRAM. This is a considerable disadvantage if the application requires to use Bluetooth functionality but not continuously. In such case this memory remains occupied even when not used.

ESP32-C3 doesn’t require Bluetooth memory to be contiguous and at fixed location. ESP32-C3 Bluetooth subsystem allocates memory using standard system heap and hence Bluetooth can be enabled and disabled by the application as and when required. All this needs is sufficient memory to be available in the heap.

## Memory Consumption for Common Use-cases

With the above mentioned 3 reasons, ESP32-C3 can provide more effective memory usability for the applications. Let’s consider some common application use-cases and let’s see how much memory these use-cases consume of ESP32 and ESP32-C3 SoCs and what headroom is available for the application.

I have ensured that the configuration is same between ESP32 and ESP32-C3 as far as possible. Also the same SDK version (IDF version 4.3-beta3) has been used to run the applications on these SoCs.

{{< figure
    default=true
    src="img/memory-4.webp"
    >}}

Looking at the above table, it is clear that:

So as we discussed, ESP32-C3 provides equal or more headroom for applications than ESP32. However when you are considering choosing the SoC or migration option, please ensure that you also consider other important features such as PSRAM availability, IO availability and CPU performance.
