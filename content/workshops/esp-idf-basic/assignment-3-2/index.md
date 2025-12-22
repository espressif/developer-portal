---
title: "ESP-IDF Basics - Assign. 3.2"
date: "2025-08-05"
lastmod: "2026-01-20"
series: ["WS00A"]
series_order: 10
showAuthor: false
---

In this assignment, you will read the temperature values from the on-board sensor OR the on-chip sensor depending on your board.


__On board sensor__
_e.g. Rust board_

1. Find the part number of the sensor on your board
2. Find the code for driving the sensor
3. Read temperature from the sensor and output it on the serial port with `printf`.

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
It is not asked to develop the driver, focus on the fastest way to solve the problem and what the previous lecture was about.
{{< /alert >}}

__On chip sensor__
_e.g. DevkitC_

1. Find the sensor api reference page
2. Find how to include, initialize and configure the sensor
3. Read temperature from the sensor and output it on the serial port with `printf`.

### Hint

<details>
<summary>Show hint on board sensor</summary>

* The sensor I2C address can be found on the [EVK GitHub page](https://github.com/esp-rs/esp-rust-board).
* To install a dependency, open an ESP-IDF terminal:<br>

  ```console
  > ESP-IDF: Open ESP-IDF Terminal
  ```
* Then use `idf.py`:

  ```console
  idf.py add-dependency "repository_name_in_the_registry"
  ```
* Remember to adjust the settings in `menuconfig`.

</details>

<details>
<summary>Show hint on chip sensor</summary>

* The information can be found in the [ESP-IDF Programming guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-reference/peripherals/temp_sensor.html#api-reference).
* Configure the sensor

  ```c
      temperature_sensor_config_t temp_sensor = {
          .range_min = -10, // Minimum measurable temperature
          .range_max = 80,  // Maximum measurable temperature
          .clk_src = TEMPERATURE_SENSOR_CLK_SRC_DEFAULT
      };
  ````
* Install and enable it
  ```c
    // Install temperature sensor driver
    temperature_sensor_install(&temp_sensor, &temp_handle);
    temperature_sensor_enable(temp_handle);
  ```
* Read the temperature
  ```c
    temperature_sensor_get_celsius(temp_handle, &tsens_out)
  ```

</details>

## Conclusion

Now that you can read the on board sensor, you're ready to move to the last assignment of the workshop to put everything together.

### Next step

> Next assignment &rarr; [Assignment 3.3](../assignment-3-3/)

> Or [go back to navigation menu](../#agenda)
