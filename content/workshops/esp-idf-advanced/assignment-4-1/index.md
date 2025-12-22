---
title: "ESP-IDF Adv. - Assign.  4.1"
date: "2025-08-05"
series: ["WS00B"]
series_order: 15
showAuthor: false
summary: "Change partition table to Factory app, two ota definitions (guided)"
---

To perform OTA, we need a partition table with at least two partitions.

## Assignment goals

1. Check the current partition table 
2. Change it to a different default partition table
3. Check the new partition table

## Check the current partition table

To check the current partition table loaded in your module, you need to:

1. Read the flash and dump the partition table in a `.bin` file
2. Convert the `.bin` file to a readable format

### Read the flash

* To read the flash, use `esptool.py`:

   ```bash
   esptool.py -p <YOUR-PORT> read_flash 0x8000 0x1000 partition_table.bin
   ```

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
`<YOUR-PORT>` is the same port you use to flash the device (e.g. `/dev/tty.usbmodem1131101` or `COM25`).
{{< /alert >}}

This creates a `partition_table.bin` file.

### Convert the partition table

* Inside a terminal, use `gen_esp32part.py`.

   ```bash
   python $IDF_PATH/components/partition_table/gen_esp32part.py partition_table.bin
   ```

You should get this output:

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

## Change partition table

Now we change the partition table, using the most appropriate default option selectable via `menuconfig`.

* Open `menuconfig`: `> ESP-IDF: SDK Configuration Editor (menuconfig)`<br>
   &rarr; `Partition Table` &rarr; `Factory app, two OTA definitions`

Since we're now using two OTAs, the default flash configuration of 2MB is not enough, so we need to change it too

* Open `menuconfig`: `> ESP-IDF: SDK Configuration Editor (menuconfig)`<br>
   &rarr; `Serial Flasher Config` &rarr; `Flash Size` &rarr; `4MB`

## Check the new partition table

Let's do the same steps as before:

* `esptool.py -p <YOUR-PORT> read_flash 0x8000 0x1000 partition_table.bin`
* `python $IDF_PATH/components/partition_table/gen_esp32part.py partition_table.bin `

And you'll get

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


## Conclusion

In this assignment you changed the partition table from `Single factory app, no ota` to the default `Factory app, two ota definitions`.
Both of these partition table scheme are provided as default values from ESP-IDF.
In the [next assignment](../assignment-4-2) you will create a custom partition table.


> Next step: [Assignment 4.2](../assignment-4-2/)

> Or [go back to navigation menu](../#agenda)