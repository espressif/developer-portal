---
title: "ESP-IDF C5 - Assign. 1.2"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 4
showAuthor: false
summary: "Change the band mode of the station from Assignment 1.1 so the ESP32-C5 picks the band automatically instead of being locked to 5 GHz."
---

Unlike the previous assignment, this one is a short challenge rather than a step-by-step guide.

In [Assignment 1.1](../assignment-1-1/), you forced the radio onto the 5 GHz band with `WIFI_BAND_MODE_5G_ONLY`. That works well when you know a 5 GHz access point is always in range, but it also means the board never connects if only 2.4 GHz is available.

Your task is to make the station __band-agnostic__: let the `ESP32-C5` scan both bands and connect on whichever one gives the strongest signal. As you saw in [Lecture 1](../lecture-1/), the `esp_wifi_set_band_mode()` API accepts more than one mode, and reaching this behavior only takes a single line change.

When you are done, the board should:

* Connect on 5 GHz when a 5 GHz access point is available.
* Fall back to 2.4 GHz when 5 GHz is out of range.
* Still report the band and channel it actually joined, using the logging you already wrote in Assignment 1.1.

## Solution outline

You do not need to rewrite the application. Start from your Assignment 1.1 code and change only how the band is selected.

* Recall from [Lecture 1](../lecture-1/) that the band is chosen through the `esp_wifi_set_band_mode()` API, and that this function accepts more than one `wifi_band_mode_t` value.
* Review the list of accepted values in the [`esp_wifi_set_band_mode()` reference](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c5/api-reference/network/esp_wifi.html#_CPPv422esp_wifi_set_band_mode16wifi_band_mode_t) and decide which one lets the driver scan both bands and pick the connection itself.
* Locate where Assignment 1.1 sets the band mode and update the value accordingly. Everything else, including the `esp_wifi_get_band()` and `esp_wifi_sta_get_ap_info()` logging, stays the same and will report whichever band the board landed on.

To see the fallback in action, test against a network that broadcasts only on 2.4 GHz, or move away from your 5 GHz access point. The log line should switch from `Connected on 5 GHz!` to `Connected on 2.4 GHz.`, and the reported channel should drop below 36.

## Assignment Code

<details>
<summary>Show assignment solution</summary>

```c
#include <stdio.h>
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_netif.h"
#include "esp_event.h"
#include "esp_wifi.h"
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"

#define TAG                  "wifi_auto_example"
#define EXAMPLE_WIFI_SSID    "SSID"
#define EXAMPLE_WIFI_PASS    "SSID_PASSWORD"

#define WIFI_CONNECTED_BIT   BIT0
#define WIFI_FAIL_BIT        BIT1
#define EXAMPLE_MAX_RETRY    5

static EventGroupHandle_t s_wifi_event_group;
static int s_retry_num = 0;

static void event_handler(void *arg, esp_event_base_t event_base,
                           int32_t event_id, void *event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        if (s_retry_num < EXAMPLE_MAX_RETRY) {
            esp_wifi_connect();
            s_retry_num++;
            ESP_LOGI(TAG, "Retrying connection...");
        } else {
            xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
        }
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        s_retry_num = 0;
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
    }
}

void app_main(void)
{
    // Initialize NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    // System initialization
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    s_wifi_event_group = xEventGroupCreate();

    // Init Wi-Fi with default config
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    // Register event handlers
    esp_event_handler_instance_t instance_any_id;
    esp_event_handler_instance_t instance_got_ip;
    ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT,
                                                        ESP_EVENT_ANY_ID,
                                                        &event_handler,
                                                        NULL,
                                                        &instance_any_id));
    ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT,
                                                        IP_EVENT_STA_GOT_IP,
                                                        &event_handler,
                                                        NULL,
                                                        &instance_got_ip));

    // Configure station
    wifi_config_t wifi_config = {
        .sta = {
            .ssid = EXAMPLE_WIFI_SSID,
            .password = EXAMPLE_WIFI_PASS,
            .threshold.authmode = WIFI_AUTH_WPA2_PSK,
        },
    };
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
    ESP_ERROR_CHECK(esp_wifi_start());

    // Let the driver choose the band automatically: it scans both bands and
    // connects on the one with the strongest signal.
    // Must be called after esp_wifi_start(), otherwise it returns
    // ESP_ERR_WIFI_NOT_STARTED (0x3002).
    ESP_ERROR_CHECK(esp_wifi_set_band_mode(WIFI_BAND_MODE_AUTO));

    // Wait for connection or failure
    EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group,
                                           WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
                                           pdFALSE,
                                           pdFALSE,
                                           portMAX_DELAY);

    if (bits & WIFI_CONNECTED_BIT) {
        // Check which band was used
        wifi_band_t band;
        ESP_ERROR_CHECK(esp_wifi_get_band(&band));

        if (band == WIFI_BAND_5G) {
            ESP_LOGI(TAG, "Connected on 5 GHz!");
        } else {
            ESP_LOGI(TAG, "Connected on 2.4 GHz.");
        }

        // Also print the channel as a cross-check (5 GHz channels are 36+)
        wifi_ap_record_t ap_info;
        ESP_ERROR_CHECK(esp_wifi_sta_get_ap_info(&ap_info));
        ESP_LOGI(TAG, "Connected to SSID: %s, Channel: %d, RSSI: %d",
                 ap_info.ssid, ap_info.primary, ap_info.rssi);

    } else {
        ESP_LOGI(TAG, "Failed to connect.");
    }
}
```
</details>


### Next step
> Next step &rarr; [Lecture 2](../lecture-2/)

> Or [go back to navigation menu](.#agenda)
