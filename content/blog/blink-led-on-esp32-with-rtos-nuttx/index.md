---
title: Blink LED on ESP32 with RTOS NuttX
date: 2020-11-30
showAuthor: false
authors: 
  - sara-monteiro
---
[Sara Monteiro](https://medium.com/@saramonteirosouza44?source=post_page-----d33c7dc62156--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F6d272ea832ca&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fblink-led-on-esp32-with-rtos-nuttx-d33c7dc62156&user=Sara+Monteiro&userId=6d272ea832ca&source=post_page-6d272ea832ca----d33c7dc62156---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*j-XGptYZE3DQ9tV1vJY2Iw.png)

## Introduction

This article is part of the “First Steps with ESP32 and NuttX” series. A series whose objective is to present an overview of the NuttX Operating System and to provide instructions for using NuttX on ESP32.

The [first part](https://medium.com/the-esp-journal/getting-started-with-esp32-and-nuttx-fd3e1a3d182c) of the series showed how to prepare the environment, compile and build the Operating System (NuttX) until uploading the firmware to the SoC (ESP32).

This is the second part and will demonstrate how to run the famous “Hello World” from the Embedded Systems world, i.e., an application that blinks a LED. The evaluation board used here is a DevKit v1 and the built-in LED will be used for convenience. If your DevKit does not come with a built-in LED, just connect an LED to pin 2 in series with a resistor as it will be briefly discussed in the execution section.

## Including LED

From the nuttx directory, clean your current configuration and pre-existing binaries, load the configuration for ESP32 DevKit board with nsh (NuttX shell) and finally enter the configuration menu using the following commands:

```
cd ~/nuttxspace/nuttx
make distclean
./tools/configure.sh esp32-devkitc:nsh
make menuconfig
```

To add the driver for the LED, navigate to* Device Drivers-> LED Support *and select* LED Driver and Generic Lower Half LED Driver* (Click y). In this step you are adding the driver for the LED.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*-0_mp7omntJvLe9k)

Return to the home menu via ‘Exit’. Just use the side arrows and ‘Enter’. Finally, to add the example, navigate to *Application Configuration-> Examples* and select *Led Driver Example.*

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*zYW0SJ_vCxtG1a5O)

Exit the menu via “Exit” and save the configuration.

✓As a shortcut, you may load the *leds* config instead of nsh. If you do so, you don’t need to enter the configuration menu. This config has everything included for you. It’s nice to try both to realize how configs may be used to try functionalities faster but it’s also nice to get familiar with the menuconfig options.

## Building and Flashing

If you did not add the paths for the cross compiler binaries and for the esptool to PATH permanently as suggested in the [Getting Started](https://medium.com/the-esp-journal/getting-started-with-esp32-and-nuttx-fd3e1a3d182c), run the following commands to load these paths.

```
export PATH=$PATH:/opt/xtensa/xtensa-esp32-elf/bin
export PATH=$PATH:/home/<user>/.local/bin
```

__NOTE:__ Replace <user> with your user name.

Finally, clean up any previously generated binaries, connect your DevKit to your computer and perform the build process and flash using the following commands:

```
make clean
make download ESPTOOL_PORT=/dev/ttyUSB0
```

NOTE: adjust the USB port according to your configuration. In case this is the first time you are downloading the binaries to ESP32, pass the bootloader and the partition table directory as an argument in the second comand as instructed in the [previous article](https://medium.com/the-esp-journal/getting-started-with-esp32-and-nuttx-fd3e1a3d182c) from this series.

## Example Execution

Access the serial terminal and execute the command leds. This command will run the selected example!

```
sudo picocom /dev/ttyUSB0 -b 115200
```

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*3breweuiaUIY_52Q)

Congratulations! From now on you should be seeing the LED blinking! If you want to return to the terminal, reset the ESP32 by pressing the DevKit EN button. If you do not have a built-in led, connect an LED to pin 2 and associate a resistor in series (between 100 Ω to 1 k Ω).

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*SOl1UurywMsLvszV.gif)

Tip:

Run “*help”* or “?” to check the built-in apps like exposed in Figure 3.

## Current Support Status

At the moment this article is written the following peripherals/features are supported:

- Symmetric Multi-Processing (SMP)

It’s already possible to use the 2 ESP32 cores. The default configuration only uses 1 core. If you want to use both cores, access the following path in menuconfig:

-> RTOS Features -> Tasks and Scheduling

and enable the SMP option.

- SPI
- I2C
- SPI Flash
- Ethernet
- WiFi
- PSRAM
- 4 Generic Timers
- Watchdog Timers
- Hardware Random Number Generator (RNG)
- Low Power support (PM)

You can keep yourself updated through the following link:

[https://github.com/apache/incubator-nuttx/tree/master/boards/xtensa/esp32/esp32-devkitc](https://github.com/apache/incubator-nuttx/tree/master/boards/xtensa/esp32/esp32-devkitc)

Currently, the support for debugging with OpenOCD and eFUSE are in development! Sooner, they will also be available!

So, stay tuned!

## Where to find support?

To participate in the Nuttx mail list, you can send an email to [dev-subscribe@nuttx.apache.org](mailto:dev-subscribe@nuttx.apache.org).

For help, doubts, bugs reports, and discussion regarding NuttX, you can send an email to [dev@nuttx.apache.org](mailto:dev@nuttx.apache.org).
