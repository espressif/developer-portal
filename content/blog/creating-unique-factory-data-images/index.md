---
title: Creating Unique Factory Data Images
date: 2018-05-01
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----3f642832a7a3--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fbuilding-products-creating-unique-factory-data-images-3f642832a7a3&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----3f642832a7a3---------------------post_header-----------)

--

A common requirement while building a device is to have some unique information programmed into the device at the time of manufacturing. This information could be a unique serial number, or a unique MAC address ; or it could be a unique secret like the default password, or the HomeKit pairing pin.

We have seen quite a number of ways that customers have achieved this.

- Some use a few NVS keys to store this information at the factory. Since the NVS also stores user configuration, this method makes it harder to implement reset-to-factory, where the user’s settings must be erased.
- Some write a script that modifies known locations of a firmware image to add unique values in the firmware. This makes firmware upgrades harder because the unique information is now part of the application firmware itself.

In the recent ESP [IDF](https://github.com/espressif/esp-idf/) master, we have introduced a few changes that should make implementing this behaviour easier.

## Multiple NVS Partitions

IDF now supports simultaneously having multiple NVS partitions.

- One of the NVS partitions can be used to store user configuration. This partition only stores user’s configuration, and thus can be freely erased at a reset-to-factory event.
- The other NVS partition can be used to store per-device unique information. Thousands of unique NVS partition images/binaries could be created and then be programmed per-device into this partition at the factory.

## Creating the partitions file

The IDF uses a default partition layout that works for most cases. A number of such layouts are available in the *components/partition_table/* directory within the IDF. We now need to create a partition file that has 2 NVS partitions instead of the typical one.

A sample updated partition file is shown below:

```
# Name, Type, SubType, Offset, Size, Flags
# Note: if you change the phy_init or app partition offset, make sure to change the offset in Kconfig.projbuild
nvs, data, nvs, 0x9000, 0x6000,
phy_init, data, phy, 0xf000, 0x1000,
__fctry, data, nvs, 0x10000, 0x6000,__ factory, app, factory, 0x20000, 1M,
```

Notice the line *fctry* that indicates the additional NVS partition. This partitions stores the per-device unique keys programmed into the factory. The first NVS partition continues to be used as the partition for storing user configuration like Wi-Fi network name, passphrase etc.

## Using the partitions file

Save the above partition file at some location. Now update your SDK configuration to pick up this partitions file as:

- menuconfig → Partition Table → Custom partition table CSV
- menuconfig → Partition Table → Custom partition CSV file
- menuconfig → Partition Table → Factory app partition offset

The custom partition CSV file should match the name of your partitions file.

The factory app partition offset should match the offset at which the ‘factory’ firmware is stored in your partitions file.

## Accessing the factory data

The factory partition can then be accessed as shown below:

```
/* Error checks removed for brevity */
nvs_handle fctry_handle;nvs_flash_init___partition__ (MFG_PARTITION_NAME);
nvs_open___from_partition__ (MFG_PARTITION_NAME, “fctryNamespace”,  
               NVS_READWRITE, &fctry_handle);nvs_get_str(fctry_handle, “serial_number”, buf, &buflen);
```

- The above code initializes and opens the factory NVS partition. Note how we use nvs_flash_init_partition() over nvs_flash_init() and nvs_open_from_partition() over nvs_open()
- The rest of the code for reading the variables uses the standard nvs_get_<type>() function.

## Generating the factory data

A utility *nvs_flash/nvs_partition_generator/nvs_partition_gen.py* is now available to make it easy to generate these unique factory partitions. This utility can generate an NVS partition from a CSV file. The following is an example of the CSV file:

```
$ __cat device-164589345735.csv__ key,type,encoding,value
fctryNamespace,namespace,,
serial_number,data,string,164589345735
mac_addr,data,string,0A:0B:0C:0D:0E:0F
```

So the CSV file has 4 lines. Each line should have 4 entries separated by commas.

- The first entry is the key.
- The second entry is the type. This indicates how should the ‘value’ be interpreted. The supported types are (a) file: the ‘value’ is a filename that actually contains the value for this key, (b) data: the ‘value’ contains the final data, (c) namespace: this key is really a namespace not a key-value pair
- The third entry is the encoding, which specifies how the value should be encoded into the generated partition. Supported values include standard data types like *u8, i8, u16, u32, i32, string*. And also *hex2bin*: which will apply a hex2bin conversion to the data before putting it into the NVS partition.
- The fourth entry is the value that we talked about above.

Now that we have this information, let’s see what the CSV shown above would do:

- The first line is just a heading of the columns, this line should be exactly as shown above
- The second line defines the NVS namespace in which the variables will be defined. In this case, the ‘device_data’ is the namespace that these variables will be defined in
- The third line defines an NVS key serial_no, with the value 164589345735
- The fourth line defines an NVS key mac_addr, with the value 0A:0B:0C:0D:0E:0F

The NVS partition can then be generated as:

```
$ python nvs_partition_gen.py device-164589345735.csv device-164589345735.bin
```

The *device-164589345735.bin* file is the NVS partition data that can now be programmed into the device. Assuming you have the partition table as shown above, the following command should do the job for you:

```
$ /path/to/idf/components/esptool_py/esptool/esptool.py — port /dev/cu.SLAB_USBtoUART write_flash 0x10000 device-164589345735.bin
```

This allows you to create as many unique images as you want, using a script, and then flash them on the respective hardware boards.

Please refer to the NVS partition generator [documentation](https://github.com/espressif/esp-idf/tree/master/components/nvs_flash/nvs_partition_generator/) for more details.

## Current Limitations

- Currently the NVS object value can only be 1968 bytes in size.
