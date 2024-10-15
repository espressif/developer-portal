---
title: "Matter: Multi-Admin, Identifiers, and Fabrics"
date: 2022-01-18
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kedar-sovani
tags:
  - IoT
  - Esp32
  - Matter

---
[*Espressif Matter Series*](/blog/matter)* #6*

[This is article #6 in the [Espressif Matter Series](/blog/matter) of articles. You may read the first part [here](/blog/what-does-matter-mean-to-you).]

In the previous articles we talked about Matter devices communicating with each other by themselves, or Matter devices participating in multiple ecosystems *simultaneously.*

{{< figure
    default=true
    src="img/matter-1.webp"
    >}}

As you can see in the image here, this lightbulb is part of 2 distinct ecosystems, green and red. Each of these ecosystems don’t know about the other, and they are powered by 2 separate organisations (Org1 and Org2).

This feature, called multi-admin, is a much desirable feature of the smart-home. This is particularly desirable because people in the same family/home may be comfortable with their own ecosystems of choice, and would love the same device be part of all of these.

The question is how do these devices identify and authenticate themselves to each other, and who controls this configuration? This is the topic of today’s article.

## Operational Credentials

Matter uses PKI to facilitate identity.

Every node in a Matter network has a __Node Operational Certificate (NOC)__ . This X.509 certificate encodes a unique identifier (Node Operational Identifier) that is used to identify this node on the network.

{{< figure
    default=true
    src="img/matter-2.webp"
    >}}

When a Matter node is part of multiple ecosystems, it has multiple of these Node Operational Certificates (one for each ecosystem it supports). As you may notice in the diagram below, the lightbulb, has two NOCs and hence has 2 Node Identifiers, *xyz* for the green ecosystem and *PQR* for the red ecosystem.

The NOC and the node identifier are valid within the scope of that particular ecosystem which it is a part of. In Matter terminology, this is called a __Matter Fabric__ . Thus in the above diagram the lightbulb is part of 2 Matter fabrics, and it has a node id *xyz *in Matter fabric green, and node id *PQR *in Matter fabric red.

A Matter node’s resources (CPU/RAM) may decide how many simultaneous Fabrics can it support.

Every Fabric will also have a __Root CA Certificate__  associated with it. This CA certificate is used to validate the identities of other nodes (validate other’s NOCs) in the Fabric. For example, the green Fabric’s Root CA Certificate is what the lightbulb will use to validate that a request is really coming from the node id *abc *on the green fabric.

## Commissioning

Now who does the configuration of the Fabric, the NOC and the Root CA Certificates on a Matter node?

Every Matter node begins its participation in a Matter network after it is __commissioned__  (the initial configuration of the device) by a __commissioner__  (say a phone app that configures the device).

{{< figure
    default=true
    src="img/matter-3.webp"
    >}}

During the process of commissioning, the commissioner will provide the node with the Node Operational Certificate (NOC) and the Trusted Root CA Certificate. This is when we say that the bulb has joined the Matter Fabric green (technically Matter Fabrics have a 64-bit identifier, we are just using *green* for convenience here).

## The Second Matter Fabric

How does the device then join the second Matter Fabric?

If you are the admin of a Matter device, you could ask the device to open up its commissioning window again, after it has been commissioned. This allows other ecosystems to commission the Matter node and make it part of their own Matter Fabric.

## Access Control List

Once any node can verify identities on the network, the other step is Access Control. Every Matter node has an Access Control List which specifies who (which NOC) can do what (read/write/invoke on endpoint x, cluster y) on this Matter node.

When a Matter phone app controls a Matter lightbulb,

- the lightbulb will have a set of permissions defined through ACLs
- when an action is executed on the lightbulb, the lightbulb will first verify the identity of the phone app using the phone app’s NOC and the Trusted Root CA that was installed on the bulb
- the lightbulb will then check the ACLs to ensure that this Node Identifier (the phone app) is allowed to perform the specific action

## Matter Ecosystems

As highlighted above, Matter ecosystems allow you to create and distribute Node Operational Certificates to devices and thus build a Matter Fabric of participating devices. You may build additional innovative features on top of these.

These features could be allowing remote control of these devices, controlling these devices through your own display controller, or say, a voice controller.

Espressif is working on creating a solution for Matter ecosystems that you can deploy as *your own* Matter ecosystem. This solution will incorporate all the building blocks that will be required to build such an ecosystem, with hooks provided to extend it further to add any innovative features that you have in mind. Please reach out through our sales channels for more information on the same.
