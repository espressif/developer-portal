---
title: "Base on ESP32-C2 and ESP-Rainmaker DIY a Smart Electric Toothbrush"
date: 2024-08-22T17:00:17+08:00
showAuthor: false
authors:
  - "raffael-rostagno"
tags: ["ESP32-C2", "SPI", "LCD", "ESP-Rainmaker", "Toothbrush"]
---


## Introduction

Open the first step with a smart teeth cleaning from a thoughtful and creative idea. Our goal is not only to make a smart toothbrush, but also to create an oral health companion that combines innovative technology with deep human care. We believe that through careful design and constant technological innovation, we can bring more comfortable and personalized dental cleaning experience to your life.

### Overview of ESP-Toothbrush

ESP-Toothbrush is an smart electric toothbrush which driver by the ESP32-C2 chip from Espressif. It integrates a 0.96 inch LCD display with SPI interface to display informations such as battery level, networking status, brushing time and brushing status. The ESP-Toothbrush have only one button to drive the ultrasonic motor of the toothbrush head and a buzzer to play the prompt tone. In addition, the ESP-Toothbrush supports connect to WiFi and access to ESP-RainMaker, which allows to view detailed brushing data and configure the toothbrush through the ESP-RainMaker APP on the phone. Finally, it supports the use of USB Type-C for firmware flashing and charging, as well as charging via a magnetic stylus.


### ESP-Toothbrush Hardware Framework

For this project, we have developed a clear hardware framework, which is as follows:

![ESP-Toothbrush Hardware Framework](./img/esp-toothbrush-hardware-framework.webp.webp "ESP-Toothbrush Hardware Framework")


## ESP-Toothbrush Hareware Design

In order to translate our ideas into reality, for each functional module of the smart toothbrush, we need to design the hardware schematic. This process is critical, we need to plan the layout of each circuit carefully and the selection of electronic components to ensure the reliability and optimal performance of the circuit, laying the foundation for the final assembly and testing.

![ESP-Toothbrush Hareware Design](./img/esp-toothbrush-hareware-design.webp "ESP-Toothbrush Hareware Design")

## ESP-Toothbrush PCB Layout

After designing the hardware, we pay attention to the placement of each part, to ensure that they work well,  but also to ensure that the entire device is small. We carefully adjusted to get every part just right,  without compromising performance or increase unnecessary PCB size.

![ESP-Toothbrush PCB Layout](./img/esp-toothbrush-pcb-layrat.webp "ESP-Toothbrush PCB Layout")

![ESP-Toothbrush PCB Front](./img/esp-toothbrush-pcb-front.webp "ESP-Toothbrush PCB Front")

![ESP-Toothbrush PCB Back](./img/esp-toothbrush-pcb-back.webp "ESP-Toothbrush PCB Back")


