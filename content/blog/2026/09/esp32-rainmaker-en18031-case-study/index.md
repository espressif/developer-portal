---
title: "A Case Study: Building an EN 18031-Compliant IoT Solution with ESP32-C5 and ESP RainMaker"
date: 2026-09-14
authors:
  - "esp-rainmaker-team"
tags:
  - ESP32-C5
  - ESP RainMaker
  - EN 18031
  - Security
  - IoT
summary: "This case study assesses device-to-cloud IoT implementation of products based on ESP32-C5 and ESP RainMaker against the EN 18031 security requirements for the EU market."
---
Espressif has completed the EN 18031 cybersecurity assessment for a device-to-cloud implementation based on the ESP32-C5-DevKitC-1 and ESP RainMaker, covering both EN 18031-1 (Cybersecurity) and EN 18031-2 (Privacy Protection). The assessment covers key compliance areas for consumer IoT devices and validates security mechanisms including secure firmware updates, encrypted communications, and user data management, providing a practical security and compliance reference for IoT products targeting the EU market.
## What Is EN 18031?

[EN 18031](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=OJ%3AL_202500138) is a set of cybersecurity standards supporting the EU Radio Equipment Directive (RED) 2014/53/EU. The requirements became mandatory on August 1, 2025, and applicable connected radio equipment placed on the EU market must meet the relevant requirements.

The EN 18031 series consists of three parts:

- **EN 18031-1** focuses on cybersecurity requirements for internet-connected radio equipment.
- **EN 18031-2** addresses privacy protection requirements for radio equipment that processes personal data.
- **EN 18031-3** addresses security requirements for radio equipment involved in financial transactions.

Compared with the general requirements set out in the RED, EN 18031 translates these regulatory requirements into specific, verifiable technical requirements and assessment methods. Manufacturers can use the applicable EN 18031 standard to guide security design, conduct risk assessments, and perform conformity assessments to ensure that their products meet the relevant cybersecurity requirements.
## What Do Manufacturers Need to Prepare?

For wireless products targeting the EU market, manufacturers need to first determine which EN 18031 requirements apply based on the product's connectivity, data processing, and functionality, and then conduct a product risk assessment. The next steps include designing and implementing security mechanisms such as access control, authentication, secure updates, secure storage, secure communications, cryptographic protection, and data deletion, while preparing the technical documentation and test evidence needed to demonstrate compliance.

Manufacturers must then select the appropriate conformity assessment route, which may involve self-assessment or assessment by a notified body, depending on the product and its implementation. The required [compliance documentation](/blog/2025/04/esp32-red-da-en18031-compliance-guide/#documentation-requirements) must also be prepared, including the Declaration of Conformity.

As a result, EN 18031 compliance involves multiple stages, from product design and risk assessment to security implementation, documentation, testing, and conformity assessment. Planning for these requirements early in the product development process can help avoid additional work later in the certification process.
## How ESP32-C5 and ESP RainMaker Address EN 18031 Requirements

The security mechanisms are achieved by a combination of ESP32-C5's hardware and device-level security capabilities and ESP RainMaker's device management and cloud security features. For example, for secure firmware updates, ESP32-C5 provides device-side security mechanisms such as Secure Boot, while ESP RainMaker uses Signed OTA to support firmware signing and OTA update management. For device-to-cloud communications, ESP32-C5's cryptographic capabilities work together with ESP RainMaker's TLS-based device authentication and encrypted communication mechanisms to establish a secure communication channel.

The following table maps selected EN 18031 security requirements to the corresponding ESP32-C5 device-side capabilities and ESP RainMaker cloud-side features.
| EN 18031 Security Requirement | Device-Side Capabilities | ESP RainMaker Capabilities |
| --- | --- | --- |
| **Secure Update** | Secure Boot verifies the authenticity of software before execution and helps establish a trusted firmware execution chain. | Secure OTA management, with OTA jobs delivered through encrypted channels and firmware downloaded over HTTPS. Supports signed firmware verification and rollback protection. |
| **Secure Communication** | ESP32-C5 provides cryptographic capabilities that support authenticated and encrypted device communications. | Mutually authenticated TLS communication using X.509 certificates, with encrypted device provisioning and PoP verification. |
| **Secure Storage** | eFUSE securely stores security keys and can prevent software readout. Flash Encryption protects data stored in external SPI Flash. | RainMaker Agent uses NVS Encryption to securely store sensitive data such as Wi-Fi credentials and device configuration. Each device has a unique key-certificate pair stored in a protected Manufacturing partition. |
| **Data Deletion** | Device-side handling and deletion of security assets can be implemented according to product requirements. | Account and device data management, supporting OTP-verified account deletion and deletion of nodes and associated cloud data. |
| **User Notification (P\*)** | Security- or privacy-related notifications may be implemented at the device or application level, depending on the product design. | Real-time event notifications for device status changes, node management events, sharing requests, and alerts. |
| **Logging (P\*)** | Device logging can record system and security-relevant events for monitoring and troubleshooting. | Remote diagnostics and log collection through ESP Insights, including error logs, warnings, crash data, reboot information, and custom events. |

**P\***: The applicability of User Notification and Logging depends on the design and functionality of the final product. Manufacturers should evaluate whether these requirements apply to their specific product and implementation.

The assessment covers not only the ESP32-C5-DevKitC-1, but also applies to the ESP32-C3-DevKitC-1 and ESP32-C6-DevKitC-1, which use the same security architecture.

## What This Means for Customers Targeting the EU Market

For manufacturers targeting the EU market, ESP RainMaker provides ready-to-use cloud security capabilities, so developers do not need to build mechanisms such as OTA signature verification, TLS communications, data deletion, and privacy notifications from scratch. Instead, they can build on these existing platform capabilities as part of their product development and compliance preparation.

While the final product must still undergo its own RED conformity assessment, manufacturers can use the device-to-cloud security mechanisms evaluated in this assessment as a reference when designing products based on ESP32-C5 and ESP RainMaker. This can help reduce duplicated security design and testing efforts and improve the efficiency of the overall compliance process.

## Further Reading

For more information about Espressif’s security, encryption, and cloud software solutions, please refer to:

- [Espressif Product Security](https://docs.espressif.com/projects/esp-product-security/en/latest/index.html)
- [Espressif Security Frameworks](https://docs.espressif.com/projects/esp-product-security/en/latest/security-frameworks.html)
- [ESP RainMaker](https://rainmaker.espressif.com/en)