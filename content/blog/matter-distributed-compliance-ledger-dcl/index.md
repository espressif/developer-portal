---
title: "Matter: Distributed Compliance Ledger (DCL)"
date: 2022-03-24
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - shu-chen
tags:
  -  Matter
  - Espressif
  - IoT
  - ESP32
---
[Espressif Matter Series](/blog/matter) #8

As Matter promised, Device Manufacturers (Vendors) don’t have to build their own Phone APP or Cloud service if they don’t want to. A Matter device will be able to work with all Matter enabled ecosystems seamlessly.

But how could the Matter device’s information be published, so that it can be retrieved by Matter ecosystems, in a secure manner? Today, we will talk about the __Distributed Compliance Ledger__  (DCL) in Matter.

## What is DCL?

The Matter DCL is a cryptographically secure, distributed storage network based on blockchain technology. It allows Connectivity Standards Alliance (CSA) and authorized Vendors to publish information about their Matter devices. This information can then be retrieved using DCL clients.

__What kind of information will be stored in DCL?__

The device information is divided into five databases (it’s called schemas in DCL):

- __Vendor Schema:__ Provide general information about a Vendor such as the Company legal name, Preferred brand name associated with the VendorID, the Landing page URL for the vendor, etc.
- __DeviceModel Schema:__ Provide general information about a device, such as ProductName, Product ID, PartNumber, Commissioning info, etc. This information is shared across all software versions of the product.
- __DeviceSoftwareVersionModel Scheme:__ Provide software version specific information. e.g Release Notes URL, FirmwareDigests, OTA Software Image URL, etc.

> Note: Only the URL is stored in DCL, so vendors need to store the OTA images in their own location and only publish the image URL to DCL.

- __Compliance Test Result Schema:__ Provide compliance and test result data about the device.
- __PAA Schema:__ Provide a list of Product Attestation Authorities Certificates for the approved PAAs (learn more from [Matter security model](/blog/matter-security-model)).

__How will this information be used by Matter ecosystems?__

With all this device information stored in DCL, Matter ecosystems may consult the DCL for:

- checking device certification compliance status
- verifying Device Attestation Certificate (DAC) (by tracing back to it’s PAA)
- getting commissioning instructions, links to manuals, and product information
- checking OTA status and upgrade the device to latest firmware
- ……

## How DCL Works?

The DCL is a network of independent servers, which are owned and hosted by CSA and its members. Each server holds a copy of the database containing the information about Matter devices, and they communicate with each other using cryptographically secure protocol.

Does every Vendor have to setup its __own__  DCL server? No.

CSA provides DCL server setup, which allows public access to DCL information using DCL client, it also allows members with write access to publish their Matter devices’ information to DCL.

Vendors could also setup dedicated DCL server. The Vendor’s setup will be available to this Vendor’s clients only. A Vendor MAY choose to grant its DCL server access to others.

__Write access to DCL is restricted__

- Vendors can add new device models that belong to the VendorID that is associated with the public key of that vendor (either via CSA’s DCL server or its own DCL server). VendorID is associated to the vendor public key during vendor account creation process.
- Vendors can update a subset of existing device model information, such as product name, product description, firmware and hardware info. Updates are only allowed if the device is associated with the same vendor account.
- CSA Certification Center can write or revoke the Compliance status of a device model to the Ledger.

__Read access from DCL is public__

- Read DeviceModel info, including firmware and hardware versions from the DCL.
- Read the Device compliance state from the DCL.
- Read the Product Attestation Authorities certificates.

## Typical Workflow

Let’s go through an example, say there are following roles:

- Connectivity Standards Alliance (CSA)
- Vendor A
- Bulb B (made by A)
- Test House T
- Ecosystem G
- Ecosystem H
- Consumer C

The typical workflow looks like:

1. Vendor A is a CSA member and has enrolled its public key to write to DCL. A makes a Matter Bulb B, and uses CSA’s DCL server to add B’s information to DCL.
2. Vendor A sends some Bulbs to Test House T, T performs the Matter certification tests on B, and sends the test results to CSA. CSA checks the test results, if pass, CSA adds the compliance status for Bulb B in DCL.
3. Consumer C buys a Bulb B from the market, C commissions the Bulb B using the commissioner from Ecosystem G, so B joins G’s Matter fabric, and works together with other devices in the same fabric. The commissioner consults the DCL for certification status of Bulb B during commissioning.
4. Someday, A implements a cool feature for Bulb B, A adds the new software version information in DCL. G has Matter OTA provider support in their device, so it can assist B to finish the OTA process.
5. Someday, C is interested in some services provided by Ecosystem H, C commissions the Bulb B to H’s fabric. Then Bulb B can work together with both Ecosystem G and H natively.

Consumer C enjoys all these seamlessly.
