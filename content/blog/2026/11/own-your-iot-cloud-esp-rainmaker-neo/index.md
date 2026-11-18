---
title: "ESP RainMaker Neo: An Extensible IoT Cloud"
date: 2026-11-18
summary: "A complete IoT cloud. In your own AWS account. Open-source, Serverless and Extensible. Find out what you get on day one, what it costs, why it beats building one with AI from scratch, and where to start, with or without an AI assistant."
authors:
  - "manali-kaswa"
  - "kedar-sovani"
tags:
  - ESP RainMaker
  - IoT
  - Cloud
  - AWS
  - open source
  - AI
---

Every connected product faces the same choice: rent a SaaS platform, or build your own.

- **Rent a SaaS platform,** and it gets in your way after launch. The data model, OTA and permissions are all *almost* right, and each *"almost"* is a compromise that takes you farther from your desired user experience.
- **Build your own,** and you write identity, authentication, device lifecycle, OTA, voice assistants and an admin console before anything specific to your product. That's months of work, even with AI assistants.

We built ESP RainMaker Neo as a third option: **Own your IoT cloud, and extend it as you like**. It is a complete cloud that runs in your own cloud account. Let's look at what you get on day one, what it costs, and how you make it yours.

## What ESP RainMaker Neo is

In August we [open-sourced ESP RainMaker Neo](/blog/2026/08/open-sourcing-esp-rainmaker-neo/): the whole device-to-cloud-to-phone stack, including the cloud backend, under the Apache License 2.0.

- **Serverless.** Managed AWS services end to end. No servers to patch.
- **Open source.** Firmware, Cloud backend, Phone apps and Admin Dashboard, all yours to read, fork and change.
- **Private.** Your account, your data, your bill. No Espressif service in the loop.

{{< figure
    default=true
    src="img/architecture.webp"
    alt="ESP RainMaker Neo architecture: ESP32 devices talk MQTT to the IoT cloud backend; admin clients reach it over the AWS SDK; user clients over HTTPS and MQTT; local control and Matter connect phones to devices directly"
    caption="High-level architecture"
    >}}

Every box above is a repository you own a copy of:

