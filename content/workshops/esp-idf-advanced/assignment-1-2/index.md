---
title: "ESP-IDF Adv. - Assign.  1.2"
date: "2025-08-05"
series: ["WS00B"]
series_order: 4
showAuthor: false
summary: "Create a `cloud_manager` component and refactor the code to use it."
---

In this second part, we will separate the connection logic from the main function. The main advantage of this approach is that you could transparently change the connection type (e.g. to MQTTS or HTTP).

In this assignment, we will refactor the connection to Wi-Fi and MQTT code to fit into a new component.

#### Assignment details

You should create a `cloud_manager` component with the following methods

* `cloud_manager_t *cloud_manager_create(void);`
* `esp_err_t cloud_manager_connect(cloud_manager_t *manager);`
* `esp_err_t cloud_manager_disconnect(cloud_manager_t *manager);`
* `esp_err_t cloud_manager_send_temperature(cloud_manager_t *manager, float temp);`
* `esp_err_t cloud_manager_send_alarm(cloud_manager_t *manager);`
* `void cloud_manager_delete(cloud_manager_t *manager);`

The following parameters should be set through `menuconfig`:

1. Broker URL (move it from the main to the `cloud_manager` component)
2. The channel where the temperature is published (`sensor/temperature` by default)
3. The channel where the alarm is published (`sensor/alarm` by default)

## Assignment steps outline

1. Create a new component and fill `cloud_manager.h`
   * Add the suggested methods<br>
   * Add an opaque declaration `typedef struct cloud_manager_t cloud_manager_t;`<br>
   _Note: In `cloud_manager.h` you need to import just `esp_err.h`_
2. Fill `cloud_manager.c`<br>
   * Implement `cloud_manager_t` as: <br>
      ```c
        struct cloud_manager_t {
        esp_mqtt_client_handle_t client;
        esp_mqtt_client_config_t mqtt_cfg;
        };
      ```
   * In `cloud_manager_create` just return the initialized object.
   * In `cloud_manager_connect` initialize everything. You can use the function `example_connect`.
3. Add the following to the `cloud_manager` component `CMakeList.txt`<br>
   ```bash
    PRIV_REQUIRES mqtt nvs_flash esp_netif protocol_examples_common
   ```
4. In `app_main.c`<br>
    * Initialize and connect to the `cloud_manager`
        ```c
        cloud_manager_t *cloud = cloud_manager_create();
        ESP_ERROR_CHECK(cloud_manager_connect(cloud));
        ```
    * Call the publishing functions in the appropriate position


## Assignment solution code

<details>
<summary>Show full assignment code</summary>

#### `cloud_manager.h`
```c
#pragma once

#include "esp_err.h"

typedef struct cloud_manager_t cloud_manager_t;

/**
 * @brief Creates a new cloud manager instance
 */
cloud_manager_t *cloud_manager_create(void);

/**
 * @brief Connects the cloud manager (starts MQTT)
 */
esp_err_t cloud_manager_connect(cloud_manager_t *manager);

/**
 * @brief Disconnects the cloud manager
 */
esp_err_t cloud_manager_disconnect(cloud_manager_t *manager);

/**
 * @brief Sends a temperature value to the cloud
 */
esp_err_t cloud_manager_send_temperature(cloud_manager_t *manager, float temp);

/**
 * @brief Sends an alarm event to the cloud
 */
esp_err_t cloud_manager_send_alarm(cloud_manager_t *manager);

/**
 * @brief Frees the memory
 */
void cloud_manager_delete(cloud_manager_t *manager);
```

#### `cloud_manager.c`

