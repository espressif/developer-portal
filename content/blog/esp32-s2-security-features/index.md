---
title: ESP32-S2 — Security Features
date: 2019-12-09
showAuthor: false
authors: 
  - amey-inamdar
---
[Amey Inamdar](https://medium.com/@iamey?source=post_page-----5e5453f98590--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F96a9b11b7090&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp32-s2-security-improvements-5e5453f98590&user=Amey+Inamdar&userId=96a9b11b7090&source=post_page-96a9b11b7090----5e5453f98590---------------------post_header-----------)

--

Espressif recently [announced](https://www.espressif.com/en/news/espressif-announces-%E2%80%A8esp32-s2-secure-wi-fi-mcu) ESP32-S2 — a new Wi-Fi SoC with additional security features and improvements over some of the ESP32 security features. Given the current state of the security of the connected devices, these are quite meaningful features. This article discusses these changes and what do they mean from security perspective.

My colleague wrote about ESP32 security features [here](https://medium.com/the-esp-journal/understanding-esp32s-security-features-14483e465724). We continue to carry forward *Secure Boot* and *Flash Encryption* features. ESP32-S2 improves these features further and also adds more security features.

Detailed ESP32-S2 [datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-s2_datasheet_en.pdf) and [technical reference manual](https://www.espressif.com/sites/default/files/documentation/esp32-s2_technical_reference_manual_en.pdf) are available now.

## Secure Boot

*Secure Boot* allows the ESP32-S2 to boot only trusted code. The BootROM (which can’t be modified and is trusted) verifies the software bootloader and software bootloader then verifies the application firmware to be trusted (authenticated) one. This is transitive trust model to ensure that the application is fully trusted.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*1p3Aomf5YQXKxJbmD2X1Og.png)

ESP32 BootROM uses a digest programmed in the eFUSE for validating the software bootloader. This digest based authentication uses AES symmetric encryption and SHA secure digest algorithm internally.

ESP32-S2 implements a public key cryptography based signature verification mechanism in BootROM. The algorithm is RSA-PSS with 3072-bit keys. The device maker generates the RSA3072 public-private key pair. The private key remains with the device maker and the public key is programmed in the eFUSE of the device at the time of manufacturing. The software bootloader image carries the signature of the image signed using the private key corresponding to the public key in eFUSE. The BootROM verifies the authenticity of the software bootloader by verifying the signature of the software bootloader (the signature in fact contains a cryptographic hash of the software bootloader that is checked against the software bootloader image).

The application firmware verification can happen using the same algorithm and same public-private key pair.

ESP32-S2 has an improved hardware RSA accelerator and BootROM’s secure boot algorithm makes use of this to provide sub-100ms signature verification time. This results into significantly reduced boot up time of the device with secure boot enabled. This is a big improvement especially for those devices which can’t afford longer boot-up time — imagine a light bulb that needs to switch on immediately upon powering-on.

## Flash Encryption

Flash encryption allows the contents of the flash to remain encrypted for the data and code at rest. This is useful in two ways

ESP32 uses AES256 cryptographic algorithm with key tweaking based on the flash offset. The flash encryption key stays in eFUSE and only the hardware has access to this key. While the key tweaking based on the flash offset adds to the security of AES256 protocol, it’s still a customised cryptographic implementation over which a standard implementation is preferred.

ESP32-S2 has an improved scheme where it uses AES256-XTS based encryption scheme that is standard for the storage encryption where the random access needs to be supported. ESP32-S2 continues to use the eFUSE for the storage and access protection of the AES-XTS keys.

## Digital Signature Peripheral

This is a new hardware block added to ESP32-S2. This block is capable of allowing application to perform RSA digital signature operations without letting the application access the private key. Let’s first discuss the need for it.

One compelling requirement for the Digital Signature Peripheral is considering the current device-cloud authentication. Most of the common device cloud implementations (AWS-IoT, Azure IoT, Google-IoT-Core to name a few) use (or support) X.509 certificate based mutual authentication. The cloud and device both have a private key and certificate with only certificate shared with the each other. With this, the cloud and device can both authenticate each other and if required cloud can revoke the service access to a specific device. So essentially the device private key is the device identity that needs to be protected. Any application vulnerability that gives the malicious user access to the device private key can compromise the device identity. The devices which require protection against such compromise typically use a separate hardware (HSM, smart-card, PIV dongles etc.) that secures the private key with itself and provides signing procedures with the stored device private key. However this adds to the cost of the device.

ESP32-S2’s Digital Signature Peripheral allows the manufacturer to generate the symmetric encryption key that can be unique to each device and then encrypt the device private key with the same encryption key. At runtime, the Digital Signature Peripheral allows application to perform signing operation with this encrypted device private key without software being able to access the plaintext private key. The per-device unique encryption key also stops malicious user from recovering plaintext private keys or cloning them on other devices.

Espressif also provides a pre-provisioned modules service where customers can order the modules that have the device certificates pre-generated in a secure fashion in Espressif factory. This when combined with the ESP32-S2’s Digital Signature Peripheral, greatly simplifies manufacturing of devices for device makers.

## More eFUSE Memory

ESP32 has 1024 bits of eFUSE memory out of which 256 bits are useable by the application.

ESP32-S2 increases the eFUSE memory to 4096 bits with 2048 bits available for application’s use. This is useful when applications want to generate and use per-device unique identifiers for its own use.

## Performance Improved Cryptographic Accelerators

ESP32-S2 has improved performance of the RSA, ECC and AES hardware accelerators. The mbedTLS stack will continue to facilitate the use of hardware accelerators making the system performance better for the TLS communication over internet and local network. Of course these peripherals can be used directly as well based on the application’s requirement.

## Resilience to Physical Fault Injection

When malicious user has physical possession of the device, a glitching based fault injection can be used to make device behave in unintended way or to give undesired information out. There has been fault injection attack [listed](https://limitedresults.com/2019/11/pwn-the-esp32-forever-flash-encryption-and-sec-boot-keys-extraction/) for ESP32 V1 SoC that allowed user to compromise security by reading encryption key or bypassing secure boot. ESP32-S2 has additional hardware and software checks in the bootROM that prevent physical voltage glitching. This hardening against physical fault injection attacks may be useful for certain product use-cases.

ESP32-S2 has some additional security features. I’ll write about them adding them to the same blog in the near future. Please stay tuned!
