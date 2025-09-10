---
title: "ESP-IDF Basics - Assign. 2.1"
date: "2025-08-05"
series: ["WS00A"]
series_order: 5
showAuthor: false
---



In this assignment, we will build up on the code from the last assignment. We will start a soft-AP and an HTTP server.


## Starting a soft-AP

To keep things as simple as possible, this tutorial will hard-code the access point (AP) credentials. As a result, we won't use Non-Volatile Storage (NVS), which is typically used in Wi-Fi applications to store credentials and calibration data.

NVS is enabled by default. To avoid warnings and errors, we have to disable it through `menuconfig`.

### Disable NVS

To disable NVS, we need to access the `menuconfig` and look for `NVS`

* `> ESP-IDF: SDK Configuration Editor (menuconfig)` &rarr; `NVS`

{{< figure
default=true
src="../assets/ass_2_1_disable_nvs.webp"
height=500
caption="NVS options to be disabled"
    >}}

### Define soft-AP parameters

The soft-AP parameters we need are
```c
#define ESP_WIFI_SSID "<YOURNAME_esp_test>"
#define ESP_WIFI_PASS "test_esp"
#define ESP_WIFI_CHANNEL 1
#define MAX_STA_CONN 2
```

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
 This is __not__ the recommended way to store credentials. Please store them securely in NVS or manage them through configuration settings using menuconfig. For this workshop, use a unique SSID value!
{{< /alert >}}

### Initialize IP stack and Event Loop

Espressif's Wi-Fi component relies on an [event loop](https://en.wikipedia.org/wiki/Event_loop) to handle asynchronous events. To start the soft-AP, we need to:

