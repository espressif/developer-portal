---
title: "Using ESP BSP with DevKits"
date: 2024-09-17
showAuthor: false
authors:
    - "vilem-zavodny"
tags: ["Embedded Systems", "ESP32", "ESP32-S2", "ESP32-S3", "ESP32-C2", "Espressif", "BSP", "DevKit"]
---

## Introduction

The BSP (Board Support Package) from Espressif is ready to use package for selected boards (usually for Espressif's and M5Stack boards). This package contains main initialization functions for features, which the board contains. For example **display** and **touch** initialization, **file system** initialization, **audio** if available, **LEDs** and **buttons**. **This is the easy way, how to start developing with your board.** Except initialization functions, there are examples for selected board too.

More about using common BSP, you can read [here](https://developer.espressif.com/blog/simplify-embedded-projects-with-esp-bsp/)

> Mainly, the BSP was only for boards with display or audio. Now, you can use it for any devkit!

## Generic and DevKit BSP

Classic DevKits usually contains only LEDs and buttons. There isn't any BSP for specific DevKit, there are special BSPSs [esp_bsp_generic](https://components.espressif.com/components/espressif/esp_bsp_generic) and [esp_bsp_devkit](https://components.espressif.com/components/espressif/esp_bsp_devkit). These BPSs can be set by menuconfig for any Espressif's DevKit. Differences between `esp_bsp_generic` and `esp_bsp_devkit` are in table below.

|         esp_bsp_generic                           |          esp_bsp_devkit                           |
| :------------------------------------------------ | :------------------------------------------------ |
| :heavy_check_mark: Up to 5 buttons                | :heavy_check_mark: Up to 5 buttons                |
| :heavy_check_mark: Up to 5 GPIO LEDs              | :heavy_check_mark: Up to 5 GPIO LEDs              |
| :heavy_check_mark: One RGB GPIO LED               | :heavy_check_mark: One RGB GPIO LED               |
| :heavy_check_mark: Unlimited addressable RGB LEDs | :heavy_check_mark: Unlimited addressable RGB LEDs |
| :heavy_check_mark: uSD File System                | :heavy_check_mark: uSD File System                |
| :heavy_check_mark: SPIFFS File System             | :heavy_check_mark: SPIFFS File System             |
|                                                   |                                                   |
| :heavy_check_mark: LVGL ready                     | :x: LVGL ready                                    |
| :heavy_check_mark: SPI LCD Display                | :x: SPI LCD Display                               |
| :heavy_check_mark: I2C LCD Touch                  | :x: I2C LCD Touch                                 |

### DevKit BSP

Basic BSP for DevKits is `esp_bsp_devkit` and there can be set only LEDs, buttons and file system.

Settings in `menuconfig`:
- Buttons
    - Count (maximum 5)
    - Each button can be type ADC or GPIO
- LEDs
    - Type (GPIO, RGB GPIO, Addressable RGB)
- SPIFFS - Virtual File System
- uSD card - Virtual File System

> This BSP can emulate any Espressif's DevKit.

### Generic BSP

Generic BSP `esp_bsp_generic` can set all same as `esp_bsp_devkit` plus selected LCD and touch.

Settings in `menuconfig`:
- Buttons
    - Count (maximum 5)
    - Each button can be type ADC or GPIO
- LEDs
    - Type (GPIO, RGB GPIO, Addressable RGB)
- Display
    - Connection (only SPI is supported)
    - Driver (ST7789, ILI9341, GC9A01)
- Display Touch
    - Connection (only I2C is supported)
    - Driver (TT21100, GT1151, GT911, CST816S, FT5X06)
- SPIFFS - Virtual File System
- uSD card - Virtual File System

> This BSP can emulate simple developer boards with SPI LCD display.

## Example and preconfigured settings

Mentioned BSPs have one very simple example with one button and one LED, which is included in component or you can find it in [GitHub](https://github.com/espressif/esp-bsp/tree/master/examples/generic_button_led). Example shows breathing LED and you can change breathing/blinking effect by button click.

This example contains preconfigured settings for these DevKits:
- esp32_c2_devkitm v1
- esp32_devkitc v4
- esp32_s2_devkitm v1
- esp32_s3_devkitc v1
- esp32_s3_devkitc v1.1

## Conclusion

BSP is ready to start for your projects. It is maintanced by Espressif and made for the best performance of your projects. If you cannot find your board, you can make own BSP very easilly or use Generic/DevKit BSP for simple boards. Start you developping with BSP!