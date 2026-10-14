---
title: "Assignment 2: Protect Data with HMAC-Based NVS Encryption"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 8
showAuthor: false
---

## Assignment 2: Protect data with HMAC-based NVS encryption

In [Assignment 1](../assignment-1) you ran [**https_mbedtls**](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_mbedtls) with the certificate bundle and Wi-Fi from menuconfig. Here you **keep that TLS client code** and add **HMAC-based NVS encryption** on the default `nvs` partition so the lab **Wi-Fi SSID and password live in encrypted NVS**, not only in the compiled `CONFIG_EXAMPLE_WIFI_*` strings.

Read [Lecture 2](../lecture-2) for the threat model, Kconfig paths, and how this differs from flash encryption. The NVS scheme matches [`nvs_encryption_hmac`](https://github.com/espressif/esp-idf/tree/master/examples/security/nvs_encryption_hmac); this assignment applies it to credentials your product would store at rest.

## Before you begin

**Starting point:** Your Assignment 1 tree under `$IDF_PATH/examples/protocols/https_mbedtls` (certificate bundle enabled, `esp32s31` target, Wi-Fi SSID and password set under **Example Connection Configuration**).

**Hardware:** [ESP32-S31-Function-CoreBoard-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-function-coreboard-1/user_guide.html).

**Commands:**

```bash
cd $IDF_PATH/examples/protocols/https_mbedtls
idf.py set-target esp32s31
idf.py menuconfig
idf.py -p PORT build flash monitor
```

Replace `PORT` with your serial port. TODO: Pin a tested ESP-IDF v6.1 commit or workshop fork when the course repository is published.

> [!IMPORTANT]
> **Workshop mode: virtual eFuses.** Keep `CONFIG_EFUSE_VIRTUAL=y` and `CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y` (see [Lab safety and virtual eFuses](../introduction/#lab-safety-and-virtual-efuses)). HMAC key setup must **not** use `espefuse burn-key` on participant boards.

**Preflight:** After `idf.py build`, confirm in `sdkconfig`:

- `CONFIG_EFUSE_VIRTUAL=y`
- `CONFIG_NVS_ENCRYPTION=y`
- `CONFIG_NVS_SEC_KEY_PROTECT_USING_HMAC=y`
- `CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID` is `0` to `5` (not `-1`)

**Forbidden:** `espefuse burn-key`, disabling virtual eFuses to test real provisioning in class, committing Wi-Fi passwords or HMAC key files to git.

> [!WARNING]
> Provisioning a real HMAC key and protecting eFuses is irreversible. Production steps are in the [production provisioning appendix](../appendix-production-provisioning).

> [!NOTE]
> Assignment 1 used `example_connect()`, which reads SSID and password from **menuconfig** and keeps Wi-Fi config in **RAM** (`WIFI_STORAGE_RAM`). This assignment stores credentials in **encrypted NVS** and connects using the loaded values so offline flash dumps do not show your lab passphrase in the NVS region.

## Step 1: Enable HMAC-based NVS encryption

Goal: register the HMAC NVS security provider and encrypt the default `nvs` partition (see [HMAC scheme in ESP-IDF](../lecture-2/#hmac-scheme-in-esp-idf)).

1. Run `idf.py menuconfig`.
2. Open **Component config → NVS Security Provider**.
3. Enable **Enable NVS encryption** ([CONFIG_NVS_ENCRYPTION](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-encryption)) if not already on.
4. Set **NVS key protection scheme** to **Using HMAC peripheral** ([CONFIG_NVS_SEC_KEY_PROTECT_USING_HMAC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-key-protect-using-hmac)).
5. Set **eFuse key ID storing the HMAC key** to **`0`** (or another free block `0` to `5`) ([CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-nvs-sec-hmac-efuse-key-id)).
6. Under **Component config → eFuse Bit Manager**, confirm **Use virtual eFuses** stays enabled for the workshop.

Optional: add a project `sdkconfig.defaults` fragment so the team shares the same baseline:

```ini
CONFIG_NVS_ENCRYPTION=y
CONFIG_NVS_SEC_KEY_PROTECT_USING_HMAC=y
CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID=0
CONFIG_EFUSE_VIRTUAL=y
CONFIG_EFUSE_VIRTUAL_KEEP_IN_FLASH=y
```

You do **not** need the `custom_nvs` partition from the standalone `nvs_encryption_hmac` example unless you extend the lab; the default `nvs` partition is enough for Wi-Fi credentials.

Build once: `idf.py build`. Fix any Kconfig error about an invalid HMAC eFuse key ID before continuing.

## Step 2: Add Wi-Fi credential helpers

Goal: write SSID and password into namespace `workshop_wifi` on the **encrypted** default NVS partition, then load them for connection.

1. In `main/`, add `wifi_creds.h` and `wifi_creds.c`.
2. Register both sources in `main/CMakeLists.txt` (keep `https_mbedtls_example_main.c`):

```cmake
idf_component_register(SRCS "https_mbedtls_example_main.c" "wifi_creds.c" "workshop_wifi_connect.c"
                    PRIV_REQUIRES esp_event nvs_flash esp_netif esp_wifi mbedtls
                    INCLUDE_DIRS ".")
```

3. Implement provisioning and load (lab: one-time copy from menuconfig on first boot; shipping firmware would use provisioning UI or factory tools instead):

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

4. Add **`workshop_wifi_connect.c`** and **`workshop_wifi_connect.h`** with a small STA connect helper (same netif and Wi-Fi init pattern as `example_connect()`, but `wifi_config_t` comes from `wifi_creds_load()`). Minimal implementation:

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

**`workshop_wifi_connect.c`** (abbreviated; mirror scan and auth threshold options from your menuconfig like the [protocol examples Wi-Fi connect](https://github.com/espressif/esp-idf/blob/master/examples/common_components/protocol_examples_common/wifi_connect.c)):

```c
#include "workshop_wifi_connect.h"
#include "wifi_creds.h"

#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_wifi.h"
#include "esp_wifi_default.h"
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "protocol_examples_common.h"

static const char *TAG = "workshop_wifi";
static EventGroupHandle_t s_wifi_event_group;
#define WIFI_CONNECTED_BIT BIT0

static void on_wifi_event(void *arg, esp_event_base_t base, int32_t id, void *data)
{
    (void)arg; (void)data;
    if (base == WIFI_EVENT && id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    }
}

static void on_got_ip(void *arg, esp_event_base_t base, int32_t id, void *data)
{
    (void)arg; (void)base; (void)id; (void)data;
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

    EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group, WIFI_CONNECTED_BIT,
                                           pdFALSE, pdTRUE, pdMS_TO_TICKS(30000));
    if ((bits & WIFI_CONNECTED_BIT) == 0) {
        return ESP_ERR_TIMEOUT;
    }
    ESP_LOGI(TAG, "Connected using credentials from NVS");
    return ESP_OK;
}
```

Add `#include "esp_check.h"` if you use `ESP_RETURN_ON_ERROR`, or replace with explicit `if (err != ESP_OK) return err;`.

## Step 3: Wire `app_main` (keep the TLS task)

Goal: initialize **encrypted NVS before** any credential access; keep **`https_get_task`** unchanged from Assignment 1.

In `https_mbedtls_example_main.c`:

1. Keep all mbedTLS client code and the certificate bundle setup in `https_get_task`.
2. Replace the plain `nvs_flash_init()` / `example_connect()` block with:

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

3. Leave **Component config → mbedTLS → Certificate Bundle** as in Assignment 1.

Flash and monitor: `idf.py -p PORT flash monitor`.

**Success criteria** (in order, log text may vary slightly):

| Check | Expected |
|-------|----------|
| HMAC NVS scheme | `NVS Encryption - Registering HMAC-based scheme...` |
| Default NVS encrypted | `NVS partition "nvs" is encrypted.` |
| Credentials stored | `Stored lab Wi-Fi credentials in encrypted NVS` on first boot, then `already in NVS` on later boots |
| Wi-Fi from NVS | `Loaded Wi-Fi SSID from NVS: ...` and `Connected using credentials from NVS` |
| TLS unchanged | Same success lines as Assignment 1: `Certificate validated`, HTTP JSON from howsmyssl |

Reboot without reflashing: Wi-Fi and TLS should still work using NVS only (menuconfig values are no longer required at runtime once provisioned).

## Step 4: Inspect raw NVS storage

Goal: show that the **passphrase is not visible** in a raw partition read (see [Reference example architecture](../lecture-2/#reference-example-architecture)).

1. Add a one-shot dump after provisioning (development build only), or run a small helper in `app_main` before Wi-Fi connect on the second boot:

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
    esp_partition_read(part, 0, buf, len);
    ESP_LOG_BUFFER_HEXDUMP("nvs_raw", buf, len, ESP_LOG_INFO);
    free(buf);
}
```

2. Call `dump_nvs_prefix(512)` after credentials are committed.
3. Search the monitor hex dump for your **Wi-Fi password** and for the **`workshop_wifi`** namespace string. You should **not** see the password as contiguous ASCII. (The SSID may still appear inside the **application image** if menuconfig strings remain in the binary; record that gap in your notes.)

4. Optional negative test: `idf.py erase-flash`, reflash, confirm HMAC and NVS are reprovisioned in virtual mode and the dump test still passes.

Document screenshots or log excerpts for your CRA-oriented **credentials at rest** evidence (see [CRA and product evidence](../lecture-2/#cra-and-product-evidence)).

## Step 5: Validation matrix

Run these checks and record pass or fail in your workshop notes.

| Test | Action | Expected |
|------|--------|----------|
| Encrypted init | Fresh flash after Step 3 | `nvs` encrypted log lines present |
| TLS regression | No changes inside `https_get_task` | Assignment 1 TLS success criteria still met |
| NVS persistence | Reboot, no reflash | Connects with `already in NVS` / load from NVS |
| Dump | Step 4 hex dump | Lab password not visible as plaintext in `nvs` sample |
| Virtual eFuse | Boot log / `idf.py efuse-summary` | Virtual eFuses active; no real `burn-key` in class |

## What you learned

You should now be able to:

- Enable **HMAC-based NVS encryption** and set a valid **HMAC eFuse key ID** on ESP32-S31
- Keep the **https_mbedtls** TLS flow from Assignment 1 while moving **Wi-Fi credentials** into encrypted NVS
- Explain why `nvs_flash_init()` must run before reading or writing secrets
- Compare API reads with a **raw partition dump** for test evidence
- Tie results to the **credentials at rest** row in the [EU CRA overview](../overview-eu-cra) without duplicating full CRA legal context

## Previous and next steps

[Previous: Lecture 2](../lecture-2)

[Next: Lecture 3: Secure Boot V2](../lecture-3)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