- **Device firmware:** [esp-rainmaker-neo-firmware](https://github.com/espressif/esp-rainmaker-neo-firmware), for ESP-IDF and POSIX
- **Cloud backend:** [esp-rainmaker-neo](https://github.com/espressif/esp-rainmaker-neo), in Go and AWS CDK
- **Phone app:** [esp-rainmaker-home](https://github.com/espressif/esp-rainmaker-home), and its [TypeScript SDK](https://github.com/espressif/esp-rainmaker-neo-app-sdk-ts)
- **Admin Dashboard:** inside the backend repository
- **Voice assistant integrations:** inside the backend repository

So customizing your product means editing code and adding features, not working around a platform.

## What you get on day one

### For your customers

Your customers get:

- Device onboarding over BLE
- Control from the app: locally over IP or Matter, remotely, or by voice
- Schedules that run on the device, even when the cloud is unreachable
- Automations across devices
- Homes, rooms and sharing
- Time-series device data history
- Push notifications
- Bridges for Zigbee, BLE mesh and Matter devices
- Controllers for gateway devices

#### Third-party integrations

Integrations with voice assistants like Amazon Alexa, Google Home and Samsung SmartThings.

The ESP RainMaker Neo cloud platform also packages its own [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) server. Your customers can link it to any AI assistant and let it control and automate their devices.

### For your operations team

The Admin Dashboard runs in your account, and has its own admin sign-in. It handles:

- Batch device registration, with certificates and factory partitions generated in the browser
- Per-device connectivity and tags
- Static and dynamic groups for better organization
- OTA to one or more devices, with history

## What it costs to run

Pay-as-you-go, straight to your cloud provider, for only what your fleet uses.

- **What you pay for:** messages, requests and stored bytes, not server-hours. A quiet fleet costs close to nothing.
- **What it adds up to:** the [cost calculator](https://calculator.neo.rainmaker.espressif.com/) estimates your bill from how your devices and users behave.
- **What you don't pay:** no per-node license, no platform fee for the open-source core, and no expensive dev-ops teams.

## Make it yours

**ESP RainMaker Neo is designed to be extensible.** Every layer is code you own. Open source is necessary but not sufficient. A platform you can safely modify needs tooling that tells you what a change does, tests that tell you when you are done, and documentation that tells you what was intended.

- **Tooling.** A CLI and Python SDK that sign in as a user or a device and drive REST and MQTT; device and phone-app simulators, so no hardware is needed during development.
- **Tests.** Unit tests own decisions: fast, against mocks, with no deploy needed. Integration tests own wiring: they run against a live deployment and catch problems such as a missing permission. Together they catch regressions: a change that breaks existing behavior shows up as a failing test.
- **Documentation.** A design spec per subsystem; API references for clients; and a [docs site](https://docs.neo.rainmaker.espressif.com/) covering all components.

## Why not let AI build the cloud from scratch?

ESP RainMaker Neo gives AI assistants a better place to start.

Generating code is now cheap. Knowing that it works is not. An AI assistant will happily generate an IoT backend, but not the years of decisions a working one is made of, or the tests that prove them.

- **Chip to cloud, from one team.** Espressif builds the chips, the SDKs and the cloud, and has run ESP RainMaker in production for six years, powering products from many customers. The defaults come from that experience.
- **Working end to end.** Firmware, cloud and apps agree on one data model, one provisioning flow and one OTA path. The seams between them are where generated systems fail. We run an integration suite against a live deployment every day to exercise these paths.
- **Security thought through.** From the chip up: secure boot, flash encryption and an X.509 identity per node in its factory partition; secured provisioning with challenge-response association; short-lived, scoped credentials per user; and a separate admin identity. We try to break it ourselves: Espressif's security team reviews it periodically, cross-tenant tests keep each customer's data apart, and dependencies are scanned for known vulnerabilities.
- **Built for scale.** Event handling that switches to batching for a fleet-wide reconnect, and bulk registration that runs as a job. An internal stress-test suite catches scaling issues.
- **Cost optimized.** Every service is billed per request, so nothing runs while idle, and a calculator tells you the bill before you ship. Unit tests on the busiest paths count the AWS calls a request makes, so a change that adds cost is flagged.
- **Safe to change.** Whoever makes a change, a developer or an AI assistant, finds out at once if it breaks something.

We organized the repository so that an AI assistant can make a correct change in a package it has never seen:

- **Rules.** `CLAUDE.md` points at `.claude/rules`, which AI assistants read. Quality, behavior and git rules always apply; Go, AWS and API rules load by path.
- **Skills.** `/run-tests`, `/sync-docs`, `/mr-template` and `/deploy` turn the feature loop into commands.
- **Specs.** 34 design specs on one template sit next to the code, so an AI assistant can tell a change that fits from one that only compiles.

About 150 Go packages, 120 REST operations and 45 MQTT channels. A small team moves across that surface because the repository teaches the AI assistant the house rules. We continue to refine and maintain these rules and skills, and add more as we go.

Ask your AI assistant to customize ESP RainMaker Neo, and see how quickly it gets it right.

## Need more? Enterprise add-ons

The open-source core is complete on its own. For teams that want more, the ESP RainMaker Neo Enterprise Plan adds:

- Support with SLAs
- Enterprise identity features
- ESP Insights device diagnostics
- Private AI agents for your devices and apps
- Consulting to scope, customize and launch your product

## Get started

1. **Try it in minutes** on Espressif's public deployment: flash a board from the browser, install the ESP RainMaker Home app, and scan the QR code.
2. **Deploy your own cloud** with the Installer, in about an hour.

{{< button href="https://docs.neo.rainmaker.espressif.com/docs/get-started" target="_blank" >}}
Get started with ESP RainMaker Neo
{{< /button >}}

We built the cloud. You build the product. We can't wait to see what you make.

Tell us how it goes at <esp-rainmaker-support@espressif.com>, or [open an issue](https://github.com/espressif/esp-rainmaker-neo/issues).

