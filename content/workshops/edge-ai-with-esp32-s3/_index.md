---
title: "Edge-AI with ESP32-S3 Workshop: Vision"
date: 2026-07-07
tags: ["Workshop", "ESP-IDF", "ESP32-S3", "AI", "ESP-WHO", "ESP-DL", "computer vision"]
summary: "Learn how to build edge AI vision applications on the ESP32-S3-EYE using ESP-WHO and ESP-DL. This hands-on workshop covers face detection, face recognition, hand gesture recognition, and object detection with real-time inference on the device."
showTableOfContents: true
---

Welcome to the Edge AI with ESP32-S3 workshop on computer vision!

## About this workshop

In this workshop, you will build real edge AI vision applications on the ESP32-S3-EYE using ESP-WHO and ESP-DL — Espressif's frameworks for camera-based AI on embedded devices. All inference runs directly on the chip, with no cloud dependency.

You will start with the complete ESP-WHO framework to run face detection and face recognition out of the box, then move on to using ESP-DL -- the framework on which ESP-WHO is built -- for hand gesture recognition and YOLO11-based object detection. Along the way, you will also learn how to capture raw camera frames without ESP-WHO, giving you the flexibility to build fully custom inference pipelines.

By the end of the workshop, you will know how to:

- Set up a complete edge AI development environment with ESP-IDF and ESP-WHO
- Run face detection and face recognition using the ESP-WHO camera pipeline
- Capture raw frames from the OV2640 sensor for use in custom applications
- Load and run models from the ESP-DL model zoo directly, without ESP-WHO
- Perform hand gesture recognition and YOLO11 object detection with ESP-DL
- Understand how to quantize and deploy a custom model using ESP-PPQ
- Explore the full ESP-DL model zoo and the ESP-Vision rapid prototyping platform

## Agenda

If you have met the [prerequisites](#prerequisites), we can start with the individual chapters:

- [Introduction to Edge-AI Vision](introduction)
- [Assignment 1: Install ESP-IDF and ESP-WHO](assignment-1)
- [Assignment 2: ESP-WHO - Working with face detection](assignment-2)
- [Assignment 3: Face recognition with ESP-WHO](assignment-3)
- [Assignment 4: Raw Camera Frames for Custom Applications](assignment-4)
- [Assignment 5: Hand gesture recognition with ESP-DL](assignment-5)
- [Assignment 6: Object detection with YOLO11](assignment-6)
- [Assignment 7: Going further](assignment-7)

## Prerequisites

To follow this workshop, you will need both hardware and software equipment.

Required hardware:

- Computer running Linux, Windows, or macOS
- [ESP32-S3-EYE](https://github.com/espressif/esp-who/blob/master/docs/en/get-started/ESP32-S3-EYE_Getting_Started_Guide.md) development kit
- USB cable (supporting power + data) compatible with the devkit above

Required software:

- ESP-IDF v5.5.4 (compatible with ESP-WHO) — installed via EIM (see Assignment 1)

Optional software:

- [Visual Studio Code](https://code.visualstudio.com/download) with the [ESP-IDF extension](https://github.com/espressif/vscode-esp-idf-extension?tab=readme-ov-file#how-to-use) — all workshop steps are CLI-based, but the extension can be used as an alternative

## Time Requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 180 min**
{{< /alert >}}

## Next step

[Introduction to Edge-AI Vision](introduction)

## Feedback

If you have any feedback about this workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).

## Conclusion

We hope that this workshop gives you a solid foundation for building your own edge AI vision applications. Thank you for the time and effort you devoted to it, and we look forward to seeing what you create with Espressif chips!