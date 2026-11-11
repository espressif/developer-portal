---
title: "Own Your IoT Cloud with ESP RainMaker Neo"
date: 2026-11-11
summary: "ESP RainMaker Neo is an open-source, serverless IoT cloud that you deploy into your own AWS account and change to fit your product. This article covers what you get on day one, what it costs to run, why it is a better starting point than generating a cloud from a prompt, and where to start customizing it, with or without an AI coding assistant."
featureAsset: "img/featured/featured-rainmaker-neo.webp"
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


Every connected product reaches the same decision about its cloud: rent a platform, or build your own.

- **Rent one,** and it gets in your way after launch. The data model, OTA and permissions are all *almost* right, and each "almost" becomes a workaround you pay for every month and never own.
- **Build one,** and you write identity, device lifecycle, OTA, voice assistants and an admin console before anything specific to your product.

We built ESP RainMaker Neo as a third option: **own your IoT cloud, without building it from scratch**. It is a complete cloud that runs in your own AWS account, and you change it to fit your product. Let's look at what you get on day one, what it costs, and how you make it yours.

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

## What you get on day one

### For your customers

The stock ESP RainMaker Home app points at your deployment with one QR scan. It brings:

- Onboarding over BLE or the local network
- Local (over IP or Matter), remote, voice control
- Schedules that run on the device, even when the cloud is unreachable
- Automations across devices
- Homes, rooms and sharing
- Time-series history
- Push notifications
- Bridges for Zigbee, BLE mesh and Matter devices

### For your operations team

The Admin Dashboard runs in your account, under your brand and with its own admin sign-in. It handles:

- Batch registration, with certificates and factory partitions generated in the browser
- Per-device connectivity and tags
- Static and dynamic groups
- OTA to one device or a query-defined fleet, with history

### For AI agents

Your deployment ships a [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) server.

1. Add its URL to Claude, Cursor or any MCP client.
2. Sign in once over OAuth.
3. The agent sees exactly the devices that account can reach, through five tools: `list_devices`, `list_groups`, `list_schedules`, `set_params` and `set_schedule`.

```text
You:   "Turn off the kitchen lights and dim the bedroom to 30%."
Agent: list_devices → set_params(Power: false) · set_params(Brightness: 30)
```

Voice assistants are integrated one at a time. MCP makes your product reachable from whatever agent your customer already uses, with no extra firmware work.

## What it costs to run

You pay AWS directly, at AWS prices, only for what your fleet uses.

