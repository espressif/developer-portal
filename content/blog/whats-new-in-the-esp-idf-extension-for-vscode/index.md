---
title: "What’s new in the ESP-IDF extension for VSCode"
date: 2022-01-30
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - brian-ignacio
tags:
  - Esp Idf
  - Espressif
  - Vscode
  - Theia
  - Esp32

---
Co-authored with Kondal Kolipaka

The [ESP-IDF extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension) aims to help users to write code with Espressif chips using ESP-IDF and other frameworks. We constantly try to improve the extension usability and add features to enhance the user developing experience.

The latest features we have added are:

__ESP-IDF QEMU integration__

[QEMU](https://www.qemu.org/) is an open-source machine emulator commonly used to emulate operating systems and many hardware devices. Espressif has a [QEMU fork](https://github.com/espressif/qemu) with ESP32 as a possible target which can be used to emulate in software the behavior of a real ESP32 device.

We added this QEMU fork in a Dockerfile used with the project template file .devcontainer (You can add these files to an existing project with the __ESP-IDF: Add docker container configuration__ command) so the user can open a project in a container using the __Remote-Containers: Open Folder in container…__ command____ from the [Remote Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

The __ESP-IDF: QEMU Manager__ command____ will____ run the current project application binary in an emulated ESP32. If you execute the __ESP-IDF: Monitor QEMU device__ it will open____ a monitor session to observe the application output. You can also use __ESP-IDF: Launch QEMU debug session__  command to start a debug session as shown below.

Find more information on this feature in [here](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/additionalfeatures/qemu.html).

{{< figure
    default=true
    src="img/whats-1.webp"
    >}}

__Partition Table Editor__

Now you should be able to get partition table information for the device connected and be allowed to select any .bin file to flash to a given partition.

To see the partitions of the current serial port, execute the __ESP-IDF: Refresh partition table__  and use the sdkconfig partition offset or a custom partition offset to see the current partitions of your device in the ESP-IDF Explorer tab.

When you can click on any partition, either you can flash a .bin file to this partition or launch the __ESP-IDF: Partition Table Editor UI__ to edit the partition table. You could also right-click on the .bin file to flash it to one of the partitions in the Device partition explorer.

{{< figure
    default=true
    src="img/whats-2.webp"
    >}}

{{< figure
    default=true
    src="img/whats-3.webp"
    >}}

{{< figure
    default=true
    src="img/whats-4.webp"
    >}}

__Importing an existing ESP-IDF Project__

Added the __Import ESP-IDF Project__ command to the extension. This command will copy an existing ESP-IDF project and add *.vscode* configuration and *.devcontainer* files into a new project to be saved in a given location and project name.

__Integrated ESP-IDF Component registry__

[IDF Component registry](https://components.espressif.com/) is integrated into the extension and this allows users to add a component to your project. Run the __ESP-IDF: Show Component registry__ command____ to launch components page.

{{< figure
    default=true
    src="img/whats-5.webp"
    >}}

IDF Component Registry running in Visual Studio Code

__Welcome Page__

Added a new welcome page with documentation links and buttons for basic features of the extension. You can run the __ESP-IDF: Welcome__  command to launch it.

{{< figure
    default=true
    src="img/whats-6.webp"
    >}}

__Other notable improvements and features__

- Use gdb commands directly for Heap tracing. Before we were using openOCD TCL commands to start and stop the heap tracing but now we are using gdb commands with a gdb file instead. To learn more about heap tracing please review the [ESP-IDF documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/heap_debug.html#heap-tracing) and the [heap tracing extension tutorial](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/additionalfeatures/heap-tracing.html).
- Added idf-size.py output after build task. This is done after executing the __ESP-IDF: Build your project__  or__ESP-IDF: Build, flash and start a monitor__ command. This will help users to understand the amount of memory used in their applications and [reduce the binary size](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/performance/size.html).

{{< figure
    default=true
    src="img/whats-7.webp"
    >}}

- Added JTAG flashing type in the Build, flash and monitor command. Before it was only using UART flashing, but now it will use the flash type defined in the __idf.flashType__ configuration setting.
- Added the __Configure project for coverage__  command to set the required values in your project’s sdkconfig file to enable code coverage for your project. This is necessary if you want to enable the code coverage feature in the extension as shown in the [code coverage tutorial](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/additionalfeatures/coverage.html).
- Using portable git and python in the extension setup workflow for Windows users. Now Windows users don’t need to install any prerequisites when configuring the extension using the __ESP-IDF: Configure ESP-IDF extension__  setup wizard.
- Enable and disable CMakeLists.txt SRCS field update whenever .c files are created or deleted. Use the i__df.enableUpdateSrcsToCMakeListsFile__  configuration setting to enable and disable it.
- Use Espressif download mirrors for the extension setup wizard. Now if downloading from Github is slow in your location you can choose the download server in the __ESP-IDF: Configure ESP-IDF extension__  setup wizard.
- Added serial port and IDF target in the VSCode status bar and add the commands to change them on click.

{{< figure
    default=true
    src="img/whats-8.webp"
    >}}

- Now users are allowed to configure pre-build, post-build, pre-flash, post flash, and custom tasks (with status bar icon for the custom task) with added configuration settings. You can use the __idf.preBuildTask__  to define a task before the build task, the __idf.postBuildTask__  after the build task, the __idf.preFlashTask__ before the flash task and the__idf.postFlashTask__ after the flash task. There is also an __idf.customTask__ which can be used with the __ESP-IDF: Execute custom task__ (which has a status bar icon).
- Now you should be able to control the settings to enable/disable notifications for extension commands completion and show the task output when hidden. Using the __idf.notificationSilentMode__ configuration setting to true will hide VSCode notifications from this extension such as *Build Successful* and *flash done* and show the task output directly.

## ESP-IDF cloud IDE based on Eclipse Theia

We are fascinated to build robust tools and IDEs to improve the productivity of esp-idf developers by leveraging the latest cloud technologies.

Eclipse Theia is an extensible framework to develop full-fledged multi-language Cloud & Desktop IDE-like products with state-of-the-art web technologies. It offers to install our existing [IDF VSCode extension](https://github.com/espressif/vscode-esp-idf-extension) and work seamlessly.

We have been working on this for quite some time and we have shown this work-in-progress model during EclispeCon 2021 conference. It’s an internal project for now! Please take a look to see what it means to be working on Eclipse Theia cloud IDE and what it offers.

## What’s next?

The extension is far from complete. We are continuously improving existing and adding new and interesting features for you! Some of the things we are looking into are:

- Extend QEMU and features related to emulated devices.
- Improve the heap tracing UI and functionality
- Extend debugging experience adding registers and memory view, disassemble view, and data watchpoints.
- Integration with new frameworks such as [NuttX](https://github.com/espressif/esp-nuttx-bootloader) and [Matter](https://github.com/espressif/connectedhomeip)
- Many more!

## Related links

- [Make a feature request or report an issue with the extension](https://github.com/espressif/vscode-esp-idf-extension/issues/new/choose)
- [Extension tutorials](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/index.html)
- [ESP32 IDE Forum](https://esp32.com/viewforum.php?f=40)

Espressif also offers an __esp-idf plugin for eclipse__  enthusiasts, please check this out [here](https://github.com/espressif/idf-eclipse-plugin)!
