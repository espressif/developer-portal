---
title: "Working with ESP-IDF in CLion"
date: 2025-03-13T16:53:32+02:00
showAuthor: false
authors:
    - "oleg-zinovyev"
tags:
- ESP32-S3
- ESP-IDF
- CLion
- IDE
- Tutorial
---

This tutorial shows how to work with an ESP-IDF project in CLion, a cross-platform C and C++ IDE. We’ll build an application, flash it to an ESP32-S3 board, and debug it. We’ll also run the serial monitor and examine the configuration menu that allows you to customize your ESP-IDF project. All of this will be done within the IDE, without having to switch to a system terminal or any other tool.

The tutorial is beginner-friendly, so it’s okay if you’ve never worked with ESP-IDF and CLion.

## Prerequisites

We’ll use the following hardware:

- ESP32-S3-DevKitC-1 v1.1.
- MacBook Pro M2 Max.
- USB-C to micro USB data cable.

To get started:

- [Install the ESP-IDF toolchain](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/get-started/linux-macos-setup.html#standard-toolchain-setup-for-linux-and-macos).
- [Install CLion](https://www.jetbrains.com/clion/download/). You can use the free 30-day trial version. Be sure to check whether there are any [discounted or free options](https://www.jetbrains.com/clion/buy/?section=discounts&billing=yearly) available.

Although we’ll be running CLion on macOS, the workflow and settings are generally similar to those for Windows and Linux, except in cases mentioned in this article. If you want to learn more about the configuration options available in CLion beyond those demonstrated in this tutorial, refer to the [CLion documentation](https://www.jetbrains.com/help/clion/installation-guide.html).

## Configuring an ESP-IDF project

1. Run CLion.
2. Select `Open` from the welcome screen.

{{< figure
default=true
src="img/1-esp-clion-open-project.webp"
    >}}

3. Navigate to the default ESP-IDF directory on your computer. For the purposes of this tutorial, this is `/Users/username/esp/esp-idf`. Then, go to the `examples` subdirectory and select a project to build.

In this tutorial, we’ll be using `led_strip_simple_encoder`. It’s located in `examples/peripherals/rmt`. This application generates an LED rainbow chase on the board. Although it’s intended to be used with an LED strip, it also works with a single LED board like the one used here. The LED will simply flash different colors in a predetermined sequence.

4. Click `Trust Project`. The `Open Project Wizard` will then open.
5. Click `Manage toolchains...`.

{{< figure
default=true
src="img/2-esp-clion-manage-toolchains.webp"
    >}}

6. Click `+`, and select `System` (for Windows, select `MinGW` instead) to create a new toolchain. You can name it anything you like.
   - Select `Add environment` > `From file` in the new toolchain template.

    {{< figure
    default=true
    src="img/3-esp-clion-add-environment.webp"
        >}}

   - Click `Browse...`.

    {{< figure
    default=true
    src="img/3.1-esp-clion-add-environment-browse.webp"
        >}}

   - Select the environment file on your computer. For macOS, you need the file called `export.sh` (on Windows, it’s `export.bat`), which is located in the default ESP-IDF directory.
   - Click `Apply`

7. Go to `Settings` > `Build, Execution, Deployment` > `CMake`.
    - In the default `Debug` profile settings, select the recently created toolchain, which in our case is `ESP-IDF`.

    {{< figure
    default=true
    src="img/4-esp-clion-cmake.webp"
        >}}

    - In the `CMake options` field, enter `-DIDF_TARGET=esp32s3` (because an ESP32-S3-based board is used).
    - In the `Build directory` field, enter `build`.
    - Click `OK`.

Your project will then start to load. If the process fails, click `Reset Cache and Reload Project` in the CMake tool window settings.

{{< figure
default=true
src="img/5-esp-clion-reload-project.webp"
    >}}

If the project is loaded successfully, you’ll see `[Finished]` at the end of the CMake log. Your application is ready to be built and flashed to the board.

## Building the application and flashing the board

1. Make sure your board is connected to your computer via the UART port.
2. If you’re using the same application example, make sure that the GPIO LED number is correctly specified in the source code:
    - In CLion’s `Project` tool window, locate the main directory in your project directory and open the `led_strip_example_main.c` file.
    - In the `#define RMT_LED_STRIP_GPIO_NUM` line, change the default value to `38` or `48`, depending on your board hardware revision.

    {{< figure
    default=true
    src="img/6-esp-clion-gpio-num.webp"
        >}}

3. Click the `Run / Debug Configurations` drop-down list on the main toolbar and select the `flash` configuration. This configuration allows you to build the project and then flash the board automatically.

{{< figure
default=true
src="img/7-esp-clion-flash-target.webp"
    >}}

4. Click the green `Build` icon on the main IDE toolbar.

{{< figure
default=true
src="img/8-esp-clion-build-flash.webp"
    >}}

In the `Messages` tool window, you can see data on the building and flashing processes.

{{< figure
default=true
src="img/9-esp-clion-build-flash-finished.webp"
    >}}

After the build, the board will blink according to the configured rainbow-chase pattern.

{{< figure
default=true
src="img/10-esp-clion-build-flash-board.webp"
    >}}

To change the chasing speed, update the `EXAMPLE_ANGLE_INC_FRAME` value in `led_strip_example_main.c`. To change the density of colors, update `EXAMPLE_ANGLE_INC_LED` in the same file.

## Running the IDF monitor

1. Copy the path to your environment file from the toolchain settings. For this tutorial, it’s `/Users/Oleg.Zinovyev/esp/esp-idf/export.sh`.
2. Go to `Run | Edit Configurations` and click `Add New Configuration`.

{{< figure
default=true
src="img/11-esp-clion-add-config.webp"
    >}}

3. Select the `Shell Script` template. In this new configuration dialog:
    - Enter a name of your choice.
    - Select `Script text` next to `Execute`.
    - Enter the following text, including the path of the environment file you’ve just copied: `. /Users/Oleg.Zinovyev/esp/esp-idf/export.sh ; idf.py flash monitor`.

    {{< figure
    default=true
    src="img/12-esp-clion-flash-monitor.webp"
        >}}

    - Leave the rest of the options as they are and click `OK`.

4. Click the green `Run` icon on the main toolbar.

You’ll then see the diagnostic data from the monitor displayed in the IDE’s terminal.

{{< figure
default=true
src="img/13-esp-clion-monitor.webp"
    >}}

## Working with the project configuration menu

The [project configuration menu](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/kconfig.html) is a GUI tool running in the terminal that allows you to configure your ESP-IDF project. It’s based on Kconfig and offers various low-level [configuration options](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/kconfig-reference.html), including access to bootloader, serial flash, and security features.

The project configuration menu runs through the `idf.py menuconfig` command, so you need to configure a run configuration accordingly.

1. Open the configuration you’ve created to run the serial monitor.
2. Click `Copy Configuration`.

{{< figure
default=true
src="img/14-esp-clion-copy-config.webp"
    >}}

3. Rename the copied configuration to reflect the new functionality, for example, `ESP-menu-config`.
4. In the script text, replace `flash monitor` with `menuconfig`.

{{< figure
default=true
src="img/15-esp-clion-menu-config.webp"
    >}}

5. Click `OK`.
6. Make sure the IDE’s new terminal is disabled (unchecked), as the project configuration menu may not work properly with it.

{{< figure
default=true
src="img/17-esp-clion-menu-config-terminal.webp"
    >}}

7. Click the green `Run` icon on the main toolbar.

The project configuration menu will open in the IDE’s terminal.

{{< figure
default=true
src="img/16-esp-clion-menu-config-run.webp"
    >}}

You can use the keyboard to navigate the menu and change the default parameters of your project, for example, the flash size.

{{< figure
default=true
src="img/18-esp-clion-menu-config-flash-size.webp"
    >}}

## Using the `idf.py` command in the terminal

You can also use the `idf.py` command with various options in the terminal to manage your project and examine its configuration. For example, here is the output of the `idf.py. size` command showing the firmware size:

{{< figure
default=true
src="img/19-esp-clion-idf-py.webp"
    >}}

You can configure commands you often use as shell scripts and run them as separate configurations, as you did earlier when accessing the serial monitor port and project configuration menu.

To learn more about the idf.py options, read the [official documentation](https://docs.espressif.com/projects/esp-idf/en/v5.4/esp32/api-guides/tools/idf-py.html).

## Debugging a project

We’ll use the [Debug Servers](https://www.jetbrains.com/help/clion/debug-servers.html) configuration option to debug the project. This CLion feature provides a convenient way to configure and use a debug server with different build targets.

1. Unplug the USB cable from the board’s UART connector and plug it into the USB connector.
2. Make sure `Debug Servers` are enabled in `Settings` > `Advanced Settings` > `Debugger`.

{{< figure
default=true
src="img/20-esp-clion-enable-debug-servers.webp"
    >}}

3. Select the `led_strip_simple_encoder.elf` configuration from the main toolbar switcher.

{{< figure
default=true
src="img/21-esp-clion-led-strip-config.webp"
    >}}

After that, the `Debug Servers` switcher appears in the main toolbar.

4. Select `Edit Debug Servers`.

{{< figure
default=true
src="img/22-esp-clion-edit-debug-server.webp"
    >}}

5. Click `+` to add a new debug server.
6. Select the `Generic` template.

{{< figure
default=true
src="img/23-esp-clion-generic-template.webp"
    >}}

7. Here, you need to specify several parameters, some of which depend on your board. For this tutorial, we’ll use the following:

    - `GDB Server` > `Executable`:  `/Users/Oleg.Zinovyev/.espressif/tools/openocd-esp32/v0.12.0-esp32-20241016/openocd-esp32/bin/openocd`
    - `GDB Server` > `Arguments`: `-f board/esp32s3-builtin.cfg`

    {{< figure
    default=true
    src="img/24-esp-clion-gdb-server-options.webp"
        >}}

    - The `Device Settings` are as follows:

    {{< figure
    default=true
    src="img/25-esp-clion-device-settings.webp"
        >}}

    - `Debugger` > `Custom GDB Executable`: `/Users/Oleg.Zinovyev/.espressif/tools/xtensa-esp-elf-gdb/14.2_20240403/xtensa-esp-elf-gdb/bin/xtensa-esp32s3-elf-gdb`
    - `Debugger` > `Connection` > `Arguments`: `tcp::3333`

    {{< figure
    default=true
    src="img/26-esp-clion-debugger-options.webp"
        >}}

Also, it’s best to disable the `Persistent session` option on the `Debugger` tab, as it can be unstable.

8. Leave the rest of the default settings as they are and click `Apply`.
9. You can also run the GDB server in test mode to verify that the settings are correct.

{{< figure
default=true
src="img/27-esp-clion-debugger-test-run.webp"
    >}}

Here is what the `Test Run...` output looks like when the test is successful:

{{< figure
default=true
src="img/28-esp-clion-debugger-test-output.webp"
    >}}

10. Save your changes and close the `Debug Servers` configuration dialog.
11. Set a breakpoint in your source code file.
12. Click the green `Debug` icon on the main toolbar. The debug session will start.

You can then perform the necessary debugging actions and examine the application data.

{{< figure
default=true
src="img/29-esp-clion-debugging.webp"
    >}}

To learn more about CLion’s debugger features, read the [IDE’s documentation](https://www.jetbrains.com/help/clion/starting-the-debugger-session.html).

For further guidance about debugging your specific ESP32 chip, refer to the manufacturer’s documentation. There may be some peculiarities related to JTAG settings that you need to be aware of when configuring a debug server for a specific chip.

## Conclusion

At CLion, we strive to make the IDE a universal and convenient tool for developing any embedded system, whether hardware, framework, or toolchain. The same is true for ESP-IDF: We plan to simplify the workflow for these projects and are actively working on it.

We’d appreciate it if you use this tutorial for your ESP-IDF project and give us your feedback. If you have anything to share or if you encounter any problems, please let us know through our [issue tracker](https://youtrack.jetbrains.com/issues/CPP/).
