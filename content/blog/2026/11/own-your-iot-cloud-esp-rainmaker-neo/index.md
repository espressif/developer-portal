---
title: "ESP RainMaker Neo: An Extensible IoT Cloud"
date: 2026-11-11
summary: "ESP RainMaker Neo is an open-source, serverless IoT cloud that you deploy into your own AWS account and change to fit your product. This article covers what you get on day one, what it costs to run, why it is a better starting point than generating a cloud from with AI from scratch, and where to start customizing it, with or without an AI coding assistant."
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

Every connected product explores the same tradeoff about its cloud platform: rent a SAAS platform, or build your own.

- **Rent a SAAS platform,** and it gets in your way after launch. The data model, OTA and permissions are all *almost* right, and each "almost" is a compromise that takes you farther from your desired user experience.
- **Build your own,** and you write identity, device lifecycle, OTA, voice assistants and an admin console before anything specific to your product. A months long project, even with AI agents.

We built ESP RainMaker Neo as a third option: **own your IoT cloud, and extend it as you like**. It is a complete cloud that runs in your own cloud account, and you change it to fit your product. Let's look at what you get on day one, what it costs, and how you make it yours.

## What ESP RainMaker Neo is

In August we [open-sourced ESP RainMaker Neo](/blog/2026/08/open-sourcing-esp-rainmaker-neo/): the whole device-to-cloud-to-phone stack, including the cloud backend, under the Apache License 2.0.

- **Serverless.** Managed AWS services end to end. No servers to patch, and close to zero cost while idle.
- **Open source.** Firmware, cloud backend, phone apps and Admin Dashboard, all yours to read, fork and change.
- **Private.** Your account, your data, your bill. No per-node licence, and no Espressif service in the loop once deployed.

{{< figure
    default=true
    src="img/architecture.webp"
    alt="ESP RainMaker Neo architecture: ESP32 devices talk MQTT to the IoT cloud backend; admin clients reach it over the AWS SDK; user clients over HTTPS and MQTT; local control and Matter connect phones to devices directly"
    caption="Devices, cloud backend, user clients and admin clients. Every box is an open-source repository."
    >}}

Every box above is a repository you own a copy of:

- **Device firmware:** [esp-rainmaker-neo-firmware](https://github.com/espressif/esp-rainmaker-neo-firmware), for ESP-IDF and POSIX
- **Cloud backend:** [esp-rainmaker-neo](https://github.com/espressif/esp-rainmaker-neo), in Go and AWS CDK
- **Phone app:** [esp-rainmaker-home](https://github.com/espressif/esp-rainmaker-home), and its [TypeScript SDK](https://github.com/espressif/esp-rainmaker-neo-app-sdk-ts)
- **Admin Dashboard:** inside the backend repository

So customizing your product means editing code, not working around a platform.

## What you get right off the gate

### For your customers

The platform offers your end-users the following features:

- Device-Onboarding over BLE
- Local (over IP or Matter), remote, voice control through phone apps
- Schedules that run on the device, even when the cloud is unreachable
- Automations across devices
- Homes, rooms and sharing
- Time-series history
- Push notifications
- Bridges for Zigbee, BLE mesh and Matter devices

#### Third-Party Integrations

Integrations with Voice Assistants like Amazon Alexa, Google Voice Assistant and Samsung SmartThings.

The ESP RainMaker Neo cloud platform also packages its own [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) server. So your end-users can link this to any AI Assistant and get them to control and automate their devices.

### For your operations team

The Admin Dashboard runs in your account, under your brand and with its own admin sign-in. It handles:

- Batch registration, with certificates and factory partitions generated in the browser
- Per-device connectivity and tags
- Static and dynamic groups
- OTA to one device or a query-defined fleet, with history

## What it costs to run

You pay your cloud provider directly, and only for what your fleet actually uses.

- **What you pay for:** messages, requests and stored bytes, not server-hours. A quiet fleet costs close to nothing.
- **What it adds up to:** the [cost calculator](https://calculator.neo.rainmaker.espressif.com/) helps you estimate how much it will cost for the interactions your devices and users will have.
- **What you don't pay:** no per-node licence, and no platform fee for the open-source core.

## Make it yours

**ESP RainMaker Neo is designed to be changed.** Every layer is code you own. Open source is necessary but not sufficient. A platform you can safely modify needs tooling that tells you what a change does, tests that tell you when you are done, and documentation that tells you what was intended.

- **Tooling.** A CLI and Python SDK that sign in as a user or a device and drive REST and MQTT; device and phone-app simulators, so no hardware is needed during development.
- **Tests.** Unit tests own decisions: fast, against mocks, with no deploy needed. Integration tests own wiring: they run against a live deployment and catch problems such as a missing permission. Both run in CI.
- **Documentation.** A design spec per subsystem on one skeleton; OpenAPI and AsyncAPI definitions validated in CI, with the API reference generated from them; and a [docs site](https://docs.neo.rainmaker.espressif.com/) for firmware, backend, apps and dashboard.

## Why not let AI build the cloud from scratch?

ESP RainMaker Neo codebase offers a better starting point for AI Coding Agents to get started.

Generating code is now cheap. Knowing that it works is not. An AI assistant will happily generate an IoT backend from scratch, but not the years of decisions a working one is made of, or the tests that prove them.

- **Working end to end.** Firmware, cloud and apps agree on one data model, one provisioning flow and one OTA path. The seams between them are where generated systems fail.
- **Security thought through.** An X.509 identity per node, challenge-response association, scoped short-lived credentials per user, a separate admin identity, and secured provisioning.
- **Built for scale.** Event handling that switches to batching for a fleet-wide reconnect, and bulk registration that runs as a job.
- **Cost optimized.** Close to zero when idle, and a calculator so you know the bill before you ship.
- **Catch regressions early.** A thorough test coverage with unit and integration tests that provide instant feedback to AI coding agents to fix their code.

We organized the repository so that an assistant can make a correct change in a package it has never seen:

- **Rules.** `CLAUDE.md` points at `.claude/rules`, which Cursor reads through a symlink. Quality, behaviour and git rules always apply; Go, AWS and API rules load by path.
- **Skills.** `/run-tests`, `/sync-docs`, `/mr-template` and `/deploy` turn the feature loop into commands.
- **Specs.** 34 design specs on one template sit next to the code, so an assistant can tell a change that fits from one that only compiles.

About 150 Go packages, 120 REST operations and 45 MQTT channels. A small team moves across that surface because the repository teaches the assistant the house rules.

Try asking your AI coding agent to customize ESP RainMaker Neo and see how quickly it understands and make changes without any regressions.

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

{{< alert icon="rocket" >}}
Start at [docs.neo.rainmaker.espressif.com/docs/get-started](https://docs.neo.rainmaker.espressif.com/docs/get-started).
{{< /alert >}}

We really look forward to what you build on your own cloud. Tell us how it goes at <esp-rainmaker-support@espressif.com>, or [open an issue](https://github.com/espressif/esp-rainmaker-neo/issues).
