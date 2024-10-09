---
title: "ESP-Jumpstart"
date: 2019-05-12
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kedar-sovani
tags:
  - Product Development
  - IoT
  - ESP32
---

[ESP-Jumpstart](https://docs.espressif.com/projects/esp-jumpstart/en/latest/index.html) (GitHub [repository](https://github.com/espressif/esp-jumpstart)) is a production-ready, easy-to-customise firmware template that you can use to jumpstart your product development with ESP32 / ESP8266. ESP-Jumpstart builds a fully functional, ready to deploy “Smart Power Outlet” in a sequence of incremental tutorial steps.

Along with the ESP32 / ESP8266 firmware, ESP-Jumpstart includes phone applications(iOS/Android) for network configuration, and integrated with cloud agents (currently AWS IoT) to synchronise device state with the cloud.

ESP-Jumpstart implements a power outlet with the following functionality:
- Allows and end-user to configure their home Wi-Fi network through phone applications (iOS/Android)
- Switch on or off the GPIO output
- Use a push-button to physically toggle this output
- Allow remote control of this output through a cloud
- Implement over-the-air (OTA) firmware upgrade
- Perform Reset to Factory settings on long-press of the push-button

{{< figure
    default=true
    src="img/jumpstart-1.webp"
    >}}

You can easily customise ESP-Jumpstart to convert it into your particular product by only writing your device drivers, and adapting the cloud agent accordingly. Everything else is already included.

{{< figure
    default=true
    src="img/jumpstart-1.webp"
    >}}

Head over to the [ESP-Jumpstart](https://docs.espressif.com/projects/esp-jumpstart/en/latest/index.html) documentation and get started.