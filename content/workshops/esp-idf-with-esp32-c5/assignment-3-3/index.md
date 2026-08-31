---
title: "ESP-IDF C5 - Assign. 3.3"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 10
showAuthor: false
summary: "Extend the application from Assignment 3.1 so it fetches a remote version string before updating, and only calls esp_https_ota when that remote version is newer than the one currently running."
---

Unlike the previous assignment, this one is a short challenge rather than a step-by-step guide.

In [Assignment 3.1](../assignment-3-1/), the board always downloaded and applied `FIRMWARE_URL` on every boot, with no way to tell whether the firmware behind that URL was actually newer than what was already running. That's wasteful, and on a real deployment it would mean re-flashing the same image over and over.

Your task is to add a version check in front of the update. The second file is hosted at the following link:

```terminal
https://github.com/espressif/developer-portal-codebase/blob/update-workshop-to-c5-code/content/workshops/esp-idf-with-esp32-c5/ota/version
```

It contains only the latest available version as plain text (for example `1.2.0`). Before calling `do_firmware_update()`, your application should download that file, compare it against the version it's currently running, and only proceed with the OTA update if the remote version is newer.

When you are done, the application should:

* Define `CURRENT_FIRMWARE_VERSION`, a string holding the version of the firmware currently running (for example `"1.0.0"`).
* Define `FIRMWARE_VERSION_URL`, pointing to the plain-text version file hosted alongside `FIRMWARE_URL`.
* Download and parse that remote version string over HTTPS.
* Compare the remote version against `CURRENT_FIRMWARE_VERSION` and only call `do_firmware_update()` when the remote one is newer.
* Log both versions and the decision, so the outcome is visible on the monitor either way.

## Solution outline

You do not need to rewrite the Wi-Fi or OTA logic from Assignment 3.1. Add a version check that runs before `do_firmware_update()` is called from `app_main()`.

* Both `major.minor.patch` version strings need to be broken down into numbers before they can be compared; comparing them as plain strings would rank `"2.0.0"` below `"10.0.0"`.
* The remote version needs to be downloaded before it can be compared. It lives in a small plain-text file, so an `esp_http_client` request that reads its body into a fixed-size buffer is enough. You don't need `esp_https_ota` for this part, since you are not writing anything to flash.
* Structure `app_main()` so the version check happens first: fetch the remote version, log both versions, and only reach `do_firmware_update()` when the remote one is newer.

### Hint: comparing versions

Since both versions follow the `major.minor.patch` format, you can parse them into three integers each and compare them component by component. Here is the complete helper, you can use it as is:

```c
// returns <0, 0, >0 if "a" is older, equal to, or newer than "b" (major.minor.patch)
static int compare_versions(const char *a, const char *b)
{
    int a_parts[3] = {0};
    int b_parts[3] = {0};

    sscanf(a, "%d.%d.%d", &a_parts[0], &a_parts[1], &a_parts[2]);
    sscanf(b, "%d.%d.%d", &b_parts[0], &b_parts[1], &b_parts[2]);

    for (int i = 0; i < 3; i++) {
        if (a_parts[i] != b_parts[i]) {
            return a_parts[i] - b_parts[i];
        }
    }
    return 0;
}
```

Call it as `compare_versions(remote_version, CURRENT_FIRMWARE_VERSION)`: a positive result means the remote version is newer.

### Hint: fetching the remote version

The trickier part is `fetch_remote_version()`, the function that downloads `FIRMWARE_VERSION_URL` and hands you back the version string it contains. It doesn't perform an OTA update, so it needs a plain HTTP request rather than `esp_https_ota`. Here is the complete helper, you can use it as is:

```c
static bool fetch_remote_version(char *version_buf, size_t buf_len)
{
    char response_buf[128] = {0};

    esp_http_client_config_t http_config = {
        .url = FIRMWARE_VERSION_URL,
        .crt_bundle_attach = esp_crt_bundle_attach,
    };

    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    esp_err_t err = esp_http_client_open(client, 0);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to open connection to %s: %s", FIRMWARE_VERSION_URL, esp_err_to_name(err));
        esp_http_client_cleanup(client);
        return false;
    }

    esp_http_client_fetch_headers(client);
    int read_len = esp_http_client_read(client, response_buf, sizeof(response_buf) - 1);
    esp_http_client_close(client);
    esp_http_client_cleanup(client);

    if (read_len <= 0) {
        ESP_LOGE(TAG, "Failed to read version file");
        return false;
    }
    response_buf[read_len] = '\0';

    // strip trailing whitespace/newline from the plain-text version file
    while (read_len > 0 && isspace((unsigned char)response_buf[read_len - 1])) {
        response_buf[--read_len] = '\0';
    }

    if (read_len == 0) {
        ESP_LOGE(TAG, "Version file at %s is empty", FIRMWARE_VERSION_URL);
        return false;
    }

    strncpy(version_buf, response_buf, buf_len - 1);
    version_buf[buf_len - 1] = '\0';

    return true;
}
```

## Assignment Code

<details>
<summary>Show assignment solution</summary>

