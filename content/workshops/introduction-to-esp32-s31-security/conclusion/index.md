---
title: "Introduction to the ESP32-S31: Security - Conclusion"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 14
showAuthor: false
---

## Conclusion

This workshop has connected ESP32-S31 security controls to the security objectives of a connected product and to selected technical concerns raised by the EU Cyber Resilience Act.

## What you learned

After completing the finished workshop, you will have:

- Reviewed the ESP32-S31 architecture and security capabilities
- Distinguished SoC security features from product-level CRA compliance
- Protected data in transit with TLS
- Configured HMAC-based NVS encryption with a real HMAC key generated on the SoC at first boot
- Walked through Secure Boot V2 signing and verification with virtual eFuses
- Exercised flash encryption flows in virtual eFuse mode (with known limits vs production)
- Optionally, added signed HTTPS OTA updates with app rollback (Assignment 5)
- Observed the instructor-led **TLS power consumption** Otii demo at the end of Assignment 1 (when offered)

## Classroom vs production

| Topic | In the workshop | On the manufacturing line |
|-------|-----------------|---------------------------|
| eFuses | Virtual (`CONFIG_EFUSE_VIRTUAL`), except the HMAC key block | Real burns per enablement workflow |
| Secure Boot | Emulated digests and enable | Hardware `SECURE_BOOT_EN` |
| Flash encryption | Virtual development simulation | Real keys and release policy |
| HMAC NVS | Real `HMAC_UP` block, key generated on the SoC | Pre-burned or first-boot key, block recorded per device |

Production provisioning and anti-rollback are documented in the [production provisioning appendix](../appendix-production-provisioning). Signed OTA with app rollback is covered in the optional [Assignment 5](../assignment-5).

## Security-control recap

| Control | Protected assets | Security property | How you verified it | Depends on | Residual risk |
|---------|------------------|-------------------|---------------------|------------|---------------|
| TLS ([Assignment 1](../assignment-1)) | Data exchanged with the server, server identity | Confidentiality and integrity in transit, server authentication | `Certificate verified.`; wrong-hostname and untrusted-server tests fail | An up-to-date CA bundle, correct device time | Aging CA bundle; the server does not authenticate the device unless you add mutual TLS |
| HMAC-based NVS encryption ([Assignment 2](../assignment-2)) | Wi-Fi credentials and configuration in NVS | Confidentiality at rest | Raw NVS dump shows no plaintext credentials | `HMAC_UP` key in a real eFuse block | Data outside NVS is not covered; any code running on the device can still read NVS |
| Secure Boot V2 ([Assignment 3](../assignment-3)) | Bootloader and application images | Integrity and authenticity of firmware | Signature verified at boot; tampered or wrongly signed images rejected | Custody of the signing key, key digest in eFuse | A leaked signing key; in the lab the digest and `SECURE_BOOT_EN` are emulated |
| Flash encryption ([Assignment 4](../assignment-4)) | Code and data in external flash | Confidentiality against offline reads | First-boot flow logged; raw read explained (plaintext in virtual mode) | Release mode, encryption key in eFuse | Development mode keeps reflashing open; encryption at rest is not proven in the lab |
| Secure OTA ([Assignment 5](../assignment-5), optional) | The update path and the running firmware | Only authentic updates install; recovery from a bad update | Unsigned and wrongly signed images rejected; rollback test | Secure Boot signing key, OTA server identity | Downgrade to an older signed image is possible without anti-rollback |

Secure Boot, flash encryption, and secure OTA ran with virtual eFuses. The results show the configuration and the flows; production evidence has to come from devices provisioned with real eFuses.

## CRA-support mapping

