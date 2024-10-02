---
title: "Presenting the Advantages of ESP32-S3-BOX, Espressif’s AI Voice Development
  Kit"
date: 2021-11-22
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - amey-inamdar
tags:
  - Sign up
  - Sign in
  - Sign up
  - Sign in
  - Follow
  - ''
  - ''
  - Esp32 S3
  - Espressif
  - Ai Voice Assistant
  - IoT
  - ''
  - ''
  - ''
  - Follow
  - ''
  - Follow
  - ''

---
{{< figure
    default=true
    src="img/presenting-1.webp"
    >}}

Espressif Systems has recently released an AI voice development kit dubbed ESP32-S3-BOX, based on ESP32-S3 Wi-Fi + Bluetooth 5 (LE) SoC. It provides a platform for developing the control of smart devices with offline and online voice assistants. ESP32-S3-BOX is ideal for developing AIoT applications with reconfigurable AI voice functions, such as smart speakers, and IoT devices that achieve human-computer voice interaction directly. Not only does ESP32-S3-BOX address connectivity use cases, but it also targets various machine-learning (AI on the edge) and HMI application scenarios. ESP32-S3-BOX comes in an attractive form-factor that differentiates it from regular PCB development boards, since users can quickly build with it applications that are fairly close to actual end products. Furthermore, ESP32-S3-BOX functions as a versatile and extensible development kit that facilitates a multitude of interesting use-cases, the most characteristic of which we will examine in this blogpost.

{{< figure
    default=true
    src="img/presenting-2.webp"
    >}}

