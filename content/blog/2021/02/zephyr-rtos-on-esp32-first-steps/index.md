---
title: "Zephyr RTOS on ESP32 — First Steps"
date: 2021-02-24
lastmod: 2025-09-26
showAuthor: false
authors:
  - ricardo-tafas
tags:
  - Esp32
  - Zephyr
  - Embedded Systems
  - Espressif
summary: "First Steps with Zephyr on ESP32, a collection of all needed tutorials."
---

## General Information

- This is a Quick Start based on several guidelines.
- There are many tutorials listed in this page, all of them very important for a sucessful start.
- It is common to overstep and miss important details. **Be attentive.**

## Before Starting

- Zephyr is an RTOS maintained by the Linux Foundation and ported to several architectures. [More about Zephyr.](https://www.zephyrproject.org)
- Espressif officially supports Zephyr RTOS on its devices. [Visit the Product page](https://www.espressif.com/en/sdks/esp-zephyr).
- Check if your device is supported. Users can track the development status of Zephyr on Espressif devices by following the [Support Status Page](https://developer.espressif.com/software/zephyr-support-status/).

## Installation

- Follow the [Official Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html)
- Make sure your system is updated.
- Follow the instructions with attention to every step.
- Extra precautions are needed with Windows:
    - Paths on environment variables may have problems with mixing '\\' and '/'.
    - You must to use Chocolatey, otherwise installation is complex. If Chocolatey is blocked, refer this article, as this step is mandatory.

## First Build

- The application *west* is the meta tool of Zephyr. After following the *Getting Started Guide*, only *west* will be needed.
- Simpleboot is the name used for the *absence* of a second stage bootloader. It is the old school firmware build.
- Find your board.
    - [Boards search page](https://docs.zephyrproject.org/latest/boards/index.html). *Vendor* refers to the board manufacturer. Many different vendors, including Espressif itself, use Espressif chips. 
    - [Boards Folder in Github](https://github.com/zephyrproject-rtos/zephyr/tree/main/boards).
- If your board is not listed or if you are using a custom board, try using a regular DevkitC for the Espressif device you have. It won't change outcome for now.
- Read the Board documentation, and stop after fetching the binary blobs. **There are important information and commands that cannot be missed.**
- [Jump to Manual Build](https://docs.zephyrproject.org/latest/boards/espressif/esp32c3_devkitc/doc/index.html#manual-build) and execute all the steps. 
- If all went well, you should have seen the *hello world* message.
- Use ```Ctrl + ]``` to exit the console application. You can study the Monitor manual [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/tools/idf-monitor.html).

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
- All Espressif boards will require to fetch binary blobs.
{{< /alert >}}
\
{{< alert >}}
Some devkits have 2 options for console output:
- UART0 (usually with on-board Serial-USB converter), as default.
- USB, using the On-Chip USB-Serial converter.

If you see some messages but not the *hello world* message, for now, try connecting to the other port. 
{{< /alert >}}

## Build with Zephyr Port of MCUboot

- If you saw the *hello world*, everything is good so far.
- If OTA or any form of firmware ugrade is necessary, MCUboot will be mandatory, so we test it. The same applies to Security. [More about MCUboot](https://docs.mcuboot.com/).
- There are 2 options for MCUboot: Zephyr port or Espressif port.
   - Zephyr port: software security only.
   - Espressif Port: hardware backed security.
- Let's go with the Zephyr Port for now.
- First, enable MCUboot. [Instructions here](https://docs.zephyrproject.org/latest/boards/espressif/esp32c3_devkitc/doc/index.html#mcuboot-bootloader). Further explanation:
    - Zephyr project configuration is based on Kconfigs. [More about it here](https://docs.zephyrproject.org/latest/build/kconfig/index.html).
    - You can [search](https://docs.zephyrproject.org/latest/kconfig.html) for Kconfigs.
    - All project configurations go to a file named *proj.conf*. On the instructions above, you will have to edit the file ```zephyr/samples/hello_world/proj.conf```.
- It is time to build the MCUboot and Zephyr. [Instructions here](https://docs.zephyrproject.org/latest/boards/espressif/esp32c3_devkitc/doc/index.html#sysbuild).
    - The ```--sysbuild``` option commands *west* to build the Zephyr, but also to build the MCUboot Second Stage Bootloader.
    - The building process results in 2 binaries, but you don't have to worry, *west* takes care of flashing both correctly.
- Remember to flash the device and start the monitor, just like the manual build.
- You should see, during the boot message, that MCUboot was executed.
- You should also see the *hello world* message.

## Building the Espressif Port of MCUboot

- If all went fine so far, it is time to build the Espressif Port of MCUboot. This allows for features like Flash Encryption and Secure Boot, although we won't be enabling them now.
- Clone the MCUboot repository on a different folder than Zephyr.
```
git clone https://github.com/mcu-tools/mcuboot.git
```
- Follow [the MCUboot instructions](https://docs.mcuboot.com/readme-espressif.html) and make sure you don't skip any step.
    - If using Windows, make sure all paths are correct.
    - Make sure NINJA is working properly. Having errors of any kind is a bad sign.
    - Stop at the ninja flashing command.
- Now, the Zephyr image needs to be rebuilt to workwith MCUboot - Espressif Port. This is not automatic.
    - The Kconfig option enabling MCUboot must be kept, so Zephyr is built accordingly.
    - There is no need to build MCUboot, as it as already done with the steps above and flashed to the device.
    - Only Zephyr needs to be built. This is done by building it without using the ```--sysbuild``` option, similar to the Manual build.
```
west build -b <board> samples/hello_world -p
```
- The ```-p``` option commands *west* to do a pristine build, which is a build after a clean-up. It is recomended when there are big config changes.
- Flash it and make it run. Usual commands:
```
west flash
west espressif monitor
```
- If you saw the bootloader running MCUboot and the *hello world* message, everything went fine. There is no noticeable difference from the Zephyr port of MCUboot.

## Next Steps

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
The steps above are valid for all examples. But be careful, some samples may not work directly out of the box.
{{< /alert >}}

- From this point and forward, you will face more *Zephyr Problems* than *Espressif Problems*.
- Run the Blinking example. It will not work directly on DevkitC, because it has no LED. You will need to learn about OVERLAYS, and have a breadboard to add LED circuitry, if not is present.
- Test Wi-Fi examples (if present).
    - It's recommeded to use Wi-Fi Shell at first.
- Test BlueTooth Examples (if present)
- Test 15.4 (if present)
- Test OTA with MCUboot

## Selected Tutorials

In case you need more information or detailed explanations, there are lots of sources to look for. These 2 below are very friendly for beginners:

- Shawn Hymel and Digikey have a very nice series about Zephyr. [Introduction to Zephyr](https://www.youtube.com/watch?v=mTJ_vKlMS_4)
- The Pull-Up Resistor Channel also has good tutorials. [ESP32 on Zephyr OS](https://www.youtube.com/watch?v=Z_7y_4O7yTw)

Make sure to see all the videos on those series. There may be changes regarding commands due to Zephyr evolution. If any command is not working, check the official documentation or ask Discord.

---
The [original article](https://medium.com/the-esp-journal/zephyr-rtos-on-esp32-first-steps-2185c0d56250) was published on Medium, at the [ESP Journal](https://medium.com/the-esp-journal). It was rewritten for the current format.
