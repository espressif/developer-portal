---
title: "Lecture 9: Power Profiling for Advanced Debugging"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 15
showAuthor: false
---

## Power profiling for advanced debugging

This lecture explains how time-aligned power traces can reveal device activity and help investigate security-operation timing, retries, failures, and energy cost.

## Learning objectives

- Understand power-profile measurement concepts
- Select useful measurement and synchronization settings
- Correlate firmware events with power traces
- Distinguish functional profiling from side-channel evaluation

## Measurement concepts

TODO: Explain voltage supply, current range, sample rate, triggers, serial synchronization, noise, and repeatability.

## Security-operation profiles

TODO: Describe expected observations for secure boot, protected NVS, TLS, and OTA operations.

## Interpretation and limitations

TODO: Cover variance, trigger alignment, statistical comparison, and why visible differences do not prove an exploitable side channel.

> [!NOTE]
> Formal side-channel analysis requires specialist methodology and expertise. This workshop uses profiling for functional and energy debugging.

## Previous and next steps

[Previous: Assignment 5](../assignment-5)

[Next: Assignment 6: Profile security operations](../assignment-6)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