- **What you pay for:** messages, requests and stored bytes, not server-hours. A quiet fleet costs close to nothing.
- **What it adds up to:** about $3 a month for a ten-node fleet with typical traffic, in the [cost calculator](https://calculator.neo.rainmaker.espressif.com/).
- **What you don't pay:** no per-node licence, and no platform fee for the open-source core.

## Make it yours

**ESP RainMaker Neo is designed to be changed.** Every layer is code you own. Open source is necessary but not sufficient. A platform you can safely modify needs tooling that tells you what a change does, tests that tell you when you are done, and documentation that tells you what was intended.

- **Tooling.** A CLI and Python SDK that sign in as a user or a device and drive REST and MQTT; device and phone-app simulators, so no hardware is needed during development.
- **Tests.** Unit tests own decisions: fast, against mocks, with no deploy needed. Integration tests own wiring: they run against a live deployment and catch problems such as a missing permission. Both run in CI.
- **Documentation.** A design spec per subsystem on one skeleton; OpenAPI and AsyncAPI definitions validated in CI, with the API reference generated from them; and a [docs site](https://docs.neo.rainmaker.espressif.com/) for firmware, backend, apps and dashboard.

Here is what people change in each layer, and where to start.

### Firmware: describe the device, get the app

This is the idea ESP RainMaker started with, and Neo keeps it. You describe your device in firmware, and the cloud and the phone app follow. Here is the core of the `light` example:

```c
light_device = esp_rmaker_lightbulb_device_create("Light", NULL, app_driver_get_power());
esp_rmaker_device_add_bulk_cb(light_device, bulk_write_cb, NULL);
esp_rmaker_device_add_param(light_device, esp_rmaker_brightness_param_create(ESP_RMAKER_DEF_BRIGHTNESS_ID, app_driver_get_brightness()));
esp_rmaker_device_add_param(light_device, esp_rmaker_hue_param_create(ESP_RMAKER_DEF_HUE_ID, app_driver_get_hue()));
esp_rmaker_device_add_param(light_device, esp_rmaker_saturation_param_create(ESP_RMAKER_DEF_SATURATION_ID, app_driver_get_saturation()));
esp_rmaker_node_add_device(node, light_device);
```

Basically:

- **`esp_rmaker_lightbulb_device_create`** creates a light, with its power state read from your driver.
- **`esp_rmaker_device_add_bulk_cb`** registers the callback that receives changes from the app, the cloud or a voice assistant. This is where you drive your hardware.
- **`esp_rmaker_device_add_param`** adds what you want to expose: here brightness, hue and saturation. Each standard parameter carries the UI it should be shown with.

No cloud code and no app code. The phone app reads the device description and draws itself:

{{< figure
    default=true
    src="img/app-light-color.webp"
    alt="ESP RainMaker Home app showing the Light device: a power button and sliders for brightness, hue and saturation"
    caption="The app draws these controls from the firmware's parameters."
    width=300
    >}}

Add a parameter in firmware, ship it over OTA, and the app shows the new control on its next refresh. You can also change provisioning and OTA policy.

**Start:** copy `examples/light` and iterate on the POSIX build, with no board.

### Cloud backend: add what your product needs

- **New REST endpoints.** Adding one is four changes: the API spec, the Go handler, the stack wiring and the tests.
- **Your product's own concepts**, notification channels and cloud integrations.

**With an AI coding assistant.** We organized the repository so that an assistant can make a correct change in a package it has never seen:

- **Rules.** `CLAUDE.md` points at `.claude/rules`, which Cursor reads through a symlink. Quality, behaviour and git rules always apply; Go, AWS and API rules load by path.
- **Skills.** `/run-tests`, `/sync-docs`, `/mr-template` and `/deploy` turn the feature loop into commands. 
- **Specs.** 34 design specs on one template sit next to the code, so an assistant can tell a change that fits from one that only compiles.

**Start:** clone [esp-rainmaker-neo](https://github.com/espressif/esp-rainmaker-neo), run `make deploy`, add an endpoint, then `make test` and `make itest`.

### Phone app: rebrand it, or build your own

- **Rebrand the stock app:** fork [esp-rainmaker-home](https://github.com/espressif/esp-rainmaker-home) and change its icon, name and colours.
- **Build your own** on the [TypeScript SDK](https://github.com/espressif/esp-rainmaker-neo-app-sdk-ts).

**Start:** scan your deployment's QR code in the stock app.

## Why not let AI build the cloud from scratch?

Generating code is now cheap. Knowing that it works is not. An AI assistant will happily generate an IoT backend from a prompt, but not the years of decisions a working one is made of, or the tests that prove them:

- **Working end to end.** Firmware, cloud and apps agree on one data model, one provisioning flow and one OTA path. The seams between them are where generated systems fail.
- **Security thought through.** An X.509 identity per node, challenge-response association, scoped short-lived credentials per user, a separate admin identity, and secured provisioning.
- **Built for scale.** Event handling that switches to batching for a fleet-wide reconnect, and bulk registration that runs as a job.
- **Cost optimized.** Close to zero when idle, and a calculator so you know the bill before you ship.

We keep maintaining the platform and run its end-to-end tests every day. A generated backend is yours alone to maintain. Without tests and specs, it builds up context debt: it works as it was built, but it is a pain to change.

We think AI is better spent on the part that makes it your product than on rebuilding the platform underneath.

## Need more? Enterprise add-ons

The open-source core is complete on its own. For teams that want more, the ESP RainMaker Neo Enterprise Plan adds:

- Support with SLAs
- Enterprise identity features
- ESP Insights device diagnostics, running in your own AWS account
- Private AI agents for your devices and apps
- Consulting to scope, customize and launch your product

Enterprise modules deploy through the same Installer once we enable them for your account. They build with the same Makefile and use the same APIs.

## Get started

1. **Try it in minutes** on Espressif's public deployment: flash a board from the browser, install the ESP RainMaker Home app, and scan the QR code.
2. **Deploy your own cloud** with the Installer, in about an hour.

{{< alert icon="rocket" >}}
Both start at the [Get Started guide](https://docs.neo.rainmaker.espressif.com/docs/get-started).
{{< /alert >}}

To go further:

- [Inside ESP RainMaker Neo](/blog/2026/11/esp-rainmaker-neo-architecture/): how the backend works
- [ESP RainMaker Neo workshop](/workshops/esp-rainmaker-neo/): build a product end to end, in one sitting

We really look forward to what you build on your own cloud. Tell us how it goes at esp-rainmaker-support@espressif.com, or [open an issue](https://github.com/espressif/esp-rainmaker-neo/issues).
