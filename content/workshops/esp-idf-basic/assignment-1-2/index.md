---
title: "ESP-IDF Basics - Assign. 1.2"
date: "2025-08-05"
lastmod: "2026-01-20"
series: ["WS00A"]
series_order: 3
showAuthor: false
summary: "Create a new project from the `blink` example and change the output GPIO pin via `menuconfig`"
---

## Assignment outcomes

1. A new project from the `blink` example is created.
2. The output GPIO is changed according to the board schematic.
3. The EVK LED is blinking.

## Assignment steps outline

For this assignment, you will create a new project from the other `get_started` example: `blink`.
In the `blink` example, you need to specify the GPIO on which the LED is connected. The default value is `GPIO8` but it's different on your board. You will need to change the configuration value through `menuconfig`.

* Create the project from example as done in the previous assignment.
* Change the example GPIO number in `menuconfig`:
   * Find the GPIO on which the LED is connected on your board
   * `> ESP-IDF: SDK Configuration Editor (menuconfig)` &rarr; `Example Configuration` &rarr; `Blink GPIO number`
* Build, flash, and monitor the example.
* Check that the LED is flashing. Is the output port correct? See the board schematic.

<!-- ![Board top view](../assets/esp-board-top.webp) -->
{{< figure
default=true
src="../assets/esp-board-top.webp"
height=500
caption="Fig.1 - Board Top View"
    >}}

## Bonus task

* (Bonus) Change the main filename to `hello_led_main.c` and the project folder to `hello_led`. Did you encounter errors?
   * Where is the problem?

<details>
<summary>Solution</summary>

The linker is not informed that it needs to compile the file `hello_led_main.c` as well.
You need to modify the `CMakeLists.txt` file, which contains the list of source files to include.

The build system is a topic covered in the advanced workshop.

```console
idf_component_register(SRCS "hello_led_main.c"
                       INCLUDE_DIRS ".")
```

</details>


## Conclusion

You have now a solid understanding of the project creation, building, and flashing.
In the next lesson, we will focus on what usually is the main topic for an Espressif application -- *connectivity*.

### Next step

> Next lecture &rarr; __[Lecture 2](../lecture-2/)__

> Or [go back to navigation menu](../#agenda)
