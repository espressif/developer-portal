---
title: "Lecture 2: HMAC-Based NVS Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 7
showAuthor: false
---

## Secure storage with HMAC-based NVS encryption

Products store Wi-Fi credentials, tokens, calibration, and user settings in [NVS](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_flash.html). Plain NVS is readable from flash if an attacker dumps the partition. **NVS encryption** keeps values confidential on the medium; your app still uses the normal `nvs_set_*` / `nvs_get_*` APIs after initialization.

[Assignment 2](../assignment-2) follows the ESP-IDF example [`nvs_encryption_hmac`](https://github.com/espressif/esp-idf/tree/master/examples/security/nvs_encryption_hmac) on the Function CoreBoard with ESP-IDF v6.1. That example uses the **HMAC peripheral scheme**: XTS keys for NVS are **derived at runtime** from an HMAC key in eFuse, so you do not need a separate `nvs_keys` partition and you do **not** need flash encryption enabled for this path. See [NVS Encryption: HMAC peripheral-based scheme (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_encryption.html#nvs-encryption-hmac-peripheral-based-scheme).

## Learning objectives

- Explain what NVS encryption protects (and what remains visible, such as metadata and partition layout)
- Describe how the HMAC key in eFuse relates to derived NVS encryption keys
- Outline the `nvs_encryption_hmac` flow: default `nvs` partition plus a custom encrypted partition
- Configure [CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-hmac-efuse-key-id) and interpret example logs
- Contrast this lab with [Lecture 4](../lecture-4) flash encryption (whole-flash confidentiality)

## Storage threat model

**In scope:** an attacker with **offline read access** to external flash (or a firmware image that dumps NVS) should not recover plaintext credentials or secrets stored in encrypted NVS.

**Out of scope or partial:**

- A **running, compromised** application can still call NVS APIs while the device is unlocked
- **Keys in RAM** during operation
- Replacing the entire flash image with attacker-controlled NVS if the product has no integrity controls (addressed by Secure Boot and signed updates in later lectures)
- Encrypting arbitrary files outside NVS partitions

Use NVS encryption for **small, structured configuration and secrets**. Large blobs or streaming data belong elsewhere, with their own threat model.

## HMAC scheme in ESP-IDF

Two keys are involved in production workflows (see [Enable NVS encryption based on HMAC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-nvs-encryption-based-on-hmac)):

| Key | Where it lives | Role |
|-----|----------------|------|
| HMAC key (256-bit) | eFuse block with purpose `HMAC_UP` | Root for derivation; one block consumed per device |
| NVS encryption (XTS) keys | Derived at runtime, not stored in flash | Encrypt NVS entries in the partition |

The [nvs_sec_provider](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_encryption.html#nvs-security-provider) component registers the HMAC-based scheme when you enable [CONFIG_NVS_ENCRYPTION](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-encryption) and set [CONFIG_NVS_SEC_KEY_PROTECTION_SCHEME](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-key-protection-scheme) to `CONFIG_NVS_SEC_KEY_PROTECT_USING_HMAC`.

On first boot, [`nvs_flash_init()`](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_flash.html#_CPPv414nvs_flash_initv) checks the configured eFuse block. If it is empty, ESP-IDF may generate and program an HMAC key (production) or, in the workshop, update **virtual** eFuses only. If a valid `HMAC_UP` key is already present, that key is used for derivation.

## Reference example architecture

Path: `$IDF_PATH/examples/security/nvs_encryption_hmac`

**menuconfig (required before build):**

- **Component config → NVS Security Provider → eFuse key ID storing the HMAC key** must be set to a valid ID (`0` to `5` on ESP32-S31). The default `-1` fails the build.
- Enable NVS encryption and HMAC protection per the example Kconfig (see example README).

**`app_main` flow:**

1. Log and initialize the **default** `nvs` partition with `nvs_flash_init()`. Expect `NVS partition "nvs" is encrypted.` when encryption is active.
2. Initialize a **custom** NVS partition (`custom_nvs` in the example partition table) via `nvs_flash_secure_init_partition()` after reading the security config with `nvs_flash_read_security_cfg_v2()` from the default scheme handle (same derived keys for both partitions in the example).
3. Write sample keys (`u8_key`, `str_key`, and others) to the custom namespace, then read them back through NVS APIs.
4. **Dump** a region of the custom partition with `esp_partition_read()` to show that raw flash does not contain the plaintext string (hex dump in the example README).

Success logs include `NVS Encryption - Registering HMAC-based scheme...` and readable key/value lines for the API path, alongside non-obvious bytes in the partition dump.

## Versus flash encryption

| | HMAC NVS (this lecture) | Flash encryption ([Lecture 4](../lecture-4)) |
|--|-------------------------|-----------------------------------------------|
| Primary goal | Confidentiality of **NVS entries** | Confidentiality of **code and data in mapped flash** |
| Typical keys | HMAC eFuse + derived XTS | Flash encryption eFuses |
| Workshop tier | B (virtual HMAC eFuse) | B (virtual encryption eFuses) |

Many products use **both**: flash encryption for firmware and bulk storage, HMAC NVS for credentials and configuration with a separate provisioning story.

## Workshop and production provisioning

**Workshop ([Assignment 2](../assignment-2)):** Keep [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) enabled. HMAC key programming is emulated; do not run `espefuse burn-key` on class boards.

**Production:** Burn a chosen HMAC key with purpose `HMAC_UP` into the block matching `CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID`, document the block allocation, and follow [Enable NVS encryption based on HMAC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-nvs-encryption-based-on-hmac). Manufacturing may pre-burn keys or rely on controlled first-boot generation. Details and risks are in the [production provisioning appendix](../appendix-production-provisioning).

## CRA and product evidence

The [EU CRA overview](../overview-eu-cra) maps this topic to **credentials and configuration at rest**. For a product technical file, this lab supports evidence that you **designed** confidential storage for NVS-backed secrets, not that the chip alone satisfies the CRA.

Useful artifacts from Assignment 2:

- Which **partitions** are encrypted and which Kconfig scheme is selected
- **Provisioning record** for the HMAC eFuse block (virtual in class; real block index and audit trail in production)
- **Test notes:** API read succeeds, raw partition dump does not show plaintext test strings

For Annex I themes and deadlines, rely on the overview and Developer Portal CRA articles linked there rather than repeating them in each lecture.

## Before Assignment 2

- Example: `$IDF_PATH/examples/security/nvs_encryption_hmac`
- Target: `idf.py set-target esp32s31`
- Confirm virtual eFuse defaults from the workshop project still apply
- Set **eFuse key ID storing the HMAC key** in menuconfig before build

## Previous and next steps

[Previous: Assignment 1](../assignment-1)

[Next: Assignment 2: Protect data with HMAC-based NVS encryption](../assignment-2)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
