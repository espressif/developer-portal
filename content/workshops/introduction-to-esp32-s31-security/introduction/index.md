---
title: "Introduction to the ESP32-S31: Security - Introduction"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 1
showAuthor: false
---

## Why security matters

A connected product stores firmware in flash, keys in eFuses or protected NVS, and often Wi-Fi or TLS credentials beside user configuration. Tampering with the bootloader, reading flash offline, or intercepting traffic breaks trust in the device and in the company that shipped it. This chapter sets scope for the workshop: which ESP32-S31 mechanisms we will configure, and how that work relates to obligations under the EU Cyber Resilience Act (CRA).

> [!IMPORTANT]
> The CRA applies to products with digital elements and to the economic operators responsible for them. An ESP32-S31 does not make a finished product compliant by itself. The assignments walk through Secure Boot V2, flash encryption, HMAC-based NVS encryption, and TLS on the ESP32-S31-Function-CoreBoard-1. Secure Boot and flash encryption use **virtual eFuses** so boards are not permanently provisioned in class; HMAC-based NVS encryption burns one real eFuse key block. That is technical evidence you can use in a compliance program; it is not legal advice. Secure OTA and anti-rollback are out of scope for the hands-on track; real production burns and update provisioning are covered in the [production provisioning appendix](../appendix-production-provisioning).

## Learning objectives

After completing this chapter, you will be able to:

- Explain the scope and structure of the workshop
- Tell SoC-level security apart from product-level CRA compliance
- Name the assets and attack surfaces the exercises address
- Prepare for the development and provisioning workflow used in the assignments

## Workshop scenario

The CRA treats cybersecurity as a product requirement under **security by design**: secure defaults, protected credentials and firmware, authenticated updates, and proof that those controls still work during the support period you commit to.

This workshop runs that idea on the ESP32-S31. A lecture introduces each topic; the next assignment implements and checks it on the [ESP32-S31-Function-CoreBoard-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-function-coreboard-1/user_guide.html) with ESP-IDF v6.1. After the SoC, security overview, and CRA context, the **lab order** is TLS, HMAC-based NVS encryption, Secure Boot V2, and flash encryption.

## Lab safety and virtual eFuses

Many ESP32-S31 security features store trust in **eFuses**, which are one-time programmable. Burning the wrong eFuse can lock debug access, block reflashing, or brick provisioning. This workshop makes **one permanent eFuse write** on participant boards: the HMAC key in [Assignment 2](../assignment-2). Everything else uses virtual eFuses.

| Tier | Hands-on scope | Permanent eFuses |
|------|----------------|------------------|
| A | TLS, image signing on the host | None |
| B | HMAC NVS | One key block with purpose `HMAC_UP` (real, generated on the SoC) |
| B | Secure Boot, flash encryption | None (virtual eFuses) |
| C | Production provisioning | Yes (appendix and instructor demo only) |

**HMAC NVS (Assignment 2)** needs real eFuses: the HMAC peripheral reads its key directly from the eFuse block, so a key written only to virtual eFuses cannot derive NVS keys. Build Assignment 2 with `CONFIG_EFUSE_VIRTUAL` **off**. The key consumes one of the six key blocks permanently and cannot be read back, but the board keeps working normally. See [Provisioning the HMAC key](../lecture-2/#provisioning-the-hmac-key).

**Secure Boot and flash encryption (Assignments 3 and 4)** must be built from the course repository with:

- [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) enabled
- [CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual-keep-in-flash) enabled
- An `efuse_em` data partition in `partitions.csv` (see [Virtual eFuses](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html#debug-efuse-unit-tests))

When `efuse_em` is empty, ESP-IDF fills it from the real eFuses at startup. The emulated copy therefore shows the Assignment 2 HMAC key block as `HMAC_UP`, and encrypted NVS keeps working.

**Preflight** (Assignments 3 and 4): confirm `CONFIG_EFUSE_VIRTUAL=y` in `sdkconfig` after `idf.py build`. After flash, the serial log should include a warning that virtual eFuses are enabled and silicon is not being burned. You may run `idf.py efuse-summary` to inspect **emulated** state.

**Forbidden in class** on participant boards: any `espefuse burn` or `burn-key` command other than the Assignment 2 HMAC key, flash encryption **release** mode, and any step that enables hardware Secure Boot without virtual eFuses.

**Reset between labs**: `idf.py erase-flash` and reflash the workshop project. If virtual eFuse state is stuck, erase flash again so the `efuse_em` partition is cleared. Erasing flash never removes the real HMAC key. Do not use `espefuse` to recover a board in the classroom.

**Production** enablement with real eFuses, release flash encryption, and bootloader OTA with hardware Secure Boot belongs in manufacturing or a controlled pilot. Follow the [production provisioning appendix](../appendix-production-provisioning) and Espressif’s [Security Features Enablement Workflows (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html) outside this course.

## Threat model

The exercises assume an attacker who can reach your device over the network, reflash or read external flash if protections are off, and in some labs gain brief physical access to USB or test points. They do not cover cloud backend compromise, supply-chain attacks on your CI, or formal penetration testing.

Assets to keep in mind:

- Bootloader and application firmware
- Device identity and cryptographic keys
- User and configuration data
- Update metadata and security version
- Network traffic and remote-service credentials

## Expected outcomes

When the workshop is complete, you will have flashed and verified the controls listed on the [workshop home page](/workshops/introduction-to-esp32-s31-security/#about-this-workshop). A table mapping each assignment to protected assets, security properties, CRA themes, and verification steps will be added as the exercise scripts are finalized.

## Next step

[Overview of the ESP32-S31 features](../overview-esp32-s31-features)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
