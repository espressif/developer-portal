---
title: "Assignment 3: ESP-NOW Communication"
date: 2025-10-17T00:00:00+01:00
showTableOfContents: true
series: ["WS00M"]
series_order : 4
showAuthor: false
---

In this assignment, you will implement wireless Morse code communication between two ESP32-C3-DevKit-RUST-2 development boards using ESP-NOW protocol.

You’ll need to work with a partner: one of you will implement the Sender and the other will implement the Receiver.

## Understanding ESP-NOW

ESP-NOW is a connectionless communication protocol developed by Espressif that enables direct, low-power communication between ESP devices (ESP8266, ESP32, ESP32-S and ESP32-C series of SoCs) without requiring Wi-Fi router infrastructure. Key features:

- **Low latency**: ~10ms typical
- **No router required**: Direct device-to-device communication
- **Long range**: Up to 200m line-of-sight (depending on environment)
- **Multiple peers**: Can communicate with up to 20 peers

## Project Morse Code Sender and Receiver

You'll build one of two devices: a sender that transmits Morse code or a receiver that displays the Morse code on an LED.

**Morse Code Timing**:

- **Dot**: Short press (< 0.3 seconds)
- **Dash**: Long press (≥ 0.3 seconds)

Pick one of the following roles and proceed with your assignment:

- **Sender**: [Assignment 3 - Sender](../assignment-3-sender/).
- **Receiver**: [Assignment 3 - Receiver](../assignment-3-receiver/).
