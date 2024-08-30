---
title: Build affordable Secure connected devices with ESP32-H2
date: 2023-05-11
showAuthor: false
authors: 
  - anant-raj-gupta
---
[Anant Raj Gupta](https://medium.com/@ehaarjee?source=post_page-----b8d542df8cb4--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F86f1508bfacc&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fbuild-affordable-secure-connected-devices-with-esp32-h2-b8d542df8cb4&user=Anant+Raj+Gupta&userId=86f1508bfacc&source=post_page-86f1508bfacc----b8d542df8cb4---------------------post_header-----------)

--

The awareness, as well as the associated concerns, about connected device security, is ever-increasing. With the European Union’s [Cyber Resilience Act](https://digital-strategy.ec.europa.eu/en/library/cyber-resilience-act) also coming into effect soon, it has become ever so important to have security features built-in to the devices in hardware.

The Espressif ESP32-H2 has been built to provide an affordable security solution to all and thus integrates a variety of security features. The ESP32-H2 Platform security considerations can be broadly classified into the following categories.

- Secure Boot
- Flash Encryption
- Protecting Debug Interfaces
- Secure Storage
- Memory Protection
- Device Identity protection

These security features are implemented using a variety of different HW accelerators as well as SW flows to go along with them. Let’s go over each of the security features in a little bit more details.

## Secure Boot

Secure Boot protects a device from running any unauthorized (i.e., unsigned) code by checking that each piece of software being booted is signed. On an ESP32-H2, these pieces of software include the second stage bootloader and each application binary. Note that the first stage bootloader does not require signing as it is ROM code and thus cannot be changed.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*5GMXx5XFj1EcLUtj_eE2fQ.png)

The Secure Boot process on the ESP32-H2 involves the following steps:

The ESP32-H2 has provisions to choose between an RSA-PSS or ECDSA-based secure boot verification scheme. ECDSA provides similar security strength compared to RSA with shorter key lengths. Current estimates suggest that ECDSA with curve P-256 has an approximate equivalent strength to RSA with 3072-bit keys. However, ECDSA signature verification takes considerably more time compared to RSA signature verification.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*nJOM-4ku2vc2I2LltTMeuQ.png)

The RSA-PSS or ECDSA public key is stored in the eFuse on the device. The corresponding RSA-PSS or ECDSA private key is kept at a secret place and is never accessed by the device. Up to three public keys can be generated and stored in the chip during manufacturing. ESP32-H2 provides the facility to permanently revoke individual public keys.

## Flash Encryption

Flash encryption is intended to encrypt the contents of the ESP32-H2’s off-chip flash memory. Once this feature is enabled, firmware is flashed as plaintext, and then the data is encrypted in place on the first boot. As a result, physical readout of flash will not be sufficient to recover most flash contents.

When flash encryption is enabled, all memory-mapped read accesses to flash are transparently, and at runtime, decrypted. The ESP32-H2 uses the XTS-AES block cipher mode with a 256-bit key size for flash encryption. The flash controller uses the key stored in the eFUSE to perform the decryption. Similarly, any memory-mapped write operation causes the corresponding data to be transparently encrypted before being written to flash.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*NJ36iuzWC4RI07iJpNoukw.png)

During the development stage, there is a frequent need to program different plaintext flash images and test the flash encryption process. This requires that Firmware Download mode can load new plaintext images as many times as needed. However, during the manufacturing or production stages, Firmware Download mode should not be allowed to access flash contents for security reasons. Hence, two different flash encryption configurations were created.

In “Development” mode, it is still possible to flash new plaintext firmware to the device, and the stub code downloaded via UART DL mode will transparently encrypt this firmware using the key stored in hardware. This allows, indirectly, to read out the plaintext of the firmware in flash. In “Release” mode, flashing plaintext firmware to the device without knowing the encryption key is no longer possible. For production use, flash encryption should be enabled in the “Release” mode only.

## eFuse based OTP memory

eFuse plays a very important role in the overall security aspects. It provides a secure storage space on the device itself as well as also a mechanism to disable potential back-doors for on-field deployed devices.

The eFuse is a type of one-time programmable (OTP) memory region which, once programmed from 0 to 1, can never be changed back to 0. The eFuse plays an important role in the functioning of the security features of the SoC as it is used to store user data and hardware parameters, including control parameters for hardware modules, calibration parameters, the MAC address, and keys used for the encryption and decryption module.

The ESP32-H2 contains a 4096-bit eFuse memory, out of which 1792 bits are reserved for custom use and can be utilized by the application. Once the keys are stored in the eFuse, it can be configured such that any software running cannot read these keys, and only the various permitted hardware peripherals can read and use these keys. The eFuse can also be used to control the disabling of USB debug as well as JTAG debug.

## __Memory Protection__ 

The permission management of ESP32-H2 can be divided into two parts: __PMP (Physical Memory Protection)__  and __APM (Access Permission Management)__ .

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*nC7pOVDAcLPVXhscKaQdCw.png)

PMP manages the CPU’s access to all address spaces. APM does not manage the CPU’s access to ROM and SRAM. If the CPU needs to access ROM and HP SRAM, it needs permission only from PMP; if it needs to access to other address spaces, it needs to pass PMP’s permission management first and then the APM’s. If the PMP check fails, APM check will not be triggered.

The APM module contains two parts: the TEE (Trusted Execution Environment) controller and the APM controller.

