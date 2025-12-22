---
title: "ESP-IDF Adv. - Assign.  3.1"
date: "2025-08-05"
series: ["WS00B"]
series_order: 10
showAuthor: false
summary: "Reduce binary size by working on configuration."
---

In this assignment, you will analyze the binary image size and optimize the memory footprint of your application.

## Assignment steps

1. Build the original project to spot any oversized or suspicious sections (e.g., .text, .data, .rodata) that may hide unoptimized code.
2. Change configuration to reduce it.
3. Rebuild the project to check the improvement.

## Build the original project

* Reopen the last assignment code (it can be both 2.1 or 2.2)
* `> ESP-IDF: Full Clean Project`
* `> ESP-IDF: Build Your Project`

You will get the summary table of Fig.1 for the binary image.
<!-- ![](../assets/assignment_3_1_size_before.webp) -->
{{< figure
default=true
src="../assets/assignment_3_1_size_before.webp"
height=500
caption="Fig.1 - Size calculation"
    >}}


#### Removing the logs

* Remove the logging output in the `menuconfig`<br>
   _if you don't remember how to do that, check [assignment 1.3](../assignment-1-3/#changing-the-configuration-in-menuconfig)_
* `> ESP-IDF: Build Your Project`

<!-- ![](../assets/assignment_3_1_size_before.webp) -->
{{< figure
default=true
src="../assets/assignment_3_1_size_after_log.webp"
height=500
caption="Fig.2 - Size calculation after removing logging"
    >}}

The binary size is 77kb less than before.

#### Certificate Bundle

* Open menuconfig: `> ESP-IDF: SDK Configuration Editor (menuconfig)`
* Uncheck `Certificate Bundle` &rarr; `Enable trusted root certificate bundle`
* `> ESP-IDF: Build Your Project`


<!-- ![](../assets/assignment_3_1_size_before.webp) -->
{{< figure
default=true
src="../assets/assignment_3_1_size_after_bundle.webp"
height=500
caption="Fig.3 - Size calculation after removing certificate bundle"
    >}}

#### MQTT unused options

* Open menuconfig: `> ESP-IDF: SDK Configuration Editor (menuconfig)`
* Uncheck `ESP-MQTT Configurations` &rarr; `Enable MQTT over SSL`
* Uncheck `ESP-MQTT Configurations` &rarr; `Enable MQTT over Websocket`
* `> ESP-IDF: Build Your Project`


<!-- ![](../assets/assignment_3_1_size_before.webp) -->
{{< figure
default=true
src="../assets/assignment_3_1_size_after_ssl.webp"
height=500
caption="Fig.4 - Size calculation after removing mqtt ssl and websocket support"
    >}}

We gained another 6.7kb.


## Conclusion

In this assignment, we saw how to check the size of our binary and how to use the menuconfig to removed unused options to improve the memory footprint of our application.

> Next step: [Assignment 3.2](../assignment-3-2/)

> Or [go back to navigation menu](../#agenda)