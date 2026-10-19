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

> [!NOTE]
> This workshop was designed for the ESP32-S31, but most of it also applies to other Espressif SoCs, depending on their capabilities. The table below shows which assignments each SoC can follow.

### Using this workshop with other SoCs

| SoC | TLS (Assignment 1) | HMAC NVS (Assignment 2) | Secure Boot V2 RSA (Assignment 3) | Flash encryption (Assignment 4) |
|-----|--------------------|-------------------------|-----------------------------------|---------------------------------|
| ESP32-S31 | Yes (Wi-Fi or Ethernet) | Yes | Yes | Yes |
| ESP32-S3 | Yes (Wi-Fi) | Yes | Yes | Yes |
| ESP32-S2 | Yes (Wi-Fi) | Yes | Yes | Yes |
| ESP32-C6 | Yes (Wi-Fi) | Yes | Yes | Yes |
| ESP32-C5 | Yes (Wi-Fi) | Yes | Yes | Yes |
| ESP32-C3 | Yes (Wi-Fi) | Yes | Yes | Yes |
| ESP32-P4 | Ethernet, or Wi-Fi through a companion SoC | Yes | Yes | Yes |
| ESP32-H2 | External network interface needed | Yes | Yes | Yes |
| ESP32 | Yes (Wi-Fi or Ethernet) | No | SoC revision v3.0 or later | Yes |
| ESP32-C61 | Yes (Wi-Fi) | No | ECDSA only | Yes |
| ESP32-C2 | Yes (Wi-Fi) | No | ECDSA only | Yes |

How to read the table:

- **HMAC NVS:** SoCs without an HMAC peripheral cannot follow Assignment 2. They can still encrypt NVS with the flash encryption-based scheme (an `nvs_keys` partition), shown in the ESP-IDF `flash_encryption` example.
- **Secure Boot V2:** Assignment 3 signs images with RSA-3072. On SoCs marked **ECDSA only**, use the ECDSA signing scheme instead; the rest of the flow is the same.
- **TLS:** SoCs without Wi-Fi need another network interface for Assignment 1, such as Ethernet or an SPI Ethernet module.
- Board-specific steps (ports, Ethernet, partition sizes) and the eFuse key block plan need adapting to your board. Check the ESP-IDF documentation for your SoC and release before running the labs.

Hands-on exercises use **virtual eFuses** so your ESP32-S31-Function-CoreBoard-1 is not permanently provisioned in class. The one exception is HMAC-based NVS encryption: Assignment 2 burns a single real eFuse key block with purpose `HMAC_UP`, because the HMAC peripheral reads its key from hardware. Production enablement with real eFuses and anti-rollback is documented separately in the [production provisioning appendix](appendix-production-provisioning). Signed OTA updates with app rollback are covered in the optional [Assignment 5](assignment-5).

By the end of the workshop, you will be able to:

- Describe the main ESP32-S31 and hardware security features
- Explain the CRA requirements relevant to embedded connected products
- Walk through Secure Boot V2 and flash encryption flows using virtual eFuses
- Protect data at rest with HMAC-based NVS encryption (real HMAC key generated on the SoC at first boot)
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

- Assignments 3, 4, and 5 require [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) and [CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual-keep-in-flash). Assignment 2 requires `CONFIG_EFUSE_VIRTUAL` to be **off**.
- The only permanent eFuse write in class is the `HMAC_UP` key that Assignment 2 generates on first boot. Do **not** run any other `espefuse burn` or `burn-key` command, and do not use release-mode flash encryption on participant boards.
- Read [Lab safety and virtual eFuses](introduction/#lab-safety-and-virtual-efuses) before the first assignment.
- Optional: one instructor demo board with real provisioning for a short live demo (students observe only). See the [production provisioning appendix](appendix-production-provisioning).

### Required software

- ESP-IDF v6.1
- [Visual Studio Code](https://code.visualstudio.com/download) with the [ESP-IDF extension](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension)
- Git

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
- Optional: [Assignment 5: Add secure OTA updates](assignment-5)
- [Conclusion](conclusion)
- Optional: [Appendix: Production provisioning (real eFuses)](appendix-production-provisioning)

## Time requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 4 hours**, plus about 45 minutes for the optional Assignment 5.
{{< /alert >}}

## Next step

[Introduction](introduction)

## Feedback

If you have feedback about this workshop, start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).
