---
title: "Workshop: ESP-IDF and ESP32-C6 - Assignment 2"
date: 2024-09-30T00:00:00+01:00
lastmod: 2026-01-20
showTableOfContents: false
series: ["WS001EN"]
series_order: 3
showAuthor: false
---

## Assignment 2: Create a new project with Components

---

In this assignment, we will show how to work with **Components** and how to use them to speed up the development of your projects.

Components are similar to libraries (like those from Arduino IDE); they also contain various additional functionality that you wouldn't find in basic ESP-IDF. For example, let's mention various drivers for sensors, protocol components, or BSP, *board support package*, which will be discussed later. Some components are already a direct part of some ESP-IDF examples, but it is also possible to use external components thanks to the modular structure of ESP-IDF.

By using components, not only is project maintainability simplified, but its development is also significantly accelerated. Components also allow the same functionality to be reused across different projects.

If you want to create and publish your own component (for example for your specific sensor), we recommend that you watch the talk [DevCon23 - Developing, Publishing, and Maintaining Components for ESP-IDF](https://www.youtube.com/watch?v=D86gQ4knUnc).

{{< youtube D86gQ4knUnc >}}

You can browse components, for example, through the [ESP Registry](https://components.espressif.com) platform.

We will demonstrate the use of components on a new project, where we will write a simple application from scratch that will blink the built-in RGB LED using a component for LED strips. Later we will show how we can use a BSP (*board support package*) component for the same purpose, which was mentioned above.

### Working with components

We will use the following two components:

* Component for RGB LED (WS2812) strips, although in our case the LED "strip" will be only a single built-in LED connected to `GPIO8`.
* [Remote Control Transceiver](https://docs.espressif.com/projects/esp-idf/en/release-v5.2/esp32c6/api-reference/peripherals/rmt.html) (RMT) component, which we will use to control the data flow to the LED.

1. **Creating a new project**

A new project can be created via GUI or command line. For those who don't work much with terminal (CLI), it can be somewhat scary, but in the future it will help you, for example, in situations where you will use ESP-IDF with an IDE other than VSCode (or completely standalone). Both examples are given below.

**GUI**

Open ESP-IDF Explorer (Espressif icon in taskbar or via *View -> Open View -> ESP-IDF: Explorer*) and select **New Project Wizard** command (may be hidden in **Advanced** menu). Then proceed according to the pictures:

{{< figure
    default=true
    src="assets/wizard-1.webp"
    title="First step of creating a new project"
    caption="Creating a new project. Serial port is not important, it can be changed later."
    >}}

{{< figure
    default=true
    src="assets/wizard-2.webp"
    title="Second step of creating a new project"
    caption="In the next step we choose what template to base our project on. We choose *get-started/hello_world* and create the project."
    >}}


After creating the project, an unobtrusive window will appear in the bottom right, which will ask you whether you want to open the newly created project in a new window. Click "Yes".

**CLI**

In the ESP-IDF Explorer in the *commands* tab, select ESP-IDF Terminal, which will open at the bottom of the screen. To create a new project:

* Create and go to the folder where we want to have our project
* Create the project
* Go to it

```bash
mkdir ~/my-workshop-folder 
cd ~/my-workshop-folder 
idf.py create-project my-workshop-project
cd my-workshop-project
```

> If the `idf.py ...` commands don't work for you, make sure you're using ESP-IDF Terminal and not just a regular console.

Now we need to set the so-called **target**. This word can have multiple meanings in the context of ESP-IDF, but in our case it will always mean **the type of SoC we are using**. In our case it is ESP32-C6 chip (via Builtin USB JTAG).

In CLI there is a slight problem, as there may be a mismatch between VSCode and ESP-IDF, so it is better to set an environment variable instead of a command.

```bash
export IDF_TARGET=esp32c6
# idf.py set-target esp32c6
```

Now we are ready to add the [espressif/led_strip](https://components.espressif.com/components/espressif/led_strip/versions/2.5.3) component. As already mentioned, the component will take care of all the necessary drivers for our LED "strip" with one built-in diode.

2. **Adding a component**

**GUI**

* Open *View -> Command Palette* (Ctrl + Shift + P or ⇧ + ⌘ + P) and type *ESP-IDF: Show ESP Component Registry* in the newly opened line. Now search for **espressif/led_strip** (searching may take a few seconds when seemingly nothing happens), click on the component, select the correct version (**2.5.3**) and click *Install*.

**WARNING:** We are using an older version of the component, don't forget to select it from

{{< figure
    default=true
    src="assets/ledstrip-1.webp"
    title="Installing led_strip component 1"
    caption="Component search"
    >}}

{{< figure
    default=true
    src="assets/ledstrip-2.webp"
    title="Installing led_strip component 2"
    caption="Component installation"
    >}}

**CLI**

```bash
idf.py add-dependency "espressif/led_strip^2.5.3"
```

You may notice that a new file named **idf_component.yml** has been created in the main project directory (**main**). On the first build, the **managed_components** folder will also be created and the component will be downloaded to it if it was added via CLI. If you added the component via GUI, everything will be created even without build.

```yaml
# Contents of idf_component.yml
dependencies:
  espressif/led_strip: "^2.5.3"
  idf:
    version: ">=4.4"
```

You can also add dependent components to this file manually, without using any commands.

Now we will throw ourselves into the programming itself.

3. **Creating a function that configures the LED and RMT driver**

Let's open the file ``hello_world_main.c``. First we need to import the `led_strip.h` library...

```c
#include "led_strip.h"
```

...declare the necessary constants...

```c
// 10MHz resolution, 1 tick = 0.1us (led strip needs a high resolution)
#define LED_STRIP_RMT_RES_HZ  (10 * 1000 * 1000)
```

...and create a function skeleton for configuration:

```c
led_strip_handle_t led_strip;
void configure_led(void)
{
    // Your code goes here
}
```

You will write the following 3 steps into this function in place of the comment `Your code goes here`.

4. **LED "strip" configuration**

We use the `led_strip_config_t` structure. For **ESP32-C6-DevKit-C**, the LED is of type WS2812.

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

5. **RMT configuration**

We use the `led_strip_rmt_config_t` structure:

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

6. **Creating RMT device**

```c
led_strip_new_rmt_device(&strip_config, &rmt_config, &led_strip);
```

7. **Creating an object for the LED "strip"**

When we have the `configure_led()` function ready, we can call it in the main `app_main` function.

```c
configure_led();
```

8. **Setting colors**

To set the color, we use the `led_strip_set_pixel` function with the following parameters:
- `led_strip`: our configured LED "strip" object
- `0`: diode index in the strip (since we only have one, the index will always be 0)
- `20`: red (RED) component with values between 0 and 255
- `0`: green (GREEN) component with values between 0 and 255
- `0`: blue (BLUE) component with values between 0 and 255

```c
led_strip_set_pixel(led_strip, 0, 20, 0, 0);
```

> Try different values for R,G,B channels!

9. **Update LED "strip" values**

Just setting the pixel value is not enough; for the values set in the previous step to take effect, the entire "strip" must first be refreshed:

```c
led_strip_refresh(led_strip);
```

If we want to turn off the entire LED strip, we can use the function `led_strip_clear(led_strip);`.

10. **Building and uploading code to the board**

When our code is complete, we need to somehow get it into our board. The entire process can be divided into 4 steps:

* Determining the **target**: the specific board we are using. In the *ESP-IDF explorer* tab in the *Commands* section, select **Set Espressif Device Target (IDF_TARGET)**, choose **esp32c6** and in the subsequent menu select **ESP32-C6 chip (via builtin USB-JTAG)**.
* **Build**: building the application and creating a binary file that we will upload. In the same place as last time, click on the **Build Project** command.
* Selecting the correct **serial port** to which our board is connected. We also set the serial port using a command in *ESP-IDF Explorer*, this time using **Select Port to Use**.
* **Flash**: uploading the binary file to the board. The command of the same name will serve us for this, which can be found right next to the others. If VScode asks us about "flash method", we select "UART".

If someone accidentally selects the wrong flash method (e.g. JTAG), just manually edit `"idf.flashType":` to `"UART"` in the `.vscode/settings.json` file.

> All commands can also be invoked using *Command Palette*, which you open with the key combination Ctrl + Shift + P or ⇧ + ⌘ + P. However, the commands are sometimes named slightly differently (for example, instead of *Select Serial Port*, the command is called *ESP-IDF: Select Port to Use*). You can freely combine both approaches.

#### Complete code

Below you can find the complete and commented code for this assignment:

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

#### Expected result

The built-in LED should light up red.

### Part two: the same, but with BSP

In the previous part, we learned how to add components to a project. Now let's talk about BSP - *board support package*.

BSP is a component that allows easy configuration of peripherals (LED, button...) of some specific development board. Specifically, our **ESP32-C6-DevKit** has one button connected to **GPIO9** and one addressable LED on pin **GPIO8**. In the BSP for this specific board, these two peripherals will therefore be configured and if we use BSP, we don't have to worry about pin configuration or add any other components that would take care of the given peripherals.

The example with our kit is relatively simple for BSP, but there are also more complex development boards, for example **ESP32-S3-BOX-3**. The BSP for this kit can therefore handle all peripherals, such as displays, sensors, LEDs, but also e.g. audio codecs. Everything in one package and without any additional components.

The advantages of using BSP are for example:

- Easy initial configuration
- Code reuse across different projects with the same development kit
- Reduces the number of board configuration errors
- Ensures that all necessary dependencies are part of the project

In addition to working with BSP, we will also show how to create a project from some example that is part of a component, in our case the [espressif/esp_bsp_generic](https://components.espressif.com/components/espressif/esp_bsp_generic/) component and the example [examples/generic_button_led](https://components.espressif.com/components/espressif/esp_bsp_generic/versions/1.2.0/examples/generic_button_led?language=en). Some components also contain demonstration projects that show how to properly use such a component.

Below we will describe how to do it:

1. **Creating a new project from an example**

To create a new project from an example that is part of a component, we need to move to the ESP-IDF command line for a while. We can invoke it either as the *ESP-IDF: Open ESP-IDF Terminal* command in *Command Palette* or find the *ESP-IDF Terminal* command as a button in the *Commands* section of our *ESP-IDF Explorer*. To avoid creating a project within a project, we first move up one directory.

```bash
cd ..
idf.py create-project-from-example "espressif/esp_bsp_generic^1.2.0:generic_button_led"
```

Then we open the project in a new window (it will be in the same folder as the previous one) and **check** that the `main/idf_component.yaml` file looks as follows:

```yaml
dependencies:
  esp_bsp_generic:
    version: ^1.2.0
description: BSP Display example
```

If, for example, the BSP version doesn't match, we change it to `^1.2.0`, as shown in the example above.

2. **Setting peripherals**

Since we are using generic BSP, we still won't avoid configuration. Again we will work with LED, so we need to set that our board has one LED on pin **GPIO8** (and we will control it using RMT).

ESP-IDF uses the Kconfig language and the kconfiglib library to configure projects. We invoke the configuration menu using:
- *SDK Configuration Editor (menuconfig)* command in *ESP-IDF: Explorer*
- By searching for this command in *Command Palette* (Ctrl + Shift + P)
- In CLI using the ``idf.py menuconfig`` command, called in the project root folder.

In the configuration menu, go to `Component config` -> `Board Support Package (generic)` and set:

- **Buttons**
  - `Number of buttons in BSP` to `0`
- **LEDs**
  - `LED type` to `Addressable RGB LED`
  - `Number of LEDs in BSP` to `1`
  - `Addressable RGB LED GPIO` to `8`
  - `Addressable RGB LED backend peripheral` to `RMT`

Finally, don't forget to save everything with the **Save** button in the top right.

> The configuration menu invoked via ``idf.py menuconfig`` is controlled with arrows, you enter the menu with enter and exit it with backspace. The final exit is done with the Escape key and subsequent pressing (Y) to confirm saving.

3. **Build and flash**

Copy the code below into the `main.c` file of our BSP project:

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

Now you can build and upload the project to your development board.

> If a problem occurred during assembly, try deleting build files:
>
> `idf.py fullclean`
>
> or *Full Clean* in *ESP-IDF Explorer*

#### Extra part

If you want to try other functionality from this BSP, try running the following code. You may need to adjust the configuration and add a button.

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

Let there be light! When we can do basic tasks with ESP and IDE, we are ready to connect to WiFi too!

[Assignment 3: Connect to Wi-Fi](../assignment-3)