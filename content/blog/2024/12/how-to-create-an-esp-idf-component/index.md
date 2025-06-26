---
title: "How to create an ESP-IDF component"
date: 2024-12-02
showAuthor: false
authors:
  - "pedro-minatel"
tags: ["I2C", "Registry", "Component", "ESP-IDF", "Driver", "Library"]
---

Using a monolithic architecture to develop complex applications tightly integrated with all the business logic, peripheral drivers, protocols, cloud connectivity, and so on, might sound like a nightmare. Yet, this is common in embedded systems, because it helps keep the resource overhead to the minimum. Inevitably, such approach makes collaborative development, maintenance, and reuse of code challenging to say the least.

These days the resources in embedded systems are not as limited as before, which makes the use of modular architecture more reasonable. This is exactly what ESP-IDF offers. The self-contained modules that implement most of the system functions are called *ESP-IDF components*.

There are two types of ESP-IDF components: *built-in components* and *project components*. Built-in components are part of the system whose APIs can be called directly from your application. Project components can be added to your project according to your needs in order to extend the ESP-IDF functionality.

You can add the project components from the ESP component registry, from third-party sources, or you can choose to create your own components. This article covers the project components you can create yourself and add to your project.


## Conceiving the component

Frequently, placing self-contained parts of code in a separate component not only helps to keep the application code cleaner, but also simplifies development and maintenance. To get started with the component development process, we need to understand the basic structure and how the component will interact with the application.

As covered in the article What is the ESP Component Registry, a component can be either created directly in the application or in a separated project and then added to the application.

{{< article link="/blog/2024/10/what-is-the-esp-registry/" >}}

When choosing whether to create a component in a separate project, consider if you plan to share the component with other applications. If yes, the best approach is to create the component in a new project that will contain just the component and examples if needed.

{{< alert >}}
This article will not cover how to publish the component in the ESP Component Registry. It will be covered in the next article of this series.
{{< /alert >}}

For this tutorial, we will create an example component that simplifies communication with an I2C device. This component will be a driver for a sensor and can be used as a starting point for any other component.

