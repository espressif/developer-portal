---
title: "Assignment 2: Protect Data with HMAC-Based NVS Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 8
showAuthor: false
---

## Assignment 2: Protect data with HMAC-based NVS encryption

In [Assignment 1](../assignment-1) you ran [**https_mbedtls**](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_mbedtls) with the certificate bundle and Wi-Fi from menuconfig. Here you **keep that TLS client code** and add **HMAC-based NVS encryption** on the default `nvs` partition, so the lab **Wi-Fi SSID and password live in encrypted NVS** instead of only in the compiled `CONFIG_EXAMPLE_WIFI_*` strings.

The NVS configuration follows the ESP-IDF example [`nvs_encryption_hmac`](https://github.com/espressif/esp-idf/tree/master/examples/security/nvs_encryption_hmac): the HMAC key lives in a **real eFuse key block**, and `nvs_flash_init()` derives the XTS keys from it at runtime. Read [Lecture 2](../lecture-2) for the threat model, the first-boot behavior, and how this differs from flash encryption.

## Before you begin

**Starting point:** Assignment 1 complete in the same project (certificate bundle enabled, Wi-Fi set under **Example Connection Configuration**). Do not run `set-target` again: it resets `sdkconfig`.

> [!WARNING]
> **This assignment burns a real eFuse key.** On the first encrypted boot, `nvs_flash_init()` generates a random HMAC key and programs it into the selected key block with purpose `HMAC_UP`. This is **permanent**: the block cannot be reused, the key cannot be read back, and erasing flash does not undo it. The board keeps working normally. Keep `CONFIG_EFUSE_VIRTUAL` **off** for this assignment. See [Provisioning the HMAC key](../lecture-2/#provisioning-the-hmac-key).

**Check that the key block is free:** run `idf.py -p PORT efuse-summary`. For key ID `0`, `BLOCK_KEY0` must show `Purpose: USER` (unused) or `HMAC_UP` from an earlier run:

```text
BLOCK_KEY0 (BLOCK4)
Purpose: USER
            Key0 or user data
= 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
```

Any other purpose means the block is taken; choose another key ID. Never commit Wi-Fi passwords or key files.

## Step 1: Enable HMAC-based NVS encryption

Goal: register the HMAC NVS security provider and encrypt the default `nvs` partition (see [HMAC scheme in ESP-IDF](../lecture-2/#hmac-scheme-in-esp-idf)).

1. Run `idf.py menuconfig`.
2. Open **Component config → NVS** and enable **Enable NVS encryption** ([CONFIG_NVS_ENCRYPTION](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-encryption)).
3. Open **Component config → NVS Security Provider** (visible only after step 2).
4. Confirm **NVS Encryption: Key Protection Scheme** is **Using HMAC peripheral** ([CONFIG_NVS_SEC_KEY_PROTECT_USING_HMAC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-key-protect-using-hmac)). This is the default on the ESP32-S31.
5. Set **eFuse key ID storing the HMAC key** to **`0`**, or the free block you chose in [Before you begin](#before-you-begin) ([CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-hmac-efuse-key-id)).

Optional: add the same settings to the project `sdkconfig.defaults` so the team shares one baseline. The first two lines match the upstream example:

```ini
CONFIG_NVS_ENCRYPTION=y
CONFIG_NVS_SEC_KEY_PROTECT_USING_HMAC=y
CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID=0
```

You do **not** need the `custom_nvs` partition from the standalone example; the default `nvs` partition is enough for Wi-Fi credentials.

Build once: `idf.py build`. If the build stops with `Configured eFuse block (CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID) out of range!`, the key ID is still `-1`.

### If the app does not fit the factory partition

The default partition table reserves 1 MB (`0x100000`) for the app and assumes a 2 MB flash. With NVS encryption, Wi-Fi, and mbedTLS, the binary can exceed that, and the build fails with an error like this:

```text
Error: app partition is too small for binary https_mbedtls.bin size 0x108580:
  - Part 'factory' 0/0 @ 0x10000 size 0x100000 (overflow 0x8580)
```

The ESP32-S31-WROOM-3 module on the board has 16 MB of flash, so increase the flash size and use a custom partition table with a larger `factory` partition:

1. Run `idf.py menuconfig`.
2. Open **Serial flasher config → Flash size** and select **16 MB** ([CONFIG_ESPTOOLPY_FLASHSIZE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-esptoolpy-flashsize)).
3. Open **Partition Table → Partition Table** and select **Custom partition table CSV**. Keep **Custom partition CSV file** as `partitions.csv`.
4. Check that **Partition Table → Offset of partition table** is `0x8000` (the default, [CONFIG_PARTITION_TABLE_OFFSET](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-partition-table-offset)). The offsets in the CSV below assume this value.
5. Create `partitions.csv` in the project root (next to `CMakeLists.txt`):

   ```csv
   # Name,   Type, SubType, Offset,   Size,     Flags
   nvs,      data, nvs,     0x9000,   0x6000,
   phy_init, data, phy,     0xf000,   0x1000,
   factory,  app,  factory, 0x10000,  0x200000,
   ```

   The partition table itself occupies `0x8000` to `0x8FFF`, so `nvs` starts at `0x9000`, which is the same place as in the default table. App partitions must start on a 64 KB (`0x10000`) boundary. The `factory` partition grows from 1 MB to 2 MB.

6. Run `idf.py build` again.

If you later change the partition table offset (for example, because a larger bootloader no longer fits below `0x8000`), shift every offset in the CSV by the same amount, or leave the **Offset** column empty so ESP-IDF places the partitions automatically.

To share the configuration with the team, add these lines to `sdkconfig.defaults`:

```ini
CONFIG_ESPTOOLPY_FLASHSIZE_16MB=y
CONFIG_PARTITION_TABLE_CUSTOM=y
CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions.csv"
CONFIG_PARTITION_TABLE_OFFSET=0x8000
```

**Optional, pre-burn your own key.** The workshop lets the firmware generate the key on first boot. To use a key generated on the host instead, burn it **before** flashing the app, into the block that matches the key ID:

```bash
idf.py -p PORT efuse-burn-key BLOCK_KEY0 hmac_key_file.bin HMAC_UP
```

## Step 2: Erase the plaintext NVS from Assignment 1

Goal: start the encrypted partition from a clean state.

The `nvs` partition still holds **plaintext** pages written by Assignment 1. Encrypted NVS cannot read them, so erase the flash before the first encrypted boot:

```bash
idf.py -p PORT erase-flash
```

Erasing flash does not touch eFuses.

## Step 3: Add Wi-Fi credential helpers

Goal: write SSID and password into namespace `workshop_wifi` on the **encrypted** default NVS partition, then load them for connection.

1. In `main/`, add four files: `wifi_creds.h`, `wifi_creds.c`, `workshop_wifi_connect.h`, and `workshop_wifi_connect.c`.
2. Register the new sources in `main/CMakeLists.txt`, keeping `https_mbedtls_example_main.c` and the upstream dependencies, and add `esp_wifi`:

```cmake
idf_component_register(SRCS "https_mbedtls_example_main.c" "wifi_creds.c" "workshop_wifi_connect.c"
                    PRIV_REQUIRES esp_event nvs_flash esp_netif esp_wifi mbedtls
                    INCLUDE_DIRS ".")
```

3. Implement provisioning and load (lab: one-time copy from menuconfig on first boot; shipping firmware would use a provisioning flow or factory tools instead):

**`wifi_creds.h`**

```c
#pragma once

#include "esp_err.h"
#include "esp_wifi.h"

#ifdef __cplusplus
extern "C" {
#endif

esp_err_t wifi_creds_provision_from_menuconfig_if_missing(void);
esp_err_t wifi_creds_load(wifi_config_t *cfg);

#ifdef __cplusplus
}
#endif
```

**`wifi_creds.c`**

```c
#include "wifi_creds.h"

#include <string.h>

#include "nvs.h"
#include "nvs_flash.h"
#include "esp_log.h"
#include "sdkconfig.h"

static const char *TAG = "wifi_creds";
static const char *NS = "workshop_wifi";
static const char *KEY_SSID = "ssid";
static const char *KEY_PASS = "pass";

esp_err_t wifi_creds_provision_from_menuconfig_if_missing(void)
{
    nvs_handle_t h;
    esp_err_t err = nvs_open(NS, NVS_READONLY, &h);
    if (err == ESP_OK) {
        size_t len = 0;
        err = nvs_get_str(h, KEY_SSID, NULL, &len);
        nvs_close(h);
        if (err == ESP_OK && len > 1) {
            ESP_LOGI(TAG, "Wi-Fi credentials already in NVS");
            return ESP_OK;
        }
    }

    err = nvs_open(NS, NVS_READWRITE, &h);
    if (err != ESP_OK) {
        return err;
    }
#if CONFIG_EXAMPLE_CONNECT_WIFI
    err = nvs_set_str(h, KEY_SSID, CONFIG_EXAMPLE_WIFI_SSID);
    if (err == ESP_OK) {
        err = nvs_set_str(h, KEY_PASS, CONFIG_EXAMPLE_WIFI_PASSWORD);
    }
    if (err == ESP_OK) {
        err = nvs_commit(h);
    }
    nvs_close(h);
    if (err == ESP_OK) {
        ESP_LOGI(TAG, "Stored lab Wi-Fi credentials in encrypted NVS");
    }
    return err;
#else
    nvs_close(h);
    return ESP_ERR_NOT_SUPPORTED;
#endif
}

esp_err_t wifi_creds_load(wifi_config_t *cfg)
{
    memset(cfg, 0, sizeof(*cfg));
    nvs_handle_t h;
    esp_err_t err = nvs_open(NS, NVS_READONLY, &h);
    if (err != ESP_OK) {
        return err;
    }

    size_t ssid_len = sizeof(cfg->sta.ssid);
    size_t pass_len = sizeof(cfg->sta.password);
    err = nvs_get_str(h, KEY_SSID, (char *)cfg->sta.ssid, &ssid_len);
    if (err == ESP_OK) {
        err = nvs_get_str(h, KEY_PASS, (char *)cfg->sta.password, &pass_len);
    }
    nvs_close(h);

    if (err == ESP_OK) {
        ESP_LOGI(TAG, "Loaded Wi-Fi SSID from NVS: %s", cfg->sta.ssid);
    }
    return err;
}
```

4. Add a small STA connect helper. It uses the same netif and Wi-Fi init pattern as `example_connect()`, but `wifi_config_t` comes from `wifi_creds_load()`:

**`workshop_wifi_connect.h`**

```c
#pragma once

#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

esp_err_t workshop_wifi_connect(void);

#ifdef __cplusplus
}
#endif
```

**`workshop_wifi_connect.c`** (minimal; mirror scan and auth threshold options from the [protocol examples Wi-Fi connect](https://github.com/espressif/esp-idf/blob/master/examples/common_components/protocol_examples_common/wifi_connect.c) if your AP needs them):

```c
#include "workshop_wifi_connect.h"
#include "wifi_creds.h"

#include "esp_check.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_wifi.h"
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"

#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT      BIT1
#define WIFI_MAX_RETRY     5

static const char *TAG = "workshop_wifi";
static EventGroupHandle_t s_wifi_event_group;
static int s_retry_count;

static void on_wifi_event(void *arg, esp_event_base_t base, int32_t id, void *data)
{
    if (id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (id == WIFI_EVENT_STA_DISCONNECTED) {
        if (s_retry_count < WIFI_MAX_RETRY) {
            s_retry_count++;
            ESP_LOGW(TAG, "Disconnected, retry %d/%d", s_retry_count, WIFI_MAX_RETRY);
            esp_wifi_connect();
        } else {
            xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
        }
    }
}

static void on_got_ip(void *arg, esp_event_base_t base, int32_t id, void *data)
{
    s_retry_count = 0;
    xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
}

esp_err_t workshop_wifi_connect(void)
{
    wifi_config_t cfg;
    ESP_RETURN_ON_ERROR(wifi_creds_load(&cfg), TAG, "load creds");

    s_wifi_event_group = xEventGroupCreate();
    esp_netif_create_default_wifi_sta();
    wifi_init_config_t wcfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&wcfg));
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &on_wifi_event, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &on_got_ip, NULL));
    ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM));
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &cfg));
    ESP_ERROR_CHECK(esp_wifi_start());

    EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group, WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
                                           pdFALSE, pdFALSE, pdMS_TO_TICKS(30000));
    if ((bits & WIFI_CONNECTED_BIT) == 0) {
        ESP_LOGE(TAG, "Could not connect to SSID %s", cfg.sta.ssid);
        return ESP_ERR_TIMEOUT;
    }
    ESP_LOGI(TAG, "Connected using credentials from NVS");
    return ESP_OK;
}
```

`WIFI_STORAGE_RAM` stops the Wi-Fi driver from keeping its own copy of the credentials in NVS, so `workshop_wifi` is the only place they are stored.

## Step 4: Wire app_main (keep the TLS task)

Goal: initialize **encrypted NVS before** any credential access; keep **`https_get_task`** unchanged from Assignment 1.

In `https_mbedtls_example_main.c`:

1. Keep all mbedTLS client code and the certificate bundle setup in `https_get_task`.
2. Replace `#include "protocol_examples_common.h"` with the two new headers, and replace the `nvs_flash_init()` / `example_connect()` block in `app_main`:

```c
#include "wifi_creds.h"
#include "workshop_wifi_connect.h"

void app_main(void)
{
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    ESP_ERROR_CHECK(wifi_creds_provision_from_menuconfig_if_missing());

    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    ESP_ERROR_CHECK(workshop_wifi_connect());

    xTaskCreate(&https_get_task, "https_get_task", 8192, NULL, 5, NULL);
}
```

3. Leave **Component config → mbedTLS → Certificate Bundle** as in Assignment 1. Keep `protocol_examples_common` in the project: `wifi_creds.c` still reads the lab SSID and password from its menuconfig options on first boot.

Flash and monitor: `idf.py -p PORT flash monitor`.

**First boot** (empty key block). The error and warning lines are expected: no key exists yet, so `nvs_flash_init()` generates one and burns it.

```log
E (418) nvs_sec_provider: Could not find HMAC key in configured eFuse block!
W (428) nvs: Failed to read NVS security cfg: [0xF001] (ERROR)
I (428) nvs: Generating NVS encr-keys...
I (438) efuse: Batch mode of writing fields is enabled
I (438) efuse: BURN BLOCK4
I (448) efuse: BURN BLOCK4 - OK (write block == read block)
I (448) efuse: BURN BLOCK0
I (448) efuse: BURN BLOCK0 - OK (all write block bits are set)
I (458) efuse: BURN BLOCK0
I (458) efuse: BURN BLOCK0 - OK (all write block bits are set)
I (468) efuse: Batch mode. Prepared fields are committed
I (478) nvs: NVS partition "nvs" is encrypted.
```

**Success criteria** (log text may vary slightly):

| Check | Expected |
|-------|----------|
| HMAC NVS scheme | `NVS Encryption - Registering HMAC-based scheme...` |
| HMAC key | First boot: `Generating NVS encr-keys...`. Later boots: no key messages |
| Default NVS encrypted | `NVS partition "nvs" is encrypted.` on every boot |
| Credentials stored | `Stored lab Wi-Fi credentials in encrypted NVS` on first boot, then `Wi-Fi credentials already in NVS` |
| Wi-Fi from NVS | `Loaded Wi-Fi SSID from NVS: ...` and `Connected using credentials from NVS` |
| TLS unchanged | Same success lines as Assignment 1: `esp-x509-crt-bundle: Certificate validated`, `Certificate verified.`, HTTP JSON from howsmyssl |

Reboot without reflashing: Wi-Fi and TLS should still work using NVS only.

Then confirm the key in eFuse:

```bash
idf.py -p PORT efuse-summary
```

The block for your key ID should now show purpose `HMAC_UP`, with the key value hidden:

```text
BLOCK_KEY0 (BLOCK4)
  Purpose: HMAC_UP
            Key0 or user data
   = ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? -/-
```

Compare this with the output from [Before you begin](#before-you-begin), where the block showed `Purpose: USER`, zeros, and `R/W`. The `??` bytes mean the key is read-protected and software cannot read it. The `-/-` flags mean the block is now protected against both reads and further writes. Save this output for your provisioning record.

## Step 5: Inspect raw NVS storage

Goal: show that the **passphrase is not visible** in a raw partition read, as the example does with `dump_custom_nvs_partition()` (see [Reference example architecture](../lecture-2/#reference-example-architecture)).

1. Add a development-only dump helper to `https_mbedtls_example_main.c`:

```c
#include <stdlib.h>
#include "esp_partition.h"

static void dump_nvs_prefix(size_t len)
{
    const esp_partition_t *part = esp_partition_find_first(
        ESP_PARTITION_TYPE_DATA, ESP_PARTITION_SUBTYPE_DATA_NVS, "nvs");
    if (!part) {
        return;
    }
    uint8_t *buf = calloc(1, len);
    if (!buf) {
        return;
    }
    ESP_ERROR_CHECK(esp_partition_read(part, 0, buf, len));
    ESP_LOG_BUFFER_HEXDUMP("nvs_raw", buf, len, ESP_LOG_INFO);
    free(buf);
}
```

2. Call `dump_nvs_prefix(512)` right after `wifi_creds_provision_from_menuconfig_if_missing()`.
3. Search the monitor hex dump for your **Wi-Fi password** and for the **`workshop_wifi`** namespace string. Neither should appear as contiguous ASCII. The first 32 bytes (page header) stay readable; that is expected. The SSID and password may still appear inside the **application image**, because the menuconfig strings are compiled into the binary. Record that gap in your notes.
4. **Erase test:** run `idf.py -p PORT erase-flash`, then `idf.py -p PORT flash monitor`. Expected:
   - No `Generating NVS encr-keys...` line: the HMAC key is still in eFuse, so the same XTS keys are derived.
   - `Stored lab Wi-Fi credentials in encrypted NVS` again, because the NVS contents were erased.
   - The dump still shows no plaintext password.

Remove the dump call when you are done. Keep screenshots or log excerpts for your CRA-oriented **credentials at rest** evidence (see [CRA and product evidence](../lecture-2/#cra-and-product-evidence)).

## Step 6: Validation matrix

Run these checks and record pass or fail in your workshop notes.

| Test | Action | Expected |
|------|--------|----------|
| Encrypted init | First flash after Step 4 | Key generated once, `nvs` encrypted log line present |
| eFuse key | `idf.py efuse-summary` | Purpose `HMAC_UP` on the configured block, key value read-protected |
| TLS regression | No changes inside `https_get_task` | Assignment 1 TLS success criteria still met |
| NVS persistence | Reboot, no reflash | `Wi-Fi credentials already in NVS`, connects from NVS |
| Dump | Step 5 hex dump | Lab password and namespace not visible as plaintext |
| Erase keeps key | Step 5 erase test | No new key generated; credentials provisioned again and still encrypted |

## What you learned

You should now be able to:

- Enable **HMAC-based NVS encryption** and set a valid **HMAC eFuse key ID** on ESP32-S31
- Provision a real `HMAC_UP` key on first boot and record the block in a provisioning record
- Keep the **https_mbedtls** TLS flow from Assignment 1 while moving **Wi-Fi credentials** into encrypted NVS
- Explain why `nvs_flash_init()` must run before reading or writing secrets
- Compare API reads with a **raw partition dump** for test evidence
- Tie results to the **credentials at rest** row in the [EU CRA overview](../overview-eu-cra) without duplicating full CRA legal context

## Previous and next steps

[Previous: Lecture 2](../lecture-2)

[Next: Lecture 3: Secure Boot V2](../lecture-3)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
