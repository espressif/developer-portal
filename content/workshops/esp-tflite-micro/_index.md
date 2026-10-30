---
title: "ESP-TFLite-Micro workshop"
date: 2026-11-03
draft: false
tags: ["Workshop", "ESP-IDF", "ESP-TFLite-Micro", "TensorFlow Lite Micro", "Edge AI", "ESP32-C5", "ESP-SensairShuttle", "Bosch Sensortec"]
summary: "A hands-on workshop for building an on-device gesture recognition application with ESP-TFLite-Micro, the ESP-SensairShuttle, and its BMI270 IMU."
---

Welcome to the ESP-TFLite-Micro workshop!

## About this workshop

This hands-on workshop covers the complete workflow for running machine learning directly on a microcontroller, with no network connection or cloud service involved. You will repeatedly move a development board by hand to record a gesture of your choice, turn those recordings into a labeled dataset, and train a small neural network on your computer to tell your gesture apart from other movements. You will then compress the model so that it fits in the limited memory of the microcontroller, embed it in the firmware, and measure how reliably the board recognizes the gesture as you perform it.

This workflow is implemented in the [ESP-SensairShuttle gesture recognition example](https://github.com/espressif/esp-dev-kits/tree/master/examples/esp-sensairshuttle/examples/gesture_recognition), which the workshop uses as its starting point. Specifically, you will collect motion data from the BMI270 IMU on the ESP-SensairShuttle, train a lightweight gesture classification model, convert it to TensorFlow Lite format, and run inference on the ESP32-C5 with ESP-TFLite-Micro.

By the end of the workshop, you will be able to:

- Capture and label time-series IMU data
- Prepare a dataset for gesture classification
- Train and evaluate a compact 1D convolutional neural network with Keras
- Convert the trained Keras model to TensorFlow Lite
- Embed a model in an ESP-IDF application
- Run and validate on-device inference with ESP-TFLite-Micro

## Prerequisites

Required hardware:

- Computer running Linux, Windows, or macOS
- [ESP-SensairShuttle](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c5/esp-sensairshuttle/index.html)
- USB cable that supports power and data

Required software:

- ESP-IDF v6.1
- Python 3.12 with TensorFlow, pandas, NumPy, matplotlib, and scikit-learn
- Git
- A serial terminal

## Agenda

- [Machine learning on microcontrollers](introduction/): Learn how TensorFlow Lite Micro, ESP-TFLite-Micro, and ESP-NN run machine-learning models on Espressif SoCs.
- [Hardware: The ESP32-C5 and ESP-SensairShuttle](hardware/): Get familiar with the processor, development board, and connections used in the workshop.
- [Bosch Sensortec sensors](bosch-sensors/): Explore the BMI270, BMM350, and BME690 sensors supported by the board.
- [Install ESP-IDF](setup/): Install and activate ESP-IDF v6.1 with the ESP-IDF Installation Manager.
- [Download and flash the gesture recognition example](gesture-example/): Build the reference application for ESP32-C5, flash it, and verify BMI270 inference.
- [Assignment 1: Collect and prepare gesture data](assignment-1/): Capture BMI270 gyroscope samples and prepare the training dataset.
- [Assignment 2: Train and evaluate the model](assignment-2/): Build a compact 1D CNN and evaluate its classification accuracy.
- [Assignment 3: Convert and embed the model](assignment-3/): Convert the trained model to TensorFlow Lite and then to a C++ array.
- [Assignment 4: Deploy and test on-device inference](assignment-4/): Integrate ESP-TFLite-Micro, run gesture inference, and validate the result on the board.

## Time requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 180 min**
{{< /alert >}}

## Workshop resources

- [Workshop gesture recognition project](https://github.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-tflite-micro/gesture_recognition): Maintained ESP-IDF firmware, pretrained model, and training workspace used throughout the workshop.
- [Training scripts](https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/training.zip): Downloadable scripts for data capture, validation, model training, conversion, and embedding.
- [Upstream ESP-SensairShuttle gesture recognition example](https://github.com/espressif/esp-dev-kits/tree/master/examples/esp-sensairshuttle/examples/gesture_recognition): Original example on which the workshop project is based.
- [Gesture Recognition Based on TFLite](/blog/2026/04/gesture-recognition-based-on-tflite/): Additional background on the end-to-end workflow.

## Feedback

If you have any feedback about the workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).

## Next step

[Introduction: Machine learning on microcontrollers](introduction/)
