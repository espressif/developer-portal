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
- Protected data in transit with TLS on the ESP32-S31-Function-CoreBoard-1
- Built production firmware with no development options and ran it in the [ESP32 emulator](https://espressif.github.io/esp-emulator/), so every eFuse burn happened on an emulated chip instead of your board
- Encrypted NVS with an HMAC key that the SoC generates and burns on first boot
- Enabled Secure Boot V2 with an RSA signing key, and watched the bootloader burn the key digest and disable ROM download mode and JTAG
- Enabled flash encryption in release mode, protected the NVS keys with flash encryption, and confirmed that raw flash reads return ciphertext
- Learned why the order of eFuse burns matters in production: an HMAC key has to be burned before Secure Boot or flash encryption runs
- Optionally, added signed HTTPS OTA updates with app rollback ([Assignment 5](../assignment-5))
- Optionally, provisioned a real board with the same image ([real-board appendix](../appendix-production-provisioning))
- Observed the instructor-led **TLS power consumption** Otii demo at the end of Assignment 1 (when offered)

## Emulator vs production device

Assignments 2 to 4 used the same production configuration you would ship. What differs is where the eFuses live:

| Topic | In the emulator | On a production device |
|-------|-----------------|------------------------|
| eFuses | Burned in emulator memory, blank again after a page reload | Burned in silicon, permanent |
| Secure Boot V2 | Real ROM and bootloader verification, digest in emulated `BLOCK_KEY0` | Same flow, digest in real `BLOCK_KEY0` |
| Flash encryption | Release mode, flash really encrypted in emulated flash | Release mode, flash encrypted with a key only the chip can use |
| NVS encryption | HMAC key generated on first boot (Assignment 2); NVS keys protected by flash encryption (Assignment 4) | Scheme and key order chosen in the eFuse plan; HMAC keys burned from the host before the first secure boot |
| ROM download mode and JTAG | Disabled in emulated eFuses | Disabled for good; updates only through signed OTA |
| Network | Wi-Fi to the emulator access point, no internet in the web version | Full network access |

The optional [real-board appendix](../appendix-production-provisioning) runs the Assignment 4 image on a board and lists what a production line adds. Signed OTA with app rollback is covered in the optional [Assignment 5](../assignment-5).

## Security-control recap

| Control | Protected assets | Security property | How you verified it | Depends on | Residual risk |
|---------|------------------|-------------------|---------------------|------------|---------------|
| TLS ([Assignment 1](../assignment-1)) | Data exchanged with the server, server identity | Confidentiality and integrity in transit, server authentication | `Certificate verified.`; wrong-hostname and untrusted-server tests fail | An up-to-date CA bundle, correct device time | Aging CA bundle; the server does not authenticate the device unless you add mutual TLS |
| HMAC-based NVS encryption ([Assignment 2](../assignment-2)) | Wi-Fi credentials and configuration in NVS | Confidentiality at rest | Raw NVS dump shows no plaintext credentials; `HMAC_UP` key in `BLOCK_KEY0` | HMAC key burned with read protection before Secure Boot or flash encryption | Data outside NVS is not covered; any code running on the device can still read NVS |
| Secure Boot V2 ([Assignment 3](../assignment-3)) | Bootloader and application images | Integrity and authenticity of firmware | `Secure boot permanently enabled`; digest in `BLOCK_KEY0`; ROM download mode and JTAG disabled | Custody of the signing key, key digest in eFuse | A leaked signing key lets an attacker sign firmware; NVS is plaintext in this lab |
| Flash encryption and NVS keys ([Assignment 4](../assignment-4)) | Code, data, and NVS keys in external flash | Confidentiality against offline reads | `Flash encryption mode is RELEASE`; raw read of `storage` returns ciphertext; raw NVS dump without plaintext credentials | Release mode, encryption key in eFuse, `nvs_keys` partition marked `encrypted` | Code running on the device can still read decrypted data; physical attacks are out of scope |
| Secure OTA ([Assignment 5](../assignment-5), optional) | The update path and the running firmware | Only authentic updates install; recovery from a bad update | Signed update installs; unsigned and wrongly signed images rejected; rollback test | Secure Boot signing key, OTA server identity | Downgrade to an older signed image is possible without anti-rollback |

Assignments 2 to 5 ran the production configuration on an emulated ESP32-S31: the ROM, bootloader, and eFuse logic are the real ones, but the eFuses and flash are not silicon. The logs are valid evidence of the configuration and the boot flows. Evidence for a shipped product, such as a flash dump from a provisioned device, has to come from production hardware.

## CRA-support mapping

Use this table as a starting template for the traceability part of your technical file. It links each product risk to an [Annex I](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120#anx_I) theme from the [EU CRA overview](../overview-eu-cra/#essential-cybersecurity-requirements), the control that addresses it, and the evidence and process that keep it working. Adapt the risks, owners, and evidence to your product and its risk assessment.

| Product risk | CRA theme | Design control | Implementation evidence | Test evidence | Lifecycle process | Typical owner |
|--------------|-----------|----------------|-------------------------|---------------|-------------------|---------------|
| Eavesdropping or a fake server | Protection of data in transit, protection against unauthorized access | TLS with server certificate verification | `sdkconfig` (certificate bundle, verification required), trust store policy | Successful handshake log; wrong-hostname and untrusted-server failures | CA bundle updates through firmware releases | Firmware lead |
| Credential theft from a lost or stolen device | Data protection at rest | NVS encryption (HMAC-based or flash encryption-based scheme) | NVS configuration, partition table, eFuse key block record per device | Raw NVS dump without plaintext credentials | Provisioning record, key block plan, eFuse burn order | Firmware lead, manufacturing |
| Malicious or modified firmware | Protection against unauthorized access and misuse | Secure Boot V2 | Signing configuration, key digest record, signing procedure | Boot log with signature check; rejection of tampered and wrongly signed images | Signing key custody, rotation, and revocation plan | Security lead |
| Firmware or data extraction from flash | Confidentiality of stored data | Flash encryption in release mode | Flash encryption mode, `encrypted` partition flags | Raw flash read shows ciphertext in the emulator and on a production device | Key generation on the device, factory provisioning procedure | Security lead, manufacturing |
| Known vulnerabilities stay in the field | Secure update mechanisms | Signed HTTPS OTA with app rollback, anti-rollback in production | OTA partition layout, rollback and secure version settings | Signed update installs; unsigned and wrongly signed updates rejected; rollback test; failed downgrade test | Release process, secure version policy, OTA server certificate rotation | Product owner, firmware lead |
| Vulnerabilities are not found or not handled | Vulnerability handling ([Annex I Part II](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A02024R2847-20241120#anx_I)) | Not a firmware control: SBOM, monitoring of advisories, disclosure policy | SBOM (for example from [esp-idf-sbom](https://github.com/espressif/esp-idf-sbom)), disclosure policy | Records of advisories reviewed and fixes shipped | Coordinated disclosure, reporting through the ENISA Single Reporting Platform | Product owner, security lead |

> [!IMPORTANT]
> Successful completion of these exercises does not establish CRA conformity. A finished product also requires a documented risk assessment, secure defaults, vulnerability handling, update and support processes, technical documentation, conformity assessment, and fulfillment of all other applicable obligations.

## Production-readiness checklist

The Assignment 4 configuration already has production settings. Use this list for what a product needs beyond it. The [real-board appendix](../appendix-production-provisioning) shows the first provisioning of a board and what a production line adds.

### Design and keys

- Product threat model and security requirements approved
- Production keys generated and protected outside source control
- Release images signed in a controlled environment, such as an offline machine or an HSM, never on developer laptops
- Signing-key rotation and revocation plan defined; unused Secure Boot digest slots revoked
- Anti-rollback secure version policy decided before the first release
- OTA server certificate issued by a CA you control or a public CA, with a plan to rotate it before it expires

### Manufacturing and device configuration

- No development options in release builds: `CONFIG_EFUSE_VIRTUAL` not set, flash encryption in **release** mode, Secure Boot V2 enabled
- eFuse key block plan and burn order recorded (Secure Boot digest, flash encryption key, HMAC key if used); HMAC keys burned before the first secure boot
- Per-device credentials written into encrypted NVS during provisioning, not compiled into the firmware from menuconfig
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

- Assignments 2 to 5 ran on an emulated chip. The emulator does not model physical attacks such as fault injection, side channels, or probing the flash bus, so the labs show the configuration and the boot flows, not resistance to those attacks.
- The web emulator has no internet access, so TLS was tested only on the board in Assignment 1.
- Each web emulator run starts from blank eFuses, so every assignment image has to work on a new chip. That is why Assignment 3 runs without NVS encryption, and Assignment 4 protects the NVS keys with flash encryption instead of an HMAC key.
- The lab firmware compiles the Wi-Fi credentials from menuconfig into the app; a product provisions them per device.
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

ESP32 emulator:

- [Web emulator](https://espressif.github.io/esp-emulator/)
- [`esp-emulator` repository](https://github.com/espressif/esp-emulator), including the native `esp-emu` tool used in Assignment 5

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

Optional: [Provision a real board (permanent)](../appendix-production-provisioning)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
