---
title: "AI agent coding for ESP-IDF workshop - Assignment 2: Create a new project"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 6
showAuthor: false
---

## Assignment 2: Create a new project

---

In this assignment, you'll use an AI agent to create a simple LED blink application, the embedded "Hello World". But the goal isn't just to get the code working. You'll try three different ways of prompting the agent and observe how the quality and precision of the output change with each one.

By the end, you'll have a clear feel for why a good spec saves time.

> [!NOTE]
> AI-generated code is **probabilistic** and **non-deterministic**. Even with identical spec files and prompts, the output can vary between runs, agents, and models. What you see in your session may look different from what someone next to you gets. That's expected. The goal of a good spec isn't to guarantee identical output — it's to keep the variation within acceptable bounds and reduce the number of correction cycles.

### What you will build

A simple ESP-IDF application for **ESP32-C5** that blinks an LED connected to a GPIO pin at a configurable interval.

### Step 1: Create a new project

Create a new ESP-IDF project using the ESP-IDF extension:

1. Open the Command Palette (Ctrl+Shift+P).
2. Select **ESP-IDF: Create Project from Extension Template**.
3. Choose the `hello_world` template as a starting point.
4. Name the project `led-blink` and select a location.
5. Open the project folder in your IDE.

---

### Approach 1: The simple prompt

Start with the most natural thing you might type. Open the AI chat panel and enter:

```
Create a LED blink project for ESP-IDF.
```

Hit send and watch what happens.

The agent may ask clarifying questions, but it may also start immediately and fill in the missing details itself: which SoC, which GPIO, which ESP-IDF version, what blink rate, and how the application should be structured. In this example, it asked no questions and generated a generic implementation based on its own assumptions.

This isn't a failure. It's a signal that the prompt didn't give the agent enough to work with.

#### Approach 1 results

**How many questions did the agent ask you?** ______

**Generated code: `main.c`**

```text
#include <stdio.h>

#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define LED_PIN 2

void app_main(void)
{
    gpio_set_direction(LED_PIN, GPIO_MODE_OUTPUT);

    while (1) {
        printf("LED ON\n");
        gpio_set_level(LED_PIN, 1);
        vTaskDelay(1000 / portTICK_PERIOD_MS);

        printf("LED OFF\n");
        gpio_set_level(LED_PIN, 0);
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
}
```

In this implementation, the agent chose the filename and program structure itself, put the infinite loop directly in `app_main`, guessed GPIO 2 and a 1000 ms delay, and used `printf` for logging. Both values are hardcoded, there is no Kconfig configuration, and return values are not checked. The result satisfies a generic interpretation of "LED blink," but several important implementation details were left to the agent's assumptions.

---

### Approach 2: The detailed prompt

Now give the agent the context it needs. Open a new chat and enter:

```
Using ESP-IDF v6.0.2 for ESP32-C5, create a LED blink application called "led-blink":

1. Blink the LED connected to GPIO 8 at a 500 ms interval.
2. Define the GPIO pin number as CONFIG_LED_BLINK_GPIO (Kconfig.projbuild, default 8, range 0–48).
3. Define the blink interval as CONFIG_LED_BLINK_PERIOD_MS (Kconfig.projbuild, default 500, range 100–5000).
4. Use ESP_LOGI with tag "app" for log output.
5. Run the blink loop in a separate FreeRTOS task and let app_main return after creating it.
```

The agent will start writing immediately. The output will be more complete, better structured, and much closer to what you actually want on the first try. Notice how few (if any) follow-up questions it asks compared to Approach 1.

Review the generated files before accepting:

- [ ] `main/led_blink.c` contains `app_main` and a separate FreeRTOS task with the GPIO toggle loop.
- [ ] `Kconfig.projbuild` defines `LED_BLINK_GPIO` and `LED_BLINK_PERIOD_MS` with defaults and help text.
- [ ] `main/CMakeLists.txt` registers `led_blink.c` as the source file.

#### Approach 2 results

**How many questions did the agent ask you?** ______

**Generated code: `led_blink.c`**

