---
title: "Optimizing RAM Usage on ESP32-C2"
date: 2025-11-03
summary: ESP32-C2 has 256 KB of physical RAM, but with default configurations, only 24 KB remains free in typical Wi-Fi + BLE scenarios. This article explores comprehensive memory optimization strategies that can free up over 100 KB of RAM, making complex applications viable on this cost-effective chip.
showAuthor: false
authors:
  - zhengzhong
tags: ["ESP32-C2", "Memory Optimization", "Performance", "ESP-IDF"]
---

## Overview

The ESP32-C2 chip provides 256 KB of available physical RAM, making it an excellent cost-effective solution for IoT applications. However, when testing with default ESP-IDF configurations, running a BLE + Wi-Fi coexistence example ([`bleprph_wifi_coex`](https://github.com/espressif/esp-idf/tree/v5.5-beta1/examples/bluetooth/nimble/bleprph_wifi_coex)) leaves only 24 KB of free memory—insufficient for developing complex applications.

The root cause of this issue is that ESP32-C2's default configuration prioritizes performance, compiling many core components into IRAM to improve execution speed. For cost-sensitive applications that primarily require simple control operations, users can significantly optimize memory usage. With deep optimization, it's possible to free up more than 100 KB of additional memory.

This article documents RAM optimization for ESP32-C2 based on ESP-IDF release/v5.5, explaining the impact of each optimization and how to enable them.

> **Warning:** Some optimization methods listed in this document may reduce system performance and stability. After implementing RAM optimizations, thorough performance and stability testing should be conducted to ensure the application meets all requirements.

## ESP32-C2 Memory Map Overview

ESP32-C2 features 256 KB of on-chip RAM, which is separate from the ROM used for boot and system code—ROM is not counted within this 256 KB. The memory map for ESP32-C2 closely resembles those of other ESP chips: RAM is allocated for data, stack, heap, and code execution, while certain regions are reserved by the system and peripherals.

Although [this blog post](https://developer.espressif.com/blog/2024/08/esp32-memory-map-101/) does not specifically describe ESP32-C2, it provides a useful primer on how memory is typically organized on ESP chips. The overall memory region concepts (dedicated areas for instruction and data, reserved and shared buffers, etc.) are similar across the ESP family, even if exact sizes or addresses differ.


## Getting Current Free Memory

Before optimizing memory, it's essential to understand the current memory usage. For static memory usage, you can use the `idf.py size` and `idf.py size-components` commands after compilation to analyze memory consumption.

For runtime memory usage, the `esp_get_free_heap_size()` and `esp_get_minimum_free_heap_size()` functions can retrieve the current free heap memory and the minimum free heap size since system startup, respectively. For more details, refer to the [ESP-IDF Heap Memory Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c2/api-reference/system/heap_debug.html).

## ESP32-C2 Memory Test Results

The following data compares free memory on ESP32-C2 using ESP-IDF tag v5.5-beta1, tested with default configurations (after `idf.py set-target esp32c2`) versus various optimization configurations.

### Test Scenario Descriptions

- **station**: Print free memory after the GOT IP event is triggered. See the [Wi-Fi station example](https://github.com/espressif/esp-idf/tree/v5.5-beta1/examples/wifi/station)
- **WiFi station + 1TLS(MQTTS)**: Use the [mqtt/ssl example](https://github.com/espressif/esp-idf/tree/v5.5-beta1/examples/protocols/mqtt/ssl) and print free memory after the MQTT_EVENT_DATA event is triggered
- **bleprph_wifi_coex**: After the WiFi GOT_IP event is triggered, initialize nimble and enable BLE advertising, then print free memory. See the [BLE + Wi-Fi coexistence example](https://github.com/espressif/esp-idf/tree/v5.5-beta1/examples/bluetooth/nimble/bleprph_wifi_coex)
- **bleprph_wifi_coex + mbedtls + power_save**: Based on [`bleprph_wifi_coex`](https://github.com/espressif/esp-idf/tree/v5.5-beta1/examples/bluetooth/nimble/bleprph_wifi_coex), integrate [https_mbedtls](https://github.com/espressif/esp-idf/tree/v5.5-beta1/examples/protocols/https_mbedtls) and [power_save](https://github.com/espressif/esp-idf/tree/v5.5-beta1/examples/wifi/power_save) functionality, then print free memory after connecting to the HTTPS server. For the demo implementation and optimization configuration files, refer to [this repository](https://github.com/Jacques-Zhao/ble_wifi_mbetlds_mem_opt_demo)

### Default Configuration Memory Usage Comparison

| Test Case                                    | Default Config (KB) | Optimized Config (KB) |
| -------------------------------------------- | ------------------- | --------------------- |
| station                                      | 95                  | 169                   |
| WiFi station + 1TLS(MQTTS)                  | 55                  | 152                   |
| bleprph_wifi_coex                            | 24                  | 125                   |
| bleprph_wifi_coex + mbedtls + power_save     | Insufficient        | 115                   |

> **Note:** This document focuses on ESP32-C2 memory optimization processes and results. For more comprehensive memory usage statistics across different chips and scenarios, refer to the [Memory Usage Comparison Documentation](https://docs.espressif.com/projects/esp-techpedia/en/latest/esp-friends/advanced-development/performance/reduce-ram-usage.html#memory-usage-comparison).

## Optimization Strategies

The optimization strategies in this article are based on a custom test case combining `bleprph_wifi_coex + mbedtls + power_save`, which includes common scenarios: Wi-Fi + BLE + HTTPS + power save auto-sleep. For the demo implementation and optimization configuration files, refer to [this repository](https://github.com/Jacques-Zhao/ble_wifi_mbetlds_mem_opt_demo). Without any optimizations, this scenario triggers a reset due to insufficient runtime memory.

### Optimization Approach Comparison

| Optimization Approach | v5.4.1 (bytes) | v5.5 (bytes) | Description                                                              |
| --------------------- | -------------- | ------------ | ------------------------------------------------------------------------ |
| No optimization       | Insufficient   | Insufficient | Default configuration after `idf.py set-target esp32c2`                  |
| Basic optimization    | 62,840         | 60,212       | Optimize configuration items according to memory optimization guidelines |
| Advanced optimization | 91,976         | 90,576       | Further optimization on top of basic, suitable for v5.4.x and earlier    |
| v5.5 deep optimization|                | 118,096      | Deep optimization utilizing v5.5 new features                            |

> **Note:** 
> 1. **No optimization**: Default configuration after `idf.py set-target esp32c2`, ensuring only basic functionality (e.g., enabling Bluetooth, PM), with no memory-specific optimizations. See the [default configuration file](https://github.com/Jacques-Zhao/ble_wifi_mbetlds_mem_opt_demo/blob/main/sdkconfig.defaults).
> 2. **Basic optimization**: Completely follows the [ESP-IDF Memory Optimization Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/performance/ram-usage.html), involving moving various functions from IRAM to flash, reducing Wi-Fi buffers, and optimizing mbedtls configuration. See [sdkconfig.defaults.opt.1](https://github.com/Jacques-Zhao/ble_wifi_mbetlds_mem_opt_demo/blob/main/sdkconfig.defaults.opt.1).
> 3. **Advanced optimization**: Based on basic optimization, further deep optimization, especially suitable for v5.4.x and earlier versions. This represents the "final optimization" result for those versions. See [sdkconfig.defaults.opt.2](https://github.com/Jacques-Zhao/ble_wifi_mbetlds_mem_opt_demo/blob/main/sdkconfig.defaults.opt.2).
> 4. **v5.5 deep optimization**: Continues optimization beyond advanced optimization, but only for ESP-IDF v5.5 and later. This optimization leverages new features (such as flash suspend) to place more code in flash, thereby freeing IRAM and minimizing memory usage. See [sdkconfig.defaults.opt.3](https://github.com/Jacques-Zhao/ble_wifi_mbetlds_mem_opt_demo/blob/main/sdkconfig.defaults.opt.3).

## Basic Optimization

The [ESP-IDF Programming Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/performance/ram-usage.html) provides a series of memory optimization methods, primarily including IRAM optimization and heap memory optimization. IRAM optimization mainly moves FreeRTOS, Wi-Fi, and heap component functions to flash; heap memory optimization primarily reduces the static memory allocation of Wi-Fi and lwIP components.

Key optimization items include:

- Moving FreeRTOS functions from IRAM to flash
- Moving Wi-Fi functions from IRAM to flash
- Reducing Wi-Fi static buffers
- Optimizing lwIP memory usage
- Optimizing mbedTLS configuration

For detailed configuration options, refer to the [memory optimization documentation](https://docs.espressif.com/projects/esp-techpedia/zh_CN/latest/esp-friends/advanced-development/performance/reduce-ram-usage.html). Through these configuration optimizations (see [sdkconfig.defaults.opt.1](https://github.com/Jacques-Zhao/ble_wifi_mbetlds_mem_opt_demo/blob/main/sdkconfig.defaults.opt.1)), available memory can be increased to 62 KB after all functions are executed.

## Advanced Optimization

Building on basic optimization, advanced optimization includes:

1. **Enable CONFIG_BT_CTRL_RUN_IN_FLASH_ONLY**  
   After enabling [`CONFIG_SPI_FLASH_AUTO_SUSPEND`](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c2/api-reference/kconfig-reference.html#config-spi-flash-auto-suspend), enabling [`CONFIG_BT_CTRL_RUN_IN_FLASH_ONLY`](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c2/api-reference/kconfig-reference.html#config-bt-ctrl-run-in-flash-only) places all Bluetooth controller code in flash, freeing approximately 20 KB of memory.

2. **Enable Compiler Optimization Options**  
   - [`CONFIG_COMPILER_OPTIMIZATION_SIZE`](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c2/api-reference/kconfig-reference.html#config-compiler-optimization)
   - [`CONFIG_COMPILER_SAVE_RESTORE_LIBCALLS`](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c2/api-reference/kconfig-reference.html#config-compiler-save-restore-libcalls)  
   These compiler optimizations can free approximately 8 KB of additional memory.

With all the above configurations enabled (basic + advanced optimization), available memory increases to 90 KB. For the complete advanced optimization configuration file, refer to [sdkconfig.defaults.opt.2](https://github.com/Jacques-Zhao/ble_wifi_mbetlds_mem_opt_demo/blob/main/sdkconfig.defaults.opt.2).

## v5.5 Deep Optimization

In ESP-IDF v5.5, we performed deep optimization on IRAM usage, allowing most IRAM functions to be placed in flash, especially when [`CONFIG_SPI_FLASH_AUTO_SUSPEND`](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c2/api-reference/kconfig-reference.html#config-spi-flash-auto-suspend) is enabled. For a detailed list of all such configurations, refer to [sdkconfig.flash_auto_suspend_iram_reduction](https://github.com/espressif/esp-idf/blob/release/v5.5/tools/test_apps/configs/sdkconfig.flash_auto_suspend_iram_reduction). For the complete v5.5 deep optimization configuration file, refer to [sdkconfig.defaults.opt.3](https://github.com/Jacques-Zhao/ble_wifi_mbetlds_mem_opt_demo/blob/main/sdkconfig.defaults.opt.3).

With all these optimizations enabled, compared to v5.4.2, an additional 20 KB of memory can be saved.

With v5.5 deep optimization, available memory after connecting to an HTTPS server can reach 118 KB, with IRAM `.text` section occupying only 10,050 bytes.

In contrast, based on v5.4.2 testing with the same optimization configuration, available memory after connecting to an HTTPS server is 95 KB, with IRAM `.text` section occupying 31,206 bytes.

### IRAM Text Section Comparison

IRAM `.text` section memory consumption data obtained using the `idf.py size` command:

| Optimization Approach | v5.4.1 (bytes) | v5.5 (bytes) |
| --------------------- | -------------- | ------------ |
| No optimization       | 93,592         | 100,616      |
| Basic optimization    | 56,384         | 60,088       |
| Advanced optimization | 36,130         | 35,912       |
| v5.5 deep optimization| N/A            | 9,742        |

The significant reduction in IRAM usage (from ~36 KB to ~10 KB) demonstrates the effectiveness of v5.5's deep optimization features.

## Applying to Other Chips

While memory optimization primarily targets the ESP32-C2 chip, other newer chips such as ESP32-C61 and ESP32-C5 can also benefit from similar optimizations. Based on default configurations, approximately 80 KB of additional memory can be freed.
