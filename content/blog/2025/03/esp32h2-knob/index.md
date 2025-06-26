---
title: "ESP-Knob: A multifunctional smart controller with the ESP32-H2"
date: 2025-03-27T18:37:17+08:00
showAuthor: false
featuredAsset: "Esp_knob_featured2.webp"
authors:
  - "cai-guanhong"
tags: ["ESP32-H2", "BLE ADV", "BLE-HID", "Matter", "Zigbee", "BLE-Mesh"]
summary: "This article provides an overview of the ESP-Knob, its features, and functionality. It also details the hardware design and outlines the firmware framework that supports its operation."
---

## Introduction

In today’s fast-paced tech world, users are moving beyond simply wanting a variety of new smart platforms. Instead, they’re looking for an intelligent ecosystem where devices work together seamlessly, supported by tools that make managing them easier. This requires not only interoperability between devices but also the ability for them to understand and respond to users’ diverse needs, offering more personalized and intelligent services. As a result, ensuring communication across different brands and platforms has become an increasingly important challenge in the smart technology space.

To address this challenge, the ESP32-H2_Knob comes into play. Designed to connect seamlessly with a wide range of devices from different brands, it supports multiple communication protocols, enabling interoperability across various platforms. With the ESP32-H2_Knob, users can enjoy a truly connected ecosystem where different smart devices work together effortlessly. Using only one ESP-Knob, you can instantly switch between devices and adjust their settings.

## Overview of ESP-Knob