```text
#include <stdbool.h>

#include "driver/gpio.h"
#include "esp_err.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "sdkconfig.h"

static const char *TAG = "app";

static void led_blink_task(void *arg)
{
    (void)arg;
    bool led_on = false;

    while (true) {
        led_on = !led_on;
        ESP_ERROR_CHECK(gpio_set_level(CONFIG_LED_BLINK_GPIO, led_on));
        ESP_LOGI(TAG, "LED %s", led_on ? "ON" : "OFF");
        vTaskDelay(pdMS_TO_TICKS(CONFIG_LED_BLINK_PERIOD_MS));
    }
}

void app_main(void)
{
    ESP_LOGI(TAG, "Configuring LED on GPIO %d", CONFIG_LED_BLINK_GPIO);
    ESP_ERROR_CHECK(gpio_reset_pin(CONFIG_LED_BLINK_GPIO));
    ESP_ERROR_CHECK(gpio_set_direction(CONFIG_LED_BLINK_GPIO, GPIO_MODE_OUTPUT));

    BaseType_t task_created = xTaskCreate(
        led_blink_task,
        "led_blink",
        2048,
        NULL,
        5,
        NULL);

    if (task_created != pdPASS) {
        ESP_LOGI(TAG, "Failed to create LED blink task");
    }
}

```

`Kconfig.projbuild`

```text
menu "LED blink configuration"

    config LED_BLINK_GPIO
        int "LED GPIO number"
        range 0 48
        default 8
        help
            GPIO connected to the LED.

    config LED_BLINK_PERIOD_MS
        int "Blink interval (milliseconds)"
        range 100 5000
        default 500
        help
            Delay between LED state changes.

endmenu
```

In this implementation, the agent followed the details provided in the prompt: it used the requested filename, moved the blink loop into a separate FreeRTOS task, and configured GPIO 8 and the 500 ms interval through Kconfig. It also used the requested `ESP_LOGI` tag and checked the GPIO operation results. Because the prompt defined the important design choices, the agent did not need to guess them.

---

### Approach 3: Spec files

The most reliable approach is to write the spec as Markdown files before touching the agent at all. This keeps the spec in version control, makes it easy to update, and gives the agent a stable reference across sessions.

Create the following three files in your project root:

**`PLAN.md`**

```markdown
# LED blink

## Goal
A minimal ESP-IDF application that blinks an LED to verify the environment is working end-to-end.

## Target
- SoC: ESP32-C5
- ESP-IDF: v6.0.2

## Constraints
- GPIO pin must be configurable via Kconfig
- Blink interval must be configurable via Kconfig
- LED toggle as a separate FreeRTOS task
```

**`ARCHITECTURE.md`**

```markdown
# Architecture

## Entry point
void app_main(void):
1. Configure GPIO pin as output.
2. Create the led_blink_task FreeRTOS task.
3. Return after the task has been created.

## LED blink task
void led_blink_task(void *arg):
1. Toggle the configured GPIO.
2. Log whether the LED is ON or OFF.
3. Delay for CONFIG_LED_BLINK_PERIOD_MS.
4. Repeat indefinitely.

## Configuration (Kconfig.projbuild)
- LED_BLINK_GPIO: GPIO pin number, default 8, range 0–48
- LED_BLINK_PERIOD_MS: blink interval in ms, default 500, range 100–5000

## Files
- main/led_blink.c
- main/CMakeLists.txt
- Kconfig.projbuild
- sdkconfig.defaults
```

**`STEP.md`**

```markdown
# Step 1: Implement the LED blink application

Read PLAN.md and ARCHITECTURE.md, then implement the application exactly as described.
Create all files listed under Architecture > Files.

## Acceptance criteria

Verify the following before considering this step complete:

- [ ] `main/led_blink.c` exists and contains `app_main` and a separate `led_blink_task`.
- [ ] `app_main` configures the GPIO, creates `led_blink_task`, and then returns.
- [ ] `led_blink_task` toggles the GPIO, logs the LED state, waits for the configured interval, and repeats indefinitely.
- [ ] `Kconfig.projbuild` defines `LED_BLINK_GPIO` (default 8, range 0–48) and `LED_BLINK_PERIOD_MS` (default 500, range 100–5000), both with help text.
- [ ] `main/CMakeLists.txt` registers `led_blink.c` as the source file.
- [ ] No GPIO pin or interval is hardcoded in the source: both reference `CONFIG_LED_BLINK_GPIO` and `CONFIG_LED_BLINK_PERIOD_MS`.
- [ ] All log output uses `ESP_LOGI` with tag `"app"`.
- [ ] `sdkconfig.defaults` is present and does not override defaults unnecessarily.
- [ ] `idf.py build` succeeds with no errors.
```

Then run the prompt:

```text
Based on @ARCHITECTURE.md, @PLAN.md and @STEP.md, create the application.
```

> [!NOTE]
> Notice the difference across all three approaches: the simpler the prompt, the more the agent has to guess. The approach based on spec files inverts this: you do the thinking up front, and the agent does the implementation.

