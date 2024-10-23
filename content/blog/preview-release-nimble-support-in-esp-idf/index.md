---
title: "Preview Release: NimBLE support in ESP-IDF"
date: 2019-03-19
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - hrishikesh-dhayagude
tags:
  - Bluetooth
  - Esp32
  - IoT

---
ESP-IDF now supports Apache Mynewt NimBLE host stack which is ported for the ESP32 platform and FreeRTOS. NimBLE is an open-source Bluetooth Low Energy (BLE) or Bluetooth Smart stack (both host and controller) fully compliant with Bluetooth 5 specifications and with support for BLE Mesh. More details can be found here: [https://mynewt.apache.org/](https://mynewt.apache.org/). NimBLE, being BLE only, is a footprint optimised stack and can be used in a variety of applications involving BLE.

The NimBLE preview release is made available on ESP-IDF Github: <https://github.com/espressif/esp-idf/>

A few examples, ported from the NimBLE repository, can be found here: [examples/bluetooth/nimble](https://github.com/espressif/esp-idf/)

The porting layer is kept cleaner by maintaining all the existing APIs of NimBLE along with a single ESP-NimBLE API for initialisation, making it simpler for the application developers. The documentation of NimBLE APIs can be found at: [https://mynewt.apache.org/](https://mynewt.apache.org/)
