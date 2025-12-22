---
title: "ESP-IDF Adv. - Lecture 2"
date: "2025-08-05"
series: ["WS00B"]
series_order: 6
showAuthor: false
summary: "In this article, we explore the event loop—a core component of Espressif's ESP-IDF framework that facilitates efficient, decoupled, and asynchronous event handling in embedded applications. We examine its functionality, highlight its benefits, explain how it is used by default within ESP-IDF, and provide practical code examples to demonstrate common usage patterns."
---

## Introduction

Managing asynchronous events—such as Wi-Fi connectivity, timers, or signals—can be challenging in embedded systems. Espressif's ESP-IDF addresses this complexity through its event loop library, which allows components to define events and register handlers that respond when those events occur. This model encourages loose coupling between components and promotes a clean, __event-driven programming__ style by deferring execution to a dedicated context rather than handling events directly in interrupt service routines or application threads.

### When are event loop useful

Event loops are essential when handling asynchronous events in a modular and structured manner. Consider a scenario where a Wi-Fi connection is established: different components—such as a logger, a UI module, and a network service—may each need to respond to this event. The event loop allows each component to independently register a handler, and ensures all handlers are executed in the order they were registered.

This approach reduces tight coupling and eliminates the need for complex interdependencies between components. As a result, applications become more modular, scalable, and easier to maintain.

Event loops are especially useful in situations where multiple components need to react to the same event independently—for example, networking, sensor data processing, or inter-task communication. This approach simplifies coordination and improves maintainability across the system.

## Events and Callback Functions

The event loop revolves around two key concepts:

* __Events__
* __Callback functions__

In simple terms, when a registered event is triggered (or *posted*), the event loop invokes the corresponding callback function.
To make this work, you must register both the event and its associated callback with the event loop.

{{< figure
default=true
src="../assets/lecture_2_event_loop.webp"
height=300
caption="Simplified event loop block diagram"
>}}

Since many events can be logically grouped—for example, all events related to Wi-Fi or MQTT—they are categorized using two identifiers:

* An __event base__, which defines the group.
* An __event ID__, which identifies the specific event within that group.

For instance, Wi-Fi-related events fall under the event base `WIFI_EVENT`. Specific event IDs within this base include `WIFI_EVENT_STA_START` and `WIFI_EVENT_STA_DISCONNECTED`.


### Default event loop

ESP-IDF automatically creates and manages a *default event loop* for core system events—such as Wi-Fi, IP configuration, and Bluetooth. This default loop is internal, and its handle is abstracted away from the user. System components post events to this loop, and application code can register handlers to process them.

For many use cases, the default event loop is sufficient and avoids the overhead of creating a custom loop. Developers can also post their own application events to the default event loop, making it an efficient option when memory usage is a concern. You can read more about the difference between default event loop and user event loop on the [documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/esp_event.html#default-event-loop).

## Code Snippets

### Defining an event

The following code snippet demonstrates how to define an event base and event IDs using the ESP-IDF macros

```c
// In your header file (e.g., my_events.h)
#include "esp_event.h"

ESP_EVENT_DECLARE_BASE(MY_EVENT_BASE);

typedef enum {
    MY_EVENT_ID_1,
    MY_EVENT_ID_2,
    MY_EVENT_ID_3,
} my_event_id_t;
```

```c
// In your source file (e.g., my_events.c)
#include "my_events.h"

ESP_EVENT_DEFINE_BASE(MY_EVENT_BASE);
```

This approach uses `ESP_EVENT_DECLARE_BASE()` to declare the event base in a header file and `ESP_EVENT_DEFINE_BASE()` to define it in a source file. Event IDs are typically declared as an enumeration for clarity and maintainability. This pattern is recommended across ESP-IDF for all supported chips.

These macros just create global variables. We can take a look to their code to understand what they do:

```c
// Defines for declaring and defining event base
#define ESP_EVENT_DECLARE_BASE(id) extern esp_event_base_t const id
#define ESP_EVENT_DEFINE_BASE(id) esp_event_base_t const id = #id
```

### Defining and Registering an Event Handler

The following example shows how to define a handler and register it to the default event loop for a specific event:

```c
// Define the event handler
void run_on_event(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data)
{
    // Event handler logic
}

// Register the handler to the default event loop
esp_event_handler_register(MY_EVENT_BASE, MY_EVENT_ID, &run_on_event, NULL);
```

### Posting an Event to the Default Event Loop

To trigger an event from within your application, you can post to the default event loop like this:

```c
// Post an event to the default event loop
esp_event_post(MY_EVENT_BASE, MY_EVENT_ID, &event_data, sizeof(event_data), portMAX_DELAY);
```

### Creating and Using a User Event Loop

In more advanced scenarios, you might want to create a dedicated event loop. Here's how:

```c
esp_event_loop_handle_t user_loop;
esp_event_loop_args_t loop_args = {
    .queue_size = 5,
    .task_name = "user_event_task", // Set to NULL to avoid creating a dedicated task
    .task_priority = uxTaskPriorityGet(NULL),
    .task_stack_size = 2048,
    .task_core_id = tskNO_AFFINITY
};

// Create the user event loop
esp_event_loop_create(&loop_args, &user_loop);

// Register a handler with the custom event loop
esp_event_handler_register_with(user_loop, MY_EVENT_BASE, MY_EVENT_ID, &run_on_event, NULL);

// Post an event to the custom loop
esp_event_post_to(user_loop, MY_EVENT_BASE, MY_EVENT_ID, &event_data, sizeof(event_data), portMAX_DELAY);
```

## Conclusion

The event loop mechanism in Espressif's ESP-IDF framework offers a powerful way to handle asynchronous events cleanly and efficiently. Used by default for system-level notifications like Wi-Fi connectivity, the event loop can also be extended for custom application needs through user-defined loops. By facilitating decoupled, ordered, and modular event processing, this architecture helps developers build more maintainable and scalable embedded systems—especially in complex IoT applications.


> Next step: [Assignment 2.1](../assignment-2-1/)

> Or [go back to navigation menu](../#agenda)

## Further reading

* [Event Loop Library Overview](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/esp_event.html)
* [esp\_event APIs](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/esp_event.html)
* [Default Event Loop Example](https://github.com/espressif/esp-idf/blob/master/examples/system/esp_event/default_event_loop/README.md)
* [User Event Loops Example](https://github.com/espressif/esp-idf/blob/master/examples/system/esp_event/user_event_loops/README.md)
