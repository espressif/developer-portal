---
title: "Lecture 4: Flash Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 11
showAuthor: false
---

## Flash encryption: Confidentiality on external flash

Offline access to external flash can expose firmware, file systems, and data partitions. **Flash encryption** uses **XTS-AES** in hardware so ciphertext is stored on the medium while the CPU sees decrypted content through the flash cache during normal operation. It complements [Secure Boot V2](../lecture-3) (authenticity) and [HMAC-based NVS encryption](../lecture-2) (structured secrets in NVS without requiring whole-flash encryption).

[Assignment 4](../assignment-4) adds flash encryption to the same **https_mbedtls** project from Assignments 1 to 3 (TLS, HMAC NVS, Secure Boot V2) on the ESP32-S31-Function-CoreBoard-1 with ESP-IDF v6.1, in **development** mode with **virtual** eFuses. Primary reference: [Flash Encryption (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html).

## Learning objectives

- State the physical-access threat flash encryption mitigates (and what it does not)
- Describe first-boot enablement: key generation, `SPI_BOOT_CRYPT_CNT`, and in-place encryption
- Explain **development** vs **release** mode and why release is incompatible with virtual eFuses in the workshop
- Plan a project that combines flash encryption, Secure Boot V2, and HMAC NVS: key blocks, partition flags, bootloader size
- Relate flash encryption to Secure Boot and to the HMAC NVS path from Assignment 2

## Threat model and limitations

**In scope:** an attacker with **physical read access** to the external flash chip (or a raw dump of the SPI contents) should not recover **plaintext** for encrypted regions (bootloader, app, and partitions marked `encrypted` in the partition table).

**Out of scope or partial:**

- **Authenticity** of images ([Lecture 3](../lecture-3)): encrypted malware is still malware if it boots
- **Runtime** memory, debug interfaces, and side channels
- **Development mode** behavior: the UART bootloader may still accept plaintext downloads that the device encrypts on write, which is not a production control
- **Virtual eFuse** lab behavior: the flow runs and is logged, but nothing in flash is actually encrypted; see [Flash Encryption Testing](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html#flash-encryption-testing)

Flash encryption protects **confidentiality at rest** on the flash bus. Pair it with Secure Boot for a typical connected product baseline; secure OTA is a separate product topic (see appendix and ESP-IDF docs).

## Encryption architecture (ESP32-S31)

Hardware derives or loads an **XTS-AES** key into eFuse key blocks (`BLOCK_KEYN` with flash-encryption purpose). The **flash encryption block** encrypts and decrypts cache-mapped flash transparently. On ESP32-S31, `SPI_BOOT_CRYPT_CNT` records how many encryption enable cycles completed; an **odd** bit count means encryption is active ([Flash encryption process](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html#flash-encryption-process)).

What typically gets encrypted on first boot after enablement:

- Second-stage bootloader (in-place)
- Application partitions
- Data partitions with the **`encrypted` flag** in the partition table (for example the `storage` partition in Assignment 4)

Partitions without the flag remain plaintext on the wire unless other layers (such as NVS entry encryption) apply.

Key source on ESP32-S31 is **eFuse-based** by default (bootloader-generated random key on first enable unless a key was pre-burned).
Enabling flash encryption **increases bootloader size**. On ESP32-S31 the bootloader starts at `0x2000`. With both Secure Boot V2 and flash encryption it is `0xC000` bytes, so the partition table moves to `0xF000` in Assignment 4. The `flash_encryption` example, with flash encryption only, uses `0xD000`.

## Combining flash encryption with Secure Boot and HMAC NVS

Assignment 4 keeps everything from the earlier labs and adds flash encryption:

- **Key blocks:** `BLOCK_KEY0` holds `HMAC_UP` (real, Assignment 2), `BLOCK_KEY1` the Secure Boot digest, and `BLOCK_KEY2` the XTS-AES-128 flash encryption key. AES-128 is the default key size and needs one block; AES-256 needs two.
- **NVS:** stays on the HMAC scheme. NVS encryption works alongside flash encryption, and the `nvs` partition is **not** marked `encrypted`; NVS encrypts its own entries.
- **Partitions:** the app is always encrypted. Custom data partitions, such as a `storage` partition for secrets or files, carry the `encrypted` flag. `efuse_em` and `nvs` must not.
- **Flashing:** `idf.py flash` writes plaintext. On a real device in development mode, later updates use `idf.py encrypted-flash`; with virtual eFuses, plain `idf.py flash` is the right command because the hardware does not decrypt.

## Reference example: `flash_encryption` (background reading)

Path: `$IDF_PATH/examples/security/flash_encryption`. Assignment 4 does not use this example, but it is a useful reference for FATFS on encrypted and plain partitions. In ESP-IDF v6.1 it does not list ESP32-S31 as a supported target yet, and it needs the NVS scheme change described below to build for `esp32s31`.

**menuconfig (typical):**

- **Security features → Enable flash encryption on boot** ([CONFIG_SECURE_FLASH_ENC_ENABLED](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-flash-enc-enabled))
- **Enable usage mode → Development** ([CONFIG_SECURE_FLASH_ENCRYPTION_MODE_DEVELOPMENT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-flash-encryption-mode-development)) for the example and workshop
- **Partition Table → Custom partition CSV** (`partitions_example.csv`): `nvs`, `storage`, factory app, `nvs_key` (subtype `nvs_keys`), `custom_nvs`, `fat_encrypted`, `fat_not_encr`
- With flash encryption enabled, **NVS encryption** defaults on. The example uses the **`nvs_key`** partition and the [flash encryption-based NVS scheme](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/storage/nvs_encryption.html#nvs-encryption-flash-encryption-based-scheme) (distinct from the **HMAC** scheme in [Lecture 2](../lecture-2)). On SoCs with an HMAC peripheral, including ESP32-S31, ESP-IDF picks the HMAC scheme by default, so select **NVS Security Provider → Using Flash Encryption** ([CONFIG_NVS_SEC_KEY_PROTECT_USING_FLASH_ENC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-key-protect-using-flash-enc)) for this example

**`app_main` flow (`flash_encrypt_main.c`):**

1. Print SoC information and **flash encryption status** (`SPI_BOOT_CRYPT_CNT`, development vs release messaging).
2. **`example_read_write_flash`**: exercise encrypted flash read/write helpers.
3. **`example_read_write_fatfs`** (if FAT partitions exist): write the same test string to **`fat_not_encr`** and **`fat_encrypted`**, read back through FATFS, then use `esp_flash_read()` on the encrypted partition at the same offset. With encryption active, the **raw read** does not show the plaintext string; the non-encrypted partition does.
4. Initialize default **`nvs`** and optional **`custom_nvs`** with `nvs_flash_secure_init_partition()` when NVS encryption is enabled.

First boot after `idf.py flash monitor`: the bootloader encrypts eligible content, sets `SPI_BOOT_CRYPT_CNT`, and resets; logs include lines such as `Checking flash encryption...` and `Flash encryption completed`. On later boots the bootloader reports `flash encryption is enabled (N plaintext flashes left)`, and the application warns `Flash encryption mode is DEVELOPMENT (not secure)`.

## Development and release modes

| | Development | Release |
|--|-------------|---------|
| Plaintext UART flash | Allowed (bootloader encrypts on write) | Not allowed for arbitrary plaintext |
| Typical use | Bring-up, example, workshop | Manufacturing and field devices |
| Workshop | Yes, with virtual eFuses | **No** in class ([CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) blocks release mode in menuconfig) |

Release mode burns stricter eFuses (for example `DIS_DOWNLOAD_MANUAL_ENCRYPT`) and write-protects `SPI_BOOT_CRYPT_CNT`. Transition from development on a real device requires explicit steps such as [`esp_flash_encryption_set_release_mode()`](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/peripherals/spi_flash/index.html#_CPPv437esp_flash_encryption_set_release_modev); see [Transitioning from Development to Release Mode](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html#transitioning-from-development-to-release-mode). Production workflows are in the [production provisioning appendix](../appendix-production-provisioning) and [Enable Flash Encryption externally](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-flash-encryption-externally).

## Versus Secure Boot and NVS encryption

| Control | Primary property | Workshop lab |
|---------|------------------|--------------|
| [Secure Boot V2](../lecture-3) | **Integrity** of bootloader and app | Assignment 3 (virtual digests) |
| Flash encryption (this lecture) | **Confidentiality** of flash contents | Assignment 4 (virtual `SPI_BOOT_CRYPT_CNT` / keys) |
| [HMAC NVS](../lecture-2) | **Confidentiality** of NVS entries without full flash encryption | Assignment 2 |

Products often enable **Secure Boot and flash encryption** together, as Assignment 4 does. HMAC NVS keeps working alongside them. The alternative, the flash encryption-based NVS scheme with an `nvs_keys` partition, suits SoCs without an HMAC peripheral; the `flash_encryption` example shows it.

## Workshop and production provisioning

### Workshop path (Assignment 4)

The lab uses flash encryption **development** mode with virtual eFuses and an `efuse_em` partition. The bootloader runs the full first-boot flow, writes the key and `SPI_BOOT_CRYPT_CNT` to the emulated eFuses, and logs it, but **nothing in flash is actually encrypted**. The real flash encryption hardware stays off, and if the bootloader wrote ciphertext, the SoC could not run the app. ESP-IDF therefore treats `encrypted` partitions as plaintext unless the real eFuses enable flash encryption, and the bootloader warns `Flash encryption not really completed. Must disable virtual efuses`. See [Flash Encryption Testing](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html#flash-encryption-testing).

In practice, the raw read of an `encrypted` partition, and a dump of the app partition, still show plaintext in the lab. Assignment 4 uses that result to teach what the evidence from a production device must show, and why virtual-mode results cannot serve as evidence of encryption at rest.

[CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) cannot be combined with flash encryption **release** mode in menuconfig. The workshop never enables release mode in class.

Keep recoverable UART download settings on student boards unless your instructor explicitly configures otherwise.

### Production path (appendix)

Release mode and real key/counter eFuses are manufacturing decisions documented in the [production provisioning appendix](../appendix-production-provisioning).

> [!WARNING]
> Release-mode eFuses and UART lockdown can be **irreversible**. Do not practice production burns on ESP32-S31-Function-CoreBoard-1 kits used in the course.

## CRA and product evidence

The [EU CRA overview](../overview-eu-cra) maps flash encryption to **confidentiality of stored data** (firmware and partitions at rest). That supports technical documentation for data-protection and secure-by-default design; it is not conformity by itself.

Useful artifacts from Assignment 4 and production planning:

- **Configuration record:** development vs release, partition table with `encrypted` flags, partition table offset, NVS scheme (HMAC vs `nvs_keys`) if both exist in your product
- **Test notes:** `esp_partition_read()` vs raw `esp_flash_read()` comparison, flash dump search, boot logs showing encryption enabled
- **Limitations documented:** development mode and virtual eFuse testing called out explicitly in the risk assessment where applicable

For Annex I timelines, reporting, and conformity process, use the overview and linked Developer Portal CRA articles rather than repeating them here.

## Before Assignment 4

- Project: the finished Assignment 3 project (`$IDF_PATH/examples/protocols/https_mbedtls`), with virtual eFuses still enabled
- Target: `idf.py --preview set-target esp32s31`
- Keep the NVS key protection scheme on HMAC (key ID `0`)
- Plan a partition table offset of `0xF000` for the larger bootloader; the board is erased again, so Secure Boot and flash encryption are both enabled on the next first boot

## Previous and next steps

[Previous: Assignment 3](../assignment-3)

[Next: Assignment 4: Enable and verify flash encryption](../assignment-4)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
