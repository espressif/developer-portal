---
title: "How to switch between multiple ESP32 firmware binaries stored in the flash memory"
date: 2024-07-18
showAuthor: false
authors:
    - "juraj-michalek"
tags: ["Embedded Systems", "ESP32", "ESP32-S3", "ESP32-P4", "GUI", "OTA", "Espressif", "BSP"]
---

## Introduction

The ESP32 microcontroller is a versatile and powerful device, widely used in IoT and embedded applications. One of its advanced features is the ability to store multiple firmware images in its flash memory and switch between them. This capability can be leveraged for various purposes, such as testing different firmware versions, running multiple applications, or maintaining a backup firmware.

In this article, we will explore how to use the ESP32 Graphical Bootloader to switch between multiple firmware images stored in the flash memory. This bootloader serves as the primary application, allowing you to select and run different firmware images. We will also demonstrate how each application can switch back to the bootloader, ensuring a seamless user experience.

## Partition Table

To enable multiple firmware images, we need a custom partition table. Below is an example of a file [partitions.csv](https://github.com/georgik/esp32-graphical-bootloader/blob/main/partitions.csv) that accommodates the bootloader and five OTA (Over-The-Air) partitions, designed for a 16MB flash memory commonly used in [ESP32-S3-BOX-3](https://github.com/espressif/esp-box) and [M5Stack-CoreS3](https://docs.m5stack.com/en/core/CoreS3):

```csv
# Name,      Type, Subtype,   Offset,  Size, Flags
nvs,         data, nvs,       0x9000,   24K,
otadata,     data, ota,       ,         8K,
phy_init,    data, phy,       ,         4K,
factory,     app,  factory,   ,         2M,
ota_0,       app,  ota_0,     ,         2816K,
ota_1,       app,  ota_1,     ,         2816K,
ota_2,       app,  ota_2,     ,         2816K,
ota_3,       app,  ota_3,     ,         2816K,
ota_4,       app,  ota_4,     ,         2816K,
```

This partition table should be defined in your project and the following option must be enabled in your [sdkconfig](https://github.com/georgik/esp32-graphical-bootloader/blob/main/sdkconfig.defaults) file:

```shell
CONFIG_PARTITION_TABLE_CUSTOM=y
```

## Setting Up the Graphical Bootloader

### Quick start with Pre-built firmware

The example application is available as a binary image in [Releases](https://github.com/georgik/esp32-graphical-bootloader/releases).

It can be flashed to the device from address 0x0

```shell
esptool.py --chip esp32s3 write_flash 0x0000 graphical_bootloader_esp32-s3-box-3.bin
```

You can also run the simulation of the application in the web browser using Wokwi.

[![ESP32-S3-BOX-3 Graphical Bootloader](img/esp32-s3-box-3-graphical-bootloader.webp)](https://wokwi.com/experimental/viewer?diagram=https://gist.githubusercontent.com/urish/c3d58ddaa0817465605ecad5dc171396/raw/ab1abfa902835a9503d412d55a97ee2b7e0a6b96/diagram.json&firmware=https://github.com/georgik/esp32-graphical-bootloader/releases/latest/download/graphical-bootloader-esp32-s3-box.uf2
)

[Run on-line in Wokwi Simulator](https://wokwi.com/experimental/viewer?diagram=https://gist.githubusercontent.com/urish/c3d58ddaa0817465605ecad5dc171396/raw/ab1abfa902835a9503d412d55a97ee2b7e0a6b96/diagram.json&firmware=https://github.com/georgik/esp32-graphical-bootloader/releases/latest/download/graphical-bootloader-esp32-s3-box.uf2
)

### Cloning the Repository

If you'd like to build your own version, please follow the instructions in this chapter.

Start by cloning the project repository:

```shell
git clone https://github.com/georgik/esp32-graphical-bootloader.git
cd esp32-graphical-bootloader
```

### Selecting the Target Board

Set the appropriate `SDKCONFIG_DEFAULTS` for your board. For example, to configure for ESP32-S3-BOX-3, use:

```shell
export SDKCONFIG_DEFAULTS=sdkconfig.defaults.esp-box-3
```

### Building the Main Application and Sub-Applications

Run the following commands to build the main application and all sub-applications:

```shell
cmake -Daction=select_board -P Bootloader.cmake
cmake -Daction=build_all_apps -P Bootloader.cmake
```

### Merging Binaries into a Single Image

After building, merge the binaries into a single image:

```shell
cmake -Daction=merge_binaries -P Bootloader.cmake
```

### Flashing the Merged Binary to the ESP32

Finally, flash the combined binary to the ESP32:

```shell
esptool.py --chip esp32s3 write_flash 0x0 build/combined.bin
```

## Using the Bootloader

Once flashed, the ESP32 will boot into the graphical bootloader. This bootloader allows you to select which application to run. The user interface is intuitive, and you can navigate through the different applications stored in the OTA partitions.

## Switching Between Applications

### Switching to Another Application

The following code snippet from the bootloader shows how to switch to another application. This is particularly useful for managing multiple applications stored in different OTA partitions:

```c
// For button 1, next_partition will not change, thus pointing to 'ota_0'
if (next_partition && esp_ota_set_boot_partition(next_partition) == ESP_OK) {
    printf("Setting boot partition to %s\\n", next_partition->label);
    esp_restart();  // Restart to boot from the new partition
} else {
    printf("Failed to set boot partition\\n");
}
```

### Returning to the Original Application

Each application can include a mechanism to switch back to the original application (bootloader). Here is an example function from one of the sub-applications:

```c
#include "esp_ota_ops.h"

void reset_to_factory_app() {
    // Get the partition structure for the factory partition
    const esp_partition_t *factory_partition = esp_partition_find_first(ESP_PARTITION_TYPE_APP, ESP_PARTITION_SUBTYPE_APP_FACTORY, NULL);
    if (factory_partition != NULL) {
        if (esp_ota_set_boot_partition(factory_partition) == ESP_OK) {
            printf("Set boot partition to factory, restarting now.\\n");
        } else {
            printf("Failed to set boot partition to factory.\\n");
        }
    } else {
        printf("Factory partition not found.\\n");
    }

    fflush(stdout);
}
```

This function can be called at the beginning of the application to ensure that the device reverts to the factory firmware (bootloader) in case of a crash. After this operation, any reset will boot into the original firmware.

In your application's `CMakeLists.txt`, ensure that you include the required dependency:

```shell
idf_component_register(SRCS "calculator.c"
                    INCLUDE_DIRS "."
                    REQUIRES app_update)
```


## Useful Links

- [ESP32 Graphical Bootloader GitHub Repository](https://github.com/georgik/esp32-graphical-bootloader)
- [ESP-IDF Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/)
- [ESP-BSP Components](https://components.espressif.com/components?q=tags:bsp)

## Conclusion

The ESP32 Graphical Bootloader provides a powerful way to manage multiple applications on a single device. By leveraging OTA partitions, you can store and switch between different applications with ease. Whether you're a maker looking to experiment with different projects or a professional needing multiple application environments, this bootloader simplifies the process.
