---
title: "Introduction to the ESP32-S31: Security"
date: 2026-10-06
tags: ["Workshop", "ESP-IDF", "ESP32-S31", "Security", "EU CRA"]
summary: "Explore the ESP32-S31 security features that can help connected-product manufacturers meet technical requirements of the EU Cyber Resilience Act."
showTableOfContents: true
---

Welcome to the Introduction to the ESP32-S31: Security workshop!

## About this workshop

This workshop introduces the ESP32-S31 and its security capabilities through a series of focused, hands-on topics. You will examine firmware authenticity, data confidentiality, secure storage, protected communications, secure updates, anti-rollback, and power profiling.

The workshop also relates these capabilities to the technical requirements of the European Union Cyber Resilience Act (CRA). An SoC is not, by itself, CRA-compliant. Compliance applies to a product with digital elements and includes responsibilities beyond silicon, such as secure product design, vulnerability handling, documentation, and lifecycle support. The ESP32-S31 features covered here can help manufacturers build products that meet relevant CRA requirements.

Hands-on exercises use **virtual eFuses** and **signed application OTA without hardware Secure Boot** so your Function CoreBoard is not permanently provisioned in class. Production enablement with real eFuses is documented separately in the [production provisioning appendix](appendix-production-provisioning).

By the end of the workshop, you will be able to:

- Describe the main ESP32-S31 and hardware security features
- Explain the CRA requirements relevant to embedded connected products
- Walk through Secure Boot V2 and flash encryption flows using virtual eFuses
- Protect data at rest with HMAC-based NVS encryption (virtual key provisioning in the lab)
- Protect data in transit with TLS
- Perform signed application OTA updates and test emulated anti-rollback
- Use power profiling as an advanced security debugging technique
- Map technical controls to product-level CRA compliance activities

## Prerequisites

To follow this workshop, you will need the following hardware and software.

### Required hardware

- [ESP32-S31-Function-CoreBoard-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-function-coreboard-1/user_guide.html) (one board per participant is sufficient for the default lab track)
- USB cable supporting power and data
- Computer running Linux, macOS, or Windows
- TODO: Otii Arc Pro, probes, and wiring requirements

### Lab safety

- Use only the workshop ESP-IDF project defaults that enable [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) and [CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual-keep-in-flash).
- Do **not** run `espefuse burn`, `espefuse burn-key`, or production release-mode flash encryption on participant boards in class.
- Read [Lab safety and virtual eFuses](introduction/#lab-safety-and-virtual-efuses) before the first assignment.
- Optional: one instructor demo board with real provisioning for a short live demo (students observe only). See the [production provisioning appendix](appendix-production-provisioning).

### Required software

- ESP-IDF v6.1
- [Visual Studio Code](https://code.visualstudio.com/download) with the [ESP-IDF extension](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension)
- Git
- TODO: Workshop source-code repository and tested commit (must ship `sdkconfig.defaults` with virtual eFuses and an `efuse_em` partition in `partitions.csv`)
- TODO: Host operating-system drivers
- TODO: TLS endpoint, certificates, and network access
- TODO: Otii software and validated version

## Agenda

The list below is the **recommended lab order**. Lecture numbers refer to topic modules, not the order in which they were authored.

- [Introduction](introduction)
- [Lecture 1: The ESP32-S31 features](lecture-1)
- [Lecture 2: Security features on the ESP32-S31](lecture-2)
- [Lecture 3: The EU Cyber Resilience Act](lecture-3)
- [Lecture 7: TLS for secure communication](lecture-7)
- [Assignment 4: Establish and verify a TLS connection](assignment-4)
- [Lecture 6: Secure storage with HMAC-based NVS encryption](lecture-6)
- [Assignment 3: Protect data with HMAC-based NVS encryption](assignment-3)
- [Lecture 4: Secure Boot V2, firmware authenticity](lecture-4)
- [Assignment 1: Enable and verify Secure Boot V2](assignment-1)
- [Lecture 5: Flash encryption, confidentiality](lecture-5)
- [Assignment 2: Enable and verify flash encryption](assignment-2)
- [Lecture 8: Secure bootloader OTA updates with anti-rollback](lecture-8)
- [Assignment 5: Signed application OTA and emulated anti-rollback](assignment-5)
- [Lecture 9: Power profiling for advanced debugging](lecture-9)
- [Assignment 6: Profile security operations with Otii Arc Pro](assignment-6)
- [Conclusion](conclusion)
- Optional: [Appendix: Production provisioning (real eFuses)](appendix-production-provisioning)

## Time requirements

{{< alert icon="mug-hot" >}}
**Estimated time: TODO**
{{< /alert >}}

## Next step

[Introduction](introduction)

## Feedback

If you have feedback about this workshop, start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).
