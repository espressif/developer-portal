---
title: "Conversational AI on ESP32: Connecting esp-webrtc-solution to Agora's Global Real-Time Network"
date: "2026-11-24"
summary: "Espressif's esp-webrtc-solution now connects to Agora SDRTN, Agora's global software-defined real-time network, so ESP32-powered devices can exchange real-time audio and talk to voice AI agents powered by the Agora Conversational AI Engine. This article explains how the open-source integration works — from the WebRTC connection on the device to cascaded and voice-to-voice AI models in the cloud — and how to try it, starting with ESP-Mosaico."
authors:
    - amey-inamdar
tags: ["AI", "Voice", "WebRTC", "ESP32-S3", "ESP32-P4", "ESP-Mosaico", "Agora", "Conversational AI"]
---

Espressif's [esp-webrtc-solution](https://github.com/espressif/esp-webrtc-solution) now connects to Agora SDRTN®, Agora's global software-defined real-time network. Through this open-source integration, ESP32-powered devices can exchange real-time audio over SDRTN and talk to voice AI agents powered by the Agora Conversational AI Engine.

With this integration, developers can add natural, real-time conversations to connected products across smart homes, industrial automation, energy systems, healthcare, and other applications — and get real-time transport without building or operating their own Real-Time Communications (RTC) infrastructure.

The initial implementation supports ESP32-S3, ESP32-S31, and ESP32-P4, as well as the official development boards ESP-Mosaico, ESP32-S31-Korvo-1, and ESP32-S3-Korvo-2.

## Bringing conversational AI to physical products

Conversational AI is transforming voice from a way to issue simple commands into a natural interface for humans interacting with connected products. People can ask questions, clarify requests, and accomplish tasks through ongoing dialogue, without navigating menus or learning predefined commands.

For developers, this creates opportunities to build connected products that understand conversational requests, maintain context across exchanges, and respond intelligently to users' needs.

These experiences require more than speech recognition or a language model. Natural conversation depends on reliable, low-latency audio transport, accurate turn detection, responsive AI processing, and the ability to connect conversations to external systems and tools.

## Agora SDRTN: the foundation for real-time conversations

At the center of the integration is SDRTN, the global network infrastructure underlying Agora's RTC and Conversational AI platform.

With more than 600 points of presence worldwide, SDRTN uses intelligent routing and real-time network monitoring to deliver low-latency, reliable communications across regions and changing network conditions. Its ability to mitigate packet loss and maintain audio quality helps support responsive voice AI interactions, even over unstable connections.

For conversational AI, network performance directly affects the user experience. Delayed responses, dropped audio, and interrupted speech can make even capable AI models difficult to use.

## How the integration works

The open-source integration establishes the real-time audio connection between ESP32 devices and voice AI agents powered by Agora.

{{< figure
    default=true
    src="img/esp32-agora-integration.webp"
    alt="ESP32 device connecting over WebRTC and Agora SDRTN to voice AI agents"
    >}}

__On the ESP32 device__: Espressif's esp-webrtc-solution handles audio capture and playback and establishes a WebRTC connection to SDRTN. The device sends speech over the network and receives spoken responses.

__On the developer's backend__: Developers use the Agora Agent SDK or REST APIs to configure agents and manage their sessions, including starting and stopping conversations. This separates agent management from the device's real-time media connection.

__On Agora's cloud-to-edge device platform__: The Conversational AI Engine runtime is a cloud service that orchestrates conversations between humans and agents. It supports two approaches:

- __Cascaded models__: Developers combine automatic speech recognition (ASR), large language models (LLMs), and text-to-speech (TTS) services, selecting providers according to their application requirements.
- __Native voice-to-voice models__: Developers connect models that process spoken input and generate spoken responses directly.

The engine manages conversational interactions, including turn-taking and coordination with the selected AI models. Developers can also connect agents to external systems and services through the Model Context Protocol (MCP), allowing agents to retrieve information, trigger workflows, and control supported devices during conversations.

For teams that prefer visual development, Agora Agent Studio provides a no-code environment for building, configuring, and testing voice AI agents using cascaded models.

## First implementation on ESP-Mosaico

The first planned implementation of the integration will be on ESP-Mosaico, Espressif's modular development platform introduced in October 2026.

Powered by the ESP32-S31, ESP-Mosaico combines a touchscreen-based host with modular hardware capabilities and AI-assisted development tools. Its ESP-Claw coding agent allows developers to describe applications in natural language and generate software that runs on the device.

Integrating Agora's conversational AI capabilities creates opportunities for developers to experiment with voice-driven applications on ESP-Mosaico, including:

- __Speak to Build__: Describe an application or hardware behavior through spoken conversation, refine requirements with an AI agent, and pass instructions to ESP-Claw for application development.
- __Pocket Interpreter__: Build a portable translation experience that helps people speaking different languages communicate through real-time voice translation and on-screen captions.
- __Voice Home Hub__: Create a conversational interface for connected-home systems, allowing users to make natural-language requests and trigger supported actions through integrated tools.

## Availability

The open-source WebRTC integration is available through Espressif's [esp-webrtc-solution](https://github.com/espressif/esp-webrtc-solution) repository, which includes an Agora demonstration implementation.

ESP-Mosaico is planned as the first platform to showcase the integration. ESP-Mosaico developer kits are available through Espressif.

Developers can access Agora's conversational AI capabilities through Agora Agent Studio, RESTful APIs, or SDKs. The first 300 Conversational AI minutes are free.

Agora and Espressif will also host a Physical AI Hackathon in Kuala Lumpur, Malaysia, on November 28, 2026, providing developers with an opportunity to explore connected-device applications using the combined technologies.
