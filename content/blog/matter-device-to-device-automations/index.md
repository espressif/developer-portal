---
title: "Matter: Device-to-Device Automations"
date: 2021-12-07
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - hrishikesh-dhayagude
tags:
  - IoT
  - Esp32
  - Matter

---
[*Espressif Matter Series*](/blog/matter)* #3*

[This is article #3 in the [Espressif Matter Series](/blog/matter) of articles. You may read the second part [here](/blog/matter-clusters-attributes-commands).]

In the previous article we looked at the data model of Matter. Today, let us talk about how Matter devices within a network can interact with each other leading to useful automations. For instance, you may want a light switch at your home to control one or more light bulbs. Or even a thermostat to turn on or off based on reports from the occupancy sensor.

This is a very interesting usecase that is not easily possible through the existing ecosystem protocols. Matter easily enables this. This doesn’t require intermediation from any cloud or phone apps to make it happen. Instead, it is all facilitated directly over the local network.

{{< figure
    default=true
    src="img/matter-1.webp"
    >}}

As mentioned in the data model article, every Matter cluster has a cluster server, and a cluster client counterpart. The communication happens between the client and server of the same cluster. As can be seen above, the OnOff cluster client on the switch can talk with the OnOff cluster server on the light to turn it on or off. And the end-user can configure which device can talk to which device(s) in their home.

For this interaction to happen, the switch should know the details about the light. This is achieved through __device binding__ . A binding represents a persistent relationship that informs a client endpoint of one or more target endpoints for a potential interaction. A user (through the Matter phone app) can establish binding between devices, regardless of the vendors they are from.

There are two ways through which device-to-device interaction can be accomplished:

## 1. Synchronous Control

Let’s go back to our example of the switch controlling the light that is shown above. For this, the switch additionally needs to have a Binding cluster server that offers the binding service. After a user binds the light to the switch, an action (on or off) on the switch results into corresponding action on the light. This scenario is illustrated below:

{{< figure
    default=true
    src="img/matter-2.webp"
    >}}

Similarly, a Dimmer Switch needs to have an OnOff client, a Level Control client and a Binding server to control a dimmable light.

## 2. Asynchronous Notification (Subscribe-Report)

This method facilitates receiving data reports from a publisher to a subscriber. The subscriber can __subscribe to attributes and/or events__  on the publisher.

The thermostat and occupancy sensor usecase mentioned above can be realised after the thermostat __subscribes to attributes__ of the sensor. First the user binds the thermostat to the occupancy sensor. Once done, the thermostat can subscribe to the sensor attributes and receive data periodically as well as when there is an activity (change in sensor attributes). This scenario is illustrated below:

{{< figure
    default=true
    src="img/matter-3.webp"
    >}}

This was an example of subscribing to attributes. Devices could also __subscribe to events__ . In the data model article, we talked about clusters having attributes and commands. Here, we introduce events which are also a part of clusters. Events capture every single change and convey it to the subscribed entity. A few examples of events include switch pressed, long press, and door opened.

This sums up the introduction to device-to-device communication in Matter along with the different ways in which it can be implemented.

This article is a part of a series of articles [*Espressif Matter Series*](/blog/matter). You may read the next article that talks about [Matter: Bridge to non-Matter Devices](/blog/matter-bridge-for-non-matter-devices).
