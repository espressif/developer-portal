---
title: "ESP-IDF with ESP32-C6 Workshop - Assignment 3: Connect to Wi-Fi"
date: 2024-06-28T00:00:00+01:00
showTableOfContents: false
series: ["WS001"]
series_order: 4
showAuthor: false
---

## Assignment 3: Connect to Wi-Fi

---

Now it's time to connect the ESP32-C6 to a Wi-Fi network. The ESP32-C6 supports both Wi-Fi4 and Wi-Fi 6 on 2.4 GHz.

[Wi-Fi connectivity](https://docs.espressif.com/projects/esp-idf/en/release-v5.2/esp32c6/api-reference/network/esp_wifi.html) is one of the most desired features for most of the smart and IoT devices. With Wi-Fi, you can connect the device to the Internet and perform many operations, such as over-the-air (OTA) updates, cloud connectivity, remote monitoring, and so on.

The ESP32 supports both Station and SoftAP modes.

{{< alert icon="circle-info">}}
For this assignment, we will set up the station mode Wi-Fi driver and connect to a Wi-Fi 4 / Wi-Fi 6 network, using the same project as used in the assignment [Create a project with Components](../assignment-2/) where a BSP was used.
{{< /alert >}}

#### Hands-on Wi-Fi

To get started with Wi-Fi, we need to set up the Wi-Fi driver in order to connect to a Wi-Fi network, using the access credentials (SSID and password).

  1. **Add all the necessary includes.**

  2. **Initialize Wi-Fi**

To initialize the Wi-Fi driver, we need to perform the following steps:

- Initialize the TCP/IP stack:

```c
    esp_netif_init();
    esp_event_loop_create_default();
    esp_netif_create_default_wifi_sta();
```

- Initialize and allocate the resources for the Wi-Fi driver:

```c
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    esp_wifi_init(&cfg);
```

- Registry the event handler for `WIFI_EVENT` and `IP_EVENT`:

```c
    esp_event_handler_instance_t instance_any_id;
    esp_event_handler_instance_t instance_got_ip;
    esp_event_handler_instance_register(WIFI_EVENT,
            ESP_EVENT_ANY_ID,
            &event_handler,
            NULL,
            &instance_any_id);
    esp_event_handler_instance_register(IP_EVENT,
            IP_EVENT_STA_GOT_IP,
            &event_handler,
            NULL,
            &instance_got_ip);
```

- Set the Wi-Fi mode as Station using `WIFI_MODE_STA`:

```c
    esp_wifi_set_mode(WIFI_MODE_STA);
```

- Set the Wi-Fi configuration:

Using the struct `wifi_config_t`, set up Wi-Fi as `sta`:

```c
    wifi_config_t wifi_config = {
        .sta = {
            // Set the newtork name
            .ssid = WIFI_SSID,
            // Set the network pass key
            .password = WIFI_PASS,
            // Set WPA as the authentication mode
            .threshold.authmode = WIFI_AUTH_WPA_PSK,
            // Set Simultaneous Authentication (SAE) and Password Element (PWE) derivation method
            .sae_pwe_h2e = WPA3_SAE_PWE_BOTH,
            // Set the password identifier for H2E (Hash-to-Element)
            .sae_h2e_identifier = "",
        },
    };
```

Then, set up the network **ssid** and **password** as:

```c
#define WIFI_SSID "network-ssid"
#define WIFI_PASS "network-pass"
```

- Now you can call the `esp_wifi_set_config` function.

```c
    esp_wifi_set_config(WIFI_IF_STA, &wifi_config);
```

- Start Wi-Fi on selected mode with the configuration defined:

```c
    esp_wifi_start();
```

- Finally, wait for `WIFI_CONNECTED_BIT` or `WIFI_FAIL_BIT`.

```c
    EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group,
            WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
            pdFALSE,
            pdFALSE,
            portMAX_DELAY);

    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "Connected!");
    } else if (bits & WIFI_FAIL_BIT) {
        ESP_LOGE(TAG, "Failed to connect!");
    }
```

This is not mandatory, however it is useful.

3. **Create the Wi-Fi event handler**

```c
static void event_handler(void* arg, esp_event_base_t event_base,
                                int32_t event_id, void* event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        if (s_retry_num < 10) {
            esp_wifi_connect();
            s_retry_num++;
            ESP_LOGW(TAG, "Trying to connect to WiFi");
        } else {
            xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
        }
        ESP_LOGE(TAG, "Failed to connect to WiFi");
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "got ip:" IPSTR, IP2STR(&event->ip_info.ip));
        s_retry_num = 0;
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
    }
}
```

4. **Check the NVS initialization**

```c
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
      ESP_ERROR_CHECK(nvs_flash_erase());
      ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);
```

5. **Init Wi-Fi**

```c
wifi_init_sta();
```

#### Troubleshooting

If you have issues with the `esp_wifi.h` not being found, please add to the `main/CMakeLists.txt`:

```txt
REQUIRES esp_wifi esp_netif esp_event nvs_flash
```

#### Assignment Code

Here you can find the full code for this assignment:

```c
#include <stdio.h>
#include "bsp/esp-bsp.h"
#include "led_indicator_blink_default.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "lwip/err.h"
#include "lwip/sys.h"

#define WIFI_SSID "network-ssid"
#define WIFI_PASS "network-pass"

#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT      BIT1

static led_indicator_handle_t leds[BSP_LED_NUM];

static EventGroupHandle_t s_wifi_event_group;
static int s_retry_num = 0;

static const char *TAG = "workshop";

static void event_handler(void* arg, esp_event_base_t event_base,
                                int32_t event_id, void* event_data)
{
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_START) {
        esp_wifi_connect();
    } else if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_STA_DISCONNECTED) {
        if (s_retry_num < 30) {
            esp_wifi_connect();
            s_retry_num++;
            ESP_LOGW(TAG, "Trying to connect to WiFi");
			led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x0, 0x20));
        } else {
            xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
        }
        ESP_LOGE(TAG, "Failed to connect to WiFi");
		led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x20, 0x0, 0x0));
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t* event = (ip_event_got_ip_t*) event_data;
        ESP_LOGI(TAG, "got ip:" IPSTR, IP2STR(&event->ip_info.ip));
		led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x20, 0x0));
        s_retry_num = 0;
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
    }
}

void wifi_init_sta(void)
{
    s_wifi_event_group = xEventGroupCreate();

    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

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

    wifi_config_t wifi_config = {
        .sta = {
            .ssid = WIFI_SSID,
            .password = WIFI_PASS,
            .threshold.authmode = WIFI_AUTH_WPA_PSK,
            .sae_pwe_h2e = WPA3_SAE_PWE_BOTH,
            .sae_h2e_identifier = "",
        },
    };

    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA) );
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config) );
    ESP_ERROR_CHECK(esp_wifi_start() );

    EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group,
            WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
            pdFALSE,
            pdFALSE,
            portMAX_DELAY);

    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "Connected!");
    } else if (bits & WIFI_FAIL_BIT) {
        ESP_LOGE(TAG, "Failed to connect!");
    }
}

void app_main(void)
{

    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
      ESP_ERROR_CHECK(nvs_flash_erase());
      ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    ESP_ERROR_CHECK(bsp_led_indicator_create(leds, NULL, BSP_LED_NUM));
    led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x0, 0x20));

    wifi_init_sta();
}
```

### Extra

1. Change your code to use the [common_components/protocol_examples_common](https://github.com/espressif/esp-idf/tree/release/v5.2/examples/common_components/protocol_examples_common) component to handle the Wi-Fi connection.


## Next step

Connected! Let's now move on to the memory side!

[Assignment 4: Try using NVS](../assignment-4)
