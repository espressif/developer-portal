---
title: "ESP32 OTA Updates — Amazon FreeRTOS"
date: 2018-09-30
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - mahavir-jain
tags:
  - AWS
  - Esp32
  - IoT
  - Framework

---
ESP32 now supports secure Over-the-Air firmware updates with Amazon FreeRTOS. This enables users of ESP32 with Amazon FreeRTOS to:

- Deploy new firmware on ESP32 in secure manner (single or group of devices, along with dynamic addition of new/re-provisioned device)
- Verify authenticity and integrity of new firmware after its deployed
- Extend OTA update security scheme to take leverage of hardware security features in ESP32

## Working

At a high level,

- The firmware image (or any other partition’s content: filesystem, configuration data), is initially uploaded to an S3 bucket on AWS.
- An AWS OTA Job with the required certificates (for demo purpose can be self-signed) and code-signing profile (security scheme for ESP32 is ECDSA + SHA256) is setup.
- On the device side, the OTA agent from Amazon FreeRTOS needs to be enabled in the firmware, along with the certificate that is responsible for verifying the firmware update image (essentially ECDSA public key).
- The AWS OTA Job then takes the firmware image from the S3 bucket, signs it, and sends it over MQTT+TLS channel in small chunks to the OTA agent on the device.
- The OTA agent on the device then writes the newly received firmware to its storage and manages the state.
- At the end, firmware signature gets validated on the device and it gets approved for boot-up.
- Post boot-up, the OTA agent again interacts with AWS OTA Job for verifying sanity of firmware, and finally the firmware image gets marked as legitimate one, notifying the boot-loader to erase all older firmware instances from the device storage (for not allowing forced rollback).

## Procedure

Lets quickly walk over the steps for getting the OTA update demo functional on ESP32:

- Please follow the Getting Started Guide for some of the prerequisites as documented at, [__https://docs.aws.amazon.com/freertos/latest/userguide/ota-prereqs.html__ ](https://docs.aws.amazon.com/freertos/latest/userguide/ota-prereqs.html)
- Refer to [__https://docs.aws.amazon.com/freertos/latest/userguide/ota-code-sign-cert-esp.html__ ](https://docs.aws.amazon.com/freertos/latest/userguide/ota-code-sign-cert-esp.html) for creating code signing profile for the ESP32 platform
- For downloading firmware to ESP32, refer to [__https://docs.aws.amazon.com/freertos/latest/userguide/ota-download-freertos.html__ ](https://docs.aws.amazon.com/freertos/latest/userguide/ota-download-freertos.html)
- Once the device boots up, the log should look like the one mentioned at, [__https://docs.aws.amazon.com/freertos/latest/userguide/burn-initial-firmware-esp.html__ ](https://docs.aws.amazon.com/freertos/latest/userguide/burn-initial-firmware-esp.html)
- Create an Amazon FreeRTOS OTA Job (by navigating to IoT Core -> Manage -> Jobs -> Create),

{{< figure
    default=true
    src="img/esp-1.webp"
    >}}

- Select “Sign a new firmware image for me” option,

{{< figure
    default=true
    src="img/esp-2.webp"
    >}}

- Create code signing profile, please select ESP32 platform here and provide certificates created earlier,

{{< figure
    default=true
    src="img/esp-3.webp"
    >}}

{{< figure
    default=true
    src="img/esp-4.webp"
    >}}

## Enabling Hardware Security

The ESP32 port is so structured that the same secure firmware verification mechanism can be used by the ESP32 chipset for enabling [__secure boot__ ](https://docs.espressif.com/projects/esp-idf/en/latest/security/secure-boot.html).

ESP32’s secure boot scheme uses the same ECDSA + SHA256 algorithm. Hence the same public key that is used for the OTA firmware image verification can also be used by the bootloader to validate the firmware image on boot-up.

It is highly recommended that you use secure boot in conjunction with the OTA firmware updates in your products.
