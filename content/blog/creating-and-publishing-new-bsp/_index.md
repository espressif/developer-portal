---
title: "Creating and Publishing a New BSP: A Step-by-Step Guide for Developers"
date: 2024-06-24
showAuthor: false
authors:
    - "juraj-michalek"
tags: ["Embedded Systems", "ESP32", "ESP32-C3", "Espressif", "BSP", "Contributing"]
---

## Introduction

The ESP Board Support Package (ESP-BSP) is a powerful tool that simplifies the development of applications for various ESP32-based boards. If you're interested in creating and publishing a new BSP for a third-party board, this guide will walk you through the process, from setting up your development environment to submitting your BSP to the ESP Component Registry. For this guide, we'll use the ESP32-C3-DevKit-RUST-1 as our example board.

## Prerequisites

Before you start, ensure you have the following:

- **ESP-IDF**: The official development framework for the ESP32, properly installed and sourced in your shell.
- **Git**: Version control system to manage your contributions.
- **GitHub Account**: Required for forking the repository and submitting pull requests.

## Setting Up Your Development Environment

1. **Fork the ESP-BSP Repository**:

   Go to the [ESP-BSP GitHub repository](https://github.com/espressif/esp-bsp) and fork the repository to your own GitHub account.

2. **Clone Your Fork**:

   Clone your forked repository to your local machine:

   ```bash
   git clone https://github.com/your-username/esp-bsp.git
   cd esp-bsp
   ```

3. **Set Up Pre-Commit Hooks**:

   ESP-BSP uses pre-commit hooks to ensure code quality. Set them up with the following commands:

   ```bash
   pip install pre-commit
   pre-commit install
   ```

## Developing a New BSP

In the following text we will describe a process how to create a new BSP for ESP32-C3-DevKit-RUST-1.

### 1. Creating a New BSP

Use the `idf.py create-component` command to create a new BSP component:

```bash
idf.py create-component esp32_c3_devkit_rust_1
cd components/esp32_c3_devkit_rust_1
```

### 2. Implementing the BSP

Follow the conventions described in the [BSP development guide](https://github.com/espressif/esp-bsp/blob/master/BSP_development_guide.md). Ensure your BSP includes the following:

- **Public API Header**: Include a header file with the public API, e.g., `bsp/esp32_c3_devkit_rust_1.h`.
- **Capabilities Macro**: Define the board's capabilities in the header file, similar to `SOC_CAPS_*` macros.
- **Initialization Functions**: Implement initialization functions for I2C, display, touch, etc.

Example of capabilities definition in `esp32_c3_devkit_rust_1.h`:

```c
/**************************************************************************************************
 *  BSP Capabilities
 **************************************************************************************************/

#define BSP_CAPS_DISPLAY        1
#define BSP_CAPS_TOUCH          0
#define BSP_CAPS_BUTTONS        1
#define BSP_CAPS_AUDIO          0
#define BSP_CAPS_AUDIO_SPEAKER  0
#define BSP_CAPS_AUDIO_MIC      0
#define BSP_CAPS_SDCARD         0
#define BSP_CAPS_IMU            1
```

Define the pin mappings and initialization functions based on the provided Rust example:

```c
// GPIO definitions for ESP32-C3-DevKit-RUST-1
#define GPIO_LCD_SCLK    0
#define GPIO_LCD_MOSI    6
#define GPIO_LCD_MISO    11 // Not used, but defined for completeness
#define GPIO_LCD_CS      5
#define GPIO_LCD_DC      4
#define GPIO_LCD_RESET   3
#define GPIO_LCD_BL      1

#define GPIO_I2C_SDA     10
#define GPIO_I2C_SCL     8

esp_err_t bsp_i2c_init(void)
{
    i2c_config_t conf = {
        .mode = I2C_MODE_MASTER,
        .sda_io_num = GPIO_I2C_SDA,
        .scl_io_num = GPIO_I2C_SCL,
        .sda_pullup_en = GPIO_PULLUP_ENABLE,
        .scl_pullup_en = GPIO_PULLUP_ENABLE,
        .master.clk_speed = 100000,
    };
    i2c_param_config(I2C_NUM_0, &conf);
    return i2c_driver_install(I2C_NUM_0, conf.mode, 0, 0, 0);
}

esp_err_t bsp_spi_init(void)
{
    spi_bus_config_t buscfg = {
        .miso_io_num = GPIO_LCD_MISO,
        .mosi_io_num = GPIO_LCD_MOSI,
        .sclk_io_num = GPIO_LCD_SCLK,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
    };
    spi_bus_initialize(HSPI_HOST, &buscfg, 1);
    
    spi_device_interface_config_t devcfg = {
        .clock_speed_hz = 10*1000*1000,           // Clock out at 10 MHz
        .mode = 0,                                // SPI mode 0
        .spics_io_num = GPIO_LCD_CS,              // CS pin
        .queue_size = 7,                          // We want to be able to queue 7 transactions at a time
    };
    spi_device_handle_t handle;
    return spi_bus_add_device(HSPI_HOST, &devcfg, &handle);
}

esp_err_t bsp_display_init(void)
{
    // Initialize display with the configured SPI and GPIO settings
    // Placeholder function for initializing display specific to this board
    // Implementation should match the Rust example provided
    return ESP_OK;
}
```

### 3. Adding the BSP to the ESP-BSP Repository

1. **Update the `idf_component.yml` File**:

   Include the new BSP in the `idf_component.yml` file with appropriate metadata:

   ```yaml
   name: esp32_c3_devkit_rust_1
   version: "1.0.0"
   description: "Board support package for ESP32-C3-DevKit-RUST-1"
   targets:
     - esp32c3
   ```

2. **Update the Root README.md**:

   Add your new BSP to the table of supported boards in the root `README.md` file:

   ```markdown
   | [ESP32-C3-DevKit-RUST-1](components/esp32_c3_devkit_rust_1) | ESP32-C3 | SPI display, I2C, GPIOs | <img src="docu/pics/esp32_c3_devkit_rust_1.png" width="150"> |
   ```

## Testing Your BSP

1. **Create an Example Project**:

   Develop an example project to test and demonstrate your BSP. Place the example in the `examples` directory of your BSP.

2. **Run the Example**:

   Build and flash the example project to ensure your BSP works as expected:

   ```bash
   idf.py build flash monitor
   ```

3. **Ensure Compatibility**:

   Ensure your BSP works with multiple supported IDF versions. Refer to the [CI workflow file](https://github.com/espressif/esp-bsp/blob/master/.github/workflows/build_test.yml) for the list of supported versions.

## Publishing Your BSP to the ESP Component Registry

To make your BSP available for others to use, you need to publish it to the ESP Component Registry.

### 1. Setting Up the IDF Component Manager

Ensure you have the latest version of the IDF Component Manager. You can check the version with the following command:

```bash
compote version
```

If necessary, update the IDF Component Manager as described in the [IDF Component Manager documentation](https://docs.espressif.com/projects/idf-component-manager/en/latest/).

### 2. Creating the `idf_component.yml` Manifest

Ensure your BSP includes an `idf_component.yml` file with the necessary metadata. Here’s an example:

```yaml
version: "1.0.0"
description: "Board support package for ESP32-C3-DevKit-RUST-1"
targets:
  - esp32c3
url: "https://github.com/your-username/esp32-c3-devkit-rust-1"
license: "Apache-2.0"
maintainers:
  - "Your Name <your.email@example.com>"
```

### 3. Packing and Uploading the Component

1. **Pack the Component**:

   Create a component archive and store it in the `dist` directory:

   ```bash
   compote component pack --name esp32_c3_devkit_rust_1 --version 1.0.0 --dest-dir dist
   ```

2. **Upload the Component**:

   Upload your component to the ESP Component Registry:

   ```bash
   compote component upload --namespace your_namespace --name esp32_c3_devkit_rust_1 --version 1.0.0
   ```

### 4. Verifying the Upload

Check the status of your upload to ensure it was successful:

```bash
compote component upload-status --job <job_id>
```

## Conclusion

Creating and publishing a new BSP for third-party boards like the ESP32-C3-DevKit-RUST-1 is a great way to contribute to the ESP32 community and make hardware integration easier for other developers. By following this guide, you can successfully develop and submit new BSPs, helping to expand the ecosystem of supported boards.

## Useful Links

- [ESP-BSP GitHub Repository](https://github.com/espressif/esp-bsp)
- [ESP-BSP Documentation](https://github.com/espressif/esp-bsp/blob/master/README.md)
- [ESP-IDF Installation Guide](https://docs.espressif.com/projects/esp-idf/en/release-v5.3/esp32/get-started/index.html)
- [BSP Development Guide](https://github.com/espressif/esp-bsp/blob/master/BSP_development_guide.md)
- [ESP Component Registry](https://components.espressif.com/)
- [IDF Component Manager Documentation](https://docs.espressif.com/projects/idf-component-manager/en/latest/)
