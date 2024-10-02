---
title: "Reducing costs and complexity for deploying connected devices with ESP-Hosted"
date: 2022-07-31
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - anant-raj-gupta
tags:
  - Esp32
  - Espressif
  - Wifi
  - IoT
  - Connectivity

---
Connecting your devices to the cloud is a topic which is actively discussed across multiple industries as it is not a hidden fact that there are numerous advantages to doing so. To name a few common advantages across various industries —

- __Accessibility:__ With devices connected to the cloud, accessing them anywhere, anytime across the globe is possible with a click of a button or a fingertip.
- __Back up your data__ : Most cloud services will provide facilities to back up your critical data collected through these connected devices.
- __Over-The-Air (OTA) updates:__ One of the most important benefits is the capability of updating your devices' FW/SW remotely. This is critical to keep your devices secure and reduces maintenance costs significantly.
- __Improved Productivity:__ With automation and increased collaboration between different devices (Machine-to-Machine), the time spent by valuable resources on getting things done is reduced drastically which results in much higher productivity.

These well-known advantages are making the technology widely accepted across various industries so much so that *“Over 60% of organisations currently use IoT, with only 9% of them currently having none at all.”* (*IoT Developer Survey, Eclipse Foundation[1]*)

But still, there are challenges for the adoption of the technology with I__ntegration with existing technology__  and __cost of implementation__  remaining two of the biggest barriers as per the *GSMA Intelligence Enterprise IoT Survey[2]*

{{< figure
    default=true
    src="img/reducing-1.webp"
    >}}

__Espressif’s ESP-Hosted__  is a solution to cater to the above two barriers and is aimed to ease the integration complexities by providing standard software interfaces which require no or minimal changes to the existing solutions, as well as, reduce the development timelines significantly by providing open source solution which works “off-the-shelf” thus lowering the development costs.

The latest __ESP-Hosted NG__  solution from Espressif is targeted toward Linux or Android-based systems which want to add wireless and cloud connectivity to their existing products as well as for IoT Gateways. This is important as Linux is the number one operating system with a 43% market share amongst all connected devices as per the *IoT Developer survey conducted by the Eclipse organisation[1]*.

## ESP-Hosted

ESP-Hosted is an open source solution that provides a way to use Espressif SoCs and modules as a communication co-processor. This solution provides wireless connectivity (Wi-Fi and BT/BLE) to the host microprocessor(MPU) or microcontroller(MCU), allowing it to communicate with other devices. ESP-Hosted communicates with the host processor through commonly available UART, SPI or SDIO peripheral interface.

{{< figure
    default=true
    src="img/reducing-2.webp"
    >}}

This architecture which separates the wireless connectivity module from the main host processing module is beneficial as it adds the wireless connectivity to existing MCU/MPU-based solutions providing the following advantages.

- __Faster development cycles__  — The ESP-Hosted help the connectivity module to connect over the standard 802.11 interface (ESP-Hosted-NG) or an 802.3 interface (ESP-Hosted-FG) and thus acts as a“plug & play” device
- __Reduce re-qualification/re-certification__  __efforts__  — As the ESP-Hosted does not touch the user-space applications, adding the connectivity module will not require developers to re-qualify or re-certify the majority of their software.
- __Power Saving__  — The main MPU/MCU can remain in low power mode without being interrupted to stay connected to the network. The main host needs to only get involved when there are actual tasks to perform offloading all the connectivity overheads to the connectivity module.
- __Easier upgrades and Product variants__  — The architecture enables the developers to easily upgrade for better wireless connectivity or have multiple variants of the same product with different connectivity options. Such an example is shown below in which the developer can use the same Host applications and software but have a variety of options for wireless connectivity from Wi-Fi4 to Wi-Fi6 to Wi-Fi6 dual band.

{{< figure
    default=true
    src="img/reducing-3.webp"
    >}}

On top of the above-stated development advantages of the two chip architecture, by choosing the ESP-Hosted solution you also get Espressif’s easy availability of modules and a cost effective solution which has acceptable performance levels for a majority of the applications.

__ESP-Hosted is open-source__  and Espressif makes the [source code](https://github.com/espressif/esp-hosted) available for developers to take advantage of the rich features of the ESP32 family of SoCs. The developers can make use of the IO and HMI capabilities of the [ESP32](https://www.espressif.com/en/products/socs/esp32) and the [ESP32-S3](https://www.espressif.com/en/products/socs/esp32-s3) or the advanced security features such as the Digital Signature Peripheral of the [ESP32-C3](https://www.espressif.com/en/products/socs/esp32-c3) device. The possibilities are endless.

## Variants of ESP-Hosted

The ESP-Hosted solution is available in two variants as mentioned below. The differentiation factor here is the type of network interface presented to the host and the way Wi-Fi on ESP SoC/module is configured/controlled. Both the variants have their respective host and firmware software.

## ESP-Hosted-FG

This is a first-generation ESP-Hosted solution. This variant provides a standard 802.3 (Ethernet) network interface to the host. In order to achieve this, the host is presented with the following:

- A simple 802.3 network interface which essentially is an Ethernet interface
- A lightweight control interface to configure Wi-Fi on the ESP SoC
- A standard HCI interface

The use of the simple 802.3 interface for this solution makes it ideal to be used with MCU hosts. The MCU application can continue to take advantage of the standard TCP/IP stack and prevents significant changes to the host application for using the AT firmware-based approach or integrating the complex 802.11 interface.

## ESP-Hosted-NG

This is the Next-Generation ESP-Hosted solution specifically designed for hosts that run Linux operating system. __*This variant of the solution takes a standard approach while providing a network interface to the host. *__ This allows usage of standard Wi-Fi applications such as wpa_supplicant to be used with ESP SoCs/modules. This solution offers the following:

- 802.11 network interface which is a standard Wi-Fi interface on a Linux host
- Configuration of Wi-Fi is supported through standard cfg80211 interface of Linux
- A standard HCI interface

## Our Recommendation

- If you are using an __*MCU host*__ , you have to use __*ESP-Hosted-FG.*__ 
- If you are using a __*Linux host*__ , we recommend __*ESP-Hosted-NG*__  since it takes a standard approach which makes it compatible with widely used user space applications/services such as wpa_supplicant, Network Manager etc.

__References -__ *1. *[*IoT Developer Survey, Eclipse Foundation*](https://f.hubspotusercontent10.net/hubfs/5413615/2020%20IoT%C2%A0Developer%20Survey%20Report.pdf)*2. *[*GSMA Intelligence Enterprise IoT Survey*](https://data.gsmaintelligence.com/api-web/v2/research-file-download?id=58621970&file=141220-Global-Mobile-Trends.pdf)

*Thanks to *[*Amey Inamdar*](https://medium.com/u/96a9b11b7090?source=post_page-----63ff9511ddef--------------------------------)* for the review and feedback.*
