---
title: "Physical AI doesn't stop at the robot: one workflow from robots to ESP32 sensors and cameras"
date: 2026-11-01
featureAsset: "img/featured/featured-espressif.webp"
summary: "Physical AI systems combine robots, cameras, distributed sensors, and the cloud, each with its own tools and connections. This article introduces Wendy Lite, which brings ESP32 microcontrollers into the Wendy platform, so you can deploy and manage them with the same workflow as your robots."
tags:
  - AI
  - ESP-IDF
  - robotics
  - cloud
  - physical AI
  - camera
authors:
  - "gabriele-mondada"
  - "joannis-orlandos"
---

Physical AI is AI that perceives the real world and acts on it. Such a system is rarely a single robot. It is a whole environment: robots and drones of different kinds, edge devices, cameras, microphones, and sensors spread across a building or a field, plus the cloud and sometimes local servers. All these devices must work as one system. A robot may need the video stream of a camera across the room, and sensor readings flow to the cloud, sometimes through a local server.

Building such a system raises the same challenges again and again:

- **Hardware diversity:** robots, sensors, servers, and cloud services each come with their own tools.
- **Connectivity:** devices talk through the cloud, over the local network, or over a mesh network they create themselves.
- **Security:** every device needs its own identity, and every connection must be secured.
- **Configuration:** each device needs Wi-Fi credentials, communication settings, and a link to the cloud.
- **Simulation:** a mixed system is hard to simulate, and each part may need a different level of detail, from a simple model to a full emulation of its hardware.
- **Deployment:** shipping software must be automated and work the same way on every target.
- **Data sharing:** a robot must get a camera's video stream or a sensor's readings without custom plumbing.

Behind all of these lies one challenge: a single, consistent way to develop, simulate, configure, deploy, and connect every device in the system, whatever its size.

Meeting this challenge is Wendy's mission. For robot control, Wendy already supports a wide range of Linux-class boards, such as NVIDIA Jetson and Raspberry Pi. But many of the sensors and cameras around the robots do not need a Linux board: they run on microcontrollers.

To cover this side of the system, Wendy chose to support Espressif's ESP32 ecosystem:

- **Popular and affordable:** ESP32 is one of the most widely adopted microcontroller platforms, with many variants at a low cost.
- **A broad family:** from small low-power chips to the high-performance ESP32-P4, it covers a large range of applications.
- **Many boards:** a large choice of ready-made boards, from Espressif and many other makers.
- **Built-in connectivity:** Wi-Fi, Bluetooth, mesh networking, and USB.
- **Security:** hardware cryptography and a complete software stack, with TLS 1.3 and post-quantum cryptography.
- **Camera support:** one ESP32 is enough to drive a camera and stream its video over the network.

That's why we're introducing Wendy Lite: An ESP32 tool for rapid iteration and integration of robotics. Same tool, same experience, from a robot down to the smallest sensor.

## How it works

Everything goes through one tool: the Wendy CLI. This CLI supports MCP, scripting and even powers GUI apps.

The quickest way to get started is to flash a prebuilt Wendy Lite firmware onto your board. Connect it over USB and run:

```bash
wendy install
```

Select your board, optionally enter your Wi-Fi credentials, and that's it. To list your devices, simply run:

```bash
wendy discover
```

It finds your devices whatever the connection: USB, LAN, Bluetooth, Mesh Networking and even over an opt-in cloud uplink.

From here, you can view your device logs without plugging into UART, through:

```bash
wendy device logs
```

If your device has a camera, view its video stream with:

```bash
wendy device camera view
```

## Build and run an app

Let's build and run a classic blink program:

```bash
wendy init blink-demo --template blink-rgb-led
cd blink-demo
```

This creates a regular ESP-IDF project:

```text
blink-demo/
├── CMakeLists.txt
├── README.md
├── sdkconfig.defaults
├── wendy.json
└── main/
    ├── CMakeLists.txt
    ├── idf_component.yml
    ├── main.c
    ├── rgb_led.c
    └── rgb_led.h
```

The additional `wendy.json` file makes that project a Wendy Lite app, which can be deployed with just one command:

```bash
wendy run
```

The only prerequisite is the ESP-IDF Installation Manager (EIM). The Wendy CLI handles the rest: it installs the ESP-IDF toolchain, builds your project, connects to the device, flashes the app, runs it, and streams its logs back to your terminal. This works over USB and Wi-Fi, and remotely through Wendy Cloud.

## Full ESP-IDF support

Your app is a regular ESP-IDF project, so you have full access to the ESP-IDF ecosystem and full control over your device.

What makes it a Wendy Lite app is the `wendy_core` component. It manages connectivity and lets you update the app over a local connection or through the cloud. Include and initialize it first in `app_main()`:

```c
#include "wendy_core.h"

void app_main(void)
{
    ESP_ERROR_CHECK(wendy_core_init());
    // your code here
}
```

Already have an ESP-IDF project? Run `wendy run` in its folder. The CLI offers to create `wendy.json` and to add the `wendy_core` component if they are missing. Your `sdkconfig` stays in your hands, and a few of its settings need to match what `wendy_core` expects. Configuring these settings can be tricky, so it is always better to start from one of our templates: its `sdkconfig.defaults` already has the right values.

## Wendy Cloud

You can use Wendy Lite entirely on your local network, with no cloud account. But when your sensors are spread across a building or a field, enroll them in Wendy Cloud and reach them from anywhere. Log in once, then `wendy install` can enroll the board while flashing it, or you can enroll it later over USB:

```bash
wendy auth login
wendy device enroll
```

Enrollment gives each device its own identity, built on proven security standards: keys generated on the device that never leave it, X.509 certificates with SPIFFE identities, mutual TLS 1.3, and certificate chains signed with post-quantum ML-DSA (FIPS 204). Once enrolled, only your team can reach the device, whether over the local network, Bluetooth, or the cloud.

## SensorLink

A robot often needs a camera it does not carry, such as an ESP32 camera across the room. SensorLink lets a Wendy device use the sensors of another Wendy device. To pair your robot with the camera, run:

```bash
wendy device pair
```

The CLI guides you: pick your robot, then the camera to use. The camera then appears on your robot exactly like a local camera. Both devices must be enrolled in your organization.

## Try it

All of the above features enable ESP32 to get the most out of your ESP32 microcontrollers. Whether you're building an offline-first mesh network, or building a digital twin. Wendy Lite can quickly turn your ESP32 into a capable and reliable interconnected device.

We would love your feedback while we continue extending its capabilities.

To get started:

1. Get an ESP32-C6 dev kit, or a Seeed XIAO ESP32-S3 Sense for the camera features.
2. Install the Wendy CLI from [wendy.dev](https://wendy.dev).
3. Watch [this video](https://www.youtube.com/watch?v=DLwwTzSmptQ) or follow one of our tutorials.

Wendy Lite is open source and available on GitHub at [wendylabsinc/wendy-lite](https://github.com/wendylabsinc/wendy-lite).
