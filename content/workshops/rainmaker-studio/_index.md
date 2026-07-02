---
title: "Build a Cloud-connected Custom Device with ESP RainMaker Studio"
date: "2026-06-18"
lastmod: "2026-06-18"
summary: "Learn to design an ESP RainMaker device data model using the Studio tool on Evaluation Hub, implement the ESP32-C3 hardware driver, and build, flash, and control a cloud-connected Rainbow LED from the ESP RainMaker Home app."
tags: ["Workshop", "ESP RainMaker Studio", "ESP-IDF", "ESP32-C3", "IoT", "Cloud Connectivity"]
authors:
  - "ivan-theng"
showTableOfContents: false
---

Welcome to the ESP RainMaker Studio workshop. In this hands-on guide, you will go from a blank project to a cloud-connected Rainbow LED on an ESP32-C3 DevKit — with the RainMaker framework already wired up, so you can focus on your product instead of the boilerplate.

## What is ESP RainMaker Studio?

ESP RainMaker Studio is a browser-based drag-and-drop tool on the [ESP RainMaker Evaluation Hub](https://evaluation.rainmaker.espressif.com). It lets you visually design an ESP RainMaker **device data model** — the node, devices, and parameters that define what your IoT product exposes to the cloud and phone app — and then automatically generates a complete, buildable ESP-IDF project from that model.

If you are new to ESP RainMaker development, we recommend reviewing the [basic concepts and features of ESP RainMaker](https://docs.rainmaker.espressif.com/docs/product_overview/technical_overview/introduction/) before you begin.

Skip the early setup work that usually slows down a RainMaker project: deciding how to structure the node and devices, mapping product controls into RainMaker parameters, wiring services such as provisioning and OTA, and learning enough of the framework before you can see your product take shape. With Studio, you start from the product experience instead — what the user should see in the phone app, what values should sync through the cloud, and what behavior the device should expose.

No account is required. Projects are saved in your browser. The generated project contains all the RainMaker framework setup, provisioning, OTA, scheduling, and services wired up and ready to go. Concentrate on what your product actually intends to do through the cloud and phone app, then fill in the hardware driver functions behind those controls.

{{< figure
  default=true
  src="assets/01-studio-landing.webp"
  caption="ESP RainMaker Studio on the Evaluation Hub homepage"
>}}

## Why Use ESP RainMaker Studio?

| Benefit | Detail |
|---|---|
| **Complete ESP RainMaker Framework Setup** | `app_main.c` is fully generated — RainMaker init, NVS, network, OTA, timezone, scheduling, scenes, and Insights are all wired up |
| **Visual data model** | Design your device hierarchy graphically; see it reflected instantly in the JSON and Code tabs |
| **Instant feedback** | The issues counter flags missing model/type fields before you can download |
| **Chip-targeted output** | Select your target (ESP32-C3, ESP32-S3, etc.) and the project ships with the matching `sdkconfig.defaults` |
| **Prototype to product** | The same data model you define here maps directly to your production RainMaker configuration — no rework |
| **Faster time-to-market** | Skip days of reading RainMaker API docs for standard device types; focus engineering time on your hardware differentiation |
| **Standard param types** | Power, Brightness, Color Hue, Fan Speed, and more are pre-configured with the correct ESP RainMaker type strings, UI hints, and default values |
| **Custom params supported** | Add any custom parameter type with a slider, toggle, or input UI — full flexibility for novel devices |

## Prerequisites

| Requirement | Details |
|---|---|
| **Browser** | Chrome or Edge (Chromium-based). Firefox and Safari are not supported for flashing via Web Serial |
| **ESP-IDF** | v5.0 or later. Install via the [ESP-IDF Getting Started Guide](https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/get-started/) |
| **Hardware** | ESP32-C3-DevKitC. The onboard WS2812 RGB LED is on GPIO 8, BOOT button on GPIO 9 |
| **ESP RainMaker Phone App** | [iOS](https://apps.apple.com/us/app/esp-rainmaker-home/id1563728960) or [Android](https://play.google.com/store/apps/details?id=com.espressif.novahome&hl) — needed to provision and control the device |

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
The Studio runs entirely in your browser. No ESP-IDF setup is needed to design the data model — only for building and flashing the downloaded project.
{{< /alert >}}

## Agenda

This workshop is divided into three parts:

- **[Part 1 — Build Your Data Model in Studio](part-1/)**: Open Studio, create a project, add a custom Rainbow LED device, configure its parameters, and download the generated project.
- **[Part 2 — Implement the Driver Functions](part-2/)**: Understand the generated scaffold and fill in the hardware driver — LED strip initialisation, button handling, and the FreeRTOS rainbow task.
- **[Part 3 — Build, Flash, and Test](part-3/)**: Build the project with ESP-IDF, flash it to your ESP32-C3, provision it with the RainMaker phone app, and verify every control.

{{< alert icon="mug-hot" >}}
**Estimated time: 90 min**
{{< /alert >}}

## Next Step

> The next step is **[Part 1 — Build Your Data Model in Studio](part-1/)**.

## Feedback

If you have any feedback about this workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).
