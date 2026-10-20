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

After Assignment 4, the firmware has TLS, encrypted NVS, Secure Boot V2, and flash encryption in release mode. Serial flashing is now disabled, so the only way to change the firmware of a deployed device is an update over the air, and every update is a chance for an attacker to install their own firmware. Here you add **over-the-air (OTA) updates** to the same project and check that the update path keeps the guarantees you built so far:

- The image is downloaded over **HTTPS**, and the device checks the server certificate.
- The device installs the image only if it is **signed** with your Secure Boot key. With Secure Boot enabled, ESP-IDF turns on [CONFIG_SECURE_SIGNED_ON_UPDATE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-secure-signed-on-update), so the app verifies the signature against the trusted Secure Boot digest before it switches partitions.
- If a new image fails its self-test, the bootloader **rolls back** to the previous one ([App Rollback](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/ota.html#app-rollback)).

## Before you begin

**Starting point:** Assignment 4 complete in the same project.

This assignment runs in the **native `esp-emu`** tool instead of the browser emulator, for two reasons:

- An update only makes sense on a device that keeps its state. `esp-emu` saves the eFuses and the flash to files between runs, so version 1.0.0 provisions the chip once and later versions arrive by OTA.
- The emulated device must reach an HTTPS server on your computer. With `--net user`, the address `192.168.4.1` inside the emulator reaches `127.0.0.1` on your computer.

> [!WARNING]
> **Do not flash these images to your board.** They permanently enable Secure Boot and flash encryption in release mode. See [Lab safety and the ESP32 emulator](../introduction/#lab-safety-and-the-esp32-emulator).

**What you need:**

- `esp-emu` and `make-efuse.py`, installed as in the [optional step of Assignment 3](../assignment-3/#step-8-optional-test-rejection-of-bad-firmware)
- Python 3, to run the test HTTPS server
- OpenSSL, to create the server certificate

The shared partition layout from Assignment 2 already has `otadata`, `ota_0` at `0x20000`, and `ota_1` at `0x1E0000`, so you do not change `partitions.csv`.

**To start over:** create a new eFuse file and copy the merged image again, as in [Step 5](#step-5-run-version-100).

## Step 1: Enable app rollback

Goal: let a new image prove it works before the device commits to it.

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

2. Under **Bootloader config → Application Rollback**, enable **Enable app rollback support** ([CONFIG_BOOTLOADER_APP_ROLLBACK_ENABLE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-rollback-enable)).
3. Leave **Enable app anti-rollback support** off. The next section explains what it does.
4. Save, exit, and add to `sdkconfig.defaults`:

```ini
CONFIG_BOOTLOADER_APP_ROLLBACK_ENABLE=y
```

The bootloader stays at `0xC000` bytes, and the app fits in the `0x1C0000` OTA slots with about 35% free.

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
- Anti-rollback needs app rollback, and it does not support `factory` or `test` partitions. The shared layout already meets both requirements.
- Anti-rollback makes the bootloader larger. Check that it still fits below the partition table at `0x10000`.

**Menuconfig options**, all under **Bootloader config → Application Rollback**:

| Option | Purpose |
|--------|---------|
| **Enable app anti-rollback support** ([CONFIG_BOOTLOADER_APP_ANTI_ROLLBACK](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-anti-rollback)) | Turns on the secure version check in the bootloader |
| **eFuse secure version of app** | The secure version written into this build's image |
| **Size of the efuse secure version field** | How many eFuse bits ESP-IDF uses for the counter |

Leave **Emulate operations with efuse secure version (only test)** off: it is a development option that turns on virtual eFuses, and it does not belong in a production build.

**Trying it in the emulator:** anti-rollback stays off in the steps below to keep the lab focused on rollback. If you try it, the `SECURE_VERSION` bits are burned in your eFuse file just as they would be on a chip, so each raise is permanent for that file. A new eFuse file gives you a blank chip again.

## Step 2: Create the OTA server certificate

Goal: give the test server an identity the device can verify.

The device connects to `192.168.4.1`, so the certificate must contain that IP address in its subject alternative name (SAN). In the project directory, run:

```bash
mkdir -p server_certs ota_server
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout server_certs/ca_key.pem -out server_certs/ca_cert.pem \
  -subj "/CN=192.168.4.1" -addext "subjectAltName=IP:192.168.4.1"
```

`ca_cert.pem` is embedded in the firmware and is public. `ca_key.pem` is the server private key. Add it to `.gitignore`:

```text
server_certs/ca_key.pem
```

> [!WARNING]
> This self-signed certificate is for the lab only. A product OTA server uses a certificate from a CA you control or a public CA, and its private key never leaves the server infrastructure.

## Step 3: Add the OTA code

Goal: download, verify, and install a new image, and confirm a new image after it boots.

1. Create `main/Kconfig.projbuild`:

```kconfig
menu "Workshop OTA"

    config WORKSHOP_OTA_URL
        string "Firmware upgrade URL"
        default "https://192.168.4.1:8070/firmware.bin"
        help
            HTTPS URL of the signed application image served by the OTA server.
            The host must match the subjectAltName in server_certs/ca_cert.pem.

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
                    PRIV_REQUIRES esp_event nvs_flash esp_netif esp_wifi mbedtls efuse esp_partition bootloader_support spi_flash
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

Calling `workshop_ota_confirm_running_app()` after Wi-Fi connects makes "Wi-Fi works" the self-test: if a new image cannot connect, `ESP_ERROR_CHECK` resets the device before the image is confirmed, and the bootloader rolls back.

7. Add the URL to `sdkconfig.defaults`:

```ini
CONFIG_WORKSHOP_OTA_URL="https://192.168.4.1:8070/firmware.bin"
```

## Step 4: Create the test OTA server

Goal: serve the update over HTTPS from your computer.

Create `ota_server.py` in the project root:

```python
import http.server
import ssl
import sys

ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain(sys.argv[1], sys.argv[2])
srv = http.server.ThreadingHTTPServer(("127.0.0.1", 8070), http.server.SimpleHTTPRequestHandler)
srv.socket = ctx.wrap_socket(srv.socket, server_side=True)
print("Serving HTTPS on 127.0.0.1:8070")
srv.serve_forever()
```

The server listens only on `127.0.0.1`, so it is not reachable from your network, and it serves the files of the folder it runs in. It keeps running when a download is aborted, which happens on purpose in the rejection tests.

## Step 5: Run version 1.0.0

Goal: provision a blank emulated chip with the first OTA-capable version.

1. Build and merge, as in Assignment 4:

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

2. Create a blank eFuse file and a working copy of the flash image. These two files are your emulated device for the rest of the assignment:

```bash
python3 make-efuse.py --chip esp32s31 --chip-rev 0.0 -o lab.efuse
cp build/merged-secure.bin lab-flash.bin
```

3. Run the first boot. `--save-state` writes the burned eFuses and the encrypted flash back to the files:

```bash
esp-emu --chip esp32s31 --firmware lab-flash.bin --efuse lab.efuse --save-state --net user --timeout 120s --exit-on "Certificate verified"
```

The first boot enables Secure Boot and flash encryption as in Assignment 4. The OTA server is not running yet, so the update check fails, and the app continues with the TLS request. `esp-emu` has internet access through your computer, so the request succeeds this time:

```log
I (...) workshop_ota: Running partition: ota_0, version: 1.0.0
I (...) workshop_ota: Checking https://192.168.4.1:8070/firmware.bin
E (...) esp_https_ota: Failed to open HTTP connection: ESP_ERR_HTTP_CONNECT
E (...) workshop_ota: workshop_ota_check_and_update(...): Could not connect to the OTA server
I (...) esp-x509-crt-bundle: Certificate validated
I (...) example: Certificate verified.
```

From now on, always run `esp-emu` on `lab-flash.bin` and `lab.efuse` with `--save-state`. Never copy `merged-secure.bin` over `lab-flash.bin` again: the chip now expects encrypted flash.

## Step 6: Publish and install version 1.0.1

Goal: run a successful signed update.

1. In a second terminal, start the server from the `ota_server` folder. Leave it running for the rest of the assignment:

```bash
cd ota_server
python3 ../ota_server.py ../server_certs/ca_cert.pem ../server_certs/ca_key.pem
```

2. In the top-level `CMakeLists.txt`, change the version to `1.0.1`, then build and publish the **signed** image:

```bash
idf.py build
cp build/<project-name>.bin ota_server/firmware.bin
```

The build writes two application images: `<project-name>.bin`, signed with `secure_boot_signing_key.pem`, and `<project-name>-unsigned.bin`. The signed one is the release artifact. The server sends it as plaintext over TLS; the device encrypts it with its own flash encryption key as it writes it to `ota_1`.

3. Boot the device again:

```bash
esp-emu --chip esp32s31 --firmware lab-flash.bin --efuse lab.efuse --save-state --net user --timeout 120s --exit-on "Firmware is up to date"
```

Expect:

```log
I (...) workshop_ota: Running partition: ota_0, version: 1.0.0
I (...) esp_https_ota: Starting OTA...
I (...) esp_https_ota: Writing to <ota_1> partition at offset 0x1e0000
I (...) workshop_ota: Running version: 1.0.0, server version: 1.0.1
I (...) secure_boot_v2: Take trusted digest key(s) from eFuse block(s)
I (...) secure_boot_v2: #0 app key digest == #0 trusted key digest
I (...) workshop_ota: OTA succeeded, rebooting into the new firmware
```

After the reboot, the bootloader verifies the new image, and the app confirms it:

```log
I (...) workshop_ota: Running partition: ota_1, version: 1.0.1
I (...) workshop_ota: New firmware passed the self-test, cancelling rollback
I (...) workshop_ota: Running version: 1.0.1, server version: 1.0.1
I (...) workshop_ota: Firmware is up to date
```

The trusted digest is the one the bootloader burned into `BLOCK_KEY0` on the first boot.

## Step 7: Reject unsigned and wrongly signed images

Goal: show that an attacker who controls the download cannot install their own firmware.

1. Change the version to `1.0.2` and build. Publish the **unsigned** image:

```bash
idf.py build
cp build/<project-name>-unsigned.bin ota_server/firmware.bin
```

2. Boot the device, stopping at the rejection:

```bash
esp-emu --chip esp32s31 --firmware lab-flash.bin --efuse lab.efuse --save-state --net user --timeout 120s --exit-on "Image rejected"
```

The image downloads, then verification fails:

```log
I (...) workshop_ota: Running version: 1.0.1, server version: 1.0.2
E (...) secure_boot_v2_rsa: Signature verification failed, err: -149
E (...) esp_image: Secure boot signature verification failed
W (...) esp_image: image valid, signature bad
E (...) esp_ota_ops: New image failed verification
E (...) workshop_ota: Image rejected: signature or hash verification failed
```

The device keeps running 1.0.1 from `ota_1` and continues with the TLS request.

3. Sign the same image with a key the device does not trust, and publish it:

```bash
espsecure generate-signing-key --version 2 --scheme rsa3072 wrong_key.pem
espsecure sign-data --version 2 --keyfile wrong_key.pem --output ota_server/firmware.bin build/<project-name>-unsigned.bin
```

4. Boot the device with the same command as in item 2. The signature is valid, but its public key digest does not match the trusted digest, so the image is rejected again:

```log
E (...) esp_image: Secure boot signature verification failed
W (...) esp_image: image valid, signature bad
E (...) esp_ota_ops: New image failed verification
E (...) workshop_ota: Image rejected: signature or hash verification failed
```

5. Delete `wrong_key.pem`.

Both tests also answer a common question: TLS protects the download, but the signature check protects the device even if the server, or the network between the server and the device, is compromised.

## Step 8: Test rollback (optional)

Goal: watch the bootloader return to the previous image when a correctly signed update fails its self-test.

1. In the project configuration, enable **Workshop OTA → Simulate a failed self-test after an update**. Keep the version at `1.0.2`.
2. Build and publish the **signed** image:

```bash
idf.py build
cp build/<project-name>.bin ota_server/firmware.bin
```

3. Boot the device:

```bash
esp-emu --chip esp32s31 --firmware lab-flash.bin --efuse lab.efuse --save-state --net user --timeout 180s --exit-on "was rolled back before"
```

Expect the update to install into `ota_0`, version 1.0.2 to fail its self-test, and the bootloader to return to `ota_1`:

```log
I (...) workshop_ota: OTA succeeded, rebooting into the new firmware
...
I (...) boot: Loaded app from partition at offset 0x20000
I (...) workshop_ota: Running partition: ota_0, version: 1.0.2
E (...) workshop_ota: Self-test failed, rolling back to the previous firmware
I (...) esp_ota_ops: Rollback to previously worked partition.
...
I (...) boot: Loaded app from partition at offset 0x1e0000
I (...) workshop_ota: Running partition: ota_1, version: 1.0.1
W (...) workshop_ota: Version 1.0.2 was rolled back before, skipping it
```

4. Disable **Simulate a failed self-test after an update** again, and stop the server with **Ctrl+C**.

## Step 9: Review production configuration (read only)

Goal: know what changes for a product fleet.

Read:

- [Over The Air Updates (OTA)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/ota.html), in particular [Anti-rollback](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/ota.html#anti-rollback)
- [ESP HTTPS OTA](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/system/esp_https_ota.html)
- [Real-board appendix](../appendix-production-provisioning)

Note for your technical file:

- **Anti-rollback:** enable [CONFIG_BOOTLOADER_APP_ANTI_ROLLBACK](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-anti-rollback) and raise [CONFIG_BOOTLOADER_APP_SECURE_VERSION](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-bootloader-app-secure-version) when a release fixes a security issue. Each increase burns eFuse bits, and the field has a limited number of bits. Decide the policy before the first release.
- **Signing:** sign release images in a controlled environment, such as an offline machine or an HSM, never on developer laptops. Plan key rotation and revocation: the first boot revoked the unused Secure Boot digest slots, so add the extra keys before that if you need them.
- **Server identity:** use a CA you control or a public CA, and decide how devices will receive a new CA certificate before the current one expires.
- **Self-test:** confirm a new image only after the checks that matter for your product, such as cloud connectivity, and keep the self-test short to limit rollbacks caused by power loss.

## Validation matrix

| Test | Action | Expected |
|------|--------|----------|
| Bootloader fits | Step 1 | `0xc000` bootloader with rollback, below the partition table at `0x10000` |
| First version | Step 5 | Boots from `ota_0`, version 1.0.0; Assignment 4 checks still pass |
| Signed update | Step 6 | Signature verified, boots from `ota_1`, version 1.0.1 confirmed |
| Unsigned image | Step 7 | `Image rejected`; still running 1.0.1 |
| Wrong key | Step 7 | `Image rejected`; still running 1.0.1 |
| Rollback (optional) | Step 8 | 1.0.2 fails self-test; back on 1.0.1; 1.0.2 skipped |

Capture the update and rejection logs for the **secure updates** row in the [EU CRA overview](../overview-eu-cra). State that the results come from the emulator and a lab server.

## What you learned

You should now be able to:

- Add HTTPS OTA updates to a project that already uses Secure Boot V2, flash encryption, and encrypted NVS
- Explain how Secure Boot V2 protects the update path: the app verifies the signature before it switches partitions, and the bootloader verifies again at boot
- Use app rollback so that a broken update does not leave the device unusable
- Explain what anti-rollback adds and why the secure version policy is a permanent decision
- Keep a stateful emulated device across runs with `esp-emu --save-state`
- Record update evidence for CRA-oriented **secure update** documentation

## Previous and next steps

[Previous: Assignment 4](../assignment-4)

[Next: Conclusion](../conclusion)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
