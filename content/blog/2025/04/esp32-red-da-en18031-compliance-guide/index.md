---
title: "RED DA (EN 18031) Certification Compliance: What You Need to Know"
date: 2025-04-08
showAuthor: false
authors:
  - sachin-billore
  - mahavir-jain
tags:
  - Security
  - IoT
  - ESP-IDF
  - ESP32
summary: This guide helps manufacturers of wireless-enabled products based on Espressif modules understand the RED DA (EN 18031) cybersecurity requirements, identify their product’s category, and determine the right path to certification before launching in the EU market.
---

## Introduction

The European Union’s **Radio Equipment Directive (RED) 2014/53/EU** ensures that all radio equipment placed on the EU market meets essential requirements for safety, health, electromagnetic compatibility, and efficient spectrum use. As part of its ongoing evolution, the directive now includes the **Delegated Act (DA) on Cybersecurity (EN 18031)**, which introduces new cybersecurity requirements for radio equipment.

For manufacturers, system integrators, and developers — whether they have an extensive security background or not — understanding and implementing these requirements is crucial to ensuring continued market access. This article provides a structured approach to help companies assess their compliance position and identify the necessary steps for certification.

## What is RED DA?

The **RED Delegated Act (DA) on Cybersecurity (EN 18031)** is an extension of the EU’s Radio Equipment Directive (RED) 2014/53/EU. It introduces mandatory cybersecurity requirements for wirelessly connected products sold in the EU market. Product manufacturers who were previously RED-compliant must now reassess their products to meet RED DA requirements by **August 1, 2025**.

## RED DA Cybersecurity Requirements

Three main cybersecurity requirements were added as part of the RED DA under Article 3(3):

- **Article 3(3)(d):** Protection of network connections. This entails implementing secure network connections, robust authentication mechanisms, and protection against unauthorized access.
- **Article 3(3)(e):** Protection of personal data and user privacy. This entails proper data encryption, secure data storage, and user consent mechanisms to safeguard personal data and privacy.
- **Article 3(3)(f):** Protection against financial fraud. This involves preventing fraud via secure payment interfaces and transaction verification mechanisms.

## EN 18031 as Harmonised Standards

To assist end-product manufacturers in meeting regulatory expectations, harmonized standards have been developed to translate legal requirements into actionable technical guidance. These standards provide technical details and solutions to meet the regulations. When manufacturers comply with these standards, they benefit from a "presumption of conformity," meaning authorities automatically recognize compliance.

On January 28, 2025, the European Commission published references to [the three harmonized EN 18031 standards](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=OJ:L_202500138), with restrictions, in the Official Journal of the European Union (OJEU).

Each EN 18031 standard directly corresponds to its matching RED DA Article:

- **EN 18031-1:2024**: Covers security requirements for internet-connected radio equipment.
- **EN 18031-2:2024**: Covers requirements for equipment that processes personal data.
- **EN 18031-3:2024**: Covers requirements for equipment that enables financial transactions.

## What Does This Mean for Product Manufacturers?

If you are a manufacturer selling wireless-enabled products in the EU, you must ensure RED DA compliance. This applies to:

- New product launches after August 1, 2025.
- Existing products that undergo significant updates affecting security.
- End-product manufacturers using pre-certified wireless modules still need to ensure full system compliance.

RED DA obligations depend on a product's status at the time the rules take effect:

- Any product not placed on the EU market by August 1, 2025, must comply with the RED DA.
- Products already shipped to distributors or available for purchase before August 1, 2025 are considered placed on the market and are not subject to RED DA retroactively.
- However, if a product receives security-relevant updates after August 1, 2025, it may be considered a new product and require reassessment under RED DA.

### Does EN 18031 Certification Apply to Modules or End Products? 

EN 18031 certification applies to complete internet-connected radio equipment, not individual modules. While modules like those from Espressif serve as essential building blocks of end products, they can be independently certified, but such certification alone is not sufficient to demonstrate RED DA compliance for the final product.

**The responsibility for RED DA compliance lies with the manufacturer of the final product.** Even when a secure, pre-certified module is used, the overall end product must be evaluated as a whole to verify it meets the EN 18031 requirements.

In short, using a secure module supports compliance but does not replace the need for end-product certification.

## RED DA Compliance Process

Manufacturers have two paths to comply with RED DA cybersecurity requirements:

