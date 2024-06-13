---
title: "Espressif IDE Workshop"
date: 2024-06-03T00:00:00+01:00
disableComments : true
tags: ["Workshop"]
series: ["IDE"]
series_order: 2
authors:
    - pedro-minatel
---

## Espressif IDE Workshop

### About this workshop

This hands-on workshop will introduce the Espressif IoT Development Framework (ESP-IDF) through the Integrated Development Environment (IDE). After this workshop, you will be able to use IDEs to enhance the development performance of your projects.

Participants will learn how to install and configure the Espressif IDE on various operating systems, including Windows, Linux, and macOS. The workshop also covers the hardware prerequisites, such as the ESP32 board with a USB to serial interface and/or debug port, and software prerequisites, including Java, Python, Git, and specific versions of Espressif IDE and ESP-IDF. 

The workshop is estimated to take between 30 to 45 minutes to complete. It is designed to be interactive and engaging, providing participants with practical skills and knowledge that they can apply to their own IoT development projects.

In this part, the Eclipse bundle, **Espressif IDE**, will be introduced.

### Prerequisites

To follow this workshop, ensure you meet the prerequisites described below.

#### Hardware Prerequisites

- Windows, Linux, or macOS
- ESP32 board with a USB to serial interface and/or debug port
  - USB CDC/JTAG
- USB cable compatible with your development board

#### Software prerequisites

*Required for manual installation*

