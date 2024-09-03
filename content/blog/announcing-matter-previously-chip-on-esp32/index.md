---
title: Announcing Matter (previously ‘CHIP’) on ESP32
date: 2021-05-25
showAuthor: false
authors: 
  - hrishikesh-dhayagude
---
[Hrishikesh Dhayagude](https://medium.com/@dhrishi?source=post_page-----84164316c0e3--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fd9449153a291&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fannouncing-matter-previously-chip-on-esp32-84164316c0e3&user=Hrishikesh+Dhayagude&userId=d9449153a291&source=post_page-d9449153a291----84164316c0e3---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*6SmRnmN49BKqaxYRVYR9Qg.jpeg)

## Introduction

[Matter](https://buildwithmatter.com), previously project CHIP, is the new foundation for connected things. Guided by the [Connectivity Standards Alliance](http://csa-iot.org/), and developed through collaboration amongst all the leaders of the IoT industry, Matter focuses on building connected devices that are secure, reliable, and importantly, seamless to use.

Espressif has been a part of the Matter initiative since early days, and we have been focusing on making it easy to develop and use Matter with Espressif’s line of SoCs. In this article, we will discuss the steps to get your first Matter application up and running on an ESP32. In upcoming articles, we will discuss various technical details of Matter and explore ways to quickly build Matter certified devices on Espressif platforms.

## Architecture

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*kSxqtZCqJf1pH4JYaoa1IA.png)

As illustrated above, Matter defines the application layer that will be deployed on devices and controllers as well as supported IPv6-based networks to help achieve the interoperability goals. Matter will initially support Wi-Fi and Thread for core communications and Bluetooth Low Energy (BLE) to simplify device commissioning and setup.

## Matter on ESP32

## Matter SDK

The [Matter SDK](https://github.com/project-chip/connectedhomeip) is an open source repository for the implementation of the specification and continues to be under active development. ESP32 has been a supported platform in the Matter SDK since the very beginning. At present, it is the only platform that offers support of both Wi-Fi as well as BLE. ESP32 supports commissioning (initial device configuration) over BLE as well as Wi-Fi SoftAP; and supports operational communication over Wi-Fi.

## Sample Examples

You could try either of the following examples:

Either of these examples can be tested against a Matter controller. The Matter SDK provides reference implementation of controllers:

## Getting Started

Let’s look at the steps to try the above examples on ESP32.

We use Espressif IoT Development Framework (ESP-IDF) [release v4.3](https://github.com/espressif/esp-idf/releases/tag/v4.3) to try this out.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*nPAQ_qyd84e8jkJq9RCeWQ.jpeg)

## Build the Python Controller

```
$ cd /path/to/connectedhomeip$ ./scripts/build_python.sh -m platform
```

- Execute the controller and establish a secure session over BLE. BLE is the default mode in the application and is configurable through menuconfig.

```
$ source ./out/python_env/bin/activate$ chip-device-ctrlchip-device-ctrl > ble-scanchip-device-ctrl > connect -ble 3840 20202021 135246
```

__Parameters:__ 

- Add credentials of the Wi-Fi network you want the ESP32 to connect to, using the AddWiFiNetwork command and then enable the ESP32 to connect to it using EnableWiFiNetwork command. In this example, we have used TESTSSID and TESTPASSWD as the SSID and passphrase respectively.

```
chip-device-ctrl > zcl NetworkCommissioning __AddWiFiNetwork__  135246 0 0 ssid=str:__TESTSSID__  credentials=str:__TESTPASSWD__  breadcrumb=0 timeoutMs=1000chip-device-ctrl > zcl NetworkCommissioning __EnableNetwork__  135246 0 0 networkID=str:__TESTSSID__  breadcrumb=0 timeoutMs=1000
```

- Close the BLE connection to ESP32, as it is not required hereafter.

```
chip-device-ctrl > close-ble
```

- Resolve DNS-SD name and update address of the node in the device controller.

```
chip-device-ctrl > resolve 135246
```

- Use the OnOff cluster command to control the OnOff attribute. This allows you to toggle a parameter implemented by the device to be On or Off.

```
chip-device-ctrl > zcl OnOff Off 135246 1 0
```

> Note: All the above commands have help associated with them that can assist with the parameters.

The above commands help you try the common functionality that is exposed by Matter on the ESP32.

## ESP32-C3 Support

ESP32-C3 support is integrated in Matter. Please follow the READMEs to run the examples on ESP32-C3

Stay tuned for more updates on Matter and ESP32. Happy hacking!
