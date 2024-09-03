---
title: Announcing ESP ZeroCode ExL Module
date: 2023-11-12
showAuthor: false
authors: 
  - amey-inamdar
---
[Amey Inamdar](https://medium.com/@iamey?source=post_page-----6f90fa89abe6--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F96a9b11b7090&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp-zerocode-exl-module-powered-by-aws-iot-expresslink-simplifying-matter-compatible-6f90fa89abe6&user=Amey+Inamdar&userId=96a9b11b7090&source=post_page-96a9b11b7090----6f90fa89abe6---------------------post_header-----------)

--

*Announcing ESP ZeroCode ExL powered by AWS IoT ExpressLink — Simplifying Matter-compatible Cloud-connected Devices*

As a part of our efforts to make the development of Matter protocol-enabled devices easy, Espressif [announced](https://www.espressif.com/en/news/ESP-ZeroCode_Modules) ESP ZeroCode modules and ESP ZeroCode Console earlier this year. These ESP ZeroCode modules are well-suited for Matter connectivity for simple devices such as lighting fixtures, switches, sockets, blind controllers, and sensors. You can use ESP ZeroCode Console to configure, evaluate, and order ESP ZeroCode modules.

In continuation of these efforts, Espressif, in collaboration with Amazon Web Services (AWS), is glad to announce the ESP ZeroCode ExL connectivity module powered by [AWS IoT ExpressLink](https://aws.amazon.com/iot-expresslink/). This module is based on Espressif’s ESP32-C6 system-on-chip (SoC) providing Wi-Fi 6, Bluetooth 5 (LE), and 802.15.4 connectivity. It contains built-in Matter and cloud connectivity software providing a simple [AT commands-based serial interface](https://docs.aws.amazon.com/iot-expresslink/latest/programmersguide/elpg.html) to the host. With such a simplified integration, you can build Matter-compliant, secure IoT devices that connect to AWS IoT Core and other AWS services.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*dXyqknrjK0PJpgNQciCICQ.png)

## Why ESP ZeroCode ExL?

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*2WVEgU33ZgPejrRPzU0Tkw.png)

- When device makers want to build cloud-connected devices, they have to write and maintain a significant amount of software. It also needs a deep understanding of connectivity, security, OTA upgrades, and device management.
- The addition of the Matter protocol adds to this making the development, maintenance, and certification even more complex. The ESP ZeroCode ExL module moves this important yet undifferentiated workload onto a separate module, allowing device makers to easily build the hardware interfacing and business logic onto the host MCU.
- On the other hand, AWS IoT ExpressLink is designed and built with the best security and cloud connectivity practices and the Espressif implementation went through rigorous security and functionality testing.

The ESP ZeroCode ExL firmware by Espressif extends the AWS IoT ExpressLink with Matter protocol implementation. This significantly reduces the efforts and time required for building and maintaining connected products by device makers.

## Target Devices

The Matter 1.2 specification adds support for new device types including appliances like refrigerators, laundry washers, air purifiers, and air conditioners. Additionally, some of the other device types are already supported such as dimmers, touch switches, and thermostats. Many of these types of devices have a dedicated MCU responsible for building the device logic. Also, cloud connectivity is a major feature for many of these device types especially in the appliance domain. ESP ZeroCode ExL offers simplified Matter and cloud connectivity for these devices and is even well-positioned for retrofitting existing designs to Matter-compliant and cloud-connected ones. It is important to note that ESP ZeroCode ExL can also enable Matter and cloud connectivity to devices beyond these types, supporting devices even with small, resource-constrained host MCUs.

## Key Features

ESP ZeroCode ExL implements AWS IoT ExpressLink specification version 1.2 and Matter protocol specification version 1.2.

## AWS IoT ExpressLink Features:

## Matter protocol features

## Security

ESP ZeroCode ExL modules are security hardened with hardware root of trust based on Secure Boot and Digital Signature Peripheral. All the sensitive data such as device identity and Wi-Fi network credentials are encrypted and secured using hardware security features such as flash encryption, digital signature peripheral, and HMAC peripheral. ESP ZeroCode ExL firmware is tested with the AWS-provided regression test suite. Communication interfaces such as Wi-Fi, BLE, and serial interface are verified against memory corruption attacks. Secure OTA ensures only the trusted firmware gets executed on the module as well as on the host. These security features add significant value and make the job of device makers significantly easier.

## Ready for Evaluation?

Espressif provides an easy evaluation through the [ESP ZeroCode Console](https://zerocode.espressif.com/) for the ESP ZeroCode ExL module. You can use any ESP32-C6 development board to quickly try out the functionality completely in the web browser. ESP ZeroCode Console supports a refrigerator, laundry washer, air conditioner, thermostat, and dimmer device types with ESP ZeroCode ExL module. We will be soon expanding on these device types.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*Dgs2Q1ONnaTm6QUVpIe_JQ.png)

If you need more information about ESP ZeroCode ExL modules, please reach out to us at [zerocode@espressif.com](mailto:zerocode@espressif.com) and we will get back to you as quickly as we can.
