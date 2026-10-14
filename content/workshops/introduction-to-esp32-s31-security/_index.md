---
title: "Introduction to the ESP32-S31: Security"
date: 2026-10-06
tags: ["Workshop", "ESP-IDF", "ESP32-S31", "Security", "EU CRA"]
summary: "Explore the ESP32-S31 security features that can help connected-product manufacturers meet technical requirements of the EU Cyber Resilience Act."
showTableOfContents: true
---

Welcome to the Introduction to the ESP32-S31: Security workshop!

## About this workshop

This workshop introduces the ESP32-S31 and its security capabilities through a series of focused, hands-on topics. You will examine firmware authenticity, data confidentiality, secure storage, and protected communications.

The workshop also relates these capabilities to the technical requirements of the European Union Cyber Resilience Act (CRA). An SoC is not, by itself, CRA-compliant. Compliance applies to a product with digital elements and includes responsibilities beyond silicon, such as secure product design, vulnerability handling, documentation, and lifecycle support. The ESP32-S31 features covered here can help manufacturers build products that meet relevant CRA requirements.

Hands-on exercises use **virtual eFuses** so your Function CoreBoard is not permanently provisioned in class. Production enablement with real eFuses, secure OTA, and anti-rollback is documented separately in the [production provisioning appendix](appendix-production-provisioning).

By the end of the workshop, you will be able to:

- Describe the main ESP32-S31 and hardware security features
- Explain the CRA requirements relevant to embedded connected products
- Walk through Secure Boot V2 and flash encryption flows using virtual eFuses
- Protect data at rest with HMAC-based NVS encryption (virtual key provisioning in the lab)
- Protect data in transit with TLS
- Observe an instructor-led **TLS power consumption** demo with Qoitech Otii (closing [Assignment 1](assignment-1/#closing-demo-tls-power-consumption))
- Map technical controls to product-level CRA compliance activities

## Prerequisites

To follow this workshop, you will need the following hardware and software.

### Required hardware

- [ESP32-S31-Function-CoreBoard-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-function-coreboard-1/user_guide.html) (one board per participant is sufficient for the default lab track)
- USB cable supporting power and data
- Computer running Linux, macOS, or Windows

**Instructor-only (Otii TLS demo):** [Qoitech Otii Arc Pro](https://www.qoitech.com/otii-arc-pro/) or equivalent, probes, and validated supply wiring. Students observe during the [Assignment 1 closing demo](assignment-1/#closing-demo-tls-power-consumption); participant kits do not require Otii hardware.

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

## Agenda

- [Introduction](introduction)
- [Overview of the ESP32-S31 features](overview-esp32-s31-features)
- [Overview of the security features on the ESP32-S31](overview-security-features)
- [Overview of the EU Cyber Resilience Act](overview-eu-cra)
- [Lecture 1: TLS for secure communication](lecture-1)
- [Assignment 1: Establish and verify a TLS connection](assignment-1) (includes optional instructor **Otii** TLS power demo at the end)
- [Lecture 2: Secure storage with HMAC-based NVS encryption](lecture-2)
- [Assignment 2: Protect data with HMAC-based NVS encryption](assignment-2)
- [Lecture 3: Secure Boot V2, firmware authenticity](lecture-3)
- [Assignment 3: Enable and verify Secure Boot V2](assignment-3)
- [Lecture 4: Flash encryption, confidentiality](lecture-4)
- [Assignment 4: Enable and verify flash encryption](assignment-4)
- [Conclusion](conclusion)
- Optional: [Appendix: Production provisioning (real eFuses)](appendix-production-provisioning)

## Time requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 4 hours.**
{{< /alert >}}

## Next step

[Introduction](introduction)

## Feedback

If you have feedback about this workshop, start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).
