---
title: "Eclipse Plugin for ESP-IDF"
date: 2020-04-17
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kondal-kolipaka
tags:
  - Esp32
  - IoT
  - Eclipse
  - Plugins
  - Esp Idf

---
{{< figure
    default=true
    src="img/eclipse-1.webp"
    >}}

ESP-IDF Eclipse Plugin brings developers an easy-to-use Eclipse-based development environment for developing ESP32 based IoT applications.

It provides better tooling capabilities, which simplifies and enhances standard Eclipse CDT for developing and debugging ESP32 IoT applications. It offers advanced editing, compiling, flashing and debugging features with the addition of Installing the tools, SDK configuration and CMake editors. The plug-in runs on Windows, macOS and GNU/Linux.

It supports [ESP-IDF](https://github.com/espressif/esp-idf) CMake based projects (4.x and above)

## Current Status

We have recently released 1.0.1 to the public. Check [here](https://github.com/espressif/idf-eclipse-plugin/releases)

## Getting Started

The IDF Eclipse Plugin is available from the Eclipse Marketplace. To get started, users need to download the [Eclipse CDT](https://www.eclipse.org/downloads/packages/release/2020-03/r/eclipse-ide-cc-developers-includes-incubating-components) from the Eclipse downloads page. The Eclipse CDT can be installed with the new Eclipse installer, or the CDT package can be downloaded directly. Once that’s set up, the [Marketplace](https://marketplace.eclipse.org/content/esp-idf-eclipse-plugin) client can be used to search for and install the ESP-IDF Eclipse Plugin.

{{< figure
    default=true
    src="img/eclipse-2.webp"
    >}}

You can also install the IDF Eclipse Plugin into the existing Eclipse CDT using the plugin update site URL [https://dl.espressif.com/dl/idf-eclipse-plugin/updates/latest/](https://dl.espressif.com/dl/idf-eclipse-plugin/updates/latest/)

You can find the detailed instructions [here](https://github.com/espressif/idf-eclipse-plugin#espressif-idf-eclipse-plugins)

{{< figure
    default=true
    src="img/eclipse-3.webp"
    >}}

Espressif believes in the open-source approach and we have made code open for the plugin as well [https://github.com/espressif/idf-eclipse-plugin](https://github.com/espressif/idf-eclipse-plugin). We really welcome any kind of contribution that one can provide.

## Key Features

Eclipse CDT with IDF Eclipse Plugin supports end-to-end workflow to develop ESP32 IoT applications. Here are some of the features.

- IDF Tools installation: It installs xtensa-esp32-elf, xtensa-esp32s2-elf, esp32ulp-elf, esp32s2ulp-elf, openocd-esp32, CMake and Ninja build tools
- Auto-configuration of Eclipse CDT build environment variables such as PATH, IDF_PATH, OPENOCD_SCRIPTS and IDF_PYTHON_ENV_PATH
- Auto-configuration of Core build toolchains and CMake toolchain which is used in resolved headers and indexing
- New ESP-IDF project wizard and templates to get started
- Compiling and Flashing an application to the board
- Viewing Serial monitor output
- JTAG GDB Hardware debugging
- OpenOCD debugging using [Eclipse GNU MCU Plugin](https://gnu-mcu-eclipse.github.io/debug/openocd/)
- Predefined debug launch configuration files to quickly get started with debugging
- Importing an existing IDF project and converting to the Eclipse-based CMake project
- [CMake Editor Plug-in](https://github.com/15knots/cmakeed) is integrated with IDF plugins for editing CMake files such as CMakeLists.txt
- Easy to use Eclipse-based GUI for SDK Configuration Editor which will simulate the behaviour of idf.py menuconfig
- Customized flash target — supports esp32 and esp32s2 chips

## Eclipse CDT Workbench with IDF Eclipse Plugin

{{< figure
    default=true
    src="img/eclipse-4.webp"
    >}}

## Components Based Design

{{< figure
    default=true
    src="img/eclipse-5.webp"
    >}}

## Demo

Please check our demo presented in EclipseCon 2019. This will also give an overview of ESP-IDF, build system and a quick demo on the plugin.

## Resources

ESP-IDF Eclipse Plugin [https://github.com/espressif/idf-eclipse-plugin](https://github.com/espressif/idf-eclipse-plugin)

ESP-IDF [https://github.com/espressif/esp-idf/](https://github.com/espressif/esp-idf/)

ESP-IDF documentation [https://docs.espressif.com/projects/esp-idf/en/latest/](https://docs.espressif.com/projects/esp-idf/en/latest/)

ESP32 Forum for IDE’s [https://www.esp32.com/viewforum.php?f=40](https://www.esp32.com/viewforum.php?f=40)
