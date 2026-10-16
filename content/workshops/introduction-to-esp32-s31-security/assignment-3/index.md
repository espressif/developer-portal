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

**Starting point:** Assignment 2 complete under `$IDF_PATH/examples/protocols/https_mbedtls` (or your workshop fork): certificate bundle, HMAC NVS with a real `HMAC_UP` key in block 0, `workshop_wifi` credentials, and virtual eFuses still off.

**Hardware:** [ESP32-S31-Function-CoreBoard-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-function-coreboard-1/user_guide.html).

**Commands (project directory):**

```bash
cd $IDF_PATH/examples/protocols/https_mbedtls
idf.py --preview set-target esp32s31
```

Replace `PORT` with your serial port in flash commands below. TODO: Pin a tested ESP-IDF v6.1 commit or workshop fork when the course repository is published.

> [!IMPORTANT]
> **Workshop mode: turn on virtual eFuses.** Enable `CONFIG_EFUSE_VIRTUAL=y` and `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y` in this assignment; they were off in Assignment 2 (see [Lab safety and virtual eFuses](../introduction/#lab-safety-and-virtual-efuses)). Secure Boot **digest** and `SECURE_BOOT_EN` programming must stay emulated; do **not** run `espefuse burn` on participant boards. On first start, ESP-IDF copies the real eFuses into the empty `efuse_em` partition, so block 0 already shows `HMAC_UP` and encrypted NVS keeps working.

**eFuse block plan (same project as Assignment 2):**

| Key block ID | Purpose | Used in |
|--------------|---------|---------|
| `0` | `HMAC_UP` (NVS encryption) | Assignment 2 (real eFuse, already burned) |
| `1` | `SECURE_BOOT_DIGEST0` | Assignment 3 signing key (virtual) |

Do not store both purposes in the same block. If Assignment 2 used a different key ID for HMAC, keep **digest 0** on another free block.

**Preflight:** After `idf.py build`, confirm in `sdkconfig`:

- `CONFIG_EFUSE_VIRTUAL=y`
- `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y`
- `CONFIG_NVS_ENCRYPTION=y` and HMAC NVS options from Assignment 2 still present

**Forbidden on participant boards:** `espefuse burn`, hardware Secure Boot without virtual eFuses, committing `secure_boot_signing_key.pem` or other private keys.

**Reset after lab (optional):** `idf.py -p PORT erase-flash`, then repeat the signed bootloader + app flash sequence so virtual eFuse state and partitions are clean. Erasing flash clears the virtual Secure Boot state but not the real HMAC key from Assignment 2.

> [!WARNING]
> Production Secure Boot burns digests and `SECURE_BOOT_EN` for real. That flow is in the [production provisioning appendix](../appendix-production-provisioning), not in this assignment.

## Step 1: Confirm the Assignment 2 baseline

Goal: verify TLS and encrypted NVS still work **before** you change the boot path.

1. Run `idf.py -p PORT build flash monitor`.
2. Confirm Assignment 2 success criteria: encrypted `nvs`, Wi-Fi from NVS, TLS `esp-x509-crt-bundle: Certificate validated` and `Certificate verified.`, howsmyssl JSON.

If anything fails, fix Assignment 2 before enabling Secure Boot. Secure Boot changes flashing steps and makes unsigned images harder to recover without `erase-flash`.

## Step 2: Add the virtual eFuse partition

Goal: persist emulated eFuse state across reboots ([Virtual eFuses (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/efuse.html#debug-efuse-unit-tests)).

1. Confirm the project uses the custom partition table from [Assignment 2](../assignment-2/#if-the-app-does-not-fit-the-factory-partition) (**Partition Table → Partition Table → Custom partition table CSV**, flash size 16 MB). If it still uses the default table, switch now.
2. Edit `partitions.csv` and add an `efuse_em` region after `nvs`. `nvs` stays at `0x9000`, so the encrypted Wi-Fi credentials from Assignment 2 are kept; the partitions after it move up, and `factory` moves to the next 64 KB boundary:

```csv
# Name,   Type, SubType, Offset,   Size,     Flags
nvs,      data, nvs,     0x9000,   0x6000,
efuse_em, data, efuse,   0xf000,   0x2000,
phy_init, data, phy,     0x11000,  0x1000,
factory,  app,  factory, 0x20000,  0x200000,
```

If you have to raise the partition table offset because the signed bootloader is larger, shift every offset by the same amount. That moves the `nvs` partition, and the encrypted Wi-Fi credentials from Assignment 2 are no longer found. On the next boot, `wifi_creds` copies them from menuconfig again (`Stored lab Wi-Fi credentials in encrypted NVS`). This is expected; the HMAC key is unchanged.

3. Rebuild once: `idf.py build`. Resolve partition overlap errors by following the size hint in the linker or Secure Boot docs (signed bootloaders are larger than the stock image).

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

3. Optional sanity check:

```bash
espsecure signature-info-v2 build/bootloader/bootloader.bin
```

(Run again after Step 4 when signed binaries exist.)

Never use this PEM in production or reuse it as a product root of trust.

## Step 4: Enable Secure Boot V2 in menuconfig

Goal: turn on hardware Secure Boot in the **bootloader** build with RSA Secure Boot v2, while keeping virtual eFuses (see [Keys, signing, and eFuses](../lecture-3/#keys-signing-and-efuses)).

1. Run `idf.py menuconfig`.
2. Open **Security features**.
3. Enable **Enable hardware Secure Boot in bootloader** ([CONFIG_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot)).
4. Confirm **Secure Boot version 2** / RSA app signing scheme ([CONFIG_SECURE_BOOT_V2_ENABLED](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot-v2-enabled)).
5. Set **Secure Boot signing key** to `secure_boot_signing_key.pem` (path relative to the project root).
6. Leave **Automatically sign binaries during build** enabled unless your instructor uses the external signing workflow.
7. Under **Component config → eFuse Bit Manager**, confirm **Use virtual eFuses** and **Keep eFuses in flash** stay enabled.
8. For the workshop, keep **UART ROM download mode** in a **recoverable** setting (for example the default that allows secure download in development). Do **not** select permanent UART disable on class boards. Production choices are in the appendix and [How to enable Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#how-to-enable-secure-boot-v2).

Optional `sdkconfig.defaults` additions (merge with Assignment 2):

```ini
CONFIG_SECURE_BOOT=y
CONFIG_SECURE_BOOT_V2_ENABLED=y
CONFIG_SECURE_BOOT_SUPPORTS_RSA=y
CONFIG_SECURE_BOOT_RSA_KEY_LENGTH_3072=y
CONFIG_SECURE_BOOT_SIGNING_KEY="secure_boot_signing_key.pem"
CONFIG_EFUSE_VIRTUAL=y
CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y
```

9. Run `idf.py build`. Fix missing signing key or partition size errors before flashing.

## Step 5: Flash signed bootloader and application

Goal: follow the ESP-IDF Secure Boot flash order. With [CONFIG_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot) enabled, **`idf.py flash` does not update the bootloader**.

1. Build the signed bootloader and note the `esptool.py write_flash` command printed at the end:

```bash
idf.py bootloader
```

2. Run the **exact** `write_flash` command from the build log (offsets vary with partition table). Example shape:

```bash
esptool.py -p PORT write_flash --force 0x0 build/bootloader/bootloader.bin
```

3. Flash partition table and signed application:

```bash
idf.py -p PORT flash
```

4. Open the monitor:

```bash
idf.py -p PORT monitor
```

**First-boot behavior (virtual eFuses):** the second-stage bootloader programs **emulated** `SECURE_BOOT_EN` and the public-key digest for your signing key, then boots the signed app. Expect a warning similar to `eFuse virtual mode is enabled` and Secure Boot enablement logs. If power is lost mid-first-boot, reset and let the sequence finish ([How to enable Secure Boot v2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#how-to-enable-secure-boot-v2)).

## Step 6: Optional runtime check in application code

Goal: keep Assignment 2 application logic and add one integrity check from ESP-IDF.

In `https_mbedtls_example_main.c`, after successful `nvs_flash_init()` and **before** Wi-Fi connect:

```c
#include "esp_secure_boot.h"

void app_main(void)
{
    esp_err_t ret = nvs_flash_init();
    /* ... existing erase/retry from Assignment 2 ... */
    ESP_ERROR_CHECK(ret);

    ESP_ERROR_CHECK(esp_secure_boot_init_checks());

    ESP_ERROR_CHECK(wifi_creds_provision_from_menuconfig_if_missing());
    /* ... rest unchanged: esp_netif_init, workshop_wifi_connect, https_get_task ... */
}
```

Add `bootloader_support` to `PRIV_REQUIRES` in `main/CMakeLists.txt` if the linker reports missing symbols for `esp_secure_boot_init_checks`.

Do **not** remove NVS encryption, `wifi_creds`, or the TLS task.

## Step 7: Verify boot, eFuses, and Assignment 2 regression

Goal: prove Secure Boot is active in emulation and that **encrypted NVS + TLS** still work on the signed image.

1. Run `idf.py -p PORT efuse-summary`. Confirm emulated **Secure Boot** fields (for example `SECURE_BOOT_EN` and a key block with purpose `SECURE_BOOT_DIGEST0`). Treat this as **lab state**, not manufacturing proof.

2. Reboot twice (`idf.py monitor`, press EN/RST). Signed firmware should boot each time.

3. Confirm **Assignment 2** behavior still passes:

| Check | Expected |
|-------|----------|
| NVS encryption | `NVS partition "nvs" is encrypted.` |
| Wi-Fi | Loaded from NVS, connected |
| TLS | `esp-x509-crt-bundle: Certificate validated`, `Certificate verified.`, howsmyssl JSON |

Capture log excerpts for workshop notes and the **integrity / unauthorized firmware** row in the [EU CRA overview](../overview-eu-cra).

## Step 8: Test rejection of bad firmware

Goal: document **fail-closed** boot when the application image does not verify (see [Secure Boot V2 process](../lecture-3/#secure-boot-v2-process)).

Use a **spare** board or plan to **`erase-flash`** and reflash Steps 5 to 7 afterward.

**Option A (recommended): corrupt the signed app in flash**

1. Note the factory app offset from `idf.py partition-table` (for example `0x20000`).
2. With the device in download mode, write a single corrupted byte in the app image (adjust offset inside the partition, not the partition table):

```bash
python -c "open('corrupt.bin','wb').write(b'\\xff')"
esptool.py -p PORT write_flash 0x200100 corrupt.bin
```

3. Reset and watch the serial log. Expect verification failure and **no** normal application log (no TLS task, no Wi-Fi success). Bootloader messages often mention signature or image verification failure.

4. Restore with `idf.py -p PORT erase-flash`, then repeat Step 5 (bootloader + `idf.py flash`).

**Option B: flash an app signed with a different key**

1. Generate `wrong_key.pem` (do not commit).
2. Temporarily point menuconfig **Secure Boot signing key** at `wrong_key.pem`, `idf.py build`, `idf.py -p PORT flash` (bootloader still trusts the **first** key digest in virtual eFuses).
3. Observe rejection on boot.
4. Restore `secure_boot_signing_key.pem`, rebuild, reflash app, or full `erase-flash` if virtual digest state is confused.

Record: test method, log output, and recovery steps. This is core **CRA-oriented test evidence** for unauthorized firmware (see [CRA and product evidence](../lecture-3/#cra-and-product-evidence)).

## Step 9: Validation matrix

| Test | Action | Expected |
|------|--------|----------|
| Baseline | Step 1 | Assignment 2 TLS + NVS OK before Secure Boot |
| Signed boot | Steps 5 to 7 | Signed app runs; virtual Secure Boot enabled in logs / summary |
| NVS + TLS regression | Step 7 | Same as Assignment 2 after Secure Boot |
| `esp_secure_boot_init_checks` | Step 6 (if added) | No abort on clean signed boot |
| Rejection | Step 8 | Tampered or wrong-key app does not run product code |
| Virtual eFuse | Boot log | Virtual mode warning; no real `espefuse burn` in class |

## What you learned

You should now be able to:

- Enable **Secure Boot V2 (RSA-3072)** on the same **https_mbedtls + encrypted NVS** project from Assignments 1 and 2
- Generate and protect a **development signing key** separate from production HSM policy
- Flash **bootloader** and **application** in the order ESP-IDF requires when `CONFIG_SECURE_BOOT` is on
- Inspect **virtual** digest and `SECURE_BOOT_EN` state with `idf.py efuse-summary`
- Demonstrate **rejection** of unsigned or invalid application images
- Relate configuration, signing policy, boot logs, and rejection tests to the Secure Boot row in the [EU CRA overview](../overview-eu-cra)

## Previous and next steps

[Previous: Lecture 3](../lecture-3)

[Next: Lecture 4: Flash encryption](../lecture-4)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
