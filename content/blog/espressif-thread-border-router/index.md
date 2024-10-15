---
title: "Espressif Thread Border Router"
date: 2023-06-14
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - shu-chen
tags:
  - Esp32
  - IoT
  - Open Thread

---
We are glad to announce that the Espressif Thread Border Router (ESP Thread BR) solution has received [certification](https://www.espressif.com/sites/default/files/Espressif%20Thread%20Border%20Router%20Thread%20V1.3%20Interoperability%20Certification_0.pdf) from the Thread Group, and the accompanying development kit has now been officially released.

This blog post will delve into the technical aspects of the solution and explore the benefits it offers, facilitating faster time-to-market for our customers’ products.

## What’s a Thread Border Router?

As defined in the [Thread Border Router White Paper](https://www.threadgroup.org/Portals/0/documents/support/ThreadBorderRouterWhitePaper_07192022_4001_1.pdf):

> A Border Router is a device that can route packets to and from the mesh. This routing happens between the Thread mesh and any other IPbearing interfaces like Wi-Fi, Ethernet, and Cellular.

## ESP Thread BR Architecture

ESP Thread BR solution is based on the combination of Espressif’s Wi-Fi and 802.15.4 SoCs, built on the ESP-IDF and open-source OpenThread stack.

{{< figure
    default=true
    src="img/espressif-1.webp"
    >}}

Unlike the well-known [ot-br-posix](https://github.com/openthread/ot-br-posix) solution that is Linux/Unix-based, the ESP Thread BR is built on the ESP-IDF framework, incorporating integrated components such as Wi-Fi and 802.15.4 stacks, LwIP, mDNS, and more.

In the solution, the Host Wi-Fi SoC operates the Espressif Thread BR and OpenThread Core stack, while the 802.15.4 SoC runs the OpenThread RCP (Radio Co-processor). Communication between the two is established through the [Spinel protocol](https://openthread.io/platforms/co-processor#spinel_protocol).

{{< figure
    default=true
    src="img/espressif-2.webp"
    >}}

## ESP Thread BR Features

## Networking Features

A previous blog [Thread Border Router in Matter](/blog/matter-thread-border-router-in-matter) introduces the role of the Thread Border Router in Matter scenario. Here are the key networking features supported by the ESP Thread BR:

- __Bi-directional IPv6 connectivity__

Enable bi-directional IPv6 communication across Thread and non-Thread networks, it currently supports both Wi-Fi and Ethernet as the backbone link.

- __Service Discovery__

Implements the functions for bi-directional service discovery, including the Service Registry Protocol (SRP) server, Advertising Proxy, and Discovery Proxy. These functions facilitate zero-configuration discovery of services offered by Thread Devices, as well as services offered by non-Thread devices.

- __Multicast Forwarding__

Implements the Multicast Listener Discovery v2 (MLDv2) protocol and enables seamless IPv6 multicast across Thread, Wi-Fi, and Ethernet networks.

- __NAT64__

The Thread devices can access the IPv4 internet via the ESP Thread BR.

*Note: Although NAT64 is not a mandatory feature for the Matter scenario, as Matter is primarily designed for local network applications, it does facilitate point-to-point communication between Thread devices and cloud services.*

## Production Features

In addition to the networking features, the Espressif Thread BR SDK also supports multiple useful features for productization.

- __RCP Update__

As the solution involves two SoCs, it requires the download of two matching firmware for over-the-air (OTA) updates. The SDK offers a mechanism that combines the two firmware into a single binary. With a streamlined one-step OTA process, the host SoC will automatically download the RCP firmware to the 802.15.4 SoC during the initial boot.

- __RF Coexistence__

The coexistence design is often a challenging aspect for devices that incorporate multiple radios. The Espressif Thread BR addresses this issue by leveraging an integrated hardware and software design, offering the 3-wires PTA Coexistence feature in the SDK. This feature greatly simplifies the complexity of the customer’s application.

- __Web GUI__

Additionally, the SDK offers a user-friendly web-based GUI for easy configuration by the user. Moreover, the provided REST APIs are compliant with the APIs offered by [ot-br-posix](https://github.com/openthread/ot-br-posix), ensuring compatibility and seamless integration.

## HW Reference and SW SDK

The Espressif Thread BR SDK is available on GitHub:

[https://github.com/espressif/esp-thread-br](https://github.com/espressif/esp-thread-br)

[https://docs.espressif.com/projects/esp-thread-br](https://docs.espressif.com/projects/esp-thread-br)

The Hardware reference design and dev kits are also available ([link](https://www.aliexpress.com/item/1005005688193617.html?spm=5261.ProductManageOnline.0.0.56162ddbyxG7Gb)):

{{< figure
    default=true
    src="img/espressif-3.webp"
    >}}
