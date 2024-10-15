---
title: "Matter: Bridge for Non-Matter Devices"
date: 2021-12-14
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - shu-chen
tags:
  - Matter
  - Zigbee
  - Espressif
  - IoT
  - Esp32

---
[*Espressif Matter Series*](/blog/matter)* #4*

Several big IoT ecosystems have announced integrated support for Matter, e.g., Amazon, Apple, Google and Samsung. It’s exciting to expect that more and more devices from multiple brands work natively together, under a bigger Matter ecosystem.

Meanwhile, people may have a question: There are many IoT products in the consumers’ home already, these can be the devices based on Zigbee, Z-Wave, BLE Mesh and others. Could these non-Matter devices work together with Matter ecosystem? The answer is YES.

Today, let’s talk about the Bridge feature in Matter.

## Matter Bridge Introduction

A Bridge serves to allow the use of non-Matter IoT devices in a Matter ecosystem (Matter Fabric). It enables the consumer to keep using these non-Matter devices together with their Matter devices.

{{< figure
    default=true
    src="img/matter-1.webp"
    >}}

The non-Matter devices are exposed as Bridged Devices to Nodes in the Matter ecosystem. The Bridge device performs the translation between Matter and other protocols so that the Matter nodes can communicate with the Bridged Devices.

Below is an example of Matter-Zigbee Bridge, it bridges two Zigbee lights to Matter ecosystem:

{{< figure
    default=true
    src="img/matter-2.webp"
    >}}

## Bridge Data Model

In the previous article [Matter: Clusters, Attributes, Commands](/blog/matter-clusters-attributes-commands), we talked about the Matter Data Model, below is a Data Model example of a Matter Bridge device.

{{< figure
    default=true
    src="img/matter-3.webp"
    >}}

- On Endpoint 0, the device type is defined as Bridge. The PartsList field lists all endpoints for bridged devices, each endpoint represents one device at the non-Matter side of the bridge.
- The Descriptor cluster on each endpoint provides information about the particular Bridged Device.

A Bridge may also contain native Matter functionality, for example, it may itself be a smart Thermostat having both Wi-Fi and Zigbee connection. The Thermostat is native Matter functionality, it is capable of sending heating and/or cooling requirement notifications to a heating/cooling unit. While the other endpoints represent the Bridged Devices.

{{< figure
    default=true
    src="img/matter-4.webp"
    >}}

Now, let’s look into the Matter-Zigbee Bridge example we mentioned in previous section.

{{< figure
    default=true
    src="img/matter-5.webp"
    >}}

Here is the workflow to control a Zigbee device on the phone with Matter protocol:

__Step-1.__  The Bridge, a device type defined in Matter, should follow the standard Matter commissioning process to join the Matter fabric.

__Step-2.__  The Matter-Zigbee Bridge Device should also join the Zigbee network. A bit different from Matter, the Zigbee specification does not mandate any standard commissioning process, it’s left to the device vendors to decide the workflow for distributing the link keys. The Install Code is the most common method since Zigbee 3.0.

__Step-3.__  Once the Bridge Device joins the Zigbee network, it will discover the supported devices in the Zigbee network by broadcasting the __Match Descriptor Request__  command. The command includes desired Profile, In-Clusters and Out-Clusters. In this example, it will ask something like “Who has an On/Off Light with OnOff Cluster? ”. The corresponding Zigbee devices will reply the __Match Descriptor Response__  with its network address included. For each matched Zigbee Light, the Bridge will add a dynamic endpoint, in Matter, which stands for the Bridged Zigbee Device.

__Step-4.__  The Bridge exposes all the Bridged Devices to the Matter fabric, which follows the __Operational Discovery__  method as defined by Matter specification (*stay tuned for the coming series talking about Discovery in Matter*).

__Step-5.__  Now the Controllers in the Matter fabric can control the lights in the Zigbee network with the help of Bridge.

Some Notes:

- Note 1: The interaction method in Step-2 and Step-3 is defined by device vendors and the protocol itself, which is out of Matter scope.
- Note 2: The Bridged Devices can be dynamic added or removed according to the keep alive mechanism in the non-Matter side network.

This was a typical workflow for bridging to a Zigbee network. The similar concepts will be applicable to other networks that we would be bridging to.

## Espressif Matter Bridge Solutions

Espressif, as an active member that supports Matter from the beginning, can offer the full spectrum of Matter protocol solutions for end-products with Wi-Fi or Thread connectivity, as well as for Thread Border Router and Bridge solutions using a combination of SoCs.

We offer both Matter-Zigbee and Matter-BLE Mesh bridge solutions with full functional software SDK support. A Matter-Zigbee Bridge uses two SoCs (Wi-Fi + 802.15.4), they are connected via a serial interface like UART or SPI, while a Matter-BLE Mesh Bridge can be done on single SoC with both Wi-Fi and BLE interfaces.

{{< figure
    default=true
    src="img/matter-6.webp"
    >}}

{{< figure
    default=true
    src="img/matter-7.webp"
    >}}

If you are interested in our Matter Bridge solutions, please contact our [customer support team](https://www.espressif.com/en/contact-us/sales-questions).
