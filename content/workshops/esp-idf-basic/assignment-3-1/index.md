---
title: "ESP-IDF Basics - Assign. 3.1"
date: "2025-08-05"
series: ["WS00A"]
series_order: 9
showAuthor: false
---

This assignment has two tasks:


1. Create a `led-toggle` component
2. Refactor the `hello_led` example using the created component

## `led-toggle` component

The first task is to create a `led-toggle` component.

### Create a new component

1. Open your project `hello_led` in VSCode
2. Create a new component: `> ESP-IDF: Create New ESP-IDF Component`
3. Type `led_toggle` in the text field appearing on top (see Fig.1)

{{< figure
default=true
src="../assets/ass3_1_new_component.webp"
caption="Fig.1 - Create new component"
    >}}

The project will now contain the folder `components` and all the required files:
```bash
.
└── hello_led/
    ├── components/
    │   └── led_toggle/
    │       ├── include/
    │       │   └── led_toggle.h
    │       ├── CMakeList.txt
    │       └── led_toggle.c
    ├── main
    └── build
```

### Create the toggle function

Inside the `led_toggle.h`, add:

```c
#include "driver/gpio.h"

typedef struct {
    int gpio_nr;
    bool status;
}led_gpio_t;



esp_err_t config_led(led_gpio_t * led_gpio);
esp_err_t drive_led(led_gpio_t * led_gpio);
esp_err_t toggle_led(led_gpio_t * led_gpio);
```

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
`esp_err` is an enum (hence an int) used to return error codes. You can check its values [in the documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/error-codes.html).
This enum is used also with logging and macros like `ESP_ERR_CHECK`, which you will find almost all esp-idf examples.
{{< /alert >}}

In the `led_toggle.c`, we have to implement the toggling logic:


```c
esp_err_t config_led(led_gpio_t * led_gpio){

    gpio_config_t io_conf = {};
    io_conf.intr_type = GPIO_INTR_DISABLE;
    io_conf.mode = GPIO_MODE_OUTPUT;
    io_conf.pin_bit_mask =  (1ULL<<led_gpio->gpio_nr);
    io_conf.pull_down_en = 0;
    io_conf.pull_up_en = 0;
    return gpio_config(&io_conf);
}

esp_err_t drive_led(led_gpio_t * led_gpio){
    return gpio_set_level(led_gpio->gpio_nr, led_gpio->status); // turns led on
}

esp_err_t toggle_led(led_gpio_t * led_gpio){
    //TBD
    return 0;
}
```

As we've seen in the previous lecture, you first need to configure the peripheral. This is done with the function `config_led`, where you can see the configuration structure we discussed in the lecture.
To test that you chose the correct GPIO and that the LED is working properly, you can also write a `drive_led` which simply drives the GPIO up or down.

Now you have to:

1. Include the appropriate header file in your main file.
2. Call the `drive_led` function and check the led is turning on and off


## Refactor the `hello_led` code

Now you are ready to:

1. Implement the `toggle_led` function
2. Refactor the `hello_led` code to use the newly created component.

## Conclusion

You can now create your own components, which makes your code easier to maintain and to share. In the next assignment, you will face a typical development problem and use the skills you just learned.

### Next step
> Next assignment &rarr; [Assignment 3.2](../assignment-3-2/)
