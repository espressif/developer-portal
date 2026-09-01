---
title: "ESP-IDF C5 - Assign. 2.1"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 6
showAuthor: false
summary: "Switch the partition table to a scheme that supports OTA updates, and confirm the change by reading it back from flash."
---

To perform OTA updates, the device needs a partition table with at least two app partitions. In this assignment we will select and flash an appropriate partition table.

## Assignment steps

1. Check the current partition table.
2. Change it to a partition table scheme that supports OTA.
3. Check the new partition table.

## Check the current partition table

To check the partition table currently loaded on your module, read it back from flash and convert it to a readable format.

1. Read the flash and dump the partition table into a `.bin` file using `esptool.py`:

   ```bash
   esptool.py -p <YOUR-PORT> read_flash 0x8000 0x1000 partition_table.bin
   ```

   {{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
   `<YOUR-PORT>` is the same port you use to flash the device (e.g. `/dev/tty.usbmodem1131101` or `COM25`).
   {{< /alert >}}

   This creates a `partition_table.bin` file containing the raw partition table.

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
   nvs,data,nvs,0x9000,24K,
   phy_init,data,phy,0xf000,4K,
   factory,app,factory,0x10000,1M,
   coredump,data,coredump,0x110000,64K,
   ```

   This table has a single `factory` app partition, so it does not support OTA updates.

## Change the partition table

Switch to the default partition table scheme that includes two OTA app partitions, then increase the flash size so both app partitions fit.

1. Open `menuconfig` (`> ESP-IDF: SDK Configuration Editor (menuconfig)`) and go to `Partition Table` &rarr; `Factory app, two OTA definitions`.

   This replaces the single `factory` app partition with two OTA app partitions (`ota_0` and `ota_1`) and adds the `otadata` partition used to track which one is active.

2. In the same `menuconfig` window, go to `Serial Flasher Config` &rarr; `Flash Size` &rarr; `4MB`.

   Two 1 MB OTA app partitions no longer fit in the default 2 MB flash size, so this step is required for the new partition table to fit.

## Check the new partition table

Repeat the read and convert steps to confirm the partition table changed.

1. Read the flash again:

   ```bash
   esptool.py -p <YOUR-PORT> read_flash 0x8000 0x1000 partition_table.bin
   ```

2. Convert it to a readable format:

   ```bash
   python $IDF_PATH/components/partition_table/gen_esp32part.py partition_table.bin
   ```

   You now get:

   ```bash
   Parsing binary partition input...
   Verifying table...
   # ESP-IDF Partition Table
   # Name, Type, SubType, Offset, Size, Flags
   nvs,data,nvs,0x9000,16K,
   otadata,data,ota,0xd000,8K,
   phy_init,data,phy,0xf000,4K,
   factory,app,factory,0x10000,1M,
   ota_0,app,ota_0,0x110000,1M,
   ota_1,app,ota_1,0x210000,1M,
   ```

   The table now includes the `otadata` partition and two app partitions, `ota_0` and `ota_1`, confirming the switch to an OTA-capable scheme.

>[!INFORMATION]
>You can also check the partition table in code using ESP-IDF APIs. See the [partition API example](https://github.com/espressif/esp-idf/tree/master/examples/storage/partition_api/partition_find#finding-partitions-example) for reference.

## Conclusion

In this assignment, you changed the partition table from `Single factory app, no OTA` to `Factory app, two OTA definitions`. Both partition table schemes are default options provided by ESP-IDF. In the next assignment, you will create a custom partition table.

### Next step
> Next assignment &rarr; [Assignment 2.2](assignment-2-2/)

> Or [go back to navigation menu](.#agenda)
