---
title: "ESP-IDF C5 - Assign. 4.2"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 13
showAuthor: false
summary: "Write a program that runs on the LP core while the main CPU is in deep sleep. The LP core wakes periodically on the LP timer, increments a counter, and wakes the main CPU once the counter reaches a threshold."
---

In the previous assignment, the main CPU woke itself up with the RTC timer. This time the main CPU stays asleep, and a small program on the __LP core__ does the work. This is the pattern you use to watch a sensor or input while the rest of the chip stays powered down.

To keep things simple, the LP core just counts. After a few counts it wakes the main CPU, which reads the count and reports it.

## Assignment steps

1. Create a new project and enable the LP core.
2. Write the LP core program.
3. Embed the LP core program in the build.
4. Load and start the LP core from the main application.
5. Enter deep sleep and report the count on wakeup.
6. Build, flash, and monitor.

## Create a new project and enable the LP core

1. Create a new ESP-IDF project.

2. Open menuconfig (`> ESP-IDF: SDK Configuration Editor (menuconfig)`) and enable the LP core:

   * Go to __Component config__ &rarr; __Ultra Low Power (ULP) Co-processor__.
   * Enable __Enable Ultra Low Power (ULP) Co-processor__.
   * Under __ULP Coprocessor types__, select __LP core RISC-V__.

   Save the configuration. This turns on the `CONFIG_ULP_COPROC_ENABLED` option and sets `CONFIG_ULP_COPROC_TYPE_LP_CORE`, which lets the build system compile a separate binary for the LP core.

   If you skip the type selection, the build defaults to the ULP FSM coprocessor, tries to assemble your C file as FSM code, and fails with `'ulp_lp_core_utils.h' file not found`.

## Write the LP core program

The LP core runs its own tiny program, built separately from your main application. You keep its source in a dedicated folder inside `main`.

1. Create a new folder `main/ulp` and add a file `main/ulp/main.c` with the following code:

   ```c
   #include "ulp_lp_core_utils.h"

   /* Shared with the main CPU */
   volatile uint32_t counter = 0;

   int main(void)
   {
       counter++;

       /* After 5 runs, wake up the main CPU */
       if (counter >= 5) {
           ulp_lp_core_wakeup_main_processor();
       }

       return 0;
   }
   ```

   Every time the LP timer fires, the LP core runs `main()` once, increments `counter`, and goes back to sleep. The `counter` variable lives in LP memory, so it keeps its value between runs. Once it reaches `5`, `ulp_lp_core_wakeup_main_processor()` brings the main CPU back online.

## Embed the LP core program in the build

You need to tell the build system to compile the LP core source and embed the result into your application.

1. Open `main/CMakeLists.txt` and add the ULP section below your existing `idf_component_register(...)` call:

   ```cmake
   idf_component_register(SRCS "main.c"
                          INCLUDE_DIRS ".")

   #
   # ULP support additions to the component CMakeLists.txt
   #
   set(ulp_app_name ulp_${COMPONENT_NAME})
   set(ulp_sources "ulp/main.c")

   ulp_embed_binary(${ulp_app_name} "${ulp_sources}" "")
   ```

   The `ulp_embed_binary()` call compiles `ulp/main.c` for the LP core and embeds it in your app. It also generates a header, `ulp_main.h`, that lets your main code reach the LP core's variables.

## Load and start the LP core from the main application

Now write the main application. It loads the LP core program, starts it with the LP timer as its wakeup source, and then goes to sleep.

1. In `main/main.c`, add the includes and the symbols that point to the embedded LP core binary:

   ```c
   #include <stdio.h>
   #include <inttypes.h>

   #include "esp_log.h"
   #include "esp_sleep.h"

   #include "ulp_lp_core.h"
   #include "ulp_main.h"

   static const char *TAG = "lp_core";

   extern const uint8_t lp_core_main_bin_start[] asm("_binary_ulp_main_bin_start");
   extern const uint8_t lp_core_main_bin_end[]   asm("_binary_ulp_main_bin_end");
   ```

   The two `extern` symbols mark the start and end of the embedded LP core binary in flash.

2. Add a helper that loads the binary and starts the LP core with the LP timer as its wakeup source:

   ```c
   static void start_lp_core(void)
   {
       ESP_ERROR_CHECK(ulp_lp_core_load_binary(lp_core_main_bin_start,
                       (lp_core_main_bin_end - lp_core_main_bin_start)));

       ulp_lp_core_cfg_t cfg = {
           .wakeup_source = ULP_LP_CORE_WAKEUP_SOURCE_LP_TIMER,
           .lp_timer_sleep_duration_us = 1000000,
       };

       ESP_ERROR_CHECK(ulp_lp_core_run(&cfg));
   }
   ```

   With `lp_timer_sleep_duration_us` set to one million microseconds, the LP core wakes up and runs `main()` once per second.

## Enter deep sleep and report the count on wakeup

1. Add `app_main()`. On the first boot it starts the LP core and enters deep sleep. When the LP core wakes the main CPU, the application reboots, detects the LP core as the wakeup source, and reads the shared counter:

   ```c
   void app_main(void)
   {
       uint32_t causes = esp_sleep_get_wakeup_causes();

       if (causes & BIT(ESP_SLEEP_WAKEUP_ULP)) {
           ESP_LOGI(TAG, "Woken up by the LP core after %" PRIu32 " counts", ulp_counter);
           return;
       }

       ESP_LOGI(TAG, "First boot, starting the LP core");
       start_lp_core();

       ESP_LOGI(TAG, "Allowing the LP core to wake the main CPU");
       ESP_ERROR_CHECK(esp_sleep_enable_ulp_wakeup());

       ESP_LOGI(TAG, "Entering deep sleep, the LP core keeps counting");
       esp_deep_sleep_start();
   }
   ```

   Note how the shared `counter` from the LP core is read here as `ulp_counter`: the generated `ulp_main.h` header exposes every LP core global with an `ulp_` prefix. The `esp_sleep_enable_ulp_wakeup()` call is what lets the LP core wake the chip out of deep sleep.

## Build, flash, and monitor

1. Build and flash the project: `> ESP-IDF: Build, Flash and Start a Monitor on your Device`.

2. Watch the monitor output. On the first boot the main CPU starts the LP core and goes to sleep. About five seconds later the LP core wakes it up:

   ```
   I (310) lp_core: First boot, starting the LP core
   I (320) lp_core: Allowing the LP core to wake the main CPU
   I (320) lp_core: Entering deep sleep, the LP core keeps counting
   ...
   I (300) lp_core: Woken up by the LP core after 5 counts
   ```

   The main CPU spent those five seconds in deep sleep while the LP core did all the counting on its own.

## Conclusion

You ran your first program on the ESP32-C5 LP core. While the main CPU slept, the LP core kept working, counted on the LP timer, and woke the main CPU only when its job was done. Sharing a variable between the two cores let the main application read the LP core's result after wakeup.

This is the foundation of ultra low power designs: hand off simple, always-on monitoring to the LP core, keep the main CPU asleep, and wake it only when there is real work to do. From here you can replace the counter with a real task, such as polling a GPIO or reading an LP I2C sensor, and wake the main CPU only when a meaningful event occurs.

This was the last assignment of the workshop. Congratulations on making it through Wi-Fi 6, partition tables, OTA updates, and the LP core!

> The next step is the workshop's [Conclusion](../_index.md#conclusion).
