---
title: "Assignment 3: Protect Data with HMAC-Based NVS Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 8
showAuthor: false
---

## Assignment 3: Protect data with HMAC-based NVS encryption

In this assignment, you will configure encrypted NVS, store a demonstration value, and verify its protection in raw flash. HMAC key provisioning uses **virtual** eFuses only.

## Before you begin

TODO: Specify the ESP-IDF v6.1 example, partition table, virtual eFuse prerequisites, and safe test-device state.

> [!IMPORTANT]
> **Workshop mode: virtual eFuses.** `CONFIG_EFUSE_VIRTUAL=y` must remain enabled. HMAC key setup must not call `espefuse burn-key` on participant boards.

**Preflight:** Confirm virtual eFuse settings in `sdkconfig` after `idf.py build`.

**Forbidden:** `espefuse burn-key`, production key material, disabling virtual eFuses to “test real” provisioning in class.

> [!WARNING]
> Provisioning a real HMAC key and protecting eFuses is irreversible. Production steps are in the [production provisioning appendix](../appendix-production-provisioning).

## Step 1: Define the encrypted NVS partition

TODO: Add the validated partition-table and project-configuration changes.

## Step 2: Provision the HMAC key

TODO: Add the virtual eFuse provisioning procedure via ESP-IDF (emulated `burn-key`). Describe the separate production process in the appendix.

## Step 3: Store and retrieve a value

TODO: Add code that writes a non-sensitive demonstration value, restarts, and reads it through the NVS API.

## Step 4: Inspect raw storage

TODO: Read the relevant flash range and verify that the plaintext is absent.

## What you learned

TODO: Summarize the key-derivation flow and verification results.

## Previous and next steps

[Previous: Lecture 6](../lecture-6)

[Next: Lecture 4: Secure Boot V2](../lecture-4)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
