---
title: "Part 2 — Implement the Driver Functions"
date: "2026-06-18"
lastmod: "2026-06-18"
series: ["WSRMS"]
series_order: 2
showAuthor: false
summary: "Understand the generated app_devices.c scaffold and fill in the three driver sections: LED strip initialisation, BOOT button handling, and the FreeRTOS rainbow cycling task."
---

The generated `app_devices.c` contains the full RainMaker device and parameter setup. The only parts marked `TODO` are:

- `app_driver_init()` — hardware peripheral initialisation
- The three `if/else` branches inside `app_device_bulk_write_cb()` — apply incoming cloud/app values to hardware
- `app_device_set_mfg_data()` — set provisioning device type

## Project Structure

```
main/app_devices.c     ← all driver work goes here
main/idf_component.yml ← add hardware component dependencies here
```

No other files need changes.

## Understanding the Generated Code

Studio generates these key definitions for you:

```c
#define NODE_NAME                           "Node"
#define NODE_TYPE                           "rainbowled"

#define RAINBOW_LED_DEVICE_NAME             "Rainbow LED"
#define RAINBOW_LED_DEVICE_TYPE             "esp.device.rainbow"

#define RAINBOW_LED_POWER_PARAM_NAME        "Power"
#define RAINBOW_LED_BRIGHTNESS_PARAM_NAME   "Brightness"
#define RAINBOW_LED_CYCLE_SPEED_PARAM_NAME  "Cycle Speed"
```

In `app_device_create()` the scaffold creates the device, registers the write callback, and adds all three parameters with correct types and bounds — ready to go.

## Add Component Dependencies

The hardware driver needs two ESP-IDF components. Add them to `main/idf_component.yml`:

```yaml
## IDF Component Manager Manifest File
dependencies:
  idf:
    version: ">=5.0.0"
  espressif/esp_rainmaker:
    version: ">=1.0"
  espressif/rmaker_app_network:
    version: "*"
  espressif/rmaker_app_insights:
    version: "*"
  espressif/led_strip:        # WS2812 RGB LED driver
    version: ">=2.0.0"
  espressif/button:           # BOOT button handling
    version: ">=3.0.0"
```

The Component Manager fetches these automatically on the first `idf.py build`.

## Implement app_driver_init()

The ESP32-C3-DevKitC has:
- **WS2812 RGB LED** on GPIO 8 (driven via RMT)
- **BOOT button** on GPIO 9 (active low)

Add these constants near the top of `app_devices.c`:

```c
/* ESP32-C3-DevKitC hardware */
#define LED_STRIP_GPIO      8
#define LED_STRIP_MAX_LEDS  1
#define BUTTON_GPIO         9
#define BUTTON_ACTIVE_LEVEL 0
```

`app_driver_init()` does three things:

**1. Initialise the WS2812 LED strip:**

```c
led_strip_config_t strip_cfg = {
    .strip_gpio_num   = LED_STRIP_GPIO,
    .max_leds         = LED_STRIP_MAX_LEDS,
    .led_pixel_format = LED_PIXEL_FORMAT_GRB,
    .led_model        = LED_MODEL_WS2812,
};
led_strip_rmt_config_t rmt_cfg = {
    .clk_src       = RMT_CLK_SRC_DEFAULT,
    .resolution_hz = 10 * 1000 * 1000,
};
ESP_ERROR_CHECK(led_strip_new_rmt_device(&strip_cfg, &rmt_cfg, &s_led_strip));
led_strip_clear(s_led_strip);
```

**2. Initialise the BOOT button with callbacks:**

```c
button_config_t btn_cfg = {
    .type             = BUTTON_TYPE_GPIO,
    .long_press_time  = 1000,
    .short_press_time = 50,
    .gpio_button_config = {
        .gpio_num     = BUTTON_GPIO,
        .active_level = BUTTON_ACTIVE_LEVEL,
    },
};
button_handle_t btn = iot_button_create(&btn_cfg);
iot_button_register_cb(btn, BUTTON_SINGLE_CLICK,     button_single_click_cb, NULL);
iot_button_register_cb(btn, BUTTON_LONG_PRESS_START, button_long_press_cb,   NULL);
```

