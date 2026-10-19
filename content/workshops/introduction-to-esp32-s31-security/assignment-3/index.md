---
title: "Assignment 3: Enable and Verify Secure Boot V2"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 10
showAuthor: false
---

## Assignment 3: Enable and verify Secure Boot V2

In [Assignment 2](../assignment-2) you kept the [**https_mbedtls**](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_mbedtls) client, **encrypted NVS**, and **Wi-Fi credentials in NVS** (`wifi_creds.c`, `workshop_wifi_connect.c`). Here you add **Secure Boot V2** on the same project so only **signed** bootloader and application images run. You now turn on virtual eFuses so the Secure Boot trust anchors stay emulated in class.

Read [Lecture 3](../lecture-3) for the boot chain, keys vs digests, and CRA evidence themes. Official flow: [How to enable Secure Boot v2 (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#how-to-enable-secure-boot-v2).

## Before you begin

**Starting point:** Assignment 2 complete in the same project: HMAC NVS with the real `HMAC_UP` key in block 0, Wi-Fi credentials in NVS, and virtual eFuses still off. Do not run `set-target` again: it resets `sdkconfig`.

> [!IMPORTANT]
> **This assignment turns on virtual eFuses** (`CONFIG_EFUSE_VIRTUAL` and `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH`), so the Secure Boot digest and `SECURE_BOOT_EN` are only emulated. On first boot, ESP-IDF copies the real eFuses into the empty `efuse_em` partition, so the `HMAC_UP` key stays visible and encrypted NVS keeps working. Do **not** run `espefuse burn`, and never commit `secure_boot_signing_key.pem`. See [Lab safety and virtual eFuses](../introduction/#lab-safety-and-virtual-efuses).

**eFuse block plan:**

| Key block | Purpose | Where it lives |
|-----------|---------|----------------|
| `BLOCK_KEY0` | `HMAC_UP` (NVS encryption) | Real eFuse, burned in Assignment 2; copied into the emulated eFuses |
| `BLOCK_KEY1` | `SECURE_BOOT_DIGEST0` | Emulated eFuse only, written by the bootloader on first boot |

The bootloader writes the digest into the first free key block, so with `HMAC_UP` in block 0 it lands in block 1.

**To start over:** run `python -m esptool --chip esp32s31 -p PORT erase-flash`, then repeat [Step 5](#step-5-erase-and-flash-signed-bootloader-and-application). This clears the emulated Secure Boot state; the real HMAC key from Assignment 2 stays.

## Step 1: Confirm the Assignment 2 baseline

Goal: verify TLS and encrypted NVS still work **before** you change the boot path.

1. Run `idf.py -p PORT build flash monitor`.
2. Confirm Assignment 2 success criteria: encrypted `nvs`, Wi-Fi from NVS, TLS `esp-x509-crt-bundle: Certificate validated` and `Certificate verified.`, howsmyssl JSON.

If anything fails, fix Assignment 2 before enabling Secure Boot. Secure Boot changes flashing steps and makes unsigned images harder to recover without `erase-flash`.

## Step 2: Make room for the signed bootloader and the virtual eFuse partition

Goal: move the partition table so the larger Secure Boot bootloader fits, and add the `efuse_em` partition that stores emulated eFuses across reboots ([Virtual eFuses (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html#debug-efuse-unit-tests)).

On ESP32-S31 the second-stage bootloader starts at `0x2000`. With the default partition table offset (`0x8000`), the bootloader has only 24 KB. A bootloader built with Secure Boot is larger, and the build fails with `Bootloader binary size [..] is too large for partition table offset`. ESP-IDF's own security examples raise the offset to `0xD000` for this reason.

1. Run `idf.py menuconfig` and set **Partition Table → Offset of partition table** to `0xD000` ([CONFIG_PARTITION_TABLE_OFFSET](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-partition-table-offset)). Keep the custom partition table CSV and the 16 MB flash size from [Assignment 2](../assignment-2/#if-the-app-does-not-fit-the-factory-partition).
2. Replace `partitions.csv` with the layout below. Every partition must start after the partition table (`0xD000` + `0x1000`), and `factory` stays on a 64 KB boundary:

```csv
# Name,   Type, SubType, Offset,   Size,     Flags
nvs,      data, nvs,     0xE000,   0x6000,
efuse_em, data, efuse,   0x14000,  0x2000,
phy_init, data, phy,     0x16000,  0x1000,
factory,  app,  factory, 0x20000,  0x200000,
```

3. Rebuild once: `idf.py build`.

The `nvs` partition moves, and Step 5 erases the flash anyway, so the encrypted Wi-Fi credentials from Assignment 2 are gone. On the next boot, `wifi_creds` copies them from menuconfig again (`Stored lab Wi-Fi credentials in encrypted NVS`). This is expected. The HMAC key lives in real eFuse, so the new NVS contents are still encrypted with keys derived from it.

## Step 3: Generate a development signing key

Goal: create an RSA-3072 **lab** private key used only to sign bootloader and app images in this course.

1. From the project directory, generate a key (ESP-IDF v6.1):

```bash
idf.py secure-generate-signing-key --version 2 --scheme rsa3072 secure_boot_signing_key.pem
```

Equivalent: `espsecure generate-signing-key --version 2 --scheme rsa3072 secure_boot_signing_key.pem` ([Enable Secure Boot v2 externally](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-secure-boot-v2-externally)).

2. Add to `.gitignore`:

```
secure_boot_signing_key.pem
*.pem
```

> [!WARNING]
> Never use this PEM in production or reuse it as a product root of trust.

## Step 4: Enable Secure Boot V2 in menuconfig

Goal: turn on Secure Boot V2 with the RSA scheme in the **bootloader** build, while keeping virtual eFuses (see [Keys, signing, and eFuses](../lecture-3/#keys-signing-and-efuses)).

1. Run `idf.py menuconfig`.
2. **First**, under **Component config → eFuse Bit Manager**, enable **Simulate eFuse operations in RAM** (`CONFIG_EFUSE_VIRTUAL`) and **Keep eFuses in flash** (`CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH`). Do this before touching Secure Boot, so there is never a saved configuration with Secure Boot on and virtual eFuses off.
3. Open **Security features**.
4. Enable **Enable hardware Secure Boot in bootloader** ([CONFIG_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot)).
5. Confirm the Secure Boot version is **Enable Secure Boot version 2** ([CONFIG_SECURE_BOOT_V2_ENABLED](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot-v2-enabled)) and the app signing scheme is **RSA** ([CONFIG_SECURE_SIGNED_APPS_RSA_SCHEME](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-signed-apps-scheme)). ESP32-S31 supports RSA-3072 only, so there is no key length to choose.
6. Keep **Sign binaries during build** enabled ([CONFIG_SECURE_BOOT_BUILD_SIGNED_BINARIES](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot-build-signed-binaries)) and set **Secure boot private signing key** to `secure_boot_signing_key.pem` (path relative to the project root).
7. Leave **UART ROM download mode** at its default. On ESP32-S31, ESP-IDF v6.1 does not support Secure download mode yet, so the default is **Enabled (not recommended)**. On SoCs that support it, such as ESP32-C5, the default is **Permanently switch to Secure mode (recommended)**, and with virtual eFuses that switch is only emulated, so the real download mode stays usable for reflashing. Never select **Permanently disabled** on class boards. Production choices are in the appendix and [How to enable Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#how-to-enable-secure-boot-v2).
8. Save, exit menuconfig, and confirm that `sdkconfig` now contains:

```ini
CONFIG_EFUSE_VIRTUAL=y
CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y
CONFIG_SECURE_BOOT=y
CONFIG_SECURE_BOOT_V2_ENABLED=y
CONFIG_SECURE_SIGNED_APPS_RSA_SCHEME=y
```

`CONFIG_SECURE_BOOT` builds a bootloader that enables Secure Boot. It does not set the `SECURE_BOOT_EN` eFuse itself: the bootloader writes `SECURE_BOOT_EN` and the key digest on its first boot in [Step 5](#step-5-erase-and-flash-signed-bootloader-and-application). With virtual eFuses enabled, both go to the emulated eFuses.

Optional `sdkconfig.defaults` additions (merge with Assignment 2):

```ini
CONFIG_PARTITION_TABLE_OFFSET=0xD000
CONFIG_SECURE_BOOT=y
CONFIG_SECURE_BOOT_V2_ENABLED=y
CONFIG_SECURE_SIGNED_APPS_RSA_SCHEME=y
CONFIG_SECURE_BOOT_BUILD_SIGNED_BINARIES=y
CONFIG_SECURE_BOOT_SIGNING_KEY="secure_boot_signing_key.pem"
CONFIG_EFUSE_VIRTUAL=y
CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y
```

ESP-IDF reads `sdkconfig.defaults` only when it creates a new `sdkconfig`. If `sdkconfig` already exists (it does after Assignment 2), adding these lines changes nothing. Either set the options in menuconfig as above, or delete `sdkconfig` and run `idf.py reconfigure`. The check at the start of Step 5 catches both cases.

9. Run `idf.py build`. Fix missing signing key or partition size errors before flashing. If the bootloader still does not fit, raise the partition table offset again (keep it a multiple of `0x1000`) and shift `nvs`, `efuse_em`, and `phy_init` by the same amount.
10. Confirm that both images carry a signature block:

```bash
espsecure signature-info-v2 build/bootloader/bootloader.bin
espsecure signature-info-v2 build/<project-name>.bin
```

Each command should report one RSA signature block. Use the application binary name printed at the end of the build.

## Step 5: Erase and flash signed bootloader and application

Goal: start from clean flash and follow the ESP-IDF Secure Boot flash order. With [CONFIG_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot) enabled, **`idf.py flash` does not flash the bootloader**.

> [!WARNING]
> **Stop and check before flashing.** The first boot of a Secure Boot bootloader writes the Secure Boot eFuses. If the bootloader was built without virtual eFuses, those writes go to the real SoC and cannot be undone. Run:
>
> ```bash
> grep -E '^CONFIG_EFUSE_VIRTUAL(_KEEP_IN_FLASH)?=y' sdkconfig
> ```
>
> It must print both `CONFIG_EFUSE_VIRTUAL=y` and `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y`. The output of your last `idf.py build` must also contain `Efuse virtual mode is enabled. If Secure boot or Flash encryption is on it does not provide any security. FOR TESTING ONLY!`. If either check fails, **do not flash the bootloader**. Fix the configuration, rebuild, and check again.

1. Erase the flash with esptool directly:

```bash
python -m esptool --chip esp32s31 -p PORT erase-flash
```

This step is required. The new `efuse_em` region overlaps flash that held other data before, such as the old application. ESP-IDF treats any non-erased content there as saved eFuse state and loads it instead of copying the real eFuses. All key blocks then look used, and the first boot fails with `Not enough unused key blocks available`. Erasing flash does not touch the real HMAC key.

Do not use `idf.py erase-flash` here. Enabling `CONFIG_SECURE_BOOT` also enables `CONFIG_ESPTOOLPY_NO_STUB`, so `idf.py` runs esptool without its flasher stub, and the ROM alone cannot erase the whole flash (`ROM does not support function erase_flash`). Calling esptool directly uses the stub. This works because, with virtual eFuses, the real download mode is not locked.

2. Flash the signed bootloader:

```bash
idf.py -p PORT bootloader-flash
```

Alternatively, run `idf.py bootloader` and copy the `esptool ... write-flash` command it prints. On ESP32-S31 the bootloader offset is `0x2000`, so the command has this shape:

```bash
python -m esptool --chip esp32s31 -p PORT write-flash 0x2000 build/bootloader/bootloader.bin
```

3. Flash the partition table and the signed application:

```bash
idf.py -p PORT flash
```

4. Open the monitor:

```bash
idf.py -p PORT monitor
```

**First-boot behavior (virtual eFuses):** the bootloader finds `efuse_em` empty and logs `[Virtual] Loading virtual efuse blocks from real efuses`. It then writes the public-key digest of your signing key and `SECURE_BOOT_EN` to the **emulated** eFuses, and the eFuse driver logs `Virtual efuses enabled: Not really burning eFuses`. If that line is missing, stop and tell the instructor before resetting the board again. It then verifies the app (`Verifying image signature...`), and boots it. The application logs `eFuse virtual mode is enabled. If Secure boot or Flash encryption is enabled then it does not provide any security. FOR TESTING ONLY!`. On later boots you see `[Virtual] Loading virtual efuse blocks from flash` instead. If power is lost during the first boot, reset and let the sequence finish ([How to enable Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#how-to-enable-secure-boot-v2)).

ESP-IDF also runs `esp_secure_boot_init_checks()` automatically during application startup. With default settings it revokes the unused digest slots (`SECURE_BOOT_DIGEST1` and `SECURE_BOOT_DIGEST2`), again only in the emulated eFuses.

## Step 6: Log the emulated security state from the application

Goal: keep Assignment 2 application logic and print the Secure Boot and key block state the firmware actually sees.

`idf.py efuse-summary` talks to the real eFuses through the ROM, so it cannot show the emulated Secure Boot state. Read it from the application instead.

First, add `bootloader_support` (provides `esp_secure_boot.h`) and `efuse` to `PRIV_REQUIRES` in `main/CMakeLists.txt`. Without them the build fails with `esp_secure_boot.h: No such file or directory`.

```cmake
idf_component_register(SRCS "https_mbedtls_example_main.c" "wifi_creds.c" "workshop_wifi_connect.c"
                    INCLUDE_DIRS "."
                    PRIV_REQUIRES esp_event nvs_flash esp_netif esp_wifi mbedtls bootloader_support efuse)
```

Then, in `https_mbedtls_example_main.c`, add:

```c
#include "esp_secure_boot.h"
#include "esp_efuse.h"

static void log_security_state(void)
{
    esp_efuse_block_t blk;

    ESP_LOGI(TAG, "Secure Boot enabled: %s", esp_secure_boot_enabled() ? "yes" : "no");
    if (esp_efuse_find_purpose(ESP_EFUSE_KEY_PURPOSE_HMAC_UP, &blk)) {
        ESP_LOGI(TAG, "HMAC_UP key in BLOCK_KEY%d", blk - EFUSE_BLK_KEY0);
    }
    if (esp_efuse_find_purpose(ESP_EFUSE_KEY_PURPOSE_SECURE_BOOT_DIGEST0, &blk)) {
        ESP_LOGI(TAG, "SECURE_BOOT_DIGEST0 in BLOCK_KEY%d", blk - EFUSE_BLK_KEY0);
    }
}
```

Call it in `app_main()` after `nvs_flash_init()` succeeds and **before** Wi-Fi connect:

```c
void app_main(void)
{
    esp_err_t ret = nvs_flash_init();
    /* ... existing erase/retry from Assignment 2 ... */
    ESP_ERROR_CHECK(ret);

    log_security_state();

    ESP_ERROR_CHECK(wifi_creds_provision_from_menuconfig_if_missing());
    /* ... rest unchanged: esp_netif_init, workshop_wifi_connect, https_get_task ... */
}
```

With `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH`, `esp_secure_boot_enabled()` and `esp_efuse_find_purpose()` read the emulated eFuses. Rebuild and run `idf.py -p PORT flash monitor` (the bootloader is unchanged, so `idf.py flash` is enough). Expected:

```text
I (...) example: Secure Boot enabled: yes
I (...) example: HMAC_UP key in BLOCK_KEY0
I (...) example: SECURE_BOOT_DIGEST0 in BLOCK_KEY1
```

Do **not** remove NVS encryption, `wifi_creds`, or the TLS task.

## Step 7: Verify boot, real eFuses, and Assignment 2 regression

Goal: prove Secure Boot is active in emulation, the real eFuses are untouched, and **encrypted NVS + TLS** still work on the signed image.

1. Check the emulated state in the log from Step 6 and the first-boot messages from Step 5. Treat this as **lab state**, not manufacturing proof.

2. Run `idf.py -p PORT efuse-summary`. This reads the **real** eFuses. Confirm that `SECURE_BOOT_EN` is still `False`, `BLOCK_KEY0` still shows `HMAC_UP` from Assignment 2, and `BLOCK_KEY1` is still empty with purpose `USER`. This is your evidence that Secure Boot stayed emulated.

3. Reboot twice (`idf.py -p PORT monitor`, press EN/RST). Signed firmware should boot each time.

4. Confirm **Assignment 2** behavior still passes:

| Check | Expected |
|-------|----------|
| NVS encryption | `NVS partition "nvs" is encrypted.` |
| Wi-Fi | Credentials stored again from menuconfig after the erase, then loaded from NVS and connected |
| TLS | `esp-x509-crt-bundle: Certificate validated`, `Certificate verified.`, howsmyssl JSON |

Capture log excerpts for workshop notes and the **integrity / unauthorized firmware** row in the [EU CRA overview](../overview-eu-cra).

## Step 8 (optional): Test rejection of bad firmware

Goal: document **fail-closed** boot when the application image does not verify (see [Secure Boot V2 process](../lecture-3/#secure-boot-v2-process)).

Use a **spare** board or plan to erase the flash and repeat Step 5 afterward.

**Option A (recommended): corrupt the signed app in flash**

1. Note the factory app offset from `idf.py partition-table` (`0x20000` with the Step 2 layout).
2. Overwrite a few bytes inside the application image. Pick an offset well inside the app binary, not past its end, for example `0x30000`:

```bash
python -c "open('corrupt.bin','wb').write(b'\\x00' * 16)"
python -m esptool --chip esp32s31 -p PORT write-flash 0x30000 corrupt.bin
```

`esptool` erases the whole 4 KB sector before writing, which damages the image even more. That is fine for this test.

3. Reset and watch the serial log. After `Verifying image signature...` the bootloader reports a hash or signature failure, and there is **no** normal application log (no TLS task, no Wi-Fi success).

4. Restore with `idf.py -p PORT flash`. The bootloader and the emulated eFuses are unchanged, so reflashing the signed app is enough.

**Option B: flash an app signed with a different key**

1. Generate `wrong_key.pem` with the Step 3 command (do not commit it).
2. Temporarily point **Secure boot private signing key** at `wrong_key.pem`, run `idf.py build`, then `idf.py -p PORT flash`. This flashes only the app; the bootloader on the board still trusts the digest of your original key. Do not run `idf.py bootloader-flash` here, or with any build whose `sdkconfig` you have not checked for virtual eFuses.
3. Reset and observe the rejection. The new key's digest is not in the emulated eFuses, and the other digest slots were revoked in Step 5, so the app cannot boot.
4. Point the setting back to `secure_boot_signing_key.pem`, rebuild, and run `idf.py -p PORT flash`.

Record: test method, log output, and recovery steps. This is core **CRA-oriented test evidence** for unauthorized firmware (see [CRA and product evidence](../lecture-3/#cra-and-product-evidence)).

> [!NOTE]
> In this lab only the bootloader-to-app check is exercised. The real `SECURE_BOOT_EN` eFuse stays off, so the ROM does not verify the bootloader itself. On a production device with hardware Secure Boot, a modified bootloader is rejected by the ROM as well.

## Step 9: Validation matrix

| Test | Action | Expected |
|------|--------|----------|
| Baseline | Step 1 | Assignment 2 TLS + NVS OK before Secure Boot |
| Signed images | Step 4 | `signature-info-v2` shows one RSA signature block on bootloader and app |
| Signed boot | Step 5 | `Verifying image signature...`, app runs, virtual eFuse warning present |
| Emulated state | Step 6 | Secure Boot enabled: yes; `HMAC_UP` in block 0; `SECURE_BOOT_DIGEST0` in block 1 |
| Real eFuses untouched | Step 7 | `efuse-summary`: `SECURE_BOOT_EN` False, `BLOCK_KEY1` empty |
| NVS + TLS regression | Step 7 | Same as Assignment 2 after Secure Boot |
| Rejection (optional) | Step 8 | Tampered or wrong-key app does not run product code |

## What you learned

You should now be able to:

- Enable **Secure Boot V2 (RSA-3072)** on the same **https_mbedtls + encrypted NVS** project from Assignments 1 and 2
- Size the partition table for a larger signed bootloader and add an `efuse_em` partition
- Generate and protect a **development signing key** separate from production HSM policy
- Flash **bootloader** and **application** in the order ESP-IDF requires when `CONFIG_SECURE_BOOT` is on
- Tell the **emulated** Secure Boot state (application log) apart from the **real** eFuses (`idf.py efuse-summary`)
- Demonstrate **rejection** of unsigned or invalid application images (optional Step 8)
- Relate configuration, signing policy, boot logs, and rejection tests to the Secure Boot row in the [EU CRA overview](../overview-eu-cra)

## Previous and next steps

[Previous: Lecture 3](../lecture-3)

[Next: Lecture 4: Flash encryption](../lecture-4)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
