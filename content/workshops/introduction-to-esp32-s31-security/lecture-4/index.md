---
title: "Lecture 4: Secure Boot V2"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 9
showAuthor: false
---

## Secure Boot V2: Firmware authenticity

This lecture explains how Secure Boot V2 establishes a chain of trust so that the device executes only authorized firmware.

## Learning objectives

- Explain the Secure Boot V2 chain of trust
- Distinguish signing keys, public-key digests, and signatures
- Understand the ESP32-S31 verification flow
- Plan production signing-key custody and provisioning

## Chain of trust

TODO: Explain ROM, bootloader, and application verification using ESP-IDF v6.1 documentation.

## Signing and verification

TODO: Describe the image signature, public-key digest, signing workflow, and failure behavior.

## Provisioning lifecycle

TODO: Contrast safe development exercises with controlled production provisioning.

### Workshop path (Assignment 1)

The class lab enables the Secure Boot V2 **build and boot flow** with [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) and [CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual-keep-in-flash). Public-key digests and `SECURE_BOOT_EN` are applied to **emulated** eFuses only. You still sign images and test rejection of bad firmware; the chip’s real eFuses stay at factory defaults.

### Production path (appendix)

Hardware Secure Boot burns key digests, enables `SECURE_BOOT_EN`, and may revoke unused digest slots. That is irreversible. Follow the [production provisioning appendix](../appendix-production-provisioning) and ESP-IDF enablement workflows on disposable provisioning hardware, not on workshop kits.

> [!WARNING]
> Enabling hardware secure boot and programming or protecting **real** eFuses can be irreversible. In class, verify virtual eFuse mode before any provisioning step. Never run `espefuse burn` on participant boards.

## CRA relevance

TODO: Explain how authenticated firmware supports product integrity and what implementation and test evidence should be retained.

## Previous and next steps

[Previous: Assignment 3](../assignment-3)

[Next: Assignment 1: Enable and verify Secure Boot V2](../assignment-1)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
