---
title: "AI Agent Coding for ESP-IDF Workshop - Assignment 3: AI-Assisted Component Development"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 6
showAuthor: false
---

## Assignment 3: AI-Assisted Component Development

---

In this assignment, you will use an AI agent to create a reusable ESP-IDF component. You will learn how to guide the agent to follow ESP-IDF component conventions and how to integrate the generated component into your main application.

### What you will build

A custom `led_indicator` component that:

- Controls a single GPIO-connected LED.
- Exposes a simple public API: `led_indicator_init`, `led_indicator_on`, `led_indicator_off`, `led_indicator_toggle`.
- Uses `Kconfig` to configure the GPIO pin number.

### Step 1: Prompt the Agent to Create the Component

Open the AI chat panel and use the following prompt:

```
Create a new ESP-IDF component called "led_indicator" under components/led_indicator/.

The component should:
- Control a single LED connected to a GPIO pin.
- Expose these functions in led_indicator.h:
    esp_err_t led_indicator_init(void);
    esp_err_t led_indicator_on(void);
    esp_err_t led_indicator_off(void);
    esp_err_t led_indicator_toggle(void);
- Use CONFIG_LED_INDICATOR_GPIO_NUM (defined in Kconfig) for the GPIO pin, with default 8.
- Use the ESP-IDF GPIO driver (driver/gpio.h).
- Follow the component structure: CMakeLists.txt, include/led_indicator.h, led_indicator.c

Follow the project rules in AGENTS.md.
```

### Step 2: Review the Generated Files

Verify that the agent produced all required files:

```
components/
└── led_indicator/
    ├── CMakeLists.txt
    ├── Kconfig
    ├── include/
    │   └── led_indicator.h
    └── led_indicator.c
```

Check each file:

- [ ] `CMakeLists.txt` uses `idf_component_register` with `SRCS` and `INCLUDE_DIRS`.
- [ ] `Kconfig` defines `LED_INDICATOR_GPIO_NUM` with a prompt, default, and help text.
- [ ] `led_indicator.h` declares all four functions with `esp_err_t` return types.
- [ ] `led_indicator.c` implements all four functions using `gpio_set_level` and `gpio_get_level`.

### Step 3: Integrate the Component into the Application

Ask the agent to update `main/app_main.c` (or your project's main file) to use the new component:

```
Update app_main.c to call led_indicator_init() at startup, then toggle the LED every 500 ms in a loop using vTaskDelay.
Add "led_indicator" to the REQUIRES list in main/CMakeLists.txt.
```

### Step 4: Build and Test

```bash
idf.py build
idf.py -p <PORT> flash monitor
```

You should see the LED toggle at 500 ms intervals. Adjust `CONFIG_LED_INDICATOR_GPIO_NUM` via `menuconfig` if needed to match your hardware.

{{< alert icon="circle-info" >}}
If your devkit has an addressable RGB LED (e.g. the ESP32-C6-DevKitC-1 uses GPIO8 for its RGB LED), use a component that supports WS2812 instead. You can ask the agent to adapt the component accordingly.
{{< /alert >}}

## Next step

[Assignment 4: Debugging and Refactoring with AI](../assignment-4)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
