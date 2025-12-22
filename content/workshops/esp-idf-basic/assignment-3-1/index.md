---
title: "ESP-IDF Basics - Assign. 3.1"
date: "2025-08-05"
lastmod: "2026-01-20"
series: ["WS00A"]
series_order: 9
showAuthor: false
summary: "Create a led-toggle component and refactor the hello_led example using the component"
---

This assignment has two tasks:


1. Create a `led-toggle` component
2. Refactor the `hello_led` example using the created component

## `led-toggle` component

The first task is to create a `led-toggle` component.

### Create a new component

1. Open your project `hello_led` in VS Code
2. Create a new component: `> ESP-IDF: Create New ESP-IDF Component`
3. Type `led_toggle` in the text field appearing on top (see Fig.1)

{{< figure
default=true
src="../assets/ass3-1-new-component.webp"
caption="Fig.1 - Create new component"
    >}}

The project will now contain the folder `components` and all the required files:
```bash
.
└── hello_led/
    ├── components/
    │   └── led_toggle/
    │       ├── include/
    │       │   └── led_toggle.h
    │       ├── CMakeList.txt
    │       └── led_toggle.c
    ├── main
    └── build
```

### Create the toggle function

Add the following code to the component header and source files (depending on your evk) and implement the toggle function.

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
`esp_err` is an enum (hence an int) used to return error codes. You can check its values [in the documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/error-codes.html).
This enum is used also with logging and macros like `ESP_ERR_CHECK`, which you will find almost all esp-idf examples.
{{< /alert >}}

#### LED GPIO Version

_`led_toggle.h`_
```c
#include "driver/gpio.h"

typedef struct {
    int gpio_nr;
    bool status;
}led_gpio_t;

esp_err_t led_config(led_gpio_t * led_gpio);
esp_err_t led_drive(led_gpio_t * led_gpio);
esp_err_t led_toggle(led_gpio_t * led_gpio);
```

_`led_toggle.c`_

```c
esp_err_t led_config(led_gpio_t * led_gpio){

    gpio_config_t io_conf = {};
    io_conf.intr_type = GPIO_INTR_DISABLE;
    io_conf.mode = GPIO_MODE_OUTPUT;
    io_conf.pin_bit_mask =  (1ULL<<led_gpio->gpio_nr);
    io_conf.pull_down_en = 0;
    io_conf.pull_up_en = 0;
    return gpio_config(&io_conf);
}

esp_err_t led_drive(led_gpio_t * led_gpio){
    return gpio_set_level(led_gpio->gpio_nr, led_gpio->status); // turns led on
}

esp_err_t led_toggle(led_gpio_t * led_gpio){
    //TBD
    return 0;
}
```

#### LED RGB Version


_`led_toggle.h`_

```c
#include "led_strip.h"

typedef struct {
    int gpio_nr;
    bool status;
    led_strip_handle_t led_strip;
}led_handle_t;

esp_err_t led_config(led_handle_t * leg_rgb);
esp_err_t led_drive(led_handle_t * leg_rgb, bool level);
esp_err_t led_toggle(led_handle_t * leg_rgb);
```

_`led_toggle.c`_

```c
#include <stdio.h>
#include "led_toggle.h"
#include "esp_err.h"

esp_err_t led_config(led_handle_t * led_handle)
{

    led_strip_config_t strip_config = {
        .strip_gpio_num = led_handle->gpio_nr,
        .max_leds = 1, // at least one LED on board
    };

    led_strip_rmt_config_t rmt_config = {
        .resolution_hz = 10 * 1000 * 1000, // 10MHz
        .flags.with_dma = false,
    };
    esp_err_t ret = led_strip_new_rmt_device(&strip_config, &rmt_config, &led_handle->led_strip);
    led_strip_clear(led_handle->led_strip);
    return ret;
}

esp_err_t led_drive(led_handle_t * led_handle, bool level){
    if(level){
        esp_err_t ret = led_strip_set_pixel(led_handle->led_strip, 0, 16, 16, 16);
        led_strip_refresh(led_handle->led_strip);
        led_handle->status = true;
        return ret;
    }else{
        led_handle->status= false;
        return led_strip_clear(led_handle->led_strip);
    }
}


esp_err_t led_toggle(led_handle_t * led_handle){
    //TBD
    return 0;
}
```



