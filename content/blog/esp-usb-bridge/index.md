---
title: "ESP USB Bridge"
date: 2022-04-13
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - roland-dobai
tags:
  - Esp32 S2
  - USB
  - Bridge
  - Espressif

---
The [ESP USB Bridge](https://github.com/espressif/esp-usb-bridge) is an [ESP-IDF](https://github.com/espressif/esp-idf) project utilizing an ESP32-S2 (or optionally, an ESP32-S3) chip to create a bridge between a computer and a target microcontroller. It can serve as a replacement for USB-to-UART chips (e.g. CP210x).

{{< figure
    default=true
    src="img/esp-1.webp"
    >}}

ESP USB Bridge creates a composite USB device accessible from the computer when they are connected through a USB cable. The main features are the following.

- *Serial bridge*: The developer can run [esptool](https://github.com/espressif/esptool) or connect a terminal program to the serial port provided by the USB CDC. The communication is transferred in both directions between the computer and the target microcontroller through the ESP USB bridge.
- *JTAG bridge*: [openocd-esp32](https://github.com/espressif/openocd-esp32) can be run on the computer which will connect to the ESP USB Bridge. The ESP32-S2 acts again as a bridge between the computer and the target microcontroller, and transfers JTAG communication between them in both directions.
- *Mass storage device*: USB Mass storage device is created which can be accessed by a file explorer of the computer. Binaries in UF2 format can be copied to this disk and the ESP32-S2 will use them to flash the target microcontroller. Currently ESP USB Bridge is capable of flashing various Espressif microcontrollers.

More information about the project can be found on [Github](https://github.com/espressif/esp-usb-bridge). We hope it will be useful for the community. It is licensed under the Apache License Version 2.0. We welcome issue reports, feature requests and contributions on the project’s [Github page](https://github.com/espressif/esp-usb-bridge).
