---
title: "Introduction to the ESP32-S31 with Vision: Assignment 7"
date: 2026-09-28
lastmod: 2026-11-04
showTableOfContents: true
series: ["ESP32-S31-VISION"]
series_order: 12
showAuthor: false
---

## Integrate local inference into a native camera pipeline

In this assignment, you will extend the BSP camera project from Assignment 6 with local face detection using [ESP-DL](https://github.com/espressif/esp-dl). Camera frames, model inference, and result rendering all remain on the ESP32-S31.

By the end, the LCD will show the live camera stream with a bounding box around each detected face.

> [!TIP]
> The commands in this assignment use the ESP-IDF CLI. As a second option, you can use [Visual Studio Code](https://code.visualstudio.com/) with the [ESP-IDF extension](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension) to select the `esp32s31` target, open menuconfig, build, flash, and monitor the project.

## Step 1: Add the ESP-DL dependencies

{{< tabs group="esp-idf-dependencies" >}}
  {{< tab label="ESP-IDF CLI" >}}

Add the face-detection component to `main/idf_component.yml`:

```yaml
dependencies:
  espressif/esp32_s31_korvo_1:
    version: "1.1.0"
  espressif/human_face_detect:
    version: "0.5.0"
```

Run reconfigure so the Component Manager downloads and registers the new dependencies:

```bash
idf.py reconfigure
```

  {{< /tab >}}
  {{< tab label="Visual Studio Code" >}}

1. Run **ESP-IDF: Show ESP Component Registry**.
2. Search for `human_face_detect`.
3. Open `espressif/human_face_detect`, select version **0.5.0**, and select **Install**.
4. Confirm that `main/idf_component.yml` contains both required components.
5. Run **ESP-IDF: Run idf.py reconfigure Task**.

  {{< /tab >}}
{{< /tabs >}}

The final component manifest must contain:

```yaml
dependencies:
  espressif/esp32_s31_korvo_1:
    version: "1.1.0"
  espressif/human_face_detect:
    version: "0.5.0"
```

The `human_face_detect` component brings in ESP-DL 3.3.x and the face model. The model is local: it is linked into the firmware as flash read-only data and does not require a network connection at runtime.

## Step 2: Load a local ESP-DL model

The face model is local because inference uses a `.espdl` file stored on the device. It is not downloaded from a server and camera frames are not uploaded for processing.

For this assignment, select **FLASH RODATA**. The Component Manager downloads the model during development, and the ESP-IDF build system links it into the application firmware. After flashing, the model is stored in the ESP32-S31-Korvo-1 module's **16 MB SPI flash**.

This is on-board storage, but it is not the ESP32-S31's internal SRAM. ESP-DL can access the model parameters from memory-mapped flash, while internal SRAM and PSRAM remain available for camera frames, model activations, and application data.

ESP-DL supports three model locations:

| Location | How it works | Advantages | Trade-offs |
|----------|--------------|------------|------------|
| Flash rodata | The model is linked into the application binary and stored in the board's SPI flash | Simplest setup; parameters can remain in memory-mapped flash; one firmware image contains everything | Updating the model requires rebuilding and flashing the application |
| Flash partition | The `.espdl` file is stored in a dedicated data partition named `human_face_det` | The model can be updated separately from the application; useful for OTA model updates | Requires a custom partition table and a separate model-flashing step |
| microSD card | ESP-DL reads an oversized `.espdl` file from a configured directory on an optional mounted card | Accommodates a model that does not fit in flash and allows replacement without rebuilding firmware | Requires a mounted card, increases startup time, and can require PSRAM for model data |

Flash rodata is the best fit for this native application because it minimizes setup and leaves the model available whenever the firmware boots. The earlier ESP-Vision assignments similarly use the root directory of the internal flash filesystem; a microSD card is reserved for models that do not fit in the available flash space.

Create `main/app_dl.h`:

```c
#pragma once

#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

esp_err_t app_dl_init(void);
void app_dl_detect_and_draw(uint8_t *rgb565, uint32_t width, uint32_t height,
                            bool run_inference);

#ifdef __cplusplus
}
#endif
```

Create `main/app_dl.cpp`:

```cpp
#include "app_dl.h"
#include <algorithm>
#include <list>
#include <new>
#include <vector>
#include "esp_log.h"
#include "human_face_detect.hpp"
#include "dl_image_draw.hpp"

static const char *TAG = "face_detect";
static HumanFaceDetect *s_detector;
static std::list<dl::detect::result_t> s_faces;

extern "C" esp_err_t app_dl_init(void)
{
    s_detector = new (std::nothrow) HumanFaceDetect();
    if (!s_detector) {
        return ESP_ERR_NO_MEM;
    }
    ESP_LOGI(TAG, "Face detector ready; model loads on first inference");
    return ESP_OK;
}

extern "C" void app_dl_detect_and_draw(uint8_t *rgb565, uint32_t width, uint32_t height,
                                       bool run_inference)
{
    if (!s_detector) {
        return;
    }

    dl::image::img_t image = {
        .data = rgb565,
        .width = static_cast<uint16_t>(width),
        .height = static_cast<uint16_t>(height),
        .pix_type = dl::image::DL_IMAGE_PIX_TYPE_RGB565LE,
    };

    if (run_inference) {
        s_faces = s_detector->run(image);
    }

    const std::vector<uint8_t> green = {0xE0, 0x07};
    for (const auto &face : s_faces) {
        // draw_hollow_rectangle() asserts that the box lies inside the image.
        int x1 = std::max(0, face.box[0]);
        int y1 = std::max(0, face.box[1]);
        int x2 = std::min(static_cast<int>(width) - 1, face.box[2]);
        int y2 = std::min(static_cast<int>(height) - 1, face.box[3]);
        if (x2 <= x1 || y2 <= y1) {
            continue;
        }
        dl::image::draw_hollow_rectangle(image, x1, y1, x2, y2, green, 3);
        if (run_inference) {
            ESP_LOGI(TAG, "face score=%.2f box=[%d,%d,%d,%d]", face.score, x1, y1, x2, y2);
        }
    }
}
```

The function receives the image that the example's PPA step prepares for the LCD. The PPA converts the output of either camera module (RGB565 from the OV3660 or YUV422 from the SC101IOT) to little-endian RGB565, and it also rotates and scales the frame. ESP-DL therefore always receives the same format, and the green box is drawn directly on the image that LVGL displays.

`draw_hollow_rectangle()` requires the box to lie inside the image, so the coordinates are clamped to the frame and empty boxes are skipped. The detection is logged only when inference runs, not every time the cached boxes are redrawn.

`HumanFaceDetect` uses the model type and storage location selected by the component's Kconfig. With flash rodata, constructing the wrapper does not copy the model into RAM. By default, the wrapper initializes the selected model lazily on the first `run()`. That call preprocesses the image, executes the quantized network, and returns bounding boxes, confidence scores, and categories. Some detector variants also return keypoints.

> [!NOTE]
> Regardless of storage location, inference still needs working memory for intermediate tensors. Storing parameters in flash avoids copying all model parameters into PSRAM, but it does not eliminate the model's activation-memory requirements.

## Step 3: Capture frames and run inference

Add `app_dl.cpp` to the sources in `main/CMakeLists.txt`:

```cmake
idf_component_register(SRCS "main.c" "app_video.c" "app_dl.cpp"
                    INCLUDE_DIRS "."
                    REQUIRES esp_driver_ppa)
```

Add the header to `main.c`:

```c
#include "app_dl.h"
```

In `camera_video_frame_operation()`, run inference after the PPA has converted and scaled the frame, just before the frame is passed to the LVGL canvas. Do not run the model on every captured frame.

The camera example is configured for 10 FPS, so a new frame is expected approximately every 100 ms. If face inference takes as long as, or longer than, that interval, processing every frame blocks the capture callback continuously. The display receives fewer updates, frames can be dropped, and interaction appears stalled.

The code below performs inference only when the frame counter is divisible by five:

```text
target inference rate = camera frame rate / frame interval
                      = 10 FPS / 5
                      = approximately 2 inferences per second
```

On the other four frames, `app_dl_detect_and_draw()` skips `s_detector->run()` and redraws the most recent results stored in `s_faces`. Consequently:

- Camera frames can continue reaching the PPA and LVGL between inference runs.
- Bounding boxes remain visible instead of disappearing on skipped frames.
- CPU and memory bandwidth are available for display processing more often.
- Detection positions can lag behind a quickly moving face for several frames.

Five is a starting value, not a universal optimum. A smaller interval updates detections more frequently but increases blocking. A larger interval improves display continuity but makes boxes react more slowly. Measure the selected model's latency and tune the interval for the required user experience.

```c
    out_buf = cam_buff[camera_buf_index];
#endif

    static uint32_t frame_count;
    app_dl_detect_and_draw(out_buf, out_w, out_h, ++frame_count % 5 == 0);

    bsp_display_lock(0);
    lv_canvas_set_buffer(camera_canvas, out_buf, out_w, out_h, lvgl_cam_rgb565_fmt);
```

Add only the two lines in the middle. The surrounding lines are the end of the example's PPA block and the start of its LVGL update.

Finally, initialize the detector in `app_main()` after the BSP starts the camera:

```c
bsp_display_start();
bsp_display_backlight_on();
bsp_camera_start(NULL);
ESP_ERROR_CHECK(app_dl_init());
```

This first implementation still runs inference synchronously in the frame callback. Frame skipping reduces how often the callback is blocked, but every inference frame still pauses capture until the model finishes. A production application should copy a frame into a PSRAM buffer and run inference in a separate task. The display task can then consume camera frames independently and overlay the latest completed result.

## Step 4: Build, flash, and test

### Make room for the firmware

The BSP example is configured for 2 MB of flash and a 1 MB application partition. With ESP-DL and the face model, the firmware is about 3 MB, so the build fails with `app partition is too small`. The ESP32-S31-Korvo-1 module has 16 MB of flash, so configure it and add a larger application partition.

Create `partitions.csv` in the project root:

```csv
# Name,   Type, SubType, Offset,  Size, Flags
nvs,      data, nvs,     0x9000,  0x6000,
phy_init, data, phy,     0xf000,  0x1000,
factory,  app,  factory, 0x10000, 0x600000,
```

Append these lines to `sdkconfig.defaults`:

```text
CONFIG_ESPTOOLPY_FLASHSIZE_16MB=y
CONFIG_PARTITION_TABLE_CUSTOM=y
CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions.csv"
```

The existing `sdkconfig` was generated before these defaults existed, so delete it and set the target again to regenerate it:

```bash
rm sdkconfig
idf.py --preview set-target esp32s31
```

In Visual Studio Code, delete `sdkconfig` and run **ESP-IDF: Set Espressif Device Target** again, or use the terminal commands above.

### Check the model settings

Check these model settings in either interface. The component's defaults already match them, but confirm them before building:

1. The default model is **MSRMNP S8 V1**, the face-detection model available for ESP32-S31.
2. The model location is **FLASH RODATA**.

{{< tabs group="esp-idf-build-flash" >}}
  {{< tab label="ESP-IDF CLI" >}}

```bash
idf.py menuconfig
```

Check the settings under **Component config → models: human_face_detect**, save, and exit. Then build, flash, and monitor:

```bash
idf.py build
idf.py -p <PORT> flash monitor
```

  {{< /tab >}}
  {{< tab label="Visual Studio Code" >}}

1. Run **ESP-IDF: SDK Configuration Editor (menuconfig)**.
2. Open **Component config → models: human_face_detect**, check the settings above, and save.
3. Connect the board through the USB Type-C **UART** port.
4. Run **ESP-IDF: Select Port to Use (COM, tty, usbserial)** and select the UART port.
5. Run **ESP-IDF: Build, Flash and Start a Monitor on Your Device**.
6. Select **UART** as the flash method.

  {{< /tab >}}
{{< /tabs >}}

Point the camera at a face. The LCD should show a green box and the terminal should print output similar to:

```text
I (4231) face_detect: face score=0.91 box=[126,48,311,267]
```

### Troubleshooting

| Symptom | Check |
|---------|-------|
| `esp32s31` is an unknown target | Install and activate ESP-IDF v6.1 or later, and pass `--preview` to `idf.py` (for example, `idf.py --preview set-target esp32s31`) because ESP32-S31 is a preview target |
| Camera device does not open | Confirm the camera module is seated and that OV3660 or SC101IOT auto-detection is enabled |
| Blank display | Check the LCD subboard connector and call `bsp_display_backlight_on()` |
| Build cannot find `human_face_detect.hpp` | Check `main/idf_component.yml`, then run `idf.py reconfigure` |
| `app partition is too small` | Complete the **Make room for the firmware** step, delete `sdkconfig`, and set the target again |
| Model does not fit | Select the smaller face model and keep it in flash rodata |
| Low frame rate | Increase the frame-skip interval or move inference to another task |

Exit the serial monitor with `Ctrl+]`.

## Complete working code

The generated `app_video.c` and `app_video.h` files remain unchanged. The `main.c` listing is the example from BSP 1.1.0 with the ESP-DL changes applied.

<details><summary>Show all changed and new project files</summary>

**`main/idf_component.yml`:**

```yaml
dependencies:
  espressif/esp32_s31_korvo_1:
    version: "1.1.0"
  espressif/human_face_detect:
    version: "0.5.0"
```

**`main/CMakeLists.txt`:**

```cmake
idf_component_register(SRCS "main.c" "app_video.c" "app_dl.cpp"
                    INCLUDE_DIRS "."
                    REQUIRES esp_driver_ppa)
```

**`partitions.csv`:**

```csv
# Name,   Type, SubType, Offset,  Size, Flags
nvs,      data, nvs,     0x9000,  0x6000,
phy_init, data, phy,     0xf000,  0x1000,
factory,  app,  factory, 0x10000, 0x600000,
```

**`sdkconfig.defaults`** (lines appended to the existing file):

```text
CONFIG_ESPTOOLPY_FLASHSIZE_16MB=y
CONFIG_PARTITION_TABLE_CUSTOM=y
CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions.csv"
```

**`main/app_dl.h`:**

```c
#pragma once

#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"

#ifdef __cplusplus
extern "C" {
#endif

esp_err_t app_dl_init(void);
void app_dl_detect_and_draw(uint8_t *rgb565, uint32_t width, uint32_t height,
                            bool run_inference);

#ifdef __cplusplus
}
#endif
```

**`main/app_dl.cpp`:**

```cpp
#include "app_dl.h"
#include <algorithm>
#include <list>
#include <new>
#include <vector>
#include "esp_log.h"
#include "human_face_detect.hpp"
#include "dl_image_draw.hpp"

static const char *TAG = "face_detect";
static HumanFaceDetect *s_detector;
static std::list<dl::detect::result_t> s_faces;

extern "C" esp_err_t app_dl_init(void)
{
    s_detector = new (std::nothrow) HumanFaceDetect();
    if (!s_detector) {
        return ESP_ERR_NO_MEM;
    }
    ESP_LOGI(TAG, "Face detector ready; model loads on first inference");
    return ESP_OK;
}

extern "C" void app_dl_detect_and_draw(uint8_t *rgb565, uint32_t width, uint32_t height,
                                       bool run_inference)
{
    if (!s_detector) {
        return;
    }

    dl::image::img_t image = {
        .data = rgb565,
        .width = static_cast<uint16_t>(width),
        .height = static_cast<uint16_t>(height),
        .pix_type = dl::image::DL_IMAGE_PIX_TYPE_RGB565LE,
    };

    if (run_inference) {
        s_faces = s_detector->run(image);
    }

    const std::vector<uint8_t> green = {0xE0, 0x07};
    for (const auto &face : s_faces) {
        // draw_hollow_rectangle() asserts that the box lies inside the image.
        int x1 = std::max(0, face.box[0]);
        int y1 = std::max(0, face.box[1]);
        int x2 = std::min(static_cast<int>(width) - 1, face.box[2]);
        int y2 = std::min(static_cast<int>(height) - 1, face.box[3]);
        if (x2 <= x1 || y2 <= y1) {
            continue;
        }
        dl::image::draw_hollow_rectangle(image, x1, y1, x2, y2, green, 3);
        if (run_inference) {
            ESP_LOGI(TAG, "face score=%.2f box=[%d,%d,%d,%d]", face.score, x1, y1, x2, y2);
        }
    }
}
```

**`main/main.c`:**

```c
/*
 * SPDX-FileCopyrightText: 2025-2026 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: CC0-1.0
 */

/**
 * @file
 * @brief BSP Camera Example
 * @details Stream camera output to display (LVGL)
 * @example https://espressif.github.io/esp-launchpad/?flashConfigURL=https://espressif.github.io/esp-bsp/config.toml&app=display_camera_video
 */

#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include "sdkconfig.h"
#include "bsp/esp-bsp.h"
#include "esp_err.h"
#include "esp_log.h"
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/videodev2.h>
#if SOC_PPA_SUPPORTED
#include "driver/ppa.h"
#endif
#include "esp_private/esp_cache_private.h"
#include "app_video.h"
#include "app_dl.h"

#define NUM_BUFS 2
#define ALIGN_UP(num, align)    (((num) + ((align) - 1)) & ~((align) - 1))

typedef struct {
    void  *start;
    size_t length;
} mmap_buf_t;

static const char *TAG = "example";
#if SOC_PPA_SUPPORTED
static ppa_client_handle_t ppa_srm_handle = NULL;
#endif
static size_t data_cache_line_size = 0;
static lv_obj_t *camera_canvas = NULL;
static uint8_t *cam_buff[NUM_BUFS];
static uint32_t cam_buff_size = 0;
static lv_color_format_t lvgl_cam_rgb565_fmt;
static bool camera_first_frame_received = false;
#if SOC_PPA_SUPPORTED
static ppa_srm_color_mode_t camera_input_color_mode = PPA_SRM_COLOR_MODE_RGB565;
static bool camera_input_byte_swap = false;
static int camera_rotation = BSP_CAMERA_ROTATION;
#endif

#if !SOC_PPA_SUPPORTED
static lv_color_format_t lvgl_rgb565_fmt_from_v4l2(uint32_t pixelformat)
{
    if (pixelformat == V4L2_PIX_FMT_RGB565X) {
        return LV_COLOR_FORMAT_RGB565_SWAPPED;
    }
    if (pixelformat == V4L2_PIX_FMT_RGB565) {
        return LV_COLOR_FORMAT_RGB565;
    }
    ESP_LOGW(TAG, "Unexpected RGB565 pixel format, using LV_COLOR_FORMAT_RGB565");
    return LV_COLOR_FORMAT_RGB565;
}
#endif

#if SOC_PPA_SUPPORTED
static void app_ppa_init(void)
{
    /* Initialize PPA */
    ppa_client_config_t ppa_srm_config = {
        .oper_type = PPA_OPERATION_SRM,
    };

    esp_err_t ret = ppa_register_client(&ppa_srm_config, &ppa_srm_handle);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to register PPA client: 0x%x", ret);
    }
}

static esp_err_t app_image_process_scale_crop(
    uint8_t *in_buf, uint32_t in_width, uint32_t in_height,
    uint8_t *out_buf, uint32_t out_width, uint32_t out_height, size_t out_buf_size,
    ppa_srm_rotation_angle_t rotation_angle)
{
    float scale_x = (float)out_width / in_width;
    float scale_y = (float)out_height / in_height;

    if (rotation_angle == PPA_SRM_ROTATION_ANGLE_90 || rotation_angle == PPA_SRM_ROTATION_ANGLE_270) {
        scale_x = (float)out_height / in_width;
        scale_y = (float)out_width / in_height;
    }

    ppa_srm_oper_config_t srm_config = {
        .in.buffer = in_buf,
        .in.pic_w = in_width,
        .in.pic_h = in_height,
        .in.block_w = in_width,
        .in.block_h = in_height,
        .in.block_offset_x = 0,
        .in.block_offset_y = 0,
        .in.srm_cm = camera_input_color_mode,
        .in.yuv_range = PPA_COLOR_RANGE_FULL,
        .in.yuv_std = PPA_COLOR_CONV_STD_RGB_YUV_BT601,
        .out.buffer = out_buf,
        .out.buffer_size = out_buf_size,
        .out.pic_w = out_width,
        .out.pic_h = out_height,
        .out.block_offset_x = 0,
        .out.block_offset_y = 0,
        .out.srm_cm = PPA_SRM_COLOR_MODE_RGB565,
        .rotation_angle = rotation_angle,
        .scale_x = scale_x,
        .scale_y = scale_y,
        .rgb_swap = 0,
        .byte_swap = camera_input_byte_swap,
        .mode = PPA_TRANS_MODE_BLOCKING,
    };

    return ppa_do_scale_rotate_mirror(ppa_srm_handle, &srm_config);
}

static void calc_aspect_fit(
    uint32_t src_w, uint32_t src_h,
    uint32_t dst_w, uint32_t dst_h,
    uint32_t *out_w, uint32_t *out_h)
{
    float src_aspect = (float)src_w / src_h;
    float dst_aspect = (float)dst_w / dst_h;

    if (src_aspect > dst_aspect) {
        *out_w = dst_w;
        *out_h = dst_w / src_aspect;
    } else {
        *out_h = dst_h;
        *out_w = dst_h * src_aspect;
    }
}
#endif
static void camera_video_frame_operation(uint8_t *camera_buf, uint8_t camera_buf_index, uint32_t camera_buf_hes,
        uint32_t camera_buf_ves, size_t camera_buf_len)
{
    uint32_t out_w = camera_buf_hes;
    uint32_t out_h = camera_buf_ves ;
    uint8_t *out_buf = camera_buf;
    if (!camera_first_frame_received) {
        ESP_LOGI(TAG, "First camera frame received: %" PRIu32 "x%" PRIu32 ", %zu bytes",
                 camera_buf_hes, camera_buf_ves, camera_buf_len);
        camera_first_frame_received = true;
    }
#if SOC_PPA_SUPPORTED
    ppa_srm_rotation_angle_t rotation = PPA_SRM_ROTATION_ANGLE_0;

    switch (camera_rotation) {
    case 0:
        rotation = PPA_SRM_ROTATION_ANGLE_0;
        break;
    case 90:
        rotation = PPA_SRM_ROTATION_ANGLE_90;
        break;
    case 180:
        rotation = PPA_SRM_ROTATION_ANGLE_180;
        break;
    case 270:
        rotation = PPA_SRM_ROTATION_ANGLE_270;
        break;
    }

    /* Get size of camera for screen (by aspect ratio)  */
    if (camera_rotation == 90 || camera_rotation == 270) {
        calc_aspect_fit(camera_buf_ves, camera_buf_hes, BSP_LCD_H_RES, BSP_LCD_V_RES, &out_w, &out_h);
    } else {
        calc_aspect_fit(camera_buf_hes, camera_buf_ves, BSP_LCD_H_RES, BSP_LCD_V_RES, &out_w, &out_h);
    }

    /* Scale camera picture for the screen + rotation */
    esp_err_t ret = app_image_process_scale_crop(
                        camera_buf, camera_buf_hes, camera_buf_ves,
                        cam_buff[camera_buf_index], out_w, out_h, cam_buff_size,
                        rotation
                    );
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "PPA image processing failed: %s", esp_err_to_name(ret));
        return;
    }
    out_buf = cam_buff[camera_buf_index];
#endif

    static uint32_t frame_count;
    app_dl_detect_and_draw(out_buf, out_w, out_h, ++frame_count % 5 == 0);

    bsp_display_lock(0);
    lv_canvas_set_buffer(camera_canvas, out_buf, out_w, out_h, lvgl_cam_rgb565_fmt);
    lv_obj_center(camera_canvas);
    lv_obj_invalidate(camera_canvas);
    bsp_display_unlock();
}

void app_main(void)
{
    esp_err_t ret = ESP_OK;

    bsp_display_start();
    bsp_display_backlight_on(); // Set display brightness to 100%

    /* Initialize Camera */
    bsp_camera_start(NULL);
    ESP_ERROR_CHECK(app_dl_init());

#if SOC_PPA_SUPPORTED
    /* Initialize PPA for scaling */
    app_ppa_init();
#endif

    /* Get cache alignment */
    ret = esp_cache_get_alignment(MALLOC_CAP_SPIRAM, &data_cache_line_size);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Get cache alignment failed: 0x%x", ret);
        return;
    }

    /* Allocate canvas buffers */
    cam_buff_size = ALIGN_UP(BSP_LCD_H_RES * BSP_LCD_V_RES * 2, data_cache_line_size);
    for (int i = 0; i < NUM_BUFS; i++) {
        cam_buff[i] = heap_caps_aligned_calloc(data_cache_line_size, 1, cam_buff_size, MALLOC_CAP_SPIRAM);
        if (cam_buff[i] == NULL) {
            ESP_LOGE(TAG, "Failed to allocate camera buffer %d", i);
            return;
        }
    }

    /* Open video first: pixel format comes from menuconfig / driver (VIDIOC_G_FMT). */
    int fd = app_video_open(BSP_CAMERA_DEVICE, APP_VIDEO_FMT_DRIVER_DEFAULT);
    if (fd < 0) {
        ESP_LOGE(TAG, "Failed to open video device");
        ESP_LOGW(TAG, "Please, try to select another camera sensor in menuconfig.");
        return;
    }
    uint32_t camera_pixelformat = app_video_get_pixelformat();
#if SOC_PPA_SUPPORTED
    if (camera_pixelformat == V4L2_PIX_FMT_UYVY) {
        camera_input_color_mode = PPA_SRM_COLOR_MODE_YUV422_UYVY;
        camera_input_byte_swap = false;
        camera_rotation = 0;
    } else if (camera_pixelformat == V4L2_PIX_FMT_RGB565X) {
        camera_input_color_mode = PPA_SRM_COLOR_MODE_RGB565;
        camera_input_byte_swap = true;
        camera_rotation = BSP_CAMERA_ROTATION;
    } else if (camera_pixelformat == V4L2_PIX_FMT_RGB565) {
        camera_input_color_mode = PPA_SRM_COLOR_MODE_RGB565;
        camera_input_byte_swap = false;
        camera_rotation = BSP_CAMERA_ROTATION;
    } else {
        ESP_LOGW(TAG, "Unsupported camera pixel format for PPA, treating as RGB565");
        camera_input_color_mode = PPA_SRM_COLOR_MODE_RGB565;
        camera_input_byte_swap = false;
        camera_rotation = BSP_CAMERA_ROTATION;
    }
    lvgl_cam_rgb565_fmt = LV_COLOR_FORMAT_RGB565;
#else
    lvgl_cam_rgb565_fmt = lvgl_rgb565_fmt_from_v4l2(camera_pixelformat);
#endif

    /* Create LVGL canvas for camera image */
    bsp_display_lock(0);
    camera_canvas = lv_canvas_create(lv_scr_act());
    lv_canvas_set_buffer(camera_canvas, cam_buff[0], BSP_LCD_H_RES, BSP_LCD_V_RES, lvgl_cam_rgb565_fmt);
    assert(camera_canvas);
    lv_obj_center(camera_canvas);
    bsp_display_unlock();

    /* Initialize video capture device */
    ret = app_video_set_bufs(fd, NUM_BUFS, NULL);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to set video buffers: 0x%x", ret);
        return;
    }

    /* Register frame process callback */
    ret = app_video_register_frame_operation_cb(camera_video_frame_operation);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to register frame operation callback: 0x%x", ret);
        return;
    }

    /* Start video stream task */
    ret = app_video_stream_task_start(fd, 0);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to start video stream task: 0x%x", ret);
        return;
    }

    ESP_LOGI(TAG, "Camera example running.");
}
```

</details>

## What you will see

After the application starts:

- The 4.3-inch LCD shows the live stream from the installed OV3660 or SC101IOT camera.
- A green bounding box appears around each detected face.
- The box remains visible between inference frames by reusing the latest detection result.
- The serial monitor reports each detection's confidence score and bounding-box coordinates.
- A moving face may briefly move ahead of its box because inference runs every fifth camera frame.

When no face is detected, the display continues showing the live camera stream without a bounding box.

## What you learned

In this assignment, you:

- Added the ESP-DL face-detection component to an ESP-IDF project
- Loaded a model locally from flash and ran inference without a cloud service
- Drew detection results on frames before displaying them

## Next step

[Conclusion](../conclusion)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-with-vision/)
