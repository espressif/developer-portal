---
title: "Assignment 2: Enable and Verify Flash Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 12
showAuthor: false
---

## Assignment 2: Enable and verify flash encryption

In this assignment, you will enable flash encryption in **workshop (virtual eFuse) mode** and verify encryption behavior through ESP-IDF logs and authorized boot. Offline plaintext reads may not match production release-mode devices until real eFuses are programmed.

## Before you begin

TODO: List the required board state, ESP-IDF v6.1 project, backup procedure, and recovery constraints.

> [!IMPORTANT]
> **Workshop mode: virtual eFuses.** Requires `CONFIG_EFUSE_VIRTUAL=y`, `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y`, and an `efuse_em` partition in `partitions.csv`.

**Preflight:** Confirm virtual eFuse settings in `sdkconfig` after `idf.py build`.

**Forbidden:** Flash encryption **release** mode, `espefuse burn`, any step that burns `SPI_BOOT_CRYPT_CNT` or flash encryption keys on real silicon.

**Reset after lab (optional):** `idf.py erase-flash` to clear virtual eFuse state in flash.

> [!WARNING]
> Release-mode settings can permanently restrict a device. Release mode is incompatible with `CONFIG_EFUSE_VIRTUAL`. Production enablement is documented in the [production provisioning appendix](../appendix-production-provisioning).

## Step 1: Capture a plaintext baseline

TODO: Build and flash the example, read a safe region, and identify a demonstration marker.

## Step 2: Enable flash encryption

TODO: Add the validated configuration and first-boot procedure (development mode, virtual eFuses).

## Step 3: Verify confidentiality

TODO: Read the same region, interpret results per [Flash Encryption Testing](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html#debug-efuse-unit-tests), and verify that authorized execution succeeds.

## Step 4: Review production configuration

TODO: Cover release mode, encrypted flashing, key custody, restricted interfaces, and recovery (read-only; perform only per appendix on provisioning hardware).

## What you learned

TODO: Summarize the observed behavior and evidence collected.

## Previous and next steps

[Previous: Lecture 5: Flash encryption](../lecture-5)

[Next: Lecture 8: Secure bootloader OTA](../lecture-8)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
