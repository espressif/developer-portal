---
title: "Announcing Espressif's Aliro SDK"
date: 2026-07-16
showAuthor: false
authors:
  - wang-qixiang
tags:
  - Matter
  - Aliro
  - NFC
summary: "Aliro brings mobile access credentials to Espressif devices and is compatible with Matter. We are excited to announce esp-aliro, an SDK that enables support for the Aliro standardized protocol on Espressif SoCs."
---

## Introduction

Developed by the Connectivity Standards Alliance (CSA), [Aliro](https://csa-iot.org/all-solutions/aliro/) is a standardized protocol for mobile access credentials. It enables smartphones and wearables to act as digital keys for smart locks and access readers across residential, enterprise, hospitality, and campus scenarios.

Aliro supports multiple transports and physical interaction models. Products can choose the transport that best fits their user experience:

- **NFC:** for tap-to-unlock
- **Bluetooth LE:** for longer-range user-initiated access
- **Bluetooth LE + UWB:** for secure hands-free access

At the access point, Aliro defines two primary roles:

- **User Device:** a phone or wearable that stores and presents an access credential.
- **Reader:** the embedded device at a door, gate, elevator, turnstile, cabinet, or other access point. It verifies the information provided during an Aliro transaction and decides whether to grant access.

## Aliro Configuration and Transaction

### Reader Configuration

Before the Reader can validate credentials, a trusted access-management system or product configurator provisions its key pair and group identifier. This provisioning takes place outside the local Aliro access transaction.

### Access Transaction Flow

To verify credentials and make an access decision, the Reader and User Device initiate an access transaction that always starts with the Expedited phase. The Expedited phase can run in **expedited-standard** or **expedited-fast** mode. If the Reader needs signed access data, it can continue with the optional **Step-up phase**.

- **Expedited-standard phase**

The expedited-standard phase is mandatory. It establishes fresh session keys from ephemeral key material, authenticates the Reader to the User Device, and lets the User Device return an authenticated credential proof to the Reader.

- **Expedited-fast phase**

After a successful expedited-standard phase, the Reader and User Device can use a previously established persistent key to reduce the number of commands in a later transaction. If the Reader cannot validate the cryptogram, it can fall back to expedited-standard or terminate the transaction.

- **Step-up phase**

The Step-up phase is optional and can only follow the expedited-standard phase. The Reader uses this phase when it needs an Access Document or Revocation Document before making the final access decision.

## Espressif's Aliro SDK

We are excited to introduce Espressif's Aliro SDK, [esp-aliro](https://github.com/espressif/esp-aliro), with initial support for Aliro over NFC. Bluetooth LE and UWB support are planned for a future release.

The solution enables developers to build interoperable smart locks and access control products using Espressif Wi-Fi or Thread SoCs, together with an NFC frontend and a lock actuator. The SDK supports all Matter-enabled Espressif chipsets, including the ESP32, ESP32-C, ESP32-S, and ESP32-H series.

{{< figure
    src="img/aliro-solution-block-diagram.webp"
    alt="Block diagram of an Aliro Reader solution, showing an Espressif SoC, NFC frontend and antenna, lock actuator, User Device, access-management configurator, and door or access point"
    caption="Aliro Reader solution architecture and the actors around it"
    >}}

To get started, refer to the [Aliro reader example](https://github.com/espressif/esp-aliro/tree/main/examples/aliro_reader), which demonstrates how to build an Aliro Reader and test with an Aliro User Device.
In this example, the Aliro Reader is configured with a fixed key pair and group identifier. In a production access point, an access manager should configure the Reader through Matter or another application protocol.

## Aliro + Matter

Matter and Aliro are complementary. Matter provides the smart home commissioning, control, and management path via Wi-Fi or Thread, while Aliro provides the local digital-key transaction between the User Device and Reader.

{{< figure
    src="img/matter-aliro-architecture.webp"
    alt="Diagram of Aliro and Matter implementations for Wi-Fi and Thread devices with NFC modules, showing Matter configuration and Aliro NFC tap-to-unlock access"
    caption="Aliro and Matter for Wi-Fi and Thread devices"
    >}}

A Matter administrator can set or clear the Aliro Reader's configuration using the `SetAliroReaderConfig` and `ClearAliroReaderConfig` commands in the Door Lock cluster.

{{< figure
    src="img/matter-aliro-reader-config.webp"
    caption="Aliro Reader Configuration and Matter Control"
    >}}

For an implementation example, see the [Matter door lock example](https://github.com/espressif/esp-matter/tree/main/examples/door_lock), which demonstrates a Matter-compatible, Aliro-enabled door lock.
For easier setup, we recommend the [M5-Unit-NFC](https://docs.m5stack.com/en/unit/Unit_NFC) as the NFC frontend.
The example can be run on any Espressif chipset that supports Matter. It supports Matter over Wi-Fi for high-speed connectivity and Matter over Thread for low-power applications.