**3. Start the rainbow cycling FreeRTOS task:**

```c
xTaskCreate(rainbow_task, "rainbow", 4096, NULL, 5, NULL);
```

The `rainbow_task` runs every 50 ms, increments the HSV hue by the current speed value, converts to RGB, and writes to the LED strip:

```c
static void rainbow_task(void *arg)
{
    while (1) {
        if (s_power) {
            s_hue += (float)s_speed;
            if (s_hue >= 360.0f) s_hue -= 360.0f;

            uint8_t r, g, b;
            hsv_to_rgb(s_hue, 1.0f, s_brightness / 100.0f, &r, &g, &b);
            led_strip_set_pixel(s_led_strip, 0, r, g, b);
            led_strip_refresh(s_led_strip);
        } else {
            led_strip_clear(s_led_strip);
            led_strip_refresh(s_led_strip);
        }
        vTaskDelay(pdMS_TO_TICKS(50));
    }
}
```

**Button behaviour:**

| Button action | Effect |
|---|---|
| Single click | Toggles Power on/off and reports to RainMaker |
| Long press (1 s) | Randomises Speed and Brightness, reports to RainMaker |

Any local hardware change is reported back to the cloud using `esp_rmaker_param_update_and_report()` so the phone app always stays in sync.

## Fill in the Write Callback

Replace the three `TODO` branches in `app_device_bulk_write_cb()` to apply incoming values to the runtime state variables:

```c
if (strcmp(param_name, RAINBOW_LED_POWER_PARAM_NAME) == 0) {
    s_power = val.val.b;
    ESP_LOGI(TAG, "Power: %s", s_power ? "ON" : "OFF");

} else if (strcmp(param_name, RAINBOW_LED_BRIGHTNESS_PARAM_NAME) == 0) {
    s_brightness = val.val.i;
    ESP_LOGI(TAG, "Brightness: %d", s_brightness);

} else if (strcmp(param_name, RAINBOW_LED_CYCLE_SPEED_PARAM_NAME) == 0) {
    s_speed = val.val.i;
    ESP_LOGI(TAG, "Cycle Speed: %d", s_speed);
}
```

The `rainbow_task` reads `s_power`, `s_brightness`, and `s_speed` directly, so changes take effect within the next 50 ms tick — no additional signalling required.

## Complete app_devices.c

The fully implemented file is reproduced below for reference:

