---
title: ESP32-C2 and Why It Matter-s
date: 2022-04-18
showAuthor: false
authors: 
  - teo-swee-ann
---
[Teo Swee Ann](https://medium.com/@teosweeann_65399?source=post_page-----bcf4d7d0b2c6--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F4c3c8300aca5&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp32-c2-and-why-it-matter-s-bcf4d7d0b2c6&user=Teo+Swee+Ann&userId=4c3c8300aca5&source=post_page-4c3c8300aca5----bcf4d7d0b2c6---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*XNuruOnvm_geYSCEbvfTJw.jpeg)

As many would have heard, Shanghai is now undergoing a major lockdown and quarantine due to COVID-19. In the midst of this lockdown, we received our production wafers of ESP32-C2, and proceeded with the verifications. Due to the quarantine, we have faced some logistics problems, but slowly, we have improvised, worked out solutions and continue to move ahead with the ramp up of this product. And thanks to Espressifers from Brazil, Czech Republic, India and Singapore, the integration of ESP32-C2 into ESP-IDF and ESP-RainMaker continues at full speed.

## ESP32-C2 and Why It Matter-s

ESP32-C2 is a combo WiFi-BLE chip that was conceived middle of last year, at the start of the Great Semiconductor Supply Shortage, which to a certain extent, persists till today. Hence, one of the most important goals of the chip is to reduce its silicon area and the flash size requirement. In short, this chip targets simple high volume, low data rate IoT applications such as smart plugs and light bulbs.

After almost a year, the result is a chip in a 4mm x 4mm package, supporting WiFi 4 + BLE 5.0 with 272 kB of memory and runs ESP-IDF and frameworks such as ESP-Jumpstart and ESP-RainMaker. The ROM code is optimized to reduce the need for flash. ESP-IDF is Espressif’s open-source real-time operating system for embedded IOT devices that now runs on more than 700 million devices. It is supported by Espressif and the community for all ESP32 chips.

__So, if you need a small, simple, cheap, robust WiFi connection added to your application, ESP32-C2 is it. Besides, ESP32-C2 also continues to have the required security features such as secure boot and flash encryption, and provides hardware root-of-trust for the applications.__ 

## RF Performance

One of the unintended side effects (positive) of this design is that the smaller package and chip enhance the RF performance due to reduced stray parasitics.

ESP32-C2 can transmit 802.11N MC7 packets (72.2 Mbps) with 18 dBm output power. It transmits at the full 20 dBm FCC limit for the lower data rates. The typical receiver sensitivity is between -97 to -100 dBm for 1 Mbps 802.11B packets. The receive current is 58 mA.

Routers usually have better transmitters than the client devices (referring to the devices connecting to the routers). However, in the case of ESP32-C2, the client devices can transmit as much output power as the router. (We are not talking about the multi-antenna ones.) For most client devices, the output power of 20 dBm is only supported for the low data rate modes, but for ESP32-C2, it is supported for some of the high data rates, and hence reduces the transmission time and improves the overall connection quality in the situation when you have more devices.

> The maximum distance is determined by the maximum power that the device can transmit, or is allowed to transmit, at the lowest data rate, i.e., 20 dBm at 802.11B 1 Mbps (usually 19.5 dBm or sometimes even lower to have some margins for FCC certification). If your application needs to maximize the physical distance, as with most applications, check out the receive sensitivity and transmit power at 802.11B 1 Mbps of the parts that you are using. ESP32-C2 is at the limits of what is allowed.

Besides physical distance, larger bandwidths are helpful if you are targeting applications related to audio.

(Incidentally, the improvements to the RF performance are also inherited by ESP32-C6, which is a WiFi-6 + BLE 5.2 IOT chip that is to be commercially available in late Q3/early Q4.)

## The Matter Standard

The Matter standard is designed to run on any network stacks that support IP. In the soon-to-be-released Matter 1st release, it supports WiFi, Thread, and Ethernet protocols.

The following are the pros and cons of using Matter WiFi vs. Matter Thread:

__WiFi Pros__ 

- Low latency, high throughput
- Most supported due to the high availability of WiFi routers

__WiFi Cons__ 

- High power consumption, hard to support battery power
- Without additional mesh protocol, the network is limited in scale and to only one hop

__Thread Pros__ 

- Low power, support battery power
- Supports mesh network (up to 250 devices)

__Thread Cons__ 

- We need a Thread border router to function. And we still need WiFi connectivity (or some other form of network connectivity).
- Low throughput, high latency

Since WiFi is widely available in most places, the migration of existing WiFi-based devices to the Matter WiFi standard will most likely drive a large part of the early adoption of the Matter standard.

For this reason, ESP32-C2, which is a low-cost WiFi chip supporting the Matter standard, matters.

## How Do I Get Started?

For ESP32-C2 samples, you can contact Espressif at sales@Espressif.com.

For other products, you can browse the list of available development kits and modules available from [https://www.espressif.com/en/products/devkits](https://www.espressif.com/en/products/devkits) and [https://www.espressif.com/en/products/modules](https://www.espressif.com/en/products/modules).

For information about ESP-IDF, do visit:

- __English__ : [https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html)
- __Chinese__ : [https://docs.espressif.com/projects/esp-idf/zh_CN/latest/esp32/get-started/index.html](https://docs.espressif.com/projects/esp-idf/zh_CN/latest/esp32/get-started/index.html)
- __Code__ : [https://github.com/espressif/esp-idf](https://github.com/espressif/esp-idf)
