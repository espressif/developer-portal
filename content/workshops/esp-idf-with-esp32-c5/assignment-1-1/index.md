---
title: "ESP-IDF C5 - Assign. 1.1"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 3
showAuthor: false
summary: "Write an application that connects the ESP32-C5 to a Wi-Fi network as a station, restricts the radio to the 5 GHz band, and reports the band and channel it joined."
---

In this assignment, you'll put the theory from [Lecture 1](../lecture-1/) into practice. You'll bring up the Wi-Fi driver in station mode, connect to an access point, restrict the radio to the 5 GHz band with `esp_wifi_set_band_mode()`, and then read back the band the connection landed on.

## Assignment steps

1. Prepare a 5 GHz network to connect to.
2. Create a new project and add the Wi-Fi includes.
3. Handle the Wi-Fi and IP events.
4. Initialize NVS, the network stack, and the Wi-Fi driver.
5. Configure the station and select the band mode.
6. Wait for the connection and report the band.
7. Build, flash, and monitor.

## Prepare a 5 GHz network to connect to

Before writing any code, you need a 5 GHz access point that the `ESP32-C5` can join. This is worth a moment of attention, because most networks make the 5 GHz band harder to reach than you might expect.

Many home routers broadcast the 2.4 GHz and 5 GHz radios under the __same SSID__ (a feature often called band steering or Smart Connect). When both bands share one name, a station only sees a single network. Because this assignment sets the band mode to `WIFI_BAND_MODE_5G_ONLY`, the board will only ever join the 5 GHz radio, so a shared SSID is fine as long as the access point actually broadcasts on 5 GHz. Here are the options to have a network that supports the 5 GHz band:

* __Split the SSIDs on your router.__ Log into your router's admin page and give the 5 GHz radio its own SSID (for example, `MyNetwork_5G`). Most routers expose this under the wireless settings, sometimes behind an "advanced" or "separate bands" toggle. You then connect the board to that dedicated 5 GHz SSID.

* __Use a phone hotspot set to 5 GHz.__ Many modern phones let you choose the hotspot band. On Android, open the hotspot settings and select the __5 GHz__ band (sometimes labeled "Maximize compatibility" for 2.4 GHz versus a 5 GHz option). This is the quickest way to get a known 5 GHz network for testing.

* __Use a second board as a 5 GHz SoftAP.__ The `ESP32-C5` can act as an access point on the 5 GHz band. If you have a spare board, you can start a SoftAP on a non-DFS channel such as 36, 40, 44, or 48 and connect your main board to it.

Whichever option you choose, note down the __SSID__ and __password__ of the 5 GHz network. You'll plug them into the code in the next steps.

## Create a new project and add the Wi-Fi includes

1. Create a new ESP-IDF project.
    {{< tabs group="config" >}}
    {{< tab label="ESP-IDF Extension for VSCode" >}}
    * Open VS Code
    * Run `> ESP-IDF: Create New Empty Project`
    * In the appeared dropdown menu, add the project name `testing-5G`
    * Select the location where the project folder will be created


    In the folder you selected, the following project files are now present:

      ```console
      .
      ├── CMakeLists.txt
      ├── README.md
      └──  main/
          ├── CMakeLists.txt
          └── main.c
      ```
    
    {{< /tab >}}

    {{< tab label="CLI" >}}

    ```terminal
        idf.py create-project "testing-5G"
    ```     
    {{< /tab >}}
    {{< /tabs >}}

2. In your main source file, add the includes for logging, NVS, the network interface, the event loop, and the Wi-Fi and FreeRTOS APIs. Then define a `TAG` for logging, your network credentials, and a few constants used later:

   ```c
   #include <stdio.h>
   #include "esp_log.h"
   #include "nvs_flash.h"
   #include "esp_netif.h"
   #include "esp_event.h"
   #include "esp_wifi.h"
   #include "freertos/FreeRTOS.h"
   #include "freertos/event_groups.h"

   #define TAG                  "wifi_5g_example"
   #define EXAMPLE_WIFI_SSID    "EXAMPLE_WIFI_SSID"
   #define EXAMPLE_WIFI_PASS    "EXAMPLE_WIFI_PASS"

   #define WIFI_CONNECTED_BIT   BIT0
   #define WIFI_FAIL_BIT        BIT1
   #define EXAMPLE_MAX_RETRY    5
   ```

   Replace `EXAMPLE_WIFI_SSID` and `EXAMPLE_WIFI_PASS` with the SSID and password of the 5 GHz network you prepared in the previous step.

3. Declare the two shared objects the event handler needs: an event group to signal the outcome of the connection, and a retry counter:

   ```c
   static EventGroupHandle_t s_wifi_event_group;
   static int s_retry_num = 0;
   ```

   The event group lets the Wi-Fi events, which run in a background task, tell `app_main()` when the connection has either succeeded or definitively failed.

## Handle the Wi-Fi and IP events

The Wi-Fi driver reports what it is doing through events. You register a single handler and react to the three events that matter for a station connection.

1. Add the event handler above `app_main()`:

   ```c
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
   ```

   The handler does three things:
   * On `WIFI_EVENT_STA_START`, it kicks off the connection with `esp_wifi_connect()`.
   * On `WIFI_EVENT_STA_DISCONNECTED`, it retries up to `EXAMPLE_MAX_RETRY` times, then sets `WIFI_FAIL_BIT` to give up.
   * On `IP_EVENT_STA_GOT_IP`, the board has an IP address, so it resets the retry counter and sets `WIFI_CONNECTED_BIT`.

