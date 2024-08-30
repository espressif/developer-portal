---
title: Announcing AWS IoT Reference Example for ESP32-C3
date: 2022-05-11
showAuthor: false
authors: 
  - dhaval-gujar
---
[Dhaval Gujar](https://medium.com/@dhavalgujar?source=post_page-----6587daf735d0--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fdcb6fdff94e2&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fannouncing-aws-iot-reference-example-for-esp32-c3-6587daf735d0&user=Dhaval+Gujar&userId=dcb6fdff94e2&source=post_page-dcb6fdff94e2----6587daf735d0---------------------post_header-----------)

--

We had [announced](/support-for-lts-release-of-aws-iot-device-sdk-for-embedded-c-on-esp32-8eeeea28b79b) the availability of AWS IoT LTS libraries for ESP32 in beta in esp-aws-iot repository in August, 2021. Since then, many of our customers and independent developers have been using these libraries that we have ported and writing applications based on the examples.

This beta release of the AWS LTS libraries provided individual examples showcasing usage of a particular AWS IoT related service. It had the following structure:

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*W4v2537dYzP6qC12kFhQIg.png)

We are pleased to announce the [stable release](https://github.com/espressif/esp-aws-iot/) of esp-aws-iot on GitHub and a [reference example](https://github.com/FreeRTOS/iot-reference-esp32c3) for the ESP32-C3 developed [in collaboration](https://www.freertos.org/featured-freertos-iot-integration-targeting-an-espressif-esp32-c3-risc-v-mcu/) with the AWS team. The combination of these repositories provides a production-ready starting point for making applications that connect to AWS IoT Core using esp-aws-iot.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*20XGbIWofbzCTdmFILVVzg.png)

The main features of this release are listed below:

## 1. Closer to Production Example

While the standalone examples provided a clear path to use a particular LTS library, it was challenging to build a production application based only on the standalone examples. To address this, we have now made available a reference example for the ESP32-C3 that provides a better starting point. The reference example is built from the ground up to provide a reliable application that can handle and recover from real world cases like MQTT-level disconnections or Wi-Fi disconnections.

It also comes baked in with Espressif’s [Unified Provisioning](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-reference/provisioning/provisioning.html) that allows you to use our phone apps (available in open source format for [Android](https://github.com/espressif/esp-idf-provisioning-android) and [iOS](https://github.com/espressif/esp-idf-provisioning-ios) and on the [Google Play Store](https://play.google.com/store/apps/details?id=com.espressif.provble) and [Apple App Store](https://apps.apple.com/app/esp-ble-provisioning/id1473590141)) for providing the Wi-Fi credentials to the device and can be easily extended to send additional information.

A major goal while designing the reference example, was to allow extensibility and cover a vast majority of real-world scenarios and considerations.

## 2. Security Best Practices

One of the important highlights of the reference example is that it is designed with security best practices in mind and provides a [comprehensive guide](https://github.com/FreeRTOS/iot-reference-esp32c3/blob/main/UseSecurityFeatures.md) for following them in production use-cases.

It makes use of the [Digital Signature Peripheral](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-reference/peripherals/ds.html) on the ESP32-C3, which provides a hardware root-of-trust and secure storage for certificates. This ensures that the device identity remains protected using hardware security.

Additionally, the guide provides steps for production security considerations like enabling [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/security/flash-encryption.html) and [Secure Boot](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/security/secure-boot-v2.html) which are now de-facto features in any secure connected device.

## 3. Combination of AWS Libraries and Features

Most of the real world scenarios use not one, but a combination of the AWS LTS libraries. To facilitate these use-cases, the reference example integrates various libraries, like coreMQTT, coreJSON and AWS OTA.

The reference example has three integrated functionalities:1. __*ota_over_mqtt_demo*__ : This demo uses the AWS IoT OTA service for FreeRTOS to configure and create OTA updates.2. __*sub_pub_unsub_demo*__ : The demo creates tasks which subscribe to a topic on AWS IoT Core, publish a constant string to the same topic, receive their publish, and then unsubscribes from the topic in a loop.3. __*temp_sub_pub_and_led_control_demo*__ : This demo creates a task which subscribes to a topic on AWS IoT Core. This task then reads the temperature from the onboard temperature sensor, publishes this information in JSON format to the same topic, and then receives this publish in a loop. This demo also enables a user to send a JSON packet back to the device to turn an LED off or on.

It is simple to extend the reference example, by adding your own application logic or modifying one of the existing ones to suit your needs.

## 4. Libraries as Individual IDF Components

As a side-effect of the restructuring of esp-aws-iot SDK in this context, we now provide ability to use each AWS LTS library as a standalone ESP-IDF component that can easily be added to any example. Each library comes with its own port layer and configuration that is easy to manage for the application.

## Getting Started

esp-aws-iot is currently supported to work on ESP-IDF [v4.3](https://github.com/espressif/esp-idf/tree/release/v4.3) and [v4.4](https://github.com/espressif/esp-idf/tree/release/v4.4) release branches, you can find the steps to install and setup ESP-IDF [here](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/get-started/index.html).You can find the stable release of esp-aws-iot [here](https://github.com/espressif/esp-aws-iot/) and the Getting Started Guide for the reference example for the ESP32-C3 [here](https://github.com/FreeRTOS/iot-reference-esp32c3/blob/main/GettingStartedGuide.md).

We hope that the stable release of the esp-aws-iot repo together with the reference example simplifies and speeds up the development of your applications that connect to AWS IoT Core.

We will make the reference example available for other SoCs shortly.

If you run into any problems, you can file an issue on the respective repos.