1. Include `esp_wifi.h` and `string.h`
1. Initialize the IP stack (via `esp_netif_init` and `esp_netif_create_default_wifi_ap`)
1. Start the [default event loop](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/esp_event.html#default-event-loop)
1. Create and register an event handler function to process Wi-Fi events.

To keep things clean, we'll encapsulate this code in the function `wifi_init_softap`

```c
#include "esp_wifi.h"
#include "string.h"

// ...

void wifi_init_softap()
{
    esp_netif_init();
    esp_event_loop_create_default();
    esp_netif_create_default_wifi_ap();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT(); // always start with this

    esp_wifi_init(&cfg);

    esp_event_handler_instance_register(WIFI_EVENT,
                                                        ESP_EVENT_ANY_ID,
                                                        &wifi_event_handler,
                                                        NULL,
                                                        NULL);

    wifi_config_t wifi_config = {
        .ap = {
            .ssid = ESP_WIFI_SSID,
            .ssid_len = strlen(ESP_WIFI_SSID),
            .channel = ESP_WIFI_CHANNEL,
            .password = ESP_WIFI_PASS,
            .max_connection = MAX_STA_CONN,
            .authmode = WIFI_AUTH_WPA2_PSK,
            .pmf_cfg = {
                .required = true,
            },
        },
    };


    esp_wifi_set_mode(WIFI_MODE_AP);
    esp_wifi_set_config(WIFI_IF_AP, &wifi_config);
    esp_wifi_start();

    ESP_LOGI(TAG, "wifi_init_softap finished. SSID:%s password:%s channel:%d",
             ESP_WIFI_SSID, ESP_WIFI_PASS, ESP_WIFI_CHANNEL);
}
```
### Register handlers for soft-AP

The function handling Wi-Fi events is as follows:

```c
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                                  int32_t event_id, void* event_data){
    printf("Event nr: %ld!\n", event_id);
}
```

Now compile, flash, start a monitor and run the project. We should start seeing several event numbers appearing on the terminal.

### Connect to the soft-AP with a Smartphone

Take your smartphone, open the Wi-Fi list, and select the SSID `esp_tutorial`.

{{< figure
    default=true
    src="../assets/ass_2_1_ap_list.webp"
    height=500
    caption="List of APs"
    >}}

In the terminal, you should now see `Event nr: 14!` which corresponds to `WIFI_EVENT_AP_STACONNECTED` (you can check the enum value on [GitHub](https://github.com/espressif/esp-idf/blob/c5865270b50529cd32353f588d8a917d89f3dba4/components/esp_wifi/include/esp_wifi_types_generic.h#L964) - remember that enumeration of values start from 0!)

This indicates that a station (i.e. your smartphone) has connected to the soft-AP (i.e. the Espressif module).

### Assignment Code: First part

Your code should resemble [this one](https://gist.github.com/FBEZ/3a81918239081bcaf48ba3684ceac412).

## Starting HTTP server

The HTTP server library provided by ESP-IDF is called `esp_http_server`. To use it, you’ll need to include the library and configure and start the server.

### Include the library

To use `esp_http_server` in your project, you’ll need to ensure that CMake recognizes it as a required component.

1. Include the HTTP server header:

   ```c
   #include "esp_http_server.h"
   ```

2. Add `esp_http_server` to your `CMakeLists.txt` under the `PRIV_REQUIRES` list. This tells the build system to include the necessary components.

Your `CMakeLists.txt` should look like this:

```cmake
idf_component_register(SRCS "blink_example_main.c"
                       PRIV_REQUIRES esp_wifi esp_http_server esp_driver_gpio
                       INCLUDE_DIRS ".")
```

### Configure the HTTP Server

We'll encapsulate the server setup in a dedicated function:

```c
httpd_handle_t start_webserver() {
    httpd_handle_t server = NULL;
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();

    if (httpd_start(&server, &config) == ESP_OK) {
        ESP_LOGI(TAG, "Server started successfully, registering URI handlers...");
        return server;
    }

    ESP_LOGE(TAG, "Failed to start server");
    return NULL;
}
```

After calling `httpd_start()`, the `server` handle is initialized and can be used to manage the HTTP server.

In your `app_main` function, you can now start the server calling:

```c
httpd_handle_t server = start_webserver();
```

### HTTP URI management

We'll return an HTML page when the user visits the `/` route.
To register a route, we call the function `httpd_register_uri_handler` after the `start_webserver` in `app_main`.

```c
httpd_register_uri_handler(server,&hello_world_uri);
```

The `httpd_uri_t` structure defines the properties of the URI being registered.
```c

static const httpd_uri_t hello_world_uri= {
    .uri       = "/",               // the address at which the resource can be found
    .method    = HTTP_GET,          // The HTTP method (HTTP_GET, HTTP_POST, ...)
    .handler   = hello_get_handler, // The function which process the request
    .user_ctx  = NULL               // Additional user data for context
};
```

The last piece we need is the request handler function

```c
static esp_err_t hello_get_handler(httpd_req_t *req)
{
    const char* resp_str = "<h1>Hello World</h1>";
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;

}
```
Note the HTML embedded in the response string.

#### Connect to the server

For Espressif devices, the default IP address of the Soft-AP is usually `192.168.4.1`.

You can verify this in the terminal output. Look for a log line like this:
```bash
I (766) esp_netif_lwip: DHCP server started on interface WIFI_AP_DEF with IP: 192.168.4.1
```

Open the web browser again on your connected device and enter the IP address in the address bar. As shown in Fig.3, you should now get the HTML page that we sent in the `hello_get_handler` function.

{{< figure
default=true
src="../assets/ass_2_1_result.webp"
height=100
caption="Fig. 3 – HTML page displayed"
 >}}

 ## Assignment Code

<details>
<summary>Show assignment code</summary>

```c
/* Blink Example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "led_strip.h"
#include "sdkconfig.h"
#include "esp_wifi.h"
#include "string.h"
#include "esp_http_server.h"

static const char *TAG = "example";


#define ESP_WIFI_SSID "esp_tutorial"
#define ESP_WIFI_PASS "test_esp"
#define ESP_WIFI_CHANNEL 1
#define MAX_STA_CONN 2


/* Use project configuration menu (idf.py menuconfig) to choose the GPIO to blink,
   or you can edit the following line and set a number here.
*/
#define BLINK_GPIO CONFIG_BLINK_GPIO

static uint8_t s_led_state = 0;

#ifdef CONFIG_BLINK_LED_STRIP

static led_strip_handle_t led_strip;

static void blink_led(void)
{
    /* If the addressable LED is enabled */
    if (s_led_state) {
        /* Set the LED pixel using RGB from 0 (0%) to 255 (100%) for each color */
        led_strip_set_pixel(led_strip, 0, 16, 16, 16);
        /* Refresh the strip to send data */
        led_strip_refresh(led_strip);
    } else {
        /* Set all LED off to clear all pixels */
        led_strip_clear(led_strip);
    }
}

static void configure_led(void)
{
    ESP_LOGI(TAG, "Example configured to blink addressable LED!");
    /* LED strip initialization with the GPIO and pixels number*/
    led_strip_config_t strip_config = {
        .strip_gpio_num = BLINK_GPIO,
        .max_leds = 1, // at least one LED on board
    };
#if CONFIG_BLINK_LED_STRIP_BACKEND_RMT
    led_strip_rmt_config_t rmt_config = {
        .resolution_hz = 10 * 1000 * 1000, // 10MHz
        .flags.with_dma = false,
    };
    ESP_ERROR_CHECK(led_strip_new_rmt_device(&strip_config, &rmt_config, &led_strip));
#elif CONFIG_BLINK_LED_STRIP_BACKEND_SPI
    led_strip_spi_config_t spi_config = {
        .spi_bus = SPI2_HOST,
        .flags.with_dma = true,
    };
    ESP_ERROR_CHECK(led_strip_new_spi_device(&strip_config, &spi_config, &led_strip));
#else
#error "unsupported LED strip backend"
#endif
    /* Set all LED off to clear all pixels */
    led_strip_clear(led_strip);
}

#elif CONFIG_BLINK_LED_GPIO

static void blink_led(void)
{
    /* Set the GPIO level according to the state (LOW or HIGH)*/
    gpio_set_level(BLINK_GPIO, s_led_state);
}

static void configure_led(void)
{
    ESP_LOGI(TAG, "Example configured to blink GPIO LED!");
    gpio_reset_pin(BLINK_GPIO);
    /* Set the GPIO as a push/pull output */
    gpio_set_direction(BLINK_GPIO, GPIO_MODE_OUTPUT);
}

#else
#error "unsupported LED type"
#endif

static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                                  int32_t event_id, void* event_data){
    printf("Event nr: %ld!\n", event_id);
}



void wifi_init_softap()
{
    esp_netif_init();
    esp_event_loop_create_default();
    esp_netif_create_default_wifi_ap();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT(); // always start with this

    esp_wifi_init(&cfg);

    esp_event_handler_instance_register(WIFI_EVENT,
                                                        ESP_EVENT_ANY_ID,
                                                        &wifi_event_handler,
                                                        NULL,
                                                        NULL);

    wifi_config_t wifi_config = {
        .ap = {
            .ssid = ESP_WIFI_SSID,
            .ssid_len = strlen(ESP_WIFI_SSID),
            .channel = ESP_WIFI_CHANNEL,
            .password = ESP_WIFI_PASS,
            .max_connection = MAX_STA_CONN,
            .authmode = WIFI_AUTH_WPA2_PSK,
            .pmf_cfg = {
                .required = true,
            },
        },
    };


    esp_wifi_set_mode(WIFI_MODE_AP);
    esp_wifi_set_config(WIFI_IF_AP, &wifi_config);
    esp_wifi_start();

    ESP_LOGI(TAG, "wifi_init_softap finished. SSID:%s password:%s channel:%d",
             ESP_WIFI_SSID, ESP_WIFI_PASS, ESP_WIFI_CHANNEL);
}

static esp_err_t hello_get_handler(httpd_req_t *req)
{
    const char* resp_str = "<h1>Hello World</h1>";
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;

}

static const httpd_uri_t hello_world_uri= {
    .uri       = "/",               // the address at which the resource can be found
    .method    = HTTP_GET,          // The HTTP method (HTTP_GET, HTTP_POST, ...)
    .handler   = hello_get_handler, // The function which process the request
    .user_ctx  = NULL               // Additional user data for context
};



httpd_handle_t start_webserver() {
    httpd_handle_t server = NULL;
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();

    if (httpd_start(&server, &config) == ESP_OK) {
        ESP_LOGI(TAG, "Server started successfully, registering URI handlers...");
        return server;
    }

    ESP_LOGE(TAG, "Failed to start server");
    return NULL;
}


void app_main(void)
{

    /* Configure the peripheral according to the LED type */
    configure_led();
    wifi_init_softap();
    httpd_handle_t server = start_webserver();
    httpd_register_uri_handler(server,&hello_world_uri);

    while (1) {
        ESP_LOGI(TAG, "Turning the LED %s!", s_led_state == true ? "ON" : "OFF");
        blink_led();
        /* Toggle the LED state */
        s_led_state = !s_led_state;
        vTaskDelay(CONFIG_BLINK_PERIOD / portTICK_PERIOD_MS);
    }
}

```

</details>

<!-- OLD ***************************-->
<!-- ---
* Follow [the developer portal article - Part 1](https://developer.espressif.com/blog/2025/04/soft-ap-tutorial/#create-a-new-project).
   * Start from [here](/blog/2025/04/soft-ap-tutorial/#create-a-new-project)
   * Skip the log discussion

Then you can create an HTTP server by following the second part of the article
* Follow [the developer portal article - Part 2](https://developer.espressif.com/blog/2025/04/soft-ap-tutorial/#create-a-new-project) -->

## Conclusion

Now you can put the Espressif device into Soft-AP or STA mode and create an HTTP server which can return both HTML based content of a JSON based response for a REST API.

### Next step

> Next assignment: [Assignment 2.2](../assignment-2-2/)
