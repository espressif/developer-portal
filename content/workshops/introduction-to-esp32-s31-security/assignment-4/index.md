---
title: "Assignment 4: Enable and Verify Flash Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 12
showAuthor: false
---

## Assignment 4: Enable and verify flash encryption

In Assignments 1 to 3 you built one product-style firmware on the [**https_mbedtls**](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_mbedtls) client: TLS with the certificate bundle, Wi-Fi credentials in **HMAC-encrypted NVS**, and **Secure Boot V2**. Here you add **flash encryption** to the same project, so the firmware ends up with all four protections. Read [Lecture 4](../lecture-4) for architecture and CRA context.

You enable flash encryption in **development** mode with **virtual** eFuses. In this mode ESP-IDF runs the whole first-boot flow and logs it, but **nothing in flash is actually encrypted**: the real flash encryption hardware stays off, so data is written and read as plaintext ([Flash Encryption Testing](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html#flash-encryption-testing)). The lab therefore teaches the configuration, the boot flow, and how to read the evidence. Part of that evidence is seeing, and explaining, why raw reads stay plaintext here while they would show ciphertext on a production device.

This assignment still walks you through every step you need to enable flash encryption on a production device later: the configuration, the partition layout, the flashing order, the checks, and the move from development to release mode. The only thing you skip for now is burning the real eFuses. While you are still developing the application, you stay on the safe side: the board remains fully reflashable, and nothing on it is changed permanently.

## Before you begin

**Starting point:** Assignment 3 complete in the same project: Secure Boot V2 with virtual eFuses, and the `log_security_state()` helper from [Assignment 3, Step 6](../assignment-3/#step-6-log-the-emulated-security-state-from-the-application).

> [!IMPORTANT]
> **Virtual eFuses stay on.** Keep `CONFIG_EFUSE_VIRTUAL` and `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH` enabled. Do **not** select flash encryption **release** mode or run `espefuse burn`: on a real device, release mode is permanent. See [Lab safety and virtual eFuses](../introduction/#lab-safety-and-virtual-efuses).

**eFuse block plan:**

| Key block | Purpose | Where it lives |
|-----------|---------|----------------|
| `BLOCK_KEY0` | `HMAC_UP` (NVS encryption) | Real eFuse, burned in Assignment 2 |
| `BLOCK_KEY1` | `SECURE_BOOT_DIGEST0` | Emulated eFuse, written on first boot |
| `BLOCK_KEY2` | `XTS_AES_128_KEY` (flash encryption) | Emulated eFuse, generated on first boot |

The default key size, XTS-AES-128, needs one key block, and the bootloader picks the first free one.

**To start over:** repeat [Step 3](#step-3-erase-and-flash), which erases the flash and reflashes everything.

## Step 1: Enable flash encryption in menuconfig

Goal: add flash encryption in **development** mode while keeping HMAC NVS, Secure Boot, and virtual eFuses ([Development Mode (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html#development-mode)).

1. Run `idf.py menuconfig`.
2. Under **Component config → eFuse Bit Manager**, confirm **Simulate eFuse operations in RAM** and **Keep eFuses in flash** are still enabled.
3. Open **Security features**.
4. Enable **Enable flash encryption on boot** ([CONFIG_SECURE_FLASH_ENC_ENABLED](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-flash-enc-enabled)).
5. Set **Enable usage mode** to **Development (NOT SECURE)** ([CONFIG_SECURE_FLASH_ENCRYPTION_MODE_DEVELOPMENT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-flash-encryption-mode-development)).
6. Keep **Size of generated XTS-AES key** at the default, **AES-128 (256-bit key)**.
7. Leave **UART ROM download mode** at its default, and never select **Permanently disabled** on class boards.
8. Under **Component config → NVS Security Provider**, keep the key protection scheme on **Using HMAC peripheral** with key ID `0` from Assignment 2. Do not switch to **Using Flash Encryption**: that scheme needs an `nvs_keys` partition this project does not have.
9. Save, exit menuconfig, and confirm that `sdkconfig` contains:

```ini
CONFIG_SECURE_FLASH_ENC_ENABLED=y
CONFIG_SECURE_FLASH_ENCRYPTION_MODE_DEVELOPMENT=y
```

## Step 2: Make room for the larger bootloader

Goal: fit a bootloader that now contains both Secure Boot and flash encryption, and add a small encrypted partition for the raw-read test.

With both features, the bootloader is `0xC000` bytes. Between `0x2000` and the Assignment 3 partition table at `0xD000` there is only `0xB000`, so the build fails with `Bootloader binary size 0xc000 bytes is too large for partition table offset 0xd000`.

1. In menuconfig, set **Partition Table → Offset of partition table** to `0xF000`.
2. Replace `partitions.csv` with:

```csv
# Name,   Type, SubType, Offset,   Size,     Flags
nvs,      data, nvs,     0x10000,  0x6000,
efuse_em, data, efuse,   0x16000,  0x2000,
phy_init, data, phy,     0x18000,  0x1000,
storage,  data, 0xff,    0x19000,  0x1000,   encrypted
factory,  app,  factory, 0x20000,  0x200000,
```

`storage` is a custom data partition marked `encrypted`; Step 4 writes a test string to it. `nvs` and `efuse_em` must **not** be marked `encrypted`: NVS is protected by the HMAC scheme, and `efuse_em` must stay readable by the bootloader.

3. Run `idf.py build`. Expect `Bootloader binary size 0xc000 bytes. 0x1000 bytes (8%) free.`

Moving `efuse_em` drops the emulated Secure Boot state from Assignment 3, and moving `nvs` drops the stored Wi-Fi credentials. Both are rebuilt on the next first boot: the bootloader enables Secure Boot and flash encryption together, and `wifi_creds` stores the credentials again from menuconfig.

## Step 3: Erase and flash

Goal: start from clean flash so `efuse_em` is filled from the real eFuses, then flash the new bootloader and app.

> [!WARNING]
> **Stop and check before flashing.** Repeat the check from [Assignment 3, Step 5](../assignment-3/#step-5-erase-and-flash-signed-bootloader-and-application): `grep -E '^CONFIG_EFUSE_VIRTUAL(_KEEP_IN_FLASH)?=y' sdkconfig` must print both lines, and the build output must contain `Efuse virtual mode is enabled`. If either check fails, do not flash.

1. Erase the flash:

```bash
python -m esptool --chip esp32s31 -p PORT erase-flash
```

2. Flash the signed bootloader, then the partition table and app:

```bash
idf.py -p PORT bootloader-flash
idf.py -p PORT flash monitor
```

Use plain `idf.py flash`, not `idf.py encrypted-flash`. With virtual eFuses the hardware does not decrypt, so the images must stay plaintext in flash.

**First-boot behavior:** after `[Virtual] Loading virtual efuse blocks from real efuses`, the bootloader enables Secure Boot as in Assignment 3, then runs the flash encryption flow and resets. Watch for:

- `Checking flash encryption...`
- `Flash encryption completed`
- `Flash encryption not really completed. Must disable virtual efuses` (warning, virtual mode only)
- `Virtual efuses enabled: Not really burning eFuses`

After the reset, the app logs `Flash encryption mode is DEVELOPMENT (not secure)`, stores the Wi-Fi credentials again, and runs the TLS request. Do not power off during the first boot.

## Step 4: Add a raw-read check to the application

Goal: show what an authorized read and a raw flash read return for an `encrypted` partition.

1. Add `esp_partition` and `spi_flash` to `PRIV_REQUIRES` in `main/CMakeLists.txt`:

```cmake
idf_component_register(SRCS "https_mbedtls_example_main.c" "wifi_creds.c" "workshop_wifi_connect.c"
                    INCLUDE_DIRS "."
                    PRIV_REQUIRES esp_event nvs_flash esp_netif esp_wifi mbedtls bootloader_support efuse esp_partition spi_flash)
```

2. In `https_mbedtls_example_main.c`, add:

```c
#include "esp_partition.h"
#include "esp_flash.h"
#include "esp_flash_encrypt.h"

static void log_flash_encryption_demo(void)
{
    static const char test_str[32] = "workshop flash encryption test";
    char buf[sizeof(test_str)] = {0};
    const esp_partition_t *part = esp_partition_find_first(ESP_PARTITION_TYPE_DATA,
                                                           ESP_PARTITION_SUBTYPE_ANY, "storage");
    if (part == NULL) {
        ESP_LOGE(TAG, "Partition \"storage\" not found");
        return;
    }

    ESP_LOGI(TAG, "Flash encryption enabled: %s", esp_efuse_is_flash_encryption_enabled() ? "yes" : "no");
    ESP_LOGI(TAG, "Partition \"%s\" treated as encrypted: %s", part->label, part->encrypted ? "yes" : "no");

    ESP_ERROR_CHECK(esp_partition_erase_range(part, 0, part->size));
    ESP_ERROR_CHECK(esp_partition_write(part, 0, test_str, sizeof(test_str)));

    ESP_ERROR_CHECK(esp_partition_read(part, 0, buf, sizeof(buf)));
    ESP_LOGI(TAG, "esp_partition_read: %s",
             memcmp(buf, test_str, sizeof(test_str)) == 0 ? "matches test string" : "does not match test string");

    ESP_ERROR_CHECK(esp_flash_read(NULL, buf, part->address, sizeof(buf)));
    ESP_LOGI(TAG, "esp_flash_read (raw): %s",
             memcmp(buf, test_str, sizeof(test_str)) == 0 ? "matches test string (plaintext)" : "does not match test string (ciphertext)");
    ESP_LOG_BUFFER_HEXDUMP(TAG, buf, sizeof(buf), ESP_LOG_INFO);
}
```

The test string is 32 bytes because encrypted flash writes must be 16-byte aligned.

3. Extend `log_security_state()` from Assignment 3 with the flash encryption key block:

```c
    if (esp_efuse_find_purpose(ESP_EFUSE_KEY_PURPOSE_XTS_AES_128_KEY, &blk)) {
        ESP_LOGI(TAG, "XTS_AES_128_KEY in BLOCK_KEY%d", blk - EFUSE_BLK_KEY0);
    }
```

4. Call the new function in `app_main()` right after `log_security_state();`:

```c
    log_security_state();
    log_flash_encryption_demo();
```

5. Rebuild and run `idf.py -p PORT flash monitor`. The bootloader is unchanged, so you do not need `bootloader-flash` again.

**Expected output in this lab:**

```text
I (...) example: Secure Boot enabled: yes
I (...) example: HMAC_UP key in BLOCK_KEY0
I (...) example: SECURE_BOOT_DIGEST0 in BLOCK_KEY1
I (...) example: XTS_AES_128_KEY in BLOCK_KEY2
I (...) example: Flash encryption enabled: yes
I (...) example: Partition "storage" treated as encrypted: no
I (...) example: esp_partition_read: matches test string
I (...) example: esp_flash_read (raw): matches test string (plaintext)
```

## Step 5: Interpret the results

Goal: explain what virtual mode can and cannot show ([Encryption architecture](../lecture-4/#encryption-architecture)).

| Check | Expected in this lab (virtual eFuses) | Expected on a production device (real eFuses) |
|-------|---------------------------------------|-----------------------------------------------|
| `Flash encryption enabled` | `yes` (emulated) | `yes` |
| `storage` treated as encrypted | `no` | `yes` |
| `esp_partition_read` | Matches test string | Matches test string (decrypted by hardware) |
| `esp_flash_read` (raw) | Matches test string (plaintext) | Does not match (ciphertext) |
| Bootloader log | `Flash encryption not really completed. Must disable virtual efuses` | No such warning |

Why the raw read stays plaintext: with `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH`, ESP-IDF treats a partition as encrypted only if flash encryption is enabled in the **real** eFuses. Here it is enabled only in the emulated copy, so every write, including the bootloader's first-boot pass, goes to flash in plaintext. This is by design: if the real hardware does not decrypt, encrypted code could not run.

Run `idf.py -p PORT efuse-summary` and confirm that the **real** `SPI_BOOT_CRYPT_CNT` is still `Disable` (`0`), `SECURE_BOOT_EN` is still `False`, and `BLOCK_KEY1` and `BLOCK_KEY2` are still empty. This command reads silicon eFuses, not the emulated copy, so it proves both features stayed emulated.

## Step 6: Optional offline read check

Goal: see what an attacker with a flash dump would get.

1. Read the application partition into a file:

```bash
python -m esptool --chip esp32s31 -p PORT read-flash 0x20000 0x200000 app_dump.bin
```

2. Search the dump for a string from the firmware:

```bash
strings app_dump.bin | grep howsmyssl
```

In this lab you see `www.howsmyssl.com` and the HTTP request line, because nothing is encrypted. On a device with flash encryption enabled in real eFuses, the dump holds ciphertext and the search finds nothing.

Delete `app_dump.bin` afterwards. On a real product a dump can also contain secrets, so treat it like any other sensitive file.

## Step 7: Regression check

Goal: confirm that adding flash encryption did not break the earlier labs.

| Check | Expected |
|-------|----------|
| NVS encryption | `NVS partition "nvs" is encrypted.` |
| Wi-Fi | Credentials stored again after the erase, then loaded from NVS and connected |
| TLS | `esp-x509-crt-bundle: Certificate validated`, `Certificate verified.`, howsmyssl JSON |
| Secure Boot | `Verifying image signature...` in the bootloader log; `Secure Boot enabled: yes` |

Capture log excerpts for the **confidentiality of stored data** row in the [EU CRA overview](../overview-eu-cra) (see [CRA and product evidence](../lecture-4/#cra-and-product-evidence)). State clearly that the workshop results come from virtual eFuses and are not evidence of encryption at rest; that evidence has to come from production-configured devices.

## Step 8: Review production configuration (read only)

Goal: know what changes for manufacturing without performing it on workshop boards.

Read (do not execute on class kits):

- [Release Mode](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html#release-mode) and [Transitioning from Development to Release Mode](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html#transitioning-from-development-to-release-mode)
- [Enable Flash Encryption externally](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-flash-encryption-externally)
- [production provisioning appendix](../appendix-production-provisioning)

Note for your technical file:

- Production uses **release** mode, key custody, and often stricter UART/JTAG policy.
- Development mode plus virtual eFuses **must** be called out as non-production in risk assessments.

## Step 9: Validation matrix

| Test | Action | Expected |
|------|--------|----------|
| Configuration | Step 1 | `sdkconfig` has flash encryption (development), Secure Boot, HMAC NVS, virtual eFuses |
| Bootloader fits | Step 2 | `0xc000` bootloader with partition table at `0xF000` |
| First-boot flow | Step 3 | `Flash encryption completed`, then the virtual-mode warning |
| Raw read | Step 4 | `esp_flash_read` still plaintext; you can explain why |
| Real eFuses untouched | Step 5 | `efuse-summary`: `SPI_BOOT_CRYPT_CNT` `Disable`, `SECURE_BOOT_EN` `False` |
| Offline dump (optional) | Step 6 | `www.howsmyssl.com` visible in virtual mode |
| Regression | Step 7 | NVS, Wi-Fi, TLS, and Secure Boot still pass |

## What you learned

You should now be able to:

- Add **flash encryption** in **development** mode to a project that already uses HMAC NVS and Secure Boot V2
- Size the partition table for a bootloader with both features, and mark partitions `encrypted` correctly
- Explain first-boot encryption, **`SPI_BOOT_CRYPT_CNT`**, and the key block plan for all three keys
- Explain why raw reads and flash dumps stay plaintext with virtual eFuses, and what changes when real eFuses enable flash encryption
- Record configuration and boot logs for CRA-oriented **data at rest** documentation, with the virtual-mode limitation stated

## Previous and next steps

[Previous: Lecture 4](../lecture-4)

[Next: Assignment 5 (optional): Add secure OTA updates](../assignment-5)

[Skip to: Conclusion](../conclusion)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
