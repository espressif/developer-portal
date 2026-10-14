---
title: "Appendix: Production Provisioning (Real eFuses)"
date: 2026-10-06
showTableOfContents: true
showAuthor: false
---

## Purpose

This appendix describes **Tier C** provisioning: enabling ESP32-S31 security features with **real eFuse burns** on purpose-built hardware. It is **not** part of the default classroom track. Participants should complete the main workshop using virtual eFuses only.

Use this material for manufacturing engineering, a pilot line, or an **instructor demo** (one spare board, students observe).

## Before you burn anything

- Complete a product threat model and written provisioning procedure.
- Use **disposable** or dedicated provisioning boards until the flow is validated.
- Back up signing keys and provisioning logs outside the repository.
- Read [Security Features Enablement Workflows (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html).
- Confirm `CONFIG_EFUSE_VIRTUAL` is **disabled** in the production project (opposite of the workshop repo).
- Never mix workshop `sdkconfig` or `espefuse` commands with production keys on a line device.

## Typical production sequence (high level)

Order and exact steps depend on your product; this is a common pattern:

1. Flash unsigned or development firmware only on provisioning stations under access control.
2. Generate and protect Secure Boot V2 signing keys; burn public-key digests and enable hardware Secure Boot per the ESP-IDF workflow.
3. Enable flash encryption in **development** mode first on pilot units; validate recovery and reflashing policy before considering release mode.
4. Provision HMAC keys for NVS (`burn-key` with purpose `HMAC_UP`) on blocks reserved in your eFuse plan.
5. Configure anti-rollback secure version fields when you commit to minimum firmware versions fleet-wide.
6. Restrict download mode and debug interfaces according to product policy.
7. Record eFuse summary, firmware versions, and test results in the product technical file.

## Bootloader OTA and anti-rollback (not in the default workshop track)

Updating the bootloader and enforcing anti-rollback with **hardware** Secure Boot assumes digests and secure-version eFuses are already programmed correctly. A failed bootloader OTA can leave a device unbootable.

The main workshop does **not** include a hands-on OTA or anti-rollback assignment. Demonstrate real bootloader OTA and secure-version eFuses on a single pre-provisioned demo board if your course needs it, or point learners to ESP-IDF OTA examples and [Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html) documentation.

## If a board was burned by mistake in class

Stop the exercise, swap the board, and continue with virtual eFuses. Do not attempt to “match” production state on remaining student kits.

## Related documentation

- [ESP-IDF: eFuse Manager (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html)
- [ESP-IDF: Secure Boot v2 (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html)
- [ESP-IDF: Flash encryption (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html)
- [ESP Product Security](https://docs.espressif.com/projects/esp-product-security/en/latest/)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
