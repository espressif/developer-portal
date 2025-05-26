---
title: "ESP32 Undocumented Bluetooth Commands: Clearing the Air"
date: 2025-03-10
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - mahavir-jain
tags:
  - ESP32
  - Security
  - IoT
  - Bluetooth

---
## Overview

Espressif has already provided a [formal response](https://www.espressif.com/en/news/Response_ESP32_Bluetooth) to the recently published claims about ESP32 Bluetooth controller serving as a potential "backdoor" or having "undocumented features" that can cause security concerns.

This post highlights the technical details about the relevant commands (HCI Commands) that were undocumented and establishes that the mentioned undocumented HCI commands do not pose a security threat and are certainly not a "backdoor".

### What are HCI Commands?

The Bluetooth protocol stack consists of two primary layers:

- **Bluetooth Controller (Lower Layer)** – Handles radio operations, link management, and low-level Bluetooth communication. Each ESP32 series chip implements a controller through a combination of hardware and software.
- **Bluetooth Host Stack (Upper Layer)** – Manages higher-level Bluetooth functionality, such as pairing, encryption, and application-layer interactions. This is fully implemented in software. The ESP32 series of chips support open-source NimBLE and Bluedroid as Bluetooth host stacks.

{{< figure
    default=true
    src="img/bluetooth_architecture.webp"
    caption="[Zoom Image](img/bluetooth_architecture.webp)"
    >}}

These layers communicate via a standard interface call the Host Controller Interface (HCI). HCI defines a set of standard commands for the Bluetooth Host stack to use. The Bluetooth controller implements standard HCI commands along with a set of Vendor-specific HCI commands that are primarily used for custom hardware initialization on control as well as for debugging purposes.

### What is the Reported Security Issue?

The reported security issue highlights that the ESP32 contains a set of undocumented HCI commands. The issue claims that these could be used to gain malicious access to devices running Bluetooth on the ESP32.

### What are these Undocumented Commands?

The "undocumented" HCI commands mentioned in the report are debug commands present in the Bluetooth controller IP in the ESP32. These commands are mostly for assisting the debug (e.g., read/write RAM, memory mapped flash read, send/receive packets, etc.) and do not play any active role in the HCI communication from a standard Bluetooth host stack such as NimBLE or Bluedroid used on the ESP32.

Such debugging commands, a common paradigm for Bluetooth Controller implementations, assist developers to debug Controller behavior. This is particularly helpful in dual-chip solutions.

## ESP32 Bluetooth Architecture

In ESP32, the Controller and the Host both run on the same MCU. The Host continues to communicate with the Controller over HCI. But since both are running on the same MCU, the HCI can be treated as a **virtual** HCI layer, an internal layer of communication.

Any code accessing this virtual HCI layer should itself be first executing on the ESP32, with full execution privileges.

{{< figure
    default=true
    src="img/esp32_bluetooth_vhci.webp"
    caption="[Zoom Image](img/esp32_bluetooth_vhci.webp)"
    >}}

## Impact

- For the majority of the ESP32 applications, the Bluetooth Host and Controller are part of the same application binary running on ESP32. There is no security risk because the application already has full privileged access to the memory and registers as well as ability to send/receive Bluetooth packets irrespective of the availability of these HCI commands.
- These undocumented HCI commands cannot be triggered by Bluetooth, radio signals, or over the Internet, unless there is a vulnerability in the application itself or the radio protocols. Presence of such vulnerabilities will be a bigger problem and the presence of these undocumented commands does not offer additional attack surface.
- Only the original ESP32 chip has these commands. ESP32-C, ESP32-S and ESP32-H series chips are unaffected as they don't have these commands supported in their Bluetooth controller.

## ESP32 Hosted Mode Operation (Less Commonly Used)

In a not-so-commonly-used alternate configuration, ESP32 can tunnel HCI commands over a serial (e.g., **UART HCI**) interface to an external host system. This is typically used in scenarios where ESP32 acts just as a communication coprocessor. This type of use of ESP32 is not as common as the standalone mode of operation.

{{< figure
    default=true
    src="img/esp32_bluetooth_serial_hci.webp"
    caption="[Zoom Image](img/esp32_bluetooth_serial_hci.webp)"
    >}}

In such a system,  the ESP32 fully trusts the host. If an attacker maliciously gains control over the host system, they could potentially issue these debug commands to influence ESP32's behavior. However, an attacker must first compromise the host device, making this a second-stage attack vector rather than a standalone vulnerability. Or, gain a physical access to the device to send the HCI commands over serial interface.

For these UART-HCI-based implementations, the attack is not self-exploitable. Still, a software fix can disable debug commands via an OTA update for added security. We will have more updates in our software stack regarding this soon.

## Mitigation

As summarized above, there is no real, known security threat that these undocumented commands pose. Regardless, Espressif has decided to take the following measures:

- Espressif will provide a fix that removes access to these HCI debug commands through a software patch for currently supported ESP-IDF versions
- Espressif will document all Vendor-specific HCI commands to ensure transparancy of what functionality is available at the HCI layer

## Summary

To summarize, for most ESP32 applications, we do not foresee any impact from the reported issue provided the product has the recommended platform security features enabled. For a small number of Bluetooth HCI serial use-cases, we can mitigate the issue by disabling debug commands and we will provide an update on that front soon.

We follow a standardized [Product Security Incident Response process](https://www.espressif.com/sites/default/files/Espressif%20Security%20Incident%20Response%20Process%20v1.0_EN.pdf) and we believe in responsible disclosure.

We believe that the security of devices based on Espressif chips is of paramount importance and are committed to transparency and best security practices. We will continue to work with the community to ensure that our devices are secure and that all security-related information is responsibly disclosed.

## Update

- **March 20, 2025**: This issue has been assigned the identifier [CVE-2025-27840](https://nvd.nist.gov/vuln/detail/CVE-2025-27840)
- **May 26, 2025**: Precautionary measures promised above are part of software stack now, please see the advisory for more details [AR2025-004](https://www.espressif.com/sites/default/files/advisory_downloads/AR2025-004_Security_Advisory_Follow-Up_Updates_and_Fixes_Regarding_ESP32_Undocumented_Bluetooth_Commands_en.pdf)
