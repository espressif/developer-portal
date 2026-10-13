---
title: "Assignment 6: Profile Security Operations with Otii Arc Pro"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 16
showAuthor: false
---

## Assignment 6: Profile security operations with Otii Arc Pro

In this assignment, you will capture repeatable power traces and correlate them with security operations.

## Before you begin

TODO: List the exact Otii hardware, software version, probes, voltage and current limits, and board wiring.

Power traces reflect the **virtual eFuse** workshop firmware from earlier assignments (TLS, NVS, Secure Boot, flash encryption, signed OTA). Timing and current shape may differ from a production-provisioned device.

> [!WARNING]
> Do not power the board simultaneously from the Otii Arc Pro and USB unless the validated setup explicitly supports it.

## Step 1: Connect the equipment

TODO: Add the validated [Otii Arc Pro](https://www.qoitech.com/otii-arc-pro/) wiring diagram and safety checks.

## Step 2: Configure the measurement

TODO: Set the supply voltage, current limit, range, sample rate, recording window, and synchronization method.

## Step 3: Capture a baseline

TODO: Record idle, boot, and network-operation traces with environmental and firmware metadata.

## Step 4: Profile security operations

TODO: Capture secure boot, protected NVS access, TLS handshake, and OTA update traces.

## Step 5: Investigate an anomaly

TODO: Use traces to identify a retry, failed connection, unexpected reset, or update-state transition.

## What you learned

TODO: Summarize the measured behavior, limitations, and debugging evidence.

## Previous and next steps

[Previous: Lecture 9](../lecture-9)

[Next: Conclusion](../conclusion)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
