---
title: "Espressif’s Alexa SDK v1.0b1!"
date: 2018-09-24
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kedar-sovani
tags:
  - ESP32
  - Alexa
  - IoT
  - Framework
aliases:
  - espressifs-alexa-sdk-v1-0b1
---
The Espressif’s Alexa SDK v1.0b1 is now available on github here: [https://github.com/espressif/esp-avs-sdk](https://github.com/espressif/esp-avs-sdk)

This is a low-footprint C-based SDK that includes support for all of the following features:

- __Conversations__  (Calendar, Shopping, News, Todo, Info, Movies, Sports)
- __Music/Audio Services__ : Amazon Prime Music, Audible, Kindle, TuneIn and iHeartRadio
- __Alerts__ : Alarms, Timers, Reminders and Notifications

## Supported Hardware

By default, the SDK supports [ESP32-LyraT](https://www.espressif.com/en/products/hardware/esp32-lyrat) development boards.

The SDK is so structured that it should be easily possible to support other hardware configurations.

## Getting Started

Instructions for building, flashing and using the firmware are available [here](https://github.com/espressif/esp-va-sdk/tree/master/examples).

## Hands-Free Mode/Wake-Word Engine

The SDK also supports hands-free mode of operation. The example [lyrat_alexa_sr/](https://github.com/espressif/esp-va-sdk/tree/master/examples) is provided that demonstrates the use in a hands-free mode (activity triggered based on saying ‘Alexa’ instead of pushing a button).

As discussed in a previous article, [Anatomy of a Voice-Integrated Device](/blog/anatomy-of-a-voice-integrated-device), multiple configurations are possible given the micro-controller, DSP and the wake-word engine. The example [lyrat_alexa_sr/](https://github.com/espressif/esp-va-sdk/tree/master/examples) demonstrates the scenario where the Alexa client as well as the WWE is running on ESP32.

## Phone Apps

The SDK release also includes a phone app for Android for performing (a) network configuration of the development board and (b) Authentication with Amazon. The source code for this app is also available here: [https://github.com/espressif/esp-idf-provisioning-android/tree/versions/avs](https://github.com/espressif/esp-idf-provisioning-android/tree/versions/avs). It can be easily modified to add your Alexa project’s ID and credentials. It can also be easily customized to the branding and look-and-feel of your products.

## Production Ready

We offer a complete production-ready solution that includes all Alexa features, reference phone app implementations and hardware reference designs. If you are interested in building commercial products with this, please reach out to us.
