---
title: Arduino ESP32 support version 2.0.0 is out!
date: 2021-08-31
showAuthor: false
authors: 
  - pedro-minatel
---
## Arduino ESP32 support version 2.0.0 is out!

[Pedro Minatel](https://medium.com/@minatel?source=post_page-----1b4de762228e--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fea25448e3ab5&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Farduino-esp32-support-version-2-0-0-is-out-1b4de762228e&user=Pedro+Minatel&userId=ea25448e3ab5&source=post_page-ea25448e3ab5----1b4de762228e---------------------post_header-----------)

--

Arduino is definitely one of the most popular embedded development frameworks, and this popularity is mostly due to its simplicity and huge community.

This popularity is also shared with the ESP32. When the first support was introduced for the ESP8266, Espressif saw the full potential about using Arduino on the SoCs, and all the possibilities for creating IoT products as easier as before.

After all the incredible success on the ESP8266, Espressif has started the ESP32 support for Arduino. This support is based on the ESP-IDF, the official IoT Development Framework. Prior to [version 2.0.0](https://github.com/espressif/arduino-esp32/releases/tag/2.0.0), it was based on the IDF v3.3, only supporting ESP32.

Espressif is continuously expanding the ESP32 family, first introducing the ESP32-S2, the first SoC with embedded USB and Wi-Fi only and secondly the ESP32-C3, the first SoC with RISC-V architecture.

To see all ESP products, visit our product page [here](https://products.espressif.com/).

## Introducing Arduino ESP32 2.0.0

As the ESP32 family increases, it’s time to move forward and give Arduino ESP32 support for the recently introduced SoC’s.

The new version, the [2.0.0](https://github.com/espressif/arduino-esp32/releases/tag/2.0.0) (this is the Arduino ESP32 support version, and it’s not related to the Arduino IDE version 2.0.0) is based on the latest ESP-IDF development version and includes all new features and bugfix since the ESP-IDF v3.3. This is the major difference from the v1.0.6 and it’s also the reason for upgrading.

With this major update, can now support the ESP32-S2 and ESP32-C3 and in the future the ESP32-S3.

## ESP32-S2

> ESP32-S2 is a highly integrated, low-power, single-core Wi-Fi Microcontroller SoC, designed to be secure and cost-effective, with a high performance and a rich set of IO capabilities.

More about [ESP32-S2](https://docs.espressif.com/projects/arduino-esp32/en/latest/boards/ESP32-S2-Saola-1.html).

## ESP32-C3

> ESP32-C3 is a single-core Wi-Fi and Bluetooth 5 (LE) microcontroller SoC, based on the open-source RISC-V architecture. It strikes the right balance of power, I/O capabilities and security, thus offering the optimal cost-effective solution for connected devices. The availability of Wi-Fi and Bluetooth 5 (LE) connectivity not only makes the device’s configuration easy, but it also facilitates a variety of use-cases based on dual connectivity.

More about [ESP32-C3](https://docs.espressif.com/projects/arduino-esp32/en/latest/boards/ESP32-C3-DevKitM-1.html).

## Major Changes and New Features Added

This version introduces major changes since the [2.0.0-alpha1](https://github.com/espressif/arduino-esp32/tree/2.0.0-alpha1).

Some of the most important ones are:

- Support for ESP32-S2.
- Support for ESP32-C3.
- Upload over CDC.
- Support for the KSZ8081 (Ethernet PHY).
- LittleFS update for partition label and multiple partitions.
- Added support for RainMaker.
- BLE5 features for ESP32-C3 (ESP32-S3 ready).
- ESPTOOL update.
- Added FTM support.
- Online Documentation added. See [here](https://docs.espressif.com/projects/arduino-esp32/en/latest/).
- USB MSC and HID support (ESP32-S2 only).
- UART refactoring (SerialHardware).
- New examples.
- Boards added.
- Bugs fixed.

See the complete list [here](https://github.com/espressif/arduino-esp32/releases).

## How to Upgrade to v2.0.0

To install or to upgrade to version 2.0.0, see this detailed process on our [online documentation](https://docs.espressif.com/projects/arduino-esp32/en/latest/installing.html#installing).

You can also install directly from the [Arduino IDE](https://www.arduino.cc/en/software), [PlatformIO](https://platformio.org/) (supported on Windows, Linux and macOS).
