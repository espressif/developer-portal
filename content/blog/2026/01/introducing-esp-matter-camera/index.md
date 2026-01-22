---
title: "Espressif - Introducing Matter Cameras"
date: 2026-01-21
slug: "introducing-esp-matter-camera"
authors:
  - sayon-deep
tags:
  - ESP32-P4
  - announcement
  - camera
  - Matter
  - WebRTC
  - IoT


summary: "This article describes the Matter camera features introduced in Matter 1.5 and discusses camera support for the ESP32 series of SoCs using Espressif Matter SDK"
---

Today, we are excited to announce Matter-based camera support for Espressif SoCs: the industry’s first implementation for MCU-based camera devices.

In November 2025, the [Connectivity Standards Alliance](https://csa-iot.org/) launched camera support in Matter 1.5. This enables device makers to build interoperable camera devices that work across any Matter ecosystem without requiring custom applications or interfaces. The Matter specification uses the widely adopted WebRTC framework to enable this functionality.

Camera enables a variety of related device types in Matter 1.5: 
- Video Doorbell – A camera and a generic switch to provide a doorbell with video and audio streaming
- Audio Doorbell - A camera that is paired with a generic switch for audio streaming
- Floodlight - A camera and light primarily used in security use cases
- Snapshot camera - Support retrieving still images on-demand
- Intercom - Provides two-way on demand communication facilities between devices
- Chime - Play a range of pre-installed sounds, usually paired with a doorbell. This is not directly a camera device type, but can be integrated with it.

Matter camera support delivers the following advantages:
- For remote viewing of the feed, Matter provides the ability for the controllers (or ecosystems) to configure the STUN/TURN servers on the cameras. This is a major benefit for the camera device manufacturers, who won't explicitly need to manage NAT traversal on their own.
- Allows the use of Secure Frame (SFrame) to enable end-to-end encrypted live camera streaming in complex, multi-device ecosystems where streams may be forwarded to multiple users.
- Supports recorded media upload using the standard Common Media Application Format (CMAF), with optional encryption.
- Includes a two dimensional cartesian zone feature to define the areas for privacy masking or motion detection in the video stream. It also facilitates the digital Pan-Tilt-Zoom (PTZ) feature through which the camera can cover multiple zones


## Technical Overview
The following diagram showcases the high-level architecture of Matter cameras: 

{{< figure
    default=true
    src="img/matter-camera-architecture.webp"
    alt=""
    caption="Matter Camera Architecture"
    >}}

### Detailed Workflow
A Matter enabled controller (like a phone app) commissions the camera device into the Matter fabric. Thereafter, when an user requests a video stream, the process begins with the Camera AV Stream Management cluster. It validates the request, checks for compatible stream configurations, and ensures that sufficient resources are available by querying the underlying camera device hardware.

Then the Matter controller initiates a WebRTC session by sending Session Description Protocol (SDP) offer to the camera device using the WebRTC Transport Provider and Requestor clusters. It creates a new WebRTC transport, sets the remote description with the offer, and requests allocation of the necessary audio and video streams.

Once the streams are successfully allocated, the camera device generates SDP answer and sends it back to the controller. Next, the controller provides Interactive Connectivity Establishment (ICE) candidates to establish network connectivity. The camera device adds these remote candidates to the transport, gathers candidates, and delivers them back to the client. Once ICE negotiation completes, the WebRTC session is established and the P2P live audio/video streaming begins.

### Camera - Data Model
The camera capabilities are built on top of the following clusters in Matter - 
- **Camera AV Stream Management** - This cluster provides the standardized interface for managing, controlling, and configuring audio, video, and snapshot streams on a camera device. It defines attributes and commands to negotiate stream resources (such as video/audio codecs, resolutions, and multiple concurrent stream usages like live view, recording, or analytics), allocate and release stream sessions, and coordinate priorities between them. 
- **Camera AV Settings User Level Management** - This cluster defines user-level attributes and commands for controlling a camera’s audio and video settings, including resolution, frame rate, bitrate, and PTZ (Pan-Tilt-Zoom) related parameters. It provides a standardized interface for reading and updating camera capture and streaming behavior. 
- **Push AV Stream Transport** - This cluster defines standardized mechanisms for cameras to push audio/video stream data to a remote transport endpoint (such as a cloud ingest server or recorder) in response to triggers or events. It can allocate, configure, modify, and deallocate stream transport connections, manage transport options (like trigger conditions and metadata), and report transport status and events back to a controller. This enables event‑driven media uploads (e.g., motion‑activated clip delivery) 
- **WebRTC Transport Provider** - This cluster defines the interface that a camera device uses to provide WebRTC‑based transport endpoints for real‑time audio and video streams. It includes commands and attributes for negotiating WebRTC sessions, exchanging SDP offers/answers, handling ICE candidates and connection state, and managing secure, low‑latency media transport using established WebRTC mechanisms. By leveraging mature WebRTC technologies for NAT traversal and media negotiation. 
- **Zone Management** - This Matter cluster provides a standardized way for devices (such as cameras and sensors) to define and manage logical zones—distinct regions of interest within a device’s field of view or coverage area. It defines attributes and commands to create, modify, and query zone configurations, including shape, size, and behavioral associations (e.g., motion detection or privacy masking). By standardizing zone definitions and interactions, this cluster enables controllers to consistently understand and control region‑based behavior. 

## Espressif Matter Camera

While most cameras run Linux-based systems, our ESP32-P4 based MCU camera is first of its kind. It offers significant advantages over traditional Linux-based camera solutions, making it a smarter choice for both device makers and end users.

* **Battery-Powered Operation**: We use a split-mode WebRTC architecture that splits the streaming and signaling parts across two SoCs.The streaming is directly handled by the ESP32-P4, while the signaling is handled by the ESP32-C5/C6.This enables true battery-powered camera implementations. The ESP32-P4 can operate in Deep-sleep mode when not actively streaming, consuming minimal power, while the ESP32-C5/C6 maintains Wi-Fi connectivity in Light-sleep mode. This power-efficient design allows cameras to run on battery power for extended periods. The ESP32-P4 only wakes up when streaming is actively requested, drastically reducing overall power consumption.

* **Enhanced Security**: MCU-based cameras offer a significantly smaller attack surface compared to Linux-based systems. Without a full operating system, complex package managers, or numerous running services, the potential attack vectors are substantially reduced. This minimalist approach means fewer vulnerabilities and a more secure device overall.

* **Cost-Effective Design**: MCU-based solutions eliminate the need for expensive application processors, large memory modules, and complex power management systems required by Linux-based cameras. This enables device manufacturers to offer competitive pricing while maintaining high-quality video streaming capabilities.

* **Faster Boot Times**: MCU-based systems boot in milliseconds rather than seconds, enabling near-instantaneous camera activation and reducing the delay between power-on and first video frame capture.

The [Espressif Matter Camera](https://github.com/espressif/esp-matter/tree/main/examples/camera) is built on top of the [Matter SDK](https://github.com/project-chip/connectedhomeip) and provides a complete implementation of the Camera device type.

### Hardware Architecture

* **ESP32-P4**: The [ESP32-P4](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32p4/esp32-p4-function-ev-board/user_guide_v1.4.html) is a powerful dual-core SoC by Espressif Systems. It provides MIPI-CSI support for camera capture and the hardware H.264 encoder for real-time 1080p @30fps. This SoC interfaces directly with the camera sensor, microphone, and speaker peripherals.
* **ESP32-C5/ESP32-C6**: The ESP32-C5 or ESP32-C6 provide Wi-Fi connectivity to the cameras, with the ESP32-C5 supporting dual-band (2.4 GHz and 5 GHz) and the ESP32-C6 supporting 2.4 GHz. The Matter application runs on this SoC.


{{< figure
    default=true
    src="img/hardware-overview.webp"
    alt=""
    caption="Hardware Overview"
    >}}

### Current Features
- Full HD (1920x1080) video capture at 1080p @30fps, with built-in H.264 hardware encoding
- Real-time audio and video streaming using WebRTC
- Two-way talk support
- Low power cameras that enable battery powered design through the split mode architecture
- Multiple simultaneous video streams support 

### Try It Out

* **Hardware Setup:**
   - [ESP32-P4 Function EV development board](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32p4/esp32-p4-function-ev-board/user_guide_v1.4.html) with MIPI-CSI camera support
   - Camera module compatible with ESP32-P4 (MIPI-CSI interface)
   - Matter-enabled phone app or [host-based Matter camera controller](https://github.com/project-chip/connectedhomeip/tree/master/examples/camera-controller)

* **Software Setup:**
   - Follow the steps in the [Camera example](https://github.com/espressif/esp-matter/tree/main/examples/camera) to build, flash, and test.

### Upcoming Features
- **Snapshot Capture**: JPEG snapshot functionality for on-demand image capture
- **Security**: Record and upload media using CMAF along with the encryption
- **Privacy**: Cartesian zone and PTZ support

As Matter 1.5 continues to gain adoption across the smart home ecosystem, MCU-based cameras powered by Espressif SoCs will play a crucial role in bringing interoperable, secure, and affordable camera solutions to market, shaping the future of connected camera devices.
