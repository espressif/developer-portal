---
title: "ESP-IDF Adv. - Assign.  2.1"
date: "2025-08-05"
series: ["WS00B"]
series_order: 7
showAuthor: false
summary: "Event loop: Manage temperature and alarm sensor via events"
---

In this assigment, we will decouple the alarm and temperature code by using the default event loop. In the previous code, we were already indirectly using this event loop for capturing MQTT and Wi-Fi events.

## Assignment steps

We will:

1. Create the events<br>
   * `TEMP_EVENT_BASE` with `temp_event_id`
   * `ALARM_EVENT_BASE` with `alarm_event_id_t`
2. Create the handler functions<br>
   * `alarm_event_handler`
   * `temp_event_handler`
3. Register the handler functions
3. Create the two timers<br>
   * `esp_timer_create`
   * `esp_timer_start_periodic`
4. Create the timer callback functions to post the event every 5s and 200ms<br>
   * `temp_timer_callback`
   * `alarm_timer_callback`
5. Create a infinite sleep loop in main


#### Create the events

We start by defining the two event bases outisde any function (global)
```c
ESP_EVENT_DEFINE_BASE(TEMP_EVENT_BASE);
ESP_EVENT_DEFINE_BASE(ALARM_EVENT_BASE);
```

We define their `event_id` as an enum. In this case, both comprise just a single value.
```c
typedef enum {
    TEMP_EVENT_MEASURE,
} temp_event_id_t;

typedef enum {
    ALARM_EVENT_CHECK,
} alarm_event_id_t;
```

#### Create handler funcions

We create the two event handler functions which do the actual job of posting the data on the MQTT channel.
The posting code is the same of the previous assignment.
```c
static void temp_event_handler(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data) {
    float temp;
    if (temperature_sensor_read_celsius(sensor, &temp) == ESP_OK) {
        cloud_manager_send_temperature(cloud, temp);
    } else {
        ESP_LOGW("APP", "Failed to read temperature");
    }
}

static void alarm_event_handler(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data) {
    if (is_alarm_set(alarm)) {
        ESP_LOGI("APP", "ALARM ON!!");
        cloud_manager_send_alarm(cloud);
    }
}
```

#### Register the handler functions

In the `app_main` we can now register the two handler function. We need to specify the event base and id they're connected to:

```c
ESP_ERROR_CHECK(esp_event_handler_register(TEMP_EVENT_BASE, TEMP_EVENT_MEASURE, temp_event_handler, NULL));
ESP_ERROR_CHECK(esp_event_handler_register(ALARM_EVENT_BASE, ALARM_EVENT_CHECK, alarm_event_handler, NULL));
```

#### Create the timers

The actual source of event in this assignment are timers, so we need to start two of them.

To create and start the temperature and alarm timers, you need to add to your `app_main()`:
```c
// Create and start periodic timers

// Temperature timer
    const esp_timer_create_args_t temp_timer_args = {
        .callback = &temp_timer_callback,
        .name = "temp_timer"
    };
    esp_timer_handle_t temp_timer;
    ESP_ERROR_CHECK(esp_timer_create(&temp_timer_args, &temp_timer));
    ESP_ERROR_CHECK(esp_timer_start_periodic(temp_timer, TEMPERATURE_MEAS_PERIOD_US));

// Alarm timer
const esp_timer_create_args_t alarm_timer_args = {
    .callback = &alarm_timer_callback,
    .name = "alarm_timer"
};
esp_timer_handle_t alarm_timer;
ESP_ERROR_CHECK(esp_timer_create(&alarm_timer_args, &alarm_timer));
ESP_ERROR_CHECK(esp_timer_start_periodic(alarm_timer, ALARM_CHECK_PERIOD_US));
```

The two macros `ALARM_CHECK_PERIOD_US` and `TEMPERATURE_MEAS_PERIOD_US` could be added as defines at the beginning of the code or as a module's parameter.
For the sake of semplicity, we will define them at the beginning of `app_main.c` as
```c
#define TEMPERATURE_MEAS_PERIOD_US (5 * 1000000)
#define ALARM_CHECK_PERIOD_US      (200 * 1000)
```
#### Create the timer callback functions

In the previous code, we gave as `.callback` the functions `temp_timer_callback` and a `alarm_timer_callback`.
These functions are called when the timer expires.

In this assignment, these functions need to just post an event
```c
static void temp_timer_callback(void* arg) {
    esp_event_post(TEMP_EVENT_BASE, TEMP_EVENT_MEASURE, NULL, 0, 0);
}

static void alarm_timer_callback(void* arg) {
    esp_event_post(ALARM_EVENT_BASE, ALARM_EVENT_CHECK, NULL, 0, 0);
}
```

The event loop will take care of calling the right function when the event is triggered.

#### Main sleep

The last thing to do, is to let the main continue to run while events are triggered. We can do this by adding an infinite loop

```c
while (1) {
    vTaskDelay(pdMS_TO_TICKS(1000));
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

#define TEMPERATURE_MEAS_PERIOD_US (5 * 1000000)
#define ALARM_CHECK_PERIOD_US      (200 * 1000)

ESP_EVENT_DEFINE_BASE(TEMP_EVENT_BASE);
ESP_EVENT_DEFINE_BASE(ALARM_EVENT_BASE);

static bool previous_alarm_set = false;

typedef enum {
    TEMP_EVENT_MEASURE,
} temp_event_id_t;

typedef enum {
    ALARM_EVENT_CHECK,
} alarm_event_id_t;

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

static void alarm_event_handler(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data) {

    bool alarm_state = is_alarm_set(alarm);
    if (alarm_state && !previous_alarm_set) {
        printf("ALARM ON!!\n");
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

    printf("Connecting...\n");
    ESP_ERROR_CHECK(cloud_manager_connect(cloud));
    printf("Connected!\n");

    // Register event handlers
    ESP_ERROR_CHECK(esp_event_handler_register(TEMP_EVENT_BASE, TEMP_EVENT_MEASURE, temp_event_handler, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(ALARM_EVENT_BASE, ALARM_EVENT_CHECK, alarm_event_handler, NULL));

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
    ESP_ERROR_CHECK(esp_timer_start_periodic(alarm_timer, ALARM_CHECK_PERIOD_US));

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

You can find the whole solution project in the [assignment_2_1](https://github.com/FBEZ-docs-and-templates/devrel-advanced-workshop-code/tree/main/assignment_2_1) folder in the GitHub repo.

## Conclusion

Using an event loop decouples the managent of the alarm and temperature sensor. In this specific assignment, we could have reached the same result by using the timers callback function to do the same and avoid all the event loop overhead. But in general, events can come from a variety of sources and event loop offer an unified approach to decouple the application logic.

If you still have time, you can check out [assignment 2.2](../assignment-2-2), which adds an additional source event triggered by a gpio.

Otherwise:
> Next step: [Lecture 3](../lecture-3/)