To simplify hardware setup, we chose the existing [ESP32-C3-DevKit-RUST-1](https://github.com/esp-rs/esp-rust-board/tree/v1.2) development board that integrates the SHTC3 I2C sensor. This sensor is an I2C temperature and humidity sensor with a typical accuracy of ±2 %RH and ±0.2 °C. You can find its specification on the official [product page](https://sensirion.com/products/catalog/SHTC3).

To be precise, the ESP32-C3-DevKit-RUST-1 development board integrates two sensors connected to the I2C peripheral on the following GPIOs:

| Signal     | GPIO        |
|------------|-------------|
| SDA        | GPIO10      |
| SCL        | GPIO8       |

All the project files for this board are available on GitHub.

{{< github repo="esp-rs/esp-rust-board" >}}

---

{{< alert >}}
If you don't have the proposed hardware, you can choose any other I2C device. All the information you might need should be provided by the manufacturer, including the device address, registers, etc.
{{< /alert >}}

## Creating the component

To create the component, we will go through some steps:

1. Create a new project (skip this step if you already have one).
2. Add a new component inside the project.
3. Write the component code.
4. Test the component

{{< alert >}}
We assume that you already have the ESP-IDF version 5.2 or higher installed on your system.
{{< /alert >}}

### Create a new project

To create a new component, we will use a project as the starting point. This project will be used to develop and test the component. However, you can also create the component as a stand-alone without using a project.

On the CLI, create a new project named `my_project_with_components` using the command:

```bash
idf.py create-project my_project_with_components
```

Now inside the `my_project_with_components` folder, let's test the build for the ESP32-C3 (this is the SoC we are using in the example below). However, you can use any other SoC.

```bash
cd my_project_with_components
idf.py set-target esp32c3
idf.py build
```

If the build finished successfully, now it's time to create the component.

### Add a new component

The component can be created manually, however, the recommended way is to use the ESP-IDF `idf.py` tool with the `create-component` command to create all the basic component skeleton.

It is recommended that the components be stored in the folder `components` in the root of the project. To create such folder and the basic component skeleton for our `shtc3` component project, we will use the following convenience command (notice the use of `-C components` to create the folder):

```bash
idf.py create-component -C components shtc3
```

As a result, the new folder should contain the following structure:

```text
.
└── components
    └── shtc3
        ├── CMakeLists.txt
        ├── include
        │   └── shtc3.h
        └── shtc3.c
```

Now we have created the component structure, including all the required files, you can populate the component with your own code. To illustrate this process, we will walk through the process for creating the I2C sensor SHTC3.

### Write the component code

We will now create the required code for the component to get the values from the sensor using I2C peripheral. The focus for the code explanation will be more on the new I2C driver `driver/i2c_master.h`.

To avoid a very long code description, please see the full code on the **SHTC3** component [repository on GitHub](https://github.com/pedrominatel/esp-components/tree/main/shtc3).

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
// SHTC3 register addresses write only
typedef enum {
    SHTC3_REG_READ_ID       = 0xEFC8, // Read ID register
    SHTC3_REG_WAKE          = 0x3517, // Wake up sensor
    SHTC3_REG_SLEEP         = 0xB098, // Put sensor to sleep
    SHTC3_REG_SOFT_RESET    = 0x805D  // Soft reset
} shtc3_register_w_t;

// SHTC3 register addresses read-write
typedef enum {
    // Temperature first with clock stretching enabled in normal mode
    SHTC3_REG_T_CSE_NM  = 0x7CA2,
    // Humidity first with clock stretching enabled in normal mode
    SHTC3_REG_RH_CSE_NM = 0x5C24,
    // Temperature first with clock stretching enabled in low power mode
    SHTC3_REG_T_CSE_LM  = 0x6458,
    // Humidity first with clock stretching enabled in low power mode
    SHTC3_REG_RH_CSE_LM = 0x44DE,
    // Temperature first with clock stretching disabled in normal mode
    SHTC3_REG_T_CSD_NM  = 0x7866,
    // Humidity first with clock stretching disabled in normal mode
    SHTC3_REG_RH_CSD_NM = 0x58E0,
    // Temperature first with clock stretching disabled in low power mode
    SHTC3_REG_T_CSD_LM  = 0x609C,
    // Humidity first with clock stretching disabled in low power mode
    SHTC3_REG_RH_CSD_LM = 0x401A
} shtc3_register_rw_t;
```

As mentioned before, this project will be based on the new I2C API from ESP-IDF.

Add the `REQUIRES "driver"` to the component `CMakeLists.txt` located inside the component folder `shtc3`.

```text
idf_component_register(
    SRCS "shtc3.c"
    INCLUDE_DIRS "include"
    REQUIRES "driver"
)
```

On the `shtc3.c` file:

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
    shtc3_register_w_t reg_addr = SHTC3_REG_WAKE;
    uint8_t read_reg[2] = { reg_addr >> 8, reg_addr & 0xff };
    ret = i2c_master_transmit(dev_handle, read_reg, 2, -1);
    ESP_RETURN_ON_ERROR(ret, TAG, "Failed to wake up SHTC3 sensor");
    return ret;
}
```

Sleep:

```c
static esp_err_t shtc3_sleep(i2c_master_dev_handle_t dev_handle)
{
    esp_err_t ret;
    shtc3_register_w_t reg_addr = SHTC3_REG_SLEEP;
    uint8_t read_reg[2] = { reg_addr >> 8, reg_addr & 0xff };
    ret = i2c_master_transmit(dev_handle, read_reg, 2, -1);
    ESP_RETURN_ON_ERROR(ret, TAG, "Failed to put SHTC3 sensor to sleep"); 
    return ret;
}
```

To read the temperature and humidity from the sensor, now we will use the `i2c_master_transmit_receive` function.

```c
 esp_err_t shtc3_get_th(i2c_master_dev_handle_t dev_handle,
          shtc3_register_rw_t reg,
          float *data1,
          float *data2)
{
    esp_err_t ret;
    uint8_t b_read[6] = {0};
    uint8_t read_reg[2] = { reg >> 8, reg & 0xff };

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

On this function, we will wakeup the sensor, write and read the data (temperature and humidity) and set the sensor to sleep. The conversion from the raw values to the temperature in Celsius and humidity in %RH is also described in the sensor datasheet.

The CRC for the temperature and humidity will be not considered for this example. If you need to implement the CRC, please see the information provided by the manufacturer.

This is a very basic sensor, with no configuration or calibration registers.

### Test the component


To test the component, let's go back to the project we have created before or the project you are using for creating this component.

For testing, the application will do:

- Initialize the I2C bus.
- Create the sensor I2C device.
- Probe the I2C bus and check the sensor presence.
- Get the sensor ID.
- Start a new task to read the sensor every 1000 ms (1 sec).

On the `app_main` function in the `example-shtc3.c` file, add the bus initialization and the device creation functions.

```c
i2c_master_bus_handle_t i2c_bus_init(uint8_t sda_io, uint8_t scl_io)
{
    i2c_master_bus_config_t i2c_bus_config = {
        .i2c_port = CONFIG_SHTC3_I2C_NUM,
        .sda_io_num = sda_io,
        .scl_io_num = scl_io,
        .clk_source = I2C_CLK_SRC_DEFAULT,
        .glitch_ignore_cnt = 7,
        .flags.enable_internal_pullup = true,
    };

    i2c_master_bus_handle_t bus_handle;
    ESP_ERROR_CHECK(i2c_new_master_bus(&i2c_bus_config, &bus_handle));
    ESP_LOGI(TAG, "I2C master bus created");
    return bus_handle;
}
```

The bus initialization is done by the function `i2c_new_master_bus` and the `bus_handle` will be used to create the device on this bus. If you have more devices, you can add to the same bus, but this will be not covered on this article.

```c
i2c_master_bus_handle_t bus_handle = i2c_bus_init(SHTC3_SDA_GPIO, SHTC3_SCL_GPIO);
shtc3_handle = shtc3_device_create(bus_handle, SHTC3_I2C_ADDR, CONFIG_SHTC3_I2C_CLK_SPEED_HZ);
```

Make sure to import the component header file.

```c
#include "shtc3.h"
```

Now to proof that the sensor is present in the I2C bus, we can probe and check it before the read and write operations. This probe has the timeout set to 200 ms.

```c
esp_err_t err = i2c_master_probe(bus_handle, SHTC3_I2C_ADDR, 200);
```

With the probe result, we can decide if the read task will be created or not.

```c
if(err == ESP_OK) {
        ESP_LOGI(TAG, "SHTC3 sensor found");
        uint8_t sensor_id[2];
        err = shtc3_get_id(shtc3_handle, sensor_id);
        ESP_LOGI(TAG, "Sensor ID: 0x%02x%02x", sensor_id[0], sensor_id[1]);

        if(err == ESP_OK) {
            ESP_LOGI(TAG, "SHTC3 ID read successfully");
            xTaskCreate(shtc3_read_task, "shtc3_read_task", 4096, NULL, 5, NULL);
        } else {
            ESP_LOGE(TAG, "Failed to read SHTC3 ID");
        }

    } else {
        ESP_LOGE(TAG, "SHTC3 sensor not found");
        shtc3_device_delete(shtc3_handle);
    }
```

Task to read the sensor.

```c
void shtc3_read_task(void *pvParameters)
{
    float temperature, humidity;
    esp_err_t err = ESP_OK;
    shtc3_register_rw_t reg = SHTC3_REG_T_CSE_NM;

    while (1) {
        err = shtc3_get_th(shtc3_handle, reg, &temperature, &humidity);
        if(err != ESP_OK) {
            ESP_LOGE(TAG, "Failed to read data from SHTC3 sensor");
        } else {
            ESP_LOGI(TAG, "Temperature: %.2f C, Humidity: %.2f %%", temperature, humidity);
        }
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
}
```

On this task, the sensor will be woken up, the readout will be read and processed, and then the sensor will return to sleep mode.

### Creating Kconfig (optional)

As a bonus, this component has a dedicated configuration menu using a `Kconfig` file.

Kconfig is a configuration system used in software projects to define and manage configuration options in a structured and hierarchical way. It's widely used in projects like the Linux kernel, Zephyr, and ESP-IDF (Espressif IoT Development Framework).

On this configuration menu, you will be able to set the I2C GPIOs (SDA and SCL), the I2C port number, and the bus frequency. This removes any hardcoded configuration from the source code.

```text
menu "Driver SHTC3 Sensor"
            
    menu "I2C"
        config SHTC3_I2C_NUM
            int "I2C peripheral index"
            default -1
            range -1 3
            help
                For auto select I2C peripheral, set to -1.

        config SHTC3_I2C_SDA
            int "I2C SDA pin"
            default 17
            range 0 55
            help
                Set the I2C SDA pin for the data signal.

        config SHTC3_I2C_SCL
            int "I2C SCL pin"
            default 18
            range 0 55
            help
                Set the I2C SCL pin for the clock signal.

        config SHTC3_I2C_CLK_SPEED_HZ
            int "I2C clock speed (Hz)"
            default 100000
            range 10000 400000
            help
                Set the I2C clock speed in Hz.
    endmenu
  
endmenu
```

The `Kconfig` file should be placed on the component root directory. To set the values, you can use the command:

```bash
idf.py menuconfig
```

To configure the I2C, go to the `Component config` -> `Driver SHTC3 Sensor` and set the `I2C SDA pin`, `I2C SCL pin`, and the `I2C clock speed (Hz)`.

## Running the application

To run the application, run the command to `flash` and `monitor` using the `idf.py`. The application will print the temperature and humidity.

```bash
idf.py flash monitor
```

### Console log output

{{< asciinema
  key="component_shtc3"
  idleTimeLimit="2"
  speed="1.5"
  cols="80"
  rows="24"
  poster="npt:0:09"
>}}

## Conclusion

In this article, we went through the basic steps of creating a component skeleton, adding it to a project, writing the code, testing it, and, finally, adding the configuration menu.

Even though creating a new component requires a few additional steps, it helps improve the project architecture and make code reusable. This is a very powerful approach not only for creating driver components, but any other code that can work in a modular fashion.
In the next article, we will show how this component can be published to the [ESP Component Registry](https://components.espressif.com/) to share with the community.

## Reference

- [ESP-Registry](https://components.espressif.com/)
- [ESP-Registry Documentation](https://docs.espressif.com/projects/idf-component-manager/en/latest/)
- [Compote Documentation](https://docs.espressif.com/projects/idf-component-manager/en/latest/reference/compote_cli.html)
- [Component Examples](https://github.com/espressif/esp-bsp/tree/master/components)
- [My Components](https://components.espressif.com/components?q=ns%3Apedrominatel)
