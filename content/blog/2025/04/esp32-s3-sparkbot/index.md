---
title: "ESP-SparkBot：Large Language Model Robot with ESP32-S3"
date: 2025-04-23
showAuthor: false
featuredAsset: "ESP-SparkBot-featured.webp"
authors:
  - "cai-guanhong"
tags: ["ESP32-S3", "ESP-NOW", "Offline Speech Recognition", "Face Recognition", "Motion Detection", "USB Screen Mirror"]
---
> This article provides an overview of the ESP-SparkBot, its features, and functionality.It also details the hardware design and outlines the software framework that supports its operation.

## Introduction

With the booming development of generative artificial intelligence, large language models (LLMs) are becoming a core technology in the AI field. They are not only driving the realization of application scenarios such as AI programming, intelligent customer service, and smart office, but also enriching interactive experiences and service quality in areas such as smart homes, remote healthcare, online education, and personalized entertainment. However, these technologies typically rely on powerful cloud computing resources, and extending them to edge devices requires overcoming numerous challenges such as computing power, latency, and power consumption. Espressif Systems with its leading wireless SoC technology, provides a solution to this challenge and is committed to bringing the powerful capabilities of AI to a wider range of edge devices, making AI technology more accessible and serving people’s daily lives.

In this article, we introduce the ESP-Sparkbot AI Robot—a versatile solution designed to meet a range of needs. Whether you're looking to create a smart home system, enhance your experience with a reliable voice assistant, or find an engaging AI toy for your children, the ESP-Sparkbot has you covered.


## Overview of ESP-SparkBot

ESP-SparkBot is a low-cost, multi-functional,  AI large language model robot with ESP32-S3. It is an intelligent device integrating voice interaction, facial recognition, remote control, motion detection, and multimedia functions.

- In home automation, ESP-SparkBot can be your personal assistant.
- In smart office scenarios, ESP-SparkBot act as your computer's secondary screen.
- In outdoor entertainment settings, the ESP-SparkBot can seamlessly transform into a compact speaker and portable camera.

In this video you can see the functions and application scenario of ESP-SparkBot.

{{<youtubeLite id="meZDJf8QTdM" label="ESP-Demo: Large Language Model Robot with ESP32-S3">}}


The ESP-ESP-SparkBot can be powered in two ways:

- **Button Battery (Default Power Supply):**
The ESP-SparkBot is equipped with a 2000mA lithium battery, supporting power supply via the lithium battery and charging of the lithium battery via its base.

- **USB Power Supply (via ESP32-S3 USB Interface):**
The ESP-SparkBot also features a USB Type-C port, enabling continuous power supply via USB, which simplifies program downloading and debugging. This added functionality expands usage scenarios and enhances overall convenience for users.


## Key Features and Capabilities

This section highlights the ESP-SparkBot's key functionalities and the innovative features that make it a versatile AI Conversation Robot for smart device control and integration.

### Smart Voice Weather Assistant & Time Manager

The ESP-SparkBot serves as a smart voice assistant, offering real-time access to local data such as the current date, time, weather conditions, temperature fluctuations, and air quality via IP address. This makes the ESP-SparkBot not only your personal assistant but also an essential smart companion, delivering timely and valuable weather and time information whenever you need it.



<!-- <video controls width="640" height="480">  <source src="./img/clock-weather-assistant.webm" type="video/webm"> -->

{{< youtubeLite id="meZDJf8QTdM" label="Smart Voice Assistant" params="start=23&end=29&controls=0" >}}


### Large Language model AI Chat Assistant Robot

The ESP-SparkBot utilizes the OpenAI platform and integrates the advanced ChatGPT model to support seamless online voice interaction. This transforms the ESP-SparkBot into not just a smart home assistant, but also an intelligent conversational partner, enabling users to engage in natural language communication and effortlessly retrieve information, thus enhancing both interactivity and convenience in the smart home experience.