## Initialize NVS, the network stack, and the Wi-Fi driver

Now start `app_main()` and bring up everything the Wi-Fi driver depends on.

1. Initialize NVS. The Wi-Fi driver stores calibration data and configuration there, so it must be ready first:

   ```c
   void app_main(void)
   {
       // Initialize NVS
       esp_err_t ret = nvs_flash_init();
       if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
           ESP_ERROR_CHECK(nvs_flash_erase());
           ret = nvs_flash_init();
       }
       ESP_ERROR_CHECK(ret);
   ```

2. Initialize the TCP/IP stack, create the default event loop, and create the default station network interface:

   ```c
       // System initialization
       ESP_ERROR_CHECK(esp_netif_init());
       ESP_ERROR_CHECK(esp_event_loop_create_default());
       esp_netif_create_default_wifi_sta();

       s_wifi_event_group = xEventGroupCreate();
   ```

3. Initialize the Wi-Fi driver with the default configuration and register the event handler for both the Wi-Fi and IP event families:

   ```c
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
   ```

## Configure the station and select the band mode

With the driver initialized, configure the station credentials, start Wi-Fi, and then enable dual-band scanning.

1. Fill in the station configuration with your SSID, password, and the minimum authentication mode to accept:

   ```c
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
   ```

2. Set the band mode to `WIFI_BAND_MODE_5G_ONLY` so the driver restricts the radio to the 5 GHz band and only connects to 5 GHz access points:

   ```c
       // Restrict Wi-Fi to the 5 GHz band only.
       // Must be called after esp_wifi_start(), otherwise it returns
       // ESP_ERR_WIFI_NOT_STARTED (0x3002).
       ESP_ERROR_CHECK(esp_wifi_set_band_mode(WIFI_BAND_MODE_5G_ONLY));
   ```

   > [!IMPORTANT]
   > `esp_wifi_set_band_mode()` must be called __after__ `esp_wifi_start()`. If you call it earlier, it returns `ESP_ERR_WIFI_NOT_STARTED` (`0x3002`) and `ESP_ERROR_CHECK` will abort the program.

   > [!TIP]
   > Here you force the board onto 5 GHz with `WIFI_BAND_MODE_5G_ONLY`. If you would rather let the board fall back to 2.4 GHz when 5 GHz is unavailable, use `WIFI_BAND_MODE_AUTO` instead, which scans both bands and picks the strongest match. In `AUTO` mode you can bias the choice toward 5 GHz using the `rssi_5g_adjustment` field of the scan threshold.

## Wait for the connection and report the band

Finally, block until the event handler signals success or failure, then read back which band the board actually joined.

1. Wait on the event group for either the connected bit or the fail bit:

   ```c
       // Wait for connection or failure
       EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group,
                                              WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
                                              pdFALSE,
                                              pdFALSE,
                                              portMAX_DELAY);
   ```

2. If the connection succeeded, confirm the active band with `esp_wifi_get_band()` and cross-check it against the channel reported by `esp_wifi_sta_get_ap_info()`. With `WIFI_BAND_MODE_5G_ONLY` the band should always be 5 GHz, and the use of channels 36 and above confirms it:

   ```c
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
   ```

## Build, flash, and monitor

1. Build and flash the project: 
    {{< tabs group="config" >}}
    {{< tab label="ESP-IDF Extension for VSCode" >}}
    `> ESP-IDF: Build, Flash and Start a Monitor on your Device`.
    
    {{< /tab >}}

    {{< tab label="CLI" >}}

    ```terminal
        idf.py -p PORT flash monitor
    ```     

    Where `PORT` is the port on which your device is connected. The name depend on your OS (usually, Windows -- "COM", Linux -- "ttyusb", macOS -- "tty.usbserial").
    {{< /tab >}}
    {{< /tabs >}}

2. Watch the monitor output. When the board joins a 5 GHz network, you should see something like:

   ```
   I (1234) wifi_5g_example: Connected on 5 GHz!
   I (1244) wifi_5g_example: Connected to SSID: TestHotspot, Channel: 36, RSSI: -42
   ```

   The band line confirms the radio, and the channel (36 in this example) is a second, independent confirmation that the connection is on the 5 GHz band.


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

#define TAG                  "wifi_5g_example"
#define EXAMPLE_WIFI_SSID    "EXAMPLE_SSID"
#define EXAMPLE_WIFI_PASS    "EXAMPLE_PASSWORD"

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

    // Force 5 GHz only: the station will scan and connect on 5 GHz channels exclusively.
    // Must be called after esp_wifi_start(), otherwise it returns
    // ESP_ERR_WIFI_NOT_STARTED (0x3002).
    ESP_ERROR_CHECK(esp_wifi_set_band_mode(WIFI_BAND_MODE_5G_ONLY));

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

## Conclusion

You built a complete Wi-Fi station that connects the `ESP32-C5` to a network, restricts the radio to the 5 GHz band through `esp_wifi_set_band_mode()`, and reports back the band and channel it joined. Along the way you saw why a 5 GHz-capable access point is needed, and how `WIFI_BAND_MODE_5G_ONLY` guarantees the board stays on the 5 GHz band.

In the next assignment, you'll build on this Wi-Fi connection and explore the dual-band configuration further.

### Next step
> Next assignment &rarr; [Assignment 1.2](../assignment-1-2/)

> Or [go back to navigation menu](.#agenda)
