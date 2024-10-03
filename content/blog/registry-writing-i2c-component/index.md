---
title: "Writing your own I2C component for the ESP-Registry"
date: 2024-10-01
showAuthor: false
authors:
  - "pedro-minatel"
tags: ["I2C", "Registry", "Component", "ESP-IDF", "Driver", "Library"]
---

When starting a new project, we often reuse code from existing components, such as libraries, to save time. This not only saves time but also makes your project easier to maintain.

In the [ESP-IDF](https://idf.espressif.com), components are widely used to make the framework more modular, making it clearer to understand and maintain. The naming convention in the ESP-IDF is to use the term "component" instead of "library" because the ESP-IDF is more like an operating system with self-contained modules that interact with the system at a high level.

## What is ESP-Registry?

To support the high number of components on the ESP-IDF, [Espressif](https://espressif.com) has developed the [ESP-Registry](https://components.espressif.com/), a platform that keeps all components available for anyone to use in a central repository. With the ESP-Registry, users can easily find and install components, use examples, and eventually create and upload their own components.

<figure style="width: 90%; margin: 0 auto; text-align: center;">
    <img
        src="./assets/cm_logo.webp"
        alt="ESP-Registry Logo"
        title="ESP-Registry Logo"
        style="width: 100%;"
    />
    <figcaption>ESP-Registry Logo</figcaption>
</figure>

Currently (Oct 2024), the Registry has **477 components**, developed by Espressif, partners, and the community.

Some examples:

- [led_strip](https://components.espressif.com/components/espressif/led_strip/): Driver designed for the addressable LEDs like WS2812.
- [ds18b20](https://components.espressif.com/components/espressif/ds18b20/): Driver for the DS18B20 temperature sensor using the 1-Wire protocol.
- [arduino-esp32](https://components.espressif.com/components/espressif/arduino-esp32): Component for the Arduino core for the ESP32 to be used inside the ESP-IDF.

## Why should I write my own component?

Right now, there is probably a developer searching for some driver, library, or anything that could help them develop their project. If you have what they are looking for, but you haven't shared it anywhere, you will not be able to know and help them. Don't forget that it could be you next time.

Besides that, making components can also help you with other projects that might use the same components, and keeping them in the Registry can save your time looking where the component was stored and how you manage the version, download, etc.

The main objective for the ESP-Registry is to keep a single platform for components, where developers across the world can search and use the shared components, however, the way the components is managed by the Component Manager, makes the use of components very easy for any developer. The components are managed in a way that you can specify the components in a `.yaml` file as a dependency for your project and the build system will download from the Registry the component automatically during the first build.

The main propose for this article is not to describe the Registry and the Component Manager. Make sure to check the other articles and related content.

> Sharing knowledge is one of the most rewarding things you can do.

Before continuing, the component we will write will be available on GitHub, so this article will be focused on GitHub as our versioning platform and you will need an account in order to publish your own component.

## Writing an I2C component

Now it's time to start with the new component. For this article we will use a I2C temperature and humidity sensor.

### The sensor: SHTC3

For this component, the [Sensirion SHTC3](https://sensirion.com/products/catalog/SHTC3) will be used. This is a I2C temperature and humidity sensor with a typical accuracy of ±2 %RH and ±0.2 °C. To know more about the specifications, please visit the [product page](https://sensirion.com/products/catalog/SHTC3).

If you don't have this sensor, you can change to any other I2C device. All the information you might need for the new sensor should be provided by the manufacturer, including the device address, registers, etc.

### The Board: ESP32-C3-DevKit-RUST-1

This is the sensor used on the [ESP32-C3-DevKit-RUST-1](https://github.com/esp-rs/esp-rust-board/tree/v1.2) and this is the board that will be used to create the component.

The ESP32-C3-DevKit-RUST-1 development board has 2 sensors connected to the I2C peripheral on the following GPIOs:

| Signal     | GPIO        |
|------------|-------------|
| SDA        | GPIO10      |
| SCL        | GPIO8       |

All the project files are available on the project GitHub.

{{< github repo="esp-rs/esp-rust-board" >}}

### The new ESP-IDF I2C driver

From the ESP-IDF version 5.2, the I2C driver has been redesigned and we recommend to use this new driver instead of the legacy. Espressif provides the [migration guide](https://docs.espressif.com/projects/esp-idf/en/release-v5.2/esp32/migration-guides/release-5.x/5.2/peripherals.html#i2c) and the [I2C peripheral documentation](https://docs.espressif.com/projects/esp-idf/en/release-v5.2/esp32/api-reference/peripherals/i2c.html) for reference.

The new features for this new driver includes:

- New initialization mode.
- Thread safety.
- The APIs were simplified and some were removed.

Please not if you are still using the legacy driver, update to the new driver since the legacy will be removed in the future.

### Creating the component

The Component Manager [documentation](https://docs.espressif.com/projects/idf-component-manager/en/latest/) is very comprehensive and you will find all the information you need there, including the [simple component](https://docs.espressif.com/projects/idf-component-manager/en/latest/guides/packaging_components.html#a-simple-esp-idf-component) structure.

To create the component, we will go through some steps:

1. Create the new component using the command line.
2. Create the component manifest file and set with the component information.
3. Set the license.
4. Write the README.md file.
5. Write the code for the sensor driver.
6. Write the example.

We assume that you already have the ESP-IDF installed on your system. If you don't, please check our article about installing the ESP-IDF.

On the Espressif DevCon23, Ivan Grokhotkov, gave a talk titled: Developing, Publishing, and Maintaining Components for ESP-IDF. You can watch this talk as an additional material for your studies.

{{< youtube D86gQ4knUnc >}}

#### Create the new component

The process will be done by the CLI (Command-line Interface) tool `idf.py`.

```bash
idf.py create-component shtc3
```

After that, the new folder should contain the following structure:

```text
.
└── shtc3
    ├── CMakeLists.txt
    ├── include
    │   └── shtc3.h
    └── shtc3.c
```

#### Create the Manifest file

The manifest file is mandatory and this is the file that the Registry will recognize it as a component. The bare-minimum for this file is described in the documentation, but we will fill with the most common important fields.

Create the `idf_component.yml` in the component root directory with this content. You can change it if you want.

```yaml
version: 1.0.0
targets:
  - esp32
  - esp32s2
  - esp32s3
  - esp32c3
  - esp32c2
  - esp32c6
  - esp32h2
  - esp32p4
description: SHTC3 Temperature and humidity sensor driver for ESP-IDF
url:
repository:
issues:
maintainers:
  - "Author Name <author@email.com>"
tags:
  - shtc3
  - sensor
  - temperature
  - humidity
  - i2c
  - driver
dependencies:
  idf : ">=5.3"
```

- **version**: This contains the component version following the version format `major.minor.patch` (0.0.0).
- **targets**: This is the list of the supported targets.
- **description**: Brief description about the component.
- **url**: URL to the component page or company page.
- **repository**: URL to the GitHub component repository ending with `.git`.
- **issues**: URL to the place you can open issues for this component.
- **maintainers**: List of the maintainers with email.
- **tags**: Tags that might be relevant for searching in the Registry page.
- **dependencies**: You can add the dependencies, like the ESP-IDF minimum version or other components.

This component will require the ESP-IDF v5.3 or higher (latest stable release in Oct 2024).

#### Set the License

Now we need to define the license file. This is a very important step for any open-source project.

#### Create the README file

#### Component code

From now on, we will create the required code for the component to get the values from the sensor using I2C peripheral. The focus for the code explanation will be more on the new I2C driver.

To avoid a very long code description, please see the full code on the **SHTC3** component repository on GitHub.

{{< github repo="pedrominatel/esp-components" >}}

The basic flow for the component side will be:

- Create the I2C device that will be attached read from the I2C bus.
  - The I2C bus will be handled by the component example or the project that will use the component.
- Read the sensor registers
  - Temperature
  - Humidity
  - ID/serial
- Set the sensor registers
  - Wake
  - Sleep
- Detach the sensor from the bus

On the `include/shtc3.h`:

```c
#include "driver/i2c_master.h"

#define SHTC3_I2C_ADDR   ((uint8_t)0x70) // I2C address of SHTC3 sensor
```

The SHTC3 sensor address is `0x70` and there is no address selection, so we can use always the same address.

Create the enumeration to hold the registers that can be read or written to the sensor.

```c
typedef enum {

} shtc3_write_register_t;

typedef enum {
    // Read temperature first with clock stretching enabled in normal mode
    SHTC3_REG_T_CSE_NM  = 0x7CA2,
    // Read humidity first with clock stretching enabled in normal mode
    SHTC3_REG_RH_CSE_NM = 0x5C24,
    // Read temperature first with clock stretching enabled in low power mode
    SHTC3_REG_T_CSE_LM  = 0x6458,
    // Read humidity first with clock stretching enabled in low power mode
    SHTC3_REG_RH_CSE_LM = 0x44DE,
    // Read temperature first with clock stretching disabled in normal mode
    SHTC3_REG_T_CSD_NM  = 0x7866,
    // Read humidity first with clock stretching disabled in normal mode
    SHTC3_REG_RH_CSD_NM = 0x58E0,
    // Read temperature first with clock stretching disabled in low power mode
    SHTC3_REG_T_CSD_LM  = 0x609C,
    // Read humidity first with clock stretching disabled in low power mode
    SHTC3_REG_RH_CSD_LM = 0x401A 
} shtc3_read_register_t;
```

As mentioned before, this project will be based on the new I2C API from ESP-IDF.

On the `shtc3.c`:

We can start by creating the function to handle the I2C device creation, that will be attached to the bus.

```c
i2c_master_dev_handle_t shtc3_device_create(i2c_master_bus_handle_t bus_handle,
    const uint16_t dev_addr, const uint32_t dev_speed)
{
    i2c_device_config_t dev_cfg = {
        .dev_addr_length = I2C_ADDR_BIT_LEN_7,
        .device_address = dev_addr,
        .scl_speed_hz = dev_speed,
    };
    i2c_master_dev_handle_t dev_handle;
    // Add device to the I2C bus
    ESP_ERROR_CHECK(i2c_master_bus_add_device(bus_handle, &dev_cfg, &dev_handle));
    return dev_handle;
}
```

In this function, the `i2c_master_bus_handle_t` will be provided and then the device will be created and attached to the bus by calling `i2c_master_bus_add_device`.

To create the device, the following settings are required:

- `dev_addr_length`: Device address length, that could it be 7 or 8 bits. Please see this information in the datasheet.
- `device_address`: Device address.
- `scl_speed_hz`: Bus clock speed. For normal mode up to 100kHz and fast mode up to 400kHz.

Once the device is attached to the bus, the `i2c_master_dev_handle_t` will be returned to be used on any read or write operation with this sensor.

To remove the device from the bus you can use the function `i2c_master_bus_rm_device`. Let's add to our component.

```c
esp_err_t shtc3_device_delete(i2c_master_dev_handle_t dev_handle)
{
    return i2c_master_bus_rm_device(dev_handle);
}
```

To read and write operations, we will use 2 functions:

- `i2c_master_transmit`: Perform a write transaction on the I2C bus.
- `i2c_master_transmit_receive`: Perform a write-read transaction on the I2C bus.

The function `i2c_master_receive` will be not used on this component. The complete list of functions can be found on the [documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/peripherals/i2c.html#functions).

On this sensor, the recommended (see datasheet) flow is:

1. Wakeup command
2. Measurement command
3. Read out command
4. Sleep command

Now let's add the register write function to wakeup and sleep:

```c
static esp_err_t shtc3_wake(i2c_master_dev_handle_t dev_handle)
{
    esp_err_t ret;
    uint16_t reg_addr = SHTC3_REG_WAKE;
    uint8_t read_reg[2] = { reg_addr >> 8, reg_addr & 0xff };
    ret = i2c_master_transmit(dev_handle, read_reg, 2, -1);
    ESP_RETURN_ON_ERROR(ret, TAG, "Failed to wake up SHTC3 sensor");
    return ret;
}
```

```c
static esp_err_t shtc3_sleep(i2c_master_dev_handle_t dev_handle)
{
    esp_err_t ret;
    uint16_t reg_addr = SHTC3_REG_SLEEP;
    uint8_t read_reg[2] = { reg_addr >> 8, reg_addr & 0xff };
    ret = i2c_master_transmit(dev_handle, read_reg, 2, -1);
    ESP_RETURN_ON_ERROR(ret, TAG, "Failed to put SHTC3 sensor to sleep");
    return ret;
}
```

To read the temperature and humidity from the sensor, now we will use the `i2c_master_transmit_receive` function.

```c
esp_err_t shtc3_get_th(i2c_master_dev_handle_t dev_handle, shtc3_register_t reg,
    float *data1, float *data2)
{
    esp_err_t ret;
    uint8_t b_read[6] = {0};
    uint16_t reg_addr = reg;
    uint8_t read_reg[2] = { reg_addr >> 8, reg_addr & 0xff };
    shtc3_wake(dev_handle);
    // Read 4 bytes of data from the sensor
    ret = i2c_master_transmit_receive(dev_handle, read_reg, 2, b_read, 6, 200);
    ESP_RETURN_ON_ERROR(ret, TAG, "Failed to read data from SHTC3 sensor");
    shtc3_sleep(dev_handle);
    // Convert the data
    *data1 = ((((b_read[0] * 256.0) + b_read[1]) * 175) / 65535.0) - 45;
    *data2 = ((((b_read[3] * 256.0) + b_read[4]) * 100) / 65535.0);
    return ret;
}
```

On this function,w e will wakeup the sensor, write and read the data (temperature and humidity) and set the sensor to sleep. The conversion from the raw values to the temperature in Celsius and humidity in %RH is also described in the sensor datasheet.

This is a very basic sensor, with no configuration or calibration registers.

#### Example for the component

Adding the examples is highly recommended. This will help developers to understand how to use the component and will let people test it easily.

To include the example, follow the steps:

1. Create the **examples** folder.

Having a component with a clear documentation and at least one example, can make your component frustration free. Developers enjoy when it just works!

### Publishing the component to the ESP-Registry

## Using the component

## Conclusion
