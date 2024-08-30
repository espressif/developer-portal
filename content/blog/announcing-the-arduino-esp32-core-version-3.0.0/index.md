---
title: Announcing the Arduino ESP32 Core version 3.0.0
date: 2023-11-01
showAuthor: false
authors: 
  - pedro-minatel
---
[Pedro Minatel](https://medium.com/@minatel?source=post_page-----3bf9f24e20d4--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fea25448e3ab5&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fannouncing-the-arduino-esp32-core-version-3-0-0-3bf9f24e20d4&user=Pedro+Minatel&userId=ea25448e3ab5&source=post_page-ea25448e3ab5----3bf9f24e20d4---------------------post_header-----------)

--

*Espressif Systems is announcing the new release of the Arduino ESP32 core including support for the ESP32-C6 and ESP32-H2 with the most recent ESP-IDF 5.1*

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*mbgPJ15qOdlVhVdIjEtyjg.png)

Back in September 2021, Arduino ESP32 Core version 2.0.0 was announced and introduced the support for the ESP32-S2, ESP32-S3 (in a later release) and ESP32-C3. This release was a huge milestone for the community not only because of the new SoCs (System on Chips) support but also because of the new era for the project, including an enormous number of new features, bug fixes, new examples, drivers, and the core documentation in 14 releases, 800 commits have been added by 88 contributors after the 2.0.0 release.  Since the Arduino ESP32 core version 2.0.0, new chips became available, and new features are now needed to keep and improve the developer’s experience and the integration with Arduino IDE (Integrated Development Environment). To continue with the remarkable success of version 2.0.0, the Arduino ESP32 core team is working hard in cooperation with the community to not stop making history.

Now it is time to announce the Arduino ESP32 Core major version 3.0.0 release with new SoC’s support (now including support for ESP32-C6 and ESP32-H2), API improvements and breaking changes.

## __ESP32-C6__ 

Announced in 2022, this new SoC from the C-series introduced the Wi-Fi 6 and the 802.15.4.

> A low-power and cost-effective 2.4 GHz Wi-Fi 6 + Bluetooth 5 (LE) + Thread/Zigbee SoC, with a 32-bit RISC-V core, for securely connected devices.

[ESP32-C6 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c6_datasheet_en.pdf).

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*JrRxjETeNIigmHjxXYV0vg.png)

## __ESP32-H2__ 

This new SoC from the new H-series is the latest 802.15.4 (Thread and Zigbee) with Bluetooth, however, this time without Wi-Fi connectivity.

> Espressif’s IEEE 802.15.4 + Bluetooth 5 (LE) SoC, powered by a 32-bit RISC-V core, designed for low power and secure connectivity.

[ESP32-H2 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-h2_datasheet_en.pdf).

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*wwwnZDR93saoXJlfx_YZvw.png)

## __Moving from 2.0.X version to 3.0.0__ 

The new Arduino ESP32 core is still under development, however, you can test the development version.

Since this is a development version, you might encounter some issues. You can report them to Arduino ESP32 GitHub issue tracker.

The expected stable release of the latest version is December 2023 and the 2.0.x will be under support maintenance until July 2024 then will be discontinued.

Some of the major changes in version 3.0.0 are related to APIs. The changes include the updated examples to be compatible with the new APIs.

