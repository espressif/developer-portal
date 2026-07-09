---
title: "Build a Cloud-connected device with ESP RainMaker Studio"
date: "2026-07-08"
summary: "Learn to design an ESP RainMaker device data model using the Studio tool on Evaluation Hub, implement the ESP32-C3 hardware driver, and build, flash, and control a cloud-connected Rainbow LED from the ESP RainMaker Home app."
featureAsset: "img/featured/rainmaker-workshop-background.webp"
tags: ["Workshop", "ESP RainMaker Studio", "ESP-IDF", "ESP32-C3", "IoT", "Cloud Connectivity"]
authors:
  - "ivan-theng"
showTableOfContents: false
---

Welcome to the ESP RainMaker Studio workshop. In this hands-on guide, you will go from a blank project to a cloud-connected Rainbow LED on an ESP32-C3 DevKit — with the RainMaker framework already wired up, so you can focus on your product instead of the boilerplate.

## What is ESP RainMaker Studio?

{{< figure
  src="assets/01-studio-landing.webp"
  caption="ESP RainMaker Studio on the Evaluation Hub homepage"
>}}

ESP RainMaker Studio is a browser-based drag-and-drop tool on the [ESP RainMaker Evaluation Hub](https://evaluation.rainmaker.espressif.com). It lets you visually design an ESP RainMaker **device data model** — the node, devices, and parameters that define what your IoT product exposes to the cloud and phone app — and then automatically generates a complete, buildable ESP-IDF project from that model.

If you are new to ESP RainMaker development, we recommend reviewing the [basic concepts and features of ESP RainMaker](https://docs.rainmaker.espressif.com/docs/product_overview/technical_overview/introduction/) before you begin.

### Skip Starting from Zero

Before your product starts taking shape, you usually need to decide how to structure the node and devices, map product controls into RainMaker parameters, wire services such as provisioning and OTA, and grow a bit more comfortable with the framework. That takes time and effort — often starting with reading the documentation and experimenting before anything comes together.

With ESP RainMaker Studio, you don't have to start from zero. Skip the early setup that slows down a project kickoff and design from the product experience first — what users see in the phone app, what syncs through the cloud, and what the device should do.

No account is required; projects are saved in your browser. The generated ESP-IDF project ships with RainMaker framework setup, provisioning, OTA, scheduling, and services already wired up. Define your product's cloud and app behavior, then implement the hardware drivers behind those controls.

### Why Use ESP RainMaker Studio?

| Benefit | Details |
|---|---|
| **Complete ESP RainMaker Framework Setup** | `app_main.c` is fully generated — RainMaker init, NVS, network, OTA, timezone, scheduling, scenes, and Insights are all wired up |
| **Visual data model** | Design your device hierarchy graphically; see it reflected instantly in the JSON and Code tabs |
| **Instant feedback** | Get instant feedback on missing fields such as model and type, so your codebase is correct and accurate before you download the complete ESP-IDF project |
| **Chip-targeted output** | Select your target (ESP32-C3, ESP32-S3, etc.) and the project ships with the matching `sdkconfig.defaults` |
| **Prototype to product** | The same data model you define here maps directly to your production RainMaker configuration — no rework |
| **Faster time-to-market** | Skip days of reading RainMaker API docs for standard device types; focus engineering time on your hardware differentiation |
| **Standard param types** | Power, Brightness, Color Hue, Fan Speed, and more are pre-configured with the correct ESP RainMaker type strings, UI hints, and default values |
| **Custom params supported** | Add any custom parameter type with a slider, toggle, or input UI — full flexibility for novel devices |

## Prerequisites

| Requirement | Details |
|---|---|
| **Browser** | Chrome or Edge (Chromium-based). <br> Firefox and Safari are not supported for flashing via Web Serial |
| **ESP-IDF** | v5.0 or later. Install via the [ESP-IDF Getting Started Guide](https://docs.espressif.com/projects/esp-idf/en/stable/esp32c3/get-started/) |
| **Hardware** | ESP32-C3-DevKitC. The onboard WS2812 RGB LED is on GPIO 8, BOOT button on GPIO 9 |
| **ESP RainMaker Phone App** | [iOS](https://apps.apple.com/us/app/esp-rainmaker-home/id1563728960) or [Android](https://play.google.com/store/apps/details?id=com.espressif.novahome&hl) — needed to provision and control the device |

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
The Studio runs entirely in your browser. No ESP-IDF setup is needed to design the data model. It is only needed later for building and flashing the downloaded project.
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
