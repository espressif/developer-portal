---
title: Accelerating Matter Device Manufacturing
date: 2023-02-19
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----2fcce0a0592a--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Faccelerating-matter-device-manufacturing-2fcce0a0592a&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----2fcce0a0592a---------------------post_header-----------)

--

[Espressif Matter Series](/matter-38ccf1d60bcd) #9

Given the latest developments in the IoT industry, there is a strong rush towards building Matter enabled smart devices. (If you are new to Matter, please read up about Matter in our series of blog posts [here](/matter-38ccf1d60bcd)).

We have been actively working on creating solutions that help accelerate our customers to build and launch Matter-enabled devices faster and that too in a cost-effective way. An often overlooked, but important, part of the device production process is how fast can you manufacture devices on the line. This becomes especially important in the case of Matter, which places some unique requirements on each device.

This blog post will talk about Espressif’s Matter Pre-Provisioning Service that allows you to quickly manufacture Matter-enabled devices.

## Matter Pre-Provisioning Service

> Espressif’s Matter Pre-Provisioning Service allows you to order modules from Espressif that are securely pre-programmed with the unique details that every Matter device needs to have. Once you receive the modules, you can directly put them on your PCBs and you are ready to go. Everything from DAC, to secure enablement is already taken care of on the modules.

Let’s understand why such a service is even required and what it offers.

## 1. Device Attestation

When any Matter device is being commissioned, the commissioning agent (phone app) will ensure that this is a genuine Matter device. This process is called Device Attestation.

For Device Attestation to happen, all Matter devices must have a unique set of certificates, called Device Attestation Certificates (DAC), that are programmed in them (You may read more about DACs in the [Matter Security Model](/matter-security-model-37f806d3b0b2) post). The DACs ascertain that the product, that is being commissioned, genuinely comes from Vendor X.

These DACs are X.509 certificates that should chain back to a valid Product Attestation Authority (PAA) that is registered with the Connectivity Standards Alliance (CSA). This ensures that only some authority that is approved by the CSA can generate and distribute these DACs, thus ensuring authenticity of the devices.

Espressif is an authorised PAA that can generate DACs for your devices. You can request modules that are securely pre-provisioned at Espressif’s end with the DACs created for your devices, before they are shipped out to you. Care is taken that the private key of the DACs never leaves the module, and the modules are securely locked before they are shipped out.

For implementing this, Espressif uses 2 components:

This ensures that the entire process is maintained and operated with the highest levels of security and compliance.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*QWMY8VLw-miQmu2ulsuFrQ.png)

## 2. Uniqueness

Matter manufacturing requires a few unique objects to be programmed on each device. This includes the DACs as we discussed earlier. Every Matter device also requires a unique QR Code that allows it to get commissioned. Unique secrets corresponding to this QR Code should also be programmed into each device that allow apps to securely commission the device.

As you may be aware, mass flashing common images on a high volume run is fairly easy. Having to program unique images per-device becomes costlier. Additionally, mapping those unique images, to the corresponding QR Code, that should be pasted on each device, is another task.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*g5AAdQqXBLtDHvOChkqCsg.png)

Espressif’s Matter Pre-Provisioning Service will configure the modules with the DACs and the appropriate authentication credentials that are required for the proper operation of Matter. We will provide a manifest file that captures the details that are configured on all the modules. This typically includes information about the MAC Address of modules, serial numbers, if any, and the corresponding QR Codes that should go along with these modules.

## 3. Security

Finally, the DAC Certificates and the operational secrets need to be protected on the device from unauthorized access. It must be ensured that only trusted firmware, that executes on the chipset, has access to the DAC certificate. This requires the enablement of __secure boot, flash encryption__  and other security settings on all the chipsets. The Espressif manufacturing process is set up in such a way that these features are enabled in Espressif’s factory, but still enabling customers to program their production and test firmware on their own.

Espressif’s Matter Pre-Provisioning Service will securely lock the modules, before being shipped out to you.

## 4. Firmware Flashing

Many of our customers also prefer that their modules are pre-programmed with their bootloader and firmware images (along with the other data that is configured so far).

If you opt for this option, you can point us to your signed bootloader and the signed firmware that should be pre-programmed on all the modules before locking and shipping them out to you.

We are very glad to see that this service is proving to be a significant accelerator for customers building Matter-enabled devices. If you are interested in this service, please reach out to [sales@espressif.com](mailto:sales@espressif.com) with your request.

This article is part of a series of articles [*Espressif Matter Series*](/matter-38ccf1d60bcd).
