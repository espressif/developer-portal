---
title: "ESP-IDF Adv. - Assign.  4.2"
date: "2025-08-05"
series: ["WS00B"]
series_order: 9
showAuthor: false
summary: "Create a custom partition table"
---

In this assignment, you'll set a custom partiton table using VSCode.

## Assignment steps

First, you need to enable the custom partition table in the `menuconfig`

* Open menuconfig: `> ESP-IDF: SDK Configuration Editor (menuconfig)`<br>
   &rarr; `Partition Table` &rarr; `Custom Partition Table CSV`
* Open editor: `> ESP-IDF: Open Partition Table Editor UI`
* Copy the previous partition table
* Add a `spiffs` partition

{{< figure
default=true
src="../assets/assignment_4_2_partition_table.webp"
height=500
caption="Custom partition table"
    >}}


* Build the partition table: `> ESP-IDF: Build Partition Table`
* Flash the partition table: `> ESP-IDF: Flash (UART) Your Project`



```bash
Parsing binary partition input...
Verifying table...
# ESP-IDF Partition Table
# Name, Type, SubType, Offset, Size, Flags
nsv,data,nvs,0x9000,16K,
otadata,data,ota,0xd000,8K,
phy_init,data,phy,0xf000,4K,
factory_app,app,factory,0x10000,1M,
ota_0,app,ota_0,0x110000,1M,
ota_1,app,ota_1,0x210000,1M,
fs,data,spiffs,0x310000,64K,
```


> Next step: [assignment 4.3](../assignment-4-3)
