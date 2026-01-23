---
title: "Workshop: ESP-IDF and ESP32-C6 - Assignment 3"
date: 2024-09-30T00:00:00+01:00
lastmod: 2026-01-20
showTableOfContents: false
series: ["WS001EN"]
series_order: 4
showAuthor: false
---

## Assignment 3: Connect to Wi-Fi

---

Now it's finally time to connect our ESP32-C6 to a Wi-Fi network. ESP32-C6 supports both Wi-Fi 4 and Wi-Fi 6 standards on the 2.4 GHz frequency.

[Wi-Fi connectivity](https://docs.espressif.com/projects/esp-idf/en/release-v5.5/esp32c6/api-reference/network/esp_wifi.html) is one of the most important features of most chips from the ESP32 family and is one of the essential components of their success. Thanks to Wi-Fi, it is possible to connect your IoT device to the internet and truly use all its features. This doesn't necessarily mean just connecting to cloud services, but also e.g. *over-the-air (OTA)* updates, remote control and monitoring and much more.

ESP32 supports two modes: *Station* and *SoftAP*:

* *Station mode*: ESP connects to an existing network (like a home router).
* *SoftAP mode*: Other devices (like laptop or mobile) connect directly to ESP, where e.g. a web server with control can run.

For this assignment, we will reuse the project we worked with in the previous assignment, specifically its second version using BSP, and connect to an existing Wi-Fi 4/Wi-Fi 6 network (so we will use *station mode*).

#### Connecting to Wi-Fi

To be able to start using Wi-Fi, we need to tell the framework that we will use Wi-Fi:
in the `main/CMakeLists.txt` file, specifically in the `idf_component_register` function, we add the following line:

```text
REQUIRES esp_wifi esp_netif esp_event nvs_flash
```

Now we need to set up the Wi-Fi driver: we need to specify **SSID** and **password**.

1. **Copy the skeleton**

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

static led_indicator_handle_t leds[1];

static EventGroupHandle_t s_wifi_event_group;
static int s_retry_num = 0;

static const char *TAG = "workshop";

// TODO handler

void wifi_init_sta(void)
{
    s_wifi_event_group = xEventGroupCreate();
   //TODO
}

void app_main(void)
{

    esp_err_t ret = nvs_flash_init();

    //TODO

    ESP_ERROR_CHECK(bsp_led_indicator_create(leds, NULL, BSP_LED_NUM));
    led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x20, 0x0, 0x0));

    wifi_init_sta();
}
```

2. **Wi-Fi initialization**

Wi-Fi initialization consists of these steps, which we will add to the `wifi_init_sta()` function:

- TCP/IP stack initialization:

```c
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();
```

- Creating default configuration for Wi-Fi initialization and the initialization itself:

```c
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));
```

- Registering *event handlers* for `WIFI_EVENT` and `IP_EVENT` events:

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

- Setting Wi-Fi mode to *station* using `WIFI_MODE_STA`:

```c
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
```

- Setting the connection parameters themselves using the `wifi_config_t` structure:

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

- Now we can call the `esp_wifi_set_config` function.

```c
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
```

- Now that both the Wi-Fi controller and the connection itself are set up, we can turn on Wi-Fi:

```c
    ESP_ERROR_CHECK(esp_wifi_start());
```

- Now we just need to wait for `WIFI_CONNECTED_BIT` or `WIFI_FAIL_BIT` and make sure everything worked:

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

3. **Creating Wi-Fi event handler**
 
This will not be part of either `app_main` or `wifi_init_sta`, but will be at the same level as these two functions. It must be located before `wifi_init_sta`, in place of the comment `//TODO event handler`:

```c
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
```

4. **NVS initialization check**

We will discuss NVS in the next assignment, so for now it will be a bit of a *blackbox*. We will add this code to `app_main`.

```c
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
      ESP_ERROR_CHECK(nvs_flash_erase());
      ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    ESP_ERROR_CHECK(bsp_led_indicator_create(leds, NULL, BSP_LED_NUM));
    ESP_LOGI(TAG, "LEDs initialized successfully");
    led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x0, 0x20));
```

5. **Wi-Fi initialization**

The last step is calling our function in `app_main`:

```c
wifi_init_sta();
```

Now you can build and upload your code.

The `ESP_LOGI` and `ESP_LOGE` functions output data to the serial line. After we upload the program to the development board, we can open communication with the board using the *Monitor* command in ESP-IDF Explorer or using *ESP-IDF: Monitor Device* via *Command Palette*.

#### Complete code

Below you can find the complete code for this assignment:

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

static led_indicator_handle_t leds[1];

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
    ESP_LOGI(TAG, "LEDs initialized successfully");
    led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x0, 0x0, 0x20));

    wifi_init_sta();
}
```

### Extra

1. If you want, you can try connecting to Wi-Fi at home using the [common_components/protocol_examples_common](https://github.com/espressif/esp-idf/tree/release/v5.2/examples/common_components/protocol_examples_common) component.

## Next step

Now that we have successfully connected to Wi-Fi, let's move on to working with memory!

[Assignment 4: NVS](../assignment-4)