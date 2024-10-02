---
title: "Matter: Improvements to Espressif DAC Provisioning Service"
date: 2024-10-01
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kedar-sovani
tags:
  - Esp32
  - IoT
  - Matter
---
[Espressif’s Secure Manufacturing Service](https://blog.espressif.com/accelerating-matter-device-manufacturing-2fcce0a0592a), which was launched last year, has assisted many customers in simplifying their manufacturing. Since a year from launch, we worked with hundreds of customers and served millions of modules that were manufactured with this service.

This service lets customers order modules from Espressif such that they are pre-programmed with all the Matter-specific security configurations, firmware, and other device-unique credentials and certificates that should be flashed on the modules. This saves organizations hassle and time from building their own manufacturing scripts and back-and-forth with factory lines.

Initially, we had been running a VID-scoped PAA (Product Attestation Authority). Now, Espressif is an approved signing authority for a [Non-VID scoped PAA](https://csa-iot.org/certification/paa/#:~:text=trust%40dreamsecurity.com-,Espressif%20Systems) (Product Attestation Authority) also called as Open PAA.

## What does being a non-VID scoped PAA mean?

Effectively, we can now support workflows that we previously were not able to support, viz:
- Secure Matter Manufacturing in your Factory (Matter DACs and device-unique data)
- Upgrading in-field devices to support Matter by generating and delivering DACs securely

## Matter Manufacturing in your Factory

We announced support for [Accelerated Matter Manufacturing](https://blog.espressif.com/accelerating-matter-device-manufacturing-2fcce0a0592a) last year. This allowed organizations to accelerate the manufacturing of their Matter devices, by allowing Espressif to pre-program the Device Attestation certificates (DACs), the firmware, and security configurations on modules before being shipped out.

One request we kept getting was a provision to perform this manufacturing in the customer’s factory of choice. This is now possible with our latest update. We are currently working with select customers to enable their factories to perform Matter manufacturing by themselves. If you are interested in this, please [reach out to us](mailto:matter-pki@espressif.com) for the next steps.

The most important part of this is having the ability to securely deliver cryptographically signed Device Attestation Certificates (DACs) to the modules without their private key ever leaving the module.

The typical workflow is shown in the following diagram.

{{< figure
    default=true
    src="img/matter-1.webp"
    >}}

## Upgrading In-field Devices to Matter

We also support delivering of DACs to in-field devices, that wish to now incorporate Matter support. For this scenario, it is essential that the in-field devices have a mutually authenticated secure connection to some device cloud platform. The cloud platform is expected to act as the trust broker for the in-field devices. The secure DAC delivery in this case happens as shown in the following diagram.

{{< figure
    default=true
    src="img/matter-2.webp"
    >}}


If you are working on building Matter products, please [reach out to us](mailto:matter-pki@espressif.com) to check how this aligns with your product deployment workflow.


