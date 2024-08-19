---
title: "ESP-IDF with ESP32-C6 Workshop - Assignment 2: Create a new project with Components"
date: 2024-06-29T00:00:00+01:00
showTableOfContents: false
series: ["WS001"]
series_order: 3
showAuthor: false
---

## Assignment 2: Create a new project with Components

---

In this assignment, we will show how to use components to accelerate your development.
Components are similar to libraries, adding new features like drivers for sensors, protocols, board support package, and any other feature that is not included in ESP-IDF by default. Certain components are already part of some examples and ESP-IDF also uses the external component approach to make ESP-IDF more modular.

Using components not only makes your project easier to maintain but also improves the development speed by reusing and sharing components with different projects.

If you want to create and publish your own component, we recommend that you watch the talk [DevCon23 - Developing, Publishing, and Maintaining Components for ESP-IDF](https://www.youtube.com/watch?v=D86gQ4knUnc).

{{< youtube D86gQ4knUnc >}}

You can also find components using our [ESP Registry](https://components.espressif.com) platform.

To show how to use components, we will create a new project from scratch and add the component LED strip. Later, we will change the approach to work with the Board Support Packages (BSP).

### Hands-on with components

This hands-on guide will use a component for the RGB LED (WS2812) connected to `GPIO8` and the [Remote Control Transceiver](https://docs.espressif.com/projects/esp-idf/en/release-v5.2/esp32c6/api-reference/peripherals/rmt.html) (RMT) peripheral to control the data transfer to the addressable LEDs.

1. **Create a new project**

Create a new project in Espressif-IDE.

**Command Line Interface**

To create the project from the command line interface (CLI), you can use the following command. Make sure you have your ESP-IDF installed.

```bash
idf.py create-project my-workshop-project
cd my-workshop-project
```

Now you can set the SoC target by the following command:

```bash
idf.py set-target esp32c6
```

This command will set the target for this project and it will build for the specified target only.

The next step is to add the component [espressif/led_strip](https://components.espressif.com/components/espressif/led_strip/versions/2.5.3). This component will add all the necessary drivers for the addressable LED (board LED).

2. **Add the component**

Now we will add the component to the project.

> **Note**: Before adding the component, it is mandatory to do a project full clean, otherwise the CMake will not re-run.

```bash
idf.py add-dependency "espressif/led_strip^2.5.3"
```

You will note that a new file, **idf_component.yml** will be created inside the main folder, after adding the dependency. On the first build, the folder **managed_components** will be created and the component will be downloaded inside this folder.

```yaml
dependencies:
  espressif/led_strip: "^2.5.3"
  idf:
    version: ">=4.1.0"
```

You can also change this file manually to include dependencies to your project.

For this assignment, please follow the steps.

3. **Create a function to configure the LEDs and the RMT peripheral driver**

Include the `led_strip.h` header file.

```c
#include "led_strip.h"
```

and create the function to configure the LED.

```c
led_strip_handle_t configure_led(void)
{
    // Your code goes here
}
```

You will use this function for the following 3 steps.

4. **Configure the LED strip**

Use the `led_strip_config_t` structure to configure the LED strip. For the **ESP32-C6-DevKit-C**, the LED model is the WS2812.

```c
    led_strip_config_t strip_config = {
        // Set the GPIO8 that the LED is connected
        .strip_gpio_num = 8,
        // Set the number of connected LEDs, 1
        .max_leds = 1,
        // Set the pixel format of your LED strip
        .led_pixel_format = LED_PIXEL_FORMAT_GRB,
        // LED model
        .led_model = LED_MODEL_WS2812,
        // In some cases, the logic is inverted
        .flags.invert_out = false,
    };
```

5. **Configure the RMT driver**

Use the `led_strip_rmt_config_t` structure to configure the RMT peripheral driver.

```c
    led_strip_rmt_config_t rmt_config = {
        // Set the clock source
        .clk_src = RMT_CLK_SRC_DEFAULT,
        // Set the RMT counter clock
        .resolution_hz = LED_STRIP_RMT_RES_HZ,
        // Set the DMA feature (not supported on the ESP32-C6)
        .flags.with_dma = false,
    };
```

6. **Create the RMT device**

```c
led_strip_new_rmt_device(&strip_config, &rmt_config, &led_strip);
```

7. **Create the LED strip handle**

```c
led_strip = configure_led();
```

8. **Set the LED RGB color**

```c
led_strip_set_pixel(led_strip, 0, 20, 0, 0);
```

Where the arguments are:

- `0` is the LED number (in this case 0 because we have only one)
- `20` is the RED that could be from 0 to 255 (max brightness)
- `0` is the GREEN that could be from 0 to 255 (max brightness)
- `0` is the BLUE that could be from 0 to 255 (max brightness)

> You can try and change the RGB values to vary the color!

9. **Refresh the LED strip**

This function must be called to update the LED pixel color.

```c
led_strip_refresh(led_strip);
```

To clear the RBG LED (off), you can use the function `led_strip_clear(led_strip)`.

#### Assignment Code

Here you can find the full code for this assignment:

```c
#include <stdio.h>
#include "led_strip.h"

// 10MHz resolution, 1 tick = 0.1us (led strip needs a high resolution)
#define LED_STRIP_RMT_RES_HZ  (10 * 1000 * 1000)

led_strip_handle_t led_strip;

void configure_led(void)
{
    // LED strip general initialization, according to your led board design
    led_strip_config_t strip_config = {
        // Set the GPIO that the LED is connected
        .strip_gpio_num = 8,
        // Set the number of connected LEDs in the strip
        .max_leds = 1,
        // Set the pixel format of your LED strip
        .led_pixel_format = LED_PIXEL_FORMAT_GRB,
        // LED strip model
        .led_model = LED_MODEL_WS2812,
        // In some cases, the logic is inverted
        .flags.invert_out = false,
    };

    // LED strip backend configuration: RMT
    led_strip_rmt_config_t rmt_config = {
        // Set the clock source
        .clk_src = RMT_CLK_SRC_DEFAULT,
        // Set the RMT counter clock
        .resolution_hz = LED_STRIP_RMT_RES_HZ,
        // Set the DMA feature (not supported on the ESP32-C6)
        .flags.with_dma = false,
    };

    // LED Strip object handle
    led_strip_new_rmt_device(&strip_config, &rmt_config, &led_strip);
}

void app_main(void)
{
    configure_led();
    led_strip_set_pixel(led_strip, 0, 20, 0, 0);
    led_strip_refresh(led_strip);
}
```

#### Expected results

The LED should turn on in RED.

### Hands-on with BSP

Now you know how to add a new component to your project, we will introduce the concept of working with BSP.

The Board Support Package (BSP) is a package that describes the supported peripherals in a particular board. For example, the **ESP32-C6-DevKit** has one button connected to the **GPIO9** and one addressable LED connected to the **GPIO8**. In the BSP for this development kit, we can assume that the configuration for both peripherals will be handled by the BSP and we do not need to set the GPIOs or to add any extra component for handling the peripherals.

This development kit is quite simple for a BSP, but if we consider a more complex board, like the **ESP32-S3-BOX-3**, the BSP will handle all the peripherals, including the display, sensors, audio codecs, and LEDs for example.

Some of the advantages of using a BSP include:

- Easy initial configuration for the board features.
- Code reuse across projects with the same board.
- Reduces the board configuration mistakes.
- Ensures that all the dependencies will be included on the project.

For this hands-on guide, we will also show how to create a new project from the component example. The component to be used in this hands-on guide is [espressif/esp_bsp_generic](https://components.espressif.com/components/espressif/esp_bsp_generic/).
Some of the components includes examples that shows on how to use the component. You can create a new project based on this example following these steps:

1. **Create a new project from the example**

To create a new project from a component example, we will use the terminal and not the Espressif-IDE. This feature is not yet implemented inside the IDE.

Let's get the generic BSP [examples/generic_button_led](https://components.espressif.com/components/espressif/esp_bsp_generic/versions/1.2.0/examples/generic_button_led?language=en) and create a new project using the BSP.

**Alternative way**

If you are using the terminal, you can run the command below to create a new project from the example.

```bash
idf.py create-project-from-example "espressif/esp_bsp_generic^1.2.0:generic_button_led"
```

This command will create all the necessary files with the example code ready to be configured.

**Creating a new project**

The way to use the BSP with the Espressif-IDE is to create a blank project and add the manifest file manually.

To do that, create a new blank project for the ESP32-C6 and inside the `main` folder create the file `idf_component.yml` with the following content:

```yaml
## IDF Component Manager Manifest File
dependencies:
  espressif/esp_bsp_generic: "^1.2.0"
  ## Required IDF version
  idf:
    version: ">=4.1.0"
```

2. **Setup the peripherals**

Since we are using the generic BSP, we need to set the configuration parameters using the configuration menu.

- LED connected to the **GPIO8** via RMT (addressable)

The configuration parameters can be set in the file `sdkconfig`.

> **Note**: If the `sdkconfig` file does not exist in the project folder, you need to build the project. This file is only created after the first build.

On the SDK Configuration, go to `Component config` -> `Board Support Package (generic)`

- **Buttons**
  - Set `Number of buttons in BSP` to `0`
- **LEDs**
  - Set `LED type` to `Addressable RGB LED`
  - Set `Number of LEDs in BSP` to `1`
  - Set `Addressable RGB LED GPIO` to `8`
  - Set `Addressable RGB LED backend peripheral` to `RMT`

3. **Build and flash**

Copy this code to the `main.c` file.

```c
#include <stdio.h>
#include "bsp/esp-bsp.h"
#include "led_indicator_blink_default.h"

static led_indicator_handle_t leds[BSP_LED_NUM];

void app_main(void)
{
    ESP_ERROR_CHECK(bsp_led_indicator_create(leds, NULL, BSP_LED_NUM));
    led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x20, 0x0, 0x0));
}
```

Now you can build and flash (run) the example to your device.

> You might need to full clean your project before building if you have added the files and the component manually. For this, run:
>
> `idf.py fullclean`

#### Extra

To see the functionalities from this BSP, you can run the following code. You might need to change the configuration to add the button.

```c
#include <stdio.h>
#include "bsp/esp-bsp.h"
#include "esp_log.h"
#include "led_indicator_blink_default.h"

static const char *TAG = "example";

#if CONFIG_BSP_LEDS_NUM > 0
static int example_sel_effect = BSP_LED_BREATHE_SLOW;
static led_indicator_handle_t leds[BSP_LED_NUM];
#endif

#if CONFIG_BSP_BUTTONS_NUM > 0
static void btn_handler(void *button_handle, void *usr_data)
{
    int button_pressed = (int)usr_data;
    ESP_LOGI(TAG, "Button pressed: %d. ", button_pressed);

#if CONFIG_BSP_LEDS_NUM > 0
    led_indicator_stop(leds[0], example_sel_effect);

    if (button_pressed == 0) {
        example_sel_effect++;
        if (example_sel_effect >= BSP_LED_MAX) {
            example_sel_effect = BSP_LED_ON;
        }
    }

    ESP_LOGI(TAG, "Changed LED blink effect: %d.", example_sel_effect);
    led_indicator_start(leds[0], example_sel_effect);
#endif
}
#endif

void app_main(void)
{
#if CONFIG_BSP_BUTTONS_NUM > 0
    /* Init buttons */
    button_handle_t btns[BSP_BUTTON_NUM];
    ESP_ERROR_CHECK(bsp_iot_button_create(btns, NULL, BSP_BUTTON_NUM));
    for (int i = 0; i < BSP_BUTTON_NUM; i++) {
        ESP_ERROR_CHECK(iot_button_register_cb(btns[i], BUTTON_PRESS_DOWN, btn_handler, (void *) i));
    }
#endif

#if CONFIG_BSP_LEDS_NUM > 0
    /* Init LEDs */
    ESP_ERROR_CHECK(bsp_led_indicator_create(leds, NULL, BSP_LED_NUM));

    /* Set LED color for first LED (only for addressable RGB LEDs) */
    led_indicator_set_rgb(leds[0], SET_IRGB(0, 0x00, 0x64, 0x64));

    /*
    Start effect for each LED
    (predefined: BSP_LED_ON, BSP_LED_OFF, BSP_LED_BLINK_FAST, BSP_LED_BLINK_SLOW, BSP_LED_BREATHE_FAST, BSP_LED_BREATHE_SLOW)
    */
    led_indicator_start(leds[0], BSP_LED_BREATHE_SLOW);
#endif
}
```


## Next step

Let there be light! Now it is time to connect to Wi-Fi!

[Assignment 3: Connect to Wi-Fi](../assignment-3)
