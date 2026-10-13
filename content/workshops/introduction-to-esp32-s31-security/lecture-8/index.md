---
title: "Lecture 8: Secure Bootloader OTA Updates"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 13
showAuthor: false
---

## Secure bootloader OTA updates with anti-rollback

This lecture explains authenticated bootloader updates and version enforcement that prevents installation of older, vulnerable releases.

## Learning objectives

- Explain the risks of updating a bootloader
- Describe the signed update and recovery flow
- Explain anti-rollback and secure versions
- Plan version allocation across a product lifetime

## Update threat model

TODO: Cover malicious servers, modified images, interrupted downloads, power loss, replay, and signing-key compromise.

## Bootloader OTA architecture

TODO: Document the validated ESP32-S31 partition layout, trust chain, state transitions, rollback behavior, and recovery path.

## Anti-rollback model

TODO: Explain secure-version fields, eFuse limits, update timing, and fleet-wide version management.

### Workshop path (Assignment 5)

The class lab teaches OTA signature verification without hardware Secure Boot:

- [CONFIG_SECURE_SIGNED_APPS_NO_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-signed-apps-no-secure-boot)
- [CONFIG_SECURE_SIGNED_ON_UPDATE_NO_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-signed-on-update-no-secure-boot)

Anti-rollback is exercised with [CONFIG_BOOTLOADER_EFUSE_SECURE_VERSION_EMULATE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-efuse-secure-version-emulate), which uses virtual eFuses and an `emul_efuse` partition (see Kconfig help). No secure-version eFuses are burned on student boards.

### Production path (appendix)

Bootloader OTA with hardware Secure Boot and real anti-rollback eFuses belongs on the manufacturing line or an instructor demo board. See the **Bootloader OTA architecture** section above and the [production provisioning appendix](../appendix-production-provisioning).

## CRA relevance

TODO: Relate secure updates to vulnerability remediation, support commitments, update evidence, and incident recovery.

## Previous and next steps

[Previous: Assignment 2](../assignment-2)

[Next: Assignment 5: Signed application OTA and emulated anti-rollback](../assignment-5)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
