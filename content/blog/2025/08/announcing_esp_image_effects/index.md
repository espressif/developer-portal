---
title: ESP-Image-Effects Release | Lightweight, Powerful, and Made for a Colorful World
date: 2025-08-29
showAuthor: false
featureAsset: "img/featured/featured-announcement.webp"
authors:
  - hou-haiyan
tags:
  - Multimedia
  - Image effects
  - Image scale
  - Image rotate
  - Image crop
  - Image color space
  - Image processing
summary: "Espressif's ESP_IMAGE_EFFECTS component is a powerful image processing library that can do common image processing operations such as scaling, rotation, cropping, and color space conversion. This article introduces the library, shows how to use it in processing images, and provides usage examples."
---

We are excited to announce the official release of [ESP_IMAGE_EFFECTS](https://github.com/espressif/esp-adf-libs/tree/master/esp_image_effects)) v1.0.0! ESP_IMAGE_EFFECTS is a high-performance image processing library tailored for embedded devices. It provides a unified API for various image effect modules, enabling efficient and flexible integration. With SIMD instruction set optimization and zero-copy memory design, ESP_IMAGE_EFFECTS delivers fast and lightweight image processing, making it ideal for real-time applications in smart homes, industrial vision, edge AI, and more.

---

## Overview

### What is ESP_IMAGE_EFFECTS?

ESP_IMAGE_EFFECTS (`esp_imgfx`) is a comprehensive image processing library that brings desktop-class image manipulation capabilities to embedded systems. By leveraging hardware acceleration and memory-efficient algorithms, it enables real-time image processing on resource-constrained devices without compromising performance or quality.

### Key Advantages

- **🚀 High Performance**: SIMD instruction set optimization for maximum throughput
- **💾 Memory Efficient**: Zero-copy memory design minimizes RAM usage
- **🔧 Flexible APIs**: Modular design supports various processing pipelines
- **📱 Embedded Optimized**: Designed specifically for microcontroller environments
- **🎯 Real-time Ready**: Millisecond-level response for time-critical applications

## Core Features

### Image Rotation

ESP_IMAGE_EFFECTS offers a high-performance image rotation solution that supports 1° precision for any angle rotation. It employs a memory block swapping algorithm for standard angles (90°, 180°, 270°) to achieve zero overhead processing. The use of SIMD instructions further enhances processing efficiency, making it suitable for applications like smart cameras, industrial inspection, mobile devices, and more that require real-time image rotation.

```c
// Rotate image by any angle 
esp_imgfx_rotate_cfg_t cfg = {
    .in_pixel_fmt = ESP_IMGFX_PIXEL_FMT_RGB888,
    .in_res = {.width = 1920, .height = 1080},
    .degree = 45  // Any angle from 0-360°
};
```

### Color Space Conversion

ESP_IMAGE_EFFECTS offers a comprehensive color space conversion solution, supporting over 100+ RGB/YUV formats, fully compatible with BT601/BT709/BT2020 and other mainstream color space standards. With SIMD hardware acceleration technology, it achieves high-speed color space conversion processing, meeting the strict requirements of professional image processing applications for format compatibility and processing efficiency.

```c
// Convert image to RGB565 format
esp_imgfx_convert_cfg_t cfg = {
    .in_pixel_fmt = ESP_IMGFX_PIXEL_FMT_RGB888,
    .out_pixel_fmt = ESP_IMGFX_PIXEL_FMT_RGB565,
    .in_res = {.width = 1920, .height = 1080},
};
```

###  Image Scaling

ESP_IMAGE_EFFECTS provides a high-performance image scaling solution, supporting real-time image scaling with high quality. It supports various scaling algorithms, including down-resampleing and bilinear, and can achieve high-quality image scaling with high performance. The solution is widely used in various scenarios, such as smart cameras, industrial inspection, mobile devices, and more that require real-time image scaling.

```c
// Scale image to 50% of original size
esp_imgfx_scale_cfg_t cfg = {
    .in_pixel_fmt = ESP_IMGFX_PIXEL_FMT_RGB565,
    .in_res = {.width = 1920, .height = 1080},
    .scale_res = {.width = 960, .height = 540},
    .filter = ESP_IMGFX_SCALE_FILTER_TYPE_DOWN_RESAMPLE,
};
```

### Image Cropping

ESP_IMAGE_EFFECTS provides a high-performance image cropping solution, which can extract a rectangular area from an image with high precision and high performance. The solution supports any cropping start positions and rectangular area sizes, and can achieve high-quality image cropping with high performance. The solution is widely used in various scenarios, such as smart cameras, industrial inspection, mobile devices, and more that require real-time image cropping.

```c
// Crop image to a 960x540 region starting at (320, 180)
esp_imgfx_crop_cfg_t cfg = {
    .in_pixel_fmt = ESP_IMGFX_PIXEL_FMT_RGB888,
    .in_res = {.width = 1920, .height = 1080},
    .cropped_res = {.width = 960, .height = 540},
    .x_pos = 320,
    .y_pos = 180,
};
```

## API Reference

A unified API for various image effect modules, designed to simplify development by providing a consistent and intuitive interface. It allows developers to apply and manage multiple image effects with minimal code changes, significantly reducing the learning curve.

### Core Functions

| Function Pattern | Description | Example |
|------------------|-------------|---------|
| `esp_imgfx_*_open` | Create processing handle | `esp_imgfx_rotate_open(&cfg, &handle)` |
| `esp_imgfx_*_get_cfg` | Get current configuration | `esp_imgfx_rotate_get_cfg(handle, &cfg)` |
| `esp_imgfx_*_set_cfg` | Update configuration | `esp_imgfx_rotate_set_cfg(handle, &new_cfg)` |
| `esp_imgfx_*_process` | Execute image processing | `esp_imgfx_rotate_process(handle, &in, &out)` |
| `esp_imgfx_*_close` | Release handle resources | `esp_imgfx_rotate_close(handle)` |
| `esp_imgfx_rotate_get_rotated_resolution` | Get rotated resolution, only for rotation | `esp_imgfx_rotate_get_rotated_resolution(handle, &res)` |

### Utility Functions

| Function | Description | Use Case |
|----------|-------------|----------|
| `esp_imgfx_get_bits_per_pixel` | Calculate BPP for format | Memory allocation |
| `esp_imgfx_get_image_size` | Calculate image size | Buffer management |

## Getting Started

### Basic Usage Example

```c
#include "esp_imgfx_rotate.h"

// Configure rotation parameters
esp_imgfx_rotate_cfg_t cfg = {
    .in_pixel_fmt = ESP_IMGFX_PIXEL_FMT_RGB888,
    .in_res = {.width = 1920, .height = 1080},
    .degree = 90
};

// Create handle
esp_imgfx_rotate_handle_t handle;
esp_imgfx_err_t ret = esp_imgfx_rotate_open(&cfg, &handle);
assert(ESP_IMGFX_ERR_OK == ret);

// Prepare image data
esp_imgfx_data_t in_image = {.data_len = 1920 * 1080 * 3};
esp_imgfx_data_t out_image = {.data_len = 1920 * 1080 * 3};

// Allocate aligned memory for optimal performance
assert(0 == posix_memalign((void **)&in_image.data, 128, in_image.data_len));
assert(0 == posix_memalign((void **)&out_image.data, 128, out_image.data_len));

// Process image
ret = esp_imgfx_rotate_process(handle, &in_image, &out_image);
assert(ESP_IMGFX_ERR_OK == ret);

// Cleanup
free(in_image.data);
free(out_image.data);
esp_imgfx_rotate_close(handle);
```

## Real-World Applications

### Smart Access Control System

**Pipeline**: Camera Capture → Rotation Correction → Face Cropping → AI Inference

```c
// Complete preprocessing pipeline for face recognition
// Step 1: Convert YUV420 to RGB565
esp_imgfx_color_convert_process(cc_handle, &yuv420_image, &rgb565_image);

// Step 2: Correct image orientation
esp_imgfx_rotate_process(rotate_handle, &rgb565_image, &rgb565_rotated);

// Step 3: Extract face region
esp_imgfx_crop_set_cfg(crop_handle, &face_crop_cfg);
esp_imgfx_crop_process(crop_handle, &rgb565_rotated, &face_roi);

// Step 4: Ready for AI inference

```

### Medical Image Enhancement

**Use Case**: Endoscope image detail enhancement for diagnostic assistance

```c
// Enhance specific regions for medical diagnosis
// Original: 640x480 → ROI: 200x200 → Enhanced: 800x800

// Step 1: Extract region of interest
esp_imgfx_crop_cfg_t roi_cfg;
esp_imgfx_crop_get_cfg(crop_handle, &roi_cfg);
roi_cfg.cropped_res.width = 200;
roi_cfg.cropped_res.height = 200;
roi_cfg.x_pos = 220;
roi_cfg.y_pos = 140;
esp_imgfx_crop_set_cfg(crop_handle, &roi_cfg);
esp_imgfx_crop_process(crop_handle, &endoscope_image, &roi_image);

// Step 2: Enhance detail with 4x scaling
esp_imgfx_scale_cfg_t scale_cfg;
esp_imgfx_scale_get_cfg(scale_handle, &scale_cfg);
scale_cfg.scale_res.width = 800;
scale_cfg.scale_res.height = 800;
esp_imgfx_scale_set_cfg(scale_handle, &scale_cfg);
esp_imgfx_scale_process(scale_handle, &roi_image, &enhanced_image);
```

### Multi-Display Adaptation

**Challenge**: Support various embedded display sizes (0.96" OLED to 7" industrial screens)

```c
// Dynamic scaling for different display targets
typedef struct {
    int width, height;
    const char* name;
} display_config_t;

display_config_t displays[] = {
    {128, 64, "0.96\" OLED"},
    {320, 240, "2.4\" TFT"},
    {800, 480, "7\" Industrial"}
};

// Adaptive scaling function
void adapt_to_display(esp_imgfx_data_t* src, int display_index) {
    esp_imgfx_scale_cfg_t scale_cfg;
    esp_imgfx_scale_get_cfg(scale_handle, &scale_cfg);
    scale_cfg.scale_res.width = displays[display_index].width;
    scale_cfg.scale_res.height = displays[display_index].height;
    esp_imgfx_scale_set_cfg(scale_handle, &scale_cfg);
    esp_imgfx_scale_process(scale_handle, src, &display_buffer);
}
```

## Performance Benchmarks

 refer to the [performance benchmarks](https://github.com/espressif/esp-adf-libs/blob/master/esp_image_effects/doc/PERFORMANCE_ESP32P4.md) for detailed results on processing times and resource usage.

## Resources and Support

### 📚 Development Resources

- **📖 Documentation**: [Complete API Reference](https://github.com/espressif/esp-adf-libs/blob/master/esp_image_effects/)
- **💻 Sample Projects**: In the [ESP_IMAGE_EFFECTS Component](https://components.espressif.com/components/espressif/esp_image_effects/) repo, see the files `esp_image_effects/test_apps/main/*.c`
- **📦 Component Registry**: [ESP_IMAGE_EFFECTS Component](https://components.espressif.com/components/espressif/esp_image_effects/)
- **📋 Release Notes**: [Version History & Updates](https://github.com/espressif/esp-adf-libs/blob/master/esp_image_effects/CHANGELOG.md)

### 🛠️ Technical Support

- **💬 Community Forum**: [ESP32 Developer Community](https://esp32.com/)
- **🐛 Issue Tracker**: [GitHub Issues](https://github.com/espressif/esp-adf/issues)

### 🚀 Getting Started

1. **Install Component**: `idf.py add-dependency "espressif/esp_image_effects"`
2. **Run Examples**: Check `test_apps/` directory for working examples
3. **Join Community**: Share your projects and get help from developers worldwide

## Conclusion

**Designed for intelligent vision, making every frame efficient!**

ESP_IMAGE_EFFECTS v1.0.0 represents a significant milestone in embedded image processing. By combining high performance with ease of use, we're empowering developers to create sophisticated vision applications on resource-constrained devices.

Whether you're building smart security systems, medical devices, industrial automation, or consumer electronics, ESP_IMAGE_EFFECTS provides the tools you need to process images efficiently and effectively.

**Ready to transform your vision applications?** 

ESP_IMAGE_EFFECTS looks forward to exploring the infinite possibilities of image processing with developers worldwide. Join us in shaping the future of embedded computer vision!
