---
title: "ESP-IDF Basics - Assign. 1.1"
date: "2025-08-05"
lastmod: "2026-01-20"
series: ["WS00A"]
series_order: 2
showAuthor: false
---

> Create a new project starting from the hello world example and change the displayed string (Guided).

## Assignment steps

In this assignment you will:
1. Create a new project starting from the `hello_world` example
2. Change the displayed string.

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
In this workshop, we'll be using ESP-IDF Extension for VS Code. If you didn't install it yet, please follow [these instructions](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/).
{{< /alert >}}

## Step 1: Create a new project starting from the `hello_world` example

In this section, we will:

1. Create a new project from an example
2. Build the project
3. Flash and monitor

Please note that most commands in VS Code are executed through the __Command Palette__, which you can open by pressing `Ctrl`+`Shift`+`P` (or `Cmd`+`Shift`+`P`)

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
  In this guide, commands to enter in the __Command Palette__ are marked with the __symbol `>`__. Usually it is sufficient to type a few character of the command, then a dropdown menu will help you find the right one.
{{< /alert >}}


### Create a new project from an example

1. Open VS Code
2. `> ESP-IDF: Show Example Project`
3. (If asked) Choose the ESP-IDF version
4. Click on `get_started` &rarr; `hello_world`
5. Click on the button `Select Location for Creating hello_world Example` in the new tab.

<!-- ![Create new project tab](../assets/ass1_1_new_project.webp) -->
{{< figure
default=true
src="../assets/ass1-1-new-project.webp"
height=500
caption="Fig.1 - Create new project tab"
    >}}

A new window will open with the following file structure:

<!-- ![Create new project tab](../assets/ass1_1_new_project.webp) -->
{{< figure
default=true
src="../assets/ass1-1-hello-world-files.webp"
height=500
caption="Fig.2 - `hello_world` example files"
    >}}

For now, you can ignore the folders `.vscode`, `.devcontainer`, and `build`. You will work on the `main/hello_world_main.c` file.

### Build the project

To compile (_build_) your project, you first need to tell the compiler which core (called _target_) you are using. You can do it through the IDE as follows:

* `> ESP-IDF: Set Espressif Device Target`
* In the dropdown menu, choose `esp32c3` &rarr; `ESP32-C3 chip (via builtin USB-JTAG)`

Now you're ready to compile your project:
* `> ESP-IDF: Build Your Project`
   _You can also click on the small &#128295; icon located in the bottom bar_

A terminal tab will open at the bottom of your IDE and show the successful compilation and size of the compiled binary.

<!-- ![Create new project tab](../assets/ass1_1_new_project.webp) -->
{{< figure
default=true
src="../assets/ass1-1-compilation-result.webp"
height=500
caption="Fig.3 - Compilation result"
    >}}

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
If you have problems that are hard to debug, it is useful to do a full clean of your project by using the command `> ESP-IDF: Full clean project`.
{{< /alert >}}

### Flash and monitor

To see the firmware running, you need to store it on the device (_flash_) and then you need to read the output it emits on the serial port (_monitor_).

* Connect the board to your workstation
* Check that the device is recognized<br>
   _If you don't know how, check [this guide](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/establish-serial-connection.html#check-port-on-windows)_
* Note the name assigned to the Espressif device
   * On Windows, it starts with `COM`
   * On Linux/macOS, it starts with `tty` or `ttyUSB`
* Inform the IDE about the port the board is connected at<br>
   `> ESP-IDF: Select Port to Use (COM, tty, usbserial)`

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
If you're having trouble, check the [Establish Serial Connection with ESP32 Guide](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/establish-serial-connection.html#establish-serial-connection-with-esp32).
{{< /alert >}}

Now you can flash and monitor your device.

* `> ESP-IDF: Build, Flash and Start a Monitor on Your Device`
* If a dropdown menu appears, choose `UART`

In the terminal, you should now see the `Hello World!` string and the countdown before the reset.

<!-- ![Create new project tab](../assets/ass1_1_monitor.webp) -->
<!-- {{< figure
default=true
src="../assets/ass1-1-monitor.webp"
height=500
caption="Fig.4 - Monitor"
    >}} -->

{{< asciinema
  key="hello_world"
  idleTimeLimit="2"
  speed="1.5"
  poster="npt:0:09"
>}}


## Step 2: Change the displayed string

Identify the output string and change it to `Hello LED`.

## Conclusion

You can now create a new project and flash it on the board. In the next assignment, we'll consolidate this process.

### Next step
> Next assignment &rarr; [Assignment 1.2](../assignment-1-2/)

> Or [go back to navigation menu](../#agenda)