Use this table as a starting template for the traceability part of your technical file. It links each product risk to an [Annex I](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120#anx_I) theme from the [EU CRA overview](../overview-eu-cra/#essential-cybersecurity-requirements), the control that addresses it, and the evidence and process that keep it working. Adapt the risks, owners, and evidence to your product and its risk assessment.

| Product risk | CRA theme | Design control | Implementation evidence | Test evidence | Lifecycle process | Typical owner |
|--------------|-----------|----------------|-------------------------|---------------|-------------------|---------------|
| Eavesdropping or a fake server | Protection of data in transit, protection against unauthorized access | TLS with server certificate verification | `sdkconfig` (certificate bundle, verification required), trust store policy | Successful handshake log; wrong-hostname and untrusted-server failures | CA bundle updates through firmware releases | Firmware lead |
| Credential theft from a lost or stolen device | Data protection at rest | HMAC-based NVS encryption | NVS configuration, partition table, eFuse key block record per device | Raw NVS dump without plaintext credentials | Provisioning record, key block plan | Firmware lead, manufacturing |
| Malicious or modified firmware | Protection against unauthorized access and misuse | Secure Boot V2 | Signing configuration, key digest record, signing procedure | Boot log with signature check; rejection of tampered and wrongly signed images | Signing key custody, rotation, and revocation plan | Security lead |
| Firmware or data extraction from flash | Confidentiality of stored data | Flash encryption in release mode | Flash encryption mode, `encrypted` partition flags | Flash dump shows ciphertext on a production device | Key generation on the device, factory provisioning procedure | Security lead, manufacturing |
| Known vulnerabilities stay in the field | Secure update mechanisms | Signed HTTPS OTA with app rollback, anti-rollback in production | OTA partition layout, rollback and secure version settings | Signed update installs; unsigned and wrongly signed updates rejected; rollback test; failed downgrade test | Release process, secure version policy, OTA server certificate rotation | Product owner, firmware lead |
| Vulnerabilities are not found or not handled | Vulnerability handling ([Annex I Part II](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120#anx_I)) | Not a firmware control: SBOM, monitoring of advisories, disclosure policy | SBOM (for example from [esp-idf-sbom](https://github.com/espressif/esp-idf-sbom)), disclosure policy | Records of advisories reviewed and fixes shipped | Coordinated disclosure, reporting through the ENISA Single Reporting Platform | Product owner, security lead |

> [!IMPORTANT]
> Successful completion of these exercises does not establish CRA conformity. A finished product also requires a documented risk assessment, secure defaults, vulnerability handling, update and support processes, technical documentation, conformity assessment, and fulfillment of all other applicable obligations.

## Production-readiness checklist

Use this list before moving from the workshop configuration to a product. The [production provisioning appendix](../appendix-production-provisioning) describes the manufacturing steps.

### Design and keys

- Product threat model and security requirements approved
- Production keys generated and protected outside source control
- Release images signed in a controlled environment, such as an offline machine or an HSM, never on developer laptops
- Signing-key rotation and revocation plan defined; unused Secure Boot digest slots revoked
- Anti-rollback secure version policy decided before the first release
- OTA server certificate issued by a CA you control or a public CA, with a plan to rotate it before it expires

### Manufacturing and device configuration

- Virtual eFuses off (`CONFIG_EFUSE_VIRTUAL` not set) in every release build
- Secure Boot enabled in real eFuses, and flash encryption in **release** mode
- eFuse key block plan recorded per device (HMAC, Secure Boot digest, flash encryption key)
- Partition table offset sized for the final bootloader, including Secure Boot, flash encryption, and anti-rollback
- UART download mode set to Secure or disabled, and JTAG disabled, according to policy
- Provisioning process controlled, logged, and tested
- Secure Boot, encryption, storage, TLS, and update controls verified on **production-provisioned** hardware

### Lifecycle and compliance

- Recovery and signing-key-compromise procedures tested
- Vulnerability disclosure and remediation processes operating
- Software bill of materials and third-party dependencies maintained
- Support period, update policy, and end-of-life process documented
- Compliance evidence reviewed by appropriate technical and legal experts

## Limitations and next steps

### Limits of the workshop

- Secure Boot, flash encryption, and secure OTA ran with virtual eFuses, so the labs show the flows but not the protection of a production device.
- Flash encryption ran in development mode only; release mode is described, not performed.
- There is no hands-on lab for bootloader OTA or anti-rollback.
- ESP32-S31 is a preview target in ESP-IDF v6.1. Check the documentation of your ESP-IDF release before you plan a product.

### Topics not covered

A complete product security program also needs work on:

- **Authorization and access control:** user roles, device pairing, and local or remote administration
- **Cloud and backend security:** device identity, provisioning to a cloud service, and companion apps
- **Physical security:** enclosure, debug headers, and tamper resistance
- **Radio and safety obligations**, such as the Radio Equipment Directive and [EN 18031](https://developer.espressif.com/blog/2025/04/esp32-red-da-en18031-compliance-guide/)
- **Manufacturing security:** factory network, key injection stations, and operator access
- **Penetration testing** by an independent team
- **Incident response:** detection, triage, user notification, and reporting
- **Conformity assessment:** product classification, Notified Body involvement, EU Declaration of Conformity, and CE marking

### Further reading

TODO: Add the link to the workshop source-code repository when it is published.

ESP-IDF documentation for ESP32-S31:

- [Security Overview](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security.html)
- [Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html)
- [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html)
- [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_encryption.html)
- [Over The Air Updates (OTA)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/ota.html)
- [Security Features Enablement Workflows](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html)

ESP-IDF examples used or referenced in the workshop:

- [`https_mbedtls`](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_mbedtls)
- [`nvs_encryption_hmac`](https://github.com/espressif/esp-idf/tree/master/examples/security/nvs_encryption_hmac)
- [`flash_encryption`](https://github.com/espressif/esp-idf/tree/master/examples/security/flash_encryption)
- [`simple_ota_example`](https://github.com/espressif/esp-idf/tree/master/examples/system/ota/simple_ota_example)

Product security and the CRA:

- [ESP Product Security](https://docs.espressif.com/projects/esp-product-security/en/latest/)
- [Understanding the EU Cyber Resilience Act (CRA)](https://developer.espressif.com/blog/2026/03/esp32-cra-compliance/)
- [EU Cyber Resilience Act: Vulnerability Reporting Obligations](https://developer.espressif.com/blog/2026/09/esp32-cra-obligations-and-deadlines/)
- [Staying Ahead with ESP32 Security Updates](https://developer.espressif.com/blog/2026/03/esp32-security-updates/)
- [Regulation (EU) 2024/2847](https://eur-lex.europa.eu/eli/reg/2024/2847/oj/eng) and the [Commission CRA policy page](https://digital-strategy.ec.europa.eu/en/policies/cyber-resilience-act)

## Previous step

[Previous: Assignment 5 (optional)](../assignment-5) or [Assignment 4](../assignment-4)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
