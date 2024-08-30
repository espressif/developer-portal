---
title: Arduino for ESP32-S2 and ESP32-C3 is coming!
date: 2021-06-08
showAuthor: false
authors: 
  - pedro-minatel
---
[Pedro Minatel](https://medium.com/@minatel?source=post_page-----f36d79967eb8--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fea25448e3ab5&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Farduino-for-esp32-s2-and-esp32-c3-is-coming-f36d79967eb8&user=Pedro+Minatel&userId=ea25448e3ab5&source=post_page-ea25448e3ab5----f36d79967eb8---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*jQ1CQP5rXCijH1fW7r3yUw.png)

> This tutorial was created based on the Arduino for ESP32 version 2.0.0-alpha1 (preview version) on April 30th, 2021.

If you were waiting for the ESP32-S2 and ESP32-C3 support for Arduino, you will soon have it!

Few days ago, we released the preview support for the S2 and C3. This is still a work in progress, but we will let you have some early access to both chips.

The ESP32-S2 was released in the end of 2019 and it’s the first ESP32 with USB support. To see more details about the S2, see this [datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-s2_datasheet_en.pdf).

At end of 2020, ESP32-C3 was announced to be [Espressif’s](https://www.espressif.com) first RISC-V SoC and soon will be ready for shipment to developers, customers and distributors all over the world.

This means that most of you will receive the new ESP32-C3 and it will be already supported in the Arduino framework!

The Arduino core for the ESP32 version 2.0.0 is a huge milestone for the community, not only for the new chip support but also due to the upgrade in the [ESP-IDF](https://idf.espressif.com/) (running under the hood of the Arduino framework). This adds new functionalities that can be added to the Arduino framework as well as a possibility to get future support to the ESP32-S3 faster than the ESP32-S2.

For now, we are offering the preview version. Some work is still in progress to fully support these new chips. We will get everything working smoothly in the near future with the help of our community!

You can track all work in progress by following our GitHub repository. If you find any issue or missing functionality, don’t hesitate to create a new issue!

[espressif/arduino-esp32If you want to test ESP32-S2 and/or ESP32-C3 through the board manager, please use the development release link…github.com](https://github.com/espressif/arduino-esp32?source=post_page-----f36d79967eb8--------------------------------)

See “[how to contribute](https://github.com/espressif/arduino-esp32/blob/master/CONTRIBUTING.rst)” for more details on how to help us to improve.

## New Supported SoC

## ESP32-S2

> ESP32-S2 is a highly integrated, low-power, single-core Wi-Fi Microcontroller SoC, designed to be secure and cost-effective, with a high performance and a rich set of IO capabilities.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*3i4s48Ad12cpX8jwjwQzoQ.png)

To learn more about the ESP32-S2, click [here](https://www.espressif.com/en/products/socs/esp32-s2)!

## ESP32-C3

> ESP32-C3 is a single-core Wi-Fi and Bluetooth 5 (LE) microcontroller SoC, based on the open-source RISC-V architecture. It strikes the right balance of power, I/O capabilities and security, thus offering the optimal cost-effective solution for connected devices. The availability of Wi-Fi and Bluetooth 5 (LE) connectivity not only makes the device’s configuration easy, but it also facilitates a variety of use-cases based on dual connectivity.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*cQSbiHcVeiib4zhOXMzBmA.png)

To learn more about the ESP32-C3, click [here](https://www.espressif.com/en/products/socs/esp32-c3)!

## __How to Get Started?__ 

If you want to try this new version, you just need to update your ESP32-Arduino install by following these steps.

First, go to our GitHub repository: [arduino-esp32](https://github.com/espressif/arduino-esp32)

__For Arduino IDE < 2.0__ 

If you are using the Arduino IDE < 2.0, you can install or update using these steps:

__File → Preferences__ 

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*53rlcy8SaOmKsTo3TzuHyA.png)

Add the “[__https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_dev_index.json__ ](https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_dev_index.json)”to Additional Boards Manager URLs and click OK.

To install it, go to __Tools → Boards → Boards Manager__  and you will find the __“esp32” by Espressif Systems__  in the list.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*-CWWOAwW2jriAN4lefpF6g.png)

Be sure to select the version 2.0.0-alpha1.

If the version 2.0.0 isn’t in the list, update the JSON link in the “Additional Boards Manager URLs” and restart the Arduino IDE.

__For the Arduino IDE 2.0:__ 

The process for the Arduino IDE 2.0 is very similar to the early version.

__File → Preferences__ 

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*oYAQjRsku_EcaWP1jfAKRA.png)

Add the “[__https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_dev_index.json__ ](https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_dev_index.json)” to Additional Boards Manager URLs and click OK.

To install it, go to __Tools → Boards → Boards Manager__  and you will find the __“esp32” by Espressif Systems__  in the list.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*3hkEYwMazLXYfX-otKSD3g.png)

You can finally start using the ESP32-S2 and ESP32-C3 SoC with Arduino!

__Conclusion__ 

We are all excited with this preview version release to give you the chance to try our new chips using Arduino.

Additionally, your feedback is very important! We are looking forward to hearing from you. Let us know how we can improve the development experience.