### Test the component

* Now, in `app_main`, include the appropriate header
* Configure the peripheral (using the `config_led` function)
* Test that everything works correctly through the `drive_led` function




## Refactor the `hello_led` code

Now you are ready to:

1. Implement the `toggle_led` function
2. Refactor the `hello_led` code to use the newly created component.


## Assignment solution

<details>
<summary>Assignment code</summary>

```c
#include <stdio.h>
#define ESP_WIFI_SSID "TEST_WORKSHOP"
#define ESP_WIFI_PASS "test_esp"
#define ESP_WIFI_CHANNEL 1
#define MAX_STA_CONN 2
#include "esp_wifi.h"
#include "string.h"
#include "esp_log.h"
#include "esp_http_server.h"
#include "led_toggle.h"

#define OUTPUT_LED 8

static const char* TAG = "main";

led_handle_t my_led = {
    .gpio_nr = OUTPUT_LED,
    .status = false,
    .led_strip = false
};

static esp_err_t hello_get_handler(httpd_req_t *req)
{
    const char* resp_str = "<h1>Hello World</h1>";
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;
}

/* Handler definitions */

static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                                  int32_t event_id, void* event_data){
    printf("Evento n°: %ld!\n", event_id);
}


static esp_err_t led_on_handler(httpd_req_t *req)
{
    ESP_ERROR_CHECK(led_drive(&my_led,true));

    const char* resp_str = "{\"led\": \"on\"}";
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;
}

static esp_err_t led_off_handler(httpd_req_t *req)
{
    led_drive(&my_led,false);

    const char* resp_str = "{\"led\": \"off\"}";
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;
}


static esp_err_t led_toggle_handler(httpd_req_t *req)
{
    led_toggle(&my_led);

    const char* resp_str = "{\"led\": \"toggled\"}";
    httpd_resp_set_type(req, "application/json");
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;
}

/* URI definitions */

static const httpd_uri_t hello_world_uri= {
    .uri       = "/",
    .method    = HTTP_GET,
    .handler   = hello_get_handler,
    .user_ctx  = NULL
};

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

static const httpd_uri_t led_toggle_uri = {
    .uri       = "/led/toggle",
    .method    = HTTP_GET,
    .handler   = led_toggle_handler,
    .user_ctx  = NULL
};

void wifi_init_softap(){
    esp_netif_init();
    esp_event_loop_create_default();
    esp_netif_create_default_wifi_ap();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT(); // sempre iniziare da qui

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

    ESP_LOGI(TAG, "wifi_init_softap completata. SSID:%s password:%s canale:%d",
             ESP_WIFI_SSID, ESP_WIFI_PASS, ESP_WIFI_CHANNEL);
}

httpd_handle_t start_webserver() {
    httpd_handle_t server = NULL;
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();

    if (httpd_start(&server, &config) == ESP_OK) {
        ESP_LOGI(TAG, "Server avviato con successo, registrazione degli handler URI...");
        return server;
    }

    ESP_LOGE(TAG, "Impossibile avviare il server");
    return NULL;
}


void app_main(void)
{
    wifi_init_softap();
    led_config(&my_led);
    httpd_handle_t server = start_webserver();
    /* Registrazione URI/Handler */
    httpd_register_uri_handler(server,&hello_world_uri);
    httpd_register_uri_handler(server, &led_on_uri);
    httpd_register_uri_handler(server, &led_off_uri);
    httpd_register_uri_handler(server, &led_toggle_uri);
}
```

</details>

## Conclusion

You can now create your own components, which makes your code easier to maintain and to share. In the next assignment, you will face a typical development problem and use the skills you just learned.

### Next step
> Next assignment &rarr; [Assignment 3.2](../assignment-3-2/)

> Or [go back to navigation menu](../#agenda)
