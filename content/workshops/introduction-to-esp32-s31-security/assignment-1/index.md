---
title: "Assignment 1: Enable and Verify Secure Boot V2"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 10
showAuthor: false
---

## Assignment 1: Enable and verify Secure Boot V2

In this assignment, you will configure Secure Boot V2, sign an application, and verify that unauthorized firmware is rejected. All eFuse operations run in **virtual** mode; the chip is not permanently provisioned.

## Before you begin

TODO: List the validated ESP32-S31-Function-CoreBoard-1 setup, ESP-IDF v6.1 example, signing tools, and backup requirements.

> [!IMPORTANT]
> **Workshop mode: virtual eFuses.** Build from the course repository with `CONFIG_EFUSE_VIRTUAL=y` and `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y`. Confirm after `idf.py build`. After boot, expect a log line that virtual eFuses are enabled and silicon is not being burned.

**Preflight:** `grep CONFIG_EFUSE_VIRTUAL sdkconfig` must show `CONFIG_EFUSE_VIRTUAL=y`.

**Forbidden on participant boards:** `espefuse burn`, enabling hardware Secure Boot without virtual eFuses, burning unused digest slots on real silicon.

**Reset after lab (optional):** `idf.py erase-flash` and reflash the workshop firmware.

> [!WARNING]
> Production Secure Boot burns digests and `SECURE_BOOT_EN` for real. That flow is in the [production provisioning appendix](../appendix-production-provisioning), not in this assignment.

## Step 1: Build the baseline application

TODO: Add the VS Code and ESP-IDF commands to build, flash, and inspect the unprotected application.

## Step 2: Generate a development signing key

TODO: Add a non-production key workflow. Never commit private keys.

## Step 3: Enable Secure Boot V2

TODO: Add the validated project configuration and signing steps (workshop defaults keep virtual eFuses enabled).

## Step 4: Provision and verify

TODO: Add the virtual provisioning sequence, expected logs, and `idf.py efuse-summary` (emulated state).

## Step 5: Test rejection

TODO: Demonstrate that an unsigned or incorrectly signed image is rejected.

## What you learned

TODO: Summarize the completed configuration, verification results, and CRA-supporting evidence.

## Previous and next steps

[Previous: Lecture 4: Secure Boot V2](../lecture-4)

[Next: Lecture 5: Flash encryption](../lecture-5)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
