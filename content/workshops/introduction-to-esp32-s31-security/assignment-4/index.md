---
title: "Assignment 4: Enable and Verify Flash Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 12
showAuthor: false
---

## Assignment 4: Enable and verify flash encryption

In Assignments 1 to 3 you built one product-style firmware on the [**https_mbedtls**](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_mbedtls) client: TLS with the certificate bundle, Wi-Fi credentials in NVS, and **Secure Boot V2**. Here you add **flash encryption** in **release** mode and turn NVS encryption back on, protected by the flash encryption key. The result is the production configuration of the workshop firmware. Read [Lecture 4](../lecture-4) for architecture and CRA context.

You run the firmware in the ESP32 emulator, which encrypts the emulated flash exactly as the chip would. The raw reads in this assignment therefore show real ciphertext.

## Before you begin

**Starting point:** Assignment 3 complete in the same project: Secure Boot V2, the signing key, and the `log_security_state()` helper from [Assignment 3, Step 4](../assignment-3/#step-4-log-the-secure-boot-state-from-the-application).

> [!WARNING]
> **Do not flash this firmware to your board.** On first boot it permanently enables Secure Boot and flash encryption in release mode, and disables ROM download mode and JTAG. Run it only in the emulator. See [Lab safety and the ESP32 emulator](../introduction/#lab-safety-and-the-esp32-emulator).

**eFuse block plan:** each emulator run starts with a blank chip, and the bootloader fills the key blocks in order:

| Key block | Purpose | Written by |
|-----------|---------|------------|
| `BLOCK_KEY0` | `SECURE_BOOT_DIGEST0` | Bootloader, first boot (Secure Boot) |
| `BLOCK_KEY1` | `XTS_AES_128_KEY` (purpose 4) | Bootloader, first boot (flash encryption) |
| none | NVS encryption keys | App, first boot, stored in the encrypted `nvs_keys` partition |

The default key size, XTS-AES-128, needs one key block.

## Step 1: Enable flash encryption and NVS encryption

Goal: turn on flash encryption in **release** mode and protect the NVS keys with it ([Release Mode (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html#release-mode)).

1. Open the project configuration:

{{< tabs group="workflow" >}}
  {{< tab label="CLI" >}}
```bash
idf.py menuconfig
```
  {{< /tab >}}
  {{< tab label="CLion" >}}
CLion instructions will be added soon.
  {{< /tab >}}
{{< /tabs >}}

2. Open **Security features**.
3. Enable **Enable flash encryption on boot** ([CONFIG_SECURE_FLASH_ENC_ENABLED](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-flash-enc-enabled)).
4. Set **Enable usage mode** to **Release** ([CONFIG_SECURE_FLASH_ENCRYPTION_MODE_RELEASE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-flash-encryption-mode-release)). Development mode keeps a way to reflash plaintext over serial, which a product must not have.
5. Keep **Size of generated XTS-AES key** at the default, **AES-128 (256-bit key)**.
6. Open **Component config → NVS** and enable **Enable NVS encryption** again.
7. Open **Component config → NVS Security Provider** and set **NVS Encryption: Key Protection Scheme** to **Using Flash Encryption** ([CONFIG_NVS_SEC_KEY_PROTECT_USING_FLASH_ENC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-key-protect-using-flash-enc)).
8. Save and exit.

In `sdkconfig.defaults`, replace `# CONFIG_NVS_ENCRYPTION is not set` and add the new lines, so the security part of the file reads:

```ini
CONFIG_SECURE_BOOT=y
CONFIG_SECURE_BOOT_V2_ENABLED=y
CONFIG_SECURE_SIGNED_APPS_RSA_SCHEME=y
CONFIG_SECURE_BOOT_BUILD_SIGNED_BINARIES=y
CONFIG_SECURE_BOOT_SIGNING_KEY="secure_boot_signing_key.pem"
CONFIG_SECURE_DISABLE_ROM_DL_MODE=y
CONFIG_SECURE_FLASH_ENC_ENABLED=y
CONFIG_SECURE_FLASH_ENCRYPTION_MODE_RELEASE=y
CONFIG_NVS_ENCRYPTION=y
CONFIG_NVS_SEC_KEY_PROTECT_USING_FLASH_ENC=y
```

**Why this NVS scheme here:** with the flash encryption scheme, the app generates random NVS keys on first boot and stores them in the `nvs_keys` partition, which flash encryption protects. No eFuse key block is needed, so it works even though Secure Boot has already locked eFuse read protection (see [Assignment 3, Step 1](../assignment-3/#step-1-turn-off-nvs-encryption-for-this-assignment)). The HMAC scheme from Assignment 2 is still a valid production choice, as long as the factory burns the HMAC key before the first boot. Lecture 2 compares the two schemes.

## Step 2: Check the partition table

Goal: confirm that the layout from Assignment 2 already fits flash encryption.

You do not need to change `partitions.csv`. Check these points against it:

- **Bootloader size:** with Secure Boot and flash encryption, the bootloader is `0xC000` bytes. It fits between `0x2000` and the partition table at `0x10000`.
- **`nvs_keys` is `encrypted`:** the NVS keys must never sit in flash as plaintext, so ESP-IDF requires this flag on the `nvs_keys` partition.
- **`nvs` is not marked `encrypted`:** NVS encrypts its own entries with the keys from `nvs_keys`. Flash encryption cannot be applied on top, because NVS writes in units smaller than the encryption block.
- **`storage` is `encrypted`:** you write a test string to it in Step 3.
- **App partitions:** all `app` partitions are always encrypted when flash encryption is on, without a flag.

## Step 3: Add a raw-read check to the application

Goal: show what an authorized read and a raw flash read return for an `encrypted` partition.

1. Add `spi_flash` to `PRIV_REQUIRES` in `main/CMakeLists.txt`:

```cmake
idf_component_register(SRCS "https_mbedtls_example_main.c" "wifi_creds.c" "workshop_wifi_connect.c"
                    INCLUDE_DIRS "."
                    PRIV_REQUIRES esp_event nvs_flash esp_netif esp_wifi mbedtls efuse esp_partition bootloader_support spi_flash)
```

2. In `https_mbedtls_example_main.c`, add:

```c
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

The test string is 32 bytes because encrypted flash writes must be 16-byte aligned. `esp_partition_read()` decrypts through the hardware; `esp_flash_read()` returns the bytes as stored in flash.

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

Keep the `dump_nvs_prefix()` call from Assignment 2: in Step 5 it shows that the Wi-Fi password is no longer readable.

## Step 4: Build and merge the images

Goal: build the signed images and merge them into one emulator image, as in Assignment 3.

{{< tabs group="workflow" >}}
  {{< tab label="CLI" >}}
```bash
idf.py build
python -m esptool --chip esp32s31 merge-bin -o build/merged-secure.bin \
  --flash-mode dio --flash-size 4MB \
  0x2000  build/bootloader/bootloader.bin \
  0x10000 build/partition_table/partition-table.bin \
  0x17000 build/ota_data_initial.bin \
  0x20000 build/<project-name>.bin
```
  {{< /tab >}}
  {{< tab label="CLion" >}}
CLion instructions will be added soon.
  {{< /tab >}}
{{< /tabs >}}

Expect `Bootloader binary size 0xc000 bytes. 0x2000 bytes (14%) free.` The merged image is **plaintext**: the bootloader encrypts it in place on first boot. That is also how a production line programs a blank chip.

## Step 5: Run in the emulator

Goal: watch the first boot encrypt the flash, then read the evidence.

1. Reload the [ESP32 emulator](https://espressif.github.io/esp-emulator/) page, so you start with a blank chip.
2. Select the chip **esp32s31**, load `build/merged-secure.bin`, and start the emulator. Do not reset during the first boot.

**First boot.** The bootloader enables Secure Boot exactly as in Assignment 3, then generates the flash encryption key and encrypts every encrypted partition in place:

```log
I (...) secure_boot_v2: Secure boot permanently enabled
I (...) boot: Checking flash encryption...
I (...) flash_encrypt: Generating new flash encryption key...
I (...) efuse: Writing EFUSE_BLK_KEY1 with purpose 4
I (...) flash_encrypt: Disable UART bootloader encryption...
I (...) flash_encrypt: Disable UART bootloader cache...
I (...) flash_encrypt: Disable JTAG...
I (...) flash_encrypt: bootloader encrypted successfully
I (...) flash_encrypt: partition table encrypted and loaded successfully
I (...) flash_encrypt: Encrypting partition 1 at offset 0x17000 (length 0x2000)...
I (...) flash_encrypt: Encrypting partition 3 at offset 0x1a000 (length 0x1000)...
I (...) flash_encrypt: Encrypting partition 4 at offset 0x1b000 (length 0x1000)...
I (...) flash_encrypt: Encrypting partition 5 at offset 0x20000 (length 0x111000)...
E (...) esp_image: image at 0x1e0000 has invalid magic byte (nothing flashed here?)
I (...) flash_encrypt: Setting CRYPT_CNT for permanent encryption
I (...) flash_encrypt: Flash encryption completed
I (...) boot: Resetting with flash encryption enabled...
```

The error for `0x1e0000` is expected: `ota_1` is empty, so there is nothing to encrypt there.

**After the reset.** The bootloader runs from encrypted flash, and the app creates the NVS keys:

```log
I (...) flash_encrypt: flash encryption is enabled (0 plaintext flashes left)
I (...) flash_encrypt: Flash encryption mode is RELEASE
I (...) nvs_sec_provider: NVS Encryption - Registering Flash encryption-based scheme...
W (...) nvs: Failed to read NVS security cfg: [0x1116] (ESP_ERR_NVS_KEYS_NOT_INITIALIZED)
I (...) nvs: Generating NVS encr-keys...
I (...) nvs: NVS partition "nvs" is encrypted.
I (...) example: Secure Boot enabled: yes
I (...) example: SECURE_BOOT_DIGEST0 in BLOCK_KEY0
I (...) example: XTS_AES_128_KEY in BLOCK_KEY1
I (...) example: Flash encryption enabled: yes
I (...) example: Partition "storage" treated as encrypted: yes
I (...) example: esp_partition_read: matches test string
I (...) example: esp_flash_read (raw): does not match test string (ciphertext)
I (...) wifi_creds: Stored lab Wi-Fi credentials in NVS
I (...) nvs_raw: ...   f2 b9 1c 04 51 6f ee ea  50 23 e3 80 ff 9d 5b 70  |....Qo..P#....[p|
I (...) workshop_wifi: Connected using credentials from NVS
E (...) example: mbedtls_net_connect returned -52
```

The `ESP_ERR_NVS_KEYS_NOT_INITIALIZED` warning appears once: `nvs_keys` is empty, so the app generates the keys and writes them. Search the `nvs_raw` dump for `myssid` or `mypassword`: neither appears. The TLS error is expected in the browser emulator.

3. Reset the emulated chip without loading a new image. This time there is no key generation, and the app loads the stored credentials from encrypted NVS.

## Step 6: Interpret the results

Goal: connect each result to the protection it proves ([Encryption architecture](../lecture-4/#encryption-architecture-esp32-s31)).

| Check | Expected | What it proves |
|-------|----------|----------------|
| `Writing EFUSE_BLK_KEY1 with purpose 4` | Once, on first boot | The XTS-AES key was generated on the chip and never left it |
| `0 plaintext flashes left` and `mode is RELEASE` | After the reset | Plaintext can no longer be flashed, and serial encryption and decryption are disabled |
| `esp_partition_read` | Matches the test string | Authorized code reads plaintext through the hardware |
| `esp_flash_read` (raw) | Ciphertext | A flash dump only contains ciphertext |
| `nvs_raw` dump | No readable SSID or password | NVS entries are encrypted with keys from `nvs_keys` |
| `nvs_keys` | Encrypted by the first-boot pass | The NVS keys are protected by the flash encryption key |

### Emulator and real board

| Aspect | ESP32 emulator | Real ESP32-S31 board |
|--------|----------------|----------------------|
| eFuses | Blank on every page load; burns last only for the session | Burned permanently |
| Flash encryption | Real XTS-AES encryption of the emulated flash | Same, on the external flash chip |
| Updating firmware after first boot | Load a new image (fresh chip) | Only signed OTA updates; serial flashing is disabled |
| Wi-Fi and TLS | Emulated access point, no internet | Your network and the internet |
| Recovery from a mistake | Reload the page | None: the chip is permanently configured |

Capture log excerpts for the **confidentiality of stored data** row in the [EU CRA overview](../overview-eu-cra) (see [CRA and product evidence](../lecture-4/#cra-and-product-evidence)).

## Step 7: Regression check

Goal: confirm that adding flash encryption did not break the earlier labs.

| Check | Expected |
|-------|----------|
| Secure Boot | `Signature verified successfully!` in the bootloader log; `Secure Boot enabled: yes` |
| NVS encryption | `NVS partition "nvs" is encrypted.` |
| Wi-Fi | Credentials stored, then loaded from NVS; `Connected using credentials from NVS` |
| TLS | The request starts; `-52` is the expected result without internet |

## Step 8: Review the production flow (read only)

Goal: know what changes on a manufacturing line.

- **Programming:** the factory writes the same plaintext merged image to a blank chip, and the first boot does what you just watched. See the [real-board appendix](../appendix-production-provisioning) for the commands and checks, and [Enable Flash Encryption externally](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-flash-encryption-externally) for host-generated keys.
- **Updates in the field:** with release mode and ROM download mode disabled, the only way to change the firmware is a signed OTA update. [Assignment 5](../assignment-5) adds one.
- **HMAC NVS instead:** if you prefer the HMAC scheme, burn the HMAC key from the host before the first boot, for example with `espefuse burn-key BLOCK_KEY0 hmac_key.bin HMAC_UP`.
- **Per-device secrets:** Wi-Fi or cloud credentials must be provisioned per device, not compiled into `sdkconfig`.

## Step 9: Validation matrix

| Test | Action | Expected |
|------|--------|----------|
| Configuration | Step 1 | Secure Boot, flash encryption in release mode, NVS encryption with the flash encryption scheme |
| Bootloader fits | Step 4 | `0xc000` bootloader below the partition table at `0x10000` |
| First boot | Step 5 | `Flash encryption completed`, then `0 plaintext flashes left` and `mode is RELEASE` |
| Key blocks | Step 5 | `SECURE_BOOT_DIGEST0 in BLOCK_KEY0`, `XTS_AES_128_KEY in BLOCK_KEY1` |
| Raw read | Step 5 | `esp_flash_read` returns ciphertext |
| NVS | Step 5 | `NVS partition "nvs" is encrypted.`, no credentials in `nvs_raw` |
| Regression | Step 7 | Secure Boot, NVS, Wi-Fi, and TLS still pass |

## What you learned

You should now be able to:

- Add **flash encryption** in **release** mode to a project that already uses Secure Boot V2
- Choose an NVS encryption scheme that fits the eFuse burn order, and explain the role of `nvs_keys`
- Mark partitions `encrypted` correctly, and explain why `nvs` is not marked
- Read the first-boot log: key generation, in-place encryption, and `SPI_BOOT_CRYPT_CNT` set for permanent encryption
- Show with a raw read that flash holds ciphertext while authorized reads return plaintext
- Record configuration and boot logs for CRA-oriented **data at rest** documentation

## Previous and next steps

[Previous: Lecture 4](../lecture-4)

[Next: Assignment 5 (optional): Add secure OTA updates](../assignment-5)

[Skip to: Conclusion](../conclusion)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
