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

This lecture follows the ESP-IDF example [`nvs_encryption_hmac`](https://github.com/espressif/esp-idf/tree/master/examples/security/nvs_encryption_hmac), which uses the **HMAC peripheral scheme**: the XTS keys for NVS are **derived at runtime** from an HMAC key stored in a **real eFuse key block**. You do not need a separate `nvs_keys` partition, and you do **not** need flash encryption enabled for this path. See [NVS Encryption: HMAC peripheral-based scheme (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_encryption.html#nvs-encryption-hmac-peripheral-based-scheme).

[Assignment 2](../assignment-2) applies the same NVS configuration to the **https_mbedtls** project from Assignment 1, so the lab Wi-Fi SSID and password are stored in encrypted NVS.

> [!WARNING]
> This scheme programs a **real** eFuse key block on your board. The HMAC peripheral reads its key directly from eFuse hardware, so virtual eFuses cannot emulate it. Programming the key is **irreversible**: it consumes one of the six key blocks (`BLOCK_KEY0` to `BLOCK_KEY5`) permanently.

## Learning objectives

- Explain what NVS encryption protects (and what remains visible, such as page headers and partition layout)
- Describe how the HMAC key in eFuse relates to the derived NVS encryption keys
- Outline the `nvs_encryption_hmac` flow: default `nvs` partition plus a custom encrypted partition
- Configure [CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-hmac-efuse-key-id) and interpret first-boot and later-boot logs
- Contrast this lab with [Lecture 4](../lecture-4) flash encryption (whole-flash confidentiality)

## Storage threat model

**In scope:** an attacker with **offline read access** to external flash (or a firmware image that dumps NVS) should not recover plaintext credentials or secrets stored in encrypted NVS.

**Out of scope or partial:**

- A **running, compromised** application can still call NVS APIs and read decrypted values
- **Keys in RAM** during operation
- Replacing the entire flash image with attacker-controlled firmware if the product has no integrity controls (addressed by Secure Boot in [Lecture 3](../lecture-3))
- Encrypting arbitrary files outside NVS partitions

XTS-AES encrypts all NVS data **except the page headers**, so the partition layout and page state remain visible. Use NVS encryption for **small, structured configuration and secrets**. Large blobs or streaming data belong elsewhere, with their own threat model.

## HMAC scheme in ESP-IDF

Two keys are involved (see [Enable NVS encryption based on HMAC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-nvs-encryption-based-on-hmac)):

| Key | Where it lives | Role |
|-----|----------------|------|
| HMAC key (256-bit) | eFuse key block with purpose `HMAC_UP`, read-protected | Root for derivation; one block per device |
| NVS encryption (XTS) keys | Derived at runtime, never stored in flash | Encrypt NVS entries in the partition |

The [nvs_sec_provider](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_encryption.html#nvs-security-provider) component registers the HMAC-based scheme at startup when [CONFIG_NVS_ENCRYPTION](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-encryption) is enabled and [CONFIG_NVS_SEC_KEY_PROTECTION_SCHEME](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-key-protection-scheme) is set to `CONFIG_NVS_SEC_KEY_PROTECT_USING_HMAC`. You will see `NVS Encryption - Registering HMAC-based scheme...` early in the boot log.

[`nvs_flash_init()`](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_flash.html#_CPPv414nvs_flash_initv) then checks the eFuse block selected by `CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID`:

- **Block empty:** a random 256-bit key is generated on the SoC and burned with purpose `HMAC_UP`. The key block is read-protected, so software cannot read the key back.
- **Block already holds an `HMAC_UP` key** (pre-burned or from an earlier boot): that key is used.
- **Block holds a key with another purpose:** initialization fails (`ESP_ERR_NVS_SEC_HMAC_KEY_BLK_ALREADY_USED`).

In each successful case, the HMAC peripheral derives the XTS encryption and tweak keys (`nvs_flash_generate_keys_v2()` / `nvs_flash_read_security_cfg_v2()`), and the default `nvs` partition is mounted encrypted.

## Reference example architecture

Path: `$IDF_PATH/examples/security/nvs_encryption_hmac`

**Configuration:**

- The example `sdkconfig.defaults` enables NVS encryption with the HMAC scheme and selects a custom partition table:

  ```ini
  CONFIG_PARTITION_TABLE_CUSTOM=y
  CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions_example.csv"
  CONFIG_NVS_ENCRYPTION=y
  CONFIG_NVS_SEC_KEY_PROTECT_USING_HMAC=y
  ```

- **Component config → NVS → Enable NVS encryption** sets `CONFIG_NVS_ENCRYPTION`. The **NVS Security Provider** menu only appears after this option is on.
- **Component config → NVS Security Provider → NVS Encryption: Key Protection Scheme** defaults to **Using HMAC peripheral** on SoCs with an HMAC peripheral, including the ESP32-S31.
- **Component config → NVS Security Provider → eFuse key ID storing the HMAC key** must be set to `0` to `5`. The default `-1` is out of range and stops the build.

**`app_main` flow:**

1. Initialize the **default** `nvs` partition with `nvs_flash_init()`. Expect `NVS partition "nvs" is encrypted.`
2. Read the security config from the default scheme with `nvs_flash_read_security_cfg_v2()` and initialize the **custom** partition (`custom_nvs` in `partitions_example.csv`) with `nvs_flash_secure_init_partition()`. Both partitions use the same derived keys.
3. Write sample keys (`u8_key`, `str_key`, and others) to the `storage` namespace, then read them back through NVS APIs.
4. **Dump** the start of the custom partition with `esp_partition_read()` to show that raw flash does not contain the plaintext string.

The assignment keeps only the default `nvs` partition. Wi-Fi credentials are small, and `nvs_flash_init()` already encrypts that partition, so the `custom_nvs` step is reference material for products that keep secrets in a separate partition.

## Versus flash encryption

| | HMAC NVS (this lecture) | Flash encryption ([Lecture 4](../lecture-4)) |
|--|-------------------------|-----------------------------------------------|
| Primary goal | Confidentiality of **NVS entries** | Confidentiality of **code and data in mapped flash** |
| Typical keys | HMAC eFuse key + derived XTS keys | Flash encryption key eFuses |
| eFuse use in the workshop | Real `HMAC_UP` key block (irreversible) | Virtual encryption eFuses |

Many products use **both**: flash encryption for firmware and bulk storage, HMAC NVS for credentials and configuration with a separate provisioning story.

## Provisioning the HMAC key

The HMAC key can reach the eFuse block in two ways:

- **First-boot generation:** flash firmware with the block empty and let `nvs_flash_init()` generate and burn the key. No key material ever leaves the SoC. This is the path used in Assignment 2.
- **Pre-burned key:** program a key you generated on the host before flashing the app. This is useful when manufacturing needs to know the key, for example to pre-generate encrypted NVS images with the [NVS Partition Generator](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_partition_gen.html). Use either command, with the block matching `CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID`:

  ```bash
  idf.py -p PORT efuse-burn-key BLOCK_KEY0 hmac_key_file.bin HMAC_UP
  # or
  espefuse -p PORT burn-key BLOCK_KEY0 hmac_key_file.bin HMAC_UP
  ```

> [!WARNING]
> **Do not run these commands during the workshop.** They are shown for reference only. In [Assignment 2](../assignment-2), the firmware generates and burns the HMAC key on first boot, so no manual burn is needed. A mistyped block or key file is written permanently and cannot be undone.

Things to know before you burn:

- The key block is consumed permanently and cannot be read back by software.
- `idf.py erase-flash` does **not** remove the key. After an erase, the same key derives the same XTS keys; only the NVS contents are lost.
- Record which block holds the HMAC key. Later features (Secure Boot digests, flash encryption keys, digital signature keys) need their own free blocks.
- Check the current state with `idf.py -p PORT efuse-summary` before choosing a block.

For production line steps and risks, see [Enable NVS encryption based on HMAC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-nvs-encryption-based-on-hmac) and the [production provisioning appendix](../appendix-production-provisioning).

## CRA and product evidence

The [EU CRA overview](../overview-eu-cra) maps this topic to **credentials and configuration at rest**. For a product technical file, this lab supports evidence that you **designed** confidential storage for NVS-backed secrets, not that the SoC alone satisfies the CRA.

Useful artifacts from Assignment 2:

- Which **partitions** are encrypted and which Kconfig scheme is selected
- **Provisioning record** for the HMAC key: block ID, provisioning method (first-boot generation or pre-burned), and `efuse-summary` output showing purpose `HMAC_UP` and read protection
- **Test notes:** API read succeeds, raw partition dump does not show plaintext test strings

For Annex I themes and deadlines, rely on the overview and Developer Portal CRA articles linked there rather than repeating them in each lecture.

## Before Assignment 2

- Starting point: your Assignment 1 project in `$IDF_PATH/examples/protocols/https_mbedtls`
- Reference: `$IDF_PATH/examples/security/nvs_encryption_hmac`
- Target: `idf.py --preview set-target esp32s31`
- Run `idf.py -p PORT efuse-summary` and pick a free key block (the workshop uses `BLOCK_KEY0`, key ID `0`)
- Set **eFuse key ID storing the HMAC key** in menuconfig before build

## Previous and next steps

[Previous: Assignment 1](../assignment-1)

[Next: Assignment 2: Protect data with HMAC-based NVS encryption](../assignment-2)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
