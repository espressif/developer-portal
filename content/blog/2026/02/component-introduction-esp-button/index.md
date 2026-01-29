---
title: Introducing esp-button component
date: 2026-02-18
authors:
    - pedro-minatel
tags:
    - ESP-IDF
    - Library
    - Registry
summary: Learn how to use the ESP-IDF esp-button component to handle GPIO buttons with event detection, debouncing, and callbacks. A step-by-step guide with practical code examples.
---

## Introduction

Buttons are fundamental input elements in embedded systems, yet handling them properly requires careful attention to debouncing, event detection, and timing. Today, we're excited to introduce the [**esp-button**](https://components.espressif.com/components/espressif/button) component, a robust and feature-rich button driver for ESP-IDF that simplifies button handling in your projects.

The esp-button component provides a comprehensive solution for managing physical buttons in your ESP32 projects, supporting both GPIO-based buttons and ADC-based button matrices.

The esp-button component is available on the ESP component registry.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
The [ESP Component Registry](https://developer.espressif.com/blog/2024/10/what-is-the-esp-registry/) is a centralized platform that hosts reusable software components for ESP-IDF projects. It simplifies development by providing pre-built, tested libraries that can be easily integrated into your applications. 
{{< /alert >}}

The [ESP Component Registry](https://developer.espressif.com/blog/2024/10/what-is-the-esp-registry/) is a centralized platform that hosts reusable software components for ESP-IDF projects. It simplifies development by providing pre-built, tested libraries that can be easily integrated into your applications. The esp-button component is one of many components available in the registry, designed to help developers accelerate their projects by leveraging community-tested solutions.

## Key Features

The esp-button component offers several powerful features:

- **Multiple Button Types**: Support for GPIO buttons and ADC button matrices
- **Event Detection**: Comprehensive event handling including press, release, long press, and repeat press
- **Debouncing**: Built-in software debouncing to eliminate false triggers
- **Low Power Support**: Optimized for battery-powered applications
- **Callback System**: Easy-to-use callback mechanism for button events
- **Thread-Safe**: Safe to use in multi-threaded applications
- **Rich Event Types**: Supports 11 different button events including:
  - Button pressed, released, and press repeat
  - Single click, double click, and multiple click detection
  - Long press start, hold, and up events
  - Press repeat done and press end notifications

## Application Examples

The esp-button component enables developers to create responsive and reliable button-based interfaces across various use cases:

- **Smart Light Controls**: Implement single click for on/off, double click for brightness adjustment, and long press for color selection
- **Device Menu Navigation**: Use button events to navigate through device settings and menus with intuitive multi-tap interactions
- **IoT Gateway Configuration**: Trigger Wi-Fi provisioning mode with a long press, or reset settings with specific button combinations
- **Wearable Interfaces**: Handle button inputs in space-constrained devices with multiple functions mapped to single button
- **Industrial Control Panels**: Implement fail-safe button handling with debouncing for reliable machine control
- **Home Automation Hubs**: Manage complex automation scenes with simple button interactions and customizable timing

## Installation

You can easily add the esp-button component to your ESP-IDF project using the IDF Component Manager:

```bash
idf.py add-dependency "espressif/button=*"
```

Or manually add it to your `idf_component.yml` file:

```yaml
dependencies:
  espressif/button: "^4.1.5"
```

## Basic Example

Here's a practical example demonstrating how to set up the esp-button component with GPIO button handling. We'll break it down into steps to understand each part.

This example creates a button application that detects multiple button events on GPIO pin 9. The code initializes the button hardware, configures timing parameters for different press types, and registers callback functions that execute when specific button events are detected. When you interact with the button, the appropriate callback function is triggered, logging the event type to the console for monitoring and debugging purposes.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
This example uses the [**ESP32-C3-DevKit-RUST-2**](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c3/esp32-c3-devkit-rust-2/index.html) development board. GPIO pin 9 is the button pin on this board, but you can adapt the GPIO pin number to match your specific hardware configuration.
{{< /alert >}}

### Step 1: Include Required Headers

First, include the necessary headers for button handling and ESP-IDF components:

```c
#include <stdio.h>
#include <inttypes.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "iot_button.h"
#include "button_gpio.h"
```

### Step 2: Define GPIO and Configuration

Set up the GPIO pin and configure logging:

```c
// Define button GPIO and active level
#define BUTTON_IO_NUM           9 // GPIO number for the button
#define BUTTON_ACTIVE_LEVEL     0 // Active level for the button (0 for active low, 1 for active high)

static const char *TAG = "BUTTON";
```

### Step 3: Create Event Callback Functions

Define callback functions that will be triggered when button events occur:

```c
// Callback functions for button events
static void button_single_click_event_cb(void *arg, void *data)
{
    ESP_LOGI(TAG, "Button single click!");
}

static void button_double_click_event_cb(void *arg, void *data)
{
    ESP_LOGI(TAG, "Button double click!");
}

static void button_long_press_event_cb(void *arg, void *data)
{
    ESP_LOGI(TAG, "Button long press!");
}

static void button_repeat_event_cb(void *arg, void *data)
{
    ESP_LOGI(TAG, "Button press repeat!");
}
```

### Step 4: Configure Button Timing

In the `app_main()` function, create the button configuration with timing parameters:

```c
void app_main(void)
{
    // Create button configurations
    const button_config_t btn_cfg = {
        .long_press_time = 5000,      // Long press time in milliseconds
        .short_press_time = 200,      // Short press time in milliseconds
    };
```

### Step 5: Configure GPIO Settings

Set up the GPIO-specific configuration for your button:

```c
    const button_gpio_config_t btn_gpio_cfg = {
        .gpio_num = BUTTON_IO_NUM,
        .active_level = BUTTON_ACTIVE_LEVEL,
        .disable_pull = false,
    };
```

### Step 6: Create the Button Device

Initialize the button device using the configurations:

```c
    // Button handle
    button_handle_t btn;
    // Create a new button device
    esp_err_t ret = iot_button_new_gpio_device(&btn_cfg, &btn_gpio_cfg, &btn);
```

### Step 7: Register Event Callbacks

Register the callback functions for different button events:

```c
    // Register callback for button press
    ret = iot_button_register_cb(btn, BUTTON_SINGLE_CLICK, NULL, button_single_click_event_cb, NULL);
    ESP_ERROR_CHECK(ret);
    ret = iot_button_register_cb(btn, BUTTON_DOUBLE_CLICK, NULL, button_double_click_event_cb, NULL);
    ESP_ERROR_CHECK(ret);
    ret = iot_button_register_cb(btn, BUTTON_LONG_PRESS_UP, NULL, button_long_press_event_cb, NULL);
    ESP_ERROR_CHECK(ret);
    ret = iot_button_register_cb(btn, BUTTON_PRESS_REPEAT, NULL, button_repeat_event_cb, NULL);
    ESP_ERROR_CHECK(ret);
}
```

## Complete Source Code

The full source code for this example is available in the [developer-portal-codebase](https://github.com/espressif/developer-portal-codebase) repository.

## Expected Log Output

When you run this application and interact with the button, you'll see the corresponding log messages in the console. The following Asciinema recording demonstrates the expected behavior:

{{< asciinema key="esp-button" idleTimeLimit="2" speed="1.5">}}

### Key Points

- **GPIO Configuration**: GPIO 9 is used with active-low logic (button pulls GPIO low when pressed)
- **Timing**: Long press detected after 5 seconds, short press after 200 milliseconds
- **Multiple Events**: The component handles single clicks, double clicks, long presses, and repeated presses
- **Error Checking**: `ESP_ERROR_CHECK()` ensures each callback registration succeeds
- **Logging**: Each event callback logs to the console for easy debugging and verification

## Conclusion

The **esp-button** component is a powerful and versatile solution for handling button inputs in ESP-IDF projects. With its comprehensive event detection system, built-in debouncing, and flexible callback mechanism, it eliminates the complexity of manual button handling and lets you focus on your application logic.

Our goal is to make developer life easier. The esp-button component removes the burden of implementing reliable button handling from scratch, allowing you to spend more time building the features that matter for your product. By providing a well-tested, production-ready solution, we help you deliver higher-quality applications faster.

Whether you're developing a smart home device, an IoT gateway, or any embedded system that requires user input, the esp-button component provides the reliability and features you need. The 11 different event types give you fine-grained control over button interactions, from simple single clicks to complex long-press sequences.

You can easily integrate esp-button into your project and benefit from community-tested, production-ready code. This accelerates your development cycle and ensures consistent, reliable button handling across your application.

We encourage you to try the esp-button component in your next ESP-IDF project and experience the simplicity and power it brings to button handling.

## Resources

- [esp-button Component on ESP Component Registry](https://components.espressif.com/components/espressif/button)
- [ESP Component Registry Documentation](https://docs.espressif.com/projects/idf-component-manager/en/latest/)
- [ESP32-C3-DevKit-RUST-2 Documentation](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c3/esp32-c3-devkit-rust-2/index.html)
- [What is the ESP Component Registry?](https://developer.espressif.com/blog/2024/10/what-is-the-esp-registry/)
- [GitHub - esp-button Repository](https://github.com/espressif/esp-iot-solution)
