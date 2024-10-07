---
title: "How to Create an UI Application for the ESP32-S3"
date: 2024-10-02
showAuthor: false
tags: ["ESP32", "ESP-IDF", "GUI", "Embedded Wizard", "ESP32-S3", "ESP32-S2"]
authors:
    - "embedded-wizard-team"
---

The following article explains all necessary steps to create an Embedded Wizard GUI application suitable for the ESP32-S3-BOX from Espressif.

Please follow these instructions carefully and step by step in order to ensure that you will get everything up and running on your target. In case you are not familiar with Embedded Wizard, please first read the chapter [basic concepts](https://doc.embedded-wizard.de/basic-concepts) and the [Quick Tour](https://doc.embedded-wizard.de/quick-tour) tutorial to understand the principles of Embedded Wizard and the GUI development workflow.

## Introduction: External display controller and partial display updates

The ESP32-S3-BOX combines the ESP32-S3 micro-controller (MCU) with a 320x240 display, connected via SPI. The display is driven by an external display controller, which contains its own display memory. As a result, the entire framebuffer can be located inside the display controller and only a small [scratch-pad buffer](https://doc.embedded-wizard.de/framebuffer-concepts#7) is needed inside the micro-controller (MCU). For this purpose, Embedded Wizard supports a partial display update, that makes it possible to update the display in sequential small areas. This makes it possible to operate with a scratch-pad buffer of a few kilobytes instead of a full-screen framebuffer within the memory space of the MCU.

Please note: The partial display update is intended to be used for extremely memory-constrained systems. Due to the fact that the display update is done in subsequent updates of small areas, moving graphical objects can cause some tearing effects. The UI design should consider this aspect.

## Prerequisites

Although you can combine the ESP32-S3-BOX with many different display controllers or your own hardware, we highly recommend to start first with the following hardware components in order to ensure that you get the entire software up and running. As soon as you have your first UI application working on the recommended environment, you can start porting to your desired display controller.

First, make sure you have all of the following items:

### Hardware components

- [ESP32-S3-BOX](https://www.espressif.com/en/news/ESP32-S3-BOX_video) from Espressif
- USB cable to connect the board with your PC

### Software components

- Embedded Wizard Studio Free or Embedded Wizard Studio Pro

If you want to use the Free edition of Embedded Wizard Studio please [register on our website](https://www.embedded-wizard.de/download) and download the software.

As a customer, please visit the Embedded Wizard Download Center (login/password required) and download Embedded Wizard Studio Pro.

- Embedded Wizard Build Environment for ESP32-S3-BOX

To evaluate Embedded Wizard on the mentioned target, you can find and download the suitable Build Environment for Embedded Wizard’s latest version under the category “software components” from the following link: https://doc.embedded-wizard.de/getting-started-esp32-s3-box

As a customer, please visit the Embedded Wizard Download Center (login/password required) and download the latest version of the Build Environment and your licensed Platform Package libraries or source codes.

### Installing Tools and Software

The following description assumes that you are familiar with ESP32-S3 software development and that you have installed the ESP32 toolchain for Windows.

IMPORTANT! Before starting the GUI development with Embedded Wizard, please make sure to have the ESP32 software development environment (ESP-IDF) installed and first applications running on your ESP32-S3-BOX. Please follow the [ESP32-S3 Get Started documentation from Espressif](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/get-started/index.html). Please also make sure that the ESP-IDF installation path (IDF_PATH) does not contain any space characters - otherwise building examples will fail.

- Step 1: Install the latest version of Embedded Wizard Studio.
- Step 2: Unpack the provided Embedded Wizard Build Environment for ESP32-S3-BOX to your `\\esp` development directory (e.g. `C:\\ESP32\\esp\\ESP32-S3-BOX`).

### Exploring the Build Environment

The provided Embedded Wizard Build Environment for ESP32-S3-BOX contains everything you need to create an Embedded Wizard UI application for the ESP32-S3-BOX. After unpacking, you will find the following subdirectories and files within `\\esp\\ESP32-S3-BOX\\main`:

- `Application\\GeneratedCode` - This folder is used to receive the generated code from an Embedded Wizard UI project. The template project is building the UI application out of this folder. You can create your own UI project and generate the code into the subdirectory `\\GeneratedCode` without the need to adapt the project.

- `Application\\Source` - This folder contains the files main.c and ewmain.c. There you will find the initialization of the system and the [main loop](https://doc.embedded-wizard.de/main-loop) to drive an Embedded Wizard GUI application. The file ewconfig.h contains general configuration settings for the target system, like memory ranges and display parameter and [configuration settings](https://doc.embedded-wizard.de/target-configuration) for the Embedded Wizard Graphics Engine and Runtime Environment. Additionally, this folder contains the device driver C/H files used for the DeviceIntegration example.

- `Examples\\ScreenSize` - This folder contains a set of demo applications prepared for a dedicated screen size (320x240 pixel). Each example is stored in a separate folder containing the entire Embedded Wizard UI project. Every project contains the necessary profile settings for the ESP32 target. The following samples are provided:
  - `HelloWorld` - A very simple project that is useful as starting point and to verify that the entire toolchain, your installation and your board is properly working.
  - `ColorFormats` - This project demonstrates that every UI application can be generated for different color formats: RGB565, Index8 and LumA44.
  - `ScreenOrientation` - This demo shows, that the orientation of the UI application is independent from the physical orientation of the display.
  - `DeviceIntegration` - This example shows the [integration of devices](https://doc.embedded-wizard.de/device-class-and-device-driver) into a UI application and addresses typical questions: How to start a certain action on the target? How to get data from a device?
  - `GraphicsAccelerator` - This application demonstrates the graphics performance of the target by using sets of basic drawing operations that are executed permanently and continuously.
  - `AnimatedList` - This demo shows the implementation of some fancy scrollable list widgets to set a time and a day of the week. The speciality of this sample application is the magnification effect of the centered list items and the soft fade-in/fade-out effects.
  - `BrickGame` - The sample application BrickGame implements a classic "paddle and ball" game. In the game, a couple of brick rows are arranged in the upper part of the screen. A ball travels across the screen, bouncing off the top and side walls of the screen. When a brick is hit, the ball bounces away and the brick is destroyed. The player has a movable paddle to bounce the ball upward, keeping it in play.
  - `ClimateCabinet` - The ClimateCabinet demo shows the implementation of a control panel for a climatic exposure test cabinet. The user can define a heating time, a nominal temperature and humidity, a dwell time and the final cooling time.
  - `WaveformGenerator` - This WaveformGenerator demo application combines waveforms with different amplitudes and frequencies. The implementation shows the usage of vector graphics to draw a curve based on a list of coordinates.

- `PlatformPackage` - This folder contains the necessary source codes and/or libraries of the ESP32 Platform Package: Several Graphics Engines for the different color formats (RGB565, Index8 and LumA44) and the Runtime Environment (in the subdirectory `\\RTE`).

- `TargetSpecific` - This folder contains all configuration files and platform specific source codes. The different ew_bsp_xxx files implement the bridge between the Embedded Wizard UI application and the underlying board support package (ESP hardware drivers) in order to access the display.

- `ThirdParty` - This folder contains third-party source codes (BSP).

## Creating the UI Examples

For the first bring up of your system, we recommend to use the example 'HelloWorld':

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-3-picture-1-example-helloworld-within-embedded-wizard-studio.webp"
    alt="Screenshot from Embedded Wizard Studio."
    caption="Picture: Example 'HelloWorld' within Embedded Wizard Studio."
    >}}

The following steps are necessary to generate the source code of this sample application:

- Navigate to the directory `\\main\\Examples\\ScreenSize\\HelloWorld`.

- Open the project file HelloWorld.ewp with your previously installed Embedded Wizard Studio. The entire project is well documented inline. You can run the UI application within the Prototyper by pressing Ctrl+F5.

- To start the code generator, select the menu items Build➤Build this profile - or simply press F8. Embedded Wizard Studio generates now the sources files of the example project into the directory `\\main\\Application\\GeneratedCode`.

### Compiling, Linking and Flashing

The following steps are necessary to build and flash the Embedded Wizard UI sample application using the MSYS2 MINGW32 toolchain:

- Open a console (with all necessary settings for building an ESP-IDF project) and navigate to the top level of the Build Environment `\\esp\\ESP32-S3-BOX`.

- If you want to change or inspect the current settings, please insert:

```shell
idf.py menuconfig
```

- Start compiling and linking:

```shell
idf.py build
```

- Now you can flash the application (by using the appropriate COM port):

```shell
idf.py -p COMxx flash
```

- In order to get outputs from the application and to provide key inputs, start the monitor:

```shell
idf.py -p COMxx monitor
```

If everything works as expected, the application should be built and flashed to the ESP32-S3-BOX.

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-3-picture-2-example-helloworld-running-on-esp32-3-box.webp"
    caption="Picture: Example 'HelloWorld' running on ESP32-S3-BOX."
    >}}

All other examples can be created in the same way: Just open the desired example with Embedded Wizard Studio, generate code and rebuild the whole application using simply:

```shell
idf.py build
idf.py -p COMxx flash
idf.py -p COMxx monitor
```

Alternatively you can abbreviate it as one command:

```shell
idf.py -p COMxx build flash monitor
```

If you update just application code, you can speed up the flashing part by flashing only the application binary:

```shell
idf.py -p COMxx app-flash monitor
```

### Creating your own UI Applications

In order to create your own UI project suitable for the ESP32-S3-BOX, you can [create a new](https://doc.embedded-wizard.de/create-new-project-dialog) project and select the ESP32-S3-BOX project template:

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-3-picture-3-select-esp32-3-box.webp"
    caption="Picture: Create new Embedded Wizard Project."
    >}}

As a result you get a new Embedded Wizard project, that contains the necessary [Profile attributes](https://doc.embedded-wizard.de/profile-member) suitable for the ESP32-S3-BOX:

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-3-picture-4-profile-attributes-suitable-for-the-esp32-3.webp"
    caption="Picture: Embedded Wizard Configuration."
    >}}