### Self-Assessment Process

Self-assessment allows manufacturers to evaluate compliance by themselves. This approach has several benefits:

- It is cost-effective, with no third-party fees.
- It saves time by avoiding external review processes.
- It gives manufacturers more control over the compliance process.

To use self-assessment, manufacturers must:

- Ensure their products fully meet all applicable EN 18031 requirements.
- Create thorough technical documentation that demonstrates how each EN 18031 requirement is met.
- Generate a self-signed Declaration of Conformity.
- No further action is required, and documentation must be kept ready for inspection by market surveillance authorities if requested.

### Notified Body Assessment Process

The other option is to work with Notified Bodies to assess your compliance. Notified Bodies are independent organizations authorized by EU member states to evaluate whether products meet the requirements.
This option becomes mandatory if a product follows the EN 18031 standards but makes exceptions for certain requirements. Scenarios that require Notified Body involvement include:

- If a product requires a password for access, sections 6.2.5.1 and 6.2.5.2 of EN 18031-1/2/3 specify how passwords should be managed. However, if users **can choose not to set a password**, the product does not comply with RED DA, even if it follows the harmonized standard.

- Standard EN 18031-2 (sections 6.1.3 to 6.1.6) outlines four access control mechanisms for toys and childcare products. Some of these methods **may not be compatible with parental or guardian controls**. In such cases, adherence to the EN 18031 harmonized standard alone does not ensure compliance with RED DA.

- Standard EN 18031-3 (section 6.3.2.4) describes secure update mechanisms. It defines four implementation categories: digital signatures, secure communication, access control, and others. **None of these methods alone is sufficient** for handling financial assets. The criteria do not fully address authentication risks and therefore cannot ensure compliance with RED DA.

The Notified Body will:

- Review technical documentation.
- Evaluate the product against RED DA requirements.
- Conduct additional tests, if needed, to verify compliance.
- Issue a formal compliance certificate if all requirements are met.

## Documentation Requirements

To comply with RED DA regulations, manufacturers must prepare and maintain the following documents:

- **Technical Specifications**: Details about the product design and features.
- **Product Risk Assessment**: List of identified risks and mitigation plans.
- **Applicable EN 18031 Standards**: List of standards applied to the product.
- **Declaration of Conformity**: Official statement of compliance.

**For self-assessment:**

- The end-product manufacturer self-signs Declaration of Conformity.

**For Notified Body assessment:**

- The end-product manufacturer prepares technical documentation.
- The Notified Body issues a Declaration of Conformity.

## End-product Manufacturer Responsibilities

End-product manufacturers are expected to follow these key requirements:

- Prepare all compliance documentation before placing products on the market.
- Keep documentation available for 10 years after the product is introduced to the market.
- Ensure the manufacturing process continues to maintain compliance.
- Affix the CE marking to compliant products.

> Market surveillance authorities may request compliance documentation at any time, even after a product is on the market. Manufacturers must provide these documents promptly upon request. Failure to comply with RED DA requirements can result in re-certification through a Notified Body, penalties, or even product recalls in certain cases.

## Espressif Module Compliance

Espressif’s SoCs have all the necessary hardware security capabilities to support compliance with RED DA requirements.

- We provide a detailed [Security Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/security/index.html) to help manufacturers implement security features in their products.
- The official firmware, with all recommended platform security features enabled, meets the cybersecurity requirements of RED DA.

However, some requirements depend on the design of the final product built on Espressif SoCs.

The table below outlines the EN 18031 cybersecurity requirement categories and how they are addressed by the EN 18031 standards and Espressif’s platform:

### RED DA Compliance Mapping Table

