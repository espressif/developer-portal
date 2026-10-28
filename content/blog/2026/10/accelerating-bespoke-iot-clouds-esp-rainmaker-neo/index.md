---
title: "Accelerating Bespoke IoT Clouds with ESP RainMaker Neo"
date: 2026-10-28
summary: ESP RainMaker Neo is a serverless, open-source IoT cloud that deploys into your own AWS account, with firmware, backend, phone apps and an admin dashboard that already work together. This article explains what you get on day one, why it is a better starting point than generating a cloud from a prompt, and how AI coding agents make customising it fast.
featureAsset: "img/featured/featured-rainmaker.webp"
authors:
  - "manali-kaswa"
  - "kedar-sovani"
tags:
  - Rainmaker
  - IoT
  - Cloud
  - AWS
  - AI
---

Every connected product eventually faces the same choice. A generic IoT platform gets you to launch, then starts to fight you: the data model is *almost* right, OTA is *almost* what your fleet needs, permissions are *almost* how your business works. Every "almost" becomes a workaround you pay for monthly and never own. The alternative, building your own cloud, means identity, device lifecycle, groups, time series, OTA, voice assistants and an admin console before you ship anything specific to your product.

ESP RainMaker Neo exists to collapse that trade-off: a complete IoT cloud you own, that you can change, and that an AI coding agent can change for you.

## What ESP RainMaker Neo is

A serverless, open-source IoT cloud that deploys into **your own AWS account**.

- **Serverless.** Managed AWS services end to end. No servers to patch, near-zero cost while idle.
- **Open source.** Firmware, backend, phone apps and dashboard are all Apache-2.0, yours to read, fork and customise.
- **Private.** Your account, your data, your bill. No per-node licence, and no Espressif service in the loop once deployed.

## Four pieces, all open source

{{< figure
    default=true
    src="img/architecture.png"
    alt="ESP RainMaker Neo architecture: ESP32 devices talk MQTT to the IoT cloud backend; admin clients reach it over the AWS SDK; user clients over HTTPS and MQTT; local control and Matter connect phones to devices directly"
    caption="Devices, backend, user clients and admin clients. Every box is an open repository."
    >}}

