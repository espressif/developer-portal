---
title: "ESP-IDF C5 - Lecture 2"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 5
showAuthor: false
summary: "This lecture introduces the ESP-IDF partition table, its typical elements, and how to select a built-in scheme through menuconfig."
---

## Introduction

Espressif SoCs store the application, filesystem, and various pieces of system data in the same SPI flash chip. To keep track of what lives where, ESP-IDF relies on a partition table: a small data structure that describes how the flash memory is divided into independent regions, each with its own name, type, and size.

The typical use of a partition table is to divide the flash into regions dedicated to specific purposes, such as the bootable application, persistent key-value storage, or a filesystem for assets. Separating these regions lets the bootloader locate the right application to run and lets your code access storage areas without risking that one region overwrites another.

The partition table defines how the flash memory is organized, specifying where applications, data, filesystems, and other resources are stored. This logical separation allows developers to manage firmware, persistent data, and update mechanisms efficiently.

ESP-IDF uses partition tables because they enable:

* __Separation of code and data:__ Application and persistent data are isolated, allowing firmware updates without erasing user data.
* __OTA updates:__ Multiple app partitions and OTA data management for robust remote firmware upgrades.
* __Flexible storage:__ Support for filesystems and custom data regions for certificates, logs, or configuration.

## Structure and Location

The partition table is typically flashed at offset `0x8000` in the device’s SPI flash. It occupies `0xC00` bytes, supporting up to 95 entries, and includes an MD5 checksum for integrity verification. The table itself takes up a full 4 KB flash sector, so any partition following it must start at least at offset `0x9000`, depending on the table size and alignment requirements. Each entry in the table includes a name (label), type (such as app or data), subtype, offset, and size in flash memory.


### Typical partition table elements

Every entry in a partition table has a name (label), a type (`app` or `data`), a subtype, an offset in flash, and a size.

| Field    | Description                                                                                          |
| -------- | ---------------------------------------------------------------------------------------------------- |
| Name     | A label (up to 16 characters) that identifies the partition, such as `nvs` or `factory`.             |
| Type     | The broad category of the partition, either `app` for bootable firmware or `data` for storage.       |
| SubType  | A finer classification within the type, such as `factory`, `ota_0`, `nvs`, or `phy`.                 |
| Offset   | The starting address of the partition in the SPI flash, for example `0x10000`.                       |
| Size     | The amount of flash reserved for the partition, expressed in bytes or with a suffix like `K` or `M`. |

#### nvs

The `nvs` partition backs the __Non-Volatile Storage__ library, a key-value store that ESP-IDF uses to persist small amounts of data across reboots, such as Wi-Fi credentials, calibration data, or your own application settings. Because it's a dedicated partition, writing to NVS never risks corrupting your application code.

#### app

The `app` partition (or partitions, when using OTA) holds the compiled firmware image that the bootloader loads and executes at startup. A basic partition table has a single `factory` app partition, while a table configured for OTA updates has multiple app partitions so that a new firmware image can be written without erasing the one currently running.

#### phy_init

The `phy_init` partition can hold PHY initialization data used to fine-tune the Wi-Fi and Bluetooth radio for a specific device.

#### otadata

The `otadata` partition is only present in tables that support OTA. It keeps track of which app partition (`ota_0`, `ota_1`, and so on) is currently active and should be booted next. We'll look at how this partition is updated during an OTA operation in the next lecture.


### Built-in Partition Schemes

ESP-IDF provides several predefined partition tables for common use cases, selectable via `menuconfig`:

* __Single factory app, no OTA__: Contains a single application partition and basic data partitions (`nvs`, `phy_init`).
* __Factory app, two OTA definitions__: Adds support for over-the-air (OTA) updates, with two OTA app partitions and an OTA data slot. We will use this predefined partition table in the [assignment 2.1](assignment-2-1/)

For example, the "Factory app, two OTA definitions" scheme typically looks like this:

```
Name      Type   SubType  Offset    Size
nvs       data   nvs      0x9000    0x4000
otadata   data   ota      0xd000    0x2000
phy_init  data   phy      0xf000    0x1000
factory   app    factory  0x10000   1M
ota_0     app    ota_0    0x110000  1M
ota_1     app    ota_1    0x210000  1M
```

The bootloader uses the partition table to locate the application to boot and the data regions for `nvs`, `phy_init`, and OTA management.

### Custom Partition Tables

For advanced use cases, developers can define custom partition tables in CSV format. This allows for additional partitions, such as extra `nvs` storage, `spiffs`, or `fat` filesystems, tailored to the application's needs. The custom CSV is specified in the project configuration, and ESP-IDF tools will flash and use it accordingly.

>[!TIP]
> If you want to dig deeper in the topics, you check the developer portal article [How to use custom partition tables on ESP32](https://developer.espressif.com/blog/how-to-use-custom-partition-tables-on-esp32/).

We will create a custom partition table in [assignment 2.2](assignment-2-2/)

## Partition table and OTA

Partition tables are fundamental for OTA because updating firmware over the air requires somewhere to write the new image while the current one keeps running. A table with a single `factory` partition has no room for this: the device would have to erase its only application to write the new one, which is not safe if the update is interrupted.

Instead, a partition table designed for OTA reserves two (or more) app partitions, typically named `ota_0` and `ota_1`, along with an `otadata` partition. When an update arrives, it's written to the unused app partition, and once the write completes successfully, `otadata` is updated to point the bootloader at the new partition on the next reboot. We'll cover this workflow in detail in the next lecture.

## Conclusion

In this lecture, you learned what a partition table is and why ESP-IDF uses one to organize flash memory into independent regions. You also saw the roles of the `nvs` and `app` partitions, how `otadata` and extra app partitions make OTA updates possible, and how to choose a partition table scheme through `menuconfig`. In the next assignment, you will inspect and modify the partition table on your own `ESP32-C5` project.

### Next Step
> Next assignment &rarr; __[assignment 2.1](assignment-2-1)__

> Or [go back to navigation menu](.#agenda)
