---
title: "Assignment 5: Signed Application OTA and Emulated Anti-Rollback"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 14
showAuthor: false
---

## Assignment 5: Signed application OTA and emulated anti-rollback

In this assignment, you will deliver a **signed application** OTA update, verify signature checking on update, and test anti-rollback using **emulated** secure-version eFuses. This is not a bootloader-partition OTA lab and does not enable hardware Secure Boot.

[Lecture 8](../lecture-8) describes full bootloader OTA with hardware Secure Boot; that path is limited to the [production provisioning appendix](../appendix-production-provisioning) or an instructor demo.

## Before you begin

TODO: Define recoverable board state, partition layout, signing setup, update server, and power requirements.

> [!IMPORTANT]
> **Workshop mode.** Enable [CONFIG_SECURE_SIGNED_APPS_NO_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-signed-apps-no-secure-boot) and [CONFIG_SECURE_SIGNED_ON_UPDATE_NO_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-signed-on-update-no-secure-boot). Keep `CONFIG_EFUSE_VIRTUAL=y`. For anti-rollback, use [CONFIG_BOOTLOADER_EFUSE_SECURE_VERSION_EMULATE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-efuse-secure-version-emulate) and the `emul_efuse` partition per Kconfig help.

**Preflight:** Confirm signed-app and virtual eFuse options in `sdkconfig` after `idf.py build`. Flash only **signed** initial firmware (required for the no-hardware-Secure-Boot OTA chain).

**Forbidden:** Bootloader OTA that assumes real `SECURE_BOOT_EN`, burning secure-version eFuses, `espefuse burn`.

> [!WARNING]
> Bootloader updates and real anti-rollback eFuses can make a device unbootable or permanently reject older firmware. Do not run those steps on participant boards in this assignment.

## Step 1: Prepare signed versions

TODO: Build a baseline signed app, valid upgrade, older signed image, and invalidly signed image with explicit security version fields.

## Step 2: Configure the update layout

TODO: Add the validated OTA partition table, signed-app Kconfig, emulated secure-version options, and update transport.

## Step 3: Perform and confirm the update

TODO: Install the valid upgrade and verify signature check, running version, and boot state.

## Step 4: Test failure and recovery

TODO: Test invalid signature and corruption safely (avoid bricking; use erase-flash recovery documented in the introduction).

## Step 5: Verify anti-rollback

TODO: Attempt the older signed image and verify that emulated secure version rejects the downgrade.

## What you learned

TODO: Summarize OTA signature guarantees, emulated rollback behavior, and how this differs from hardware Secure Boot and bootloader OTA.

## Previous and next steps

[Previous: Lecture 8](../lecture-8)

[Next: Lecture 9: Power profiling](../lecture-9)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
