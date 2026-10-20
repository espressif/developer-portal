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

[Assignment 3](../assignment-3) walks through the ESP-IDF enablement flow on the ESP32-S31-Function-CoreBoard-1 with ESP-IDF v6.1: generate a development signing key, build signed images, watch the bootloader burn the key digest on first boot in the ESP32 emulator, and confirm that tampered firmware is rejected. Primary reference: [Secure Boot v2 (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html).

## Learning objectives

- Describe the ESP32-S31 boot chain and where signature verification runs
- Separate the **signing private key**, the **signature block** on flash, and the **public-key digest** in eFuse
- Summarize the Secure Boot V2 verification steps for bootloader and app
- Outline key rotation, revocation, and why unused digest slots are revoked in production
- Contrast the emulator lab with manufacturing provisioning on real silicon

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

The same format applies to bootloader and application binaries. OTA updates re-use this path in production: a bad image should not become the running firmware. The hands-on track covers Secure Boot in [Assignment 3](../assignment-3); signed OTA with app rollback is the optional [Assignment 5](../assignment-5), and anti-rollback is covered in ESP-IDF docs and the [real-board appendix](../appendix-production-provisioning).

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
> The signed bootloader is also larger. On ESP32-S31 it sits between `0x2000` and the partition table, which leaves only 24 KB at the default offset of `0x8000`. Raise [CONFIG_PARTITION_TABLE_OFFSET](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-partition-table-offset) and move the partitions in your CSV accordingly. The workshop layout uses `0x10000`, which also leaves room for flash encryption in Assignment 4.

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

The lab builds a production configuration: Secure Boot V2 with RSA-3072, ROM download mode permanently disabled, and JTAG disabled. It runs in the [ESP32 emulator](https://espressif.github.io/esp-emulator/) instead of on your board. The emulator models the eFuses and the ROM, so the whole chain of trust runs as on silicon:

- On first boot, the bootloader burns the public key digest into `BLOCK_KEY0`, revokes the unused digest slots, and sets `SECURE_BOOT_EN`.
- After a reset, the ROM verifies the bootloader (`RSA-PSS secure boot verification succeeded`), and the bootloader verifies the app.

Each image you load in the browser starts on a blank chip, so nothing is permanent. To test rejection of a tampered or wrongly signed app, the chip must already trust your key. The optional step of Assignment 3 uses the native `esp-emu` tool for this, because it can save the eFuse and flash state between runs.

**Burn order:** Secure Boot write-protects the eFuse read-protection bits on first boot. An HMAC key for NVS encryption must therefore be burned before that boot, which a blank emulated chip cannot do. Assignment 3 runs with NVS encryption off, and Assignment 4 turns it back on with the flash encryption-based scheme (see [Lecture 2](../lecture-2/#efuse-burn-order)).

**Flashing images:** with `CONFIG_SECURE_BOOT`, `idf.py merge-bin` leaves out the bootloader. The assignments merge the signed bootloader, partition table, `otadata`, and app with `esptool merge-bin` instead.

### Production path (appendix)

Hardware Secure Boot burns key digests, enables `SECURE_BOOT_EN`, and may revoke unused digest slots. UART download mode and debug policies are often restricted at the same time. That is **irreversible** on real silicon. Follow the [real-board appendix](../appendix-production-provisioning) and [Security Features Enablement Workflows (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html) on hardware you are ready to give up, not on workshop kits.

> [!WARNING]
> Enabling hardware Secure Boot and programming or protecting **real** eFuses is irreversible. In class, run Secure Boot firmware only in the emulator. Never flash it to participant boards or run `espefuse burn` on them.

## CRA and product evidence

The [EU CRA overview](../overview-eu-cra) maps Secure Boot V2 to **integrity** and **protection against unauthorized firmware**. That supports Annex I themes such as secure-by-default design and controlled update surfaces; it does not replace your product risk assessment or conformity process.

Useful artifacts from Assignment 3 and production rollout:

- **Configuration record:** Secure Boot version, signing scheme (RSA-3072), digest slot allocation, and whether results come from the emulator or production silicon
- **Signing policy:** who holds the private key, CI signing vs offline HSM, rotation and revocation plan
- **Boot and test logs:** successful verify messages, intentional **rejection** of unsigned or wrongly signed images (document the test procedure)
- **Key custody:** evidence that development keys are not shipped as production trust roots

For CRA timelines, reporting duties, and conformity steps, use the overview and linked Developer Portal articles rather than repeating them in each lecture.

## Before Assignment 3

- Target: `idf.py --preview set-target esp32s31`
- Read [How to enable Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#how-to-enable-secure-boot-v2) once before changing **Security features** in menuconfig
- The partition table from Assignment 2, at offset `0x10000`, already fits the larger signed bootloader
- Open the [ESP32 emulator](https://espressif.github.io/esp-emulator/); for the optional rejection tests, install the native `esp-emu` tool from the [esp-emulator repository](https://github.com/espressif/esp-emulator)
- Generate a **lab-only** signing key; add `*.pem` to `.gitignore` and never commit private keys

## Previous and next steps

[Previous: Assignment 2](../assignment-2)

[Next: Assignment 3: Enable and verify Secure Boot V2](../assignment-3)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
