---
title: "Introduction to the ESP32-S31: Security - Introduction"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 1
showAuthor: false
---

## Why security matters

A connected product stores firmware in flash, keys in eFuses or protected NVS, and often Wi-Fi or TLS credentials beside user configuration. If an attacker manages to tamper with the bootloader, read flash offline, or intercept traffic, it will breaks trust in the device and in the company that shipped it.

This chapter sets the scope for the workshop: which ESP32-S31 mechanisms we will configure, and how that work relates to obligations under the EU Cyber Resilience Act (CRA).

> [!IMPORTANT]
> The CRA applies to products with digital elements and to the economic operators responsible for them. An ESP32-S31 does not make a finished product compliant by itself.
>
> The assignments walk through TLS on the ESP32-S31-Function-CoreBoard-1, then HMAC-based NVS encryption, Secure Boot V2, and flash encryption with production settings in the [ESP32 emulator](https://espressif.github.io/esp-emulator/), so no eFuse is burned on your board in class.
>
> That is technical evidence you can use in a compliance program; it is not legal advice. Signed OTA updates with app rollback are covered in the optional [Assignment 5](../assignment-5); provisioning a real board, with permanent eFuse burns, is covered in the optional [real-board appendix](../appendix-production-provisioning).

## Learning objectives

After completing this chapter, you will be able to:

- Explain the scope and structure of the workshop
- Tell SoC-level security apart from product-level CRA compliance
- Name the assets and attack surfaces the exercises address
- Prepare for the development and provisioning workflow used in the assignments

## Workshop scenario

The CRA treats cybersecurity as a product requirement under **security by design**: secure defaults, protected credentials and firmware, authenticated updates, and proof that those controls still work during the support period you commit to.

This workshop runs that idea on the ESP32-S31 with ESP-IDF v6.1. A lecture introduces each topic, and the next assignment implements and checks it. After the overview of SoC, its security features, and the CRA context, the **lab order** is TLS, HMAC-based NVS encryption, Secure Boot V2, and flash encryption. TLS runs on the [ESP32-S31-Function-CoreBoard-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-function-coreboard-1/user_guide.html); the other labs run the same firmware project in the ESP32 emulator.

## Get the workshop projects

The [workshop code examples](https://github.com/espressif/developer-portal-codebase/tree/main/content/workshops/introduction-to-esp32-s31-security/code-examples) provide one complete, independently buildable ESP-IDF v6.1 project for each assignment, plus controlled build and emulator scripts.

Clone only the workshop examples:

```bash
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/espressif/developer-portal-codebase.git
cd developer-portal-codebase
git sparse-checkout set \
  content/workshops/introduction-to-esp32-s31-security/code-examples
cd content/workshops/introduction-to-esp32-s31-security/code-examples
scripts/check-environment.sh
```

Each assignment links to its matching folder. The prepared project is the recommended route: inspect the supplied source while following the steps, then build and run the checks. If you want to practice every edit, you can instead use the cumulative manual route described in the assignments, starting from the ESP-IDF `https_mbedtls` example.

## Lab safety and the ESP32 emulator

Many ESP32-S31 security features store user settings and secrets in **eFuses** which are one-time programmable. The firmware you build in this workshop uses production settings, so on its first boot it burns eFuses for real: the Secure Boot key digest, the flash encryption key, and the bits that disable ROM download mode and JTAG. On a physical board, it cannot be reverted. From then on, the board will accept only the firmware signed with your key and will lose the ability to be flashed over serial.

To learn these flows without locking your board, Assignments 2 to 4 run in the [ESP32 emulator](https://espressif.github.io/esp-emulator/), a web page that emulates Espressif SoCs. It runs the real ESP32-S31 ROM and the ESP-IDF bootloader, so the eFuse burns, signature checks, and flash encryption happen exactly as on silicon, but only in the emulator's memory. Reloading the page gives you a new, blank chip.

The emulator runs entirely in your browser tab: the firmware never leaves your machine and is not uploaded anywhere. A live dashboard shows the console, instruction rate, cores, GPIO pads, registers, and memory. The native `esp-emu` tool used in Assignment 5 also runs locally, on your computer.

| Lab | Runs on | Burns eFuses on your board |
|-----|---------|--------------------------------|
| [Assignment 1](../assignment-1): TLS | ESP32-S31-Function-CoreBoard-1 | No |
| [Assignment 2](../assignment-2): HMAC-based NVS encryption | Web emulator | No |
| [Assignment 3](../assignment-3): Secure Boot V2 | Web emulator | No |
| [Assignment 4](../assignment-4): flash encryption and NVS keys | Web emulator | No |
| [Assignment 5](../assignment-5) (optional): secure OTA | Native `esp-emu` on your computer | No |
| [Real-board appendix](../appendix-production-provisioning) (optional) | ESP32-S31-Function-CoreBoard-1 | **Yes, permanently** |

**Working with the web emulator:**

- Build the project as usual, merge the bootloader, partition table, and app into one image, and load that file in the emulator with the chip set to **esp32s31**. Each assignment gives the exact merge command.
- The emulator's UART console shows the same log you would see in `idf.py monitor`. It is your only evidence, so read it carefully.
- The emulator provides a Wi-Fi access point with SSID `myssid` and password `mypassword`. Configure these credentials in menuconfig.
- The web version has no internet access. Wi-Fi connects, but the TLS request in the example fails with `mbedtls_net_connect returned -52`. This is expected; TLS is tested on the board in Assignment 1.
- eFuses survive resets within one run, but loading a new image or reloading the page starts with blank eFuses. Every assignment image is therefore built to provision a new chip on its first boot.

**Assignment 5** needs networking between the device and an OTA server on your computer, which the web version does not provide.

**Forbidden in class:** flashing the Assignment 2 to 5 images to your board, and running any `espefuse burn` or `burn-key` command on it. These images provision a chip on first boot; on a board, that is permanent.

**Production** enablement on real hardware belongs in manufacturing or a controlled pilot. The optional [real-board appendix](../appendix-production-provisioning) shows how to provision one dedicated board with the Assignment 4 image. Also see Espressif's [Security Features Enablement Workflows (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/v6.1/esp32s31/security/security-features-enablement-workflows.html).

## Threat model

The exercises assume there is an attacker who can reach your device over the network, reflash or read external flash if protection is off, and, in some labs, gain brief physical access to USB or test points. They do not cover cloud backend compromise, supply-chain attacks on your CI, or formal penetration testing.

Assets to keep in mind:

- Bootloader and application firmware
- Device identity and cryptographic keys
- User and configuration data
- Update metadata and security version
- Network traffic and remote-service credentials

## Expected outcomes

When the workshop is complete, you will have built and verified the controls listed on the [workshop home page](/workshops/introduction-to-esp32-s31-security/#about-this-workshop): TLS on the board, and production-configured NVS encryption, Secure Boot V2, and flash encryption in the emulator. The [conclusion](../conclusion/#security-control-recap) maps each assignment to protected assets, security properties, CRA themes, and verification steps.

## Navigation

[Next: Overview of the ESP32-S31 features](../overview-esp32-s31-features)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