```c
#include <math.h>
#include <string.h>
#include <esp_log.h>
#include <esp_random.h>
#include <esp_rmaker_core.h>
#include <esp_rmaker_standard_types.h>
#include <esp_rmaker_standard_devices.h>
#include <esp_rmaker_standard_params.h>
#include <app_network.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <led_strip.h>
#include <iot_button.h>
#include "app_devices.h"

#define NODE_NAME "Node"
#define NODE_TYPE "rainbowled"

#define RAINBOW_LED_DEVICE_NAME            "Rainbow LED"
#define RAINBOW_LED_DEVICE_TYPE            "esp.device.rainbow"
#define RAINBOW_LED_POWER_PARAM_NAME       "Power"
#define RAINBOW_LED_POWER_PARAM_TYPE       "esp.param.power"
#define RAINBOW_LED_BRIGHTNESS_PARAM_NAME  "Brightness"
#define RAINBOW_LED_BRIGHTNESS_PARAM_TYPE  "esp.param.brightness"
#define RAINBOW_LED_CYCLE_SPEED_PARAM_NAME "Cycle Speed"
#define RAINBOW_LED_CYCLE_SPEED_PARAM_TYPE "esp.param.cycle_speed"

/* ESP32-C3-DevKitC hardware */
#define LED_STRIP_GPIO      8
#define LED_STRIP_MAX_LEDS  1
#define BUTTON_GPIO         9
#define BUTTON_ACTIVE_LEVEL 0

static const char *TAG = "app_devices";

esp_rmaker_device_t *rainbow_led_device;
static led_strip_handle_t s_led_strip;

static volatile bool s_power      = true;
static volatile int  s_brightness = 30;
static volatile int  s_speed      = 5;
static float         s_hue        = 0.0f;

static void hsv_to_rgb(float h, float s, float v,
                       uint8_t *r, uint8_t *g, uint8_t *b)
{
    float c = v * s;
    float x = c * (1.0f - fabsf(fmodf(h / 60.0f, 2.0f) - 1.0f));
    float m = v - c;
    float r1, g1, b1;
    if      (h < 60)  { r1 = c; g1 = x; b1 = 0; }
    else if (h < 120) { r1 = x; g1 = c; b1 = 0; }
    else if (h < 180) { r1 = 0; g1 = c; b1 = x; }
    else if (h < 240) { r1 = 0; g1 = x; b1 = c; }
    else if (h < 300) { r1 = x; g1 = 0; b1 = c; }
    else              { r1 = c; g1 = 0; b1 = x; }
    *r = (uint8_t)((r1 + m) * 255.0f);
    *g = (uint8_t)((g1 + m) * 255.0f);
    *b = (uint8_t)((b1 + m) * 255.0f);
}

static void rainbow_task(void *arg)
{
    while (1) {
        if (s_power) {
            s_hue += (float)s_speed;
            if (s_hue >= 360.0f) s_hue -= 360.0f;
            uint8_t r, g, b;
            hsv_to_rgb(s_hue, 1.0f, s_brightness / 100.0f, &r, &g, &b);
            led_strip_set_pixel(s_led_strip, 0, r, g, b);
            led_strip_refresh(s_led_strip);
        } else {
            led_strip_clear(s_led_strip);
            led_strip_refresh(s_led_strip);
        }
        vTaskDelay(pdMS_TO_TICKS(50));
    }
}

static void report_param(const char *name, esp_rmaker_param_val_t val)
{
    if (!rainbow_led_device) return;
    esp_rmaker_param_t *p = esp_rmaker_device_get_param_by_name(rainbow_led_device, name);
    if (p) esp_rmaker_param_update_and_report(p, val);
}

static void button_single_click_cb(void *arg, void *usr_data)
{
    s_power = !s_power;
    ESP_LOGI(TAG, "Button: Power -> %s", s_power ? "ON" : "OFF");
    report_param(RAINBOW_LED_POWER_PARAM_NAME, esp_rmaker_bool(s_power));
}

static void button_long_press_cb(void *arg, void *usr_data)
{
    s_speed      = 1  + (esp_random() % 10);
    s_brightness = 10 + (esp_random() % 91);
    ESP_LOGI(TAG, "Button: Speed=%d Brightness=%d", s_speed, s_brightness);
    report_param(RAINBOW_LED_CYCLE_SPEED_PARAM_NAME, esp_rmaker_int(s_speed));
    report_param(RAINBOW_LED_BRIGHTNESS_PARAM_NAME,  esp_rmaker_int(s_brightness));
}

void app_driver_init(void)
{
    led_strip_config_t strip_cfg = {
        .strip_gpio_num   = LED_STRIP_GPIO,
        .max_leds         = LED_STRIP_MAX_LEDS,
        .led_pixel_format = LED_PIXEL_FORMAT_GRB,
        .led_model        = LED_MODEL_WS2812,
    };
    led_strip_rmt_config_t rmt_cfg = {
        .clk_src        = RMT_CLK_SRC_DEFAULT,
        .resolution_hz  = 10 * 1000 * 1000,
        .flags.with_dma = false,
    };
    ESP_ERROR_CHECK(led_strip_new_rmt_device(&strip_cfg, &rmt_cfg, &s_led_strip));
    led_strip_clear(s_led_strip);

    button_config_t btn_cfg = {
        .type             = BUTTON_TYPE_GPIO,
        .long_press_time  = 1000,
        .short_press_time = 50,
        .gpio_button_config = {
            .gpio_num     = BUTTON_GPIO,
            .active_level = BUTTON_ACTIVE_LEVEL,
        },
    };
    button_handle_t btn = iot_button_create(&btn_cfg);
    iot_button_register_cb(btn, BUTTON_SINGLE_CLICK,     button_single_click_cb, NULL);
    iot_button_register_cb(btn, BUTTON_LONG_PRESS_START, button_long_press_cb,   NULL);

    xTaskCreate(rainbow_task, "rainbow", 4096, NULL, 5, NULL);
}

esp_rmaker_node_t *app_device_create_node(esp_rmaker_config_t *config)
{
    esp_rmaker_node_t *node = esp_rmaker_node_init(config, NODE_NAME, NODE_TYPE);
    if (!node) {
        ESP_LOGE(TAG, "Could not initialise node. Aborting!!!");
        return NULL;
    }
    return node;
}

static esp_err_t app_device_bulk_write_cb(const esp_rmaker_device_t *device,
                                           const esp_rmaker_param_write_req_t write_req[],
                                           uint8_t count, void *priv_data,
                                           esp_rmaker_write_ctx_t *ctx)
{
    if (ctx) {
        ESP_LOGI(TAG, "Received write via: %s", esp_rmaker_device_cb_src_to_str(ctx->src));
    }
    for (int i = 0; i < count; i++) {
        const esp_rmaker_param_t *param = write_req[i].param;
        esp_rmaker_param_val_t    val   = write_req[i].val;
        const char *param_name = esp_rmaker_param_get_name(param);

        if (strcmp(param_name, RAINBOW_LED_POWER_PARAM_NAME) == 0) {
            s_power = val.val.b;
            ESP_LOGI(TAG, "Power: %s", s_power ? "ON" : "OFF");
        } else if (strcmp(param_name, RAINBOW_LED_BRIGHTNESS_PARAM_NAME) == 0) {
            s_brightness = val.val.i;
            ESP_LOGI(TAG, "Brightness: %d", s_brightness);
        } else if (strcmp(param_name, RAINBOW_LED_CYCLE_SPEED_PARAM_NAME) == 0) {
            s_speed = val.val.i;
            ESP_LOGI(TAG, "Cycle Speed: %d", s_speed);
        } else {
            ESP_LOGW(TAG, "Unknown param: %s", param_name);
        }
        esp_rmaker_param_update(param, val);
    }
    return ESP_OK;
}

esp_rmaker_device_t *app_device_create(esp_rmaker_node_t *node)
{
    rainbow_led_device = esp_rmaker_device_create(RAINBOW_LED_DEVICE_NAME,
                                                   RAINBOW_LED_DEVICE_TYPE, NULL);
    if (!rainbow_led_device) {
        ESP_LOGE(TAG, "Failed to create %s", RAINBOW_LED_DEVICE_NAME);
        return NULL;
    }
    esp_rmaker_device_add_bulk_cb(rainbow_led_device, app_device_bulk_write_cb, NULL);
    esp_rmaker_device_add_param(rainbow_led_device,
        esp_rmaker_power_param_create(RAINBOW_LED_POWER_PARAM_NAME, false));
    esp_rmaker_device_add_param(rainbow_led_device,
        esp_rmaker_brightness_param_create(RAINBOW_LED_BRIGHTNESS_PARAM_NAME, 30));
    esp_rmaker_param_t *speed_param = esp_rmaker_param_create(
        RAINBOW_LED_CYCLE_SPEED_PARAM_NAME, RAINBOW_LED_CYCLE_SPEED_PARAM_TYPE,
        esp_rmaker_int(5), PROP_FLAG_READ | PROP_FLAG_WRITE);
    esp_rmaker_param_add_ui_type(speed_param, ESP_RMAKER_UI_SLIDER);
    esp_rmaker_param_add_bounds(speed_param,
        esp_rmaker_int(1), esp_rmaker_int(10), esp_rmaker_int(1));
    esp_rmaker_device_add_param(rainbow_led_device, speed_param);
    esp_rmaker_node_add_device(node, rainbow_led_device);
    return rainbow_led_device;
}

esp_err_t app_device_set_mfg_data(void)
{
    return app_network_set_custom_mfg_data(MGF_DATA_DEVICE_TYPE_LIGHT,
                                           MFG_DATA_DEVICE_SUBTYPE_LIGHT);
}
```

## Next Step

> Next &rarr; **[Part 3 — Build, Flash, and Test](../part-3/)**

> Or [go back to the workshop overview](../)
