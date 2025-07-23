---
title: "How to use custom partition tables on ESP32"
date: 2021-02-12
showAuthor: false
authors:
  - pedro-minatel
tags:
  - Espressif
  - Esp32
  - IoT
  - Esp Idf

---
{{< figure
    default=true
    src="img/how-1.webp"
    >}}

## Introduction

When we create a new project using __ESP32__ , sometimes we need to store data in the flash to persist even after a restart or power down. In the past, the most common way to do that was by using EEPROM, with just a few bytes of storage ability which limited it for larger amount of data.

On the other hand, the __ESP32__  uses a flash memory to store the firmware, including the bootloader and other relevant data. The flash memory size may vary from version to version, but it’s enough for most of the application code and you still can manage to have some spare storage area.

But not only the firmware, (your application) is stored in the flash memory. There is some other important data to keep in the flash, including the partitions map, RF calibration data, WiFi data, Bluetooth pairing information, Over-the-air updates and many other data important enough to be kept in the flash.

To see all ESP32 family variants, see this ordering information [__link__ ](https://www.espressif.com/sites/default/files/documentation/espressif_products_ordering_information_en.pdf).

> Important note: This article uses the [ESP-IDF v4.2](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/) and all references use this version.

## Understanding partition tables

The partition tables on the ESP32 works very similarly to our computer. Just imagine that you can logically separate data according to the usage by telling the system where certain type of data will be stored on the memory, the type of this partition and, of course, the size.

Using the partition tables, you can have your application stored in one partition and your data, like the configuration or any other data, could be stored in a different partition. This allows you to keep your app and data in a separate memory area, making it possible, for example, to update only the application with a latest version and keep all your data intact.

The default partition scheme is defined by two different major partitions:

## nvs

The default NVS partition is used to store the unique device PHY calibration, WiFi data, Bluetooth pairing information, and any other value to be stored as NVS format. The default size is 24kB (0x6000 bytes).

## factory

The factory partition stores the application firmware itself. The bootloader uses this partition as the starting point to initialize the application. When using [__OTA__ ](https://docs.espressif.com/projects/esp-jumpstart/en/latest/firmwareupgrade.html), this partition is used only if all OTA partitions are empty, otherwise the actual OTA partition will be used, and the factory partition will be no longer used.

Another usage for this partition is to keep the default application and use the OTA API to change the boot partition in case of factory reset (after updating the device to some OTA partition) or some failure during OTA updates.

## Use case

The most common usage for a custom partition table is when the firmware needs to be updated remotely by using the Over-The-Air update. This feature requires, at least three additional partitions to store the OTA data (*ota*) and two application (*ota_0* and *ota_1*).

Another usage for this feature to add another storage area for saving files, logging data, device configuration, GPIO status or many other kinds of data.

You can also use the extended storage area to store the cloud certificates, therefore avoiding the need to keep hardcoded in your application (not recommended at all).

The flash memory on the [__ESP32__ ](https://www.espressif.com/sites/default/files/documentation/esp32_datasheet_en.pdf) and [__ESP32-S2__ ](https://www.espressif.com/sites/default/files/documentation/esp32-s2_datasheet_en.pdf) is limited to up to 16MB. This way, if you need a more than 16MB of flash memory for data storage, you can add a second flash memory or an SDCard to your board.

## Creating custom partition tables

To start creating new partitions, we need to first understand the partitions’ file structure. The custom partition tables are defined by a CSV file with the following structure:

```
__# ESP-IDF Partition Table
# Name, Type, SubType, Offset, Size, Flags__ 
```

The CSV file contains 6 columns, defined in the second line in the CSV file.

## Name

The first column is the partition name, and it defines the label of the partition.

The name field doesn’t have special meaning (except to the default NVS partition) but must be meaningful according to the partition usage and the name size should at maximum of 16 chars (larger names will be truncated).

## Type

The second column is the partition type. Currently there are two types: *data* and *app*.

The __*data (0x01)*__  type can be used to define the partition that stores general data, not the application.

The __*app (0x00)*__  type is used to define the partition that will store the application.

Note: The type is defined by the [esp_partition_type_t enumeration](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/api-reference/storage/spi_flash.html#_CPPv420esp_partition_type_t).

## SubType

The third column is the partition sub type and defines the usage of the __*app*__  and __*data*__  partitions.

__SubType for data partitions:__ 

For the __*data*__  type, the subtype can be specified as:

Note: The subtype is defined on the [__*esp_partition_subtype_t enumeration*__ ](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/api-reference/storage/spi_flash.html#_CPPv423esp_partition_subtype_t).

- __ota (0x00):__ The *ota* subtype is used to store the OTA information. This partition is used only when the OTA is used to select the initialization partition, otherwise no need to add it to your custom partition table.The size of this partition should be a fixed size of 8kB (0x2000 bytes).
- __nvs (0x02):__ The *nvs* partition subtype is used to define the partition to store general data, like the WiFi data, device PHY calibration data and any other data to be stored on the non-volatile memory.This kind of partition is suitable for small custom configuration data, cloud certificates, etc. Another usage for the NVS is to store sensitive data, since the NVS supports encryption.It is highly recommended to add at least one *nvs* partition, labeled with the name nvs, in your custom partition tables with size of at least 12kB (0x3000 bytes). If needed, you can increase the size of the nvs partition.The recommended size for this partition is from 12kb to 64kb. Although larger NVS partitions can be defined, we recommend using FAT or SPIFFS filesystem for storage of larger amounts of data.
- __coredump (0x03):__ The *coredump* partition subtype is used to store the [__core dump__ ](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/api-guides/core_dump.html) on the flash. The core dump is used to analyze critical errors like crash and panic.This function must be enabled in the project configuration menu and set the data destination to flash.The recommended size for this partition is 64kB (0x10000).
- __nvs_keys (0x04):__ The *nvs_keys* partition subtype is used to store the keys when the NVS encryption is used.The size for this partition is 4kB (0x1000).
- __fat (0x81):__ The *fat* partition subtype defines the FAT filesystem usage, and it is suitable for larger data and if this data is often updated and changed. The FAT FS can be used with [__wear leveling__ ](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/api-reference/storage/wear-levelling.html) feature to increase the erase/modification cycles per memory sector and [__encryption__ ](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/security/flash-encryption.html) for sensitive data storage, like cloud certificates or any other data that may be protected.To use FAT FS with wear leveling see the [example](https://github.com/espressif/esp-idf/tree/release/v4.2/examples/storage/wear_levelling).
- __spiffs (0x82):__ The *spiffs* partition subtype defines the SPI flash filesystem usage, and it is also suitable for larger files and it also performs the wear leveling and file system consistency check.The SPIFFS do not support flash encryption.

__SubType for app partitions:__ 

For the __*app*__  type it can be specified as:

- __factory (0x00):__ The *factory* partition subtype is the default application. The bootloader will set this partition as the default application initialization if no OTA partition is found, or the OTA partitions are empty.If the OTA partition is used, the ota_0 can be used as the default application and the *factory* can be removed from the partition table to save memory space.
- __ota_0 to ota_15 (0x10–0x19):__ The *ota_x* *partition* subtype is used for the [Over-the air](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/api-reference/system/ota.html) update. The OTA feature requires at least two *ota_x* partition (usually *ota_0* and *ota_1*) and it also requires the *ota* partition to keep the OTA information data.Up to 16 OTA partitions can be defined but only two are needed for basic OTA feature.
- __test (0x20):__ The *test* partition subtype is used for [__factory test procedures__ ](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/api-guides/bootloader.html#bootloader-boot-from-test-firmware).

## Offset

The fourth column is the memory offset and it defines the partition start address. The offset is defined by the sum of the offset and the size of the earlier partition.

Note that the first partition (nvs in our case) must start at offset 0x9000. This is mandatory due the bootloader (offset 0x1000 and size of 0x7000) and the partition table section offset (offset 0x8000 and size of 0x1000) as well. Those partitions are not listed in the CSV file.

If the size of the bootloader needs to be increased, due any customization on it for example, you need to increase the offset in the project configuration menu (*Partition Table → Offset of partition table*) and you need to add the new offset on the first partition.

> Offset must be multiple of 4kB (0x1000) and for *app* partitions it must be aligned by 64kB (0x10000).

If left blank, the offset will be automatically calculated based on the end of the previous partition, including any necessary alignment.

## Size

The fifth column is size and defines the amount of memory to be allocated on the partition. The size can be formatted as decimal, hex numbers (0x prefix), or using unit prefix K (kilo) or M (mega) i.e: 4096 = 4K = 0x1000.

The size is defined in number of bytes and the minimum size is 4kB. The size for larger partitions must be multiple of 4kB. The maximum size is limited by the flash memory size, including all partitions.

## Flags

The last column in the CSV file is the *flags* and it is currently used to define if the partition will be encrypted by the [__flash encryption__ ](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/security/flash-encryption.html) feature.

After creating the CSV file, we need to change the project configuration to load the new partition tables’ file.

It is important to mention that for any changes on the partition tables structure, we need to erase the flash memory and reprogram the device including the new partitions binary file.

There is a [__tool__ ](https://github.com/espressif/esp-idf/blob/v4.2/components/partition_table/gen_esp32part.py) to create the partition table in binary format manually from the CSV file. This conversion is done automatically during the build process.

## Demo

To show the usage of custom partition tables, we will create a quite simple demo with an extended NVS partition and one partition for SPIFFS alongside the default partitions and OTA.

The code will be based on the *partition_find* example, using the [ESP-IDF v4.2](https://github.com/espressif/esp-idf/tree/release/v4.2/examples/storage/partition_api/partition_find).

The extended NVS will be used to store the device configuration and any other small relevant data besides the other NVS partition.

*NOTE: We highly recommend the use of NVS to store small amount of data. For larger data storage, you should move to FAT file system or SPIFFS.*

Another partition that we will create is to store files and any other large data. For that partition, we will use the SPIFFS format.

{{< figure
    default=true
    src="img/how-2.webp"
    >}}

In this demo, our [__development board is based on ESP32__ ](https://docs.espressif.com/projects/esp-idf/en/release-v4.2/esp32/hw-reference/esp32/get-started-devkitc.html) and equipped with a 8MB flash memory.

The custom partition table will be the following:

```
__*# ESP-IDF Partition Table
# Name, Type, SubType, Offset, Size, Flags*__ *
nvs,* *data, nvs, 0x9000,* *0x6000,
otadata,* *data, ota, 0xf000, 0x2000,
ota_0,* *app, ota_0, 0x20000, 0x200000,
ota_1,* *app, ota_1, 0x220000, 0x200000,
storage,* *data, spiffs, 0x420000, 0x200000,
nvs_ext,* *data, nvs, 0x620000, 0x10000,*
```

The graphical representation of the partition table is the following:

{{< figure
    default=true
    src="img/how-3.webp"
    >}}

The *storage* will be used with SPIFFS and the *nvs_ext* for extra NVS data storage.

It’s important to mention that the both OTA partitions should have the same size and be sure to keep in mind to allocate enough space for additional features in the future.

If not using OTA, you don’t need to set the size of 2MB on the factory partition, if your firmware size is less than 1MB.

Now we need to add the new CVS file, named as __*partitions_example.csv*__  and change the example to find the partition scheme:
```bash
# ESP-IDF Partition Table
# Name, Type, SubType, Offset, Size, Flags
nvs, data, nvs, 0x9000, 0x6000,
otadata, data, ota, 0xf000, 0x2000,
ota_0, app, ota_0, 0x20000, 0x200000,
ota_1, app, ota_1, 0x220000, 0x200000,
storage, data, spiffs, 0x420000, 0x200000,
nvs_ext, data, nvs, 0x620000, 0x10000,
```

After flashing and running the example, the output will show all detected partitions, according to our partition table layout.

```
idf.py -p <COM_PORT> flash monitor
```

Log output on terminal:

```
# ESP-IDF Partition Table
# Name, Type, SubType, Offset, Size, Flags
nvs, data, nvs, 0x9000, 0x6000,
otadata, data, ota, 0xf000, 0x2000,
ota_0, app, ota_0, 0x20000, 0x200000,
ota_1, app, ota_1, 0x220000, 0x200000,
storage, data, spiffs, 0x420000, 0x200000,
nvs_ext, data, nvs, 0x620000, 0x10000,
I (380) example: ----------------Find partitions---------------
I (390) example: Find partition with type ESP_PARTITION_TYPE_DATA, subtype ESP_PARTITION_SUBTYPE_DATA_NVS, label NULL (unspecified)...
I (400) example:  found partition 'nvs' at offset 0x9000 with size 0x6000
I (410) example: Find partition with type ESP_PARTITION_TYPE_DATA, subtype ESP_PARTITION_SUBTYPE_DATA_PHY, label NULL (unspecified)...
E (420) example:  partition not found!
I (430) example: Find partition with type ESP_PARTITION_TYPE_APP, subtype ESP_PARTITION_SUBTYPE_APP_FACTORY, label NULL (unspecified)...
E (440) example:  partition not found!
I (450) example: Find partition with type ESP_PARTITION_TYPE_DATA, subtype ESP_PARTITION_SUBTYPE_DATA_FAT, label NULL (unspecified)...
E (460) example:  partition not found!
I (460) example: Find partition with type ESP_PARTITION_TYPE_DATA, subtype UNKNOWN_PARTITION_SUBTYPE, label NULL (unspecified)...
I (480) example:  found partition 'storage' at offset 0x420000 with size 0x200000
I (480) example: Find partition with type ESP_PARTITION_TYPE_DATA, subtype ESP_PARTITION_SUBTYPE_APP_FACTORY, label NULL (unspecified)...
I (500) example:  found partition 'otadata' at offset 0xf000 with size 0x2000
I (500) example: Find partition with type ESP_PARTITION_TYPE_DATA, subtype UNKNOWN_PARTITION_SUBTYPE, label NULL (unspecified)...
E (520) example:  partition not found!
I (520) example: Find partition with type ESP_PARTITION_TYPE_DATA, subtype UNKNOWN_PARTITION_SUBTYPE, label NULL (unspecified)...
E (530) example:  partition not found!
I (540) example: Find second FAT partition by specifying the label
I (540) example: Find partition with type ESP_PARTITION_TYPE_DATA, subtype ESP_PARTITION_SUBTYPE_DATA_NVS, label nvs_ext...
I (560) example:  found partition 'nvs_ext' at offset 0x620000 with size 0x10000
I (560) example: ----------------Iterate through partitions---------------
I (570) example: Iterating through app partitions...
I (580) example:  found partition 'ota_0' at offset 0x20000 with size 0x200000
I (590) example:  found partition 'ota_1' at offset 0x220000 with size 0x200000
I (590) example: Iterating through data partitions...
I (600) example:  found partition 'nvs' at offset 0x9000 with size 0x6000
I (610) example:  found partition 'otadata' at offset 0xf000 with size 0x2000
I (610) example:  found partition 'storage' at offset 0x420000 with size 0x200000
I (620) example:  found partition 'nvs_ext' at offset 0x620000 with size 0x10000
I (630) example: Example end
```

To use the extended NVS partition (nvs_ext), you need to change the NVS initialization by using* *[*nvs_flash_init_partition_ptr*](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/api-reference/storage/nvs_flash.html#_CPPv424nvs_flash_init_partitionPKc) by passing the NVS partition name.

## Using ESP-IDF VS Code Extension

There is another way to work with the partition table CSV file, instead of editing in text mode. The [ESP-IDF VS Code Extension](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension) allows you to install ESP-IDF, manage and create projects directly on the Microsoft Visual Studio Code IDE.

ESP-IDF VS Code Extension embeds various tools to aid in development. One of those tools is used to create the partition table using a GUI tool, called the ESP-IDF Partition Table Editor.

To start the Partition Table Editor, first open the Command Palette and type *Partition Table Editor UI *to open the editor interface (to open the command menu press F1).

{{< figure
    default=true
    src="img/how-4.webp"
    >}}

Now you can start creating your Partition Table structure by filling the same fields described in the last section.

{{< figure
    default=true
    src="img/how-5.webp"
    >}}

After creating the partition table structure, you can save the CSV file to your project, build the binary and flash it to your board.

{{< figure
    default=true
    src="img/how-6.webp"
    >}}

If you are interested, watch the get started with the ESP-IDF VS Code Extension video-tutorial:

## Common issues (Troubleshooting)

Some of the most common issues when dealing with partitions are about the alignment and overlapping.

First, you need to flash erase if any modification on the partitions structure is done. This ensures that all new binary files will be flashed.

To erase flash, use the following command:

```
idf.py -p <COM_PORT> erase_flash
```

## Failed to find X partition…

This issue means that the partition is not found or missing in your partition tables. This could be due to some wrong value on the CSV file, like the wrong type or subtype.

## Partition overlapping issue

If your partition offset points into an area that belongs to another partition, you will see an error like the following:

CSV Error: Partitions overlap. Partition at line 6 sets offset __0x210000__ . Previous partition ends __0x220000__ 

It means that your partition at line 6 on the CSV should start at __0x220000__  and not at __0x210000__ . To solve this issue, change the value on the CSV file.

## Memory size issue

The most common issue about the partition size stands for the size alignment.

For the partitions type __*app*__ , the size must be aligned by 64kB (0x10000) and must be multiple of the same value. This means that the size and offset must be aligned by 64kB for any *app* partition.

If you have a partition like this:

```
ota_0, app, ota_0, 0x12000, 0x200000,
```

Then the error should be something like this:

Partition ota_0 invalid: Offset 0x12000 is not aligned to 0x10000

To solve this issue, change the offset to __0x20000__  and remember to recalculate the next offset.

A smart solution for any alignment issue is to keep the offset blank and let the magic happen. By keeping the offset blank, the offset will be calculated *automagically.*

For example, if you create a partition table that uses 8MB flash, be sure to change in the project configuration the right amount on the menu ‘*Serial flasher config — → Flash size’*.

## Conclusion

Creating custom partition tables in your project can be advantageous as you reuse available flash memory for extended data storage by customizing the partitions. This technique can avoid usage of external SDCard for extra data storage.

When defining a custom partition table, make sure to use the right amount of data and alignment for each partition. Have in mind to allocate some free space in the application partition, especially when OTA is used, avoiding any problem if the size of the application increases and doesn't fits in the partition anymore.

That way, you can maximize the flash usage you will not be wasting resources!

## Reference for Partition Table

Docs: [API Guide — Partition Tables](https://docs.espressif.com/projects/esp-idf/en/v4.2/esp32/api-guides/partition-tables.html)