The following profile settings are important for your target: ★The attribute [PlatformPackage](https://doc.embedded-wizard.de/platformpackage-attr) should refer to the ESP32 Platform Package. The supported color formats are RGB565, Index8 and LumA44.

- The attribute [ScreenSize](https://doc.embedded-wizard.de/screensize-attr) should correspond to the display size of the ESP32-S3-BOX.

- The attributes [ModeOfBitmapResources](https://doc.embedded-wizard.de/formatofbitmapresources-attr) and [ModeOfStringConstants](https://doc.embedded-wizard.de/formatofstringconstants-attr) should be set to DirectAccess. This ensures that resources are taken directly from flash memory. 

- The attribute [OutputDirectory](https://doc.embedded-wizard.de/outputdirectory-attr) should refer to the \main\Application\GeneratedCode directory within your Build Environment. By using this template, it will be very easy to build the UI project for your target.

- The attribute [CleanOutputDirectories](https://doc.embedded-wizard.de/cleanoutputdirectories-attr) should be set to true to ensure that unused source code within the output directory \main\Application\GeneratedCode will be deleted.

Now you can use the template project in the same manner as it was used for the provided examples to compile, link and flash the binary.

After generating code, please follow these steps, in order to build your own UI application:

- Start compiling, linking and flashing:

```shell
idf.py build
idf.py -p COMxx flash
idf.py -p COMxx monitor
```

Most of the project settings are taken directly out of the generated code, like the color format or the screen orientation. All other settings can be made directly within the file ewconfig.h, which contains general [configuration settings](https://doc.embedded-wizard.de/target-configuration) for the target system.

### Console output

In order to receive error messages or to display simple debug or trace messages from your Embedded Wizard UI application, a serial terminal like 'Putty' or 'TeraTerm' should be used or the monitor that is started together with `idf.py -p COMxx monitor`

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-3-picture-5-console-output.webp"
    caption="Picture: Console output."
    >}}

This terminal connection can be used for all [trace statements](https://doc.embedded-wizard.de/trace-statement) from your Embedded Wizard UI applications or for all debug messages from your C code.

You can find all release notes and the version history of the Build Environment (including Graphics Engine and Runtime Environment) for the ESP32-S3-BOX at the bottom of [this page](https://doc.embedded-wizard.de/getting-started-esp32-s3-box). These release notes describe only the platform specific aspects - for all general improvements and enhancements please see the [Embedded Wizard release notes](https://doc.embedded-wizard.de/release-notes).

