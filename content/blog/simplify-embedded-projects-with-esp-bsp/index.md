---
title: "Simplify Your Embedded Projects with ESP-BSP"
date: 2024-06-18
showAuthor: false
authors:
    - "juraj-michalek"
tags: ["Embedded Systems", "ESP32", "ESP32-S3", "Espressif", "BSP"]
---

# Simplify Your Embedded Projects with ESP-BSP

## Introduction

Are you a maker or an embedded systems enthusiast looking to create applications that work seamlessly across different ESP32 development boards? Whether you’re using the [ESP-WROVER-KIT](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/hw-reference/esp32/get-started-wrover-kit.html), [M5Stack-CoreS3](https://docs.m5stack.com/en/core/CoreS3), [ESP32-S3-BOX-3](https://github.com/espressif/esp-box/blob/master/docs/hardware_overview/esp32_s3_box_3/hardware_overview_for_box_3.md), or other compatible boards, the ESP Board Support Package (ESP-BSP) makes your life easier. In this article, we’ll walk you through how to get started with ESP-BSP, enabling you to focus on your project’s functionality without worrying about hardware differences.

## What is ESP-BSP?

[ESP-BSP](https://github.com/espressif/esp-bsp) is a collection of Board Support Packages featuring Espressif’s or M5Stack development boards. The set can be extended to any board with Espressif’s chip. It provides a convenient way to start a project for a specific development board without the need to manually look for drivers and other details. By using ESP-BSP, you can:

- **Streamline Hardware Integration**: Simplify code and reduce complexity.
- **Enhance Development Speed**: Quickly set up and start working on your projects.
- **Access Standardized APIs**: Ensure consistency across your projects.

## Getting Started with ESP-BSP

The following example covers steps for building application for ESP32-S3-BOX-3 which is supported by ESP-BSP.

### Hardware Setup

Ensure you have the following hardware:

- [ESP32-S3-BOX-3](https://github.com/espressif/esp-box) development board.
- USB-C Cable for power and programming.

### Prerequisites

Before you begin, make sure you have the following:

- [ESP-IDF v5.3](https://docs.espressif.com/projects/esp-idf/en/release-v5.3/esp32/get-started/index.html): The official development framework for the ESP32, properly installed and sourced in your shell.

### Creating Project from Example

Let’s create a simple project using the `display_audio_photo` example, which is available for the ESP32-S3-BOX-3. This example showcases how to use the display, touch, and audio features.

First, let's see the whole build in Asciinema recording:
{{< asciinema key="esp-bsp-display-demo" cols="80" rows="24" poster="npt:0:08" >}}

1. **Initialize a New Project**:

   Use the `idf.py` tool to create a new project from the example:

   ```bash
   idf.py create-project-from-example "espressif/esp-box-3^1.2.0:display_audio_photo"
   cd display_audio_photo
   ```

2. **Set the Target**:

   Ensure the correct target is set for your project:

   ```bash
   idf.py set-target esp32s3
   ```

   Note: For users of ESP-IDF 5.3 or newer, it is necessary to add the following dependency with the corrected I2C driver (error message at runtime: `CONFLICT! driver_ng`):

   ```bash
   idf.py add-dependency "espressif/esp_codec_dev==1.1.0"
   ```

3. **Check the Configuration of Dependencies**:

    Check that file `main/idf_component.yml` contains dependency on BSP specific to you board.

    Configuration for ESP32-S3-BOX-3:

    ```yaml
    ## IDF Component Manager Manifest File
    dependencies:
        espressif/esp-box-3: "^1.2.0"
        esp_jpeg: "^1.0.5~2"
        esp_codec_dev:
            public: true
            version: "==1.1.0"
    ## Required IDF version
    idf:
        version: ">=5.0.0"
    ```

    Configuration for ESP32-S3-BOX:

    ```yaml
    ## IDF Component Manager Manifest File
    dependencies:
        espressif/esp-box: "^3.1.0"
        esp_jpeg: "^1.0.5~2"
        esp_codec_dev:
            public: true
            version: "==1.1.0"
    ## Required IDF version
    idf:
        version: ">=5.0.0"
    ```

    Configuration for M5Stack-CoreS3:

    ```yaml
    ## IDF Component Manager Manifest File
    dependencies:
        espressif/m5stack_core_s3: "^1.1.0"
        esp_jpeg: "^1.0.5~2"
        esp_codec_dev:
            public: true
            version: "==1.1.0"
    ## Required IDF version
    idf:
        version: ">=5.0.0"
    ```

4. **Build and Flash the Project**:

   Compile and flash your application to the ESP32-S3-BOX-3:

   ```bash
   idf.py build flash monitor
   ```

   Note: Use `Ctrl+]` to quit the monitor application.

   Or, you can try it directly with ESP Launchpad and flash precompiled binary to your ESP32-S3-BOX-3:

   <a href="https://espressif.github.io/esp-launchpad/?flashConfigURL=https://espressif.github.io/esp-bsp/config.toml&amp;app=display_audio_photo">
   <img alt="Try it with ESP Launchpad" src="https://espressif.github.io/esp-launchpad/assets/try_with_launchpad.png">
   </a>

   Note: Some models of M5Stack CoreS3 have QUAD SPI RAM, in that case please use the following command for the build, which will take into account specific settings for M5Stack CoreS3 from the file:

   ```bash
   idf.py build -DSDKCONFIG=sdkconfig.bsp.m5stack_core_s3
   ```

### Exploring the Example

Once the application is running, you’ll see the following features in action:

- **Display**: Shows images, text files, and more.
- **Touch**: Interacts with the display.
- **Audio**: Plays sound files.

Let's look at the source code of the example. Board Support Package provides API which allows to initialize a board. The application code the can be cleaner and does not need to require board specific details like pins definition.

```c
#include "esp_log.h"
#include "bsp/esp-bsp.h"
#include "app_disp_fs.h"

static const char *TAG = "example";

void app_main(void)
{
    /* Initialize and mount SPIFFS */
    bsp_spiffs_mount();

    /* Initialize I2C (for touch and audio) */
    bsp_i2c_init();

    /* Initialize display and LVGL */
    bsp_display_start();

    /* Set default display brightness */
    bsp_display_brightness_set(APP_DISP_DEFAULT_BRIGHTNESS);

    /* Add and show LVGL objects on display */
    app_disp_lvgl_show();

    /* Initialize SPI flash file system and show list of files on display */
    app_disp_fs_init();

    /* Initialize audio */
    app_audio_init();

    ESP_LOGI(TAG, "Example initialization done.");

}
```

## Conclusion

With ESP-BSP, you can quickly develop and port your applications across various ESP32 boards, saving time and effort. Whether you’re building a new project or upgrading an existing one, ESP-BSP simplifies your development process.

## Useful Links

- [Board Support Packages at Component Registry](https://components.espressif.com/components?q=Board+Support+Package)
- [ESP-BSP GitHub Repository](https://github.com/espressif/esp-bsp)
- [ESP-BSP Documentation](https://github.com/espressif/esp-bsp/blob/master/README.md)
- [ESP-BOX-3 BSP Example](https://components.espressif.com/components/espressif/esp-box-3/versions/1.2.0/examples?language=en)
- [ESP-IDF Installation Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html)
- [Wokwi - Online ESP32 Simulator](https://wokwi.com)