- **Device firmware.** An SDK for ESP-IDF and POSIX: [esp-rainmaker-neo-firmware](https://github.com/espressif/esp-rainmaker-neo-firmware).
- **Cloud backend.** Go Lambda handlers and CDK stacks, private to your account: [esp-rainmaker-neo](https://github.com/espressif/esp-rainmaker-neo).
- **Phone apps and SDK.** [esp-rainmaker-home](https://github.com/espressif/esp-rainmaker-home) and the [TypeScript app SDK](https://github.com/espressif/esp-rainmaker-neo-app-sdk-ts).
- **Admin Dashboard.** Node management, OTA and configuration, shipped inside the backend repository.

Because every piece is open, customising a product means editing, not working around.

## What you get on day one

**For your customers**, in the stock ESP RainMaker Home app pointed at your deployment with one QR scan: QR-based onboarding over BLE with a secured session and challenge-response association; local control on the same Wi-Fi and remote control elsewhere; schedules that run on the device even when the cloud is unreachable; cloud-evaluated automations; homes, rooms and sharing; group control; time-series history; bridges and Matter; Alexa, Google Home and SmartThings; and push notifications.

**For your operations team**, in the Admin Dashboard: device identity and batch registration, with factory partitions generated in the browser; device management with static and dynamic groups; OTA to a device, a group or a query-defined fleet, snapshot or continuous, with per-device status; a separate admin identity pool with role-based access; integration settings for voice assistants, push credentials and node capabilities; post-deployment checks; and branding and a custom domain. Beside the dashboard sit a Python SDK and CLI, device and app simulators, and an integration suite that runs against your live stack.

**For enterprises**, paid modules add support with SLAs, enterprise identity features, bridge integrations, ESP Insights diagnostics and private AI agents. They deploy through the same Installer and build with the same Makefile, so nothing forks.

## Voice assistants today, any AI agent tomorrow

Alexa, Google Home and SmartThings integrations deploy with your cloud. You configure your skill's credentials in the Admin Dashboard; your users enable the skill, link once and discover their devices.

Your deployment also ships a [Model Context Protocol](https://modelcontextprotocol.io/) server. Add its URL to Claude, Cursor or any MCP client, sign in once over OAuth, and the agent sees exactly the devices that account can reach, with `list_devices`, `list_groups`, `list_schedules`, `set_params` and `set_schedule`. Voice assistants are closed ecosystems you integrate with one at a time. MCP is one open interface every agent speaks, so your product is reachable from whatever assistant your customer already uses, with no new integration per vendor and no extra firmware work.

## What it costs to keep running

Serverless changes what you pay for, and who you need.

- **Near-zero idle cost.** You are billed per message, request and stored byte, not per server-hour. A ten-node fleet is about $2.5 a month, and a prototype and a product run on the same stacks.
- **Less engineering to keep it up.** No OS patching, no clusters, no database upgrades, no on-call for infrastructure.
- **No scaling headaches.** The same stacks serve one node and a million, with a runtime switch between a cost-optimised and a scaling mode.

What you pay is your AWS bill, at AWS prices, in your own account. Estimate a fleet with the [cost calculator](https://calculator.neo.rainmaker.espressif.com/).

## Designed to be changed

Open source is necessary but not sufficient. A platform you can safely modify needs tooling that tells you what a change does, tests that tell you when you are done, and documentation that tells you what was intended.

- **Tooling.** A CLI and Python SDK that sign in as a user or a device and drive REST and MQTT; device and phone-app simulators, so no hardware is needed during development; App Studio to preview a rebranded app live.
- **Tests.** Unit tests own decisions: over 3,000 test cases against mocked AWS, fast and parallel, no deploy needed. Integration tests own wiring: over 400 tests against your live stack, catching a missing permission or an unattached IoT policy. Both run in CI with lint, vulnerability and secret scans.
- **Documentation.** A design spec per subsystem on one skeleton; OpenAPI and AsyncAPI definitions validated in CI, with the API reference generated from them; and a [docs site](https://docs.neo.rainmaker.espressif.com/) for firmware, backend, apps and dashboard.

What people change, in practice:

- **Firmware.** Their own devices and parameters, which is the data model the app draws from; provisioning transport and security; OTA policy and rollback diagnostics; local control, time series, bridge children.
- **Backend.** A REST endpoint as four changes: spec, Go handler, stack wiring, tests. A new notification channel, trigger or action as a registry entry. Proprietary code in a sibling `addon_modules` folder that the same Makefile builds. Dashboard branding from one config file.
- **Phone apps.** The stock app with your deployment's QR and no app code; a rebrand of esp-rainmaker-home under your own store account; or your own app on the TypeScript SDK.

Each change is local: a directory, a registry entry, a config file. Nothing requires forking the platform.

## Why not just let AI build it from scratch?

An assistant will happily generate an IoT backend from a prompt. What it cannot generate is the years of decisions a working one is made of. Neo is those decisions, made up front:

- **Working end to end.** Firmware, cloud and apps already agree on one data model, one provisioning flow and one OTA path. The seams are where generated systems fail.
- **Security thought through.** An X.509 identity per node, challenge-response association, scoped short-lived credentials per user, a separate admin identity, secured provisioning sessions.
- **Built for scale.** Serverless from the first node to the millionth, event handling that switches to batching for a fleet-wide reconnect, bulk registration that runs as a job.
- **Cost optimised.** A cost-conscious architecture, near-zero when idle, and a calculator so you know before you ship.

That is the starting point. Let AI write the delta that makes it your product, not the platform underneath.

## Built to be changed by an assistant

The backend repository is organised so that an AI coding agent can land a correct change in a package it has never seen.

- **Rules.** A `CLAUDE.md` points at `.claude/rules`: code quality, behaviour and git flow always on; Go, AWS and API rules load by path. Cursor reads the same files through a symlink. One of them says it plainly: keep code AI-compatible, with self-documenting names, small focused functions, explicit types and predictable structure.
- **Skills.** `/implementation-plan`, `/run-tests`, `/sync-docs`, `/mr-template` and `/deploy` turn the feature loop into commands: spec it, implement it under the rules, test it, sync the docs, open the PR. The test skill never weakens an assertion to get green; the deploy skill always asks before touching an account.
- **Specs are the contract.** Thirty-four design specs on one skeleton, API definitions validated in CI, and an MCP tool catalogue generated from a snapshot test. An assistant reading the spec beside the code can tell what is intentional, which is the difference between a change that fits and one that merely compiles.

About 150 Go packages, 120 REST operations and 45 MQTT channels. A small team moves across that surface because the repository teaches the assistant the house rules.

## Try it in minutes

Flash a devkit from the browser, install ESP RainMaker Home, scan the QR, and you have a working device on Espressif's public deployment with nothing to deploy. Then deploy your own cloud with the Installer in about an hour.

{{< alert icon="rocket" >}}
Start at [docs.neo.rainmaker.espressif.com/docs/get-started](https://docs.neo.rainmaker.espressif.com/docs/get-started).
{{< /alert >}}

- Docs: [docs.neo.rainmaker.espressif.com](https://docs.neo.rainmaker.espressif.com/)
- Cost calculator: [calculator.neo.rainmaker.espressif.com](https://calculator.neo.rainmaker.espressif.com/)
- Repositories: [esp-rainmaker-neo](https://github.com/espressif/esp-rainmaker-neo), [esp-rainmaker-neo-firmware](https://github.com/espressif/esp-rainmaker-neo-firmware), [esp-rainmaker-home](https://github.com/espressif/esp-rainmaker-home), [esp-rainmaker-neo-app-sdk-ts](https://github.com/espressif/esp-rainmaker-neo-app-sdk-ts)
- Questions: esp-rainmaker-support@espressif.com
