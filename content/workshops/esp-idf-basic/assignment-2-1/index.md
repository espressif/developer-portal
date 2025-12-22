---
title: "ESP-IDF Basics - Assign. 2.1"
date: "2025-08-05"
lastmod: "2026-01-20"
series: ["WS00A"]
series_order: 5
showAuthor: false
summary: "Start a soft-AP and an HTTP server (guided)"
---

## Assignment Steps

1. Create a new project from a template
2. Start a soft-AP
3. Start an HTTP server

## Create a new project from a template

In the previous exercises, we created a project based on an example. This time, we will create a project from an empty template instead.

* Open VS Code
* Run `> ESP-IDF: Create Project from Extension Template`
* In the appeared dropdown menu, `Choose a container directory`
* Select the location where the project folder will be created
* In the appeared dropdown menu. choose `template-app`


In the folder you selected, the following project files are now present:

```console
.
├── CMakeLists.txt
├── README.md
└──  main/
    ├── CMakeLists.txt
    └── main.c
```

As you can see, the structure is much simpler than in the `blink` or `hello_world` example.

## Start a soft-AP

To keep things as simple as possible, this tutorial will hard-code the access point (AP) credentials. As a result, we won't use Non-Volatile Storage (NVS), which is typically used in Wi-Fi applications to store credentials and calibration data.

NVS is enabled by default. To avoid warnings and errors, we have to disable it through `menuconfig`.

### Disable NVS

To disable NVS, open `menuconfig` and find for the `NVS` option:

* `> ESP-IDF: SDK Configuration Editor (menuconfig)` → `NVS`
* Deselect `PHY` and `Wi-Fi`, as shown in Fig.2

{{< figure
default=true
src="../assets/ass-2-1-disable-nvs.webp"
height=500
caption="Fig. 2 - NVS options to disable"

>}}

* Click `Save`
* Close the `menuconfig` tab

### Define soft-AP parameters

Now open the file `main/main.c`.
We'll use `define` to set the parameters required by the soft-AP:
```c
#define ESP_WIFI_SSID "<YOURNAME_esp_test>"
#define ESP_WIFI_PASS "test_esp"
#define ESP_WIFI_CHANNEL 1
#define MAX_STA_CONN 2
```

To avoid overlapping with the other participants, please __choose a unique SSID name__.
{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
 This is __not__ the recommended way to store credentials. Please store them securely in NVS or manage them through configuration settings using `menuconfig`. For this workshop, use a unique SSID value!
{{< /alert >}}

### Initialize IP stack and Event Loop

Espressif's Wi-Fi component relies on an [event loop](https://en.wikipedia.org/wiki/Event_loop) to handle asynchronous events. To start the soft-AP, we need to:

1. Include `esp_wifi.h`, `string.h`, and `esp_log.h`
1. Initialize the IP stack (via `esp_netif_init` and `esp_netif_create_default_wifi_ap`)
1. Start the [default event loop](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/esp_event.html#default-event-loop)
1. Create and register an event handler function to process Wi-Fi events

To keep things clean, we'll encapsulate this code in the function `wifi_init_softap`

```c
#include "esp_wifi.h"
#include "string.h"
#include "esp_log.h"


static const char* TAG = "main"; // Used for logging
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

* Create a `wifi_event_handler` function to handle Wi-Fi events.<br>
  _Because this function is invoked by `wifi_init_softap()`, it must be defined before that function._


```c
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                                  int32_t event_id, void* event_data){
    printf("Event nr: %ld!\n", event_id);
}
```

* Call the function inside the `app_main`<br>
   ```c
    void app_main(void)
    {
        wifi_init_softap();
    }
   ```
* Choose the target (`esp32c3`) and select port as done in the previous assignments.
* `> ESP-IDF: Build, Flash and Start a Monitor on Your Device`

You should start seeing several event numbers appearing on the terminal.

```console
[...]
I (576) wifi:Init max length of beacon: 752/752
Event n°: 43!
I (576) esp_netif_lwip: DHCP server started on interface WIFI_AP_DEF with IP: 192.168.4.1
Event n°: 12!
I (586) main: wifi_init_softap completata. SSID:TEST_WORKSHOP password:test_esp canale:1
I (596) main_task: Returned from app_main()
```

### Connect to the soft-AP with a Smartphone

Take your smartphone, open the Wi-Fi list, and select the SSID that you chose at the previous step (Fig.2)

{{< figure
    default=true
    src="../assets/ass-2-1-ap-list.webp"
    height=500
    caption="Fig. 2 - List of APs"
    >}}

In the terminal, you should now see `Event nr: 14!` which corresponds to `WIFI_EVENT_AP_STACONNECTED` (you can check the enum value on [GitHub](https://github.com/espressif/esp-idf/blob/c5865270b50529cd32353f588d8a917d89f3dba4/components/esp_wifi/include/esp_wifi_types_generic.h#L964) - remember that enumeration of values start from 0!)

This indicates that a station (i.e. your smartphone) has connected to the soft-AP (i.e. the Espressif module).

## Start an HTTP server

The HTTP server library provided by ESP-IDF is called `esp_http_server`. To use it, you’ll need to include the library and configure and start the server.

### Include the library

To use `esp_http_server` in your project, you’ll need to ensure that CMake recognizes it as a required component.

1. Include the HTTP server header:

   ```c
   #include "esp_http_server.h"
   ```
2. To use the logging library (`ESP_LOGI`), we define a string named TAG:
   ```c
    static const char* TAG = "main";
   ```

### Configure the HTTP Server

* We encapsulate the server setup in a dedicated function:

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

* In your `app_main` function, start the server calling:

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
src="../assets/ass-2-1-result.webp"
height=100
caption="Fig. 3 – HTML page displayed"
 >}}

 ## Assignment Code

<details>
<summary>Show assignment code</summary>

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


static const char* TAG = "main";

static esp_err_t hello_get_handler(httpd_req_t *req)
{
    const char* resp_str = "<h1>Hello World</h1>";
    httpd_resp_send(req, resp_str, HTTPD_RESP_USE_STRLEN);
    return ESP_OK;
}


static const httpd_uri_t hello_world_uri= {
    .uri       = "/",
    .method    = HTTP_GET,
    .handler   = hello_get_handler,
    .user_ctx  = NULL
};


static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                                  int32_t event_id, void* event_data){
    printf("Evento n°: %ld!\n", event_id);
}

void wifi_init_softap(){
    esp_netif_init();
    esp_event_loop_create_default();
    esp_netif_create_default_wifi_ap();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT(); 

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

httpd_handle_t start_webserver() {
    httpd_handle_t server = NULL;
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();

    if (httpd_start(&server, &config) == ESP_OK) {
        ESP_LOGI(TAG, "Server successfully started, registering URI handlers...");
        return server;
    }

    ESP_LOGE(TAG, "Server initialization failed");
    return NULL;
}


void app_main(void)
{
    wifi_init_softap();
    httpd_handle_t server = start_webserver();
    httpd_register_uri_handler(server,&hello_world_uri);
}
```

</details>


## Conclusion

Now you can put the Espressif device into Soft-AP or STA mode and create an HTTP server which can return both HTML based content of a JSON based response for a REST API.

### Next step

> Next assignment: [Assignment 2.2](../assignment-2-2/)

> Or [go back to navigation menu](../#agenda)
