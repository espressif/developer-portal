---
title: "Introduction to the ESP32-S31: Security - Conclusion"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 17
showAuthor: false
---

## Conclusion

This workshop has connected ESP32-S31 security controls to the security objectives of a connected product and to selected technical concerns raised by the EU Cyber Resilience Act.

## What you learned

After completing the finished workshop, you will have:

- Reviewed the ESP32-S31 architecture and security capabilities
- Distinguished SoC security features from product-level CRA compliance
- Protected data in transit with TLS
- Configured HMAC-based NVS encryption using virtual HMAC key provisioning
- Walked through Secure Boot V2 signing and verification with virtual eFuses
- Exercised flash encryption flows in virtual eFuse mode (with known limits vs production)
- Performed signed application OTA updates and tested emulated anti-rollback
- Used power profiling to investigate security-operation behavior

## Classroom vs production

| Topic | In the workshop | On the manufacturing line |
|-------|-----------------|---------------------------|
| eFuses | Virtual (`CONFIG_EFUSE_VIRTUAL`) | Real burns per enablement workflow |
| Secure Boot | Emulated digests and enable | Hardware `SECURE_BOOT_EN` |
| Flash encryption | Virtual development simulation | Real keys and release policy |
| HMAC NVS | Virtual key block | `burn-key` and protections |
| OTA | Signed apps without hardware Secure Boot | Bootloader OTA + hardware trust chain |
| Anti-rollback | `CONFIG_BOOTLOADER_EFUSE_SECURE_VERSION_EMULATE` | Secure-version eFuses |

Production provisioning is documented in the [production provisioning appendix](../appendix-production-provisioning).

## Security-control recap

TODO: Add a summary table containing each control, its protected assets, security property, verification method, operational dependency, and residual risk.

## CRA-support mapping

TODO: Add the final traceability matrix from product risks and CRA requirements to design controls, implementation evidence, test evidence, lifecycle process, and accountable owner.

> [!IMPORTANT]
> Successful completion of these exercises does not establish CRA conformity. A finished product also requires a documented risk assessment, secure defaults, vulnerability handling, update and support processes, technical documentation, conformity assessment, and fulfillment of all other applicable obligations.

## Production-readiness checklist

TODO: Expand and validate this checklist:

- Product threat model and security requirements approved
- Production keys generated and protected outside source control
- Provisioning process controlled, logged, and tested (see appendix)
- Debug and download interfaces restricted according to policy
- Secure boot, encryption, storage, TLS, and update controls verified on **provisioning** hardware
- Recovery and signing-key-compromise procedures tested
- Vulnerability disclosure and remediation processes operating
- Software bill of materials and third-party dependencies maintained
- Support period, update policy, and end-of-life process documented
- Compliance evidence reviewed by appropriate technical and legal experts

## Limitations and next steps

TODO: Document topics not covered by this workshop, including product-specific authorization, cloud security, physical enclosure security, radio and safety obligations, manufacturing security, formal penetration testing, incident response, and conformity-assessment details.

TODO: Add links to the final source repository, authoritative ESP32-S31 security documentation, ESP-IDF examples, official CRA resources, and further security training.

## Previous step

[Previous: Assignment 6: Profile security operations](../assignment-6)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
