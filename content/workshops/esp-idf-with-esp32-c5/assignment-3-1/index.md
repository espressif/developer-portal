---
title: "ESP-IDF C5 - Assign. 3.1"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 9
showAuthor: false
summary: "Configure the partition table for OTA, then write an application that connects to Wi-Fi and performs a single OTA update by downloading new firmware from a fixed HTTPS URL with esp_https_ota."
---

In this assignment, you'll put the theory from [Lecture 3](../lecture-3/) into practice. You'll switch to a partition table that supports OTA, then write an application that connects to Wi-Fi and downloads a new firmware image over HTTPS using the `esp_https_ota` component.

The OTA firmware location is at the following link.
```terminal
https://raw.githubusercontent.com/espressif/developer-portal-codebase/update-workshop-to-c5-code/content/workshops/esp-idf-with-esp32-c5/ota/ota-new-firmware.bin
```
Its only job is to log a message confirming the update worked.

## Assignment steps

1. Create a new project and set up the partition table for OTA.
2. Add the includes.
3. Connect to Wi-Fi.
4. Perform the OTA update.
5. Put it all together in `app_main()`.
6. Build, flash, and monitor.

## Create a new project and set up the partition table for OTA

1. Create a new ESP-IDF project

   OTA needs at least two app partitions: one to boot from and one to receive the new firmware, so you need to change it next.

2. Open `menuconfig` (`> ESP-IDF: SDK Configuration Editor (menuconfig)`) and go to `Partition Table` &rarr; `Factory app, two OTA definitions`.

   This replaces the single `factory` app partition with two OTA app partitions (`ota_0` and `ota_1`) and adds the `otadata` partition used to track which one is active.

3. In the same `menuconfig` window, go to `Serial Flasher Config` &rarr; `Flash Size` &rarr; `4MB`.


4. Save the configuration and close `menuconfig`.

## Add the includes

1. In your main source file, add the includes for FreeRTOS, the event group, the network stack, Wi-Fi, HTTPS OTA, and NVS. Then define a `TAG` for logging, your network credentials, and the firmware URL:

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

   #define WIFI_SSID     "EXAMPLE_WIFI_SSID"
   #define WIFI_PASSWORD "EXAMPLE_WIFI_PASS"

   #define FIRMWARE_URL "https://raw.githubusercontent.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-idf-with-esp32-c5/ota/ota-new-firmware.bin"

   static const char *TAG = "ota_example";
   ```

   Replace `EXAMPLE_WIFI_SSID` and `EXAMPLE_WIFI_PASS` with the credentials of the Wi-Fi network your board should join.

## Connect to Wi-Fi

The OTA download needs a working Wi-Fi connection first, so bring up the station and wait until it gets an IP address.

1. Declare an event group and a bit to signal a successful connection, above `app_main()`:

   ```c
   static EventGroupHandle_t s_wifi_event_group;
   #define WIFI_CONNECTED_BIT BIT0
   ```

2. Add the Wi-Fi event handler. It reconnects on start and on disconnect, and sets the event bit once the station gets an IP address:

   ```c
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
   ```

3. Add a `wifi_connect()` helper that initializes the network stack and the Wi-Fi driver, registers the handler above, then starts the station and blocks until it connects:

   ```c
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
   ```

   `xEventGroupWaitBits()` blocks `app_main()` until `WIFI_CONNECTED_BIT` is set, so the OTA download only starts once the board actually has an IP address.

## Perform the OTA update

With Wi-Fi connected, download the new firmware and let `esp_https_ota` write it to the inactive OTA partition.

1. Add a `do_firmware_update()` helper:

   ```c
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
   ```

   A few things worth noting:

   * `crt_bundle_attach = esp_crt_bundle_attach` validates the server's TLS certificate against the certificate bundle built into ESP-IDF. Since `FIRMWARE_URL` uses `https://`, this is what lets the HTTPS connection be verified without you supplying a certificate yourself.
   * `esp_https_ota()` does the entire download and write in one call: it opens the HTTP connection, streams the image into the inactive OTA partition, and validates it as it goes.
   * On success, the new image is marked as the one to boot next. The application waits briefly to let the log flush, then calls `esp_restart()` to boot into it.

   {{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
   `esp_crt_bundle_attach` relies on `CONFIG_MBEDTLS_CERTIFICATE_BUNDLE`, which is enabled by default in ESP-IDF, so no extra `menuconfig` step is needed for it.
   {{< /alert >}}

## Put it all together in app_main()

1. Write `app_main()` so it initializes NVS, connects to Wi-Fi, and then performs the update:

   ```c
   void app_main(void)
   {
       ESP_ERROR_CHECK(nvs_flash_init());
       wifi_connect();
       do_firmware_update();
   }
   ```

   NVS is initialized first because the Wi-Fi driver stores calibration data there.

## Build, flash, and monitor

1. Build and flash the project: `> ESP-IDF: Build, Flash and Start a Monitor on your Device`.

2. Watch the monitor output. The board connects to Wi-Fi, downloads the firmware, and reboots:

   ```
   I (612) ota_example: Connecting to SSID: EXAMPLE_WIFI_SSID
   I (2145) ota_example: Got IP: 192.168.1.42
   I (2148) ota_example: Starting OTA update from https://raw.githubusercontent.com/...
   I (3820) esp_https_ota: Starting OTA...
   I (4560) esp_https_ota: esp_https_ota_perform returned ESP_OK
   I (4560) ota_example: OTA update successful, rebooting...
   ```

3. After the reboot, the board runs the new firmware, which confirms the download worked and then returns from `app_main()`:

   ```
   OTA firmware v2.0 downloaded!

   I (284) main_task: Returned from app_main()
   ```

   Seeing this message from a brand new binary is the confirmation that the OTA update replaced your original application: the code now running is the one you just downloaded, not the one you flashed over the wire.


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

#define WIFI_SSID     "SSID"
#define WIFI_PASSWORD "PASSWORD"

#define FIRMWARE_URL "https://raw.githubusercontent.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-idf-with-esp32-c5/ota/ota-new-firmware.bin"
#define FIRMWARE_VERSION_URL "https://raw.githubusercontent.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-idf-with-esp32-c5/ota/version"

#define CURRENT_FIRMWARE_VERSION "1.0.0"

static const char *TAG = "ota_version_example";

static EventGroupHandle_t s_wifi_event_group;
#define WIFI_CONNECTED_BIT BIT0

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


void app_main(void)
{
    ESP_ERROR_CHECK(nvs_flash_init());
    wifi_connect();
    do_firmware_update();

}
```

</details>


## Conclusion

In this assignment, you switched to a partition table with two OTA app partitions, then wrote an application that connects to Wi-Fi and updates itself over HTTPS with a single call to `esp_https_ota()`. The new firmware took over after a reboot, proving the update worked end to end.

In the next assignment, you'll extend this OTA workflow further.

### Next step
> Next assignment &rarr; [Assignment 3.2](../assignment-3-2/)

> Or [go back to navigation menu](.#agenda)
