---
title: "ZephyrSupportStatus"
date: 2025-06-27T13:46:46-03:00
showAuthor: false
authors:
  - "rftafas"
tags: ["Zephyr", "Support", "Espressif"]
---

## Zephyr Support Status

Espressif started contributing directly to the Zephyr project in May, 2020. Initially aiming to supporting only ESP32. **All ESP32\*\* chips will eventually be supported**, although there might be difference in support level for different devices.

Questions about the table below or the roadmap can be directed to:
* [Espressif Sales Contact Page](https://www.espressif.com/en/contact-us/sales-questions)
* [Espressif Technical Inquiries page](https://www.espressif.com/en/contact-us/technical-inquiries)
* [Zephyr Discord Server, Espressif Channel](https://discord.com/channels/720317445772017664/883444902971727882)
* [GH Issues](https://github.com/zephyrproject-rtos/zephyr/issues)
* [GH Discussions](https://github.com/zephyrproject-rtos/zephyr/discussions)

Also, make sure to check Zephyr in [Espressif's website](https://www.espressif.com/en/sdks/esp-zephyr) for overall information about Espressif and Zephyr. You can also use the ChatBot.

Users can chek the [ESP32 Support Status RFC](https://github.com/zephyrproject-rtos/zephyr/issues/29394), for historical reasons.

## Zephyr Support Status Table

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
| SPI RAM                            | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:     | :no_entry_sign:    | :no_entry_sign:    | :x:                |
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

## Work and Release Plan

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

{{< tabs groupId="config" >}}
  {{% tab name="ESP32" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | 3.0                |
| Chip Revision (current)            | 3.1                |
| CPU                                | :heavy_check_mark: |
| IRQ                                | :heavy_check_mark: |
| TIMERS                             | :heavy_check_mark: |
| UART                               | :heavy_check_mark: |
| I2C                                | :heavy_check_mark: |
| SPI                                | :heavy_check_mark: |
| SPI FLASH                          | :heavy_check_mark: |
| SPI RAM                            | :heavy_check_mark: |
| Cryptography                       | :x:                |
| Wi-Fi                              | :heavy_check_mark: |
| Bluetooth                          | :heavy_check_mark: |
| Bluetooth Mesh                     | :x:                |
| IEEE802.15.4                       | :no_entry_sign:    |
| DMA                                | :heavy_check_mark: |
| GPIO                               | :heavy_check_mark: |
| TWAI                               | :heavy_check_mark: |
| E-FUSE                             | :heavy_check_mark: |
| ADC                                | :heavy_check_mark: |
| DAC                                | :heavy_check_mark: |
| MCPWM                              | :heavy_check_mark: |
| LEDPWM                             | :heavy_check_mark: |
| PCNT                               | :heavy_check_mark: |
| TRNG                               | :heavy_check_mark: |
| LCD                                | :no_entry_sign:    |
| WATCHDOG                           | :heavy_check_mark: |
| LOW POWER (Light Sleep)            | :heavy_plus_sign:  |
| LOW POWER (Deep Sleep)             | :heavy_check_mark: |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :no_entry_sign:    |
| USB CDC                            | :no_entry_sign:    |
| ETH MAC                            | :heavy_check_mark: |
| SDHC                               | :heavy_check_mark: |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :no_entry_sign:    |
| I2S                                | :heavy_check_mark: |
| LP CPU                             | :no_entry_sign:    |
| SMP                                | :x:                |
| AMP                                | :heavy_plus_sign:  |
| FLASH ENCRYPTION                   | :heavy_check_mark: |
| SecureBoot V2                      | :heavy_check_mark: |
| DFS                                | :x:                |
| OPENOCD                            | :heavy_check_mark: |
| MCUBOOT (Zephyr port)              | :heavy_check_mark: |
| MCUBOOT (Espressif port)           | :heavy_check_mark: |
  {{% /tab %}}
  {{% tab name="ESP32-S2" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | 0.0                |
| Chip Revision (current)            | 1.0                |
| CPU                                | :heavy_check_mark: |
| IRQ                                | :heavy_check_mark: |
| TIMERS                             | :heavy_check_mark: |
| UART                               | :heavy_check_mark: |
| I2C                                | :heavy_check_mark: |
| SPI                                | :heavy_check_mark: |
| SPI FLASH                          | :heavy_check_mark: |
| SPI RAM                            | :heavy_check_mark: |
| Cryptography                       | :x:                |
| Wi-Fi                              | :heavy_check_mark: |
| Bluetooth                          | :no_entry_sign:    |
| Bluetooth Mesh                     | :x:                |
| IEEE802.15.4                       | :no_entry_sign:    |
| DMA                                | :heavy_check_mark: |
| GPIO                               | :heavy_check_mark: |
| TWAI                               | :heavy_check_mark: |
| E-FUSE                             | :heavy_check_mark: |
| ADC                                | :heavy_check_mark: |
| DAC                                | :heavy_check_mark: |
| MCPWM                              | :no_entry_sign:    |
| LEDPWM                             | :heavy_check_mark: |
| PCNT                               | :heavy_check_mark: |
| TRNG                               | :heavy_check_mark: |
| LCD                                | :no_entry_sign:    |
| WATCHDOG                           | :heavy_check_mark: |
| LOW POWER (Light Sleep)            | :heavy_plus_sign:  |
| LOW POWER (Deep Sleep)             | :heavy_check_mark: |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :x:                |
| USB CDC                            | :no_entry_sign:    |
| ETH MAC                            | :no_entry_sign:    |
| SDHC                               | :no_entry_sign:    |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :no_entry_sign:    |
| I2S                                | :heavy_check_mark: |
| LP CPU                             | :x:                |
| SMP                                | :no_entry_sign:    |
| AMP                                | :no_entry_sign:    |
| FLASH ENCRYPTION                   | :heavy_check_mark: |
| SecureBoot V2                      | :heavy_check_mark: |
| DFS                                | :x:                |
| OPENOCD                            | :heavy_check_mark: |
| MCUBOOT (Zephyr port)              | :heavy_check_mark: |
| MCUBOOT (Espressif port)           | :heavy_check_mark: |
  {{% /tab %}}
  {{% tab name="ESP32-S3" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | 0.1                |
| Chip Revision (current)            | 0.2                |
| CPU                                | :heavy_check_mark: |
| IRQ                                | :heavy_check_mark: |
| TIMERS                             | :heavy_check_mark: |
| UART                               | :heavy_check_mark: |
| I2C                                | :heavy_check_mark: |
| SPI                                | :heavy_check_mark: |
| SPI FLASH                          | :heavy_check_mark: |
| SPI RAM                            | :heavy_check_mark: |
| Cryptography                       | :x:                |
| Wi-Fi                              | :heavy_check_mark: |
| Bluetooth                          | :heavy_check_mark: |
| Bluetooth Mesh                     | :x:                |
| IEEE802.15.4                       | :no_entry_sign:    |
| DMA                                | :heavy_check_mark: |
| GPIO                               | :heavy_check_mark: |
| TWAI                               | :heavy_check_mark: |
| E-FUSE                             | :heavy_check_mark: |
| ADC                                | :heavy_check_mark: |
| DAC                                | :no_entry_sign:    |
| MCPWM                              | :heavy_check_mark: |
| LEDPWM                             | :heavy_check_mark: |
| PCNT                               | :heavy_check_mark: |
| TRNG                               | :heavy_check_mark: |
| LCD                                | :x:                |
| WATCHDOG                           | :heavy_check_mark: |
| LOW POWER (Light Sleep)            | :heavy_plus_sign:  |
| LOW POWER (Deep Sleep)             | :heavy_check_mark: |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :x:                |
| USB CDC                            | :heavy_check_mark: |
| ETH MAC                            | :no_entry_sign:    |
| SDHC                               | :heavy_check_mark: |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :heavy_check_mark: |
| I2S                                | :heavy_check_mark: |
| LP CPU                             | :x:                |
| SMP                                | :x:                |
| AMP                                | :heavy_plus_sign:  |
| FLASH ENCRYPTION                   | :heavy_check_mark: |
| SecureBoot V2                      | :heavy_check_mark: |
| DFS                                | :x:                |
| OPENOCD                            | :heavy_check_mark: |
| MCUBOOT (Zephyr port)              | :heavy_check_mark: |
| MCUBOOT (Espressif port)           | :heavy_check_mark: |
  {{% /tab %}}
  {{% tab name="ESP32-C2" %}}
| Peripheral / Subsystem             | Status                 |
|:-----------------------------------|:----------------------:|
| Chip Revision (minimum)            | 1.0                    |
| Chip Revision (current)            | 1.2                    |
| CPU                                | :heavy_check_mark:     |
| IRQ                                | :heavy_check_mark:     |
| TIMERS                             | :heavy_check_mark:     |
| UART                               | :heavy_check_mark:     |
| I2C                                | :heavy_check_mark:     |
| SPI                                | :heavy_check_mark:     |
| SPI FLASH                          | :heavy_check_mark:     |
| SPI RAM                            | :heavy_check_mark:     |
| Cryptography                       | :x:                    |
| Wi-Fi                              | :heavy_check_mark:     |
| Bluetooth                          | :heavy_plus_sign:      |
| Bluetooth Mesh                     | :x:                    |
| IEEE802.15.4                       | :no_entry_sign:        |
| DMA                                | :heavy_check_mark:     |
| GPIO                               | :heavy_check_mark:     |
| TWAI                               | :x:                    |
| E-FUSE                             | :heavy_plus_sign:      |
| ADC                                | :heavy_check_mark:     |
| DAC                                | :no_entry_sign:        |
| MCPWM                              | :no_entry_sign:        |
| LEDPWM                             | :heavy_check_mark:     |
| PCNT                               | :no_entry_sign:        |
| TRNG                               | :heavy_check_mark:     |
| LCD                                | :no_entry_sign:        |
| WATCHDOG                           | :heavy_check_mark:     |
| LOW POWER (Light Sleep)            | :heavy_plus_sign:      |
| LOW POWER (Deep Sleep)             | :heavy_plus_sign:      |
| LOW POWER (Peripherals)            | :x:                    |
| RTC                                | :x:                    |
| USB OTG                            | :x:                    |
| USB CDC                            | :x:                    |
| ETH MAC                            | :no_entry_sign:        |
| SDHC                               | :no_entry_sign:        |
| SDIO (slave)                       | :x:                    |
| CAMERA                             | :no_entry_sign:        |
| I2S                                | :x:                    |
| LP CPU                             | :x:                    |
| SMP                                | :no_entry_sign:        |
| AMP                                | :no_entry_sign:        |
| FLASH ENCRYPTION                   | :heavy_plus_sign:      |
| SecureBoot V2                      | :heavy_plus_sign:      |
| DFS                                | :x:                    |
| OPENOCD                            | :heavy_check_mark:     |
| MCUBOOT (Zephyr port)              | :heavy_check_mark:     |
| MCUBOOT (Espressif port)           | :heavy_plus_sign:      |
  {{% /tab %}}
  {{% tab name="ESP32-C3" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | 0.4                |
| Chip Revision (current)            | 1.1                |
| CPU                                | :heavy_check_mark: |
| IRQ                                | :heavy_check_mark: |
| TIMERS                             | :heavy_check_mark: |
| UART                               | :heavy_check_mark: |
| I2C                                | :heavy_check_mark: |
| SPI                                | :heavy_check_mark: |
| SPI FLASH                          | :heavy_check_mark: |
| SPI RAM                            | :no_entry_sign:    |
| Cryptography                       | :x:                |
| Wi-Fi                              | :heavy_check_mark: |
| Bluetooth                          | :heavy_check_mark: |
| Bluetooth Mesh                     | :x:                |
| IEEE802.15.4                       | :no_entry_sign:    |
| DMA                                | :heavy_check_mark: |
| GPIO                               | :heavy_check_mark: |
| TWAI                               | :heavy_check_mark: |
| E-FUSE                             | :heavy_check_mark: |
| ADC                                | :heavy_check_mark: |
| DAC                                | :no_entry_sign:    |
| MCPWM                              | :no_entry_sign:    |
| LEDPWM                             | :heavy_check_mark: |
| PCNT                               | :no_entry_sign:    |
| TRNG                               | :heavy_check_mark: |
| LCD                                | :no_entry_sign:    |
| WATCHDOG                           | :heavy_check_mark: |
| LOW POWER (Light Sleep)            | :heavy_plus_sign:  |
| LOW POWER (Deep Sleep)             | :heavy_check_mark: |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :no_entry_sign:    |
| USB CDC                            | :heavy_check_mark: |
| ETH MAC                            | :no_entry_sign:    |
| SDHC                               | :no_entry_sign:    |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :no_entry_sign:    |
| I2S                                | :heavy_check_mark: |
| LP CPU                             | :no_entry_sign:    |
| SMP                                | :no_entry_sign:    |
| AMP                                | :no_entry_sign:    |
| FLASH ENCRYPTION                   | :heavy_check_mark: |
| SecureBoot V2                      | :heavy_check_mark: |
| DFS                                | :x:                |
| OPENOCD                            | :heavy_check_mark: |
| MCUBOOT (Zephyr port)              | :heavy_check_mark: |
| MCUBOOT (Espressif port)           | :heavy_check_mark: |
  {{% /tab %}}
  {{% tab name="ESP32-C5" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | :x:                |
| Chip Revision (current)            | :x:                |
| CPU                                | :x:                |
| IRQ                                | :x:                |
| TIMERS                             | :x:                |
| UART                               | :x:                |
| I2C                                | :x:                |
| SPI                                | :x:                |
| SPI FLASH                          | :x:                |
| SPI RAM                            | :x:                |
| Cryptography                       | :x:                |
| Wi-Fi                              | :x:                |
| Bluetooth                          | :x:                |
| Bluetooth Mesh                     | :x:                |
| IEEE802.15.4                       | :x:                |
| DMA                                | :x:                |
| GPIO                               | :x:                |
| TWAI                               | :x:                |
| E-FUSE                             | :x:                |
| ADC                                | :x:                |
| DAC                                | :no_entry_sign:    |
| MCPWM                              | :x:                |
| LEDPWM                             | :x:                |
| PCNT                               | :x:                |
| TRNG                               | :x:                |
| LCD                                | :x:                |
| WATCHDOG                           | :x:                |
| LOW POWER (Light Sleep)            | :x:                |
| LOW POWER (Deep Sleep)             | :x:                |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :x:                |
| USB CDC                            | :x:                |
| ETH MAC                            | :x:                |
| SDHC                               | :x:                |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :x:                |
| I2S                                | :x:                |
| LP CPU                             | :x:                |
| SMP                                | :x:                |
| AMP                                | :x:                |
| FLASH ENCRYPTION                   | :x:                |
| SecureBoot V2                      | :x:                |
| DFS                                | :x:                |
| OPENOCD                            | :x:                |
| MCUBOOT (Zephyr port)              | :x:                |
| MCUBOOT (Espressif port)           | :x:                |
  {{% /tab %}}
  {{% tab name="ESP32-C6" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | 0.2                |
| Chip Revision (current)            | 0.2                |
| CPU                                | :heavy_check_mark: |
| IRQ                                | :heavy_check_mark: |
| TIMERS                             | :heavy_check_mark: |
| UART                               | :heavy_check_mark: |
| I2C                                | :heavy_check_mark: |
| SPI                                | :heavy_check_mark: |
| SPI FLASH                          | :heavy_check_mark: |
| SPI RAM                            | :no_entry_sign:    |
| Cryptography                       | :x:                |
| Wi-Fi                              | :heavy_check_mark: |
| Bluetooth                          | :heavy_plus_sign:  |
| Bluetooth Mesh                     | :x:                |
| IEEE802.15.4                       | :heavy_check_mark: |
| DMA                                | :heavy_check_mark: |
| GPIO                               | :heavy_check_mark: |
| TWAI                               | :heavy_check_mark: |
| E-FUSE                             | :heavy_plus_sign:  |
| ADC                                | :heavy_check_mark: |
| DAC                                | :no_entry_sign:    |
| MCPWM                              | :heavy_check_mark: |
| LEDPWM                             | :heavy_check_mark: |
| PCNT                               | :heavy_check_mark: |
| TRNG                               | :heavy_check_mark: |
| LCD                                | :no_entry_sign:    |
| WATCHDOG                           | :heavy_check_mark: |
| LOW POWER (Light Sleep)            | :heavy_plus_sign:  |
| LOW POWER (Deep Sleep)             | :heavy_plus_sign:  |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :x:                |
| USB CDC                            | :heavy_check_mark: |
| ETH MAC                            | :no_entry_sign:    |
| SDHC                               | :x:                |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :no_entry_sign:    |
| I2S                                | :heavy_check_mark: |
| LP CPU                             | :x:                |
| SMP                                | :no_entry_sign:    |
| AMP                                | :no_entry_sign:    |
| FLASH ENCRYPTION                   | :heavy_check_mark: |
| SecureBoot V2                      | :heavy_check_mark: |
| DFS                                | :x:                |
| OPENOCD                            | :heavy_check_mark: |
| MCUBOOT (Zephyr port)              | :heavy_check_mark: |
| MCUBOOT (Espressif port)           | :heavy_check_mark: |
  {{% /tab %}}
  {{% tab name="ESP32-C6" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | 0.2                |
| Chip Revision (current)            | 0.2                |
| CPU                                | :heavy_check_mark: |
| IRQ                                | :heavy_check_mark: |
| TIMERS                             | :heavy_check_mark: |
| UART                               | :heavy_check_mark: |
| I2C                                | :heavy_check_mark: |
| SPI                                | :heavy_check_mark: |
| SPI FLASH                          | :heavy_check_mark: |
| SPI RAM                            | :no_entry_sign:    |
| Cryptography                       | :x:                |
| Wi-Fi                              | :heavy_check_mark: |
| Bluetooth                          | :heavy_plus_sign:  |
| Bluetooth Mesh                     | :x:                |
| IEEE802.15.4                       | :heavy_check_mark: |
| DMA                                | :heavy_check_mark: |
| GPIO                               | :heavy_check_mark: |
| TWAI                               | :heavy_check_mark: |
| E-FUSE                             | :heavy_plus_sign:  |
| ADC                                | :heavy_check_mark: |
| DAC                                | :no_entry_sign:    |
| MCPWM                              | :heavy_check_mark: |
| LEDPWM                             | :heavy_check_mark: |
| PCNT                               | :heavy_check_mark: |
| TRNG                               | :heavy_check_mark: |
| LCD                                | :no_entry_sign:    |
| WATCHDOG                           | :heavy_check_mark: |
| LOW POWER (Light Sleep)            | :heavy_plus_sign:  |
| LOW POWER (Deep Sleep)             | :heavy_plus_sign:  |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :x:                |
| USB CDC                            | :heavy_check_mark: |
| ETH MAC                            | :no_entry_sign:    |
| SDHC                               | :x:                |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :no_entry_sign:    |
| I2S                                | :heavy_check_mark: |
| LP CPU                             | :x:                |
| SMP                                | :no_entry_sign:    |
| AMP                                | :no_entry_sign:    |
| FLASH ENCRYPTION                   | :heavy_check_mark: |
| SecureBoot V2                      | :heavy_check_mark: |
| DFS                                | :x:                |
| OPENOCD                            | :heavy_check_mark: |
| MCUBOOT (Zephyr port)              | :heavy_check_mark: |
| MCUBOOT (Espressif port)           | :heavy_check_mark: |
  {{% /tab %}}
  {{% tab name="ESP32-H2" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | :x:                |
| Chip Revision (current)            | :x:                |
| CPU                                | :x:                |
| IRQ                                | :x:                |
| TIMERS                             | :x:                |
| UART                               | :x:                |
| I2C                                | :x:                |
| SPI                                | :x:                |
| SPI FLASH                          | :x:                |
| SPI RAM                            | :x:                |
| Cryptography                       | :x:                |
| Wi-Fi                              | :no_entry_sign:    |
| Bluetooth                          | :no_entry_sign:    |
| Bluetooth Mesh                     | :no_entry_sign:    |
| IEEE802.15.4                       | :no_entry_sign:    |
| DMA                                | :x:                |
| GPIO                               | :x:                |
| TWAI                               | :x:                |
| E-FUSE                             | :x:                |
| ADC                                | :x:                |
| DAC                                | :no_entry_sign:    |
| MCPWM                              | :x:                |
| LEDPWM                             | :x:                |
| PCNT                               | :x:                |
| TRNG                               | :x:                |
| LCD                                | :x:                |
| WATCHDOG                           | :x:                |
| LOW POWER (Light Sleep)            | :x:                |
| LOW POWER (Deep Sleep)             | :x:                |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :x:                |
| USB CDC                            | :x:                |
| ETH MAC                            | :x:                |
| SDHC                               | :x:                |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :x:                |
| I2S                                | :x:                |
| LP CPU                             | :x:                |
| SMP                                | :x:                |
| AMP                                | :x:                |
| FLASH ENCRYPTION                   | :x:                |
| SecureBoot V2                      | :x:                |
| DFS                                | :x:                |
| OPENOCD                            | :x:                |
| MCUBOOT (Zephyr port)              | :x:                |
| MCUBOOT (Espressif port)           | :x:                |
  {{% /tab %}}
  {{% tab name="ESP32-H4" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | :x:                |
| Chip Revision (current)            | :x:                |
| CPU                                | :x:                |
| IRQ                                | :x:                |
| TIMERS                             | :x:                |
| UART                               | :x:                |
| I2C                                | :x:                |
| SPI                                | :x:                |
| SPI FLASH                          | :x:                |
| SPI RAM                            | :x:                |
| Cryptography                       | :x:                |
| Wi-Fi                              | :no_entry_sign:    |
| Bluetooth                          | :no_entry_sign:    |
| Bluetooth Mesh                     | :no_entry_sign:    |
| IEEE802.15.4                       | :no_entry_sign:    |
| DMA                                | :x:                |
| GPIO                               | :x:                |
| TWAI                               | :x:                |
| E-FUSE                             | :x:                |
| ADC                                | :x:                |
| DAC                                | :no_entry_sign:    |
| MCPWM                              | :x:                |
| LEDPWM                             | :x:                |
| PCNT                               | :x:                |
| TRNG                               | :x:                |
| LCD                                | :x:                |
| WATCHDOG                           | :x:                |
| LOW POWER (Light Sleep)            | :x:                |
| LOW POWER (Deep Sleep)             | :x:                |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :x:                |
| USB CDC                            | :x:                |
| ETH MAC                            | :x:                |
| SDHC                               | :x:                |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :x:                |
| I2S                                | :x:                |
| LP CPU                             | :x:                |
| SMP                                | :x:                |
| AMP                                | :x:                |
| FLASH ENCRYPTION                   | :x:                |
| SecureBoot V2                      | :x:                |
| DFS                                | :x:                |
| OPENOCD                            | :x:                |
| MCUBOOT (Zephyr port)              | :x:                |
| MCUBOOT (Espressif port)           | :x:                |
  {{% /tab %}}
  {{% tab name="ESP32-P4" %}}
| Peripheral / Subsystem             | Status             |
|:-----------------------------------|:------------------:|
| Chip Revision (minimum)            | :x:                |
| Chip Revision (current)            | :x:                |
| CPU                                | :x:                |
| IRQ                                | :x:                |
| TIMERS                             | :x:                |
| UART                               | :x:                |
| I2C                                | :x:                |
| SPI                                | :x:                |
| SPI FLASH                          | :x:                |
| SPI RAM                            | :x:                |
| Cryptography                       | :x:                |
| Wi-Fi                              | :no_entry_sign:    |
| Bluetooth                          | :no_entry_sign:    |
| Bluetooth Mesh                     | :no_entry_sign:    |
| IEEE802.15.4                       | :no_entry_sign:    |
| DMA                                | :x:                |
| GPIO                               | :x:                |
| TWAI                               | :x:                |
| E-FUSE                             | :x:                |
| ADC                                | :x:                |
| DAC                                | :no_entry_sign:    |
| MCPWM                              | :x:                |
| LEDPWM                             | :x:                |
| PCNT                               | :x:                |
| TRNG                               | :x:                |
| LCD                                | :x:                |
| WATCHDOG                           | :x:                |
| LOW POWER (Light Sleep)            | :x:                |
| LOW POWER (Deep Sleep)             | :x:                |
| LOW POWER (Peripherals)            | :x:                |
| RTC                                | :x:                |
| USB OTG                            | :x:                |
| USB CDC                            | :x:                |
| ETH MAC                            | :x:                |
| SDHC                               | :x:                |
| SDIO (slave)                       | :x:                |
| CAMERA                             | :x:                |
| I2S                                | :x:                |
| LP CPU                             | :x:                |
| SMP                                | :x:                |
| AMP                                | :x:                |
| FLASH ENCRYPTION                   | :x:                |
| SecureBoot V2                      | :x:                |
| DFS                                | :x:                |
| OPENOCD                            | :x:                |
| MCUBOOT (Zephyr port)              | :x:                |
| MCUBOOT (Espressif port)           | :x:                |
  {{% /tab %}}
{{< /tabs >}}
