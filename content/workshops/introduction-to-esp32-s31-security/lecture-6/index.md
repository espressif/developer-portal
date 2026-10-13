---
title: "Lecture 6: HMAC-Based NVS Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 7
showAuthor: false
---

## Secure storage with HMAC-based NVS encryption

This lecture explains how HMAC-based NVS encryption protects sensitive values without storing the NVS encryption keys in flash.

## Learning objectives

- Explain the purpose and boundaries of NVS encryption
- Describe HMAC-based key derivation
- Identify suitable data for protected NVS
- Understand its relationship with whole-flash encryption

## Storage threat model

TODO: Define protected application data, attacker access, metadata exposure, and runtime limitations.

## Key derivation and storage

TODO: Describe the ESP32-S31 HMAC key, derived NVS keys, partition layout, and key protection.

## Provisioning considerations

TODO: Explain development and production key generation, injection, protection, backup, and auditing.

### Workshop path (Assignment 3)

The lab provisions the HMAC key through ESP-IDF’s normal NVS encryption workflow while [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) is enabled. Equivalent `burn-key` operations update emulated blocks only. Do not run `espefuse burn-key` on participant boards or use production key material.

### Production path (appendix)

Manufacturing typically burns an HMAC key into a dedicated eFuse block with the correct key purpose and may set read/write protection. See the [production provisioning appendix](../appendix-production-provisioning) and [Enable NVS Encryption Externally (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-nvs-encryption-externally).

## CRA relevance

TODO: Relate local data and credential protection to product requirements and retained evidence.

## Previous and next steps

[Previous: Assignment 4](../assignment-4)

[Next: Assignment 3: Protect data with HMAC-based NVS encryption](../assignment-3)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
