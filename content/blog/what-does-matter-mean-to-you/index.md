---
title: "What does Matter mean to you?"
date: 2021-11-23
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kedar-sovani
tags:
  - IoT
  - Esp32
  - Matter

---
[*Espressif Matter Series*](/blog/matter)* #1*

You may have recently read about the newly introduced standard, [Matter](/blog/announcing-matter-previously-chip-on-esp32). Matter is an initiative of the [Connectivity Standards Alliance](http://csa-iot.org/), and developed through collaboration amongst all the leaders of the IoT industry.

There is a high level of excitement about Matter and what it aims to achieve. We often hear questions from device-makers and end-users as to how they can benefit from the Matter standard. In this article, let’s look at what does Matter mean to you as an end-user and as a device-maker.

## For End Users

If you are an end-user, Matter will make smart-home much more natural and intuitive for you.

{{< figure
    default=true
    src="img/what-1.webp"
    >}}

__No More Silos:__ 

Gone would be the days where one vendor’s app only worked with its own smart home devices. *A Matter enabled app, will work with any Matter enabled device.*

So also no more of: “Oh this is an iOS ecosystem device, so my wife on Android can’t use it that well”.

[Amazon](https://developer.amazon.com/en-US/alexa/matter), [Apple](https://developer.apple.com/videos/play/wwdc2021/10298/), [Google](https://blog.google/products/google-nest/four-google-smart-home-updates-matter/) and [Samsung](https://news.samsung.com/global/samsung-smartthings-integrates-matter-into-ecosystem-bringing-matter-device-control-to-multiple-samsung-products) all have announced integrated support for Matter in their latest announcements. So the typical devices that let us interact with smart devices: phones (iOS as well as Android) and voice assistants/smart speakers will support Matter based devices out of the box. *You might not even require a separate phone app to use devices that run Matter.*

{{< figure
    default=true
    src="img/what-2.webp"
    >}}

__More automation:__  Matter allows effective device-to-device communication without any other intermediary involved. A Matter smart switch or sensor can directly switch on/off a Matter lightbulb (or a group of bulbs), without having to go through any app, cloud or a skill. Once devices are setup, the control happens completely locally over the local network.

__No more transport silos:__ Matter works with devices that support Wi-Fi, as well as Thread/802.15.4. Your phone app will be able to control devices using any of these transports equally well.

You could also setup automations that allow an 802.15.4-based sensor to directly switch-on a Wi-Fi based light-bulb without an app or a cloud into the picture. Yes, you read that right. A device called a border router (that includes both Wi-Fi and 802.15.4 transports) helps bridge these two networks, allowing direct addressability from one to another.

Additionally, all the communication happens over the local Wi-Fi/802.15.4 network. So smart control continues to work within devices in the local network even across Internet outages.

For existing products that use ZigBee or BLE Mesh, Matter bridges can help you make these devices reachable through the Matter ecosystems.

{{< figure
    default=true
    src="img/what-3.webp"
    >}}

__More ecosytems:__  Solution providers may offer higher level ecosystems based on Matter, that provide additional features to end users. The Matter specification makes it easier for devices to work with multiple ecosystems. So the same device could, *simultaneously*, work with multiple heterogenous ecosystems. What’s more, device vendors themselves [can create their own ecosystems](/blog/matter-multi-admin-identifiers-and-fabrics) (not just restricted to phone OSes or voice assistants) and provide innovative features as part of these ecosystems. Please watch out for a follow-on blog post for more details about Matter Ecosystems.

__Better security:__ The Matter specification has baked in secure features, agreed and reviewed by the best in the tech industry. This guarantees that devices that pass Matter certification rely on well reviewed and strong industry standards.

All in all, Matter should help accelerate pervasive intelligence in the smart home by delivering seamless integrations and new possibilities.

## For Device Makers

If you are a device maker, firstly your customers will benefit from all the advantages of Matter described above. Secondly, Matter will help you build and scale smart devices much faster, with no encumbrances.

__Ease of Development:__ Device makers no more have to spend engineering effort in painstakingly supporting and, importantly, certifying multiple ecosystems. This is often an engineering/cost overhead, but also a launch timeline overhead. Matter makes building devices much easier and faster.

__Power of Open:__  The Matter implementation is built [openly](https://github.com/project-chip/connectedhomeip) and for a wide variety of vendors. This makes evaluation and development faster.

You can try out a Matter-enabled device even today, just head over to the [Git repository](https://github.com/project-chip/connectedhomeip/tree/master/examples/all-clusters-app/esp32).

__Device — Device Automations:__  The device-to-device automations make it easier to introduce intelligence in a smart-home: a sensor coupled with light-bulb, that work by themselves. Your bulb or sensor, could work with any other Matter vendor’s devices.

If you are a device maker that builds devices like sensors or switches that always works in conjunction with other devices, this is great news for you. This means you could build smart devices, leaving up to the customer’s imagination what they tie the output of your device to (a bulb or a fan or anything else, from any vendor).

__Matter Ecosystems:__  Matter ecosystems is a way to implement an ecosystem of smart devices that may talk to each other and build compelling multi-device scenarios. The Matter specification allows vendors to create such an ecosystem so that these features can be layered on top.

__Manufacturer-specific Innovations:__  The Matter specification has an evolving list of device-types, the typical attributes they will have, and the commands they will obey. If your device has certain innovative features that cannot be expressed through these, you could define your own attributes that allow you to make the best use of these.

## Espressif and Matter

Espressif has been actively working with Matter since its inception. Support for Espressif SoCs is already [available upstream](https://github.com/project-chip/connectedhomeip/tree/master/examples/all-clusters-app/esp32) in the Matter repositories. You may take it for a spin on an ESP32 or ESP32-C3 by following the instructions in [this article](/blog/announcing-matter-previously-chip-on-esp32#gettingstarted).

We are currently working on building tools and documentation, to assist our customers in every step of the product development process, right from solution architecture, to certification, manufacturing and diagnostics.

We are excited about this journey, and look forward to hearing how you envision building with Matter.

This article is a part of a series of articles [*Espressif Matter Series*](/blog/matter). You may read the next article that talks about [Matter’s Data Model](/blog/matter-clusters-attributes-commands).
