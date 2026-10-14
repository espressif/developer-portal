---
title: "Assignment 4: Enable and Verify Flash Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 12
showAuthor: false
---

## Assignment 4: Enable and verify flash encryption

In Assignments 1 to 3 you built a **https_mbedtls** product-style firmware with encrypted NVS and Secure Boot. This assignment uses a **separate** ESP-IDF example, [**flash_encryption**](https://github.com/espressif/esp-idf/tree/master/examples/security/flash_encryption), to focus on **whole-flash confidentiality**: encrypted vs plaintext partitions, first-boot enablement, and raw read checks. Read [Lecture 4](../lecture-4) for architecture and CRA context.

You enable flash encryption in **development** mode with **virtual** eFuses. Offline dumps in this mode are for **learning and test evidence**, not a guarantee of production release-mode behavior.

## Before you begin

**Example location:** `$IDF_PATH/examples/security/flash_encryption`

**Hardware:** [ESP32-S31-Function-CoreBoard-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-function-coreboard-1/user_guide.html).

**Commands:**

```bash
cd $IDF_PATH/examples/security/flash_encryption
idf.py set-target esp32s31
idf.py menuconfig
idf.py -p PORT build flash monitor
```

Replace `PORT` with your serial port. TODO: Pin a tested ESP-IDF v6.1 commit or workshop fork when the course repository is published.

> [!IMPORTANT]
> **Workshop mode: virtual eFuses.** Enable [CONFIG_EFUSE_VIRTUAL](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual) and [CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-efuse-virtual-keep-in-flash). Add an **`efuse_em`** row to the custom partition table (see Step 2). Do **not** use flash encryption **release** mode or `espefuse burn` on class boards.

**Switching from Assignment 3:** That lab used `examples/protocols/https_mbedtls` with Secure Boot. Before this assignment, run `idf.py -p PORT erase-flash` on the CoreBoard so old bootloaders and virtual eFuse state do not confuse the flash encryption example.

**Preflight:** After `idf.py build`, confirm in `sdkconfig`:

- `CONFIG_EFUSE_VIRTUAL=y`
- `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y`
- `CONFIG_PARTITION_TABLE_OFFSET=0xD000` (example default; required when flash encryption grows the bootloader)
- `CONFIG_SECURE_FLASH_ENCRYPTION_MODE_DEVELOPMENT=y` once flash encryption is enabled (Step 3)

**Forbidden:** Release mode, `espefuse burn`, burning real `SPI_BOOT_CRYPT_CNT` or flash encryption keys on silicon.

**Reset after lab (optional):** `idf.py -p PORT erase-flash` to clear virtual eFuse emulation in flash.

> [!WARNING]
> Release-mode settings can permanently restrict a device. Release mode is incompatible with `CONFIG_EFUSE_VIRTUAL`. Production enablement is in the [production provisioning appendix](../appendix-production-provisioning).

> [!NOTE]
> This example uses **NVS encryption with an `nvs_keys` partition** (flash-encryption-based NVS scheme), not the **HMAC NVS** path from [Assignment 2](../assignment-2). Both are valid product patterns; compare [Lecture 4](../lecture-4/#versus-secure-boot-and-nvs-encryption).

## Step 1: Prepare the example (partition table and virtual eFuses)

Goal: use the stock example layout plus workshop eFuse emulation ([Reference example architecture](../lecture-4/#reference-example-architecture)).

1. Run `idf.py menuconfig`.
2. **Partition Table → Partition Table:** Custom partition table CSV.
3. Confirm **Custom partition CSV file** is `partitions_example.csv` and **Offset of partition table** is **`0xD000`** (matches example [sdkconfig.defaults](https://github.com/espressif/esp-idf/blob/master/examples/security/flash_encryption/sdkconfig.defaults)).
4. Open `partitions_example.csv`. Add a virtual eFuse region (adjust sizes if your flash budget is tight):

```csv
efuse_em,      data, efuse,   , 0x2000,
```

Place it after the `nvs` line or another free slot; keep `factory`, `nvs_key`, `fat_encrypted`, and `fat_not_encr` from the upstream example.

5. **Component config → eFuse Bit Manager:** enable **Use virtual eFuses** and **Keep eFuses in flash**.
6. **Security features → Enable flash encryption on boot:** leave **disabled** for this step only (baseline build).
7. Save and run `idf.py build`.

## Step 2: Capture a plaintext baseline (flash encryption off)

Goal: see how the example behaves **before** hardware flash encryption is active.

1. Flash and monitor:

```bash
idf.py -p PORT flash monitor
```

2. In the log, find the flash encryption status section from `flash_encrypt_main.c` (encryption **disabled** or `SPI_BOOT_CRYPT_CNT` not yet set for encryption).

3. Follow **`example_fatfs`** logs for partition **`fat_not_encr`**:
   - Mount, write, and read the test string: `the quick brown fox jumped over the lazy dog`
   - Note **`Test string was found at offset`** on the **non-encrypted** FAT partition after `esp_partition_read` / search.

4. On **`fat_encrypted`**, the same FATFS read through the VFS should still show the string (file layer works). Note whether a raw read at the same offset still shows ASCII for the test string when flash encryption is **not** enabled yet (both may look like plaintext on the wire in this baseline).

5. Stop the monitor. You will **`erase-flash`** before enabling encryption so NVS key partitions start empty (required by the [example README](https://github.com/espressif/esp-idf/blob/master/examples/security/flash_encryption/README.md)).

```bash
idf.py -p PORT erase-flash
```

## Step 3: Enable flash encryption (development, virtual eFuses)

Goal: turn on first-boot encryption per [Development Mode (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html#development-mode).

1. Run `idf.py menuconfig`.
2. **Security features:**
   - Enable **Enable flash encryption on boot** ([CONFIG_SECURE_FLASH_ENC_ENABLED](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-flash-enc-enabled)).
   - **Enable usage mode:** **Development (NOT SECURE)** ([CONFIG_SECURE_FLASH_ENCRYPTION_MODE_DEVELOPMENT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-flash-encryption-mode-development)).
   - Leave UART ROM download mode in a **recoverable** workshop setting (do not permanently disable UART in class).
3. Confirm virtual eFuses remain enabled (Step 1).
4. With NVS encryption enabled for this example, ensure **`nvs_key`** exists in `partitions_example.csv` (upstream file already includes it). After `erase-flash`, the key partition is empty so keys can be generated on first boot.
5. Build and flash:

```bash
idf.py -p PORT flash monitor
```

6. **First boot:** the bootloader encrypts the bootloader image, app, and partitions marked `encrypted`, sets virtual **`SPI_BOOT_CRYPT_CNT`**, and resets. This can take up to a minute on large FAT regions. Watch for:
   - `Checking flash encryption...`
   - `flash encryption is enabled`
   - `Flash encryption mode is DEVELOPMENT (not secure)` (application warning)
   - Status print: `Flash encryption feature is enabled in DEVELOPMENT mode` and `SPI_BOOT_CRYPT_CNT` / eFuse value **`1`** (wording may vary slightly)

7. Let the device **reset and run the application** on the second boot. Do not power off during the first encryption cycle.

Optional workshop `sdkconfig.defaults` fragment (merge with example defaults):

```ini
CONFIG_EFUSE_VIRTUAL=y
CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y
CONFIG_SECURE_FLASH_ENC_ENABLED=y
CONFIG_SECURE_FLASH_ENCRYPTION_MODE_DEVELOPMENT=y
```

## Step 4: Verify confidentiality (FATFS and logs)

Goal: compare **authorized** file access with **raw flash** reads ([Encryption architecture](../lecture-4/#encryption-architecture)).

After flash encryption is active (Step 3 second boot), capture logs for:

| Check | Where to look | Expected |
|-------|----------------|----------|
| Encryption status | `example_print_flash_encryption_status` | Feature enabled, development mode |
| FAT on `fat_not_encr` | Tag `example_fatfs` | File read OK; raw read **`Data matches test string`** or test string found at offset |
| FAT on `fat_encrypted` | Tag `example_fatfs` | File read through VFS still OK (`Written to file` / `Read from file`) |
| Raw read on `fat_encrypted` | Same offset as plaintext partition | **`Data does not match test string`** and hex dump is not the ASCII sentence |
| NVS | `nvs_flash_init` / custom NVS logs | Default and `custom_nvs` init without `ESP_ERR_NVS_CORRUPT_KEY_PART` |
| Virtual eFuse | Boot log | Warning that virtual eFuse mode is for testing only |

Interpret results using [Flash Encryption Testing](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html#debug-efuse-unit-tests): with **`CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH`**, encrypt/decrypt through ESP-IDF flash APIs should behave consistently across reboots even though real silicon eFuses are not burned.

Run `idf.py -p PORT efuse-summary` and note emulated flash-encryption-related fields for your workshop notes (not as production proof).

## Step 5: Optional external read check

Goal: relate on-device logs to an **offline** dump mental model (instructor may provide a scripted dump tool).

If your instructor supplies a flash dump of the **`fat_encrypted`** region **after** Step 4:

- Search the dump for the ASCII test string. It should **not** appear contiguously as plaintext.
- Repeat on **`fat_not_encr`**; the string may still appear in plaintext on the unencrypted partition.

If you do not have a dump tool, the example’s `esp_flash_read` comparison in Step 4 is sufficient lab evidence.

Document screenshots or log lines for the **confidentiality of stored data** row in the [EU CRA overview](../overview-eu-cra) (see [CRA and product evidence](../lecture-4/#cra-and-product-evidence)).

## Step 6: Review production configuration (read only)

Goal: know what changes for manufacturing without performing it on workshop boards.

Read (do not execute on class kits):

- [Release Mode](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html#release-mode) and [Transitioning from Development to Release Mode](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/flash-encryption.html#transitioning-from-development-to-release-mode)
- [Enable Flash Encryption externally](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-flash-encryption-externally)
- [production provisioning appendix](../appendix-production-provisioning)

Note for your technical file:

- Production uses **release** mode, key custody, and often stricter UART/JTAG policy.
- Development mode plus virtual eFuses **must** be called out as non-production in risk assessments.

## Step 7: Validation matrix

| Test | Action | Expected |
|------|--------|----------|
| Baseline | Step 2 | Example runs with flash encryption off; FAT test string visible via API |
| First-boot encrypt | Step 3 | Bootloader encrypts; `SPI_BOOT_CRYPT_CNT` / status shows enabled |
| Encrypted raw FAT | Step 4 | `fat_encrypted` raw read does not match test string |
| Plain FAT | Step 4 | `fat_not_encr` raw read still matches test string |
| NVS + keys | Step 4 | No corrupt key partition after clean `erase-flash` |
| Virtual eFuse | Logs / summary | Virtual mode active; no `espefuse burn` |
| Recovery | Optional | `erase-flash` restores ability to repeat the lab |

## What you learned

You should now be able to:

- Run the **`flash_encryption`** example on ESP32-S31 with **development** mode and **virtual** eFuses
- Explain first-boot encryption, **`SPI_BOOT_CRYPT_CNT`**, and the **`encrypted`** partition flag
- Contrast **FATFS file reads** with **`esp_flash_read`** on encrypted vs plaintext partitions
- Describe how this lab differs from **HMAC NVS** (Assignment 2) and **Secure Boot** (Assignment 3)
- Record configuration, boot logs, and partition read tests for CRA-oriented **data at rest** evidence

## Previous and next steps

[Previous: Lecture 4](../lecture-4)

[Next: Conclusion](../conclusion)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
