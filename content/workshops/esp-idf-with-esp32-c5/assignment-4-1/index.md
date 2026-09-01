---
title: "ESP-IDF C5 - Assign. 4.1"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 12
showAuthor: false
summary: "Write an application that enters deep sleep, wakes up periodically with the RTC timer, and keeps a counter alive across sleep cycles using RTC memory."
---

In this assignment, you'll build a simple sleep-and-wake cycle. The board wakes up, prints how many times it has woken and why, then goes back to deep sleep.

## Assignment steps

1. Create a new project and add the sleep includes.
2. Keep a boot counter in RTC memory so it survives deep sleep.
3. Report the wakeup cause after each wakeup.
4. Configure the RTC timer as a wakeup source and enter deep sleep.
5. Build, flash, and monitor

## Create a new project and add the sleep includes

1. Create a new ESP-IDF project.

2. In your main source file, add the includes for logging, FreeRTOS delays, and the sleep API, plus a `TAG` for logging:

   ```c
   #include <stdio.h>

   #include "freertos/FreeRTOS.h"
   #include "freertos/task.h"

   #include "esp_log.h"
   #include "esp_sleep.h"

   static const char *TAG = "deep_sleep";
   ```

## Keep a boot counter in RTC memory so it survives deep sleep

Deep sleep powers off the CPU and most of the RAM, so ordinary variables are lost. Only RTC FAST memory survives and you can place a variable there with the `RTC_DATA_ATTR` attribute.

1. Declare a boot counter in RTC memory, just above `app_main()`:

   ```c
   static RTC_DATA_ATTR int boot_count = 0;
   ```

   > [!INFO]
   > Because it lives in RTC FAST memory, this variable keeps its value across deep sleep cycles. A normal global would be reset to `0` every time the board wakes up and reboots.

## Report the wakeup cause after each wakeup

After waking, the application can find out what triggered the wakeup. Since ESP-IDF v6.0, `esp_sleep_get_wakeup_causes()` returns a bitmap of all sources that fired, which you test with bitwise operations.

1. Add a helper that logs the wakeup cause:

   ```c
   static void log_wakeup_cause(void)
   {
       uint32_t causes = esp_sleep_get_wakeup_causes();

       if (causes & BIT(ESP_SLEEP_WAKEUP_TIMER)) {
           ESP_LOGI(TAG, "Woken up by the RTC timer");
       } else {
           ESP_LOGI(TAG, "First boot or reset (not a timer wakeup)");
       }
   }
   ```

   On the very first boot there is no wakeup source, so the bitmap is empty and the `else` branch runs. On every later wakeup, the timer bit is set.

## Configure the RTC timer as a wakeup source and enter deep sleep

Now tie it together: count the boot, report the cause, arm the timer, and go back to sleep.

1. In `app_main()`, increment and log the boot counter, then call the helper you just wrote:

   ```c
       boot_count++;
       ESP_LOGI(TAG, "Boot count: %d", boot_count);

       log_wakeup_cause();
   ```

2. Configure the RTC timer as a wakeup source with `esp_sleep_enable_timer_wakeup()`. The duration is given in microseconds, so multiply by one million to sleep for 10 seconds:

   ```c
       const int wakeup_time_sec = 10;
       ESP_LOGI(TAG, "Entering deep sleep for %d seconds", wakeup_time_sec);
       ESP_ERROR_CHECK(esp_sleep_enable_timer_wakeup(wakeup_time_sec * 1000000));
   ```

3. Give the log output a moment to flush, then enter deep sleep. Remember that `esp_deep_sleep_start()` never returns: when the timer fires, the chip reboots and `app_main()` runs again from the top:

   ```c
       vTaskDelay(pdMS_TO_TICKS(100));
       esp_deep_sleep_start();
   ```

## Build, flash, and monitor

1. Build and flash the project: `> ESP-IDF: Build, Flash and Start a Monitor on your Device`.

2. Watch the monitor output. You should see a cycle like this every 10 seconds:

   ```
   I (310) deep_sleep: Boot count: 1
   I (310) deep_sleep: First boot or reset (not a timer wakeup)
   I (320) deep_sleep: Entering deep sleep for 10 seconds
   ...
   I (300) deep_sleep: Boot count: 2
   I (300) deep_sleep: Woken up by the RTC timer
   I (310) deep_sleep: Entering deep sleep for 10 seconds
   ```

   The boot count keeps growing because it lives in RTC memory, and every wakeup after the first reports the RTC timer as its cause.


## Conclusion

You built a complete low-power cycle: the `ESP32-C5` wakes on a timer, does a small amount of work, remembers state across sleep with `RTC_DATA_ATTR`, and returns to deep sleep. This pattern is the backbone of battery-powered sensors that wake up, take a reading, and sleep again.

In the next assignment, you'll go further and let the ULP LP core do the monitoring while the main CPU stays asleep.

### Next step
> Next assignment &rarr; [Assignment 4.2](assignment-4-2/)

> Or [go back to navigation menu](.#agenda)
