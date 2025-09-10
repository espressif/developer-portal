---
title: "ESP-IDF Basics - Lecture 3"
date: "2025-08-05"
series: ["WS00A"]
series_order: 8
showAuthor: false
---

## Introduction

As we saw earlier, ESP-IDF contains several libraries, from FreeRTOS --- the operating system which manages all tasks --- to the peripheral drivers and protocol libraries.
Including the libraries for every possible protocol, algorithm, or driver inside ESP-IDF is not possible: It's size would increase dramatically.
If you need a specific protocol, you can probably find it's C implementation somewhere on Github. In this case, the challenge will be to port it to ESP-IDF, taking care of finding all dependencies and informing the build system about which files should be compiled and linked.

To solve these problem, Espressif developed a component system similar to a package system in GNU/Linux distributions. The components take care of the dependencies and the build system and you can simply include the header file and you're ready to go!
Like in the case of Linux packages, there is also a component manager and a component registry, where you can find all the official packages by Espressif. Once, components are included, the `idf.py` tool will download the component and set the stage for its use.


For additional information, we recommend that you watch the talk [DevCon23 - Developing, Publishing, and Maintaining Components for ESP-IDF](https://www.youtube.com/watch?v=D86gQ4knUnc).

{{< youtube D86gQ4knUnc >}}

We will explore the differences in the use of the integrated libraries and the ones provided by the component registry. We will also see how to create a component, in order to make reusable code.

We will explore how to:

1. Include and use the `gpio` and the `i2c` libraries (included)
2. See how and use the `button` component (registry)
3. Create a new component

During the assignments, the goal will be to control the LED and the I2C sensor (SHTC3) on the board (see Fig. 1).

{{< figure
default=true
src="../assets/lec_3_led_gpio.webp"
caption="Fig.1 - GPIO connected to the LED"
    >}}

## Included Libraries

Let’s take a look at how to use the included libraries. This usually involves three main steps:

1. Let the build system know about the library
   _(include the header file and update `CMakeLists.txt`)_
2. Configure the library settings
3. Use the library by calling its functions


### GPIO

A GPIO (General-Purpose Input/Output) peripheral is a digital interface on a microcontroller or processor that allows it to read input signals (like button presses) or control output devices (like LEDs) through programmable pins. These pins can be configured individually as either input or output and are commonly used for basic device interfacing and control.

On our board, we have an LED connected to the GPIO10 (see Fig. 1) and we will use this pin for the example.

#### Including the library

To include the `gpio` library, we first need to include the header file and tell the build system where to find it.

We need first to include
```c
#include "driver/gpio.h"
```

and then add to `CMakeList.txt`

```c
REQUIRES esp_driver_gpio
```

Note that the header file and the required path are different: When including a library, make sure you check the [programming guide](https://docs.espressif.com/projects/esp-idf/en/v5.4.1/esp32c3/index.html) first.
You need to:

* In the upper left corner, choose the core (ESP32-C3)
* Find the page for the peripheral (GPIO)
* Find the section [API Reference](https://docs.espressif.com/projects/esp-idf/en/v5.4.1/esp32c3/api-reference/peripherals/gpio.html#api-reference-normal-gpio)

#### Configuration

Peripherals have many settings (input/output, frequency, etc). You need to confiure them before using the peripherals.

In case of GPIO, a basic configuration is
```c
    //zero-initialize the config structure.
    gpio_config_t io_conf = {};
    //disable interrupt
    io_conf.intr_type = GPIO_INTR_DISABLE;
    //set as output mode
    io_conf.mode = GPIO_MODE_OUTPUT;
    //bit mask of the pins that you want to set,e.g.GPIO18/19
    io_conf.pin_bit_mask = GPIO_OUTPUT_PIN_SEL;
    //disable pull-down mode
    io_conf.pull_down_en = 0;
    //disable pull-up mode
    io_conf.pull_up_en = 0;
    //configure GPIO with the given settings
    gpio_config(&io_conf);
```

In this workshop, we will use GPIO for output. Due to this, we won't talk about:

* Interrupts (trigger a function when the input changes)
* Pull-up and pull-down (set a default input value)


The only field that needs some explanation is the `pin_bit_mask`.
The configuration refers to the whole GPIO peripheral. In order to apply the configuration only to certain pins (via `gpio_config`), we need to specify the pins via a [bit mask](https://en.wikipedia.org/wiki/Mask_(computing)).
The `pin_bit_mask` is set equal to GPIO_OUTPUT_PIN_SEL which is

```c
#define GPIO_OUTPUT_LED   10
#define GPIO_OUTPUT_PIN_SEL  (1ULL<<GPIO_OUTPUT_LED) // i.e. 0000000000000000000000000000010000000000
```

If you want to apply the configuration to more than one GPIO, you need to `OR` them.
For example:
```c
#define GPIO_OUTPUT_LED   10
#define GPIO_OUTPUT_EXAMPLE   12
#define GPIO_OUTPUT_PIN_SEL  ((1ULL<<GPIO_OUTPUT_LED) | (GPIO_OUTPUT_EXAMPLE))// i.e. 0000000000000000000000000001010000000000
```

#### Usage

Once the peripheral is configured, we can use the function [`gpio_set_level`](https://docs.espressif.com/projects/esp-idf/en/v5.4.1/esp32c3/api-reference/peripherals/gpio.html#_CPPv414gpio_set_level10gpio_num_t8uint32_t) to set the GPIO output to either `0` or `1`.
The header file:
```c
gpio_set_level(GPIO_OUTPUT_LED, 1); // turns led on
gpio_set_level(GPIO_OUTPUT_LED, 0); // turns led off
```


### I2C

I2C (Inter-Integrated Circuit) is a communication protocol that uses only two wires—SDA (data line) and SCL (clock line)—to transmit data between devices. Usually, it is used to connect a microcontroller to an external sensor or actuator. It allows multiple peripherals to communicate with a microcontroller using unique addresses, enabling efficient and scalable device interconnection.

#### Including the library

Consulting the corresponding [programming guide section](https://docs.espressif.com/projects/esp-idf/en/v5.4.1/esp32c3/api-reference/peripherals/i2c.html#api-reference) we get the header file
```c
#include "driver/i2c_master.h"
```
and value for the `CMakeList.txt`
```make
REQUIRES esp_driver_i2c
```

#### Configuration

A configuration has the following form:
```c
    i2c_master_bus_config_t bus_config = {
        .i2c_port = I2C_NUM_0,
        .sda_io_num = I2C_MASTER_SDA_IO,
        .scl_io_num = I2C_MASTER_SCL_IO,
        .clk_source = I2C_CLK_SRC_DEFAULT,
        .glitch_ignore_cnt = 7,
        .flags.enable_internal_pullup = true,
    };
    i2c_new_master_bus(&bus_config, bus_handle);

    i2c_device_config_t dev_config = {
        .dev_addr_length = I2C_ADDR_BIT_LEN_7,
        .device_address = SHTC3_SENSOR_ADDR,
        .scl_speed_hz = 400000,
    };
    i2c_master_bus_add_device(*bus_handle, &dev_config, dev_handle);
```

The values for our board are (see Fig. 1)
```c
#define I2C_MASTER_SDA_IO 7
#define I2C_MASTER_SCL_IO 8
#define SHTC3_SENSOR_ADDR 0x70
```

The other macros are defined internally.


## Component registry

### Use a component from the registry - button

For our last external library (button), we will use the component manager and registry.

* Go to the [component registry](https://components.espressif.com/)
* Search for the button component ([espressif/button](https://components.espressif.com/components/espressif/button/versions/4.1.3))
* Copy the instruction on the left (see Fig.2) - `idf.py add-dependency "espressif/button^4.1.3"`
* In VSCode: `> ESP-IDF: Open ESP-IDF Terminal` and paste the instruction

{{< figure
default=true
src="../assets/lec_3_registry.webp"
caption="Fig.2 - espressif/button component"
    >}}

You should get a message
```bash
Executing action: add-dependency
NOTICE: Successfully added dependency "espressif/button": "^4.1.3" to component "main"
NOTICE: If you want to make additional changes to the manifest file at path <user_path>/blink/main/idf_component.yml manually, please refer to the documentation: https://docs.espressif.com/projects/idf-component-manager/en/latest/reference/manifest_file.html
```

A new file `idf_component.yml` has been created in your project with the following content:

```yaml
dependencies:
  espressif/led_strip: ^2.4.1
  espressif/button: ^4.1.3
```

You can add dependencies directly in this file, but it's recommended to use `idf.py add-dependency` utility.

To use the component, you have to include the appropriate header file and call the functions given in the component documentation and folder.

<!-- TODO: Where are these files mentioned? I couldn't find an easy reference on the component registry! -->


### Create a component

For detailed instructions on how to create a component using the CLI, you can refer to the article [How to create an ESP-IDF component](https://developer.espressif.com/blog/2024/12/how-to-create-an-esp-idf-component/) on the Espressif Developer Portal.


In VSCode, you can follow a similar flow:

1. Create a new project
2. Create a new component by calling `> ESP-IDF: Create New ESP-IDF Component`
3. Give the component a name (e.g. `led_toggle`)

The project will now contain a components folder and all the required files
```bash
.
└── project_folder/
    ├── components/
    │   └── led_toggle/
    │       ├── include/
    │       │   └── led_toggle.h
    │       ├── CMakeList.txt
    │       └── led_toggle.c
    ├── main
    └── build
```

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Each time you create or download a component, you need to perform a project __full cleal__ by calling:

`> ESP-IDF: Full Clean Project`
{{< /alert >}}

You can then include your component in the main file as `led_toggle.h`.

## Conclusion

In this short lecture, we explored two main ways to include external libraries: directly through the CMakeLists.txt file and via the component registry. We covered how to include and use libraries with both methods and explained how to create a custom component from scratch using VSCode. Now it's time to put these concepts into practice in the upcoming assignments.

### Next step

> Next assignment &rarr; [Assignment 3.1](../assignment-3-1/)
