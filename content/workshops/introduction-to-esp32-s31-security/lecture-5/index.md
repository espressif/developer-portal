---
title: "Lecture 5: Flash Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 11
showAuthor: false
---

## Flash encryption: Confidentiality

This lecture explains how flash encryption protects code and data stored in external flash from direct extraction.

## Learning objectives

- Explain the threat addressed by flash encryption
- Distinguish development and release configurations
- Describe the encryption-key lifecycle
- Understand its relationship with Secure Boot V2

## Threat model and limitations

TODO: Define the physical-access threat, protected partitions, runtime behavior, and out-of-scope attacks.

## Encryption architecture

TODO: Explain the validated ESP32-S31 encryption engine, key storage, boot behavior, and encrypted flashing workflow.

## Development and release modes

TODO: Contrast recoverability, reflashing limits, interface restrictions, and production use.

### Workshop path (Assignment 2)

The lab uses flash encryption **development** behavior with virtual eFuses and an `efuse_em` partition. ESP-IDF may log encryption operations even when real `SPI_BOOT_CRYPT_CNT` and key eFuses are not burned. Offline read tests in virtual mode **do not** match a release-mode product until real eFuses are programmed. See [Flash Encryption Testing](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html#debug-efuse-unit-tests).

[CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) cannot be combined with flash encryption **release** mode. The workshop never enables release mode in class.

### Production path (appendix)

Release mode and real key/counter eFuses are production decisions documented in the [production provisioning appendix](../appendix-production-provisioning).

## CRA relevance

TODO: Relate data-at-rest confidentiality to product risks and verification evidence.

## Previous and next steps

[Previous: Assignment 1](../assignment-1)

[Next: Assignment 2: Enable and verify flash encryption](../assignment-2)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
