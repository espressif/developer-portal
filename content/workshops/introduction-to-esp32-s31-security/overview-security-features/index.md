---
title: "Overview of the Security Features on the ESP32-S31"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 3
showAuthor: false
---

## A walkthrough on ESP32-S31 security

You will walk through TLS, NVS encryption, Secure Boot V2, and flash encryption on the ESP32-S31. This chapter explains what each control does on the ESP32-S31 and where it sits in ESP-IDF.

The [workshop agenda](/workshops/introduction-to-esp32-s31-security/#agenda) runs labs in an order that starts with network and storage topics, then authenticity and confidentiality. TLS runs on the ESP32-S31-Function-CoreBoard-1. NVS encryption, Secure Boot, and flash encryption use production settings and run in the [ESP32 emulator](https://espressif.github.io/esp-emulator/), which burns eFuses on an emulated chip instead of your board. See [Lab safety and the ESP32 emulator](../introduction/#lab-safety-and-the-esp32-emulator).

## Learning objectives

- Name the boot chain and where Secure Boot V2 and flash encryption apply
- Describe how eFuses and hardware keys back NVS encryption
- Match authenticity and confidentiality to the four hands-on controls below
- Pick which control addresses a given asset (firmware, flash, NVS, network)
- Explain which eFuses each control burns, and why the order of those burns matters

## Cryptographic capabilities

The ESP32-S31 has hardware accelerators for AES, SHA, RSA, ECC, and HMAC, plus a True Random Number Generator (TRNG) for keys and TLS nonces. RSA_DS and ECDSA_DS can sign without giving application code access to the private key. See the [ESP32-S31 Series Datasheet](https://documentation.espressif.com/esp32-s31_datasheet_en.html) and [ESP-IDF security overview](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security.html).

## What you are going to use

The list follows the order used in this chapter. Each topic links to its lecture and assignment. The **Runs on** column shows where the lab runs, and the **eFuses burned** column shows what the firmware burns on its first boot.

| Control | Lecture / assignment | Runs on | eFuses burned |
|---------|----------------------|---------|---------------|
| TLS | [Lecture 1](../lecture-1), [Assignment 1](../assignment-1) | ESP32-S31-Function-CoreBoard-1 | None |
| HMAC-based NVS encryption | [Lecture 2](../lecture-2), [Assignment 2](../assignment-2) | Web emulator | `HMAC_UP` key |
| Secure Boot V2 | [Lecture 3](../lecture-3), [Assignment 3](../assignment-3) | Web emulator | Key digest, Secure Boot enable, ROM download mode and JTAG disable |
| Flash encryption | [Lecture 4](../lecture-4), [Assignment 4](../assignment-4) | Web emulator | Flash encryption key and counter, plus the Secure Boot eFuses |
| Secure OTA (optional) | [Assignment 5](../assignment-5) | Native `esp-emu` | Same as Assignment 4; OTA adds none |

Every eFuse in the emulator columns is burned in the emulator's memory, not on your board.

### TLS for secure connection

TLS checks the server (and optionally the device) and encrypts traffic over Wi-Fi or Ethernet. You set trust anchors, hostname or certificate checks, and cipher suites through ESP-IDF’s mbedTLS stack. [Lecture 1](../lecture-1), [Assignment 1](../assignment-1).

### NVS encryption

NVS stores configuration and credentials in flash. NVS encryption encrypts it with XTS-AES keys, and ESP-IDF offers two ways to protect those keys:

- **HMAC-based scheme:** the SoC derives the NVS keys at runtime from an HMAC key in a read-protected eFuse block, so no NVS key is stored in flash. In [Assignment 2](../assignment-2), the SoC generates the HMAC key on first boot and burns it.
- **Flash encryption-based scheme:** the NVS keys live in an `nvs_keys` partition that flash encryption protects. [Assignment 4](../assignment-4) uses this scheme together with Secure Boot and flash encryption.

[Lecture 2](../lecture-2) explains both schemes and when to use each.

### Secure Boot V2

Secure Boot V2 verifies the second-stage bootloader and application images so only signed firmware runs. On the first boot, the bootloader burns the SHA-256 digest of your public key into an eFuse key block, enables Secure Boot, and, with production settings, disables ROM download mode and JTAG. From then on, the ROM and bootloader accept only images signed with your key, and OTA updates go through the same check. [Lecture 3](../lecture-3), [Assignment 3](../assignment-3).

### Flash encryption

Flash encryption hides code and data on external flash from offline reads. With PSRAM encryption enabled, cached PSRAM contents are protected the same way. In release mode, the bootloader generates the key on the chip, burns it into a read-protected eFuse block, encrypts the flash in place, and locks the configuration so it cannot be turned off. A raw flash read then returns only ciphertext. [Lecture 4](../lecture-4), [Assignment 4](../assignment-4).

### Secure updates (optional lab)

Signed OTA, bootloader OTA, and anti-rollback are important in production and in CRA-oriented gap analysis. The optional [Assignment 5](../assignment-5) adds signed HTTPS OTA with app rollback to the workshop project; bootloader OTA and anti-rollback are **not** taught as class assignments. See the [EU CRA overview](../overview-eu-cra), ESP-IDF [Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html) OTA sections, and the [real-board appendix](../appendix-production-provisioning).

## eFuses and security state

eFuses are one-time programmable. Typical security uses include:

- Secure Boot V2 public-key digests
- Flash encryption key mode and policy
- HMAC key purposes for NVS and other derived keys
- Secure version fields for anti-rollback (production)
- Restrictions on debug and download modes in production

A wrong eFuse write can brick provisioning or lock out recovery, and the **order** of burns matters too. Secure Boot and flash encryption both write-protect the eFuse read-protection bits. After that, the firmware can no longer burn a new read-protected key, such as an HMAC key for NVS encryption. A provisioning plan therefore fixes which key goes into which block, and in which order.

In this workshop, all security eFuses are burned in the [ESP32 emulator](https://espressif.github.io/esp-emulator/). It runs the real ESP32-S31 ROM and ESP-IDF bootloader, so you see the same burns and logs as on silicon, without permanent changes to your board. To provision a real board with the same firmware, see the optional [real-board appendix](../appendix-production-provisioning).

## Previous and next steps

[Previous: Overview of the ESP32-S31 features](../overview-esp32-s31-features)

[Next: Overview of the EU Cyber Resilience Act](../overview-eu-cra)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