Make sure to review and test your application. To help the migration from the Arduino ESP32 core 2.0.x to 3.0.0, we prepared a guide that will assist you with the migration process. Here is the [Migration Guide](https://docs.espressif.com/projects/arduino-esp32/en/latest/migration_guides/migration_guides.html).

If you want to see all the changes in the development release alpha, here is the [full change log](https://github.com/espressif/arduino-esp32/releases/tag/3.0.0-alpha1).

## __Major Changes from the 2.0.x to 3.0.0__ 

Here are the major changes from version 2.0.x to 3.0.0.

## __Peripheral Manager__ 

The Peripheral Manager was created to help users and avoid peripheral configuration with GPIOs mistakes. This new functionality will be transparent to the user; however, it will warn the user about the current peripheral configuration.

Manages the peripherals initialization and avoid common issues like:

- Same GPIO being used on two peripherals at the same time
- Restricted GPIOs being used on some other peripherals, like FLASH and PSRAM

And also:

- Prints the report after the initialization to show all peripherals being used
- Helps on the peripheral management on different ESPs families

Some ESPs have a different number of peripherals, channels, and limits.

For example, if you configure the GPIO18 for the SPI peripheral and then after the SPI initialization you set the same GPIO18 for the RMT peripheral, the SPI will be deinitialized.

The Peripheral Manager prints in the Verbose Debug Level, a full report including chip information, memory allocation, partitions, software information, board details, and the GPIO mapping. Here is an example of the Peripheral Manager report when the following peripherals are initialized:

```

ESP-ROM:esp32c3-api1-20210207
Build:Feb  7 2021
rst:0x1 (POWERON),boot:0xc (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:1
load:0x3fcd5820,len:0x458
load:0x403cc710,len:0x814
load:0x403ce710,len:0x2878
entry 0x403cc710
=========== Before Setup Start ===========
Chip Info:
------------------------------------------
  Model             : ESP32-C3
  Package           : 0
  Revision          : 3
  Cores             : 1
  Frequency         : 160 MHz
  Embedded Flash    : No
  Embedded PSRAM    : No
  2.4GHz WiFi       : Yes
  Classic BT        : No
  BT Low Energy     : Yes
  IEEE 802.15.4     : No
------------------------------------------
INTERNAL Memory Info:
------------------------------------------
  Total Size        :   341480 B ( 333.5 KB)
  Free Bytes        :   312940 B ( 305.6 KB)
  Allocated Bytes   :    24960 B (  24.4 KB)
  Minimum Free Bytes:   312940 B ( 305.6 KB)
  Largest Free Block:   294900 B ( 288.0 KB)
------------------------------------------
Flash Info:
------------------------------------------
  Chip Size         :  4194304 B (4 MB)
  Block Size        :    65536 B (  64.0 KB)
  Sector Size       :     4096 B (   4.0 KB)
  Page Size         :      256 B (   0.2 KB)
  Bus Speed         : 80 MHz
  Bus Mode          : QIO
------------------------------------------
Partitions Info:
------------------------------------------
                nvs : addr: 0x00009000, size:    20.0 KB, type: DATA, subtype: NVS
            otadata : addr: 0x0000E000, size:     8.0 KB, type: DATA, subtype: OTA
               app0 : addr: 0x00010000, size:  1280.0 KB, type:  APP, subtype: OTA_0
               app1 : addr: 0x00150000, size:  1280.0 KB, type:  APP, subtype: OTA_1
             spiffs : addr: 0x00290000, size:  1408.0 KB, type: DATA, subtype: SPIFFS
           coredump : addr: 0x003F0000, size:    64.0 KB, type: DATA, subtype: COREDUMP
------------------------------------------
Software Info:
------------------------------------------
  Compile Date/Time : Nov  2 2023 10:06:48
  Compile Host OS   : windows
  ESP-IDF Version   : v5.1.1-577-g6b1f40b9bf-dirty
  Arduino Version   : 3.0.0
------------------------------------------
Board Info:
------------------------------------------
  Arduino Board     : ESP32C3_DEV
  Arduino Variant   : esp32c3
  Arduino FQBN      : esp32:esp32:esp32c3:JTAGAdapter=default,CDCOnBoot=default,PartitionScheme=default,CPUFreq=160,FlashMode=qio,FlashFreq=80,FlashSize=4M,UploadSpeed=921600,DebugLevel=debug,EraseFlash=none
============ Before Setup End ============
[   380][I][esp32-hal-i2c.c:99] i2cInit(): Initialising I2C Master: sda=8 scl=9 freq=100000
=========== After Setup Start ============
INTERNAL Memory Info:
------------------------------------------
  Total Size        :   341480 B ( 333.5 KB)
  Free Bytes        :   314976 B ( 307.6 KB)
  Allocated Bytes   :    22508 B (  22.0 KB)
  Minimum Free Bytes:   312360 B ( 305.0 KB)
  Largest Free Block:   286708 B ( 280.0 KB)
------------------------------------------
GPIO Info:
------------------------------------------
                  8 : I2C_MASTER
                  9 : I2C_MASTER
                 20 : UART_RX
                 21 : UART_TX
============ After Setup End =============
```

## __ESP-IDF 5.1__ 

The Arduino ESP32 core 3.0.0 is based on the ESP-IDF 5.1 which includes the support for the new SoCs (ESP32-C6 and ESP32-H2). This version also brings new features that could be implemented on the following versions without the need to update the ESP-IDF core like the 802.15.4 features.

## __SPI Ethernet Support__ 

From now on, the SPI Ethernet is supported with the ESP-IDF SPI library and Arduino SPI. This new support includes the W5500, DM9051 and the KSZ8851SNL Ethernet ICs.

## __New I2S Library__ 

The new I2S library has been added based on the ESP-IDF API.

## __Wake Word and Command Recognition (ESP32-S3 only)__ 

Based on the ESP-SR, the ESP32-S3 will support voice recognition, being capable of wake word and command recognition.

## __TensorFlowLite Micro support__ 

TensorFlow is now supported, and examples were added.

## __Improved APIs__ 

The APIs improved includes:

- ADC
- BLE
- I2S
- LEDC
- RMT
- SigmaDelta
- Timer
- UART (HardwareSerial)

Deprecated: The Hall Sensor is no longer supported.

## __New boards added__ 

New boards have been added, including from [Adafruit](https://www.adafruit.com/), [Arduino.cc](https://www.arduino.cc/), [M5Stack](https://m5stack.com/), [LILYGO](https://www.lilygo.cc), and many others.

## __How to Install the development version of the Arduino ESP32 Core__ 

To install the development version of Arduino ESP32 Core on the Arduino IDE, you can follow the installation instructions in our [documentation](https://docs.espressif.com/projects/arduino-esp32/en/latest/installing.html).  Development release link for Arduino IDE:

```
https://espressif.github.io/arduino-esp32/package_esp32_dev_index.json
```

## __Keep Updated__ 

If you want to keep updated about the Arduino ESP32 Core development releases, you can follow us on GitHub, Gitter channel or participate in our monthly community meetings.

- [GitHub Repository](https://github.com/espressif/arduino-esp32)
- [Gitter](https://app.gitter.im/#/room/#espressif_arduino-esp32:gitter.im)
- [Community Meetings](https://github.com/espressif/arduino-esp32/discussions/categories/monthly-community-meetings)

__A special thank you to all our community that motivated us to keep improving the Arduino ESP32 core support!__
