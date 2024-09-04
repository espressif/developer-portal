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

ESP-IDF v5.4, currently in development, will include preview support for the early samples of the ESP32-C61, and ESP-IDF v5.4.x will include the initial support for the mass production version of ESP32-C61.

If you have an issue to report about any of the ESP32-C61 features, please create an issue in [ESP-IDF GitHub issue tracker](https://github.com/espressif/esp-idf/issues).

### Bluetooth Low Energy (BLE)

- :hourglass_flowing_sand: BLE Light Sleep (IDF-10366)
- :hourglass_flowing_sand: Bluetooth 5 Controller (Bluetooth 5.3 Certified) (IDF-10363)
- :hourglass_flowing_sand: ESP-BLE-MESH (IDF-10364)
- :hourglass_flowing_sand: ESP-Bluedroid Host (IDF-10360)
- :hourglass_flowing_sand: ESP-NimBLE Host (IDF-10365)
- :hourglass_flowing_sand: HCI (IDF-10362)

### Coexistence

- :hourglass_flowing_sand: Coexistence of Wi-Fi and Bluetooth (IDF-10532)
- :hourglass_flowing_sand: External coexistence follower mode (IDF-10533)
- :hourglass_flowing_sand: External coexistence leader mode (IDF-10531)

### Debugging tools

- :hourglass_flowing_sand: OpenOCD (IDF-10747)

### Low Power System

- :hourglass_flowing_sand: Low-power Timer (IDF-9244)
- :hourglass_flowing_sand: Low-power Watchdog Timer (IDF-9243)

### Peripherals

- ADC
  - :hourglass_flowing_sand: ADC Calibration (IDF-9303)
  - :hourglass_flowing_sand: ADC continuous mode driver (IDF-9302)
    - ADC continuous mode digital monitor
  - :hourglass_flowing_sand: ADC oneshot mode driver (IDF-9304)
  - :hourglass_flowing_sand: ADC sleep retention (IDF-10376)
- :hourglass_flowing_sand: Clock Output (IDF-10970)
- DMA (Direct Memory Access)
  - :white_check_mark: GDMA
- :white_check_mark: Dedicated GPIO driver
- Ethernet driver
  - :hourglass_flowing_sand: SPI Ethernet driver (IDF-9298)
- :hourglass_flowing_sand: Event Task Matrix (IDF-9295)
  - :hourglass_flowing_sand: ETM sleep retention (IDF-10373)
- :white_check_mark: GPIO driver
  - :hourglass_flowing_sand: GPIO ETM (IDF-9318)
  - :hourglass_flowing_sand: GPIO sleep retention (IDF-10382)
  - Hysteresis
  - :hourglass_flowing_sand: RTC IO (LP IO) driver (IDF-9317)
- GPSPI
  - :hourglass_flowing_sand: GPSPI sleep retention (IDF-10375)
  - :white_check_mark: [SPI Master driver](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c61/api-reference/peripherals/spi_master.html)
  - :white_check_mark: SPI Slave HD driver
  - :white_check_mark: SPI Slave driver
- :white_check_mark: GPTimer driver
  - :hourglass_flowing_sand: GPTimer sleep retention (IDF-10377)
- I2C
  - :white_check_mark: I2C master driver
  - :white_check_mark: I2C slave driver
  - :hourglass_flowing_sand: I2C sleep retention (IDF-10374)
- I2S
  - :hourglass_flowing_sand: I2S driver (IDF-9312)
    - I2S PDM tx mode
    - I2S STD mode
    - I2S TDM mode
  - :hourglass_flowing_sand: I2S legacy driver (IDF-9313)
  - :hourglass_flowing_sand: I2S sleep retention (IDF-10381)
- LCD driver
  - :hourglass_flowing_sand: I2C LCD driver (IDF-10971)
  - :hourglass_flowing_sand: SPI LCD driver (IDF-9309)
- :white_check_mark: LEDC driver
  - Gamma Curve Generation
  - :hourglass_flowing_sand: LEDC sleep retention (IDF-10372)
- PSRAM
  - :white_check_mark: .bss/.noinit PSRAM
  - :white_check_mark: PSRAM Device Driver
  - :hourglass_flowing_sand: XIP PSRAM (IDF-9292)
- SD/SDIO/MMC driver
  - :hourglass_flowing_sand: SDSPI Host driver (IDF-9305)
- :hourglass_flowing_sand: SPI Flash driver (IDF-9314)
- Systimer driver
  - :hourglass_flowing_sand: Esptimer implementation over systimer (IDF-9308)
  - :hourglass_flowing_sand: OS tick port over systimer (IDF-9307)
  - :hourglass_flowing_sand: Systimer sleep retention (IDF-10378)
- :hourglass_flowing_sand: Temperature Sensor driver (IDF-9322)
  - :hourglass_flowing_sand: Temp Sensor sleep retention (IDF-10385)
- UART
  - :white_check_mark: UART FIFO mode driver
  - :hourglass_flowing_sand: UART sleep retention (IDF-10384)
- :white_check_mark: USB Serial JTAG
  - :hourglass_flowing_sand: USB Serial JTAG sleep retention (IDF-10383)

### Power management

- :hourglass_flowing_sand: Auto Light Sleep (IDF-9248)
- :hourglass_flowing_sand: Deep Sleep (IDF-9245)
- :hourglass_flowing_sand: Dynamic Frequency Switch (IDF-9246)
- :hourglass_flowing_sand: Light Sleep (IDF-9247)

### Security Features

- :white_check_mark: ECC accelerator
- :white_check_mark: ECDSA driver
- :white_check_mark: Flash encryption
- :white_check_mark: RNG
- :hourglass_flowing_sand: SHA accelerator (IDF-9234)
- :white_check_mark: Secure boot

### System Features

- :hourglass_flowing_sand: Bootloader Support (IDF-9260)
- :white_check_mark: Brownout Detector
- Cache
  - :white_check_mark: Cache Driver
- :hourglass_flowing_sand: Console (IDF-9258)
- :hourglass_flowing_sand: Cxx Component (IDF-9277)
- :hourglass_flowing_sand: ESP Event (IDF-9259)
- :hourglass_flowing_sand: ESP ROM (IDF-9281)
- :hourglass_flowing_sand: ESP Ringbuffer (IDF-9266)
- :hourglass_flowing_sand: ESP Timer (IDF-9284)
- :hourglass_flowing_sand: Efuse controller driver (IDF-9282)
  - :hourglass_flowing_sand: Efuse sleep retention (IDF-10371)
- :white_check_mark: FreeRTOS
- :hourglass_flowing_sand: Interrupt Controller sleep retention (IDF-10369)
- :white_check_mark: MMU
- MSPI
  - :hourglass_flowing_sand: MSPI sleep retention (Flash & PSRAM) (IDF-10367)
  - :hourglass_flowing_sand: MSPI tuning (Flash & PSRAM DDR and/or over 80 MHz) (IDF-9256)
  - :hourglass_flowing_sand: SPI Flash auto suspend (IDF-9255)
- :hourglass_flowing_sand: POSIX Threads (IDF-9279)
- Panic Handling Features
  - :hourglass_flowing_sand: Core Dump (IDF-9268)
  - :hourglass_flowing_sand: Debug Watchpoint (IDF-9270)
  - :hourglass_flowing_sand: GDB Stub (IDF-9272)
  - :hourglass_flowing_sand: Panic Handler (IDF-9271)
  - :hourglass_flowing_sand: Stack Guard (IDF-9269)
- :hourglass_flowing_sand: Ram App (IDF-9251)
- :hourglass_flowing_sand: Watch Dog Timers (IDF-9257)
  - :hourglass_flowing_sand: Watchdog Timer sleep retention (IDF-10368)
- :hourglass_flowing_sand: app trace (IDF-9264)
- :hourglass_flowing_sand: newlib (IDF-9283)

### Thread

- :hourglass_flowing_sand: Thread Border Router (IDF-10569)

### Wi-Fi

- :hourglass_flowing_sand: 802.11ax: 20MHz-only non-AP mode (IDF-10621)
- :hourglass_flowing_sand: 802.11bgn (IDF-10632)
- :hourglass_flowing_sand: Advanced DTIM Sleep (IDF-10627)
- :hourglass_flowing_sand: BSS Color (IDF-10643)
- :hourglass_flowing_sand: CSI (Channel State Information) (IDF-10642)
- :hourglass_flowing_sand: DCM (IDF-10619)
- :hourglass_flowing_sand: DL MU-MIMO, DL MU-MIMO within OFDMA (IDF-10636)
- :hourglass_flowing_sand: DPP (Device Provisioning Protocol) (IDF-10631)
- :hourglass_flowing_sand: ESP-NOW (IDF-10624)
- :hourglass_flowing_sand: ESP-Touch v1/v2 (IDF-10625)
- :hourglass_flowing_sand: ESP-WiFi-Mesh (IDF-10622)
- :hourglass_flowing_sand: FTM (Fine Time Measurement) (IDF-10638)
- :hourglass_flowing_sand: HE ER (HE Extended Range) (IDF-10637)
- :hourglass_flowing_sand: HT40 (IDF-10629)
- :hourglass_flowing_sand: Power Save: modem sleep, light sleep (IDF-10630)
- Roaming
  - :hourglass_flowing_sand: 802.11k (Radio Measurements) (IDF-10639)
  - :hourglass_flowing_sand: 802.11r (Fast BSS Transition) (IDF-10640)
  - :hourglass_flowing_sand: 802.11v (BTM) (IDF-10641)
- :hourglass_flowing_sand: Station, SoftAP, sniffer mode (IDF-10620)
- TWT
  - :hourglass_flowing_sand: Broadcast TWT (IDF-10634)
  - :hourglass_flowing_sand: Individual TWT (IDF-10635)
- :hourglass_flowing_sand: UL/DL OFDMA (26/52/106/242 tone) (IDF-10626)
- :hourglass_flowing_sand: Wi-Fi Aware (IDF-10628)
- :hourglass_flowing_sand: Wi-Fi Security (IDF-10633)

### Zigbee

- :hourglass_flowing_sand: Zigbee Gateway (IDF-10568)


## Other Projects

If you have an issue to report about any of the ESP32-C61 features, please create an issue in the issue tracker of a respective project.

- :hourglass_flowing_sand: [ESP-AT](https://docs.espressif.com/projects/esp-at/en/latest/esp32c61/index.html) (IDF-10746)
- :hourglass_flowing_sand: [ESP-Modbus](https://docs.espressif.com/projects/esp-modbus/en/latest/esp32c61/) (IDF-10051)