<!-- <video controls width="640" height="480">  <source src="./img/chat-with-openAI.webm" type="video/webm"> -->

{{< youtubeLite id="meZDJf8QTdM" label="AI Chat Assistant Robot" params="start=46&end=85&controls=0" >}}


### Relaxation Game

ESP-SparkBot is equipped with a touch button on top, allowing users tap a virtual zen drum and accumulate merit. With the ESP-NOW broadcast function, multiple ESP-SparkBots can be controlled simultaneously to tap the virtual zen drums, exponentially increasing the accumulated merit.  

<!-- <video controls width="640" height="480">  <source src="./img/esp-now.webm" type="video/webm"> -->

{{< youtubeLite id="meZDJf8QTdM" label="Relaxation Game" params="start=86&end=111&controls=0" >}}


### Virtual 3D Die

The ESP-SparkBot also features a built-in accelerometer, enabling it to function as a virtual die. By randomly rotating or shaking ESP-SparkBot, the 3D die displayed on the screen will rotate according to the accelerometer data. Once the movement stops, the on-screen die will gradually come to a halt and display the final result.

<!-- <video controls width="640" height="480">  <source src="./img/cyber-dice.webm" type="video/webm"> -->

{{< youtubeLite id="meZDJf8QTdM" label="Virtual 3D Die" params="start=111&end=116&controls=0" >}}


### 2048 Game

ESP-SparkBot comes integrated with the 2048 game. After entering the 2048 game interface, users can interact with the game through gesture recognition enabled by the built-in accelerometer. Tapping the touch button on top will reset the game.


<!-- <video controls width="640" height="480">  <source src="./img/2048-game.webm" type="video/webm"> -->

{{< youtubeLite id="meZDJf8QTdM" label="2048 Game" params="start=116&end=129&controls=0" >}}


### Offline speech recognition, face recognition and motion detection

In addition to online interactions with cloud-based large models, ESP-SparkBot also supports running various offline AI models locally, such as offline speech recognition, face recognition, and motion detection.