| **ID¹** | **Requirement** | **EN 18031-1** | **EN 18031-2** | **EN 18031-3** | **ESP Support²** |
|---------|-----------------|----------------|----------------|----------------|------------------|
| **ACM** | **Access Control** – Ensures that security assets are accessible only to authorized users. | Y | Y | Y | :white_check_mark: |
| **AUM** | **Authentication** – Device shall authenticate users or external entities before granting access to security assets. | Y | Y | Y | :white_check_mark: |
| **SUM** | **Secure Update** – Device shall perform secure and verified update of firmware and software. | Y | Y | Y | :white_check_mark: |
| **SSM** | **Secure Storage** – Device shall securely store security assets and protect them from unauthorized access. | Y | Y | Y | :white_check_mark: |
| **SCM** | **Secure Communication** – Device shall use secure communication for communicating security and network assets with other entities via network interfaces. | Y | Y | Y | :white_check_mark: |
| **CCK** | **Confidential Cryptographic** – Device shall protect confidentiality of cryptographic material and operations. | Y | Y | Y | :white_check_mark: |
| **GEC** | **General Equipment Capabilities** – Device shall support hardware or software capabilities for security requirements. | Y | Y | Y | :white_check_mark: |
| **CRY** | **Cryptography** – Device shall implement best practice cryptographic algorithms to protect security assets and communication. | Y | Y | Y | :white_check_mark: |
| **DLM** | **Deletion** – Device shall provide the option to delete security assets and user personal data in a secure and irreversible manner. | - | Y | - | :white_check_mark: |
| **LGM** | **Logging** – Device shall record logs of security events for monitoring and audit purposes. | - | Y | Y | **P** |
| **RLM** | **Resilience** – Device shall maintain secure behavior during faults, attacks, or disruptions. | Y | - | - | **P** |
| **NMM** | **Network Monitoring** – Device shall monitor network interfaces to detect and respond to security events. | Y | - | - | **P** |
| **TCM** | **Traffic Control** – Device shall control and filter network traffic to protect security assets. | Y | - | - | **P** |
| **UNM** | **User Notification** – Device shall notify users about security events or changes in security posture. | - | Y | - | **P** |

> **¹ ID denotes the cybersecurity requirement categories as defined in the EN 18031 standard.**\
> **² 'P' in this column indicates that the applicability of the requirement depends on the final end product design.**

## Frequently Asked Questions (FAQs)

**Q1: Does EN 18031 apply to Espressif connectivity modules or end products?**\
**A:** Although Espressif connectivity modules are themselves components, the end-product manufacturer holds the final responsibility for compliance. If an Espressif module is used in a product with its default firmware and security settings, the final product may still require separate certification to confirm compliance.

**Q2: What if the product developer has no security background?**\
**A:** Developers with no cybersecurity background should consider working with external security consultants or labs and leveraging Espressif’s guidance to meet the requirements.

**Q3: Does RED DA compliance require third-party certification?**\
**A**: Not necessarily. In many cases, self-assessment is sufficient, but certain exceptions do require certification by a Notified Body, which means involving third-party labs.

**Q4: What happens if self-assessment documents are inadequate?**\
**A**: If self-assessment documentation is found to be inadequate, regulatory authorities may request additional proof or corrections. This situation could result in penalties in cases of non-conformance

**Q5: Who can request compliance documentation?**\
**A**: Market surveillance authorities, regulatory bodies, or even distributors may request to review these documents.

**Q6: In a two-chip architecture (host MCU + separate Wi-Fi/Bluetooth module), who is responsible for RED DA compliance?**\
**A**: In a two-chip design, the end-product manufacturer is ultimately responsible for ensuring the entire system complies with RED DA. Even if the wireless connectivity module (e.g., an ESP32-based module) has its own security features or certifications, the final combined device (host MCU + module) must, as a whole, meet EN 18031 requirements. If the host MCU manages security credentials and controls the wireless connectivity module, its role must be evaluated as part of the overall RED DA compliance of the end product to ensure the entire system meets security requirements.

**Q7: What if Espressif manages the entire firmware and security configuration (e.g., ESP-Zerocode)?**\
**A**: In such cases, where Espressif provides the complete firmware and security configuration, Espressif assumes the responsibility for RED DA compliance of the module. The end-product manufacturer must still ensure that no changes compromise the end product certified configuration.

## Summary

RED DA (EN 18031) compliance presents both challenges and opportunities for IoT manufacturers. By leveraging Espressif's secure Wi-Fi modules and expertise, product developers can achieve compliance faster and more cost-effectively. Espressif is fully committed to supporting manufacturers in achieving RED DA compliance. We can help with:

- Technical guidance on security implementation
- Pre-filled compliance documentation templates from the platform perspective

For assistance, please reach out to us at **[sales@espressif.com](mailto:sales@espressif.com)**.

Stay informed and ensure your devices meet the latest regulatory standards to avoid market disruptions. Plan ahead for RED DA compliance!
