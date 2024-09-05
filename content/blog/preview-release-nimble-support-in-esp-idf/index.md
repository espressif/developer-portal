---
title: "Preview Release: NimBLE support in ESP-IDF"
date: 2019-03-19
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - hrishikesh-dhayagude
---
ESP-IDF now supports Apache Mynewt NimBLE host stack which is ported for the ESP32 platform and FreeRTOS. NimBLE is an open-source Bluetooth Low Energy (BLE) or Bluetooth Smart stack (both host and controller) fully compliant with Bluetooth 5 specifications and with support for BLE Mesh. More details can be found here: [https://github.com/apache/mynewt-nimble.](https://github.com/apache/mynewt-nimble.) NimBLE, being BLE only, is a footprint optimised stack and can be used in a variety of applications involving BLE.

The NimBLE preview release is made available on ESP-IDF Github: [https://github.com/espressif/esp-idf/tree/feature/nimble-preview](https://github.com/espressif/esp-idf/tree/feature/nimble-preview)

A few examples, ported from the NimBLE repository, can be found here: [https://github.com/espressif/esp-idf/tree/feature/nimble-preview/examples/bluetooth/nimble](https://github.com/espressif/esp-idf/tree/feature/nimble-preview/examples/bluetooth/nimble)

The porting layer is kept cleaner by maintaining all the existing APIs of NimBLE along with a single ESP-NimBLE API for initialisation, making it simpler for the application developers. The documentation of NimBLE APIs can be found at: [https://mynewt.apache.org/latest/network/docs/index.html#ble-user-guide](https://mynewt.apache.org/latest/network/docs/index.html#ble-user-guide)
