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

- **HMAC NVS:** SoCs without an HMAC peripheral cannot follow Assignment 2. They can still encrypt NVS with the flash encryption-based scheme (an `nvs_keys` partition), which Assignment 4 uses.
- **Secure Boot V2:** Assignment 3 signs images with RSA-3072. On SoCs marked **ECDSA only**, use the ECDSA signing scheme instead; the rest of the flow is the same.
- **TLS:** SoCs without Wi-Fi need another network interface for Assignment 1, such as Ethernet or an SPI Ethernet module.
- **Emulator:** Assignments 2 to 5 run in the [ESP32 emulator](https://github.com/espressif/esp-emulator). For another SoC, check that the emulator supports it, or run those labs on a board you are ready to provision permanently.
- Board-specific steps (ports, Ethernet, partition sizes) and the eFuse key block plan need adapting to your board. Check the ESP-IDF documentation for your SoC and release before running the labs.

Assignment 1 runs on your ESP32-S31-Function-CoreBoard-1. Assignments 2 to 4 build firmware with **production settings**, with no development or test options, and run it in the [ESP32 emulator](https://espressif.github.io/esp-emulator/) in your browser. The emulator runs the real ESP32-S31 ROM and bootloader, so Secure Boot V2, flash encryption, and NVS encryption burn their eFuses exactly as on silicon, but your board is never permanently provisioned. Signed OTA updates with app rollback are covered in the optional [Assignment 5](assignment-5), and provisioning a real board with the same firmware is covered in the optional [real-board appendix](appendix-production-provisioning).

By the end of the workshop, you will be able to:

- Describe the main ESP32-S31 and hardware security features
- Explain the CRA requirements relevant to embedded connected products
- Enable Secure Boot V2 and release-mode flash encryption with production settings, and read the evidence in the boot log
- Protect data at rest with NVS encryption, using an HMAC key or keys protected by flash encryption
- Explain why the order of eFuse burns matters when you provision a device
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

- The workshop burns no eFuses on participant boards. Assignments 2 to 5 run in the emulator.
- Never flash the Assignment 2 to 5 images to a board, and do not run any `espefuse burn` or `burn-key` command on it. These images provision a chip on first boot, and on a board that is permanent.
- Read [Lab safety and the ESP32 emulator](introduction/#lab-safety-and-the-esp32-emulator) before the first assignment.
- Optional: one instructor demo board, provisioned for real for a short live demo (students observe only). See the [real-board appendix](appendix-production-provisioning).

### Required software

- ESP-IDF v6.1
- TODO: Add CLion
- Git
- A recent desktop web browser for the [ESP32 emulator](https://espressif.github.io/esp-emulator/) (Assignments 2 to 4)
- For the optional Assignment 5: the native `esp-emu` tool from the [`esp-emulator` repository](https://github.com/espressif/esp-emulator), and Python 3 to run the test OTA server

## Agenda

- [Introduction](introduction)
- [Overview of the ESP32-S31 features](overview-esp32-s31-features)
- [Overview of the security features on the ESP32-S31](overview-security-features)
- [Overview of the EU Cyber Resilience Act](overview-eu-cra)
- [Lecture 1: TLS for secure communication](lecture-1)
- [Assignment 1: Establish and verify a TLS connection](assignment-1)
- [Lecture 2: Secure storage with HMAC-based NVS encryption](lecture-2)
- [Assignment 2: Protect data with HMAC-based NVS encryption](assignment-2)
- [Lecture 3: Secure Boot V2, firmware authenticity](lecture-3)
- [Assignment 3: Enable and verify Secure Boot V2](assignment-3)
- [Lecture 4: Flash encryption, confidentiality](lecture-4)
- [Assignment 4: Enable and verify flash encryption](assignment-4)
- [Assignment 5: Add secure OTA updates](assignment-5) (optional)
- [Conclusion](conclusion)
- [Appendix: Provision a real board (permanent)](appendix-production-provisioning) (optional)

## Time requirements

{{< alert icon="mug-hot" >}}
**Estimated time: 4 hours**, plus about 45 minutes for the optional Assignment 5.
{{< /alert >}}

## Next step

[Introduction](introduction)

## Feedback

If you have feedback about this workshop, start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).
