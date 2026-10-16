---
title: "Overview of the Security Features on the ESP32-S31"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 3
showAuthor: false
---

## A walkthrough on ESP32-S31 security

You will walk through TLS, HMAC-based NVS encryption, Secure Boot V2, and flash encryption on the ESP32-S31-Function-CoreBoard-1. This chapter explains what each control does on the ESP32-S31 and where it sits in ESP-IDF.

The [workshop agenda](/workshops/introduction-to-esp32-s31-security/#agenda) runs labs in an order that starts with network and storage topics, then authenticity and confidentiality. Secure Boot and flash encryption use **virtual eFuses**, so those labs build on emulated security state in the `efuse_em` flash partition without programming real silicon. HMAC-based NVS encryption is the exception: it burns one real eFuse key block. See [Lab safety and virtual eFuses](../introduction/#lab-safety-and-virtual-efuses).

## Learning objectives

- Name the boot chain and where Secure Boot V2 and flash encryption apply
- Describe how eFuses and hardware keys back NVS encryption
- Match authenticity and confidentiality to the four hands-on controls below
- Pick which control addresses a given asset (firmware, flash, NVS, network)
- Distinguish classroom simulation (Tier A/B) from production provisioning (Tier C)

## Cryptographic capabilities

The ESP32-S31 has hardware accelerators for AES, SHA, RSA, ECC, and HMAC, plus a True Random Number Generator (TRNG) for keys and TLS nonces. RSA_DS and ECDSA_DS can sign without giving application code access to the private key. See the [ESP32-S31 Series Datasheet](https://documentation.espressif.com/esp32-s31_datasheet_en.html) and [ESP-IDF security overview](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security.html).

## What you are going to use

The list follows the order used in this chapter. Each topic links to its lecture and assignment. The **Lab tier** column shows whether the assignment burns real eFuses in this workshop.

| Control | Lecture / assignment | Lab tier |
|---------|----------------------|----------|
| TLS | [Lecture 1](../lecture-1), [Assignment 1](../assignment-1) | A (no eFuses) |
| HMAC-based NVS encryption | [Lecture 2](../lecture-2), [Assignment 2](../assignment-2) | B (one real `HMAC_UP` key block) |
| Secure Boot V2 | [Lecture 3](../lecture-3), [Assignment 3](../assignment-3) | B (virtual digests) |
| Flash encryption | [Lecture 4](../lecture-4), [Assignment 4](../assignment-4) | B (virtual encryption eFuses) |

### TLS for secure connection

TLS checks the server (and optionally the device) and encrypts traffic over Wi-Fi or Ethernet. You set trust anchors, hostname or certificate checks, and cipher suites through ESP-IDF’s mbedTLS stack. [Lecture 1](../lecture-1), [Assignment 1](../assignment-1).

### HMAC-based NVS encryption

NVS stores configuration and credentials in flash. With HMAC-based NVS encryption, the SoC derives NVS keys from a hardware-protected HMAC key instead of leaving NVS keys in a readable partition. In the lab, the SoC generates the HMAC key on first boot and burns it into a **real** eFuse key block, because the HMAC peripheral reads its key from hardware. [Lecture 2](../lecture-2), [Assignment 2](../assignment-2).

### Secure Boot V2

Secure Boot V2 verifies the second-stage bootloader and application images so only signed firmware runs. Trusted public-key digests live in eFuses in production; the lab stores digests in virtual eFuses only. OTA slots use the same verification path when you enable hardware Secure Boot in a product. [Lecture 3](../lecture-3), [Assignment 3](../assignment-3).

### Flash encryption

Flash encryption hides code and data on external flash from offline reads. With PSRAM encryption enabled, cached PSRAM contents are protected the same way. Keys stay in hardware in production; the lab simulates enablement without burning `SPI_BOOT_CRYPT_CNT` on the SoC. [Lecture 4](../lecture-4), [Assignment 4](../assignment-4).

### Secure updates (not a hands-on lab in this workshop)

Signed OTA, bootloader OTA, and anti-rollback are important in production and in CRA-oriented gap analysis, but they are **not** taught as a class assignment here. See the [EU CRA overview](../overview-eu-cra), ESP-IDF [Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html) OTA sections, and the [production provisioning appendix](../appendix-production-provisioning).

## eFuses and security state

eFuses are one-time programmable. Typical security uses include:

- Secure Boot V2 public-key digests
- Flash encryption key mode and policy
- HMAC key purposes for NVS and other derived keys
- Secure version fields for anti-rollback (production)
- Restrictions on debug and download modes in production

A wrong eFuse write can brick provisioning or lock out recovery. In this workshop, [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) redirects reads and writes to RAM (and optionally the `efuse_em` partition) so students learn the same ESP-IDF flows without permanent burns. The only real burn in class is the `HMAC_UP` key for NVS encryption. For manufacturing, use the [production provisioning appendix](../appendix-production-provisioning).

## Previous and next steps

[Previous: Overview of the ESP32-S31 features](../overview-esp32-s31-features)

[Next: Overview of the EU Cyber Resilience Act](../overview-eu-cra)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
