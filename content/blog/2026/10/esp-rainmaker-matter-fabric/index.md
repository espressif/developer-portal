---
title: "ESP RainMaker Matter Fabric Support: A Complete Solution for Branded Ecosystems"
date: 2026-10-23T00:00:00.000Z
summary: "Build an ecosystem that supports Matter—and still keep end users on your app, with user accounts and remote control."
tags:
  - Matter
  - ESP RainMaker
  - announcement
  - smart home
authors:
  - "iot-solution-team"
---

As [Matter](https://csa-iot.org/all-solutions/matter/) becomes the interoperability standard for smart homes, more developers looking at Espressif’s stack are asking the same thing: how do I build an ecosystem that works with the rest of the house, and still keep an app—and a relationship with end users—that my brand owns?

Matter answers the first half. It is a local standard: devices from different brands can be set up from a phone, talk to each other on the home network, and join mainstream ecosystems. That interoperability is the point. What end users do not get from Matter itself is an account, remote control once they leave the house, or anyone looking after the device afterwards. Once someone walks out the door, Matter has nothing more to say.

[ESP RainMaker](https://docs.rainmaker.espressif.com/docs/product_overview/technical_overview/introduction/) is Espressif’s answer to that product side. It gives you user management with secure isolation between accounts, so one household cannot see another’s devices, and it covers a device through its life—onboarding, updates, sharing, and diagnostics—on a cloud you can run as your own.

Put the two together, and RainMaker adds what Matter itself does not have: end-user accounts with isolation between households, lifecycle management for the devices, and remote control when no one is home. Local interoperability stays. Your own app can also add Matter products from other makers, not only yours—so your brand can work with a wide range of Matter devices, and end users stay in one place. ESP RainMaker has had Matter Fabric support since it was [announced in 2023](https://www.espressif.com/en/news/RainMaker_Matter_Fabric). Below is the full picture of that support today.

## What is Matter Fabric?

Think of a Matter Fabric as one trusted circle in the home: the lights, plugs, phone app, and hub that are allowed to see each other and work together as part of the same ecosystem. You add a device to that circle from a phone—usually by scanning a code. After that, members of the circle can talk securely on the local network.

The same lamp can sit in more than one circle at once. That is Multi-Admin: it can belong to your brand and to a mainstream ecosystem at the same time, and each circle only sees its own membership. If you want the technical version—identifiers, certificates, and how a second circle is added—see [Matter: Multi-Admin, Identifiers, and Fabrics](https://developer.espressif.com/blog/matter-multi-admin-identifiers-and-fabrics/).

ESP RainMaker attaches that circle to an end-user account in the cloud, so the end user can manage and maintain it.

## What ESP RainMaker Matter Fabric Support provides

ESP RainMaker parses the Matter protocol in the cloud, covers Matter product categories, and maps Matter clusters and attributes to a human-readable Thing Model. Teams can operate and manage Matter devices through the cloud without building their own protocol processing stack—lowering the barrier from proof of concept to product deployment.

**PKI and certificate management.** During commissioning, RainMaker can issue Node Operational Certificates (NOCs) for the Fabric. Device identity across the lifecycle is managed in the cloud, so you do not need to operate a separate certificate system for Fabric operations.

**User-level Fabric management.** An end user can own multiple Fabrics, each bound to their account. The platform covers create, configure, share, and delete, plus the full [sharing-invitation flow](https://docs.rainmaker.espressif.com/docs/product_overview/features/group_sharing)—useful when a household needs isolation across homes or multi-dwelling deployments.

**App and SDK.** Built on a React Native stack, the open-source [ESP RainMaker Home](https://docs.rainmaker.espressif.com/docs/dev/phone-app/home-app/home-app-get-started#download-esp-rainmaker-home) app is the starting point. It already supports Matter commissioning (BLE or QR code), local control on the LAN, and remote control through a cloud-connected controller. Going branded is straightforward: change the logo and the UI to whatever you need, deploy RainMaker privately, and that same app becomes yours. End users stay in one place, which is how brand recognition and habit build. [`@espressif/rainmaker-matter-sdk`](https://docs.rainmaker.espressif.com/docs/sdk/rainmaker-matter-sdk/overview) exposes the same capabilities—Fabric management, commissioning, certificates, and challenge-response—for branded apps built on [`@espressif/rainmaker-base-sdk`](https://docs.rainmaker.espressif.com/docs/sdk/rainmaker-base-sdk/overview).

**Matter controllers.** Matter is fundamentally a local protocol. Physical controllers—touch panels, speakers, TVs, routers, or even end devices such as smart plugs—deliver low-latency local control. Connected to ESP RainMaker, they also keep a persistent cloud link so the home gains remote control. Espressif provides controller examples based on ESP-Matter and ESP RainMaker, including ESP32-P4 touch-panel hubs and ESP32-S31 voice speakers.

{{< figure
    src="img/esp-rainmaker-matter-topology.webp"
    alt="ESP RainMaker Matter topology: ESP RainMaker Cloud with PKI and NOC, device management, Matter Fabric management, and cloud-to-cloud API; the RainMaker app commissioning over BLE and QR code with local and remote control; and a Matter controller and Thread Border Router connecting Matter-over-Wi-Fi and Matter-over-Thread devices"
    caption="ESP RainMaker Matter topology"
    >}}

## Two integration models

**Unified management on ESP RainMaker.** Use RainMaker as the IoT cloud for both Matter and non-Matter devices. The serverless backend, open-source mobile apps, voice-assistant integrations, and device firmware SDKs are ready to use. This path suits you if you want Matter quickly without operating a separate IoT cloud.

**Cloud-to-cloud integration.** If you already have a mature business cloud, you can add Matter Fabric Support as modules—Fabric management, PKI issuance, and Matter protocol parsing—without replacing the rest of your stack. The [Matter Fabric Interface](https://docs.rainmaker.espressif.com/docs/product_overview/integrated_solutions/matter-fabric/interface) is an optional cloud API add-on for this integration, exposing Matter Fabric capabilities through APIs. It can also be used in the Unified RainMaker model when a product has specific API integration needs, but it is not required for standard RainMaker integration.

ESP RainMaker is built on AWS serverless architecture. Private deployments keep data under your control and can scale to large device fleets.

## Thread devices on the same Fabric

A [Thread Border Router (TBR)](https://developer.espressif.com/blog/matter-thread-border-router-in-matter/) connects Thread devices to the rest of the home network so Matter-over-Thread products can join the same Fabric as Wi-Fi Matter devices. TBR support can be enabled in the [`matter_controller`](https://github.com/espressif/esp-rainmaker/tree/master/examples/matter/matter_controller) example, so one hub can act as both a Matter controller and a TBR. The ESP RainMaker app can add a TBR, keep Thread network information, and use that information during Matter commissioning.

## Matter-ready upgrades for existing devices

Non-Matter devices already in the field can be upgraded to Matter over OTA. RainMaker can deliver DACs and Matter onboarding payloads from the cloud, with APIs to retrieve pairing codes, so products can join the Matter ecosystem without a hardware redesign.

Espressif also provides DAC provisioning (including as a CSA-authorized PAA), certification assistance with ATLs, and complementary solutions such as Thread Border Router, Matter Bridge, and Matter controllers.

## Getting started

The fastest way to evaluate this is the public RainMaker instance. You do not need to build your own app:

1. Install the [ESP RainMaker Home](https://docs.rainmaker.espressif.com/docs/dev/phone-app/home-app/home-app-get-started#download-esp-rainmaker-home) app.
2. Flash the `wifi_matter_light` firmware from [ESP Launchpad](https://espressif.github.io/esp-launchpad/?solution=matter) onto a supported ESP board. That is the Matter device you can test with right away.
3. Add the light in the app and try commissioning, Fabric management, and local control.
4. Optional: flash the [`matter_controller`](https://github.com/espressif/esp-rainmaker/tree/master/examples/matter/matter_controller) example as a hub in the house if you want remote control when the phone is not on the home network.

For the full picture, see the [Matter Fabric Support overview](https://docs.rainmaker.espressif.com/docs/product_overview/integrated_solutions/matter-fabric/overview).

## Summary

ESP RainMaker Matter Fabric Support is how you keep Matter’s interoperability in the home, and still own the rest: the app, the end-user accounts, and remote control when no one is home. Start from the open-source ESP RainMaker Home app, put your own logo and UI on it, deploy the cloud privately, and that circle becomes yours—including Matter products from other makers, not only your own. You can run everything on RainMaker, or plug the same Fabric pieces into a cloud you already have. Either way, evaluation is a phone app and a Launchpad-flashed light, and the path from there to your own ecosystem is the same stack.

For more information, please [contact us](https://www.espressif.com/en/contact-esp-rainmaker).