- __Speech Recognition__
By leveraging the [ESP-SR](https://gitee.com/link?target=https://github.com/espressif/esp-sr) library, ESP-SparkBot can perform local speech recognition with ease.

- __Face recognition__ and __motion detection__
The ESP-SparkBot features a foldable camera on top, enabling real-time facial detection and recognition. Users can easily add or remove faces through voice commands. With the [ESP-WHO](https://gitee.com/link?target=https://github.com/espressif/esp-who) library, integrating additional vision AI models is simple, including capabilities such as cat face recognition, human face recognition, motion detection, and pedestrian detection.


<!-- <video controls width="640" height="480">  <source src="./img/speech-face-recognition-motion-detection.webm" type="video/webm"> -->

{{< youtubeLite id="meZDJf8QTdM" label="Offline Speech Recognition & Face Recognition & Motion Detection" params="start=130&end=188&controls=0" >}}


### Remote Controlled Reconnaissance Robot

The ESP-SparkBot can function as a wireless, remote-controlled reconnaissance robot, responding to voice commands to control its movement direction and light displays. Additionally, users can issue voice commands to capture photos while the robot is in motion.

<!-- <video controls width="640" height="480">  <source src="./img/moving-car.webm" type="video/webm"> -->

{{< youtubeLite id="meZDJf8QTdM" label="Remote Controlled Reconnaissance Robot" params="start=213&end=229&controls=0" >}}


By connecting to the robot's WebSocket server, users can achieve two-way interaction with mobile remote control and real-time video streaming. No dedicated app installation is required—users can simply access the remote control interface via a web browser, featuring a simulated joystick design for smooth and intuitive operation.

<!-- <video controls width="640" height="480">  <source src="./img/remote-control-car.webm" type="video/webm"> -->

{{< youtubeLite id="meZDJf8QTdM" label="Robot's WebSocket Server" params="start=231&end=291&controls=0" >}}


### USB Screen Mirror

With just a single USB cable, the ESP-SparkBot transforms into a plug-and-play USB secondary display. It supports bi-directional audio transmission and touch control, enabling it to function as both a speaker and a microphone. In addition to providing smooth video streaming for TV shows, it offers an immersive experience for gaming, including esports and AAA titles. 



<!-- <video controls width="640" height="480">  <source src="./img/usb-screen-mirror.webm" type="video/webm"> -->

{{< youtubeLite id="meZDJf8QTdM" label="USB Screen Mirror" params="start=294&end=3301&controls=0" >}}

## Hardware Design

The hardware system of the ESP-SparkBot is composed as follows:


{{< figure
default=true
src="img/sparkbot-hardware.webp"
height=500
caption="ESP-SparkBot Hardware Design"
    >}}


### Description of Different Circuit Blocks

- **Main MCU**: [ESP32-S3-WROOM-1-N16R8](https://www.espressif.com/sites/default/files/documentation/esp32-s3-wroom-1_wroom-1u_datasheet_en.pdf) module，responsible for controlling the entire system. In includes both connectivity (Wi-Fi and Bluetooth) and peripherals (LCD, camera and audio).

- **Camera**: Uses a DVP interface camera, whose model is [OV2640](https://www.waveshare.com/w/upload/9/92/Ov2640_ds_1.8_.pdf). It is used for capture images and transmit video streams.

- **Audio**: An audio module is used for both microphone input and speaker output. It transmits digital audio data via the I2S interface and drives the speaker to play audio signals through an audio amplifier circuit.

- **LCD (Display)**: 1.54-inch with 240x240 pixel resolution. This LCD is equipped with the ST7789 controller. 

- **USB Type-C (USB-C Interface)**: Supports USB Type-C connection for device power supply and data transmission. Support USB serial communication for debugging and flashing firmware.

- **DC-DC Converter** : Responsible for converting the input voltage to the stable voltage required by the ESP32-S3 and other modules.

- **Connector Pins (External Connectors)**: Connection interfaces for external devices, facilitating interconnection with other modules or development boards. Can be used for expanding functionality and debugging.

- **Touch (Touch Circuit)**: Touch sensing circuit for detecting user touch operations. 

- **Microphone Module**: Microphone signal biasing network. 

- **Power Switching Circuit**: Responsible for switching between different power inputs (such as battery and USB). Ensures stable operation of the device under multiple power supply methods.

- **Lithium Battery Charging Circuit**: Manages the charging process of the lithium battery, supporting battery overcharge protection and constant current/constant voltage charging. Provides a portable power solution for the device.

- **IMU (BMI270) (Inertial Measurement Unit)**: Used for detect the acceleration and angular velocity. It realizes motion detection, attitude detection and gesture recognition functions.

- **Button**: Detects button input for user interaction, enabling function switching or mode selection.

Complete open-source hardware resources are available at [ESP-SparkBot](https://oshwlab.com/hawaii0707/esp-sparkbot). For more ESP hardware design instructions, please refer to the [ESP Hardware Design Guidelines](https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32s3/index.html#esp-hardware-design-guidelines)


## Software Design

The software code for the ESP-SparkBot AI robot is fully open-source and available at [esp-friends/esp_sparkbot](https://gitee.com/esp-friends/esp_sparkbot). This repository includes a series of sample projects designed to showcase the full capabilities of the ESP-SparkBot. For more details, see: [ESP-SparkBot examples](https://gitee.com/esp-friends/esp_sparkbot/tree/master/example).

## Conclusion

The ESP-SparkBot is a versatile AI-powered robot offering voice interaction, facial recognition, motion detection, and multimedia features for smart home, office, and entertainment use. With both its hardware and software being open-source, and welcoming contributions from the community, it makes advanced AI accessible and practical for everyday applications, enhancing both personal and professional experiences.
