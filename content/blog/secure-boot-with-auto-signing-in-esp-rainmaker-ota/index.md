---
title: "Secure boot with auto-signing in ESP RainMaker OTA"
date: 2024-07-29
showAuthor: false
featureAsset: "img/featured/featured-rainmaker.webp"
authors:
  - piyush-shah
tags:
  - Esp32
  - Espressif
  - IoT
  - Secure Boot
  - Rainmaker

---
Security is one of the most important aspects of any IoT system and at Espressif, we take it very seriously. The ESP RainMaker platform offers a secure way to onboard a device onto Wi-Fi network and then control and monitor it through cloud. However, the security of the hardware itself is also critical for the overall system to be secure. Espressif MCUs come with various security features like [secure boot](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/security/secure-boot-v2.html), [flash encryption](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/security/flash-encryption.html), etc.

{{< figure
    default=true
    src="img/secure-1.webp"
    >}}

The secure boot feature is especially important as it allows only authorised firmware to run on the MCUs. ESP IDF has made enabling secure boot very easy. However, managing the secure boot keys is still the developer’s responsibility. Some questions that commonly come up for our customers include:

- How to generate the secure boot key?
- Where to store the key securely, is it stored on the developer’s machine or a server?
- How to protect the key from leakage? What if our engineers leave the organisation?
- How do I know which key is programmed on a device, so I don’t accidentally upgrade with the incorrect keys?
- How to manage a fleet of devices with similar firmware but different secure boot keys?

The recent addition of “[Secure Signing](https://rainmaker.espressif.com/docs/secure-signing)” feature in ESP RainMaker addresses all its concerns. It offers a way to

- generate and manage keys
- simplify signing bootloader and firmware images before device manufacturing
- supports transparently “Auto Signing” before deploying OTA firmware upgrades

## Auto Sign for OTA

The auto-signing feature in ESP RainMaker allows developers to just upload their unsigned firmware to ESP RainMaker, and deploy an OTA firmware upgrade. The ESP RainMaker backend transparently handles the signing with the correct keys during OTA firmware upgrades.

{{< figure
    default=true
    src="img/secure-2.webp"
    >}}

If your fleet includes devices that use distinct keys for key verification, ESP RainMaker will ensure that the correctly signed firmware goes to the right device.

The developer no more needs to keep track of the keys (or should even have the visibility of the keys), making the fleet management simpler.

Additionally, since the key management is handled in the cloud, this decouples the development activity from the device-management activity, providing better role based separation.

## Key Management

The secure boot signing keys are created and maintained in the cloud with ESP RainMaker. The private key itself is not accessible to the user but can be used only for signing requests. On private deployments, RainMaker uses a FIPS compliant HSM for added security. Access control, for who can trigger signing requests, ensures that only authorised persons in your organisation can utilise this for signing firmware images. This adds another layer of security to the system.

## First-Time Signing

Once the signing key is created in ESP RainMaker, you need to sign the firmware images (bootloader and firmware) that gets flashed on your production devices. This is achieved by uploading unsigned images of secure-boot enabled bootloader and firmware and getting them signed for the first time.

ESP RainMaker provides detailed instruction for flashing and setting up your SoC with the appropriate security configurations for secure boot.

---

The secure signing feature is available in public as well as private RainMaker deployments. Use [backend release 2.1.0](https://customer.rainmaker.espressif.com/docs/rainmaker-releases/#210-22-apr-2024) or later and [frontend release 2.0.1](https://customer.rainmaker.espressif.com/docs/frontend-releases/#201-12-jun-2024) or later for this.

Check out more usage details in the [ESP RainMaker docs](https://rainmaker.espressif.com/docs/secure-signing). Go ahead and use this to secure your RainMaker powered IoT devices. Let us know (at [esp-rainmaker-support@espressif.com](mailto:esp-rainmaker-support@espressif.com)) if you have any queries.
