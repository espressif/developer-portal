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

Questions about the contents of this page should be directed to:  
* [Espressif Sales Contact Page](https://www.espressif.com/en/contact-us/sales-questions)  
* [Espressif Technical Inquiries Page](https://www.espressif.com/en/contact-us/technical-inquiries)  
* [Zephyr Discord Server – Espressif Channel](https://discord.com/channels/720317445772017664/883444902971727882)  
* [GitHub Issues](https://github.com/zephyrproject-rtos/zephyr/issues)  
* [GitHub Discussions](https://github.com/zephyrproject-rtos/zephyr/discussions)

Additionally, be sure to check the [Zephyr section on Espressif's website](https://www.espressif.com/en/sdks/esp-zephyr) for general information about Espressif and Zephyr. You can also use the chatbot for assistance.

For historical context, users can refer to the [ESP32 Support Status RFC](https://github.com/zephyrproject-rtos/zephyr/issues/29394).

## Zephyr Support Status

### Device Support Information

Espressif began contributing directly to the Zephyr project in May 2020. Initially aiming to support only the ESP32, the strategy was later expanded to include other devices in response to community requests.

**All ESP32\*\* chips will eventually be supported**, although support levels may vary across devices.

Since the release of version 4.0 for the ESP32-C3, the system has been considered stable for production. However, users are always advised to test the system with their specific application before making any major decisions.

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

**Legend:**
* :heavy_check_mark: : Supported
* :heavy_plus_sign: : Work in Progress / Partially Supported
* :x: : Not yet Supported
* :no_entry_sign: : Not available on this device

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
- *Current chip versions* are listed as supported in Zephyr. For the latest chip versions, please consult the Espressif website.  
- Peripherals developed by the community are marked as supported if a test case is provided and has passed both internal manual and automated testing.  
- The camera implementation on ESP32 and ESP32-S2 is based on ESP-IDF software. It will not be ported to Zephyr.  
- ULP is not a full CPU and will not be supported in Zephyr for ESP32 and ESP32-S2.  
- For ESP32 and ESP32-S2, DMA is implemented on a per-peripheral basis. With the exception of the ESP32 DAC, all peripheral DMA is supported.  
- Flash encryption and secure boot are only available through Espressif's port of MCUboot. MCUboot's "soft features" may still be available in the Zephyr port of MCUboot.  
- SMP (Symmetric MultiProcessing) is currently non-functional and has Bluetooth limitations. [Check the thread about it](https://github.com/zephyrproject-rtos/zephyr/issues/56011).  
- For ESP8684, please refer to ESP32-C2.  
- For ESP8685, please refer to ESP32-C3.
{{< /alert >}}

## Zephyr Releases

### Devices and Release Plan

Espressif fully adheres to the Zephyr schedule and plans its development around Zephyr's public roadmap. The first ready-for-production release of Zephyr for Espressif products was version 4.0, targeting the ESP32-C3.

| Release Version | Date        | Expected New Device Support          | Comments | 
|:----------------|:-----------:|:------------------------------------:|:--------:|
| 4.2             | Jul 2025    |                                      | Current  |
| 4.3             | Nov 2025    | ESP32-H2, ESP32-P4                   |          |
| 4.4             | Mar 2026    | ESP32-C5, ESP32-C61, ESP32-H4        |          |
| 4.5             | Jul 2026    |                                      |          |
| 4.6             | Nov 2026    |                                      |          |
| 4.7             | Mar 2027    |                                      | LTS      |


{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
- Work on devices often begins before official releases, and devices may become available in the middle of a release cycle. Therefore, the table above reflects the first official release that supports the device.
- Dates are tentative and subject to change. The [Zephyr Release Plan](https://github.com/zephyrproject-rtos/zephyr/wiki/Release-Management#future-releases) may be updated without notice.
{{< /alert >}}

### Best Release for Espressif Devices

{{< alert >}}
**Users should always use the latest hash or commit from the [Zephyr repository](https://github.com/zephyrproject-rtos/zephyr) during the development cycle, due to ongoing updates and bug fixes.**
{{< /alert >}}

During the development stage, users are expected to use the latest available software. In other words, they should work with the most recent commit hash from the Zephyr GitHub repository, even if it does not correspond to a numbered release. The version will typically resemble *v4.0-hashnumber*.

Espressif strongly recommends adhering to the rolling release model for Zephyr-based software on its devices, staying aligned with upstream developments. Espressif considers Zephyr version numbers to be weak indicators of software status. Remaining between releases is not seen as problematic, given Git's robust tracking capabilities. Furthermore, any backfixes that diverge from upstream will result in a fork, which, according to best practices, should be avoided.

Espressif follows Zephyr's LTS releases solely for operating system bug fixes.

## Disclaimers
 
Espressif does not control the Zephyr Project and does not claim any ownership of it. The Zephyr Project is managed by the Linux Foundation, and Espressif participates as a regular contributor.

Accordingly, elements such as release dates, planning, issue classification, relevance levels, major technical decisions, and the activities of the Technical Steering Committee (TSC) and the broader community, as well as much of the information found on the Zephyr Project's GitHub, are not under Espressif's control or supervision.

Espressif remains fully committed to adhering the Zephyr Project's rules, regulations, and governance, just like any other regular contributor.
