---
title: "What’s New with ESP ZeroCode"
date: 2024-04-28
showAuthor: false
featureAsset: "img/featured/featured-zerocode.webp"
authors:
  - kedar-sovani
tags:
  - IoT
  - Zero Code
  - Esp32
  - Espressif

---
*The Fastest Way to Launch Matter-enabled Products*

{{< figure
    default=true
    src="img/whats-1.webp"
    >}}

It’s been about 8 months since we launched [ESP ZeroCode](https://zerocode.espressif.com). For all these months, continuous interest and customer activity has kept us busy. Let’s look at some of the highlights of what’s new with ESP ZeroCode.

## Customer Interest

Over 11,000 users across 125 countries have visited ESP ZeroCode, building various kinds of Matter-enabled products. Every week we get numerous queries and requests for samples or product-related queries. Many of these have now become products that have completed certification and selling in their respective market places.

Along the way we have Matter-certified over 100 ESP ZeroCode powered devices.

## Quality

We have been rigorously conducting automated QA tests and making continuous fixes in the ZeroCode firmware. These include a variety of tests including,

- long-duration tests over 30 days
- tests under network stress and RF interference
- tests with multiple simultaneous ecosystem operations
- OTA and rollback tests

Overall the test framework runs over 1000 tests, and most of these are run for over 50 different products.

Numerous issues for memory footprint, corner cases, commissioning/uncommissioning have been identified and fixed.

## Product Enhancements

We now support 2 different solution types through ESP ZeroCode.

- __single-chip solution:__  This is the typical solution that we launched with, which today, runs on Wi-Fi (ESP32-C3, ESP32-C2, ESP32) and Thread (ESP32-H2). This solution is the most cost optimised solution and is recommended for all lighting categories.
- __two-chip (hosted) solution:__  Our ESP ZeroCode ExL is a hosted solution that is ideal for __Appliances__ . Appliances often consider connectivity through a “connectivity co-processor”, and work with it over a UART interface. Our two-chip solution addresses the typical Appliance scenarios, particularly MQTT connectivity to cloud platforms (AWS IoT). Read more about it here: [Announcing ESP ZeroCode ExL](/blog/esp-zerocode-exl-module-powered-by-aws-iot-expresslink-simplifying-matter-compatible).

---

We also extended our portfolio of partnerships. All ESP ZeroCode products can now be easily certified with all of the following ecosystem programs:

- Works with Alexa
- Works with Apple Home
- Works with Google Home
- Works with Home Assistant
- Works with SmartThings

---

We also collaborated with Amazon with Alexa Connect Kit (ACK) for Matter and created ZeroCode devices using the ACK for Matter. Through the ESP ZeroCode portal, you can now choose ACK for Matter as a solution for the firmware of your devices.

## Device Catalogue

As Matter standard evolved from v1.0 to v1.1 and v1.2, it kept introducing support for new device types. We have kept pace with the standard’s evolution and have been incorporating newer device types and a variety of device drivers in our product catalogue.

Today, with ESP ZeroCode, you can quickly build the following Matter-enabled products:

- Window Blinds (automatic and manual calibration)
- Sockets: 1, 2, 3, 4 channel
- Power outlets: 1, 2, 3, 4 channel
- LED Lights with options for RGB, RGBW, RGBWW, RGBCW and RGBCCT with the following drivers are supported: WS2812, PWM, BP5758D, BP5758D, BP1658CJ, BP1658CJ, SM2135E, SM2135E, SM2135EH, SM2135EH, SM2135EGH, SM2135EGH, SM2335EGH
- Filament bulbs, Candle bulb, Reflector bulb, Downlights, Flat Panels (Full Colour, Tunable White)
- Dimmers
- Appliances (hosted mode solutions) like Thermostat, Air Conditioner, Laundry Washer, and Refrigerator

All the above device types are available on both Wi-Fi as well as Thread/802.15.4 transport.

## Richer Customisations

With the introduction of text mode configurability, ESP ZeroCode now allows richer set of customisations.

You can now create multi-channel outlets or sockets. You can also create multi-endpoint device types, like a socket and a light in the same accessory and such.

A variety of driver specific customisations have been included. A few of these include,

- Various configurations for lightbulbs, viz: current, gamma, low power
- Configuring indicator colours and patterns for all the device states, viz: setup mode, device ready, network disconnected
- The state of the device after turning the power on, viz: power, brightness, colour
- Factory reset trigger mechanism

## Shorter Time To Market

A number of optimisations in our manufacturing and certification processes have been made to provide the shortest production time.

In the fastest case, some of our customers have gone from concept to production-start (including certification) within 3 weeks.

---

All in all, we are taking great strides to make ESP ZeroCode the fastest, most secure and robust tool to launch Matter products. If you are looking to develop and maintain your own Matter-enabled products, with your specific customisation, please head over to [ESP ZeroCode](https://zerocode.espressif.com) to get started.

For additional information about ESP ZeroCode, check out this podcast:

{{< youtube XMh81q81EMA >}}
