---
title: June 2020
date: 2020-07-27
showAuthor: false
authors: 
  - esp-bot
---
[ESP BOT](https://medium.com/@espbot?source=post_page-----44f455db36d3--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F71611a95e5c4&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fjune-2020-44f455db36d3&user=ESP+BOT&userId=71611a95e5c4&source=post_page-71611a95e5c4----44f455db36d3---------------------post_header-----------)

--

Hi everyone,

We’ve got some exciting news for you this month! In response to our customers’ requests, we have just launched [ESP-Hosted](https://github.com/espressif/esp-hosted). This is a project which addresses our customers’ requirement to use ESP32 as a connectivity module with Linux-based host controllers.

More specifically, the ESP-Hosted project offers a way of using ESP32 as a communication processor that provides Wi-Fi and Bluetooth/BLE connectivity to the host MCU. In this context, [ESP32](https://www.espressif.com/en/products/socs/esp32/overview) provides a standard network-interface implementation for the host to receive and transmit 802.3 frames. The host can use its own TCP/IP and TLS stack above the network interface that the application uses. For Bluetooth connectivity, ESP32 provides a standard host controller interface (HCI), on which the host can run a Bluetooth host stack. Although this project does not provide a standard 802.11 interface to the host, it does provide the control path with a custom command implementation, based on Protobufs, both on the host-side and the ESP32-side.

[On our GitHub webpage](https://github.com/espressif/esp-hosted), you can get all the information about ESP-Hosted, along with the relevant diagrams and getting-started instructions. Other topics you can read about in this month’s newsletter include:

- ATOM Echo, an ESP32-based miniature programmable smart speaker by M5Stack. With ATOM Echo, you and your friends can now enjoy your favorite music everywhere!
- An ESP32-based Wi-Fi-connected espresso machine, with which you can make the most elaborate tasting coffee in the “Blynk” of an eye!
- A cool project by the Embedded Club founder, Ashok, who used ESP8266 for hacking the IR remote control of his air cooler. This project shows that you can hack pretty much any infrared remote control in the same way!

Hope you enjoy reading this month’s newsletter. Keep sending us your messages and requests on [Facebook](https://www.facebook.com/espressif/), [Twitter](https://twitter.com/EspressifSystem), [LinkedIn](https://www.linkedin.com/company/espressif-systems/), [Instagram](https://www.instagram.com/espressif_systems/) and [YouTube](https://www.youtube.com/channel/UCDBWNF7CJ2U5eLGT7o3rKog). We try to respond to all of your messages as quickly as possible!

Best wishes,John Lee.Senior Customer Support Officer

## ATOM Echo: ESP32-based Miniature Programmable Smart Speaker by M5Stack

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*29CgvGDBh4F8PK8n.png)

[M5Stack’s ATOM Echo](https://m5stack.com/collections/m5-atom/products/atom-echo-smart-speaker-dev-kit) is a tiny programmable smart speaker. It makes full use of [ESP32](https://www.espressif.com/en/products/socs/esp32/overview)’s IoT power, while the design of ATOM Echo is based on the M5ATOM series of products. Its slim design measures only 24x24x17mm, so the gadget itself can be easily carried anywhere. At the same time, its premium finish gives it a sleek appearance.

[*Keep Reading*](https://www.espressif.com/en/news/ESP32_ATOM_Echo)

## ESP32-based Wi-Fi-connected Espresso Machine

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*SL1tcv7wj1GIvkSg.png)

[Fracino](https://www.fracino.com/index.html), an award-winning UK manufacturer of cappuccino and espresso machines, chose an [ESP32](https://www.espressif.com/en/products/socs/esp32/overview)-powered mobile app for building an efficient and aesthetically pleasing solution for their client, [Londinium espresso](https://londiniumespresso.com/). The ESP32-based app, which was created by [Blynk IoT](https://blynk.io/clients/londinium-fracino-iot-connected-wifi-espresso-machine-case-study-blynk), controls all the main parameters of the espresso machine effortlessly.

[*Keep Reading*](https://www.espressif.com/en/news/ESP32_Espresso_Machine)

## Alexa-controlled Air Cooler with ESP8266

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*qOhI7iBMQraWIl0T.png)

[Ashok](https://ashokr.com/), the founder of [Embedded Club](https://www.instagram.com/embeddedclub/), a community of makers in India, focused on embedded programming / design, STEM trainings, application development and 2D/3D animations, has come up with really cool project. He hacked the remote control of an air cooler, using [ESP8266](https://www.espressif.com/en/products/socs/esp8266/overview). More importantly, though, this project demonstrates that any infrared remote control can be hacked in the same way!

[*Keep Reading*](https://www.espressif.com/en/news/ESP8266_hack)

*Originally published at *[*https://mailchi.mp*](https://mailchi.mp/75befa5646ab/espressif-esp-news-june-2020)*.*