- [UsbDriverTool](https://visualgdb.com/UsbDriverTool/)
- [Java 17 or above](https://www.oracle.com/technetwork/java/javase/downloads/index.html)
- [Python 3.6 or above](https://www.python.org/downloads/)
- [Git](https://git-scm.com/downloads)
- [Espressif IDE 3.0.0]()
- [ESP-IDF v5.2]()

#### Downloads

- [ESP-IDF Offline Installer for Windows](https://dl.espressif.com/dl/esp-idf/) (recommended for Windows users)
- [Espressif-IDE v3.0.0 macOS aarch64](https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-macosx-cocoa-aarch64-v3.0.0.dmg)
- [Espressif-IDE v3.0.0 macOS x86-64](https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-macosx-cocoa-x86_64-v3.0.0.dmg)
- [Espressif-IDE v3.0.0 Windows](https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-3.0.0-win32.win32.x86_64.zip)
- [Espressif-IDE v3.0.0 Linux](https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-3.0.0-linux.gtk.x86_64.tar.gz)

#### Extra resources

{{< github repo="espressif/idf-eclipse-plugin" >}}

#### Completion time

{{< alert icon="mug-hot">}}
**Estimated completion time: 30 to 45 min**
{{< /alert >}}

### Installation

Now it's time to install the Espressif IDE. Please follow the instructions according to your operating system.

#### Windows

For Windows, the recommended method is to install using the [ESP-IDF offline installer](https://dl.espressif.com/dl/esp-idf/). If you already have the ESP-IDF installed on your system and you are currently working with it, you can reuse the installation and proceed directly with the [Espressif IDE installation](https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-3.0.0-win32.win32.x86_64.zip).

Please follow the instructions in the step-by-step guide:

#### Linux and macOS

If your system is Linux or macOS, you can install the Espressif IDE using the links provided in the [downloads section](#downloads).

Make sure to install all [prerequisites](#software-prerequisites) before continuing with the Espressif IDE installation.

#### Installing ESP-IDF

To install the ESP-IDF, you can do it in two different ways:

- Manual installation
- ESP-IDF Manager (Espressif IDE tool)

Depending on your operating system, we recommend installing via the offline installer. If your operating system does not support it, then the installation can be done via the ESP-IDF Manager inside the Espressif IDE.

The manual installation can also be used as an alternative solution.

For this workshop, we will skip the manual installation, however, you can see how it works in our [Get Started Guide](https://docs.espressif.com/projects/esp-idf/en/release-v5.3/esp32c6/get-started/index.html#manual-installation).

After the installation process is completed, you will be able to open the Espressif IDE.


The first step is to select your workspace folder. This folder is where all your projects will be stored.

![Workspace](assets/espressif-ide-1.webp "Espressif IDE Workspace selection")

Once you have selected it, you can proceed by clicking on the `Launch` button.

![Espressif-IDE](assets/espressif-ide-16.webp "Espressif IDE welcome screen")

#### Installing, upgrading or downgrading ESP-IDF versions

Before creating the first project, we need to install the ESP-IDF.

![Workspace](assets/espressif-ide-17.webp)

![Workspace](assets/espressif-ide-18.webp)

![Workspace](assets/espressif-ide-19.webp)

![Workspace](assets/espressif-ide-20.webp)

![Workspace](assets/espressif-ide-21.webp)

![Workspace](assets/espressif-ide-22.webp)

![Workspace](assets/espressif-ide-23.webp)

![Workspace](assets/espressif-ide-24.webp)

![Workspace](assets/espressif-ide-25.webp)

> TODO: Install the ESP-IDF 5.3

### Creating a new project

To create a new project, go to `File` -> `New` -> `Project`.

![Create New Project](assets/espressif-ide-2.webp)

On the **New Project** screen, select `Espressif` -> `Espressif IDF Project` and click `Finish`.

![New Project](assets/espressif-ide-3.webp)

Now we will select the `Create a project using one of the templates` and select the **blink** project.

![Create New Project Example](assets/espressif-ide-4.webp)

Select the target for this project, in this case, the **ESP32-C6**.

![Select the SoC](assets/espressif-ide-5.webp)

Click `Finish` to create the project in the selected workspace.

### Building the Project

Building the project is done by clicking the button with a hammer icon, as shown in the next image.

![Build the Project](assets/espressif-ide-6.webp)

By clicking the build button, the build process will start. This operation can take a while depending on your operating system.

![Create New Project](assets/espressif-ide-7.webp)

After the build is complete, you will be able to flash the application to the device.

### Project Configuration

If you need to change any project or ESP-IDF configuration, this can be done by opening the `sdkconfig` file. After opening this file, you will see the SDK configuration interface, as shown in the image.

![Create New Project](assets/espressif-ide-14.webp)

> Please note that if you change anything in this file, the build process will rebuild everything.

### Flashing the Device

Before flashing the device, we need to define the communication port by clicking on the gear icon.

![Target configuration](assets/espressif-ide-15.webp)

If your board is already connected to your computer, and the operating system is able to recognize it, you will see the available COM ports in the drop-down menu.

{{< alert icon="comment">}}
**Make sure you are using the devkit USB port labeled as USB**
{{< /alert >}}

You can also debug using an external JTAG, like the [ESP-PROG]().

Please select the one recognized as `USB JTAG/serial debug unit`.

![Create New Project](assets/espressif-ide-8.webp)

Once you select the correct communication port, the board will be detected as you can see in the image.

![Create New Project](assets/espressif-ide-9.webp)

Now to flash, you can click on the green orb with a "play" icon labeled as `Launch in 'run' mode`.

![Create New Project](assets/espressif-ide-10.webp)

After a successful flashing procedure, you will see the message in the console output:

![Create New Project](assets/espressif-ide-11.webp)

If everything worked, you will see the RGB LED blinking in white color.

> TODO: Add a gif with the board blinking.

### Monitoring the Serial Output

In this project, the application will print some log output from the USB serial interface.

![Create New Project](assets/espressif-ide-12.webp)

![Create New Project](assets/espressif-ide-13.webp)

### Debugging

Debugging is a crucial part of software development. It allows you to find and fix issues in your code. When working with ESP32, the Espressif IDE provides a built-in debugger that can be used to debug your applications.

To start debugging, you first need to build and flash your project to the target device.

Once the project is built, you can start a debugging session by clicking on the bug icon in the IDE. This will launch the debugger and attach it to your ESP32 device. There is an option to build and flash every time you start debugging, however, we will disable this option for this workshop to save time.

> TODO

During a debugging session, you can control the execution of your program by setting breakpoints, stepping through your code, inspecting variables, and watching expressions. Breakpoints can be set by clicking in the margin of the code editor next to the line of code where you want the breakpoint.

> TODO

When the program execution hits a breakpoint, it will pause, and you can inspect the current state of your program. The IDE provides several views to inspect the state of your program, such as the Variables view, the Call Stack view, and the Watch view.

Remember, debugging is a powerful tool that can help you understand how your code is executing and where problems may be occurring.

### Tools

#### Partition table editor

#### Components

### Conclusion

In this workshop, we have walked through the process of setting up and using the Espressif IDE for ESP32 development. We've covered the installation process, project creation, building and flashing the project to the device, and using the built-in debugger to troubleshoot your code. 

We've also briefly touched on some of the additional tools provided by the IDE, such as the partition table editor and component manager/registry. These tools further enhance the development experience by providing more control and customization options for your IoT projects.

By now, you should have a solid understanding of how to use the Espressif IDE for your ESP32's projects. Remember, the key to mastering any new tool is practice. Don't hesitate to experiment with different settings and features, and always be on the lookout for ways to improve your workflow.

Thank you for participating in this workshop. We hope you found it informative and helpful. Happy coding!

### Next steps

- [ESP-IDF Workshop]()
