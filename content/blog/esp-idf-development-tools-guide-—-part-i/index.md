---
title: ESP-IDF Development Tools Guide — Part I
date: 2021-06-08
showAuthor: false
authors: 
  - pedro-minatel
---
[Pedro Minatel](https://medium.com/@minatel?source=post_page-----89af441585b--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fea25448e3ab5&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp-idf-development-tools-guide-part-i-89af441585b&user=Pedro+Minatel&userId=ea25448e3ab5&source=post_page-ea25448e3ab5----89af441585b---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*tsv7HGKaQD-bptRTGa4SWw.png)

If you are starting on ESP32 development, you will see that the ESP-IDF is the official development framework and [Espressif](https://www.espressif.com) actively maintains it with constant updates.

The ESP-IDF is a collection of different things. We have the development framework which provides a comprehensive Software Development Kit, and it also includes the toolchain (the compilers are installed separate from the ESP-IDF folder), documentation, example codes, and a set of tools.

These tools are particularly important and commonly used in many different scenarios in the development process.

This guide will introduce some tools that are not commonly used and could help you on specific tasks or to be used for automation process for example.

To access the documentation reference about the complete Build System, including the idf.py, see: [Build System](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/build-system.html) on our official documentation.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*r52M2Hq85pSd9RcUX180ow.png)

## ESP-IDF Introduction

Before starting on the tools themselves, it is important to explain the basic structure of the ESP-IDF. This part will be very introductory and more informative. We will explore it more in detail in future articles.

The ESP-IDF means __Espressif IoT Development Framework__  and was created to provide the full development environment for IoT applications, including the SDK, installation scripts, components, documentation, examples, build system, compilers, and tools. It is required to develop the application on the ESP32 (not compatible with ESP8266).

The ESP-IDF is compatible with all ESP32 SoC series, including the Xtensa and RISC-V cores.

Currently, the ESP-IDF is available on our [GitHub](https://github.com/espressif/esp-idf).

[espressif/esp-idfESP-IDF is the official development framework for the and ESP32-S Series SoCs provided for Windows, Linux and macOS…github.com](https://github.com/espressif/esp-idf?source=post_page-----89af441585b--------------------------------)

> Contributions from the community are very welcome! To know how to contribute, please see: [How to Contribute](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/contribute/index.html).

The ESP-IDF is composed of various parts, detailed below:

## Components

The components are where the SDK is located. It contains several components used for the bootloader, FreeRTOS, drivers, stacks and libraries.

## Documentation

The ESP-IDF includes the documentation needed for developers to create and use all the features available. This documentation is also available online.

For [ESP32](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started), [ESP32-S2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s2/get-started) or [ESP32-C3](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/get-started).

Or: [Getting Started with ESP-IDF](https://idf.espressif.com).

## Examples

We provide a set of examples on each peripheral and functionality, so you can start your project using one of those examples. Most of the examples were written in C and a few in C++.

You can find examples from blinking a LED, to connect to Wi-Fi, Bluetooth, protocols, storage, systems functions, and many others. This section is continuously updated to provide new examples for each new release.

To see more: [ESP-IDF Examples](https://github.com/espressif/esp-idf/tree/master/examples).

## Tools

The tools referred in this article are the specific ESP-IDF tools. They are not the tools installed in the Operating System, like CMake, git, dfu-utils, and many others required tools.

The ESP-IDF tools are a set of scripts, most created in Python, to help with various tasks, from configuring the SDK to programming the ESP32. All the tools are available directly from the virtual environment terminal.

The following is the list of the tools available on the ESP-IDF v4.3:

- idf.py – It is a command-line tool and provides a front-end for managing your project builds.
- esptool.py – This tool is a ROM bootloader utility used to perform memory-related, like read, write, erase, dump, etc.
- otatool.py – It is a set of commands to deal with the OTA partitions and configuration.
- parttool.py – This tool is similar to the otatool.py but more generic. You can use this to read, write, erase and get partitions information.
- espefuse.py – The espefuse manages the efuses and gets states from them. This tool must be used very carefully since some operations are irreversible.
- espsecure.py - It is the Secure Boot & Flash Encryption tool, used for secure operations.

> __Installing ESP-IDF for Windows, Linux and macOS:__ To install the ESP-IDF in your system, you can follow the Getting Started guide in the documentation.See the [Getting Started](https://idf.espressif.com) page to start using ESP-IDF.We also have some tutorials on the Espressif [Official YouTube channel](https://www.youtube.com/c/EspressifSystems).

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*QQeIY-j3NB9-OBPwTsZ1eg.png)

## ESP-IDF Tools

To start using the tools, we need to open a terminal window and set the virtual environment variables. This can be done by running the export script, included on the ESP-IDF.

__Windows Command Prompt:__ 

```
%userprofile%\esp\esp-idf\export.bat
```

__or for PowerShell:__ 

```
.$HOME/esp/esp-idf/export.ps1
```

__Linux/macOS:__ 

```
. $HOME/esp/esp-idf/export.sh
```

In this guide, the idf.py and esptool.py will be addressed first. The other tools will be covered in the other guides.

## IDF Tool

The idf.py is the main command tool and it is widely used.

The main feature of this tool is to serve as a front-end. It invokes the build system, currently supporting CMake, creates new project, components, prepares the DFU binary, configures the SDK, program the firmware to the device, etc. Other features are included on the idf.py and the commands will be described below:

To see the full list of commands supported, type in the terminal:

> idf.py --help

> Note: Some commands are target-dependent and may not be available on other targets. To see all the commands supported by the target, run the set-target command before.

idf.py set-target [TARGET]

To see all the targets supported:

idf.py set-target --help

The command syntax may vary from command to command, but the basic structure is:

Usage: idf.py [OPTIONS] COMMAND1 [ARGS]... [COMMAND2 [ARGS]...]...

Here is the list of the most used commands as well as some that are helpful. Not all commands will be covered in this guide, so specific guides will be created to cover them.

For the commands that requires serial connection to the device, the COM port, we can use the the option --port or -p and the port.

*For example:*

__Linux:__  -p /dev/ttyUSB0

*or*

__Windows:__  -p COM1

The COM port name and number may vary from system to system and from different Serial-to-USB converters.

## Commands:

- __all__  — Build the project. This command is used to build the full project, including the bootloader and all other required partitions. You can use __build__  instead of __all__  as a alias.

Syntax: idf.py all or idf.py build

- __app__  — Build the app only. This command is used if you want to build only the application and keep the other binaries (bootloader, partitions, etc) out from the build.

Syntax: idf.py app

- __app-flash__  — Flash the application only. Using this command to flash the application, all the other partitions will be kept unchanged.

Syntax: idf.py p [PORT] app-flash

- __bootloader__  — Build the bootloader only. This is similar to the app command.

Syntax: idf.py bootloader

- __bootloader-flash__  — Flash the bootloader only. This is like the app-flash but for the bootloader.

Syntax: idf.py p [PORT] bootloader-flash

- __clean__  — Cleans all the build output files from the build directory. This command is used to delete the last build file in order to re-build if needed.See also: *fullclean.*

Syntax: idf.py clean

- __create-component__  — Create a new component. This command creates a new component and all necessary files into your project.

To use this command, first, you need to create a folder in your project called “components” and under the folder, you can run the following command and the new component name as an argument.

Syntax: idf.py create-component [COMPONENT-NAME]

Alternatively, you can use the -C option and point the path to the components folder. If the components folder does not exist, the folder will be created.

Syntax: idf.py -C [PATH]/components create-component [COMPONENT-NAME]

After that, you can simply add the new component header file to your project.

- __create-project__  — Create a new project. This command is extremely helpful for creating new projects, including all necessary files to build.

To create a new project using this tool, you need to go to the destination folder and use the following command.

Syntax: idf.py create-project [PROJECT-NAME]

If you want to define the path to the project destination folder, you can use the -C option.

Syntax: idf.py -C [PATH] create-project [PROJECT-NAME]

- __dfu__  — Build the DFU binary. To create the DFU binary, use the dfu option before downloading it to the device.

This option is only available if the SoC supports DFU and may not be visible before setting the target to the supported SoC.

Syntax: idf.py dfu

- __dfu-flash__  — Flash the DFU binary. This option is used to download the DFU binary to the device.

Syntax: idf.py dfu-flash

To see the DFU in detail, please check the [ESP32-S2 DFU API guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s2/api-guides/dfu.html) documentation.

- __erase-flash__  — Erase the entire flash chip. This option is used to wipe the flash memory.

Syntax: idf.py -p [PORT] erase-flash

- __flash__  — Flash the project. This option will download the firmware binaries to the device. If the project has not been built yet, this command will trigger the build before flashing it to the device.

Syntax: idf.py -p [PORT] flash

- __fullclean__  — Delete the entire build directory contents. This option removes all files from the build folder. This command does not remove the build folder.

Syntax: idf.py fullclean

- __menuconfig__  — Run “menuconfig” project configuration tool. This command opens the configuration menu to adjust the SDK options to your needs.

Syntax: idf.py menuconfig

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*jFY1tXFuLpu6eMcQvZvarA.png)

- __monitor__  — Display serial output. One of the most used option is the monitor. This option allows you to start the monitoring tool and to display all the output from the device.

Syntax: idf.py -p [PORT] monitor

> To see more details about the monitor tool, see: [Monitor](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/tools/idf-monitor.html) on our docs.

- __reconfigure__  — Re-run CMake. This option can reconfigure your project CMake.

Syntax: idf.py reconfigure

If you are adding a new component to your project, this function should be used to update the CMake for your new project structure.

- __set-target__  — Set the chip target to build. This option is often used to change the target device in the current project.

It’s important to mention that every time you change the target, the project creates a new SDK configuration, and all changes will be settled as the default target configuration. You will need to rebuild the project after setting the new target.

Syntax: idf.py set-target [TARGET]

To see all the available targets on the current ESP-IDF version, you can use:

Syntax: idf.py set-target

- __size__  — Print basic size information about the app. This allows you to check the RAM usage and the total image size.

Syntax: idf.py size

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*Y1DG0hD311gLHBMHZhpJcg.png)

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*j3fDxTv3_eKWaEW1V123ZA.png)

## ESPTOOL

The ROM Bootloader Utility, also known as [esptool](https://github.com/espressif/esptool), is the tool used to write the firmware to the device and also for other memory and binary operations.

Below you will see the full list of functionalities on the esptool.py:

> esptool.py --help

The idf.py uses the esptool.py in several commands, including flash and erase. You might need to use the esptool for some other specific reasons.

The esptool.py command syntax is defined below:

Usage: esptool.py [OPTIONS] COMMAND1 [ARGS]... [COMMAND2 [ARGS]...]...

## __Here are some commands:__ 

- __write_flash__  — Write a binary blob to the device flash.

Syntax:

```
esptool.py -p [PORT] write_flash [ADDRESS1] [PATH_TO_BINARY1]… [ADDRESS2] [PATH_TO_BINARY2]
```

The write_flash command supports multiple binaries in the same command.

This command also allows some before-and-after commands:

__*--before*__ : What to do before connecting to the chip.

```
default_reset
no_reset
no_reset_no_sync
```

This option usually is used with default_reset by the idf.py when flashing the device. For some special demands, you can change this behavior.

__*-- after*__ : What to do after esptool.py is finished.

```
hard_reset
soft_reset
no_reset
```

For this option, the idf.py default option is the hard_reset. It means that the device will be hard reset after flashing is done.

If you need to keep the device into download state, you can use the “no_reset” argument for this option.

Syntax:

```
esptool.py -p [PORT] --before [ARG_BEFORE] --after [ARG_AFTER] write_flash [ADDRESS] [PATH_TO_BINARY]
```

- __verify_flash__  — Verify a binary blob against flash.

This option is used to verify the integrity of the compiled version to the flashed into the device. This kind of verification is often used to check or verify possible errors after flashing the device.

Syntax: esptool.py -p [PORT] verify_flash [ADDRESS] [PATH_TO_BINARY]

- __image_info__  — Dump headers from an application image.

Syntax: esptool.py --chip [CHIP] image_info [PATH_TO_BINARY]

- __read_mac__  — Read MAC address from OTP ROM.

Syntax: esptool.py -p [PORT] read_mac

- __erase_flash__  — Perform Chip Erase on SPI flash. Same as idf.py erase_flash.

It wipes the whole flash memory and could take some time depending on the flash size.

Syntax: esptool.py -p [PORT] erase_flash

- __erase_region__  — Erase a region of the flash.

This partially wipes the flash memory. This can be used to erase a specific partition or some other area specified by the addresses.

Syntax: esptool.py -p [PORT] erase_region [START_ADDRESS] [END_ADDRESS]

Note: The parttool.py use this option on esptool.py to erase the selected partition.

- __chip_id__  — Read Chip ID from OTP ROM, if available.

Syntax: esptool.py -p [PORT] chip_id

- __flash_id__  — Read SPI flash manufacturer and device ID.

You can use this option to detect the flash information, like size and manufacturer. You can also use this to get the chip details such as:

- Chip type and revision
- Crystal frequency
- MAC Address

Syntax: esptool.py -p [PORT] flash_id

- __merge_bin__  — Merge multiple raw binary files into a single file for later flashing.

This option is useful when distributing the full image. You can merge all binaries files generated by the build, including bootloader, app, partitions, ota, etc.

Merge Command Syntax:

```
esptool.py merge_bin [OUT] [OPTIONS] [ADDRESS1] [PATH_TO_BINARY1]...[ADDRESS2] [PATH_TO_BINARY2]
```

Merge Advanced Options:

```
• __--flash_freq__ : Defines the flash SPI speed (in MHz)
    ◦ keep
    ◦ 40m
    ◦ 26m
    ◦ 20m
    ◦ 80m• __--flash_mode__ : Defines the SPI flash memory connection mode.
    ◦ keep
    ◦ qio
    ◦ qout
    ◦ dio
    ◦ dout• __--flash_size [FLASH_SIZE]__ : Defines the flash memory size.• __--spi-connection [SPI_CONNECTION]:__  Defines the flash pinout configuration. If not defined, the default will be used from efuse.• __--target-offset [TARGET_OFFSET]:__  This option define the memory ofsset that the binary will be flashed. The default option is 0x0.• __--fill-flash-size [FILL_FLASH_SIZE]:__  Use this option to fill the binary with 0xff padding. This option will increase the binary size up to the defined flash size.
```

Here is an example to merge three binaries into one for an ESP32 with 4MB of flash in DIO mode:

```
esptool.py --chip esp32 merge_bin -o my_app_merged.bin --flash_mode dio --flash_size 4MB 0x1000 build/bootloader/bootloader.bin 0x8000 build/partition_table/partition-table.bin 0x10000 build/my_app.bin
```

Note that the addresses may vary from one application to another. A good way to check this is through the partitions CSV file or the output from the command idf.py build.

Then, the output file can be flashed at the offset 0x0.

```
esptool.py write_flash 0x0  my_app_merged.bin
```

## Optional arguments

The esptool.py has some optional arguments that help the commands to be more specific or to change some default options. Here are the arguments:

If not set, the default will be used.

```
• __--help__ : Shows the help information.• __--chip__ : Set the target chip type. Can be used to avoid mistakes such as sending a command to the wrong chip type.• __--port__ : Set the serial port device.• __--baud__ : Set the serial port device speed.• __--before__ : What to do before connecting to the chip.• __--after__ : What to do after running esptool.py.• -__-no-stub__ : Disable launching the flasher stub, only talk to ROM bootloader.• __--trace__ : Enable trace-level output of esptool.py interactions.• __--override-vddsdio__ : Override ESP32 VDDSDIO internal voltage regulator (use with care).• __--connect-attempts__ : Number of attempts to connect, negative or 0 for infinite. Default: 7.
```

## Conclusion

The get the full potential of the ESP-IDF, you must also know how to use the set of tools available. Using these tools’ functionalities, you can build automation for your project or manufacturing process, creating scripts that perform specific functions.

Mastering the ESP-IDF tools could save time and get your development process even easier on the daily tasks!
