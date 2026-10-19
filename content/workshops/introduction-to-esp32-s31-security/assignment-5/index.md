---
title: "Assignment 5 (optional): Add Secure OTA Updates"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 13
showAuthor: false
---

## Assignment 5 (optional): Add secure OTA updates

> [!NOTE]
> This assignment is **optional**. Do it if you finished Assignment 4 early, or later at home. The [Conclusion](../conclusion) does not depend on it.

After Assignment 4, the firmware has TLS, HMAC-encrypted NVS, Secure Boot V2, and flash encryption. A product also has to be updated in the field, and every update is a chance for an attacker to install their own firmware. Here you add **over-the-air (OTA) updates** to the same project and check that the update path keeps the guarantees you built so far:

- The image is downloaded over **HTTPS**, and the device checks the server certificate.
- The device installs the image only if it is **signed** with your Secure Boot key. With Secure Boot enabled, ESP-IDF turns on [CONFIG_SECURE_SIGNED_ON_UPDATE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-signed-on-update), so the app verifies the signature against the trusted Secure Boot digest before it switches partitions.
- If a new image fails its self-test, the bootloader **rolls back** to the previous one ([App Rollback](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/ota.html#app-rollback)).

The virtual eFuses from Assignments 3 and 4 stay on, and this assignment does not burn any eFuse. The signature check during the update reads the trusted digest from the emulated `BLOCK_KEY1`, so a rejected image is rejected exactly as it would be on a production device.

## Before you begin

**Starting point:** Assignment 4 complete in the same project, with virtual eFuses still on and the partition table at `0xF000`.

**What you need:**

- A computer on the same network as the board, reachable on TCP port `8070`. Allow incoming connections on that port if a firewall is active.
- OpenSSL 1.1.1 or later on the computer, to create the server certificate and run a test HTTPS server.

**To start over:** run `python -m esptool --chip esp32s31 -p PORT erase-flash`, then repeat [Step 5](#step-5-flash-version-100).

## Step 1: Switch to an OTA partition layout

Goal: replace the single `factory` partition with two OTA slots and an `otadata` partition that records which slot boots ([OTA Process Overview](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/ota.html#ota-process-overview)).

Replace `partitions.csv` with:

```csv
# Name,   Type, SubType, Offset,   Size,     Flags
nvs,      data, nvs,     0x10000,  0x6000,
efuse_em, data, efuse,   0x16000,  0x2000,
phy_init, data, phy,     0x18000,  0x1000,
storage,  data, 0xff,    0x19000,  0x1000,   encrypted
otadata,  data, ota,     0x1A000,  0x2000,
ota_0,    app,  ota_0,   0x20000,  0x180000,
ota_1,    app,  ota_1,   0x1A0000, 0x180000,
```

- `nvs` and `efuse_em` keep their Assignment 4 offsets, so the stored Wi-Fi credentials and the emulated Secure Boot and flash encryption state survive. You do not need to erase the flash.
- Each OTA slot is 1.5 MB. The current app is about 1.2 MB, which leaves room to grow.
- App partitions must be 64 KB aligned, which also satisfies the 4 KB alignment Secure Boot V2 needs for signed images.
- With flash encryption enabled, ESP-IDF treats `otadata` as encrypted automatically. Do not add the `encrypted` flag yourself.

## Step 2: Enable app rollback

Goal: let a new image prove it works before the device commits to it.

1. Run `idf.py menuconfig`.
2. Under **Bootloader config → Application Rollback**, enable **Enable app rollback support** ([CONFIG_BOOTLOADER_APP_ROLLBACK_ENABLE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-rollback-enable)).
3. Leave **Enable app anti-rollback support** off. The next section explains what it does and why it stays off in this lab.
4. Save, exit, and confirm that `sdkconfig` contains:

```ini
CONFIG_BOOTLOADER_APP_ROLLBACK_ENABLE=y
```

5. Run `idf.py build`. Expect:
   - `Bootloader binary size 0xc000 bytes. 0x1000 bytes (8%) free.`
   - `Smallest app partition is 0x180000 bytes.` with free space left

### Anti-rollback: what it adds

Rollback and anti-rollback solve different problems:

- **Rollback** protects the device from a **broken** update: if a new image does not confirm itself, the bootloader goes back to the previous one.
- **Anti-rollback** protects the device from an **old** image ([Anti-rollback](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/ota.html#anti-rollback)). Secure Boot does not stop a downgrade: a version with a known vulnerability is still signed with your key, so it passes the signature check. Anti-rollback stops the device from booting it.

**How it works.** Each image carries two version numbers:

| Version | Set by | Used for |
|---------|--------|----------|
| App version, for example `1.0.1` | `PROJECT_VER` | Information only. This assignment's code compares it to decide whether to download. |
| Secure version, an integer | [CONFIG_BOOTLOADER_APP_SECURE_VERSION](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-secure-version) | Anti-rollback. Stored in the image header (`esp_app_desc_t.secure_version`) and covered by the signature. |

The SoC keeps the minimum accepted secure version in the `SECURE_VERSION` eFuse field, as a count of burned bits. eFuse bits can only go from 0 to 1, so the value can only increase.

1. The bootloader boots only images whose secure version is **greater than or equal to** the eFuse value. Older images are skipped.
2. When the app confirms a new image with `esp_ota_mark_app_valid_cancel_rollback()`, ESP-IDF raises the eFuse value to that image's secure version. From then on, every image with a lower secure version is refused, including the one still in the other OTA slot.
3. During an update, `esp_ota_set_boot_partition()` refuses an image with a lower secure version: it erases the slot and returns `ESP_ERR_OTA_SMALL_SEC_VER`, so `esp_https_ota_finish()` fails. To avoid a useless download, check `new_desc.secure_version` with `esp_efuse_check_secure_version()` right after `esp_https_ota_get_img_desc()`.
4. Rollback still works, but only to an image whose secure version is at least the eFuse value. If you raise the secure version, test the new release well: after confirmation there is no going back to the old one.

**Limits:**

- The `SECURE_VERSION` field has 16 bits on ESP32-S31 (9 on ESP32-C5), so the secure version can be raised at most 16 times in the life of the device. Raise it only for releases that fix a security issue, not for every release. [CONFIG_BOOTLOADER_APP_SEC_VER_SIZE_EFUSE_FIELD](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-sec-ver-size-efuse-field) sets how many of those bits ESP-IDF uses.
- Anti-rollback needs app rollback, and it does not support `factory` or `test` partitions. The OTA layout from Step 1 already meets both requirements.

**Menuconfig options**, all under **Bootloader config → Application Rollback**:

| Option | Purpose |
|--------|---------|
| **Enable app anti-rollback support** ([CONFIG_BOOTLOADER_APP_ANTI_ROLLBACK](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-anti-rollback)) | Turns on the secure version check in the bootloader |
| **eFuse secure version of app** | The secure version written into this build's image |
| **Size of the efuse secure version field** | How many eFuse bits ESP-IDF uses for the counter |
| **Emulate operations with efuse secure version (only test)** ([CONFIG_BOOTLOADER_EFUSE_SECURE_VERSION_EMULATE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-efuse-secure-version-emulate)) | Tests anti-rollback without burning eFuses. It turns on virtual eFuses, which this project already uses. |

**Why it stays off in this lab:**

- **Bootloader size:** with Secure Boot, flash encryption, and anti-rollback together, the bootloader grows to `0xD000`. That fills all the space between `0x2000` and the partition table at `0xF000`, so any further growth breaks the build. To make room you would move the partition table, which moves `nvs` and `efuse_em`, and then erase and provision the board again.
- **Production impact:** on a device with real eFuses, every confirmed increase is a permanent burn. Decide the secure version policy before the first release; [Step 10](#step-10-review-production-configuration-read-only) lists it for your technical file.

## Step 3: Create the OTA server certificate

Goal: give the test server an identity the device can verify.

The device connects to your computer by IP address, so the certificate must contain that IP address in its subject alternative name (SAN). Find the IP address of your computer, for example with `ipconfig getifaddr en0` on macOS or `hostname -I` on Linux. The commands below use `192.168.1.10`; replace it everywhere with your address.

In the project directory, run:

```bash
mkdir -p server_certs ota_server
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout server_certs/ca_key.pem -out server_certs/ca_cert.pem \
  -subj "/CN=192.168.1.10" -addext "subjectAltName=IP:192.168.1.10"
```

`ca_cert.pem` is embedded in the firmware and is public. `ca_key.pem` is the server private key. Add it to `.gitignore`:

```text
server_certs/ca_key.pem
```

> [!WARNING]
> This self-signed certificate is for the lab only. A product OTA server uses a certificate from a CA you control or a public CA, and its private key never leaves the server infrastructure.

## Step 4: Add the OTA code

Goal: download, verify, and install a new image, and confirm a new image after it boots.

1. Create `main/Kconfig.projbuild`:

```kconfig
menu "Workshop OTA"

    config WORKSHOP_OTA_URL
        string "Firmware upgrade URL"
        default "https://192.168.1.10:8070/firmware.bin"
        help
            HTTPS URL of the signed application image served by the OTA server.
            Use the IP address of the computer that runs the server; it must match
            the subjectAltName in server_certs/ca_cert.pem.

    config WORKSHOP_OTA_FAIL_SELF_TEST
        bool "Simulate a failed self-test after an update"
        default n
        help
            When enabled, a freshly updated image reports a failed self-test and
            asks the bootloader to roll back to the previous image. Use it only to
            build a deliberately bad update for the rollback test.

endmenu
```

2. Create `main/workshop_ota.h`:

```c
#pragma once

#include "esp_err.h"

void workshop_ota_confirm_running_app(void);
esp_err_t workshop_ota_check_and_update(void);
```

3. Create `main/workshop_ota.c`:

```c
#include <string.h>
#include "esp_app_desc.h"
#include "esp_check.h"
#include "esp_http_client.h"
#include "esp_https_ota.h"
#include "esp_log.h"
#include "esp_ota_ops.h"
#include "esp_system.h"
#include "workshop_ota.h"

static const char *TAG = "workshop_ota";

extern const uint8_t ota_server_cert_pem_start[] asm("_binary_ca_cert_pem_start");

void workshop_ota_confirm_running_app(void)
{
    const esp_partition_t *running = esp_ota_get_running_partition();
    esp_ota_img_states_t state;

    ESP_LOGI(TAG, "Running partition: %s, version: %s", running->label, esp_app_get_description()->version);
    if (esp_ota_get_state_partition(running, &state) == ESP_OK && state == ESP_OTA_IMG_PENDING_VERIFY) {
#if CONFIG_WORKSHOP_OTA_FAIL_SELF_TEST
        ESP_LOGE(TAG, "Self-test failed, rolling back to the previous firmware");
        esp_ota_mark_app_invalid_rollback_and_reboot();
#endif
        ESP_LOGI(TAG, "New firmware passed the self-test, cancelling rollback");
        ESP_ERROR_CHECK(esp_ota_mark_app_valid_cancel_rollback());
    }
}

esp_err_t workshop_ota_check_and_update(void)
{
    esp_http_client_config_t http_config = {
        .url = CONFIG_WORKSHOP_OTA_URL,
        .cert_pem = (const char *)ota_server_cert_pem_start,
        .timeout_ms = 10000,
        .keep_alive_enable = true,
    };
    esp_https_ota_config_t ota_config = {
        .http_config = &http_config,
    };
    esp_https_ota_handle_t handle = NULL;

    ESP_LOGI(TAG, "Checking %s", CONFIG_WORKSHOP_OTA_URL);
    ESP_RETURN_ON_ERROR(esp_https_ota_begin(&ota_config, &handle), TAG, "Could not connect to the OTA server");

    esp_app_desc_t new_desc;
    esp_err_t err = esp_https_ota_get_img_desc(handle, &new_desc);
    if (err != ESP_OK) {
        esp_https_ota_abort(handle);
        ESP_LOGE(TAG, "Could not read the image header");
        return err;
    }

    const esp_app_desc_t *running = esp_app_get_description();
    ESP_LOGI(TAG, "Running version: %s, server version: %s", running->version, new_desc.version);
    if (strcmp(new_desc.version, running->version) == 0) {
        ESP_LOGI(TAG, "Firmware is up to date");
        esp_https_ota_abort(handle);
        return ESP_OK;
    }

    const esp_partition_t *last_invalid = esp_ota_get_last_invalid_partition();
    esp_app_desc_t invalid_desc;
    if (last_invalid != NULL && esp_ota_get_partition_description(last_invalid, &invalid_desc) == ESP_OK &&
            strcmp(new_desc.version, invalid_desc.version) == 0) {
        ESP_LOGW(TAG, "Version %s was rolled back before, skipping it", new_desc.version);
        esp_https_ota_abort(handle);
        return ESP_OK;
    }

    while ((err = esp_https_ota_perform(handle)) == ESP_ERR_HTTPS_OTA_IN_PROGRESS) {
    }
    if (err != ESP_OK) {
        esp_https_ota_abort(handle);
        ESP_LOGE(TAG, "Download failed (%s)", esp_err_to_name(err));
        return err;
    }

    err = esp_https_ota_finish(handle);
    if (err == ESP_ERR_OTA_VALIDATE_FAILED) {
        ESP_LOGE(TAG, "Image rejected: signature or hash verification failed");
        return err;
    }
    ESP_RETURN_ON_ERROR(err, TAG, "OTA finish failed");

    ESP_LOGI(TAG, "OTA succeeded, rebooting into the new firmware");
    esp_restart();
    return ESP_OK;
}
```

What the code does:

- `esp_https_ota_begin()` opens the HTTPS connection and checks the server against the embedded `ca_cert.pem`.
- The version check skips the download when the server has the version that is already running, or a version that was rolled back before.
- `esp_https_ota_finish()` verifies the downloaded image. With Secure Boot enabled this includes the Secure Boot V2 signature; a bad image returns `ESP_ERR_OTA_VALIDATE_FAILED` and the boot partition does not change.
- `workshop_ota_confirm_running_app()` marks a freshly updated image as valid. If the image resets before that call, the bootloader rolls back to the previous image on the next boot.

4. Update `main/CMakeLists.txt` with the new source file, the OTA components, and the embedded certificate:

```cmake
idf_build_get_property(project_dir PROJECT_DIR)
idf_component_register(SRCS "https_mbedtls_example_main.c" "wifi_creds.c" "workshop_wifi_connect.c" "workshop_ota.c"
                    INCLUDE_DIRS "."
                    PRIV_REQUIRES esp_event nvs_flash esp_netif esp_wifi mbedtls bootloader_support efuse esp_partition spi_flash
                                  esp_https_ota esp_http_client app_update esp_app_format
                    EMBED_TXTFILES ${project_dir}/server_certs/ca_cert.pem)
```

5. In the top-level `CMakeLists.txt`, set the application version before `project()`:

```cmake
set(PROJECT_VER "1.0.0")
```

6. In `https_mbedtls_example_main.c`, include the header and call the OTA functions in `app_main()` right after Wi-Fi connects:

```c
#include "workshop_ota.h"
```

```c
    ESP_ERROR_CHECK(workshop_wifi_connect());

    workshop_ota_confirm_running_app();
    workshop_ota_check_and_update();
```

Calling `workshop_ota_confirm_running_app()` after Wi-Fi connects makes "Wi-Fi works" the self-test: if a new image cannot connect, `ESP_ERROR_CHECK` resets the board before the image is confirmed, and the bootloader rolls back.

7. Run `idf.py menuconfig`, open **Workshop OTA**, and set **Firmware upgrade URL** to `https://<your-computer-ip>:8070/firmware.bin`.

## Step 5: Flash version 1.0.0

Goal: install the OTA-capable bootloader and the first application version.

> [!WARNING]
> **Stop and check before flashing.** `grep -E '^CONFIG_EFUSE_VIRTUAL(_KEEP_IN_FLASH)?=y' sdkconfig` must print both lines, and the build output must contain `Efuse virtual mode is enabled`. If either check fails, do not flash.

1. Build and flash. The bootloader changed in Step 2, so flash it first:

```bash
idf.py build
idf.py -p PORT bootloader-flash
idf.py -p PORT flash monitor
```

`idf.py flash` also writes an empty `otadata`, so the device boots from `ota_0`.

2. The OTA server is not running yet, so the update check fails and the app continues with the TLS request. Expect:

```text
I (...) workshop_ota: Running partition: ota_0, version: 1.0.0
I (...) workshop_ota: Checking https://192.168.1.10:8070/firmware.bin
E (...) workshop_ota: Could not connect to the OTA server
```

The rest of the log should match Assignment 4: Secure Boot and flash encryption state, encrypted NVS, Wi-Fi, and the TLS request.

## Step 6: Publish and install version 1.0.1

Goal: run a successful signed update.

1. In a second terminal, start the test HTTPS server from the project directory:

```bash
cd ota_server
openssl s_server -WWW -key ../server_certs/ca_key.pem -cert ../server_certs/ca_cert.pem -port 8070
```

`-WWW` serves files from the current directory, so the device downloads `ota_server/firmware.bin`. Leave the server running for the rest of the assignment.

2. In the top-level `CMakeLists.txt`, change the version to `1.0.1`, then build and publish the **signed** image. Do not flash it:

```bash
idf.py build
cp build/<project-name>.bin ota_server/firmware.bin
```

The build writes two application images: `<project-name>.bin`, signed with `secure_boot_signing_key.pem`, and `<project-name>-unsigned.bin`. The signed one is the release artifact.

3. Reset the board (press **RST** or use `idf.py -p PORT monitor`). Expect:

```text
I (...) workshop_ota: Running version: 1.0.0, server version: 1.0.1
I (...) esp_https_ota: Starting OTA...
I (...) esp_https_ota: Writing to <ota_1> partition at offset 0x1a0000
I (...) esp_image: Verifying image signature...
I (...) secure_boot_v2: Take trusted digest key(s) from eFuse block(s)
I (...) secure_boot_v2: #0 app key digest == #0 trusted key digest
I (...) secure_boot_v2: Verifying with RSA-PSS...
I (...) workshop_ota: OTA succeeded, rebooting into the new firmware
```

After the reboot, the bootloader verifies the new image, and the app confirms it:

```text
I (...) workshop_ota: Running partition: ota_1, version: 1.0.1
I (...) workshop_ota: New firmware passed the self-test, cancelling rollback
I (...) workshop_ota: Running version: 1.0.1, server version: 1.0.1
I (...) workshop_ota: Firmware is up to date
```

The digest is read from the emulated `BLOCK_KEY1`, the same digest the bootloader trusts since Assignment 3.

## Step 7: Reject unsigned and wrongly signed images

Goal: show that an attacker who controls the download cannot install their own firmware.

1. Change the version to `1.0.2` and build. Publish the **unsigned** image:

```bash
idf.py build
cp build/<project-name>-unsigned.bin ota_server/firmware.bin
```

2. Reset the board. The image downloads, then verification fails:

```text
I (...) workshop_ota: Running version: 1.0.1, server version: 1.0.2
I (...) esp_image: Verifying image signature...
E (...) esp_image: Secure boot signature verification failed
W (...) esp_image: image valid, signature bad
E (...) workshop_ota: Image rejected: signature or hash verification failed
```

The device keeps running 1.0.1 from `ota_1` and continues with the TLS request.

3. Sign the same image with a key the device does not trust, and publish it:

```bash
espsecure generate-signing-key --version 2 --scheme rsa3072 wrong_key.pem
espsecure sign-data --version 2 --keyfile wrong_key.pem --output ota_server/firmware.bin build/<project-name>-unsigned.bin
```

4. Reset the board. The signature is valid, but its public key digest does not match the trusted digest, so the image is rejected again with `Image rejected: signature or hash verification failed`.

5. Delete `wrong_key.pem`.

Both tests also answer a common question: TLS protects the download, but the signature check protects the device even if the server, or the network between the server and the device, is compromised.

## Step 8: Test rollback (optional)

Goal: watch the bootloader return to the previous image when a correctly signed update fails its self-test.

1. In menuconfig, enable **Workshop OTA → Simulate a failed self-test after an update**. Keep the version at `1.0.2`.
2. Build and publish the **signed** image:

```bash
idf.py build
cp build/<project-name>.bin ota_server/firmware.bin
```

3. Reset the board. Expect:
   - The update installs into `ota_0`, as in Step 6.
   - Version 1.0.2 boots, connects to Wi-Fi, and logs `Self-test failed, rolling back to the previous firmware`.
   - The board reboots into `ota_1` with version 1.0.1.
   - The update check logs `Version 1.0.2 was rolled back before, skipping it`.
4. Disable **Simulate a failed self-test after an update** again.

## Step 9: Confirm that the real eFuses are untouched

Goal: confirm that OTA added no permanent change to the board.

Run `idf.py -p PORT efuse-summary` and check, as in Assignment 4, that the **real** `SECURE_BOOT_EN` is still `False`, `SPI_BOOT_CRYPT_CNT` is still `Disable`, `BLOCK_KEY1` and `BLOCK_KEY2` are still empty, and `SECURE_VERSION` (the anti-rollback field) is still `0`.

Stop the OpenSSL server with **Ctrl+C**. To go back to a known state, run `idf.py -p PORT flash`: it rewrites `ota_0` and an empty `otadata`, so the board boots from `ota_0` again.

## Step 10: Review production configuration (read only)

Goal: know what changes for a product fleet without performing it on workshop boards.

Read (do not execute on class kits):

- [Over The Air Updates (OTA)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/ota.html), in particular [Anti-rollback](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/ota.html#anti-rollback)
- [ESP HTTPS OTA](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/esp_https_ota.html)
- [production provisioning appendix](../appendix-production-provisioning)

Note for your technical file:

- **Anti-rollback:** enable [CONFIG_BOOTLOADER_APP_ANTI_ROLLBACK](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-anti-rollback) and raise [CONFIG_BOOTLOADER_APP_SECURE_VERSION](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-secure-version) when a release fixes a security issue. Each increase burns eFuse bits, and the field has a limited number of bits. Anti-rollback does not support a `factory` partition, and it needs space for a larger bootloader, so plan the partition table offset early.
- **Signing:** sign release images in a controlled environment, such as an offline machine or an HSM, never on developer laptops. Plan key rotation and revocation using the extra Secure Boot digest slots.
- **Server identity:** use a CA you control or a public CA, and decide how devices will receive a new CA certificate before the current one expires.
- **Self-test:** confirm a new image only after the checks that matter for your product, such as cloud connectivity, and keep the self-test short to limit rollbacks caused by power loss.
- Development mode plus virtual eFuses **must** be called out as non-production in risk assessments.

## Validation matrix

| Test | Action | Expected |
|------|--------|----------|
| Partition layout | Step 1 | `otadata`, `ota_0`, `ota_1`; `nvs` and `efuse_em` unchanged |
| Bootloader fits | Step 2 | `0xc000` bootloader with rollback, partition table at `0xF000` |
| First version | Step 5 | Boots from `ota_0`, version 1.0.0; Assignment 4 checks still pass |
| Signed update | Step 6 | Signature verified, boots from `ota_1`, version 1.0.1 confirmed |
| Unsigned image | Step 7 | `Image rejected`; still running 1.0.1 |
| Wrong key | Step 7 | `Image rejected`; still running 1.0.1 |
| Rollback (optional) | Step 8 | 1.0.2 fails self-test; back on 1.0.1; 1.0.2 skipped |
| Real eFuses untouched | Step 9 | `efuse-summary`: `SECURE_BOOT_EN` `False`, `SECURE_VERSION` `0` |

Capture the update and rejection logs for the **secure updates** row in the [EU CRA overview](../overview-eu-cra). State clearly that the results come from virtual eFuses and a lab server.

## What you learned

You should now be able to:

- Add HTTPS OTA updates to a project that already uses Secure Boot V2, flash encryption, and HMAC NVS
- Explain how Secure Boot V2 protects the update path: the app verifies the signature before it switches partitions, and the bootloader verifies again at boot
- Use app rollback so that a broken update does not leave the device unusable
- Explain what anti-rollback adds and why it is a permanent, production-only decision
- Record update evidence for CRA-oriented **secure update** documentation, with the virtual-mode limitation stated

## Previous and next steps

[Previous: Assignment 4](../assignment-4)

[Next: Conclusion](../conclusion)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
