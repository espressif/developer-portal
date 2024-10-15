---
title: "RainMaker Projects: Firmware Considerations"
date: 2020-05-01
showAuthor: false
featureAsset: "img/featured/featured-rainmaker.webp"
authors:
  - kedar-sovani
tags:
  - Rainmaker

---
Recently we released [ESP RainMaker](https://rainmaker.espressif.com) that easily allows makers to build connected devices. Beyond the part of connecting with the phone applications, the way the applications are structured makes it much easier to build an easy to distribute firmware. Many of these features are the guidelines that are part of the [ESP-Jumpstart](https://docs.espressif.com/projects/esp-jumpstart/en/latest/) framework. Let’s look at some of these features.

## Wi-Fi Network Configuration

In many projects, the Wi-Fi network’s credentials (SSID/Password) are embedded within the code itself. This makes it harder to make the project easily usable by others.

RainMaker applications utilise the [Wi-Fi Provisioning](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/provisioning/provisioning.html) firmware component, that lets users configure the Wi-Fi SSID/passphrase into the device securely over the SoftAP/BLE interface. This configuration can easily be done by users with iOS/Android phone apps. The phone applications for both, iOS and Android, with full source-code, are available for easy customisation and integration.

{{< figure
    default=true
    src="img/rainmaker-1.webp"
    >}}

{{< figure
    default=true
    src="img/rainmaker-2.webp"
    >}}

{{< figure
    default=true
    src="img/rainmaker-3.webp"
    >}}

## QR Code — Security with Proof of Possession

The Wi-Fi provisioning IDF component includes an optional field called *pop (proof of possession).* The proof-of-possession field is a per-device unique secret, that only a person with physical possession of the device has access to. The Wi-Fi provisioning step validates that the user has access to this secret before initiating the provisioning. This ensures that when the device is being provisioned, your neighbour can’t just configure it to connect to their own Wi-Fi network (since they don’t have access to the proof of possession).

Many makers hesitated from using this, since it increases a step in the end-user’s device provisioning user-experience: the users had to look-up and enter this proof of possession secret into the phone-apps.

The RainMaker agent makes it much easier to include the proof of possession handling by embedding it in the QR code. Each device has a unique QR code, which is displayed on the device console, or can be easily printed on a sheet of paper.

## Reset to Factory

This is a common feature requirement, so users can erase the earlier configuration and re-configure the device with updated settings. In RainMaker applications, all the configuration information, like the Wi-Fi credentials, is stored in an NVS partition.

Implemented like this, the reset-to-factory is nothing but a simple *nvs-erase* operation.

## Manufacturing Partition

Many devices want to have some per-device unique information that should be configured at the time of building the device. This may include the unique key that the device’s use to authenticate with the RainMaker service, or any other information like UUID, and other secrets. We don’t want this information to be erased with a *Reset to Factory *action.

The RainMaker infrastructure uses a “[manufacturing](/blog/building-products-creating-unique-factory-data-images)” partition for storing such unique information. This ensures that,

- this unique information isn’t erased across a reset-to-factory event
- the device firmware is common across all devices, since all unique information is partitioned out
- IDF already contains the [mass_mfg ](https://github.com/espressif/esp-idf/tree/master/tools/mass_mfg)utility that lets you build these mfg partition easily and in large numbers

## Over the Air Firmware Upgrades

The default partitioning mechanism for RainMaker applications includes the active-passive firmware partition support from IDF. So currently, you can easily create a RainMaker parameter (of type *string*) that accepts a URL as the value. And then once you get data on this parameter, you can initiate upgrade from that link using the [esp_https_ota](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/esp_https_ota.html) component.

## Remote Sync

The RainMaker agent internally synchronises the state of the device with the RainMaker service over MQTT/TLS.

The agent manages the initial communication required to [associate](https://rainmaker.espressif.com/docs/user-node-mapping.html) the end-user and the device. The other part of this implementation is implemented in the phone applications.

Additionally the agent syncs the device state. A concept of “device parameters” is used to identify the parameters of the device (power, brightness, speed etc.). Any local changes to these parameters are published to the RainMaker service, while any remote updates are delivered to the application using a callback.

---

Those were some of the highlights of the considerations that have been taken on the RainMaker applications so far. If you have a request to add as a feature, or believe we missed any other considerations, please let us know in the comments below.
