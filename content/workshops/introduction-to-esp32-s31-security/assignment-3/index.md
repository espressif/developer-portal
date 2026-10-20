---
title: "Assignment 3: Enable and Verify Secure Boot V2"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 10
showAuthor: false
---

## Assignment 3: Enable and verify Secure Boot V2

In [Assignment 2](../assignment-2) you kept the [**https_mbedtls**](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_mbedtls) client, moved the **Wi-Fi credentials into NVS** (`wifi_creds.c`, `workshop_wifi_connect.c`), and ran the firmware in the ESP32 emulator. Here you add **Secure Boot V2** to the same project, with production settings, so only **signed** bootloader and application images run.

Read [Lecture 3](../lecture-3) for the boot chain, keys vs digests, and CRA evidence themes. Official flow: [How to enable Secure Boot v2 (ESP32-S31)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/secure-boot-v2.html#how-to-enable-secure-boot-v2).

## Before you begin

**Starting point:** Assignment 2 complete in the same project: the shared partition table, the Wi-Fi helpers, and the `log_security_state()` and `dump_nvs_prefix()` helpers. Do not run `set-target` again: it resets `sdkconfig`.

> [!WARNING]
> **Do not flash this firmware to your board.** On first boot it permanently enables Secure Boot, burns your key digest, and disables ROM download mode and JTAG. A board that runs it can never be flashed over serial again. Run it only in the emulator, and never commit `secure_boot_signing_key.pem`. See [Lab safety and the ESP32 emulator](../introduction/#lab-safety-and-the-esp32-emulator).

**eFuse block plan:** each emulator run starts with a blank chip, so the bootloader writes the digest into the first free key block:

| Key block | Purpose | Written by |
|-----------|---------|------------|
| `BLOCK_KEY0` | `SECURE_BOOT_DIGEST0` | Bootloader, on first boot |

## Step 1: Turn off NVS encryption for this assignment

Goal: understand why this lab runs without NVS encryption, and turn it off.

Secure Boot write-protects the eFuse read-protection bits on its first boot (`Prevent read disabling of additional efuses`). The HMAC key from Assignment 2 must be read-protected, so once Secure Boot is on, the application can no longer burn it. On a blank chip, the bootloader enables Secure Boot before the app runs, so `nvs_flash_init()` would fail:

```log
E (...) nvs_sec_provider: Could not find HMAC key in configured eFuse block!
E (...) nvs_sec_provider: Failed to write the HMAC key to eFuse: [0x103] (ESP_ERR_INVALID_STATE)
...
abort() was called at PC ...
```

A production line avoids this by burning the HMAC key **before** the first boot of secure firmware (see the [real-board appendix](../appendix-production-provisioning/#efuse-key-block-plan)). The browser emulator always starts from a blank chip, so it cannot follow that order. This assignment therefore runs with NVS encryption off, and [Assignment 4](../assignment-4) turns it back on with a scheme that works on a blank chip: NVS keys protected by flash encryption.

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

2. Open **Component config → NVS** and disable **Enable NVS encryption**.
3. In `sdkconfig.defaults`, remove the three `CONFIG_NVS_*` lines from Assignment 2 and add:

```ini
# CONFIG_NVS_ENCRYPTION is not set
```

For the rest of this assignment, the Wi-Fi password is stored in **plaintext** in NVS. You will see it in the raw dump in Step 6.

## Step 2: Generate a development signing key

Goal: create an RSA-3072 **lab** private key used only to sign bootloader and app images in this course.

1. From the project directory, generate a key:

{{< tabs group="workflow" >}}
  {{< tab label="CLI" >}}
```bash
idf.py secure-generate-signing-key --version 2 --scheme rsa3072 secure_boot_signing_key.pem
```

Equivalent: `espsecure generate-signing-key --version 2 --scheme rsa3072 secure_boot_signing_key.pem` ([Enable Secure Boot v2 externally](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/security/security-features-enablement-workflows.html#enable-secure-boot-v2-externally)).
  {{< /tab >}}
  {{< tab label="CLion" >}}
CLion instructions will be added soon.
  {{< /tab >}}
{{< /tabs >}}

2. Add to `.gitignore`:

```
secure_boot_signing_key.pem
*.pem
```

> [!WARNING]
> Never use this PEM in production or reuse it as a product root of trust.

## Step 3: Enable Secure Boot V2

Goal: turn on Secure Boot V2 with the RSA scheme and production settings (see [Keys, signing, and eFuses](../lecture-3/#keys-signing-and-efuses)).

1. Open the project configuration, as in Step 1.
2. Open **Security features**.
3. Enable **Enable hardware Secure Boot in bootloader** ([CONFIG_SECURE_BOOT](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot)).
4. Confirm the Secure Boot version is **Enable Secure Boot version 2** ([CONFIG_SECURE_BOOT_V2_ENABLED](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot-v2-enabled)) and the app signing scheme is **RSA** ([CONFIG_SECURE_SIGNED_APPS_RSA_SCHEME](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-signed-apps-scheme)). ESP32-S31 supports RSA-3072 only, so there is no key length to choose.
5. Keep **Sign binaries during build** enabled ([CONFIG_SECURE_BOOT_BUILD_SIGNED_BINARIES](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-boot-build-signed-binaries)) and set **Secure boot private signing key** to `secure_boot_signing_key.pem` (path relative to the project root).
6. Set **UART ROM download mode** to **Permanently disabled (recommended)** ([CONFIG_SECURE_DISABLE_ROM_DL_MODE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-disable-rom-dl-mode)). On ESP32-S31, ESP-IDF v6.1 does not support Secure download mode yet, so this is the production choice. On SoCs that support it, such as ESP32-C5, **Permanently switch to Secure mode** keeps a restricted serial path for provisioning tools.
7. Leave the JTAG options at their defaults. With Secure Boot enabled, the bootloader disables JTAG on first boot.
8. Save and exit.

Add the same settings to `sdkconfig.defaults`, so the file now contains:

```ini
CONFIG_ESPTOOLPY_FLASHSIZE_4MB=y
CONFIG_PARTITION_TABLE_CUSTOM=y
CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions.csv"
CONFIG_PARTITION_TABLE_OFFSET=0x10000
CONFIG_EXAMPLE_WIFI_SSID="myssid"
CONFIG_EXAMPLE_WIFI_PASSWORD="mypassword"
# CONFIG_NVS_ENCRYPTION is not set
CONFIG_SECURE_BOOT=y
CONFIG_SECURE_BOOT_V2_ENABLED=y
CONFIG_SECURE_SIGNED_APPS_RSA_SCHEME=y
CONFIG_SECURE_BOOT_BUILD_SIGNED_BINARIES=y
CONFIG_SECURE_BOOT_SIGNING_KEY="secure_boot_signing_key.pem"
CONFIG_SECURE_DISABLE_ROM_DL_MODE=y
```

ESP-IDF reads `sdkconfig.defaults` only when it creates a new `sdkconfig`, so menuconfig is what changes your current build. Keeping the file in sync lets anyone rebuild the same configuration from scratch.

`CONFIG_SECURE_BOOT` builds a bootloader that enables Secure Boot. It does not set the `SECURE_BOOT_EN` eFuse itself: the bootloader writes `SECURE_BOOT_EN` and the key digest on its first boot in [Step 6](#step-6-run-in-the-emulator).

## Step 4: Log the Secure Boot state from the application

Goal: extend `log_security_state()` from Assignment 2 so the app reports what the eFuses now enforce.

1. Add `bootloader_support` (provides `esp_secure_boot.h`) to `PRIV_REQUIRES` in `main/CMakeLists.txt`. Without it the build fails with `esp_secure_boot.h: No such file or directory`.

```cmake
idf_component_register(SRCS "https_mbedtls_example_main.c" "wifi_creds.c" "workshop_wifi_connect.c"
                    INCLUDE_DIRS "."
                    PRIV_REQUIRES esp_event nvs_flash esp_netif esp_wifi mbedtls efuse esp_partition bootloader_support)
```

2. In `https_mbedtls_example_main.c`, include `esp_secure_boot.h` and extend the helper:

```c
#include "esp_secure_boot.h"

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

The call in `app_main()` stays where Assignment 2 put it, right after `nvs_flash_init()`. Do **not** remove `wifi_creds`, the dump, or the TLS task.

## Step 5: Build and merge the signed images

Goal: build signed images and merge them into one emulator image.

With Secure Boot enabled, `idf.py merge-bin` leaves the bootloader out, because ESP-IDF expects you to flash it separately. Merge the images with `esptool` instead, using the offsets of the shared layout:

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

Use the application binary name printed at the end of the build for `<project-name>`.
  {{< /tab >}}
  {{< tab label="CLion" >}}
CLion instructions will be added soon.
  {{< /tab >}}
{{< /tabs >}}

The build should report `Bootloader binary size 0xb000 bytes`, which fits below the partition table at `0x10000`.

Confirm that both images carry a signature block:

```bash
espsecure signature-info-v2 build/bootloader/bootloader.bin
espsecure signature-info-v2 build/<project-name>.bin
```

Each command should report one RSA signature block. The build also writes `build/<project-name>-unsigned.bin`; you use it in the optional Step 8.

## Step 6: Run in the emulator

Goal: watch the bootloader enable Secure Boot on a blank chip, and check the result.

1. Reload the [ESP32 emulator](https://espressif.github.io/esp-emulator/) page, so you start with a blank chip.
2. Select the chip **esp32s31**, load `build/merged-secure.bin`, and start the emulator.

**First boot.** The bootloader verifies the app signature, burns the digest of your public key, and enables Secure Boot:

```log
I (...) esp_image: Verifying image signature...
I (...) secure_boot_v2: Secure boot V2 is not enabled yet and eFuse digest keys are not set
I (...) secure_boot_v2: Verifying with RSA-PSS...
I (...) secure_boot_v2: Signature verified successfully!
I (...) secure_boot_v2: enabling secure boot v2...
I (...) secure_boot_v2: Secure boot digests absent, generating..
I (...) secure_boot_v2: Burning public key hash to eFuse
I (...) efuse: Writing EFUSE_BLK_KEY0 with purpose 9
I (...) secure_boot_v2: Application key(0) matches with bootloader key(0).
I (...) secure_boot_v2: Revoking empty key digest slot (1)...
I (...) secure_boot_v2: Revoking empty key digest slot (2)...
I (...) secure_boot_v2: blowing secure boot efuse...
I (...) secure_boot: Disable ROM Download mode...
I (...) secure_boot: Disable hardware & software JTAG...
I (...) secure_boot: Prevent read disabling of additional efuses...
I (...) secure_boot_v2: Secure boot permanently enabled
```

Purpose 9 is `SECURE_BOOT_DIGEST0`. The two revoked slots mean no other key can ever be added. `Prevent read disabling of additional efuses` is the line that blocks the HMAC key burn described in Step 1.

The app then starts and reports:

```log
I (...) example: Secure Boot enabled: yes
I (...) example: SECURE_BOOT_DIGEST0 in BLOCK_KEY0
I (...) wifi_creds: Stored lab Wi-Fi credentials in NVS
I (...) nvs_raw: ...   6d 79 70 61 73 73 77 6f  72 64 00 ff ff ff ff ff  |mypassword......|
I (...) workshop_wifi: Connected using credentials from NVS
E (...) example: mbedtls_net_connect returned -52
```

The password is readable in the raw dump, because NVS encryption is off in this assignment. The TLS error is expected in the browser emulator.

3. **Second boot.** Reset the emulated chip without loading a new image. Now the ROM verifies the bootloader before it runs, and the bootloader skips the provisioning:

```log
Valid secure boot key blocks: 0
RSA-PSS secure boot verification succeeded
...
I (...) secure_boot_v2: enabling secure boot v2...
I (...) secure_boot_v2: secure boot v2 is already enabled, continuing..
```

Capture log excerpts for workshop notes and the **integrity / unauthorized firmware** row in the [EU CRA overview](../overview-eu-cra).

## Step 7: Check the evidence

Goal: tie each log line to the protection it proves.

| Check | Expected in the log |
|-------|---------------------|
| App signature verified on first boot | `Signature verified successfully!` |
| Key digest burned | `Writing EFUSE_BLK_KEY0 with purpose 9`, then `SECURE_BOOT_DIGEST0 in BLOCK_KEY0` |
| Unused digest slots revoked | `Revoking empty key digest slot (1)...` and `(2)...` |
| Secure Boot enabled | `Secure boot permanently enabled`, then `Secure Boot enabled: yes` |
| Serial and debug access closed | `Disable ROM Download mode...` and `Disable hardware & software JTAG...` |
| ROM verifies the bootloader | `RSA-PSS secure boot verification succeeded` after a reset |
| NVS not encrypted (known gap) | `mypassword` readable in `nvs_raw` |

## Step 8 (optional): Test rejection of bad firmware

Goal: document **fail-closed** boot when the application image does not verify (see [Secure Boot V2 process](../lecture-3/#secure-boot-v2-process)).

The browser emulator cannot run this test: every image you load starts on a blank chip, which burns the digest of whatever key signed that image and then trusts it. To boot a modified image on a chip that already trusts your key, use the native `esp-emu` tool, which can save the eFuse and flash state between runs.

1. Install `esp-emu` and download the eFuse file tool from the [`esp-emulator` repository](https://github.com/espressif/esp-emulator):

```bash
curl -fsSL https://raw.githubusercontent.com/espressif/esp-emulator/main/install.sh | sh
curl -fsSL https://raw.githubusercontent.com/espressif/esp-emulator/main/tools/make-efuse.py -o make-efuse.py
```

2. Create a blank eFuse file and run the first boot. `--save-state` writes the burned eFuses and the flash back to the files:

```bash
python3 make-efuse.py --chip esp32s31 --chip-rev 0.0 -o lab.efuse
cp build/merged-secure.bin lab-flash.bin
esp-emu --chip esp32s31 --firmware lab-flash.bin --efuse lab.efuse --save-state --timeout 60s --exit-on "Calling app_main()"
```

The log should show `Secure boot permanently enabled`. `lab.efuse` now holds the digest of your key.

3. **Tampered image:** flip one byte inside the app and boot it on the provisioned chip, without `--save-state`:

```bash
cp lab-flash.bin tampered.bin
python3 -c "f=open('tampered.bin','r+b'); f.seek(0x30000); b=f.read(1); f.seek(0x30000); f.write(bytes([b[0]^0xFF]))"
esp-emu --chip esp32s31 --firmware tampered.bin --efuse lab.efuse --timeout 30s --exit-on "No bootable app partitions"
```

Expected:

```log
E (...) esp_image: Checksum failed. Calculated 0x2a read 0xd5
E (...) boot: OTA app partition slot 0 is not bootable
E (...) boot: No bootable app partitions in the partition table
```

4. **Image signed with a different key:** sign the unsigned app with a new key and put it in `ota_0`:

```bash
espsecure generate-signing-key --version 2 --scheme rsa3072 wrong_key.pem
espsecure sign-data --version 2 --keyfile wrong_key.pem --output wrong_app.bin build/<project-name>-unsigned.bin
cp lab-flash.bin wrongkey.bin
python3 -c "d=open('wrong_app.bin','rb').read(); f=open('wrongkey.bin','r+b'); f.seek(0x20000); f.write(d)"
esp-emu --chip esp32s31 --firmware wrongkey.bin --efuse lab.efuse --timeout 30s --exit-on "No bootable app partitions"
```

Expected:

```log
I (...) esp_image: Verifying image signature...
Sig block 0 signed with untrusted key
E (...) secure_boot_v2: Secure Boot V2 verification failed.
E (...) esp_image: Secure boot signature verification failed
W (...) esp_image: image valid, signature bad
E (...) boot: No bootable app partitions in the partition table
```

The image is intact, but its key digest is not in eFuse, and the other digest slots were revoked on first boot.

5. Delete `wrong_key.pem`, `wrong_app.bin`, and the test images.

Record the test method and log output. This is core **CRA-oriented test evidence** for unauthorized firmware (see [CRA and product evidence](../lecture-3/#cra-and-product-evidence)).

## Step 9: Validation matrix

| Test | Action | Expected |
|------|--------|----------|
| Signed images | Step 5 | `signature-info-v2` shows one RSA signature block on bootloader and app |
| First boot | Step 6 | Digest burned in `BLOCK_KEY0`, `Secure boot permanently enabled`, download mode and JTAG disabled |
| App state | Step 6 | `Secure Boot enabled: yes`, `SECURE_BOOT_DIGEST0 in BLOCK_KEY0` |
| Second boot | Step 6 | `RSA-PSS secure boot verification succeeded`, `secure boot v2 is already enabled` |
| Wi-Fi from NVS | Step 6 | `Connected using credentials from NVS` |
| Rejection (optional) | Step 8 | Tampered and wrong-key apps do not boot |

## What you learned

You should now be able to:

- Enable **Secure Boot V2 (RSA-3072)** with production settings on the **https_mbedtls** project from Assignments 1 and 2
- Generate and protect a **development signing key** separate from production HSM policy
- Merge signed images for the emulator when `idf.py merge-bin` omits the Secure Boot bootloader
- Read the first-boot log: digest burn, slot revocation, download mode and JTAG disabled
- Explain why an HMAC key must be burned before Secure Boot is enabled
- Demonstrate **rejection** of tampered and wrongly signed images with native `esp-emu` (optional Step 8)
- Relate configuration, signing policy, boot logs, and rejection tests to the Secure Boot row in the [EU CRA overview](../overview-eu-cra)

## Previous and next steps

[Previous: Lecture 3](../lecture-3)

[Next: Lecture 4: Flash encryption](../lecture-4)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
