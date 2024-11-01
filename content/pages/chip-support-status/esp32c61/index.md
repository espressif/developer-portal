---
title: "ESP32-C61 support status"
date: 2024-08-29T16:40:07+08:00
draft: false
---

This page lists the projects in which the ESP32-C61 is supported.

In the list below, the supported features are marked with a checkbox (:white_check_mark:), while unsupported features are marked with an hourglass (:hourglass_flowing_sand:). An internal issue reference (such as \"IDF-1234\") is listed at the end of the feature description to help us keep this list up to date:

- :hourglass_flowing_sand: Unsupported feature (IDF-1234)
- :white_check_mark: Supported feature

This page will be periodically updated to reflect the current support status for the ESP32-C61.

{{< alert >}}
  Some links provided below might appear invalid due to being generated as placeholders for documents to be added later.
{{< /alert >}}


## ESP-IDF

According to the chip mass production plan, the planned support for ESP32-C61 in ESP-IDF v5.4 has been rescheduled to ESP-IDF v5.5. Thank you for your understanding.

- ESP-IDF v5.5, whose planned release date is June 30th 2025, will include the initial support for the mass production version of ESP32-C61.
- If you would like to try features with the early samples of the ESP32-C61, suggest to use the master branch of ESP-IDF.

If you have an issue to report about any of the ESP32-C61 features, please create an issue in [ESP-IDF GitHub issue tracker](https://github.com/espressif/esp-idf/issues).

### Bluetooth Low Energy (BLE)

- :hourglass_flowing_sand: BLE Light Sleep (IDF-10366)
- :white_check_mark: Bluetooth 5 Controller (Bluetooth 5.3 Certified)
- :white_check_mark: ESP-BLE-MESH
- :white_check_mark: ESP-Bluedroid Host
- :white_check_mark: ESP-NimBLE Host
- :white_check_mark: HCI

### Coexistence

- :white_check_mark: Coexistence of Wi-Fi and Bluetooth
- :hourglass_flowing_sand: External coexistence follower mode (IDF-10533)
- :white_check_mark: External coexistence leader mode

### Debugging tools

- :hourglass_flowing_sand: OpenOCD (IDF-10747)

### Low Power System

- :white_check_mark: Low-power Timer
- :white_check_mark: Low-power Watchdog Timer

### Peripherals

- ADC
  - :hourglass_flowing_sand: ADC Calibration (IDF-9303)
  - :hourglass_flowing_sand: ADC continuous mode driver (IDF-9302)
    - ADC continuous mode digital monitor
  - :hourglass_flowing_sand: ADC oneshot mode driver (IDF-9304)
- :hourglass_flowing_sand: Clock Output (IDF-10970)
- DMA (Direct Memory Access)
  - :white_check_mark: GDMA
- :white_check_mark: Dedicated GPIO driver
- Ethernet driver
  - :white_check_mark: SPI Ethernet driver
- :white_check_mark: Event Task Matrix
- :white_check_mark: GPIO driver
  - :hourglass_flowing_sand: Analog Comparator (IDF-11082)
  - :white_check_mark: GPIO ETM
  - Hysteresis
  - :white_check_mark: RTC IO (LP IO) driver
- GPSPI
  - :white_check_mark: [SPI Master driver](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c61/api-reference/peripherals/spi_master.html)
  - :white_check_mark: SPI Slave HD driver
  - :white_check_mark: SPI Slave driver
- :white_check_mark: GPTimer driver
- I2C
  - :white_check_mark: I2C master driver
  - :white_check_mark: I2C slave driver
- I2S
  - :white_check_mark: I2S driver
    - I2S PDM tx mode
    - I2S STD mode
    - I2S TDM mode
  - :white_check_mark: I2S legacy driver
- LCD driver
  - :white_check_mark: I2C LCD driver
  - :white_check_mark: SPI LCD driver
- :white_check_mark: LEDC driver
  - Gamma Curve Generation
- PSRAM
  - :white_check_mark: .bss/.noinit PSRAM
  - :white_check_mark: PSRAM Device Driver
  - :white_check_mark: XIP PSRAM
- SD/SDIO/MMC driver
  - :white_check_mark: SDSPI Host driver
- :white_check_mark: SPI Flash driver
  - :hourglass_flowing_sand: External flash support (IDF-11021)
- Systimer driver
  - :white_check_mark: Esptimer implementation over systimer
  - :white_check_mark: OS tick port over systimer
- :hourglass_flowing_sand: Temperature Sensor driver (IDF-9322)
- UART
  - :white_check_mark: UART FIFO mode driver
- :white_check_mark: USB Serial JTAG

### Power management

- :white_check_mark: Auto Light Sleep
- :white_check_mark: Deep Sleep
- :white_check_mark: Dynamic Frequency Switch
- :white_check_mark: Light Sleep
  - :hourglass_flowing_sand: Sleep retention (IDF-11003)

### Security Features

- :white_check_mark: ECC accelerator
- :white_check_mark: ECDSA driver
- :white_check_mark: Flash encryption
- :white_check_mark: RNG
- :white_check_mark: SHA accelerator
- :white_check_mark: Secure boot

### System Features

- :hourglass_flowing_sand: Bootloader Support (IDF-9260)
- Cache
  - :white_check_mark: Cache Driver
- :white_check_mark: Console
- :white_check_mark: Cxx Component
- :white_check_mark: ESP Event
- :white_check_mark: ESP ROM
- :white_check_mark: ESP Ringbuffer
- :white_check_mark: ESP Timer
- :white_check_mark: Efuse controller driver
- :white_check_mark: FreeRTOS
- :white_check_mark: MMU
- MSPI
  - :hourglass_flowing_sand: MSPI tuning (Flash & PSRAM DDR and/or over 80 MHz) (IDF-9256)
  - :white_check_mark: SPI Flash auto suspend
- :white_check_mark: POSIX Threads
- Panic Handling Features
  - :white_check_mark: Core Dump
  - :white_check_mark: Debug Watchpoint
  - :white_check_mark: GDB Stub
  - :white_check_mark: Panic Handler
  - :hourglass_flowing_sand: Stack Guard (IDF-9269)
- Power Supply Detector
  - :white_check_mark: Brownout Detector
- :white_check_mark: Ram App
- :white_check_mark: Watch Dog Timers
- :white_check_mark: app trace
- :white_check_mark: newlib

### Thread

- :hourglass_flowing_sand: Thread Border Router (IDF-10569)

### Wi-Fi

- :white_check_mark: 802.11ax: 20MHz-only non-AP mode
- :white_check_mark: 802.11bgn
- :white_check_mark: Advanced DTIM Sleep
- :white_check_mark: BSS Color
- :white_check_mark: CSI (Channel State Information)
- :white_check_mark: DCM
- :white_check_mark: DL MU-MIMO, DL MU-MIMO within OFDMA
- :white_check_mark: DPP (Device Provisioning Protocol)
- :white_check_mark: ESP-NOW
- :white_check_mark: ESP-Touch v1/v2
- :white_check_mark: ESP-WiFi-Mesh
- :hourglass_flowing_sand: FTM (Fine Time Measurement) (IDF-10638)
- :white_check_mark: HE ER (HE Extended Range)
- :white_check_mark: HT40
- :white_check_mark: Power Save: modem sleep, light sleep
- Roaming
  - :hourglass_flowing_sand: 802.11k (Radio Measurements) (IDF-10639)
  - :hourglass_flowing_sand: 802.11r (Fast BSS Transition) (IDF-10640)
  - :hourglass_flowing_sand: 802.11v (BTM) (IDF-10641)
- :white_check_mark: Station, SoftAP, sniffer mode
- TWT
  - :white_check_mark: Broadcast TWT
  - :white_check_mark: Individual TWT
- :white_check_mark: UL/DL OFDMA (26/52/106/242 tone)
- :hourglass_flowing_sand: Wi-Fi Aware (IDF-10628)
- :white_check_mark: Wi-Fi Security

### Zigbee

- :hourglass_flowing_sand: Zigbee Gateway (IDF-10568)


## Other Projects

If you have an issue to report about any of the ESP32-C61 features, please create an issue in the issue tracker of a respective project.

- :hourglass_flowing_sand: [ESP-AT](https://docs.espressif.com/projects/esp-at/en/latest/esp32c61/index.html) (IDF-10746)
- :white_check_mark: [ESP-Modbus](https://docs.espressif.com/projects/esp-modbus/en/latest/)
