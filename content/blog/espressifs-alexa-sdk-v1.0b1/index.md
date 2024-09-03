---
title: Espressif’s Alexa SDK v1.0b1!
date: 2018-09-24
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----326f13c862f6--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fespressifs-alexa-sdk-v1-0b1-326f13c862f6&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----326f13c862f6---------------------post_header-----------)

--

The Espressif’s Alexa SDK v1.0b1 is now available on github here: [https://github.com/espressif/esp-avs-sdk](https://github.com/espressif/esp-avs-sdk)

This is a low-footprint C-based SDK that includes support for all of the following features:

- __Conversations__  (Calendar, Shopping, News, Todo, Info, Movies, Sports)
- __Music/Audio Services__ : Amazon Prime Music, Audible, Kindle, TuneIn and iHeartRadio
- __Alerts__ : Alarms, Timers, Reminders and Notifications

## Supported Hardware

By default, the SDK supports [ESP32-LyraT](https://www.espressif.com/en/products/hardware/esp32-lyrat) development boards.

The SDK is so structured that it should be easily possible to support other hardware configurations.

## Getting Started

Instructions for building, flashing and using the firmware are available here: [https://github.com/espressif/esp-avs-sdk/tree/master/examples/lyrat_alexa](https://github.com/espressif/esp-avs-sdk/tree/master/examples/lyrat_alexa)

## Hands-Free Mode/Wake-Word Engine

The SDK also supports hands-free mode of operation. The example [lyrat_alexa_sr/](https://github.com/espressif/esp-avs-sdk/tree/master/examples/lyrat_alexa_sr) is provided that demonstrates the use in a hands-free mode (activity triggered based on saying ‘Alexa’ instead of pushing a button).

As discussed in a previous article, [Anatomy of a Voice-Integrated Device](https://medium.com/the-esp-journal/anatomy-of-a-voice-controlled-device-e48703e0ec20), multiple configurations are possible given the micro-controller, DSP and the wake-word engine. The example [lyrat_alexa_sr/](https://github.com/espressif/esp-avs-sdk/tree/master/examples/lyrat_alexa_sr) demonstrates the scenario where the Alexa client as well as the WWE is running on ESP32.

## Phone Apps

The SDK release also includes a phone app for Android for performing (a) network configuration of the development board and (b) Authentication with Amazon. The source code for this app is also available here: [https://github.com/espressif/esp-idf-provisioning-android/tree/versions/avs](https://github.com/espressif/esp-idf-provisioning-android/tree/versions/avs). It can be easily modified to add your Alexa project’s ID and credentials. It can also be easily customized to the branding and look-and-feel of your products.

## Production Ready

We offer a complete production-ready solution that includes all Alexa features, reference phone app implementations and hardware reference designs. If you are interested in building commercial products with this, please reach out to us.
