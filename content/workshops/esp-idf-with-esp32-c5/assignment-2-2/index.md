---
title: "ESP-IDF C5 - Assign. 2.2"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 7
showAuthor: false
summary: "Create a custom partition table that adds a spiffs filesystem partition, then flash it and confirm the change by reading it back from flash."
---

In this assignment, you'll set a custom partition table using VS Code.

## Assignment steps

1. Enable the custom partition table in `menuconfig`.
2. Add a `spiffs` partition using the partition table editor.
3. Build and flash the new partition table.
4. Read the partition table again to confirm the change.

## Enable the custom partition table in menuconfig

1. Open `menuconfig`: `> ESP-IDF: SDK Configuration Editor (menuconfig)`
2. Go to `Partition Table` &rarr; `Custom Partition Table CSV`.

   This tells ESP-IDF to build the project's partition table from a CSV file that you edit yourself, instead of one of the built-in schemes.

## Add a spiffs partition using the partition table editor

1. Open the editor: `> ESP-IDF: Open Partition Table Editor UI`
2. Copy the partition table from [Assignment 2.1](../assignment-2-1/) as your starting point.
3. Add a `spiffs` partition after the existing entries.

{{< figure
default=true
src="https://developer.espressif.com/workshops/esp-idf-advanced/assets/assignment-4-2-partition-table.webp"
height=500
caption="Custom partition table"
    >}}

## Build and flash the new partition table

1. Build the partition table: `> ESP-IDF: Build Partition Table`
2. Flash the partition table: `> ESP-IDF: Flash (UART) Your Project`

## Read the partition table again to confirm the change

Read the partition table back from flash, as you did in [Assignment 2.1](../assignment-2-1/), to confirm the new `spiffs` partition was written correctly.

1. Read the flash and dump the partition table into a `.bin` file using `esptool.py`:

   ```bash
   esptool.py -p <YOUR-PORT> read_flash 0x8000 0x1000 partition_table.bin
   ```

   {{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
   `<YOUR-PORT>` is the same port you use to flash the device (e.g. `/dev/tty.usbmodem1131101` or `COM25`).
   {{< /alert >}}

2. Convert the `partition_table.bin` file to a readable format using `gen_esp32part.py`:

   ```bash
   python $IDF_PATH/components/partition_table/gen_esp32part.py partition_table.bin
   ```

   You get this output:

   ```bash
   Parsing binary partition input...
   Verifying table...
   # ESP-IDF Partition Table
   # Name, Type, SubType, Offset, Size, Flags
   nvs,data,nvs,0x9000,16K,
   otadata,data,ota,0xd000,8K,
   phy_init,data,phy,0xf000,4K,
   factory_app,app,factory,0x10000,1M,
   ota_0,app,ota_0,0x110000,1M,
   ota_1,app,ota_1,0x210000,1M,
   fs,data,spiffs,0x310000,64K,
   ```

   The table now includes the `fs` partition, confirming that the custom partition table with the `spiffs` filesystem was flashed successfully.

## Conclusion

In this assignment, you built a custom partition table CSV based on the OTA scheme from the previous assignment and added a `spiffs` partition for a filesystem. You then built, flashed, and verified the new partition table. With the partition table in place, you're ready to move on to OTA updates.

### Next step
> Next step &rarr; [Lecture 3](../lecture-3/)

> Or [go back to navigation menu](.#agenda)