- The TEE controller is responsible for configuring the security mode of a particular master in ESP32-H2 to access memory or peripheral registers. There are four security modes supported. When the RISC-V core is in Machine mode, the security mode is set to Trusted(TEE). When the core is in User mode, the security mode can se set to any of the 3 REE based on the register configurations.
- The APM controller is responsible for managing a master’s permission (read/write/execute) when accessing memory and peripheral registers. By comparing the pre-configured address ranges and corresponding access permissions with the information carried on the bus, such as Master ID, security mode, access address, access permissions, etc, the APM controller determines whether access should be allowed or blocked. The total memory space including internal memory, external memory and peripheral space can be configured into 16 address regions to define the different access permissions to each of these regions.

When ever there is an illegal access, if enabled, an interrupt is be generated and the details of the illegal access are recorded. The APM controller will record relevant information including the master ID, security mode, access address, reasons for illegal access (address out of bounds or permission restrictions), and permission management result of each access path.

## Device Identity protection

The __Digital Signature (DS) peripheral__  is a security feature included in the ESP32-H2 and enhanced from the previous version in the Espressif’s SoC. It produces hardware accelerated digital signatures, without the private key being accessible by software. This allows the private key to be kept secured on the device without anyone other than the device hardware being able to access it. You can read more in details about in a previous [blog post](/esp32-s2-digital-signature-peripheral-7e70bf6dde88).

Digital Signature Peripheral allows the manufacturer to generate the symmetric encryption key that can be unique to each device and then encrypt the device private key with the same encryption key. At runtime, the Digital Signature Peripheral allows application to perform signing operation with this encrypted device private key without software being able to access the plaintext private key.

It uses pre-encrypted parameters to calculate a signature. The parameters are encrypted using HMAC as a key-derivation function. In turn, the HMAC uses eFuses as input key. The whole process happens in hardware so that neither the decryption key nor the input key for the HMAC key derivation function can be seen by the software while calculating the signature.

__ECDSA Accelerator__ With ESP32-H2, supports ECDSA based private keys as well on top of the RSA based keys. This is particularly important with regards to [Matter](https://csa-iot.org/all-solutions/matter/). The [Matter security model](/matter-security-model-37f806d3b0b2) is based on [Public Key Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure)(PKI), a cryptographic mechanism widely adopted in the Internet and uses the ECC with the “P-256” curve for digital signatures and key exchanges. This makes ECDSA based signatures mandatory for certificate exchanges.

Elliptic Curve Digital Signature Algorithm, or ECDSA, is one of the more complex public key cryptography encryption algorithms. Keys are generated via elliptic curve cryptography, which are smaller than the average keys generated by digital signing algorithms. ECDSA’s use of smaller keys to achieve the same level of security as other digital signature algorithms is a major advantage, reducing implementation overheads such as key storage and exchange.

## Cryptographic Accelerators

The ESP32-H2 includes a wide range of cryptographic accelerators to offload the CPU for all commonly required cryptographic functions for the above features as well as other common application scenarios. The ESP32-H2 continues to have the common accelerators found in the ESP32 series, including:

__*AES-128/256*__ : ESP32-H2 integrates an Advanced Encryption Standard (AES) accelerator supporting AES-128/AES-256 encryption and decryption specified in FIPS PUB 197 for protection against DPA attack. The peripheral also supports block cipher modes ECB, CBC, OFB, CTR, CFB8, and CFB128 under NIST SP 800–38A.

__*SHA Accelerator:*__  The ESP32-H2 integrates a HW to accelerate the Secure Hashing Algorithm (SHA) hash algorithms SHA-1, SHA-224 and SHA-256 introduced in FIPS PUB 180–4 Spec. Secure Hashing Algorithms are required in all digital signatures and certificates relating to SSL/TLS connection nd is also used by the Digital Signature Peripheral internally.

__*RSA Accelerator:*__  The RSA algorithm is a public-key signature algorithm based on the [Public Key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography). The RSA accelerator provides hardware support for high-precision computation used in various RSA asymmetric cipher algorithms, significantly improving their run time and reducing their software complexity. The RSA accelerator also supports operands of different lengths, which provides more flexibility during the computation.

__*HMAC:*__  The HMAC (Hash-based Message Authentication Code) module provides hardware acceleration for SHA256-HMAC, as described in RFC 2104,* *generation. The 256-bit HMAC key is stored in an eFuse key block and can be set as read-protected. HMACs work with pre-shared secret keys and provide authenticity and integrity to a message.

__*ECC Accelerator : *__ Elliptic Curve Cryptography (ECC) is an approach to public-key cryptography based on the algebraic structure of elliptic curves. ECC uses smaller keys compared to RSA cryptography while providing equivalent security. ESP32-H2’s ECC Accelerator can complete various calculations based on 2 different elliptic curves, namely P-192 and P-256 defined in FIPS 186–3, thus accelerating the ECC algorithm and ECC-derived algorithms. The HW supports up to 11 working modes.

This summarises the various security features present in the ESP32-H2 which can enable the development of affordable secure connected devices for varied applications.

__*Further Readings:*__ 

- *IDF security guide: *[*https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/security/security.html*](https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/security/security.html)
- *Secure Boot v2 guide : *[*https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/security/secure-boot-v2.html*](https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/security/secure-boot-v2.html)
- *Flash Encryption guide : *[*https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/security/flash-encryption.html*](https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/security/flash-encryption.html)
- *Digital Signature guide : *[*https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/api-reference/peripherals/ds.html*](https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/api-reference/peripherals/ds.html)
- *eFuse Manager guide : *[*https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/api-reference/system/efuse.html*](https://docs.espressif.com/projects/esp-idf/en/latest/esp32h2/api-reference/system/efuse.html)
