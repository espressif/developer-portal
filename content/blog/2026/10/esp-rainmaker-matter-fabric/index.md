---
title: "ESP RainMaker Matter Fabric Support: A More Complete Solution for Branded Ecosystems"
date: 2026-10-16
summary: "ESP RainMaker Matter Fabric Support helps manufacturers build and operate branded Matter ecosystems with device management, local control, and cloud services—while keeping control of their apps, cloud, and long-term product strategy."
tags:
  - Matter
  - ESP RainMaker
  - announcement
  - smart home
authors:
  - "iot-solution-team"
---

As Matter becomes the interoperability standard for smart homes, device manufacturers need products that work across mainstream Matter ecosystems—without giving up their own apps, cloud services, and user relationships. ESP RainMaker has supported Matter Fabric for some time. This update makes that support more concrete and complete: device management, local control, and cloud services so customers can build and operate branded Matter ecosystems with greater clarity from evaluation to production.

## What is Matter Fabric?

A Matter Fabric is a local, virtual network that spans Wi-Fi, Thread, Ethernet, and other physical transports in a home. It organizes Matter devices, controllers, and commissioners (such as mobile apps) into a single Fabric for secure device-to-device communication on the local network. Matter also supports Multi-Admin and Joint Fabric for cross-ecosystem management.

ESP RainMaker takes Fabric management to the cloud with a cloud-native approach, so customers can run a private, branded Matter ecosystem on top of that local Fabric.

## What ESP RainMaker Matter Fabric Support provides

ESP RainMaker parses the Matter protocol in the cloud, covers Matter product categories, and maps Matter clusters and attributes to a human-readable Thing Model. Teams can operate and manage Matter devices through the cloud without building their own protocol processing stack—lowering the barrier from proof of concept to product deployment.

**PKI and certificate management.** During commissioning, RainMaker can issue Node Operational Certificates (NOCs) for the Fabric. Device identity across the lifecycle is managed in the cloud, so customers do not need to operate a separate certificate system for Fabric operations.

