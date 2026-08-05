---
title: "Open Sourcing ESP RainMaker Neo"
date: 2026-08-05
showAuthor: false
authors:
  - "amey-inamdar"
tags:
  - ESP RainMaker
  - announcement
  - open source
  - AWS
  - Matter
  - cloud
summary: "ESP RainMaker Neo is a new implementation of ESP RainMaker in which the entire device-to-cloud-to-app stack, including the cloud backend, is open source under the Apache License 2.0. This article explains what Neo is, why we rebuilt RainMaker on native AWS IoT services, what open source means in practice for your product, and how Neo relates to ESP RainMaker Classic."
---

Over the past several years, ESP RainMaker — now known as ESP RainMaker Classic — has helped developers build and operate their own IoT cloud platform, deployed directly in their own AWS account. This model gives developers and organizations ownership of their infrastructure and data, while a serverless architecture minimizes infrastructure management, scales with their needs, and provides the benefits of pay-as-you-go cloud services.

ESP RainMaker Classic provides open-source device firmware, mobile apps, and dashboards, together with an open API for the cloud backend. While the backend itself is closed source, the open APIs and client-side components provide developers significant flexibility to build and customize their own connected product experience.

Today, we are taking this model further with ESP RainMaker Neo.

**[ESP RainMaker Neo](https://github.com/espressif/esp-rainmaker-neo) is a new implementation of ESP RainMaker** in which the entire device-to-cloud-to-app stack, including the cloud backend, is open source. **The RainMaker Neo backend is released under the Apache License 2.0.** It is production-ready and can be deployed directly into your own AWS account, giving you control over the infrastructure, data, and product experience. Device firmware, mobile apps, dashboards, and voice assistant integrations for Alexa and Google Home are also available as open-source components under their respective licenses.

At the same time, we have kept the developer experience familiar. The device-side APIs remain largely similar to ESP RainMaker Classic, while the hybrid mobile app SDK (RainMaker Home) remains the same, with an additional underlying transport for ESP RainMaker Neo. Developers already familiar with ESP RainMaker Classic can therefore get started with Neo without having to relearn the device and mobile application stack.

While ESP RainMaker Neo maintains familiarity at the device and mobile application layers, it is a new implementation with a different cloud architecture from ESP RainMaker Classic. Existing ESP RainMaker Classic deployments cannot be directly migrated to Neo, and the two platforms are not deployment-compatible. **ESP RainMaker Neo is therefore recommended for new product development**, while existing products deployed on ESP RainMaker Classic can continue to use the Classic platform, which remains supported by Espressif.

## Why a New Implementation?

From its inception, ESP RainMaker has been **guided by a set of core design tenets: maintainability, scalability, security, openness, and cost efficiency.** These principles shaped the architecture of ESP RainMaker Classic and the technology choices we made at the time. They continue to be the north star for ESP RainMaker Neo.

What has changed is the technology landscape around us. When ESP RainMaker Classic was designed several years ago, we made architectural choices based on the capabilities and economics of AWS services available at the time. As AWS IoT has evolved, both its capabilities and pricing have changed significantly. Choices that best satisfied our design tenets then are therefore not necessarily the choices we would make today.

For example, we consciously chose not to use AWS IoT OTA in ESP RainMaker Classic because its cost at the time made it unsuitable for the broad range of connected products RainMaker was designed to support. Today, that is hardly a concern. Similarly, limitations in Device Shadow capabilities at the time influenced how we modeled device data and built some of the functionality around it.

ESP RainMaker Neo gave us an opportunity to revisit these architectural choices while staying true to the same design tenets. **Neo is a leaner implementation that relies more directly on native AWS IoT services** such as Device Shadow, Thing Groups, and AWS IoT OTA. User and device permissions are enforced using IAM-level access control, further leveraging AWS-native mechanisms for security and authorization.

Importantly, this architectural evolution does not come at the expense of cost efficiency. **ESP RainMaker Neo continues the cost-efficient serverless model of ESP RainMaker Classic** and is designed to remain economically viable for high-volume, cost-sensitive connected products. The evolution of AWS services allows Neo to make greater use of native capabilities while continuing to meet the cost considerations that have always been fundamental to RainMaker.

The result is a simpler and more AWS-native architecture, with less RainMaker-specific infrastructure to build and maintain, while benefiting directly from the scalability, security, and continued evolution of AWS IoT services.

## What Does Open Source Mean in Practice?

With ESP RainMaker Neo, open source means more than visibility into the source code. You have the freedom to understand, customize, integrate, and audit every layer of the platform — from the device firmware and cloud backend to the mobile apps and dashboards. You can adapt the platform to your product requirements, integrate it with your existing systems and workflows, and evolve it on your own roadmap while retaining full control over the infrastructure and data.

For connected-product companies, this provides an opportunity to make the IoT platform itself a product differentiator without having to build the foundational infrastructure from scratch. ESP RainMaker Neo provides a production-ready starting point built on AWS services, while leaving you free to extend or replace parts of the stack as your needs evolve. And because the complete implementation is open source and runs in your AWS account, teams with the necessary cloud and embedded expertise can operate, troubleshoot, modify, and maintain the platform independently, without being dependent on Espressif for technical support.

## Familiar RainMaker Capabilities, Built on AWS IoT

ESP RainMaker Neo retains most of the capabilities that developers have come to expect from ESP RainMaker Classic. This includes device registration and user-device association, user management, remote device control and telemetry, time-series data, schedules, automations, and more. The goal is to provide a familiar and comprehensive foundation for building connected products, while making the underlying implementation simpler, more transparent, and easier to adapt.

Device management, in particular, benefits from Neo's deeper use of native AWS IoT services. Capabilities such as device organization and grouping, OTA updates, and fleet management build directly on AWS IoT's device management infrastructure. This allows ESP RainMaker Neo to benefit from the scalability and continued evolution of AWS IoT, while avoiding the need to build and maintain parallel RainMaker-specific implementations of these capabilities.

## Matter Across Device, App, and Cloud

**ESP RainMaker Neo provides comprehensive Matter support** across the device, mobile app, and cloud. Espressif's Matter-enabled devices can use the ESP-Matter SDK, while the RainMaker mobile SDKs and reference apps provide Matter commissioning and control capabilities. RainMaker Neo extends Matter into the cloud by providing Matter Fabric capabilities, allowing the cloud to securely interact with devices on the RainMaker Matter Fabric. This brings together Matter's local interoperability with RainMaker's remote access and cloud capabilities, providing developers a complete foundation for building and managing Matter-enabled connected products.

## Built for Production — and Ready to Evolve

ESP RainMaker Neo is built with production use in mind. The platform is backed by well-documented specifications that define its architecture, interfaces, and expected behavior. The implementation also has significant automated test coverage, including unit and integration tests across the stack.

This foundation becomes even more valuable in the age of AI-assisted software development. Well-defined specifications give developers — and AI coding tools — a clear description of the intended behavior, while comprehensive tests provide the feedback loop needed to validate changes. Together, they make it significantly easier to understand, customize, and extend ESP RainMaker Neo while maintaining compatibility and expected behavior.

## Enterprise Support and Additional Capabilities

For teams that need additional capabilities, the **ESP RainMaker Neo Enterprise Plan adds technical support and SLAs, along with complementary stacks** such as ESP Insights for remote device observability and ESP Private Agents for cloud-based AI agent capabilities.

Customers can also draw on Espressif's expertise in connected devices, AWS IoT architecture, and RainMaker to design, customize, and integrate solutions for their specific requirements. This combines the flexibility of an open-source platform with direct access to the teams that build and evolve the underlying technologies.

The Enterprise offering builds on the same open-source ESP RainMaker Neo foundation, allowing teams to start with the open-source platform and add Espressif support, expertise, and additional capabilities as their requirements evolve.

## Getting Started

ESP RainMaker Neo is available today as open source. You can start against the **public ESP RainMaker Neo deployment** with no cloud setup at all, run the **packaged backend** in your own AWS account, or **build the cloud from source** and deploy your own version.

The [Get Started guide](https://docs.neo.rainmaker.espressif.com/docs/get-started) walks you through the full path end to end — deploying the cloud backend, building and flashing the device firmware, and provisioning and controlling your device with the **ESP RainMaker Home** app ([iOS](https://apps.apple.com/us/app/esp-rainmaker-home/id1563728960) / [Android](https://play.google.com/store/apps/details?id=com.espressif.novahome)). To go straight to the device side, start from the [firmware examples](https://github.com/espressif/esp-rainmaker-neo-firmware/tree/main/examples).

The complete stack is open source — the [cloud backend](https://github.com/espressif/esp-rainmaker-neo), the [firmware](https://github.com/espressif/esp-rainmaker-neo-firmware), the [mobile app](https://github.com/espressif/esp-rainmaker-home), the [app SDK](https://github.com/espressif/esp-rainmaker-neo-app-sdk-ts), and the dashboard — with the full [HTTP and MQTT API reference](https://api.docs.neo.rainmaker.espressif.com) available online.

To learn more about ESP RainMaker, visit <https://rainmaker.espressif.com/>. If you are evaluating ESP RainMaker Neo for a new product, or would like to discuss the Enterprise Plan, please [get in touch with us](https://www.espressif.com/en/contact-us/sales-questions).

We would love to hear how ESP RainMaker Neo works for you. Once you have given it a try, tell us what you built, what worked well, and what could be better — your feedback will help shape where Neo goes next.