First, let’s take a look at the ESP32-S3-BOX specifications. In general, ESP32-S3-BOX is a compact, extensible kit with many features of a finished product. It is equipped with a 2.4-inch display (with a 320 x 240 resolution) integrated with a capacitive touch panel, a Type-C USB interface that supports 5 V of power input and serial/JTAG debugging, and two [Pmod](https://digilent.com/reference/pmod/start)™-compatible headers for connecting peripheral modules that expand the functionality of the original board. The two Pmod™ headers offer 16 programmable GPIOs that are able to provide 3.3 V of power supply to peripherals.

At the core of ESP32-S3-BOX is [ESP32-S3](https://www.espressif.com/en/products/socs/esp32-s3), a Wi-Fi (802.11b/g/n) + Bluetooth 5 (LE) SoC which has a 240 MHz Xtensa® 32-bit LX7 dual-core processor with powerful AI instruction extensions that enable neural network acceleration, and efficient audio processing. Moreover, ESP32-S3-BOX has 16MB of flash and 8MB of PSRAM, in addition to the internal SRAM of ESP32-S3.

Now, let’s look at some of the most important use cases that are readily supported by ESP32-S3-BOX.

{{< figure
    default=true
    src="img/presenting-3.webp"
    >}}

## Online and Offline Voice Assistant

ESP32-S3-BOX features an online and offline voice assistant which can be used as either a stand-alone voice assistant, or a voice-enablement module that can be integrated into other devices.

For every high-quality voice assistant, a high-performance audio front-end and a wake-word engine are essential. Indeed, ESP32-S3-BOX supports Espressif’s Audio Front-End (AFE) algorithms that take advantage of the AI accelerator available in the ESP32-S3 SoC. Hence, ESP32-S3-BOX achieves a great performance, without requiring an external DSP co-processor. The combination of the AI accelerator and Espressif’s AFE algorithms achieves a 360-degree and far-field 5 m pickup with only two microphones, while ensuring high-quality, stable audio data; it also improves the quality of the target audio source in high-SNR scenarios, thus achieving an excellent performance in voice interaction. On this note, Espressif’s AFE algorithms have been qualified by Amazon as a “Software Audio Front-End” solution for Alexa built-in devices.

Espressif’s [ESP-Skainet](https://github.com/espressif/esp-skainet) SDK provides a reliable offline voice assistant that enables developers to configure up to 200 commands. Espressif’s [Alexa for IoT SDK](https://github.com/espressif/esp-va-sdk) provides an easy way to integrate the Alexa functionality into IoT devices. Both of these assistants are available on ESP32-S3-BOX, thus addressing any developer requirements for offline and online voice assistants. Practical examples of these will be made available shortly.

## HMI Touch Screen

{{< figure
    default=true
    src="img/presenting-4.webp"
    >}}

ESP32-S3-BOX has a 320x240 capacitive touch screen that can be used for HMI applications, such as control panels. ESP32-S3 SoC’s improved PSRAM interface and computing power support a touch screen with a high refresh rate. Espressif has integrated [LVGL](https://github.com/espressif/esp-iot-solution/blob/release/v1.1/documents/hmi_solution/littlevgl/littlevgl_guide_en.md) into its SDK, as a component, thus making it easy for developers to evaluate and port LVGL into their product designs. LVGL is a free and open-source graphics library, providing users with everything they need for creating an embedded GUI in ESP32-S3-BOX, with easy-to-use graphical elements and advanced visual effects, including animations and anti-aliasing.

## Smart Gateways

ESP32-S3-BOX can support several Espressif chip series through its Pmod™ headers, so that developers can easily build a smart gateway and integrate into it various communication protocols. This ensures connectivity for a variety of devices in a seamless way.

{{< figure
    default=true
    src="img/presenting-5.webp"
    >}}

For instance, we can combine ESP32-S3-BOX with the ESP32-H2 module, which supports 802.15.4 (Thread 1.x/ZigBee 3.x) and Bluetooth 5 (LE), to build a Thread Border Router that connects a low-power Thread network to a Wi-Fi network. The router can also work as a Zigbee gateway, allowing users to control Zigbee devices through [Matter](https://buildwithmatter.com), a connectivity protocol for smart home.

{{< figure
    default=true
    src="img/presenting-6.webp"
    >}}

ESP32-S3-BOX can also work as a Wi-Fi/Bluetooth gateway. After it connects to the Internet via a router, it can share its connection with neighbouring devices via hotspots . By connecting to a mobile network module (e.g. LTE, 5G, NB-IoT) through the Pmod™ headers, ESP32-S3-BOX can also be used as a portable Wi-Fi hotspot that provides neighbouring devices with internet access.

{{< figure
    default=true
    src="img/presenting-7.webp"
    >}}

In addition, ESP32-S3-BOX also supports multiple third-party cloud platforms to ensure device interoperability in different ecosystems. With the help of Espressif’s one-stop AIoT could platform, [ESP RainMaker®](https://rainmaker.espressif.com), developers can use phone apps to communicate with ESP32-S3-BOX, configure GPIO pins at will, customize voice commands, and upgrade firmware via OTA. With ESP RainMaker and ESP-S3-BOX, you can convert any offline product into a connected product, just by using the Pmod™ interface. Bridge support in the ESP RainMaker integration also extends ESP-S3-BOX’s capability to control devices easily, with BLE or 802.15.4 radio, via the cloud.

## Extensible Pmod™ Interface

{{< figure
    default=true
    src="img/presenting-8.webp"
    >}}

ESP32-S3-BOX also provides two Pmod™-compatible headers (with 16 programmable GPIOs) that support interfacing with various peripherals for flexibly expanding the functions of the board. Here are a few examples of how to use ESP32-S3-BOX in this way:

- Connect to a Micro SD card to make ESP32-S3-BOX work as a multimedia player that can store images and audio files.
- Connect to an infrared sensor to make ESP32-S3-BOX simulate a voice-enabled, infrared, remote control for an air conditioner, TV set, projector or other equipment, with offline voice commands.
- Connect to a temperature and humidity sensor or PM2.5 sensor to make ESP32-S3-BOX work as an air-quality detector that supports voice control, and displays sensor data on a screen.
- Connect to an RGB LED module to build with ESP32-S3-BOX a smart-lighting solution that supports offline voice control.
- Connect to a USB OTG module to achieve various USB applications involving a camera, 4G networking, a Wi-Fi USB disk, a USB touchpad, etc.
- Connect to a camera module to make ESP32-S3-BOX support face detection and recognition

## Additional Resources

Espressif provides developers with full access to its open-source technical resources, i.e. the ESP32-S3-BOX [hardware reference design and user guide](https://github.com/espressif/esp-box), [LVGL guide](https://github.com/espressif/esp-iot-solution/blob/release/v1.1/documents/hmi_solution/littlevgl/littlevgl_guide_en.md), [ESP-SR speech-recognition model library](https://github.com/espressif/esp-sr/tree/66e21f6cc384d6b4aec077c187ebb0f5fbb4c5ff) (including the wake-work detection model, speech-command recognition model, and acoustic algorithms), as well as [ESP-DL deep-learning library](https://github.com/espressif/esp-dl/blob/master/README.md) that provides APIs for Neural Network (NN) Inference, Image Processing, Math Operations and some Deep Learning Models. Furthermore, [Espressif’s IoT Development Framework (ESP-IDF)](https://www.espressif.com/en/products/sdks/esp-idf) simplifies secondary development around ESP32-S3-BOX, and supports high-performance AI applications to run on the board, thus speeding up time-to-market for the end product. Please, keep watching this space, because we shall update specific example pointers shortly.

Espressif will continue offering its customers innovative technologies and high-performance products. We look forward to collaborating with our partners to develop more state-of-the-art applications for the AIoT industry. If you are interested in ordering ESP32-S3-BOX, please go to [AliExpress](https://www.aliexpress.com/item/1005005920207976.html), [Adafruit](https://www.adafruit.com/product/5290) or [Amazon](https://www.amazon.com/dp/B09JZ8XWCN?ref=myi_title_dp). If you want to know more about the product, please contact our [customer support team](https://www.espressif.com/en/contact-us/sales-questions), who will try and assist you as soon as possible.
