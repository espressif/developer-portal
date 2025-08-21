---
title: "RED DA Compliance (Part 2): Espressif’s Platform Support, Templates, and Pathways for Conformity"
date: 2025-07-09
showAuthor: false
authors:
  - anant-raj-gupta
  - sachin-billore
tags:
  - Security
  - IoT
  - ESP-IDF
  - ESP32
summary: Espressif is streamlining RED Delegated Act (RED-DA) compliance by providing pre-certified firmware platforms, documentation templates, and partner support to help developers meet the upcoming EN 18031 standard. With flexible pathways including self-declaration and third-party assessments, developers can accelerate EU market readiness for Aug 2025 and beyond.
---

## Introduction

In [Part 1 of this series](https://developer.espressif.com/blog/2025/04/esp32-red-da-en18031-compliance-guide/), we introduced the upcoming requirements of the **RED Delegated Act (DA)** and the associated harmonized standard **EN 18031**, which comes into effect in **August 2025**. These new obligations place a strong emphasis on **cybersecurity, privacy, and protection against network abuse** for all radio-connected products entering the European market.

With the compliance deadline drawing closer, Espressif is taking proactive steps to simplify and accelerate the path to RED DA compliance for developers building with our chipsets and modules.

---

## Documentation Templates – Foundation for Compliance

To further assist customers, we have prepared technical document templates for the ESP32 series of SoCs. These templates are intended to assist manufacturers in preparing RED-DA self-assessment compliance documentation for products based on the ESP32 series of SoCs.

These templates are being developed in close collaboration with **[Brightsight](https://www.brightsight.com/)** to ensure they meet the expectations of **Notified Bodies**, **Market Surveillance Authorities**, and **Approved Testing Labs (ATLs)**.

### What’s Included in the Templates?

**Base conformance documentation templates** include:

- **Product Risk Assessment :** This document outlines the identified security risks related to Article 3.3(d) of the RED Delegated Act, specifically concerning network harm.
- **Applicable EN 18031 Standards :** This document details how the product meets the security requirements defined in the harmonized standard EN 18031-1.
- **Declaration of Conformity :** This is a template that manufacturers can use to declare their product compliance with the RED Delegated Act through the self-assessment route.
- **Technical Specifications :** Details about the product design and features. This is a product-specific document.

These templates are intended to be used as a **starting point**, allowing product makers to significantly reduce time and effort in preparing RED DA compliance documentation.

---

## Compliance Pathways: Choose the Approach That Fits Your Product

With Espressif’s platform support and draft templates, you now have **three practical paths** to achieve RED DA compliance, depending on your product complexity, internal expertise, and certification strategy.

### **1. Self-Declaration Using Espressif Templates**

For customers using Espressif firmware stacks with minimal customization:

* You can adapt the provided documentation templates for your specific product.
* Complete a **self-assessment** and issue a **Declaration of Conformity (DoC)**.
* Suitable for devices not under the restricted list and companies confident in handling regulatory documentation.

### **2. Consultancy-Assisted Self-Declaration**

If additional guidance is needed:

* Work with a **security consultancy** to update the templates, fill any gaps, and validate your conformity documentation.
* You remain responsible for issuing the final DoC, but with confidence that expert support has verified your assumptions.

### **3. Full Conformity Assessment via ATL or Notified Body**

For products with:

* Products which will fall under the restricted list as defined in the standard
* Custom security models
* Mandatory for a certain device types
* Demanding Market segments

Engaging an **Approved Testing Laboratory (ATL)** or **Notified Body** allows a formal third-party evaluation to issue an **attestation of conformity**, which can carry more weight during audits or market checks.

---

## Recommended Partners for Compliance

While Espressif will try to facilitate maximum support for our customers to achieve the RED DA conformance, we understand that some customers may need further professional assistance. In order to facilitate this, Espressif will continue to work with other companies to provide a streamlined solution. At present, Espressif has established following partnerships that customers can take advantage of.

### 🔸 [**Brightsight**](https://www.brightsight.com/)
{{< figure default=true src="img/brightsight-logo.webp" >}}
* Services: End-to-end RED DA conformity assessment (ATL), documentation advisory, vulnerability analysis
* Role: Espressif’s direct partner for preparing reference documentation and platform-level conformance

### 🔸 [**CyberWhiz**](https://www.cyberwhiz.co.uk/)
{{< figure default=true src="img/cyberwhiz-logo.webp" >}}
* Services: RED DA consultancy and documentation preparation
* Role: Independent consultancy specialized in embedded systems and EU compliance

> If you need introductions or referrals to either of these partners, contact us via **[sales@espressif.com](mailto:sales@espressif.com)**.

---

## Espressif's Compliance Coverage: What We Will Support

Espressif will complete the full RED DA conformance and provide the related reports and documentation for firmware platforms where Espressif is the primary maintainer and software publisher. These include:

### ✅ **[ESP-AT](https://docs.espressif.com/projects/esp-at/en/release-v2.2.0.0_esp8266/index.html)**

Our AT command firmware for Wi-Fi and Bluetooth connectivity modules, widely used in embedded products along with a Host MCU.

### ✅ **[ESP-ZeroCode](https://zerocode.espressif.com/)**

An out-of-the-box complete solution with predefined features for fast time-to-market, currently supporting varied Matter devices applications.

### ✅ **[Espressif's AWS IoT ExpressLink](https://www.espressif.com/en/solutions/device-connectivity/esp-aws-iot-expresslink)**

The pre-provisioned, pre-programmed connectivity modules with AWS qualified  firmware for AWS IoT core integration, for secure and reliable device onboarding.

For these platforms, Espressif is undergoing formal conformance activities based on the **EN 18031** template supplied by **Brightsight**, a globally recognized security laboratory and Notified Body via SGS Fimko. This conformance is focused on ensuring compliance with the EN 18031 standard.

> **Key Benefit:** When you build your product on top of these firmware platforms which does not include changes to the network stack, you inherit a significant portion of Espressif’s RED DA conformance. The final product compliance is still dependent on the complete application.

---

## What to Expect Next

Espressif is currently finalizing draft templates and internal reviews for each supported firmware platform as listed above and ESP32 series SoCs. Over the coming weeks:

* We will provide **documentation packages** for each firmware platform and ESP32 series SoCs via [***sales@espressif.com***](mailto:sales@espressif.com). We are also evaluating other channels for publication.
* Platform-specific **guiding document** will accompany the templates to assist in completion.
* We will host a **webinar** with Brightsight to walk through the documentation and answer developer questions.

We encourage all customers targeting the EU market to start evaluating their RED DA readiness now, especially if product releases are planned for late 2025 or beyond.

---

## Stay Informed

Espressif remains committed to providing **transparent, practical, and secure** solutions to meet evolving regulatory and market needs. If you have questions about RED DA, documentation needs, or how to engage with our compliance partners, please reach out to us.

- 🌐 [Espressif Developer Portal](https://developer.espressif.com)
- 📚 [RED DA Part 1 Blog](https://developer.espressif.com/blog/2025/04/esp32-red-da-en18031-compliance-guide/)

---

## Updates

**August 2025:** [Preparing for RED DA (EN 18031) Compliance](https://www.youtube.com/watch?v=j-qSfqoy_Wg) - Watch our recorded webinar with Brightsight covering RED DA compliance requirements and implementation guidance.