```c
#include <stdio.h>
#include <string.h>
#include "cloud_manager.h"
#include "esp_log.h"
#include "mqtt_client.h"
#include "nvs_flash.h"
#include "esp_event.h"
#include "esp_netif.h"
#include "protocol_examples_common.h"

static const char *TAG = "cloud_manager";

struct cloud_manager_t {
    esp_mqtt_client_handle_t client;
    esp_mqtt_client_config_t mqtt_cfg;
};

// Event handler for MQTT
static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data)
{
    esp_mqtt_event_handle_t event = event_data;
    esp_mqtt_client_handle_t client = event->client;

    switch ((esp_mqtt_event_id_t)event_id) {
    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "Connected to MQTT broker");
        esp_mqtt_client_subscribe(client, CONFIG_TEMPERATURE_CHANNEL, 0);
        esp_mqtt_client_subscribe(client, CONFIG_ALARM_CHANNEL, 0);
        break;

    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGI(TAG, "Disconnected from MQTT broker");
        break;

    case MQTT_EVENT_PUBLISHED:
        ESP_LOGI(TAG, "Message published (msg_id=%d)", event->msg_id);
        break;

    case MQTT_EVENT_ERROR:
        ESP_LOGE(TAG, "MQTT_EVENT_ERROR");
        break;

    default:
        break;
    }
}

cloud_manager_t *cloud_manager_create(void)
{
    cloud_manager_t *manager = calloc(1, sizeof(cloud_manager_t));
    if (!manager) return NULL;


    manager->mqtt_cfg = (esp_mqtt_client_config_t){
        .broker.address.uri = CONFIG_BROKER_URL,
    };

    return manager;
}

esp_err_t cloud_manager_connect(cloud_manager_t *manager)
{

    if(manager == NULL){return ESP_ERR_INVALID_ARG;}
    ESP_ERROR_CHECK(nvs_flash_init());
    ESP_ERROR_CHECK(esp_netif_init());
    manager->client = esp_mqtt_client_init(&manager->mqtt_cfg);
    esp_mqtt_client_register_event(manager->client, ESP_EVENT_ANY_ID, mqtt_event_handler, manager);
    ESP_ERROR_CHECK(example_connect());
    return esp_mqtt_client_start(manager->client);
}

esp_err_t cloud_manager_disconnect(cloud_manager_t *manager)
{
    if (!manager || !manager->client) return ESP_ERR_INVALID_ARG;
    return esp_mqtt_client_stop(manager->client);
}

esp_err_t cloud_manager_send_temperature(cloud_manager_t *manager, float temp)
{
    if (!manager || !manager->client) return ESP_ERR_INVALID_ARG;

    char payload[64];
    snprintf(payload, sizeof(payload), "%.2f", temp);
    ESP_LOGI(TAG, "Temperature: %.2f °C", temp);
    int msg_id = esp_mqtt_client_publish(manager->client, CONFIG_TEMPERATURE_CHANNEL, payload, 0, 1, 0);
    return msg_id >= 0 ? ESP_OK : ESP_FAIL;
}

esp_err_t cloud_manager_send_alarm(cloud_manager_t *manager)
{
    if (!manager || !manager->client) return ESP_ERR_INVALID_ARG;

    const char *alarm_payload = "ALARM ON!";
    int msg_id = esp_mqtt_client_publish(manager->client, CONFIG_ALARM_CHANNEL, alarm_payload, 0, 1, 0);
    return msg_id >= 0 ? ESP_OK : ESP_FAIL;
}

void cloud_manager_delete(cloud_manager_t *manager)
{
        if (manager) {
        free(manager);
    }

}
```

#### `Kconfig`

```bash
menu "Cloud MQTT Configuration"

    config BROKER_URL
        string "Broker URL"
        default "mqtt://test.mosquitto.org/"
        help
            URL of the broker to connect to
    config TEMPERATURE_CHANNEL
        string "MQTT channel for publishing the temperature"
        default "/sensor/temperature"
        help
            The channel in the mqtt broker where the temperature is published
    config ALARM_CHANNEL
        string "MQTT channel for publishing the alarm"
        default "/sensor/alarm"
        help
            The channel in the mqtt broker where the alarm is published

endmenu
```
</details>


You can find the whole solution project on the [assignment_1_2](https://github.com/FBEZ-docs-and-templates/devrel-advanced-workshop-code/tree/main/assignment_1_2) folder on the github repo.


> Next step: [assignment 1.3](../assignment-1-3/)
