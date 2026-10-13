---
title: "Lecture 2: Security Features on the ESP32-S31"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 3
showAuthor: false
---

## A walkthrough on ESP32-S31 security

You will walk through TLS, HMAC-based NVS encryption, Secure Boot V2, flash encryption, and signed OTA with anti-rollback on the Function CoreBoard. This chapter explains what each control does on the ESP32-S31 and where it sits in ESP-IDF.

The [workshop agenda](/workshops/introduction-to-esp32-s31-security/#agenda) runs labs in an order that starts with network and storage topics, then authenticity and confidentiality, then updates. Assignments that touch eFuses use **virtual eFuses** so prior labs can build on emulated security state in the `efuse_em` flash partition without programming real silicon. See [Lab safety and virtual eFuses](../introduction/#lab-safety-and-virtual-efuses).

## Learning objectives

- Name the boot chain and where Secure Boot V2 and flash encryption apply
- Describe how eFuses and hardware keys back NVS encryption and anti-rollback
- Match authenticity, confidentiality, and rollback protection to the five controls below
- Pick which control addresses a given asset (firmware, flash, NVS, network, updates)
- Distinguish classroom simulation (Tier A/B) from production provisioning (Tier C)

## Cryptographic capabilities

The ESP32-S31 has hardware accelerators for AES, SHA, RSA, ECC, and HMAC, plus a True Random Number Generator (TRNG) for keys and TLS nonces. RSA_DS and ECDSA_DS can sign without giving application code access to the private key. See the [ESP32-S31 Series Datasheet](https://documentation.espressif.com/esp32-s31_datasheet_en.html) and [ESP-IDF security overview](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security.html).

## What you are going to use

The list follows the order used in this chapter. Each topic links to its lecture and assignment. The **Lab tier** column shows whether the assignment burns real eFuses in this workshop.

| Control | Lecture / assignment | Lab tier |
|---------|----------------------|----------|
| TLS | [Lecture 7](../lecture-7), [Assignment 4](../assignment-4) | A (no eFuses) |
| HMAC-based NVS encryption | [Lecture 6](../lecture-6), [Assignment 3](../assignment-3) | B (virtual HMAC key) |
| Secure Boot V2 | [Lecture 4](../lecture-4), [Assignment 1](../assignment-1) | B (virtual digests) |
| Flash encryption | [Lecture 5](../lecture-5), [Assignment 2](../assignment-2) | B (virtual encryption eFuses) |
| Signed OTA and anti-rollback | [Lecture 8](../lecture-8), [Assignment 5](../assignment-5) | A/B (signed app OTA without hardware Secure Boot; emulated secure version) |

### TLS for secure connection

TLS checks the server (and optionally the device) and encrypts traffic over Wi-Fi or Ethernet. You set trust anchors, hostname or certificate checks, and cipher suites through ESP-IDF’s mbedTLS stack. [Lecture 7](../lecture-7), [Assignment 4](../assignment-4).

### HMAC-based NVS encryption

NVS stores configuration and credentials in flash. With HMAC-based NVS encryption, the chip derives NVS keys from a hardware-protected HMAC key instead of leaving NVS keys in a readable partition. In the lab, the HMAC key is provisioned into **virtual** eFuse blocks. [Lecture 6](../lecture-6), [Assignment 3](../assignment-3).

### Secure Boot V2

Secure Boot V2 verifies the ROM, bootloader, and application images so only signed firmware runs. Trusted public-key digests live in eFuses in production; the lab stores digests in virtual eFuses only. [Lecture 4](../lecture-4), [Assignment 1](../assignment-1).

### Flash encryption

Flash encryption hides code and data on external flash from offline reads. With PSRAM encryption enabled, cached PSRAM contents are protected the same way. Keys stay in hardware in production; the lab simulates enablement without burning `SPI_BOOT_CRYPT_CNT` on the chip. [Lecture 5](../lecture-5), [Assignment 2](../assignment-2).

### Secure OTA and Bootloader OTA updates

OTA images must pass signature checks before install. Bootloader OTA uses the same trust model for the boot path and is taught in [Lecture 8](../lecture-8); the class lab uses [signed application OTA without hardware Secure Boot](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#signed-app-verification-without-hardware-secure-boot) plus [emulated secure version](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-efuse-secure-version-emulate) instead of burning anti-rollback eFuses. Full bootloader OTA with hardware Secure Boot is **appendix / instructor demo** only. [Assignment 5](../assignment-5).

## eFuses and security state

eFuses are one-time programmable. Typical security uses include:

- Secure Boot V2 public-key digests
- Flash encryption key mode and policy
- HMAC key purposes for NVS and other derived keys
- Secure version fields for anti-rollback
- Restrictions on debug and download modes in production

A wrong eFuse write can brick provisioning or lock out recovery. In this workshop, [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) redirects reads and writes to RAM (and optionally the `efuse_em` partition) so students learn the same ESP-IDF flows without permanent burns. For manufacturing, use the [production provisioning appendix](../appendix-production-provisioning).

## Previous and next steps

[Previous: Lecture 1](../lecture-1)

[Next: Lecture 3: The EU Cyber Resilience Act](../lecture-3)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
