---
title: "Overview of the EU Cyber Resilience Act"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 4
showAuthor: false
---

## What do you need to know about the new rules in Europe

[Regulation (EU) 2024/2847](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120), the Cyber Resilience Act (CRA), sets mandatory cybersecurity rules for products with digital elements on the EU market. That covers typical ESP32 designs: connected appliances, sensors, gateways, wearables, device firmware, companion apps, and cloud services sold as part of the product.

Espressif’s Developer Portal CRA series goes deeper than this lecture. Read [Understanding the EU Cyber Resilience Act (CRA)](https://developer.espressif.com/blog/2026/03/esp32-cra-compliance/) first, then [EU Cyber Resilience Act: Vulnerability Reporting Obligations](https://developer.espressif.com/blog/2026/09/esp32-cra-obligations-and-deadlines/). If your product already falls under the RED Delegated Act, use [ESP32 RED DA / EN 18031 Compliance Guide](https://developer.espressif.com/blog/2025/04/esp32-red-da-en18031-compliance-guide/) alongside the CRA material.

> [!NOTE]
> This workshop is technical education, not legal advice. Finishing the labs does not make a product CRA-compliant. The manufacturer of the product placed on the market owns the risk assessment, technical file, and lifecycle processes.

## Learning objectives

- Say which products the CRA covers and how that maps to ESP32-based designs
- Recall the September 2026 and December 2027 deadlines and what each triggers
- Tell Annex I Part I (design-time security) from Part II (vulnerability handling)
- Link workshop labs to artifacts you might keep for a gap analysis or technical file

## Scope and who is responsible

Medical, automotive, aviation, and other sector rules can exempt or overlap with the CRA. Confirm your product category with qualified counsel.

Economic operators (manufacturer, importer, distributor) each have defined duties. The manufacturer is normally whoever places the product on the EU market under their name or trademark. Re-branding does not shift liability: the name on the box owns the obligations. See the FAQ in the [vulnerability reporting article](https://developer.espressif.com/blog/2026/09/esp32-cra-obligations-and-deadlines/#frequently-asked-questions-faq).

## Key dates

The CRA entered into force on 10 December 2024. For ESP32 OEMs, two dates usually drive the plan:

| Date | What starts | Practical note |
|------|-------------|----------------|
| 11 September 2026 | [Article 14](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120#art_14) reporting via the ENISA Single Reporting Platform | In-scope products already on the EU market, not only new SKUs |
| 11 December 2027 | Essential requirements, conformity assessment, CE marking under the CRA | Units placed on the market from this date; see Art. 69(2) for substantial modifications |

Timeline figures and context: [CRA overview](https://developer.espressif.com/blog/2026/03/esp32-cra-compliance/#cra-timeline), [reporting obligations](https://developer.espressif.com/blog/2026/09/esp32-cra-obligations-and-deadlines/).

The overview FAQ cites a minimum five-year security update period unless you document and communicate a shorter support window to buyers.

## Essential cybersecurity requirements

[Annex I Part I](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120#anx_I) covers design and development. Provisioning, update policy, documentation, and post-market handling count alongside firmware features.

Espressif’s [summary of Part I](https://developer.espressif.com/blog/2026/03/esp32-cra-compliance/#essential-cra-requirements) groups the themes as:

- Secure-by-design and secure-by-default development
- Product-level cybersecurity risk assessment
- Protection against unauthorized access and misuse
- Secure update mechanisms
- Data protection and minimization where relevant
- Logging and monitoring where relevant
- Transparency (security documentation and user instructions)

Secure Boot, encryption, and TLS in this workshop address parts of that list. Signed OTA belongs in your product plan; the optional [Assignment 5](../assignment-5) shows it with app rollback. Anti-rollback is referenced here for CRA mapping but is not a hands-on lab in this course. You still own the product risk assessment and the technical file that ties controls to requirements.

## Vulnerability handling and reporting

[Annex I Part II](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120#anx_I) covers vulnerability management for the declared support period.

Reportable conditions under the CRA (see the [overview article](https://developer.espressif.com/blog/2026/03/esp32-cra-compliance/#essential-cra-requirements)):

- Actively exploited vulnerability in the product
- Severe incident with significant impact on the product or its users

When thresholds are met, manufacturers coordinate disclosure, notify users, ship fixes, and report through the [ENISA Single Reporting Platform (SRP)](https://www.enisa.europa.eu/topics/product-security/single-reporting-platform-srp). Notification timelines appear in the overview article reporting table.

Espressif’s side of the stack is described in [Staying Ahead with ESP32 Security Updates](https://developer.espressif.com/blog/2026/03/esp32-security-updates/): advisories, the [ESP-IDF Security Dashboard](https://espressif.github.io/esp-idf-security-dashboard/), [esp-idf-sbom](https://github.com/espressif/esp-idf-sbom), LTS branches, and secure OTA. You still track impact on your firmware, deploy patches, and file CRA reports when your product triggers Article 14.

## Conformity assessment (overview)

Under the full CRA regime, manufacturers usually:

1. Classify the product (default, Important Class I or II, or critical) using [Annex III and IV](https://developer.espressif.com/blog/2026/03/esp32-cra-compliance/#cra-compliance-process). Many ESP32 IoT devices land in default or Important Class I depending on function and risk.
2. Run the risk assessment, implement measures, write technical documentation, sign an EU Declaration of Conformity, and apply CE marking. Some classes need a Notified Body.
3. Keep post-market duties: monitor vulnerabilities, ship updates, and report under Article 14 when required.

Class diagrams and step detail: [CRA compliance process](https://developer.espressif.com/blog/2026/03/esp32-cra-compliance/#cra-compliance-process).

## From workshop controls to CRA evidence

The labs do not finish conformity assessment. They produce testable artifacts for themes that often appear in gap analysis and technical documentation.

| Workshop topic | Typical CRA-related theme | What you might retain as evidence |
|----------------|---------------------------|-----------------------------------|
| Secure Boot V2 | Integrity, unauthorized firmware | Configuration, signing policy, boot logs, rejection tests |
| Flash encryption | Confidentiality of stored data | Encryption mode, offline read test results |
| HMAC-based NVS encryption | Credentials and configuration at rest | Partition layout, provisioning record, NVS read tests |
| TLS | Protection in transit, authentication | Trust store policy, test results, cipher configuration |
| Secure OTA (optional Assignment 5) and anti-rollback (not a workshop lab) | Secure updates, rollback prevention | Signed image workflow, version policy, failed downgrade test; see appendix and ESP-IDF |
Platform features (secure boot, flash encryption, eFuse keys, ESP-IDF patches, OTA, SBOM tools) are listed in Espressif’s [CRA overview](https://developer.espressif.com/blog/2026/03/esp32-cra-compliance/#how-espressif-will-support-oem-customers-for-cra-compliance) and [Product Security](https://docs.espressif.com/projects/esp-product-security/en/latest/) docs. The [reporting FAQ](https://developer.espressif.com/blog/2026/09/esp32-cra-obligations-and-deadlines/#frequently-asked-questions-faq) states plainly: no API or SoC is “CRA-compliant” by itself; compliance belongs to the finished product.

## Developer Portal reading list

| Resource | Focus |
|----------|--------|
| [Understanding the EU Cyber Resilience Act (CRA)](https://developer.espressif.com/blog/2026/03/esp32-cra-compliance/) | Scope, timeline, Annex I, conformity process, platform support |
| [EU Cyber Resilience Act: Vulnerability Reporting Obligations](https://developer.espressif.com/blog/2026/09/esp32-cra-obligations-and-deadlines/) | Article 14, SRP, products already on market, OEM FAQ |
| [ESP32 RED DA / EN 18031 Compliance Guide](https://developer.espressif.com/blog/2025/04/esp32-red-da-en18031-compliance-guide/) | Radio equipment before full CRA application |
| [Staying Ahead with ESP32 Security Updates](https://developer.espressif.com/blog/2026/03/esp32-security-updates/) | Dashboard, SBOM, LTS, OTA |
| [Software Bill of Materials](https://developer.espressif.com/blog/software-bill-of-materials/) | SBOM generation and dependency tracking |

EU primary sources: [Regulation (EU) 2024/2847](https://eur-lex.europa.eu/eli/reg/2024/2847/oj/eng), [Commission CRA policy](https://digital-strategy.ec.europa.eu/en/policies/cyber-resilience-act), [CRA implementation FAQ](https://digital-strategy.ec.europa.eu/en/library/cyber-resilience-act-implementation-frequently-asked-questions).

## Previous and next steps

[Previous: Overview of the security features on the ESP32-S31](../overview-security-features)

[Next: Lecture 1: TLS for secure communication](../lecture-1)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
