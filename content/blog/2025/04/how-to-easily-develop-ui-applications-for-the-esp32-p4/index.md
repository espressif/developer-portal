---
title: "How to Create an UI Application for the ESP32-P4"
date: 2025-04-14
showAuthor: false
tags: [ESP-IDF", "GUI", "Embedded Wizard", "ESP32-P4"]
authors:
    - "embedded-wizard-team"
---

The following article explains all necessary steps to create an Embedded Wizard UI application suitable for the [ESP32-P4-Function-EV-Board](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32p4/esp32-p4-function-ev-board/index.html) from Espressif.

Please follow these instructions carefully and step by step in order to ensure that you will get everything up and running on your target. In case you are not familiar with Embedded Wizard, please first read the chapter [basic concepts](https://doc.embedded-wizard.de/basic-concepts) and the [Quick Tour](https://doc.embedded-wizard.de/quick-tour) tutorial to understand the principles of Embedded Wizard and the GUI development workflow.

## Prerequisites

Although you can combine the ESP32-P4-Function-EV-Board with some other display panels, we highly recommend to start first with the following hardware components in order to ensure that you get the entire software up and running. As soon as you have your first UI application working on the recommended environment, you can start porting to your desired display.

First, make sure you have all of the following items:

### Hardware components

- [ESP32-P4-Function-EV-Board](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32p4/esp32-p4-function-ev-board/index.html) from Espressif
- USB cable to connect the board with your PC

### Software components

- Embedded Wizard Studio Free or Embedded Wizard Studio Pro

If you want to use the Free edition of Embedded Wizard Studio please [register on our website](https://www.embedded-wizard.de/download) and download the software.

As a customer, please visit the Embedded Wizard Download Center (login/password required) and download Embedded Wizard Studio Pro.

- [Embedded Wizard Build Environment for ESP32-P4-Function-EV-Board](https://doc.embedded-wizard.de/getting-started-esp32-p4-function-ev-board)

To evaluate Embedded Wizard on the mentioned target, you can find and download the suitable Build Environment for Embedded Wizard’s latest version under the category “software components” from the following link: https://doc.embedded-wizard.de/getting-started-esp32-p4-function-ev-board

As a customer, please visit the Embedded Wizard Download Center (login/password required) and download the latest version of the Build Environment and your licensed Platform Package libraries or source codes.

- [ESP-IDF V5.3.1 (stable) for ESP32-P4 from Espressif](https://docs.espressif.com/projects/esp-idf/en/v5.3.1/esp32p4/get-started/index.html)

### Installing Tools and Software

The following description assumes that you are familiar with ESP32-P4 software development and that you have installed the ESP32 toolchain for Windows.

** IMPORTANT! **

Before starting the GUI development with Embedded Wizard, please make sure to have the ESP32 software development environment (ESP-IDF) installed and first applications running on your ESP32-S3-BOX. Please follow the [ESP32-P4 Get Started documentation from Espressif](https://docs.espressif.com/projects/esp-idf/en/stable/esp32p4/get-started/index.html). Please also make sure that the ESP-IDF installation path (IDF_PATH) does not contain any space characters - otherwise building examples will fail.

- Step 1: Install the latest version of Embedded Wizard Studio.
- Step 2: Unpack the provided Embedded Wizard Build Environment for ESP32-P4-Function-EV-Board to your `\esp` development directory (e.g. `C:\ESP32\esp\ESP32-P4-Function-EV-Board`).

### Embedded Wizard GUI Demos

If you just want to run our GUI demos on your ESP32-P4-Function-EV-Board without building the different examples, you can simply flash the binary file of the Embedded Wizard Master Demo.

The Embedded Wizard Master Demo combines a variety of examples within one huge demo application. It can be used for presentations and showcases. Each demo application can be activated from a common main menu. To return back from a demo application to the main menu, a small home button appears on top of every demo. Additionally, the Master Demo contains an auto-demo mode that presents one demo application after the other. The auto-demo starts automatically and stops as soon as the user touches the screen.

In order to flash the binary file to your target, please follow these steps:

- Connect your development board with your PC via USB (make sure to use the USB-UART connector).
- Open a ESP-IDF PowerShell console (with all necessary settings for building an ESP-IDF project) and navigate to the directory of the Master Demo within the Build Environment `\esp\ESP32-P4-Function-EV-Board\main\MasterDemo`.
- Flash the MasterDemo by starting the following script:
```shell
python FlashMasterDemo.py
```

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-p4-function-ev-board-1.webp"
    alt="Picture of ESP32-P4 board."
    caption="Master Demo running on ESP32-P4-Function-EV-Board."
    >}}

### Exploring the Build Environment

The provided Embedded Wizard Build Environment for ESP32-P4-Function-EV-Board contains everything you need to create an Embedded Wizard UI application for the ESP32-P4-Function-EV-Board. After unpacking, you will find the following subdirectories and files within `\esp\ESP32-P4-Function-EV-Board\main`:

- `Application\GeneratedCode` - This folder is used to receive the generated code from an Embedded Wizard UI project. The template project is building the UI application out of this folder. You can create your own UI project and generate the code into the subdirectory `GeneratedCode` without the need to adapt the project.
- `Application\\Source` - This folder contains the files `main.c` and `ewmain.c`. There you will find the initialization of the system and the [main loop](https://doc.embedded-wizard.de/main-loop) to drive an Embedded Wizard GUI application. The file `ewconfig.h` contains general [configuration settings](https://doc.embedded-wizard.de/target-configuration) for the target system, like memory ranges and display parameter and configuration settings for the Embedded Wizard Graphics Engine and Runtime Environment. Additionally, this folder contains the device driver C/H files used for the DeviceIntegration example.

- `Examples\ScreenSize` - This folder contains a set of demo applications prepared for a dedicated screen size (1024x600 pixel). Each example is stored in a separate folder containing the entire Embedded Wizard UI project. Every project contains the necessary profile settings for the ESP32 target. The following samples are provided:
  - `HelloWorld` - A very simple project that is useful as starting point and to verify that the entire toolchain, your installation and your board is properly working.
  - `ColorFormats` - This project demonstrates that every UI application can be generated for different color formats: RGB565, Index8 and LumA44.
  - `ScreenOrientation` - - This demo shows, that the orientation of the UI application is independent of the physical orientation of the display.
  - `DeviceIntegration` - This example shows the integration of devices into a UI application and addresses typical questions: How to start a certain action on the target? How to get data from a device?
  - `GraphicsAccelerator` - This application demonstrates the graphics performance of the PPA hardware graphics accelerator. Sets of basic drawing operations are executed permanently and continuously.
  - `BezierClock` - The sample application BezierClock implements a fancy digital clock and timer application with animated digits. The application uses vector graphics to render dynamically the different digits for clock and timer. The change from one digit to another is handled by moving the vector points to get a smooth transition animation.
  - `BrickGame` - The sample application BrickGame implements a classic "paddle and ball" game. In the game, a couple of brick rows are arranged in the upper part of the screen. A ball travels across the screen, bouncing off the top and side walls of the screen. When a brick is hit, the ball bounces away and the brick is destroyed. The player has a movable paddle to bounce the ball upward, keeping it in play.
  - `PatientMonitor` - This application displays continuously measured data in an overwriting data recorder (such as an oscilloscope). The data graphs of the (simulated) measured values and the dialogs for user settings are presented in a modern, clean medical style. Dialogs are using blur filters to show the content behind them with a glass effect.
  - `PulseOximeter` - The sample application PulseOximeter shows the implementation of a medical device for monitoring a person's pulse frequency and peripheral oxygen saturation. The application demonstrates the usage of vector graphics within graphs and circular gauges.
  - `SmartThermostat` - The SmartThermostat demo application shows the implementation of a fancy, rotatable temperature controller to adjust and display the nominal and actual temperature.
  - `WashingMachine` - This demo shows the implementation of a washing machine with a couple of fancy scrollable list widgets to choose the washing program and parameters. The speciality of this sample application is the magnification effect of the centered list items and the soft fade-in/fade-out effects.
  - `WaveformGenerator` - This WaveformGenerator demo application combines waveforms with different amplitudes and frequencies. The implementation shows the usage of vector graphics to draw a curve based on a list of coordinates.
  - `MasterDemo` - This folder contains the binary file of the Embedded Wizard Master Demo application and a script file to flash the demo on your target. The Master Demo combines a variety of examples within one huge demo application. It can be used for presentations and showcases.

- `PlatformPackage` - This folder contains the necessary source codes and/or libraries of the ESP32 Platform Package: Several Graphics Engines for the supported color format RGB565 and the Runtime Environment (in the subdirectory `\RTE`).

- `TargetSpecific` - This folder contains all configuration files and platform specific source codes. The different ew_bsp_xxx files implement the bridge between the Embedded Wizard UI application and the underlying board support package (ESP hardware drivers) in order to access the display.

## Creating the UI Examples

For the first bring up of your system, we recommend to use the example `HelloWorld`:

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-p4-function-ev-board-2.webp"
    alt="Screenshot from Embedded Wizard Studio."
    caption="Picture: Example 'HelloWorld' within Embedded Wizard Studio."
    >}}

The following steps are necessary to generate the source code of this sample application:

- Navigate to the directory `\main\Examples\<ScreenSize>\HelloWorld`.

- Open the project file `HelloWorld.ewp` with your previously installed Embedded Wizard Studio. The entire project is well documented inline. You can run the UI application within the Prototyper by pressing Ctrl+F5.

- To start the code generator, select the menu items Build➤Build this profile - or simply press F8. Embedded Wizard Studio generates now the sources files of the example project into the directory `\main\Application\GeneratedCode`.

### Compiling, Linking and Flashing

The following steps are necessary to build and flash the Embedded Wizard UI sample application using the ESP-IDF toolchain:

- Open a console (with all necessary settings for building an ESP-IDF project) and navigate to the top level of the Build Environment `\esp\ESP32-P4-Function-EV-Board`.

- If you want to change or inspect the current settings, please insert:

```shell
idf.py menuconfig
```

- Start compiling and linking:

```shell
idf.py build
```

- Now you can flash the application:

```shell
idf.py flash
```

- In order to get outputs from the application and to provide key inputs, start the monitor:

```shell
idf.py monitor
```

If everything works as expected, the application should be built and flashed to the ESP32-P4-Function-EV-Board.

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-p4-function-ev-board-3.webp"
    caption="Picture: Example 'HelloWorld' running on ESP32-P4."
    >}}

All other examples can be created in the same way: Just open the desired example with Embedded Wizard Studio, generate code and rebuild the whole application using simply:

```shell
idf.py build
idf.py flash
idf.py monitor
```

Alternatively you can abbreviate it as one command:

```shell
idf.py build flash monitor
```

If you update just application code, you can speed up the flashing part by flashing only the application binary:

```shell
idf.py app-flash monitor
```

### Creating your own UI Applications

In order to create your own UI project suitable for the ESP32-P4-Function-EV-Board, you can create a new project and select the ESP32-P4-Function-EV-Board project template:

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-p4-function-ev-board-4.webp"
    caption="Picture: Create new Embedded Wizard Project."
    >}}

