---
title: "ESP-IDF Adv. - Assign.  2.2"
date: "2025-08-05"
series: ["WS00B"]
series_order: 8
showAuthor: false
summary: "Event loop: add an external GPIO event"
---

In this assignment you'll extend the functionality from Assignment 2.1 by introducing an additional event source: When __GPIO9__ is pressed, an "alarm" event is posted to the system.

## Assignment goals

* The code for detecting a GPIO press is provided below.
* You need to integrate the logic into the existing event loop.
* Use the same `ALARM_EVENT_BASE` as the alarm trigger used before.
* Create a `ALARM_EVENT_BUTTON` to differenciate it from the `ALARM_EVENT_CHECK`.

## Tips

* There is an alternative version for `esp_event_post` called `esp_event_isr_post`.

### Reading GPIO code
```c
#include "driver/gpio.h"
#include "esp_attr.h"
#include "esp_log.h"

#define GPIO_INPUT_IO_9    9
#define ESP_INTR_FLAG_DEFAULT 0

static const char *TAG = "example";

// ISR handler
static void gpio_isr_handler(void* arg) {
    uint32_t gpio_num = (uint32_t) arg;
    ESP_EARLY_LOGI(TAG, "GPIO[%d] interrupt triggered", gpio_num);
}

void app_main(void)
{
    gpio_config_t io_conf = {
        .intr_type = GPIO_INTR_NEGEDGE,      // Falling edge interrupt
        .mode = GPIO_MODE_INPUT,             // Set as input mode
        .pin_bit_mask = (1ULL << GPIO_INPUT_IO_9),
        .pull_up_en = GPIO_PULLUP_ENABLE,    // Enable pull-up
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
    };
    gpio_config(&io_conf);

    // Install GPIO ISR service
    gpio_install_isr_service(ESP_INTR_FLAG_DEFAULT);
    // Hook ISR handler for specific GPIO pin
    gpio_isr_handler_add(GPIO_INPUT_IO_9, gpio_isr_handler, (void*) GPIO_INPUT_IO_9);

    ESP_LOGI(TAG, "GPIO 9 configured as input with falling edge interrupt");
}
```

## Assignment solution code

<details>
<summary>Show full assignment code</summary>

