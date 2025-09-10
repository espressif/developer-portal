---
title: "ESP-IDF Basics - Assign. 2.2"
date: "2025-08-05"
series: ["WS00A"]
series_order: 6
showAuthor: false
---

The second assignment is to add the following routes to the HTTP server that we created in the previous assignment:


- `GET /led/on` &rarr; turns the LED on and returns JSON {"led": "on"}
- `GET /led/off`&rarr; turns the LED off and returns JSON {"led": "off"}
- `POST /led/blink` &rarr; accepts JSON `{ "times": int, "interval_ms": int }` to blink the LED the specified number of times at the given interval, and returns JSON `{"blink": "done"}`


## Assignment Code

<details>
<summary>Show assignment code</summary>

```c
#include <stdint.h>
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

// Define an unique SSID
#define ESP_WIFI_SSID "esp_tutorial"
// Define a password for the WiFi network
#define ESP_WIFI_PASS "test_esp"
#define ESP_WIFI_CHANNEL 1
#define MAX_STA_CONN 2

#define BLINK_GPIO GPIO_NUM_7 // GPIO pin for the LED

static const char *TAG = "assingment";


static uint8_t s_led_state = 0;

static void led_control(uint8_t s_led_state)
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

static esp_err_t led_on_handler(httpd_req_t *req)
{
    led_control(1);

    const char* resp_str = "{\"led\": \"on\"}";
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;
}

static esp_err_t led_off_handler(httpd_req_t *req)
{
    led_control(0);

    const char* resp_str = "{\"led\": \"off\"}";
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;
}

static esp_err_t led_blink_handler(httpd_req_t *req)
{
    char buf[100];
    int ret = httpd_req_recv(req, buf, sizeof(buf));
    if (ret <= 0) {
        httpd_resp_send_500(req);
        return ESP_FAIL;
    }

    buf[ret] = '\0';

    int times = 0, interval = 0;
    sscanf(buf, "{\"times\": %d, \"interval_ms\": %d}", &times, &interval);

    // add logging for debugging
    ESP_LOGI(TAG, "Blinking LED %d times with interval %d ms", times, interval);

    for (int i = 0; i < times; i++) {
        s_led_state = 1;
        led_control(s_led_state);
        vTaskDelay(interval / portTICK_PERIOD_MS);
        s_led_state = 0;
        led_control(s_led_state);
        vTaskDelay(interval / portTICK_PERIOD_MS);
    }

    const char* resp_str = "{\"blink\": \"done\"}";
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;
}

static const httpd_uri_t led_on_uri = {
    .uri       = "/led/on",
    .method    = HTTP_GET,
    .handler   = led_on_handler,
    .user_ctx  = NULL
};

static const httpd_uri_t led_off_uri = {
    .uri       = "/led/off",
    .method    = HTTP_GET,
    .handler   = led_off_handler,
    .user_ctx  = NULL
};

static const httpd_uri_t led_blink_uri = {
    .uri       = "/led/blink",
    .method    = HTTP_POST,
    .handler   = led_blink_handler,
    .user_ctx  = NULL
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
    httpd_register_uri_handler(server, &hello_world_uri);
    httpd_register_uri_handler(server, &led_on_uri);
    httpd_register_uri_handler(server, &led_off_uri);
    httpd_register_uri_handler(server, &led_blink_uri);

}
```
<details>
### Conclusion

Now we have a clear picture of how to connect REST API requests to physical device control. You will work on a more complex application in the last assignment 3.3.

### Next step

If you still have time, you can try this optional assignment.

> Next (optional) assignment &rarr; [Assignment 2.3](../assignment-2-3/)

Otherwise, you can move to the third lecture.

> Next lecture &rarr; [Lecture 3](../lecture-3/)
