---
title: "Espressif RainMaker over Thread Solution"
date: 2025-02-19
showAuthor: false
authors:
  - shu-chen
tags:
  - RainMaker
  - Thread
  - IoT
---

[ESP RainMaker](https://developer.espressif.com/blog/esp-rainmaker/) is complete-yet-customizable IoT cloud platform software based on AWS Serverless architecture that simplifies the development of connected devices by providing device control and device management features. ESP RainMaker can be deployed in customers' own AWS accounts to achieve full autonomy and control for rapid development.

[Thread](https://threadgroup.org/), based on 802.15.4, is a low-power, secure, IP-based mesh networking protocol for IoT devices. It offers a secure, reliable, and scalable solution for connecting devices, enabling direct communication with each other and the Internet.

## Introduction

Traditionally, Wi-Fi and Cellular IoT devices have relied on direct cloud connectivity to achieve autonomy in operation. With the IP capabilities of Thread networks and the evolution of Thread Border Routers enabling Internet connectivity, Thread-based devices can now achieve the same level of seamless, direct cloud communication.

Being in the best position to offer such a comprehensive solution, we at Espressif are excited to announce the **ESP RainMaker over Thread solution**. Integrating ESP RainMaker with Thread, the solution includes a [device-agent SDK](https://github.com/espressif/esp-rainmaker/) for both RainMaker over Thread devices and the Thread Border Router, a transparent cloud application, and [iOS](https://apps.apple.com/us/app/esp-rainmaker/id1497491540)/[Android](https://play.google.com/store/apps/details?id=com.espressif.rainmaker&hl=en_IN) phone apps.

The typical ESP RainMaker topology is shown below:

  {{< figure
      default=true
      src="img/rainmaker-topology.webp"
      alt=""
      caption=""
      >}}

## Why ESP RainMaker over Thread

With the **ESP RainMaker over Thread** solution, customers can deploy various AIoT applications, such as:

- **Large-scale networking:** Supports up to 300 devices in a single network, with the ability to accommodate multiple networks within a deployment.
- **Wide-range deployment:** Multi-hop mesh networks can cover areas spanning several kilometers.
- **Ultra-low power device:** Battery-powered sensors can operate for several years.

Additional benefits of using ESP RainMaker over Thread devices are:

- Direct point-to-point communication with the cloud, enabling direct remote control and device management such as cloud-based fleet management and OTA.
- Easy and secure network configuration with local and remote device control using phone apps.
- Compatibility with any Thread Border Routers that support NAT64, such as Apple HomePod and [Espressif's Thread Border Router solution](https://developer.espressif.com/blog/espressif-thread-border-router/).
- Supports a wide range of [smart home device types](https://docs.rainmaker.espressif.com/docs/product_overview/concepts/terminologies#devices), enabling rapid productization of Thread-based products.

Thread device provisioning and control in the ESP RainMaker app:

  {{< figure
      default=true
      src="img/rainmaker-thread-app.webp"
      alt=""
      caption=""
      >}}

## Feature Details

In addition to the existing **ESP RainMaker over Wi-Fi** solution, **ESP RainMaker over Thread** facilitated the introduction of several new features covered in the sections below.

### Network Provisioning

The new [Network Provisioning](https://components.espressif.com/components/espressif/network_provisioning) component is an enhanced version of [Wi-Fi Provisioning](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/provisioning/wifi_provisioning.html) and now supports both Wi-Fi and Thread network provisioning:

- Provision Wi-Fi credentials via SoftAP or Bluetooth LE
- Provision Thread credentials via Bluetooth LE

### Thread Border Router Management

A new device type in the ESP RainMaker ecosystem is based on the [ESP Thread Border Router](https://developer.espressif.com/blog/espressif-thread-border-router/), which supports the latest Thread 1.4 version:

- Bi-directional IPv6 connectivity
- Service Discovery
- Multicast Forwarding
- NAT64
- Credential Sharing
- TREL (Thread Radio Encapsulation Link)

ESP RainMaker over Thread devices can communicate with other devices on the local network and the cloud through the Thread Border Router.

### Large Scale Deployment

Thread, based on 802.15.4 as the underlying PHY and MAC layer, has bandwidth limitations that can pose challenges in large-scale deployments. For example, if too many devices within the same network attempt to generate heavy traffic—such as establishing TLS sessions with the cloud or performing OTA updates simultaneously—it can impact network connectivity and stability.

To ensure uninterrupted Thread communication for telemetry reporting and device control, we have implemented several solutions:

- Traffic Control

  A central device (typically the Thread BR) regulates the maximum number of devices allowed to establish TLS sessions with the cloud simultaneously.

- OTA Optimization

  The number of simultaneous OTA sessions in a given environment needs to be limited. ESP RainMaker implements the logic to ensure managed OTA delivery to Thread devices in the environment even when devices span multiple Thread networks. When a new firmware version is available in the cloud, instead of pushing OTA notifications to all devices simultaneously, we introduced a query mechanism. This allows the cloud service to control the maximum number of parallel OTA sessions within a single network, ensuring a smoother update process.

### Group Control

Multicast-based group control is supported for Thread devices, making it highly effective for managing large groups. For example, in a use case with 50 devices in a group, multicast control significantly reduces latency by eliminating the need to send 50 individual unicast messages.

### ESP RainMaker Apps

Both the Android and iOS ESP RainMaker apps have been updated to support the new Network Provisioning feature and the Thread Border Router device type. They can be used to set up and manage ESP RainMaker Thread Border Routers and ESP RainMaker over Thread devices.

## Other Useful Links

- [Espressif RainMaker](https://rainmaker.espressif.com/)
- [Espressif Thread Border Router](https://docs.espressif.com/projects/esp-thread-br)
- [Espressif 300x Thread Nodes Demo](https://www.youtube.com/watch?v=0WXcu_r_lvQ)

If you are interested in our ESP RainMaker over Thread solution, please contact our [customer support team](https://www.espressif.com/en/contact-us/sales-questions).

<div style="font-size: 0.8em; color: #888; margin-top: 2em;">
Apple and HomePod are trademarks of Apple Inc., registered in the U.S. and other countries and regions.
</div>