```c
#include "cloud_manager.h"
#include "temperature_sensor.h"
#include "alarm.h"
#include "esp_log.h"
#include "esp_event.h"
#include "esp_timer.h"
#include "driver/gpio.h"
#include "esp_attr.h"

#define TEMPERATURE_MEAS_PERIOD_US (5 * 1000000)
#define ALARM_CHECK_PERIOD_US      (200 * 1000)

#define GPIO_INPUT_IO_9    9
#define ESP_INTR_FLAG_DEFAULT 0


static const char *TAG = "assignment2_2";

// EVENTS
ESP_EVENT_DEFINE_BASE(TEMP_EVENT_BASE);
ESP_EVENT_DEFINE_BASE(ALARM_EVENT_BASE);

static bool previous_alarm_set = false;

typedef enum {
    TEMP_EVENT_MEASURE,
} temp_event_id_t;

typedef enum {
    ALARM_EVENT_CHECK,
    ALARM_EVENT_BUTTON
} alarm_event_id_t;


// GPIO

// ISR handler
static void gpio_isr_handler(void* arg) {
    uint32_t gpio_num = (uint32_t) arg;
    // Now that we post the event, we remove the log:
    // It is not recommended to log or print inside an ISR
    //
    // ESP_EARLY_LOGI(TAG, "GPIO[%d] interrupt triggered", gpio_num);
    esp_event_isr_post(ALARM_EVENT_BASE, ALARM_EVENT_BUTTON, NULL, 0, 0);
}

static temperature_sensor_t *sensor = NULL;
static alarm_t *alarm = NULL;
static cloud_manager_t *cloud = NULL;

static void temp_event_handler(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data) {
    float temp;
    if (temperature_sensor_read_celsius(sensor, &temp) == ESP_OK) {
        cloud_manager_send_temperature(cloud, temp);
    } else {
        ESP_LOGW("APP", "Failed to read temperature");
    }
}

static void alarm_event_button_handler(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data) {

    ESP_LOGI("APP", "ALARM ON!!");
    cloud_manager_send_alarm(cloud);

}


static void alarm_event_handler(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data) {

    bool alarm_state = is_alarm_set(alarm);
    if (alarm_state && !previous_alarm_set) {
        ESP_LOGI("APP", "ALARM ON!!");
        cloud_manager_send_alarm(cloud);
    }
    previous_alarm_set = alarm_state;
}

static void temp_timer_callback(void* arg) {
    esp_event_post(TEMP_EVENT_BASE, TEMP_EVENT_MEASURE, NULL, 0, 0);
}

static void alarm_timer_callback(void* arg) {
    esp_event_post(ALARM_EVENT_BASE, ALARM_EVENT_CHECK, NULL, 0, 0);
}

void app_main(void)
{
    ESP_LOGI("APP", "Starting...");

    ESP_ERROR_CHECK(esp_event_loop_create_default());

    sensor = temperature_sensor_create();
    alarm = alarm_create();
    cloud = cloud_manager_create();

    ESP_LOGI("APP", "Connecting...");
    ESP_ERROR_CHECK(cloud_manager_connect(cloud));
    ESP_LOGI("APP", "Connected!");

    // Register event handlers
    ESP_ERROR_CHECK(esp_event_handler_register(TEMP_EVENT_BASE, TEMP_EVENT_MEASURE, temp_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(ALARM_EVENT_BASE, ALARM_EVENT_CHECK, alarm_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(ALARM_EVENT_BASE, ALARM_EVENT_BUTTON, alarm_event_button_handler, NULL));

    // Create and start periodic timers
    const esp_timer_create_args_t temp_timer_args = {
        .callback = &temp_timer_callback,
        .name = "temp_timer"
    };
    esp_timer_handle_t temp_timer;
    ESP_ERROR_CHECK(esp_timer_create(&temp_timer_args, &temp_timer));
    ESP_ERROR_CHECK(esp_timer_start_periodic(temp_timer, TEMPERATURE_MEAS_PERIOD_US));

    const esp_timer_create_args_t alarm_timer_args = {
        .callback = &alarm_timer_callback,
        .name = "alarm_timer"
    };
    esp_timer_handle_t alarm_timer;
    ESP_ERROR_CHECK(esp_timer_create(&alarm_timer_args, &alarm_timer));


    // GPIO

     gpio_config_t io_conf = {
        .intr_type = GPIO_INTR_NEGEDGE,      // Falling edge interrupt
        .mode = GPIO_MODE_INPUT,             // Set as input mode
        .pin_bit_mask = (1ULL << GPIO_INPUT_IO_9),
        .pull_up_en = GPIO_PULLUP_ENABLE,    // Enable pull-up
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
    };
    gpio_config(&io_conf);

    // Install GPIO ISR service
    gpio_install_isr_service(ESP_INTR_FLAG_DEFAULT);
    // Hook ISR handler for specific GPIO pin
    gpio_isr_handler_add(GPIO_INPUT_IO_9, gpio_isr_handler, (void*) GPIO_INPUT_IO_9);

    // The main task can now just sleep
    while (1) {
        vTaskDelay(pdMS_TO_TICKS(1000));
    }

    // Cleanup (unreachable in this example)
    cloud_manager_disconnect(cloud);
    cloud_manager_delete(cloud);
    temperature_sensor_delete(sensor);
    alarm_delete(alarm);
}
```

</details>


You can find the whole solution project on the [assignment_2_2](https://github.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-idf-advanced/assignment_2_2) folder on the github repo.


### Next step

> Next step: [Lecture 3](../lecture-3/)

> Or [go back to navigation menu](../#agenda)