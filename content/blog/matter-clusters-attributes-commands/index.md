---
title: "Matter: Clusters, Attributes, Commands"
date: 2021-11-30
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kedar-sovani
tags:
  - Esp32
  - Matter
  - IoT

---
[*Espressif Matter Series*](/blog/matter)* #2*

[This is article #2 in the [Espressif Matter Series](/blog/matter) of articles. You may read the first part [here](/blog/what-does-matter-mean-to-you).]

In the previous article we looked at [what does Matter mean to you](/blog/what-does-matter-mean-to-you). Today, let’s talk about an important part of Matter, its data model. The data model of Matter defines the typical elements that go into making of a typical Matter *node*. As a device developer, you would typically express the capabilities of your device through this data model.

{{< figure
    default=true
    src="img/matter-1.webp"
    >}}

For better understanding, let’s consider we are building a luminaire that has 2 lights: one dimmable, one simple on/off.

## Elements of Matter

The following diagram shows a simplistic view of how this can be represented in the Matter’s data model.

{{< figure
    default=true
    src="img/matter-2.webp"
    >}}

__Node:__  In our case, the luminaire is a node. This is a uniquely network addressable entity that exposes some functionality. This is typically a physical device that a user can recognise as a whole device.

__Endpoint:__ Each node has a number of endpoints. An endpoint could be thought of like a virtual device that provides services that could be logically grouped together. In our example above, our luminaire has 2 separate lights, one dimmable, one on-off. Each of these will have an endpoint of their own.

Notice that endpoint 0 is reserved. This contains certain services that are applicable to the entire node. We will look at what this contains later in the section.

The Matter specification defines certain common __Device Types__ . For example, the On/Off Light and Dimmable Light, that you see within endpoints 1 and 2 are standard device-types defined by Matter. A device type is used to indicate a set of commonly available functionality.

__Clusters:__  A cluster groups together commonly used functionality in a reusable building block.

In our diagram, our first light (endpoint 1), is shown with 2 standard clusters, On/Off cluster, and Level Control cluster. The On/Off cluster provides a service to switch on or off certain things. The Level Control cluster provides a service that enables configuring levels of certain things. In our case, the On/Off cluster helps switch on or off the light and the Level Control cluster helps configure the brightness of our light.

If our light had supported controlling the colour, it would have another standard cluster called the Color Control cluster.

Our second light (endpoint 2), is just an on/off light, hence it only includes the On/Off cluster.

As you may notice from the diagram, clusters contain attributes and commands.

__Attributes:__  Attributes indicate something that can be read or written to. In our example, the OnOff cluster has an OnOff attribute that maps to the actual state of the device. Similarly, in the Level Control cluster there is a Current Level attribute that maps to the current level that is set.

Attributes may be persistent or volatile (lost across reboots), and also read-only or read-write.

The Matter specification includes a list of data types that may be possible for attributes. These include the typical, boolean, integers (signed/unsigned), floats, enumerations, strings, or even collections (lists or structures).

__Commands:__  A cluster command provides an ability to invoke a specific behaviour on the cluster. A command may have parameters that are associated with it. In our diagram above, the On/Off cluster has a *Toggle* command that toggles the current On/Off attribute of the cluster. The Level Control cluster has commands like *MoveToLevel, Move, Step*, that move the current level of the cluster in specified ways.

These are the typical elements of the Matter data model. The Matter specification provides a list of standard clusters and their attributes and commands. You may peruse this to check how it aligns with the capabilities of your device.

Now that we’ve looked at the common elements in Matter’s data model, let’s understand another concept Cluster servers and clients.

## Cluster Servers and Clients

Every Matter cluster has a Cluster Server, and a Cluster Client counterpart. In the diagram above, our device included Cluster Servers, as they provide the service. Interaction with these is done through Cluster Clients.

The following diagram demonstrates this well:

{{< figure
    default=true
    src="img/matter-3.webp"
    >}}

- Here a Matter Dimmer Switch implements OnOff and Level Control Cluster __clients__ . These clients talk to the corresponding __servers__  on the light, to control them.
- We also have a Matter Simple Switch, that only implements an OnOff Cluster client.
- Finally, a phone app that controls the same Light will also implement the relevant cluster __clients__  to control the light.
- Note here that the Dimmer Switch, Simple Switch, Light as well as the phone-app, are all Matter nodes.

Let’s look at some other examples that drive the point home.

{{< figure
    default=true
    src="img/matter-4.webp"
    >}}

{{< figure
    default=true
    src="img/matter-5.webp"
    >}}

## The Endpoint 0

Finally, earlier we talked about the endpoint 0, this is an endpoint with a “Root Node” device type. This is a special endpoint that has clusters that are specific to this entire Matter node. Some of the typical clusters that are part of this endpoint include:

- __Basic Information Cluster Server__ : Provides basic information about the node, like firmware version, manufacturer etc
- __ACL Cluster Server__ : Allows configuration of the Access Control Lists for this node.
- __Network Commissioning Cluster Server__ : Allows configuration of a network (Wi-Fi, Ethernet, Thread) on the node.

[Note that the Matter specification defines certain mandatory clusters that should be part of any endpoint. Similarly, every cluster may have certain mandatory attributes and commands as defined in the specification. For the sake of brevity, we have omitted listing all of them here.]

This was a short overview of the commonly used elements of the Matter Data Model. Hope it helps you to envision how your device’s capabilities aligns with the Matter Data Model.

This article is a part of a series of articles [*Espressif Matter Series*](/blog/matter). You may read the next article that talks about [Matter: Device-to-Device Automations](/blog/matter-device-to-device-automations).