```c
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_wifi.h"
#include "esp_http_client.h"
#include "esp_https_ota.h"
#include "esp_crt_bundle.h"
#include "nvs_flash.h"
#include <ctype.h>
#include <stdio.h>
#include <string.h>

#define WIFI_SSID     "EXAMPLE_WIFI_SSID"
#define WIFI_PASSWORD "EXAMPLE_WIFI_PASS"

#define FIRMWARE_URL "https://raw.githubusercontent.com/espressif/developer-portal-codebase/update-workshop-to-c5-code/content/workshops/esp-idf-with-esp32-c5/ota/ota-new-firmware.bin"
#define FIRMWARE_VERSION_URL "https://raw.githubusercontent.com/espressif/developer-portal-codebase/update-workshop-to-c5-code/content/workshops/esp-idf-with-esp32-c5/ota/version"

#define CURRENT_FIRMWARE_VERSION "1.0.0"

static const char *TAG = "ota_version_example";

static EventGroupHandle_t s_wifi_event_group;
#define WIFI_CONNECTED_BIT BIT0

// returns <0, 0, >0 if "a" is older, equal to, or newer than "b" (major.minor.patch)
static int compare_versions(const char *a, const char *b)
{
    int a_parts[3] = {0};
    int b_parts[3] = {0};

    sscanf(a, "%d.%d.%d", &a_parts[0], &a_parts[1], &a_parts[2]);
    sscanf(b, "%d.%d.%d", &b_parts[0], &b_parts[1], &b_parts[2]);

    for (int i = 0; i < 3; i++) {
        if (a_parts[i] != b_parts[i]) {
            return a_parts[i] - b_parts[i];
        }
    }
    return 0;
}

static void wifi_event_handler(void *arg, esp_event_base_t event_base,
                                int32_t event_id, void *event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        ESP_LOGI(TAG, "Disconnected from AP, retrying...");
        esp_wifi_connect();
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t *event = (ip_event_got_ip_t *) event_data;
        ESP_LOGI(TAG, "Got IP: " IPSTR, IP2STR(&event->ip_info.ip));
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
    }
}

static void wifi_connect(void)
{
    s_wifi_event_group = xEventGroupCreate();

    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t wifi_init_cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&wifi_init_cfg));

    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, ESP_EVENT_ANY_ID, &wifi_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &wifi_event_handler, NULL));

    wifi_config_t wifi_config = {
        .sta = {
            .ssid = WIFI_SSID,
            .password = WIFI_PASSWORD,
        },
    };

    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
    ESP_ERROR_CHECK(esp_wifi_start());

    ESP_LOGI(TAG, "Connecting to SSID: %s", WIFI_SSID);
    xEventGroupWaitBits(s_wifi_event_group, WIFI_CONNECTED_BIT, pdFALSE, pdTRUE, portMAX_DELAY);
}

static void do_firmware_update(void)
{
    ESP_LOGI(TAG, "Starting OTA update from %s", FIRMWARE_URL);

    esp_http_client_config_t http_config = {
        .url = FIRMWARE_URL,
        .crt_bundle_attach = esp_crt_bundle_attach,
    };

    esp_https_ota_config_t ota_config = {
        .http_config = &http_config,
    };

    esp_err_t ret = esp_https_ota(&ota_config);
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "OTA update successful, rebooting...");
        vTaskDelay(pdMS_TO_TICKS(2000));
        esp_restart();
    } else {
        ESP_LOGE(TAG, "OTA update failed: %s", esp_err_to_name(ret));
    }
}

static bool fetch_remote_version(char *version_buf, size_t buf_len)
{
    char response_buf[128] = {0};

    esp_http_client_config_t http_config = {
        .url = FIRMWARE_VERSION_URL,
        .crt_bundle_attach = esp_crt_bundle_attach,
    };

    esp_http_client_handle_t client = esp_http_client_init(&http_config);
    esp_err_t err = esp_http_client_open(client, 0);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Failed to open connection to %s: %s", FIRMWARE_VERSION_URL, esp_err_to_name(err));
        esp_http_client_cleanup(client);
        return false;
    }

    esp_http_client_fetch_headers(client);
    int read_len = esp_http_client_read(client, response_buf, sizeof(response_buf) - 1);
    esp_http_client_close(client);
    esp_http_client_cleanup(client);

    if (read_len <= 0) {
        ESP_LOGE(TAG, "Failed to read version file");
        return false;
    }
    response_buf[read_len] = '\0';

    // strip trailing whitespace/newline from the plain-text version file
    while (read_len > 0 && isspace((unsigned char)response_buf[read_len - 1])) {
        response_buf[--read_len] = '\0';
    }

    if (read_len == 0) {
        ESP_LOGE(TAG, "Version file at %s is empty", FIRMWARE_VERSION_URL);
        return false;
    }

    strncpy(version_buf, response_buf, buf_len - 1);
    version_buf[buf_len - 1] = '\0';

    return true;
}

void app_main(void)
{
    ESP_ERROR_CHECK(nvs_flash_init());
    wifi_connect();

    char remote_version[32];
    if (!fetch_remote_version(remote_version, sizeof(remote_version))) {
        ESP_LOGE(TAG, "Could not retrieve remote firmware version, skipping update");
        return;
    }

    ESP_LOGI(TAG, "Running version: %s, remote version: %s", CURRENT_FIRMWARE_VERSION, remote_version);

    if (compare_versions(remote_version, CURRENT_FIRMWARE_VERSION) > 0) {
        ESP_LOGI(TAG, "New firmware available, starting OTA update");
        do_firmware_update();
    } else {
        ESP_LOGI(TAG, "Already running the latest firmware, nothing to do");
    }
}
```
</details>

### Next step
> Next step &rarr; [Lecture 4](../lecture-4/)

> Or [go back to navigation menu](.#agenda)