**User-level Fabric management.** A user can own multiple Fabrics, each bound to their account. The platform covers create, configure, share, and delete, plus the full [sharing-invitation flow](https://docs.rainmaker.espressif.com/docs/product_overview/features/group_sharing)—useful when end users need network isolation across homes or multi-dwelling deployments.

**App and SDK.** Built on a React Native stack, the [ESP RainMaker Home](https://docs.rainmaker.espressif.com/docs/dev/phone-app/home-app/home-app-get-started#download-esp-rainmaker-home) app provides a customizable starting point for smart home applications. It already supports Matter commissioning (BLE or QR code), local control on the LAN, and remote control through a cloud-connected controller. [`@espressif/rainmaker-matter-sdk`](https://docs.rainmaker.espressif.com/docs/sdk/rainmaker-matter-sdk/overview) exposes the same capabilities—Fabric management, commissioning, certificates, and challenge-response—for branded apps built on [`@espressif/rainmaker-base-sdk`](https://docs.rainmaker.espressif.com/docs/sdk/rainmaker-base-sdk/overview).

**Matter controllers.** Matter is fundamentally a local protocol. Physical controllers—touch panels, speakers, TVs, routers, or even end devices such as smart plugs—deliver low-latency local control. Connected to ESP RainMaker, they also keep a persistent cloud link so the home gains remote control. Espressif provides controller examples based on ESP-Matter and ESP RainMaker, including ESP32-P4 touch-panel hubs and ESP32-S31 voice speakers.

{{< figure
    src="img/esp-rainmaker-matter-topology.webp"
    alt="ESP RainMaker Matter topology: ESP RainMaker Cloud with PKI and NOC, device management, Matter Fabric management, and cloud-to-cloud API; the RainMaker app commissioning over BLE and QR code with local and remote control; and a Matter controller and Thread Border Router connecting Matter-over-Wi-Fi and Matter-over-Thread devices"
    caption="ESP RainMaker Matter topology"
    >}}

## Two integration models

**Unified management on ESP RainMaker.** Use RainMaker as the IoT cloud for both Matter and non-Matter devices. The serverless backend, open-source mobile apps, voice-assistant integrations, and device firmware SDKs are ready to use. This path suits brands that want Matter quickly without operating a separate IoT cloud.

**Cloud-to-cloud integration.** Customers who already have a mature business cloud can add Matter Fabric Support as modules—Fabric management, PKI issuance, and Matter protocol parsing—without replacing the rest of their stack. The [Matter Fabric Interface](https://docs.rainmaker.espressif.com/docs/product_overview/integrated_solutions/matter-fabric/interface) is an optional cloud API add-on for this integration, exposing Matter Fabric capabilities through APIs. It can also be used in the Unified RainMaker model when a product has specific API integration needs, but it is not required for standard RainMaker integration.

ESP RainMaker is built on AWS serverless architecture. Private deployments keep data under the customer’s control and can scale to large device fleets.

## Thread devices on the same Fabric

A Thread Border Router (TBR) connects Thread devices to the rest of the home network so Matter-over-Thread products can join the same Fabric as Wi-Fi Matter devices. TBR support can be enabled in the [`matter_controller`](https://github.com/espressif/esp-rainmaker/tree/master/examples/matter/matter_controller) example, so one hub can act as both a Matter controller and a TBR. The ESP RainMaker app can add a TBR, keep Thread network information, and use that information during Matter commissioning.

## Matter-ready upgrades for existing devices

Non-Matter devices already in the field can be upgraded to Matter over OTA. RainMaker can deliver DACs and Matter onboarding payloads from the cloud, with APIs to retrieve pairing codes, so products can join the Matter ecosystem without a hardware redesign.

Espressif also provides DAC provisioning (including as a CSA-authorized PAA), certification assistance with ATLs, and complementary solutions such as Thread Border Router, Matter Bridge, and Matter controllers.

## Getting started

You do not need a custom app to evaluate the solution:

1. Install the [ESP RainMaker Home](https://docs.rainmaker.espressif.com/docs/dev/phone-app/home-app/home-app-get-started#download-esp-rainmaker-home) app to commission devices, manage Fabrics, and try local and remote control.
2. Use the [RainMaker Matter App SDK](https://docs.rainmaker.espressif.com/docs/sdk/rainmaker-matter-sdk/overview) when you are ready to bring the same flows into a branded app on `@espressif/rainmaker-base-sdk`.
3. Flash the latest [`matter_controller`](https://github.com/espressif/esp-rainmaker/tree/master/examples/matter/matter_controller) firmware as a Matter controller for demos and as a starting point for product development. In the app SDK, this is the [RainMaker Controller](https://docs.rainmaker.espressif.com/docs/sdk/rainmaker-matter-sdk/Controlling/RemoteControl/rainmaker-controller) that relays Matter operations when the phone is not on the home LAN.
4. Choose unified RainMaker management, or cloud-to-cloud via the [Matter Fabric Interface](https://docs.rainmaker.espressif.com/docs/product_overview/integrated_solutions/matter-fabric/interface). See the full [Matter Fabric Support overview](https://docs.rainmaker.espressif.com/docs/product_overview/integrated_solutions/matter-fabric/overview) for details.

## Summary

ESP RainMaker Matter Fabric Support addresses the practical challenges of building a branded Matter ecosystem—from NOC/PKI and Matter protocol parsing to Fabric lifecycle management, app/SDK adaptation, and cloud-connected controllers (including Thread on the same Fabric when a TBR is present). Whether you adopt a turnkey path on ESP RainMaker or integrate Fabric modules into an existing cloud, you can move from evaluation to product architecture with lower R&D overhead while staying interoperable with mainstream Matter ecosystems.

For more information, please [contact us](https://www.espressif.com/en/contact-esp-rainmaker).