As a result you get a new Embedded Wizard project, that contains the necessary [Profile](https://doc.embedded-wizard.de/profile-member) attributes suitable for the ESP32-P4-Function-EV-Board:

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-p4-function-ev-board-5.webp"
    caption="Picture: Embedded Wizard Configuration."
    >}}

The following profile settings are important for your target: ★The attribute [PlatformPackage](https://doc.embedded-wizard.de/platformpackage-attr) should refer to the ESP32 Platform Package. The supported color formats are RGB565, Index8 and LumA44.

- The attribute [PlatformPackage](https://doc.embedded-wizard.de/platformpackage-attr) should refer to the ESP32 Platform Package. The supported color format is RGB565.

- The attribute [ScreenSize](https://doc.embedded-wizard.de/screensize-attr) should correspond to the display size of the ESP32-P4-Function-EV-Board.

- The attributes [ModeOfBitmapResources](https://doc.embedded-wizard.de/formatofbitmapresources-attr) and [ModeOfStringConstants](https://doc.embedded-wizard.de/formatofstringconstants-attr) should be set to DirectAccess. This ensures that resources are taken directly from flash memory. 

- The attribute [OutputDirectory](https://doc.embedded-wizard.de/outputdirectory-attr) should refer to the `\main\Application\GeneratedCode` directory within your Build Environment. By using this template, it will be very easy to build the UI project for your target.

- The attribute [CleanOutputDirectories](https://doc.embedded-wizard.de/cleanoutputdirectories-attr) should be set to `true` to ensure that unused source code within the output directory `\main\Application\GeneratedCode` will be deleted.

Now you can use the template project in the same manner as it was used for the provided examples to compile, link and flash the binary.

After generating code, please follow these steps, in order to build your own UI application:

- Start compiling, linking and flashing:

```shell
idf.py build
idf.py flash
idf.py monitor
```

Most of the project settings are taken directly out of the generated code, like the color format or the screen orientation. All other settings can be made directly within the file ewconfig.h, which contains general [configuration settings](https://doc.embedded-wizard.de/target-configuration) for the target system.

### Console output

In order to receive error messages or to display simple debug or trace messages from your Embedded Wizard UI application, a serial terminal like 'Putty' or 'TeraTerm' should be used or the monitor that is started together with `idf.py monitor`

{{< figure
    default=true
    src="img/how-to-create-an-ui-application-for-the-esp32-p4-function-ev-board-6.webp"
    caption="Picture: Console output."
    >}}

This terminal connection can be used for all [trace statements](https://doc.embedded-wizard.de/trace-statement) from your Embedded Wizard UI applications or for all debug messages from your C code.

You can find all release notes and the version history of the Build Environment (including Graphics Engine and Runtime Environment) for the ESP32-S3-BOX at the bottom of [this page](https://doc.embedded-wizard.de/getting-started-esp32-s3-box). These release notes describe only the platform specific aspects - for all general improvements and enhancements please see the [Embedded Wizard release notes](https://doc.embedded-wizard.de/release-notes).

