---
title: ESP32-S2 Is Here!
date: 2020-03-10
showAuthor: false
authors: 
  - teo-swee-ann
---
[Teo Swee Ann](https://medium.com/@teosweeann_65399?source=post_page-----104a5173e2b3--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F4c3c8300aca5&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp32-s2-is-here-104a5173e2b3&user=Teo+Swee+Ann&userId=4c3c8300aca5&source=post_page-4c3c8300aca5----104a5173e2b3---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*yTO0fPa2qE1E16PFNRPBpw.png)

## Why Is ESP32-S2 Significant?

We launched the ESP32-S2 chip and we are excited to announce that it is in mass production now. Personally, I think it’s a big thing; it’s something we have been working for, for many years: a Wi-Fi enabled MCU targeting connected low-cost low-power interactive sensors with these features:

All these features add up to be a self-contained small form factor connected interactive secure computing and sensor device with a small LCD, such as a thermostat or a smart light switch.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*9icAP0oRYK8HMsgD3EZf8Q.png)

## Radio

Transmit power on the client device is central to the quality of the wireless connection. Most routers have large linear amplifiers, while IOT client devices have more limitations on output power range.

ESP32-S2 transmits at the maximum output power level while meeting the stringent spectral mask requirements.

ESP32-S2 also has leading receiver sensitivity of -97 dBm. With the combination receive sensitivity and output power, the customer is guaranteed the best possible user experience for Wi-Fi connectivity.

Importantly ESP32-S2 maintains this performance from -40°C to 105°C facilitating the applications such as light bulbs and industrial sensors.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*Yqb1qBzrDWDyuU-wHRgmEg.jpeg)

## GPIOs (Lots Of It)

__ESP32-S2__ has 43 programmable GPIOs with all the standard peripheral support including USB-OTG. These standard peripheral enable different sensors and actuators interfacing. 14 IO pins can be configured for capacitive touch sense. This paired with available LCD interface can enable HMI interface for your devices. Availability of audio interfaces and sufficient compute power and memory expandability allows building streaming media solutions.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*o4VD_J2xZGwIt5unSDciZw.jpeg)

## Touch Sensors and HMI

Based on ESP32-S2, the highly-integrated kit provides an easy-to-use platform to develop HMI solutions with touch screen displays for use across a wide range of industrial and building automation, simplistic designs with touch pad and basic LED indicator screens or a more complex HMI systems with touchscreen and other features. ESP32-S2 touch sensors are able to withstand harsh environments and are resistant to dust, water, moisture. We can envision these type of devices used to improve the communication among various types of equipment throughout the facility benefiting in operation, safety and productivity.

## Security

With tiny MCU based devices becoming frontline soldiers of the IOT revolution, their security becomes an important aspect. The target attack surface is wide given the fact that these devices become first class citizens of the internet using standard communication protocols. ESP32-S2 supports secure boot and flash encryption with standard cryptographic protocols. RSA based secure boot ensures that only trusted software executes on the chip. AES-XTS based flash encryption ensures that the sensitive configuration data and application remain encrypted on the flash. In addition the cryptographic accelerators provide TLS connectivity with cloud servers with strongest cipher suites without any performance impact. It also comes with a high tolerance to physical fault injection attacks. You can find more information about these security features [here](https://medium.com/the-esp-journal/esp32-s2-security-improvements-5e5453f98590).

## ESP-IDF SDK

[ESP-IDF](https://github.com/espressif/esp-idf) is Espressif’s open source RTOS based SDK that is already being used in millions of deployed products. The same SDK continues to supports ESP32-S2. Availability of commonly required software components and rich tooling makes it easy to develop and maintain your application firmware. It implements easy to use Wi-Fi network provisioning protocols, cloud support and over the air (OTA) software upgrades. [ESP-Jumpstart](https://docs.espressif.com/projects/esp-jumpstart/en/latest/introduction.html) running on ESP32-S2 offers a step-by-step production quality application reference for the developers. ESP-Rainmaker provides a quick way to realise production quality cloud connected devices.

## Camera Support

ESP32-S2 provides an 8/16 bit DVP camera interface that supports a maximum clock frequency of 40 MHz. Also, the DMA bandwidth is optimized for transferring high resolution images.

We imagine that ESP32-S2 can be widely used in various IoT applications. It is suitable for variety of smart-home devices, industrial wireless control, wireless monitoring, wireless QR code scanners, wireless positioning systems and many other IoT applications. As always, we remain open to your valuable feedback.

## Available Documentation

- [*ESP32-S2 Datasheet*](https://www.espressif.com/sites/default/files/documentation/esp32-s2_datasheet_en.pdf)
- [ESP32-S2 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-s2_technical_reference_manual_en.pdf)
