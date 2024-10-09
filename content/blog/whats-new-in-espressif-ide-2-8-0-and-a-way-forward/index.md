---
title: "What’s New in Espressif-IDE 2.8.0 and a Way Forward"
date: 2023-02-01
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kondal-kolipaka
tags:
  - Espressif-IDE 2.8.0
  - Espresif-IDE
  - bug fixes
  - Espressif Ide
  - Esp Idf
  - Espressif
  - Eclipse

---
{{< figure
    default=true
    src="img/whats-1.webp"
    >}}

[Espressif-IDE 2.8.0](https://github.com/espressif/idf-eclipse-plugin/releases/tag/v2.8.0) was released recently, featuring a Partition table editor NVS Partition Editor along with enhancements in the Debugger Configuration and many more bug fixes to stabilize and improve the overall quality of the plugin.

You can get the latest version using the [update site](https://dl.espressif.com/dl/idf-eclipse-plugin/updates/latest/), but if you’re starting for the first time and you’re a Windows user, I would recommend using the [Espressif-IDE Windows Offline installer](https://dl.espressif.com/dl/esp-idf/) which does most of the work of installing all the prerequisites, esp-idf, esp-idf tools, and device drivers required to work with espressif chips. Here is the current version of [Espressif-IDE 2.8.0 with ESP-IDF 5.0 Installer](https://dl.espressif.com/dl/esp-idf/). If you’re a mac or Linux user, get [Espresif-IDE](https://github.com/espressif/idf-eclipse-plugin/releases/tag/v2.8.0) instead of Eclipse CDT and then installing the IDF Eclipse Plugin separately.

Espressif-IDE 2.8.0 is bundled with the Eclipse CDT 2022–09 package and it has Java 11 support. We would recommend not updating to the latest version of Eclipse CDT 2022–12 as we have not added support yet.

## Here are the new features and improvements added in the 2.8.0 release

## Partition Table Editor

Eclipse Plugin offers UI for editing your [partition table](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/partition-tables.html) and flash it to your chip, instead of editing the CSV files directly. This offer editing the existing Partition table and creating a new one.

{{< figure
    default=true
    src="img/whats-2.webp"
    >}}

To launch the Partition editor

## NVS Table Editor

NVS Table Editor can help you to edit [NVS Partition](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/storage/nvs_partition_gen.html?highlight=nvs+partition#introduction) CSV file, and generate encrypted and non-encrypted partitions through UI without interacting directly with the CSV files.

Eclipse plugin uses the [nvs_partition_gen.py](https://github.com/espressif/esp-idf/blob/2707c95a5f/components/nvs_flash/nvs_partition_generator/nvs_partition_gen.py) utility from esp-idf for creating a binary file based on key-value pairs provided in the editor.

{{< figure
    default=true
    src="img/whats-3.webp"
    >}}

To launch the NVS Partition editor

## Multiple Build configurations

The plugin offers to configure the customized build configuration settings using the __Build Settings__  tab in the launch configuration wizard. This would enable the user to define the multiple build configurations with different settings — for example, debug and release configurations.

There were issues reported earlier on this where changing additional CMake Arguments in one configuration is reflected in the other configuration so there is no way one could configure different settings and this release address this [issue](https://github.com/espressif/idf-eclipse-plugin/pull/669).

{{< figure
    default=true
    src="img/whats-4.webp"
    >}}

## GDB Client Remote Timeout

There were numerous reports from clients saying that GDB Client was unable to connect with the default timeout which was 2 seconds that is to wait for the remote target to respond, otherwise, it use to drop the GDB connection with an error.

{{< figure
    default=true
    src="img/whats-5.webp"
    >}}

Now the default GDB Client remote timeout is set for 20 seconds! You could see this in the new OpenOCD Debugger configuration window.

{{< figure
    default=true
    src="img/whats-6.webp"
    >}}

## Below are the most notable bug fixes in the new version

Please find more about other [bug fixes](https://github.com/espressif/idf-eclipse-plugin/releases/tag/v2.8.0) that were part of 2.8.0.

## A way forward for IDEs and what you could expect in H1 2023

It’s been 3 years since we started working on the plugin for Eclipse and VSCode and we have built IDEs with a great set of features to support end-to-end application building with esp-idf using espressif chips. However, we realized it’s time to go back and retrospect ourselves and make a foundation much stronger. Hence we decided to focus more on code refactoring, design changes, automation, test cases, quality, onboarding, and revamping some wizards(for example OpenOCD Debugger configuration has a lot of duplicate config parameters) before we take up any new developments.

However, will work on news chips support as and when needed. For example, C6 and H2 in H1.2023 and P4 and C5 in H2.2023

## How about Eclipse CDT 2022–12 support?

Eclipse CDT 2022–12 comes with [CDT 11.0](https://github.com/eclipse-cdt/cdt/blob/main/NewAndNoteworthy/CDT-11.0.md) which is a major release and has some breaking changes in our IDF Eclipse Plugin and which also comes with Java 17 dependency.

Considering our priority on fixing bugs, improving onboarding workflows, and UX/UI we thought of pushing this bit late. Importantly, this brings a Java 17 dependency and that’s a big thing to consider for most of us as we need to update from current Java 11 to Java 17. We started work on this, probably we could expect this by end of H1.2023 or earlier.

If you’ve some feedback on IDEs and would like to share it with us, please write a mail directly to [ide.support@espressif.com](http://ide.support@espressif.com) or raise an issue on the project [GitHub](https://github.com/espressif/idf-eclipse-plugin/issues) issues section and we will be happy to connect with you!

Thank you!