#### Approach 3 results

**How many questions did the agent ask you?** ______

**Generated code: `led_blink.c`**

```text
#include <stdbool.h>

#include "driver/gpio.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static const char *const TAG = "app";

static void led_blink_task(void *arg)
{
    (void)arg;
    bool led_is_on = false;

    while (true) {
        led_is_on = !led_is_on;
        gpio_set_level(CONFIG_LED_BLINK_GPIO, led_is_on);
        ESP_LOGI(TAG, "LED is %s", led_is_on ? "ON" : "OFF");
        vTaskDelay(pdMS_TO_TICKS(CONFIG_LED_BLINK_PERIOD_MS));
    }
}

void app_main(void)
{
    const gpio_config_t led_config = {
        .pin_bit_mask = 1ULL << CONFIG_LED_BLINK_GPIO,
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };

    ESP_ERROR_CHECK(gpio_config(&led_config));

    const BaseType_t task_created = xTaskCreate(
        led_blink_task,
        "led_blink",
        2048,
        NULL,
        5,
        NULL);

    if (task_created != pdPASS) {
        ESP_LOGI(TAG, "Failed to create LED blink task");
    }
}
```

In this implementation, the agent followed the design recorded in the spec files. `app_main` configures the GPIO with `gpio_config`, creates a dedicated `led_blink_task`, and then returns. The task owns the continuous blink loop, toggles the Kconfig-selected GPIO, logs each state change, and waits for the configured interval. The GPIO, timing, file structure, task behaviour, and acceptance criteria are documented separately, making the implementation easier to review and reproduce without expanding the chat prompt.

---

### Step 2: Build and fix

Whichever approach produced the best result, ask the agent to handle the complete build-and-fix cycle:

```text
Set the target to esp32c5 and run idf.py build.
Read the build output, fix any errors, and rebuild.
Repeat until the build succeeds, then summarise the changes you made.
```

The agent runs the commands in its terminal and reads the output directly, so you do not need to copy and paste build errors. Review each fix it makes and confirm that it does not change the requirements just to make the build pass.

If the build fails because `idf.py` is not found or the environment is not set up, ask the agent to export it first:

```text
Export the ESP-IDF environment from <path to your ESP-IDF installation>, then run idf.py build.
```

Replace `<path to your ESP-IDF installation>` with the actual path, for example `~/esp/v6.0.2/esp-idf`. The agent will source the export script and retry the build.

### Step 3: Flash and verify

Ask the agent to flash the application and verify its serial output:

```text
Detect the connected ESP32-C5 serial port. If no port or more than one suitable
port is found, ask me which one to use.
Run idf.py -p <PORT> flash monitor, observe at least two LED ON/OFF cycles,
then stop the monitor.
Report the captured log output and whether the timing matches the specification.
```

The agent should report log output similar to:

```
  I (260) app: LED is ON
  I (760) app: LED is OFF
  I (1260) app: LED is ON
  I (1760) app: LED is OFF
  I (2260) app: LED is ON
  I (2760) app: LED is OFF
```

The agent can verify the serial output, but it cannot see the physical LED. Confirm that the LED is blinking on the board. If it is not, tell the agent the exact board model and ask it to check the LED type and GPIO configuration before making any changes.

### Is the LED blinking?

No. The application built and flashed successfully, and the serial monitor showed the expected ON/OFF messages, but the physical LED did not blink.

This happened because the specification named the **ESP32-C5** SoC but did not identify the board as the **ESP32-C5-DevKitC-1**. Without the exact board model, the agent assumed that the LED was a regular LED connected directly to a GPIO. Instead, the DevKitC-1 has an addressable LED, which requires the appropriate LED driver and cannot be controlled by simply setting a GPIO high or low.

From the agent's perspective, everything was working:

- The project compiled without errors.
- The firmware flashed successfully.
- The application ran and produced the expected log messages.

Those checks verify the software workflow, but they do not verify the physical output. The log messages only report the state that the application attempted to set, and the agent cannot see whether the LED actually changed.

This is why an embedded specification should include the exact board model and relevant hardware details, not only the target SoC. Tell the agent what happened and provide the missing context:

```text
The physical LED is not blinking. The board is an ESP32-C5-DevKitC-1 and its
onboard LED is addressable. Check the board documentation for the LED type and
GPIO, then update the implementation to use the appropriate ESP-IDF driver.
Build, flash, and monitor the application again.
```

Do not move to the next assignment until you have confirmed that the physical LED is blinking correctly.

## Next step

[Assignment 3: Create a component](../assignment-3)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