The ESP-Knob is a multifunctional smart knob controller developed by Espressif Application team and powered by the [ESP32-H2](https://www.espressif.com/en/products/socs/esp32-h2) chip. It not only integrates with [Home Assistant](https://www.home-assistant.io/) but also widely supports wireless communication protocols such as [BLE-HID](https://novelbits.io/bluetooth-hid-devices-an-intro/), [Thread](https://www.threadgroup.org/What-is-Thread/Overview), [Matter](https://docs.espressif.com/projects/esp-matter/en/latest/esp32h2/introduction.html#introduction), [ESP-BLE-MESH](https://docs.espressif.com/projects/esp-idf/en/v5.2.3/esp32h2/api-guides/esp-ble-mesh/ble-mesh-index.html#esp-ble-mesh), and [Zigbee](https://docs.espressif.com/projects/esp-zigbee-sdk/en/latest/esp32h2/index.html#esp-zigbee-sdk-programming-guide). By establishing connections with mainstream smart devices like Apple [HomePod](https://www.apple.com/homepod/) and [Amazon Echo](https://www.dxomark.cn/amazon-echo-4th-gen-speaker-review-wider-than-meets-the-eye/), the ESP32-H2_Knob helps bridge cross-platform gaps, enabling simpler collaboration between devices from different ecosystems

The front of the ESP-Knob features a push-rotary knob housed in a durable aluminum alloy casing, capable of detecting both pressing and rotating actions. The back is equipped with a strong magnetic base that securely attaches to metal surfaces, offering flexible and convenient control placement.

{{< figure
default=true
src="img/knob.webp"
height=500
caption="ESP-Knobs"
    >}}

In this video you can see the ESP-Knob in action

{{< youtubeLite id="NBSx1MIzFPg" label="ESP-Demo: Multi-Function Smart Controller with ESP32-H2" >}}


#### Power Supply Modes

To ensure flexibility and reliability, there are two ways to supply power to ESP-Knob:

- **Button Battery (Default Power Supply):**
The ESP-Knob operates efficiently and stably with a single button battery, supporting low power management to extend battery life.

{{< figure
default=true
src="img/power.webp"
height=500
caption="ESP-Knob exploded view with batteries"
    >}}

- **USB Power Supply (via ESP32-H2 USB Interface):**
In terms of hardware design, the ESP-Knob also includes a USB-C port, allowing for continuous power supply via USB, which facilitates program downloading and debugging.


## Key Features and Capabilities
This section highlights the ESP-Knob's key functionalities and the innovative features that make it a versatile tool for smart device control and integration.

### BLE ADV Broadcast Function

The ESP-Knob connects to the [Home Assistant](https://www.home-assistant.io/) smart home system via the [BTHome](https://bthome.io/) protocol, sending broadcast packets in the [BTHome](https://bthome.io/) format to control the third-party smart devices easily, such as adjusting the brightness and color of the Xiaomi bedside lamp, as well as turning it on or off.


{{< youtubeLite id="SznMNu9SA14" label="ESP32-H2 Knob Working" >}}

### Matter Control Function
The ESP-Knob is also compatible with the Matter-Over-Thread protocol, allowing for easily connect with smart devices such as Apple [HomePod](https://www.apple.com/homepod/) and [Amazon Echo](https://www.dxomark.cn/amazon-echo-4th-gen-speaker-review-wider-than-meets-the-eye/) simultaneously. This enables users to seamlessly manage and control various smart home devices in their homes through the Matter protocol, facilitating a cross-platform smart home control system that enhances the coherence and convenience of the user experience.


{{< youtubeLite id="n4Fq6U70qlk" label="Matter-Over-Thread protocol" >}}


### BLE-HID Device Control Function

The ESP-Knob also supports the [BLE-HID](https://novelbits.io/bluetooth-hid-devices-an-intro/) protocol, allowing it as **a Volume Control Device** and **a Wireless Slide Presenter** when connected via Bluetooth.

- The ESP-Knob can easily pair with smartphones or other Bluetooth devices, serving as an intuitive volume controller. Users can effortlessly adjust the volume using the knob, providing convenient volume control whether enjoying music at home or participating in video conferences at the office.

{{< youtubeLite id="pmnauIzcIpU" label="Bluetooth HID" >}}

- In presentation or speech settings, the ESP-Knob can transform into a convenient Wireless Slide Presenter, enabling remote slide advancement thanks to its support for the [BLE-HID](https://novelbits.io/bluetooth-hid-devices-an-intro/) protocol.


{{< youtubeLite id="hjV7RA3wVpI" label="PPT Wireless control" >}}



### BLE-Mesh & Zigbee Networking Control Functions


For multi-device Mesh scenarios, ESP-Knob supports both [ESP-BLE-MESH](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.3.1/esp32h2/api-guides/esp-ble-mesh/ble-mesh-index.html#esp-ble-mesh) and [Zigbee](https://docs.espressif.com/projects/esp-zigbee-sdk/en/latest/esp32h2/introduction.html#espressif-zigbee-solutions) protocols, and it can efficiently and reliably control multiple devices.

- Multi-device lighting control demonstration

{{< youtubeLite id="wwnxeq8N-V0" label="Zigbee Control" >}}


### Long-distance & Through-wall control function

With the [ESP32-H2](https://www.espressif.com/sites/default/files/documentation/esp32-h2_datasheet_en.pdf)'s transmission power of up to 20 dBm and the maximum reception sensitivity of -106.5 dBm, the ESP-Knob can easily achieve wall penetration communication while maintaining a stable connection over long distances. This means that even in complex environments with numerous obstacles and potential signal interference, the ESP-Knob can still provide reliable and continuous wireless connectivity, ensuring the stability and responsiveness of remote control and data transmission for smart home devices.

- Wall Penetration and Long-Distance Control Demonstration

{{< youtubeLite id="PuD6JZsAOBU" label="Zigbee Control" >}}

## Hardware Design

The hardware design of the ESP-Knob is relatively simple. Apart from the basic battery power supply circuit, rotary knob circuit, and download/debugging circuit, it only includes a simple LED indicator circuit. The hardware system of the ESP-Knob is composed as follows:

{{< figure
default=true
src="img/knob-hardware.webp"
height=500
caption="ESP-Knob Hardware Design"
    >}}

The circuit blocks annotated in the drawing are as follows:

- **`Main MCU`**: [ESP32-H2-MINI-1-H2](https://www.espressif.com/sites/default/files/documentation/esp32-h2-mini-1_mini-1u_datasheet_en.pdf) module

- **`EC11 (Rotary Encoder):`** Used for user input, capable of detecting both rotation and press operations. The press signal from the EC11 controls `VCC_EN`, which is used for power switching or mode switching.

- **`5V → 3.3V (Power Module):`** Uses the XC6206P332MR-G low-dropout linear regulator to step down the USB power supply (5V) to the 3.3V required by the [ESP32-H2](https://www.espressif.com/sites/default/files/documentation/esp32-h2_datasheet_en.pdf).

- **`VBAT → 3.3V (Power Module):`** Utilizes the TPS61291 boost converter to accommodate a wide input voltage range, supplying 3.3V to the [ESP32-H2](https://www.espressif.com/sites/default/files/documentation/esp32-h2_datasheet_en.pdf) during operation. When the [ESP32-H2](https://www.espressif.com/sites/default/files/documentation/esp32-h2_datasheet_en.pdf) is in sleep mode, it is directly powered by the battery, and supporting low-power on sleep mode for wake-up functionality.

- **`USB-C Interface:`** Use a USB-C port connect to the ESP32-H2 and used for data transmission and power supply.

- **`LED (LED Module):`** Uses `GPIO2` and `GPIO3` of the [ESP32-H2](https://www.espressif.com/sites/default/files/documentation/esp32-h2_datasheet_en.pdf) to control a dual-color LED for lighting and off, and used indicating different operating states of the ESP-Knob.

- **`BATTERY (Battery Management Module):`** Connects an external lithium battery (VBAT) through BT1 and monitors the battery voltage. The voltage is divided to BAT_ADC, allowing the ESP32-H2 to monitor the battery level.

- **`DEBUG (Download & Debug Interface):`** A reserved test point for the download interface and hardware reset interface of the ESP-Knob device. By connecting to the ESP32-H2’s UART0 interface `(TXD0 and RXD0`), it supports firmware flashing and debugging. Pulling the `ESP_EN` pin low allows for a hardware reset of the ESP-Knob.

The complete open-source hardware documentation for ESP-Knob can be found at [ESP32-H2-Knob](https://oshwlab.com/hawaii0707/esp32-h2-switch). For more details on ESP hardware design, please refer to the [ESP Hardware Design Guidelines](https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32h2/index.html).


## Available firmware and examples

The example projects for the ESP-Knob available at the time of writing are detailed below. Once you flash the corresponding firmware, the ESP-Knob can be connected to different smart home systems. You can also directly download the three kinds of ESP-Knob firmware from the [ESP-LAUNCHPAD](https://espressif.github.io/esp-launchpad/?flashConfigURL=https://dl.espressif.com/AE/AE-Demo/ESP32-H2-Knob/config.toml).
The examples are
* **BLE-HID**: A BLE-HID implementation based on the [ble_hid_device_demo](https://github.com/espressif/esp-idf/tree/release/v5.4/examples/bluetooth/bluedroid/ble/ble_hid_device_demo). You can adjust the volume by turning the knob and change the bonded device through a long press.
* **BTHome firmware**: It integrates `Button`and `Dimmer`components, broadcasting the data in BTHome protocol. It supports Home Assistant and automatic deep sleep.
* **Matter universal switch**: It implements a simple matter switch, which can be provisioned using the network qr-code.


## Conclusion

Leveraging the power of the ESP32-H2 chip, the independently developed smart ESP-Knob offers users a seamless smart home control experience. With its exceptional compatibility and flexibility, it allows developer to easily manage all smart devices in the home with a simple device. We encourage contributions from DIY developers to help expand and enhance the capabilities of the ESP-Knob, and we look forward to seeing fresh ideas and innovations from the community.

<div style="font-size: 0.8em; color: #888; margin-top: 2em;">
Apple and HomePod are trademarks of Apple Inc., registered in the U.S. and other countries and regions.
</div>
