---
title: "Understanding ESP32’s Security Features"
date: 2018-05-31
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kedar-sovani
tags:
  - Security
  - Building Products

---
[This document discusses security features for ESP32v3. If you are looking for the security features of the latest [ESP32-S2](https://www.espressif.com/en/news/espressif-announces-%E2%80%A8esp32-s2-secure-wi-fi-mcu) SoC, that article is available [here](/blog/esp32-s2-security-improvements).]

The ESP32v3 has two interesting features, secure boot and flash encryption. Let’s have a quick overview of these features.

Typically when a device is shipped, any firmware or data is stored in the SPI flash connected to the ESP32v3. Since typically flashes are external to the SoC, a sufficiently inclined person could read the contents of this flash if she so desires for their benefit. What’s more, the contents could also be modified or tampered with to affect the flow of execution.

The flash encryption and secure boot features protect from the side-effects of these types of unwanted accesses to the flash.

## The eFUSE: One Time Programmable

The eFUSE plays an important role in the functioning of these security features. So let’s quickly look into the eFUSE before we get into the security features.

The ESP32 has a 1024-bit eFUSE, which is a one-time programmable memory. This eFUSE is divided into 4 blocks of 256-bits each.

{{< figure
    default=true
    src="img/understanding-1.webp"
    >}}

Of primary interest to us right now are blocks 1 and 2. These blocks store keys for flash encryption and secure boot respectively. Also, once the keys are stored in the eFUSE, it can be configured such that any software running on ESP32 cannot read (or update) these keys (__disable software readout__ ). Once enabled, only the ESP32 hardware can read and use these keys for ensuring secure boot and flash encryption.

## Secure Boot

> The secure boot support ensures that when the ESP32 executes any software from flash, that software is trusted and signed by a known entity. If even a single bit in the software bootloader and application firmware is modified, the firmware is not trusted, and the device will refuse to execute this untrusted code.

This is achieved by building a chain of trust from the hardware, to the software bootloader to the application firmware.

{{< figure
    default=true
    src="img/understanding-2.webp"
    >}}

## Validating the Software Bootloader

The Bootloader image, as stored in flash, contains the following logical parts:

{{< figure
    default=true
    src="img/understanding-3.webp"
    >}}

- __Bootloader Image:__ This is the bootloader executable that contains the bootloader
- __RSA Signature:__  This is the RSA3072 based signature of the bootloader image.
- __RSA 3072 Public Key:__  The public key that can be used to validate the signature.

The validation progresses as follows:

This way, it is validated that the bootloader is trusted. The RSA __private__  key that was used to generate the signature is kept safely with the manufacturer.

## Validating the Application Firmware

In the previous step, the Bootloader is confirmed to be trusted. Once trust is established, the BootROM transfers execution control to the Bootloader.

The Bootloader will now, in turn, validate the Application Firmware. The validation of application firmware is exactly similar to that of the bootloader as shown below.

{{< figure
    default=true
    src="img/understanding-4.webp"
    >}}

And that’s how secure boot on ESP32 works.

## Flash Encryption

> The flash encryption support ensures that any application firmware, that is stored in the flash of the ESP32, stays encrypted. This allows manufacturers to ship encrypted firmware in their devices.

When flash encryption is enabled, all memory-mapped read accesses to flash are transparently, and at-runtime, decrypted. The flash controller uses the AES key stored in the eFUSE to perform the AES decryption. Similarly, any memory-mapped write operation causes the corresponding data to be transparently encrypted before being written to flash.

{{< figure
    default=true
    src="img/understanding-5.webp"
    >}}

Because the key is locked into the eFUSE, only the hardware can use it to decrypt the contents of the flash.

## Disabling JTAG/UART Boot

The eFuse has one-time programmable bit fields that allow you to disable support for JTAG debugging, as well as the support for UART Boot. Once disabled, these features cannot be re-enabled on the device under consideration.

__Previous versions of ESP32__ 

The previous versions of ESP32 (prior to ESP32v3), did not support RSA. This is called [Secure Boot v1](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/security/secure-boot-v1.html) (as opposed to Secure Boot v2 supported in ESP32v3 onwards).

If you are looking for network security using TLS (Transport Layer Security), please go to this article: [TLS and IoT](https://link.medium.com/dAVg4xqtkR).

If you are looking for more information or would like to try it out, please head over to the step-by-step documentation for [Secure Boot](http://esp-idf.readthedocs.io/en/latest/security/secure-boot.html) and [Flash Encryption](http://esp-idf.readthedocs.io/en/latest/security/flash-encryption.html).
