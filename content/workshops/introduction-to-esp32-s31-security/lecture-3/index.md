---
title: "Lecture 3: Secure Boot V2"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 9
showAuthor: false
---

## Secure Boot V2: Firmware authenticity

If an attacker can replace the bootloader or application in flash, they can run arbitrary code: bypass your TLS stack, exfiltrate [encrypted NVS](../lecture-2) after boot, or impersonate your device on the network. **Secure Boot V2** checks **digital signatures** on the second-stage bootloader and on each application image before execution, using **RSA-PSS** and public-key digests stored in eFuses.

[Assignment 3](../assignment-3) walks through the ESP-IDF enablement flow on the ESP32-S31-Function-CoreBoard-1 with ESP-IDF v6.1: generate a development signing key, build signed images, provision trust with **virtual** eFuses, and confirm that tampered firmware is rejected. Primary reference: [Secure Boot v2 (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html).

## Learning objectives

- Describe the ESP32-S31 boot chain and where signature verification runs
- Separate the **signing private key**, the **signature block** on flash, and the **public-key digest** in eFuse
- Summarize the Secure Boot V2 verification steps for bootloader and app
- Outline key rotation, revocation, and why unused digest slots are revoked in production
- Contrast workshop virtual eFuses with manufacturing provisioning

## Integrity threat model

**In scope:** an attacker with **write access to external flash** (or supply-chain substitution of firmware) should not get persistent execution of **unsigned** or **wrongly signed** bootloader or application code.

**Out of scope or partial:**

- **Confidentiality** of flash contents (use [flash encryption](../lecture-4) and [NVS encryption](../lecture-2))
- A **buggy but signed** application you approved with your own key
- **Runtime** compromise after a legitimate boot
- **Physical glitch or invasive** attacks on the SoC (different mitigations and test labs)

Secure Boot answers: *“Is this image cryptographically approved by keys I trust?”* It does not answer: *“Is this image free of vulnerabilities?”* Patch management, SBOM, and CRA **Part II** vulnerability handling remain product responsibilities.

## Boot chain on ESP32-S31

See [ESP-IDF startup flow](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-guides/startup.html) for full detail. At a high level:

| Stage | Role in Secure Boot V2 |
|-------|-------------------------|
| ROM (first stage) | Fixed in silicon; if `SECURE_BOOT_EN` is set, verifies the **second-stage bootloader** signature before running it |
| Second-stage bootloader | Verifies **application** (and OTA slot) signatures before jump to app |
| Application | Runs only after verification; ESP-IDF runs `esp_secure_boot_init_checks()` automatically at startup to check the Secure Boot eFuses and, by default, revoke unused digest slots |

The ROM image is not signed; trust starts from ROM code plus eFuse policy. Everything **you can update in flash** that affects execution must pass verification once Secure Boot is enabled.

## Secure Boot V2 process

ESP32-S31 implements [Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#secure-boot-v2-process) with **RSA-3072** and **RSA-PSS** (RFC 8017). Each signed image has one or more **signature blocks** appended (up to **three** per image). Each block contains the image digest, the public key material, and the signature.

Verification (simplified):

1. ROM checks whether Secure Boot is enabled (`SECURE_BOOT_EN`).
2. ROM validates the bootloader’s signature block(s) and image against **trusted digests** in eFuse.
3. Bootloader validates the selected app partition the same way.
4. On failure, boot **stops**; the bootloader may try another OTA app partition if one verifies.

The same format applies to bootloader and application binaries. OTA updates re-use this path in production: a bad image should not become the running firmware. The hands-on track covers Secure Boot in [Assignment 3](../assignment-3); signed OTA with app rollback is the optional [Assignment 5](../assignment-5), and anti-rollback is covered in ESP-IDF docs and the [production provisioning appendix](../appendix-production-provisioning).

Detailed steps: [Verifying a signature block](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#verifying-a-signature-block) and [Verifying an image](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#verifying-an-image).

## Keys, signing, and eFuses

Three concepts often get conflated:

| Artifact | Location | Purpose |
|----------|----------|---------|
| **Signing private key** | Host, HSM, or signing service; **never** on the device | Creates signatures at build or release time |
| **Signature block(s)** | Appended to bootloader/app in flash | Supplies public key + signature for verification |
| **Public-key digest** | eFuse block with purpose `SECURE_BOOT_DIGEST0` … `SECURE_BOOT_DIGEST2` | Trust anchor: only keys whose digest matches may boot |

On ESP32-S31, the digest is a **SHA-256** hash over part of the signature block (see [eFuse usage](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#efuse-usage)). Digests must be **write-protected** and **readable** (read-protect breaks verification).

**Key management** (production): use one to three independent key pairs; sign apps with a single active private key; revoke unused digest slots with `KEY_REVOKEX` so an attacker cannot add a new trusted key later. See [Key management](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#key-management) and [Key revocation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#secure-boot-v2-key-revocation).

ESP-IDF build helpers (wrappers around `espsecure`):

- `idf.py secure-generate-signing-key` or `espsecure generate-signing-key --version 2 --scheme rsa3072 …`
- Signed builds attach blocks automatically when [CONFIG_SECURE_BOOT_BUILD_SIGNED_BINARIES](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot-build-signed-binaries) is enabled
- Inspect signatures: `espsecure signature-info-v2` on a signed binary

Manufacturing may use **menuconfig-first** enablement ([How to enable Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#how-to-enable-secure-boot-v2)) or an **external** workflow ([Enable Secure Boot v2 externally](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-secure-boot-v2-externally)) with manual digest burn and `espsecure sign-data`.

> [!NOTE]
> Enabling [CONFIG_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot) changes flashing: `idf.py flash` does **not** flash the bootloader. Flash the signed bootloader separately with `idf.py bootloader-flash`, or with the `esptool write-flash` command printed by `idf.py bootloader` (offset `0x2000` on ESP32-S31).
>
> The signed bootloader is also larger. On ESP32-S31 it sits between `0x2000` and the partition table, which leaves only 24 KB at the default offset of `0x8000`. Raise [CONFIG_PARTITION_TABLE_OFFSET](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-partition-table-offset) (for example to `0xD000`) and move the partitions in your CSV accordingly.

## Relation to other workshop topics

| Topic | Secure Boot V2 | Complementary control |
|-------|----------------|------------------------|
| [HMAC NVS](../lecture-2) | Does not stop rogue **code** from running | Protects **secrets at rest** once honest firmware runs |
| [Flash encryption](../lecture-4) | Does not prove **authenticity** | Hides ciphertext from offline read |
| [TLS](../lecture-1) | Protects **network** sessions | Does not verify **local** flash images |
| Signed OTA (optional Assignment 5, production) | Hardware SB verifies every boot | OTA path must deliver **signed** images your digests trust |

Together, authenticity (Secure Boot), confidentiality (flash/NVS encryption), and signed updates (product lifecycle) form a typical CRA-oriented **defense-in-depth** story for firmware and data.

## Workshop and production provisioning

### Workshop path (Assignment 3)

The class lab enables the Secure Boot V2 **build and boot flow** with [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) and [CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual-keep-in-flash). Public-key digests and `SECURE_BOOT_EN` are applied to **emulated** eFuses only. You still sign images and can optionally test rejection of bad firmware; the SoC’s real eFuses stay at factory defaults, apart from the HMAC key block burned in [Assignment 2](../assignment-2). The emulated copy starts from the real eFuses, so that block still shows `HMAC_UP` and encrypted NVS keeps working.

Emulation has one important limit: the ROM reads the **real** `SECURE_BOOT_EN` eFuse, which stays off. In the lab, the ROM does not verify the bootloader; only the bootloader's verification of the application is exercised. That is enough to sign images and see a tampered app rejected, but it is not the full hardware chain of trust.

**Preflight:** After `idf.py build`, confirm `CONFIG_EFUSE_VIRTUAL=y` and `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y`. After boot, expect the `eFuse virtual mode is enabled` warning. Note that `idf.py efuse-summary` reads the **real** eFuses through the ROM, so it shows `SECURE_BOOT_EN` as `False` even when emulated Secure Boot is on. Read the emulated state from the application (for example with `esp_secure_boot_enabled()`), as Assignment 3 does.

**Reset between labs:** erase the flash, then flash the signed bootloader and app again. Erase before the first Secure Boot flash as well, so `efuse_em` starts empty and is filled from the real eFuses. Erasing flash never touches the real HMAC key. Once `CONFIG_SECURE_BOOT` is set, `idf.py erase-flash` fails because ESP-IDF switches esptool to ROM-only mode (`CONFIG_ESPTOOLPY_NO_STUB`); run `python -m esptool --chip esp32s31 -p PORT erase-flash` instead.

### Production path (appendix)

Hardware Secure Boot burns key digests, enables `SECURE_BOOT_EN`, and may revoke unused digest slots. UART download mode and debug policies are often restricted at the same time. That is **irreversible** on real silicon. Follow the [production provisioning appendix](../appendix-production-provisioning) and [Security Features Enablement Workflows (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html) on disposable provisioning hardware, not on workshop kits.

> [!WARNING]
> Enabling hardware Secure Boot and programming or protecting **real** eFuses can be irreversible. In class, verify virtual eFuse mode before any Secure Boot step. Never run `espefuse burn` on participant boards.

## CRA and product evidence

The [EU CRA overview](../overview-eu-cra) maps Secure Boot V2 to **integrity** and **protection against unauthorized firmware**. That supports Annex I themes such as secure-by-default design and controlled update surfaces; it does not replace your product risk assessment or conformity process.

Useful artifacts from Assignment 3 and production rollout:

- **Configuration record:** Secure Boot version, signing scheme (RSA-3072), digest slot allocation, virtual vs hardware mode
- **Signing policy:** who holds the private key, CI signing vs offline HSM, rotation and revocation plan
- **Boot and test logs:** successful verify messages, intentional **rejection** of unsigned or wrongly signed images (document the test procedure)
- **Key custody:** evidence that development keys are not shipped as production trust roots

For CRA timelines, reporting duties, and conformity steps, use the overview and linked Developer Portal articles rather than repeating them in each lecture.

## Before Assignment 3

- Target: `idf.py --preview set-target esp32s31`
- Read [How to enable Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#how-to-enable-secure-boot-v2) once before changing **Security features** in menuconfig
- Enable virtual eFuses and add an `efuse_em` partition (they were off during Assignment 2)
- Plan a partition table offset of `0xD000` for the larger signed bootloader; the move resets NVS, and the Wi-Fi credentials are stored again from menuconfig
- Generate a **lab-only** signing key; add `*.pem` to `.gitignore` and never commit private keys

## Previous and next steps

[Previous: Assignment 2](../assignment-2)

[Next: Assignment 3: Enable and verify Secure Boot V2](../assignment-3)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
