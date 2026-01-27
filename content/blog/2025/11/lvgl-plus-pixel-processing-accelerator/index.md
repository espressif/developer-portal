---
title: "Using the Espressif Pixel Processing Accelerator with LVGL 9.4"
date: "2025-11-23"
summary: "The Espressif Pixel Processing Accelerator integration in LVGL 9.4 brings hardware acceleration for fills, blending, and display transforms to ESP32-P4 devices, while keeping the LVGL API unchanged."
authors:
    - felipe-neves
tags: ["component","lvgl","ESP-IDF"]
---

## Introduction

LVGL 9.4 introduces experimental support for the Espressif Pixel Processing Accelerator (PPA) as a **draw unit**, allowing rendering operations to be offloaded from the CPU to dedicated hardware on ESP32-P4 devices.

This article explains:

* What the PPA is on ESP32-P4
* How LVGL models it as a draw unit
* How to enable PPA support
* Why the acceleration is fully transparent to user code

---

## What is the Pixel Processing Accelerator?

On ESP32-P4, the Pixel Processing Accelerator (PPA) is a hardware block designed to accelerate common pixel and image operations, including:

* Scale, rotate, mirror transformations
* Blending of foreground and background images
* Solid rectangle fills

In ESP-IDF, these are exposed through functions from its driver component such as:

* `ppa_do_blend()`
* `ppa_do_fill()`

LVGL 9.4 takes advantage of these operations via its draw pipeline, offloading supported tasks to the PPA when running on compatible Espressif targets.

---

## LVGL Draw Units in a Nutshell

In LVGL 9.x, rendering is decomposed into **draw tasks** processed by one or more **draw units**, which are implementations of `lv_draw_unit_t`.

Draw units can handle operations such as:

* Filling rectangles
* Blending images
* Drawing labels, arcs, lines, and more

Common draw units include:

* Software renderer
* Vendor-specific units such as the new Espressif PPA backend
* Advanced 2D Graphic accelerators.

The LVGL scheduler decides which unit handles each task, routing PPA-compatible operations to the PPA draw unit whenever possible.

---

## PPA as an LVGL Draw Unit

LVGL 9.4 includes a dedicated draw unit for Espressif PPA, implemented inside LVGL’s backend and registered alongside the software renderer when enabled.

Once the feature is active:

* LVGL keeps the normal software renderer
* A PPA draw unit is added
* Supported operations (fill, blend, scale/rotate/mirror) are routed to PPA
* Unsupported operations gracefully fall back to software

From the application’s perspective:

* No PPA-specific API calls are required
* All LVGL widget APIs remain the same
* PPA acceleration is completely transparent

---

## Enabling the LVGL PPA Draw Unit

### 1. Requirements

* Target SoC: ESP32-P4 (PPA hardware block available)
* LVGL version: 9.4 or later
* ESP-IDF version with PPA driver support (e.g., ESP-IDF 5.5.x)
* ESP-LVGL-Port component v2.6 or later.
* (Optional) ESP-BSP if running LVGL under Espressif Development Board.

### 2. LVGL Configuration

Enable PPA in LVGL via Kconfig. Add to `sdkconfig.defaults`:

```
# Enable PPA draw unit in LVGL
CONFIG_LV_USE_PPA=y

# Required alignment for draw buffers
CONFIG_LV_DRAW_BUF_ALIGN=64
```

After updating config:

```
idf.py menuconfig
idf.py build
```

Once rebuilt, LVGL automatically registers the PPA draw unit.
No application source changes are needed.

---

## Starting LVGL with Double Buffering

Espressif recommends using **full-screen double buffering** to get maximum performance, as PPA operates best on large continuous buffer regions.

Example initialization:

```c
#include "lvgl.h"
#include "bsp/esp-bsp.h"

void app_main(void)
{
    bsp_display_cfg_t cfg = {
        .lvgl_port_cfg = ESP_LVGL_PORT_INIT_CONFIG(),
        .buffer_size = BSP_LCD_H_RES * BSP_LCD_V_RES,
        .double_buffer = 1,

        .hw_cfg = {
#if CONFIG_BSP_LCD_TYPE_HDMI
#if CONFIG_BSP_LCD_HDMI_800x600_60HZ
            .hdmi_resolution = BSP_HDMI_RES_800x600,
#elif CONFIG_BSP_LCD_HDMI_1280x720_60HZ
            .hdmi_resolution = BSP_HDMI_RES_1280x720,
#elif CONFIG_BSP_LCD_HDMI_1280x800_60HZ
            .hdmi_resolution = BSP_HDMI_RES_1280x800,
#elif CONFIG_BSP_LCD_HDMI_1920x1080_30HZ
            .hdmi_resolution = BSP_HDMI_RES_1920x1080,
#endif
#else
            .hdmi_resolution = BSP_HDMI_RES_NONE,
#endif
            .dsi_bus = {
                .phy_clk_src = MIPI_DSI_PHY_CLK_SRC_DEFAULT,
                .lane_bit_rate_mbps = BSP_LCD_MIPI_DSI_LANE_BITRATE_MBPS,
            }
        },

        .flags = {
#if CONFIG_BSP_LCD_COLOR_FORMAT_RGB888
            .buff_dma = false,
#else
            .buff_dma = true,
#endif
            .buff_spiram = true,
            .sw_rotate = true,
        }
    };

    bsp_display_start_with_config(&cfg);
    bsp_display_backlight_on();

    bsp_display_lock(0);
    lv_demo_widgets();
    bsp_display_unlock();
}
```

This ensures:

* Full-resolution buffers
* DMA-capable regions when necessary
* Highest PPA efficiency

---

## Using PPA for Rotation and Mirroring (Port-Level Acceleration)

The PPA integration has two layers:

1. **LVGL PPA draw unit** — accelerates LVGL drawing
2. **Espressif LVGL port PPA** — accelerates final framebuffer rotation/mirroring before output

To enable the second layer:

```
CONFIG_LVGL_PORT_ENABLE_PPA=y
```

When active:

* LVGL sets rotation/mirror metadata
* The Espressif port applies PPA transforms to the final framebuffer
* No application code changes are needed

This layer can provide major performance gains (e.g., rotation at near-zero CPU cost).

---

## Transparency for Application Code

One of the main design goals is complete transparency:

* No need to include PPA headers
* No need to manage PPA clients or transactions
* No changes to LVGL widget code
* No special calls or pipeline management

Once enabled via configuration, LVGL and the Espressif port:

* Create the PPA draw unit
* Select when to use PPA vs software
* Optionally apply PPA rotation/mirroring before sending to the display

Your UI code remains unchanged.

---

## Verifying That PPA is Working

Use the LVGL benchmark demo:

```c
bsp_display_lock(0);
lv_demo_benchmark();
bsp_display_unlock();
```

With PPA enabled, you should observe:

* Around 30% improvement on many operations
* Up to 9× improvement in certain full-screen or fill-heavy cases

Compare FPS with and without PPA configuration.

---

## Limitations and Notes

* **Experimental**: LVGL 9.4 marks PPA as experimental
* **Operation coverage**: Best on rectangle fills; image blend benefits vary
* **Bandwidth constraints**: PSRAM/DMA bandwidth may limit gains
* **Buffer alignment**: Must set `CONFIG_LV_DRAW_BUF_ALIGN=64`
* **Best performance**: Full-screen double buffering
