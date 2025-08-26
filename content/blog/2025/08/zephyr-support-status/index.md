---
title: "Zephyr Support Status"
date: 2025-08-27
showAuthor: false
authors:
  - "ricardo-tafas"
tags: ["Zephyr", "Support", "Espressif"]
---

## Zephyr Support Status

### General Information

Questions about the contents of this page must be directed to:
* [Espressif Sales Contact Page](https://www.espressif.com/en/contact-us/sales-questions)
* [Espressif Technical Inquiries page](https://www.espressif.com/en/contact-us/technical-inquiries)
* [Zephyr Discord Server, Espressif Channel](https://discord.com/channels/720317445772017664/883444902971727882)
* [GH Issues](https://github.com/zephyrproject-rtos/zephyr/issues)
* [GH Discussions](https://github.com/zephyrproject-rtos/zephyr/discussions)

Also, make sure to check Zephyr in [Espressif's website](https://www.espressif.com/en/sdks/esp-zephyr) for overall information about Espressif and Zephyr. You can also use the ChatBot.

Users can check the [ESP32 Support Status RFC](https://github.com/zephyrproject-rtos/zephyr/issues/29394), for historical reasons.

## Zephyr Support Status

### Device Support Information

Espressif started contributing directly to the Zephyr project in May, 2020. Initially aiming to supporting only ESP32, the strategy was expanded to cover other devices due to community request.

**All ESP32\*\* chips will eventually be supported**, although there might be difference in support level for different devices.

Since the release v4.0 for ESP32-C3, the system is considered stable for production, although users are always advised to test the system for their application before any major decision.

### Peripheral Support Table

| Peripheral / Subsystem             | ESP32              | ESP32-S2           | ESP32-S3           | ESP32-C2               | ESP32-C3           | ESP32-C6           | ESP32-P4           |
|:-----------------------------------|:------------------:|:------------------:|:------------------:|:----------------------:|:------------------:|:------------------:|:------------------:|
| Chip Revision (minimum)            | 3.0                | 0.0                | 0.1                | 1.0                    | 0.4                | 0.2                | :x:                |
| Chip Revision (current)            | 3.1                | 1.0                | 0.2                | 1.2                    | 1.1                | 0.2                | :x:                |
| CPU                                | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| IRQ                                | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| TIMERS                             | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| UART                               | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| I2C                                | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| SPI                                | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| SPI FLASH                          | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| SPI RAM                            | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :no_entry_sign:        | :no_entry_sign:    | :no_entry_sign:    | :x:                |
| Cryptography                       | :x:                | :x:                | :x:                | :x:                    | :x:                | :x:                | :x:                |
| Wi-Fi                              | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :no_entry_sign:    |
| Bluetooth                          | :heavy_check_mark: | :no_entry_sign:    | :heavy_check_mark: | :heavy_plus_sign:      | :heavy_check_mark: | :heavy_plus_sign:  | :no_entry_sign:    |
| Bluetooth Mesh                     | :x:                | :x:                | :x:                | :x:                    | :x:                | :x:                | :no_entry_sign:    |
| IEEE802.15.4                       | :no_entry_sign:    | :no_entry_sign:    | :no_entry_sign:    | :no_entry_sign:        | :no_entry_sign:    | :heavy_check_mark: | :no_entry_sign:    |
| DMA                                | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| GPIO                               | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| TWAI                               | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :x:                    | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| E-FUSE                             | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_plus_sign:      | :heavy_check_mark: | :heavy_plus_sign:  | :x:                |
| ADC                                | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| DAC                                | :heavy_check_mark: | :heavy_check_mark: | :no_entry_sign:    | :no_entry_sign:        | :no_entry_sign:    | :no_entry_sign:    | :no_entry_sign:    |
| MCPWM                              | :heavy_check_mark: | :no_entry_sign:    | :heavy_check_mark: | :no_entry_sign:        | :no_entry_sign:    | :heavy_check_mark: | :x:                |
| LEDPWM                             | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| PCNT                               | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :no_entry_sign:        | :no_entry_sign:    | :heavy_check_mark: | :x:                |
| TRNG                               | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| LCD                                | :no_entry_sign:    | :no_entry_sign:    | :x:                | :no_entry_sign:        | :no_entry_sign:    | :no_entry_sign:    | :x:                |
| WATCHDOG                           | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| LOW POWER (Light Sleep)            | :heavy_plus_sign:  | :heavy_plus_sign:  | :heavy_plus_sign:  | :heavy_plus_sign:      | :heavy_plus_sign:  | :heavy_plus_sign:  | :x:                |
| LOW POWER (Deep Sleep)             | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_plus_sign:      | :heavy_check_mark: | :heavy_plus_sign:  | :x:                |
| LOW POWER (Peripherals)            | :x:                | :x:                | :x:                | :x:                    | :x:                | :x:                | :x:                |
| RTC                                | :x:                | :x:                | :x:                | :x:                    | :x:                | :x:                | :x:                |
| USB OTG                            | :no_entry_sign:    | :x:                | :x:                | :x:                    | :no_entry_sign:    | :x:                | :x:                |
| USB CDC                            | :no_entry_sign:    | :no_entry_sign:    | :heavy_check_mark: | :x:                    | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| ETH MAC                            | :heavy_check_mark: | :no_entry_sign:    | :no_entry_sign:    | :no_entry_sign:        | :no_entry_sign:    | :no_entry_sign:    | :x:                |
| SDHC                               | :heavy_check_mark: | :no_entry_sign:    | :heavy_check_mark: | :no_entry_sign:        | :no_entry_sign:    | :x:                | :x:                |
| SDIO (slave)                       | :x:                | :x:                | :x:                | :x:                    | :x:                | :x:                | :x:                |
| CAMERA                             | :no_entry_sign:    | :no_entry_sign:    | :heavy_check_mark: | :no_entry_sign:        | :no_entry_sign:    | :no_entry_sign:    | :x:                |
| I2S                                | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :x:                    | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| LP CPU                             | :no_entry_sign:    | :x:                | :x:                | :x:                    | :no_entry_sign:    | :x:                | :x:                |
| SMP                                | :x:                | :no_entry_sign:    | :x:                | :no_entry_sign:        | :no_entry_sign:    | :no_entry_sign:    | :x:                |
| AMP                                | :heavy_plus_sign:  | :no_entry_sign:    | :heavy_plus_sign:  | :no_entry_sign:        | :no_entry_sign:    | :no_entry_sign:    | :x:                |
| FLASH ENCRYPTION                   | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_plus_sign:      | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| SecureBoot V2                      | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_plus_sign:      | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| DFS                                | :x:                | :x:                | :x:                | :x:                    | :x:                | :x:                | :x:                |
| OPENOCD                            | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| MCUBOOT (Zephyr port)              | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :heavy_check_mark: | :heavy_check_mark: | :x:                |
| MCUBOOT (Espressif port)           | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_plus_sign:      | :heavy_check_mark: | :heavy_check_mark: | :x:                |

*Last update in 30/06/2025*

**Legend:**
* :heavy_check_mark: : Supported
* :heavy_plus_sign: : Work in Progress / Partially Supported
* :x: : Not yet Supported
* :no_entry_sign: : Not available on this device

**:blue_book: Notes and Limitations:**
* *Current Chip Versions* are listed for support in Zephyr. For the newest chip versions, consult Espressif website.
* Peripherals developed by community are flagged as supported if a test case is provided and it has passed internal manual and automatic tests.
* The camera implementation on ESP32 and ESP32S2 is an ESP-IDF software based implementation. It won't be ported to Zephyr.
* ULP is not a full CPU, and it won't be supported in Zephyr for ESP32 and ESP32-S2.
* ESP32 and ESP32S2, DMA is 'per peripheral'. With the exception of ESP32 DAC, all peripheral DMA is implemented.
* Flash Encryption and Secureboot are only available with Espressif Port of MCUboot. MCUboot "soft features" may still be available on Zephyr port of MCUboot.
* SMP (Symmetric MultiProcessing) is not working and has BT limitations. [Check the thread about it](https://github.com/zephyrproject-rtos/zephyr/issues/56011).
* ESP8684, please check ESP32-C2
* ESP8685, please check ESP32-C3

## Zephyr Releases

### Devices and Release Plan

Espressif is 100% adherent to Zephyr Schedule and plans around Zephyr public plans. The first *ready for production* release of Zephyr for Espressif products was 4.0 targetting ESP32-C3.

| Release Version | Date        | Expected New Device Support          | Comments | 
|:----------------|:-----------:|:------------------------------------:|:--------:|
| 4.2             | Jul 2025    |                                      |          |
| 4.3             | Nov 2025    | ESP32-H2, ESP32-P4                   |          |
| 4.4             | Mar 2026    | ESP32-C5, ESP32-C61, ESP32-H4        |          |
| 4.5             | Jul 2026    |                                      |          |
| 4.6             | Nov 2026    |                                      |          |
| 4.7             | Mar 2027    |                                      | LTS      |

*Last update in 30/06/2025*

**:warning: Warning**
- **Users should ALWAYS use the latest hash/commit of [Zephyr Repository](https://github.com/zephyrproject-rtos/zephyr) during development cycle due to constant update and bug fixes.** 

**:blue_book: Notes:**
- Work on devices starts earlier and devices may be available in between releases. Then, the table above reflects the first Release to support the device.
- Dates are tenative and subject to change. [Zephyr Release Plan](https://github.com/zephyrproject-rtos/zephyr/wiki/Release-Management#future-releases) may change without notice.

### Best Release for Espressif Devices

During the development stage, users are expected to keep using the latest software available. In other words, users are expected to be using the latest commit hash from Zephyr GitHub repository.

Espressif strongly suggests, for Zephyr-based software on its devices, the adherence to the rolling release model, keeping up with upstream. Espressif considers Zephyr versions as weak locators of software status. Staying in between releases, given the great capacity of tracking offered by GIT, is not perceived as an issue.

Espressif is adherent to LTS releases of Zephyr for OS bugfixes only.

## Disclaimers
 
Espressif does not control the Zephyr Project and does not claim any ownership over it. The Zephyr Project is managed by the Linux Foundation, and Espressif participates as a regular contributor.

As such, elements like release dates, release planning, issue classification, relevance levels, major technical decisions, and the activities of the Technical Steering Committee (TSC)—as well as much of the information found on the Zephyr Project's GitHub—are not under Espressif’s control or supervision.

Espressif is fully committed to following the Zephyr Project’s rules, regulations, and governance, just like any other regular contributor.
