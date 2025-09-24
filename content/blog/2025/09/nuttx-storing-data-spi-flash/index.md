---
title: "SPI Flash for Persistent Data Storage with NuttX RTOS"
date: 2025-09-23
tags: ["NuttX", "Apache", "ESP32", "flash", "data", "storage"]
showAuthor: false
authors:
    - "filipe-cavalcanti"
summary: "This guide explores how to utilize flash memory for persistent data storage in NuttX-based embedded systems, covering SPI Flash fundamentals, file system options (SmartFS, SPIFFS, LittleFS), and practical implementation of a boot time logging application with Wi-Fi and NTP synchronization."
---

## Introduction

When developing embedded applications, one of the challenges developers may face is persistent data storage. Whether you need to store long term important information such as configuration parameters, sensor calibration data or user preferences, understanding how to utilize flash memory can be a game changer.

Espressif SoCs come equipped with internal flash memory that can be partitioned and utilized for various storage needs beyond just program code. NuttX provides mechanisms to access and manage this flash storage.

This article will guide you through the different options available for storing custom user data in flash memory. First, we'll compare flash memory across Espressif devices, followed
by an analysis of some file systems available for use. Then some examples are provided for each file system. Finally, we develop an application that connects to Wi-Fi, updates
the system clock and logs the current time to a file that is stored on flash.

## About Flash Memory 

Before diving into the article, we need to understand what is flash memory and its **limitations**. We will refer to it as flash or SPI Flash interchangeably, since
flash memory in Espressif devices is accessed via SPI bus.

### What is SPI Flash NOR

**SPI Flash NOR memory** is a type of flash memory that, unlike NAND, is not used for mass data storage, such as in flash drives or SD cards. Its main function is to store **executable code**, like the *firmware* of a device. It's the ideal flash memory for what computers call the BIOS or the EFI (Extended Firmware Interface).

### Why use SPI Flash NOR

SPI Flash NOR memory offers several advantages for specific applications:

* **Read speed:** Fast, random reading is the most important characteristic of SPI Flash NOR memory. This is crucial for systems that need to boot quickly, as the *boot* code must be loaded to the processor as fast as possible.
* **Random access:** In NAND memory, reading and writing are done in data blocks. If the processor needs a single bit of information, it has to read the entire block. In NOR memory, it can access the information directly, bit by bit.
* **Reliability:** NOR technology is more reliable than NAND in terms of durability and long-term data retention. Additionally, it has fewer read and write errors.
* **Compact size:** SPI Flash NOR *chips* are small and have few pins, which saves space on printed circuit boards.


### Why not use it for data storage

Despite all its advantages, SPI Flash NOR is not suitable for mass data storage for two main reasons:

* **Cost:** The cost per bit of NOR memory is much higher than that of NAND.
* **Storage density:** NOR memory has a much lower storage density than NAND.

In short, SPI Flash NOR is ideal for storing **executable code** that needs to be read quickly and randomly. For mass data storage, NAND memory is a better option because it is cheaper and has a higher density.

## Espressif Flash Memory Overview

Espressif devices are available with a range of SPI flash sizes, typically from 4 MB up to 16 MB, depending on the specific SoC and module variant selected.

| SoC | Common SPI Flash Sizes |
|-----|----------------------|
| ESP32 | 4 MB to 16 MB |
| ESP32-S2 | 4 MB to 16 MB |
| ESP32-C3 | 4 MB |
| ESP32-S3 | 8 MB to 16 MB |
| ESP32-C6 | 4 MB to 8 MB |
| ESP32-H2 | 4 MB |
| ESP32-P4 | 8 MB or 16 MB |
| ESP32-C5 | 4 MB to 8 MB |

## Flash Memory and NuttX
When using NuttX, a few addresses will define the flash partitioning depending on the bootloader used.

Simple boot is the default bootloader used in NuttX. It is explained in detail for Zephyr in [this article](https://developer.espressif.com/blog/2025/06/simple-boot-explained/), however the same principles apply for NuttX. 

The simple boot approach relies on a single binary file flashed at the beginning of flash memory (0x0000 or 0x1000 for ESP32 and ESP32-S2). There is no limit to the size of the binary except for the maximum flash size.

The alternative to simple boot is MCUBoot, which also adds OTA capabilities. In this case, the binary images will have maximum sizes and the flash is divided into specific partitions such as: slot 0, slot 1, scratch and bootloader.

**This article will focus on simple boot.**

### Flash Memory Layout
As an example, we'll be using an [ESP32-C3-DevKitC-02](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c3/esp32-c3-devkitc-02/user_guide.html), which comes with 4 MB of SPI Flash.

When a binary is generated, it contains the bootloader and application code, which in this case is
the NuttX RTOS. Then, it is flashed at the starting address of 0x0000.

The example below illustrates what a 1.5 MB binary would look like when flashing.

```
ESP32-C3 Flash Memory Layout (Simple Boot) - 4MB Total

Address Range     | Size     | Description
------------------|----------|----------------------------------
0x000000          |          | ┌─────────────────────────────────┐
    |             |          | │                                 │
    |             |          | │        Application Image        │
    |             | ~1.5MB   | │        (Bootloader +            │
    |             |          | │         NuttX RTOS +            │
    |             |          | │         User Applications)      │
    |             |          | │                                 │
0x180000          |          | ├─────────────────────────────────┤
    |             |          | │                                 │
    |             |          | │                                 │
    |             | ~2.5MB   | │     Available Flash             │
    |             |          | │     (Unused/Future Use)         │
    |             |          | │                                 │
    |             |          | │                                 │
0x400000          |          | └─────────────────────────────────┘
(4MB Total)

Key Addresses:
- Application Start:  0x000000
- Application End:    ~0x180000 (varies with build size)
- Total Flash Size:   0x400000 (4MB)
- Available Space:    ~2.5MB for user data/future use
```

In this simple boot configuration, the entire NuttX application (including bootloader, kernel, and user applications) is contained in a single binary image. The remaining flash space can be utilized for data storage.

### Reserving Flash for General Use

Now, to reserve some area for persistent data, we can enable the SPI Flash support on NuttX, which will register a Memory Technology Device (MTD) driver entry at `/dev` that allows access from user space.

The MTD base address is the flash offset for the MTD partition. This offset automatically defines what the maximum binary image size should be, this way we avoid overlapping the persistent data with the application image.

As an example, we can set the MTD base address to 0x110000, which means that the application image could go up to 1.1 MB. We also need a MTD partition size, which for the sake of an example will be set to 0x100000, which is 1 MB. This new layout is illustrated below.

```
ESP32-C3 Flash Memory Layout (Simple Boot with MTD) - 4MB Total

Address Range     | Size     | Description
------------------|----------|----------------------------------
0x000000          |          | ┌─────────────────────────────────┐
    |             |          | │                                 │
    |             |          | │        Application Image        │
    |             | 1.1MB    | │        (Bootloader +            │
    |             |          | │         NuttX RTOS +            │
    |             |          | │         User Applications)      │
    |             |          | │                                 │
0x110000          |          | ├─────────────────────────────────┤
    |             |          | │                                 │
    |             |   1MB    | │     MTD Partition               │
    |             |(0x100000)| │     (User Data Storage)         │
    |             |          | │                                 │
0x210000          |          | ├─────────────────────────────────┤
    |             |          | │                                 │
    |             | ~1.9MB   | │     Available Flash             │
    |             |          | │     (Unused/Future Use)         │
    |             |          | │                                 │
0x400000          |          | └─────────────────────────────────┘
(4MB Total)

Key Addresses:
- Application Start:  0x000000
- Application Limit:  0x110000 (1.1MB max)
- MTD Partition:      0x110000 - 0x210000 (1MB)
- Total Flash Size:   0x400000 (4MB)
- Available Space:    ~1.9MB for future use
```

The MTD partition at `0x110000` provides a dedicated 1MB region accessible via `/dev/mtdX` for user data storage. This partition can be used with file systems like SPIFFS or LittleFS, or accessed directly for custom storage implementations.

## Setting Up SPI Flash in NuttX

The following sections describe some of the common file systems and how to enable them for SPI Flash use on NuttX.

### File System Options

NuttX supports several file systems for flash storage, each with distinct characteristics. Three examples are presented below,
which are currently supported on NuttX for Espressif devices.

- **SmartFS - Sector Mapped Allocation for Really Tiny (SMART) Flash**
  - NuttX-specific file system optimized for embedded systems
  - Good balance of features and resource usage
  - Built-in journaling for power-loss protection
  - Moderate complexity with good performance characteristics
  - Documentation: [SmartFS](https://cwiki.apache.org/confluence/display/NUTTX/Using+SmartFS)

- **SPIFFS - SPI Flash File System**
  - Lightweight, designed specifically for SPI NOR flash
  - Good for small files and read-heavy workloads
  - Limited wear leveling and power-loss resilience
  - Simple implementation with minimal RAM usage
  - Documentation: [SPIFFS](https://github.com/pellepl/spiffs/wiki)

- **LittleFS**
  - Modern file system with excellent power-loss resilience
  - Built-in wear leveling and dynamic wear leveling
  - Better performance for mixed read/write workloads
  - Higher RAM usage but more robust than SPIFFS
  - Documentation: [LittleFS](https://github.com/littlefs-project/littlefs)

The documentation on ESP-IDF website can also be consulted for more detailed technical information: [File System Considerations](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/file-system-considerations.html#file-system-considerations).

### SmartFS

First of all, we configure NuttX to use ESP32-C3 with a pre-configured SPI Flash scenario.

```bash
./tools/configure.sh esp32c3-generic:spiflash
```

Next, open `menuconfig`:
1. Navigate to `System Type` > `SPI Flash Configuration`

Here, you'll find options such as `Storage MTD base address in SPI Flash` and `Storage MTD size in SPI Flash`. Set these values to match the region you reserved for general use (see the [Reserving Flash for General Use](#reserving-flash-for-general-use) section above). This ensures your file system or storage implementation uses the correct flash positioning.

{{< figure
    default=true
    src="imgs/menuconfig_spi_flash_config.webp"
    >}}

2. Enable auto mounting MTD partition: `Main Menu` > `Board Selection` > set `Mount SPI Flash MTD on bring-up` to SmartFS.

You may now exit `menuconfig`, save the configuration, build and flash.

```
$ make -j10
$ make flash ESPTOOL_BINDIR=./ ESPTOOL_PORT=/dev/ttyUSB0
```

#### Testing SmartFS
Open the serial interface and reboot the board, you should see the boot log. Two scenarios could happen now:
1. You already had SmartFS configured on this flash region and the system boots without warnings.
2. It is the first time you boot using SmartFS and the system asks you to format the partition.

The second option looks like this:
```
*** Booting NuttX ***
dram: lma 0x00000020 vma 0x3fc83af0 len 0x644    (1604)
[...]
total segments stored 6
ERROR: Failed to mount the FS volume: -19
Smartfs seems unformatted. Did you run 'mksmartfs /dev/smart0'?
ERROR: Failed to setup smartfs
ERROR: Failed to initialize SPI Flash

NuttShell (NSH) NuttX-12.8.0
nsh> 
```

If that is the case, run `mksmartfs /dev/smart0` so the partition is properly formatted.
When finalized, reboot the board and you should not see any errors, as expected in option 1.

Now run `ls /` to see your file system. A directory called `/data` should be available and that 
is now your SPI Flash available for general use.

```
nsh> ls /
/:
 data/
 dev/
 proc/
```

To test if it works, write a hello world to a file, reboot the board and read it back:

```
nsh> echo 'Hello Espressif Developer Portal!' > /data/hello.txt
nsh> ls /data
/data:
 hello.txt
```

Reboot the board.

```
NuttShell (NSH) NuttX-12.8.0
nsh> ls /data
/data:
 hello.txt
nsh> cat /data/hello.txt
Hello Espressif Developer Portal!
nsh> 
```

### SPIFFS

SPIFFS has a similar procedure, with few changes required.

On `menuconfig`:
1. Enable SPIFFS on auto-mount: `Board Selection` > set `Mount SPI Flash MTD on bring-up` to SPIFFS.
2. Enable BSD License support: `License Setup` > `Use components that have BSD licenses`
2. Enable large file support: `File Systems` > `Large File Support (CONFIG_FS_LARGEFILE)`
3. Optionally, disable SMART FS: `File Systems` > `SMART File system`.

Repeat the make and flash procedure, and open the serial port. You should again see the `/data` directory available for use:
```
nsh> ls
/:
 data/
 dev/
 proc/
```

And the hello world is still present:

```
nsh> cat /data/hello.txt
Hello Espressif Developer Portal!
```

### LittleFS

Repeat the previous steps on the `Board Selection` menu by changing SPI Flash bring-up to LittleFS,
then navigating to `File Systems` and disabling SPIFFS.

On `menuconfig`:
1. Enable LittleFS on auto-mount: `Board Selection` > set `Mount SPI Flash MTD on bring-up` to LittleFS.
3. Optionally, disable SPIFFS: `File Systems` > `SPIFFS File System`.

Repeat the make and flash procedure. Now when you boot and look into `/data` you will see that it is empty.
That is because LittleFS is not compatible with SPIFFS or SmartFS.

We should format the partition use it as usual. First, obtain the name of the flash device under `/dev`. In this example,
it is `/dev/espflash`. Then, format the partition with `flash_eraseall` and reboot the board.

```
nsh> ls /dev
/dev:
 console
 espflash
 null
 random
 ttyS0
 zero
nsh> flash_eraseall /dev/espflash
```

Reboot the board.

```
nsh> echo 'Hello Espressif Developer Portal!' > /data/hello.txt
nsh> ls /data
/data:
 .
 ..
 hello.txt
nsh> cat /data/hello.txt
Hello Espressif Developer Portal!
```

Success! We can save files on our SPI Flash and have demonstrated it in three different file systems.

## Practical Application

Now that we have managed to take control of the SPI Flash, we may now create an application that makes use of this functionality.

Let's say our application needs to **log the last time the board was reset**, however we don't have RTC but we do have Wi-Fi available.
My goal is to save date and time of each reboot on flash after Wi-Fi connects, so I can monitor downtime.

First, our board should connect to Wi-Fi, synchronize its clock and write the current date and time to a file.

For this to work, we need: functional Wi-Fi, Network Time Protocol (NTP) and some automation. The Wi-Fi part we are not going to
look deep into since we have other articles on it, instead, let's go straight to NTP and automating.

Check the following for instructions on wireless connectivity:
- [NuttX Getting Started](https://developer.espressif.com/blog/nuttx-getting-started/)
- [Wi-Fi Network Configuration for Motor Control](https://developer.espressif.com/blog/2025/07/nuttx-motor-control-and-sensing-data-trans/#wi-fi-network-configuration)
- [ESP32-C3 NuttX Documentation on Wi-Fi](https://nuttx.apache.org/docs/latest/platforms/risc-v/esp32c3/boards/esp32c3-generic/index.html#wifi)

### Understanding NTP

Network Time Protocol (NTP) is a networking protocol used to synchronize the clocks of computers and embedded devices over a network. It allows devices to obtain accurate time information from NTP servers, ensuring that system clocks are consistent and correct. In embedded systems like NuttX, NTP is commonly used to set the system time after boot or network reconnection, especially when there is no real-time clock (RTC) hardware available.

Start a new NuttX environment using the `wifi` defconfig:

```
./tools/configure.sh esp32c3-generic:wifi
```

Configure NTP on `menuconfig`:

1. Enable the NTP client: `Application Configuration` > `Network Utilities` > enable `NTP client`
2. Enable NTP daemon commands: `Application Configuration` > `System Libraries and NSH Add-Ons` > enable `NTP Daemon Commands`

Now build and flash the device.

Open the serial port and connect to Wi-Fi. Once we are connected, we should start the NTP task, which will try to
synchronize the system clock over the network.

Connect to Wi-Fi:
```
nsh> wapi psk wlan0 espmint123 3 3
nsh> wapi essid wlan0 Nuttx-IOT 1
nsh> renew wlan0
```

Start the NTP client:
```
nsh> ntpcstart
Starting NTP client...
Using NTP servers: 0.pool.ntp.org;1.pool.ntp.org;2.pool.ntp.org
NTP client started successfully (task ID: 10)
NTP client is now running in the background
```

Now wait a few seconds and run the `date` command.

```
nsh> date
Fri, Sep 05 19:34:43 2025
```

We should now have our system clock in perfect sync!

### Automating Boot Time Logging

Now that we know how to synchronize the system clock to the network, we should do this automatically.

#### Enable Startup Script

To achieve our automation, we enable the ROMFS and startup script. The startup script is able to run sh commands after the initial system bring-up, which we can use for automating network connection and saving the date in flash.

On `menuconfig`:
1. Enable ROMFS: `File Systems` -> enable `ROMFS file system (CONFIG_FS_ROMFS)`.
2. Enable auto-mounting `/etc`: `RTOS Features` > `Tasks and Scheduling` > enable `Auto-mount etc baked-in ROMFS image (CONFIG_ETC_ROMFS)`.

Now flash the board and open the serial console. We should see two messages before the NSH banner,
and the `/etc` file system.

```
total segments stored 7
rc.sysinit is called!
rcS file is called!

NuttShell (NSH) NuttX-12.8.0
nsh> ls /etc/init.d
/etc/init.d:
 .
 ..
 rc.sysinit
 rcS
nsh> 
```

Success! We have a simple script that echoes a message before the shell is available.

#### Connecting to Wi-Fi and Logging Date

Now we need to automate Wi-Fi and date logging. At this point, because we are using Wi-Fi,
the SPI Flash support should already be enabled.

Navigate to `nuttx/boards/risc-v/esp32c3/common/src/etc/init.d` and add the
WAPI commands to automatically connect to Wi-Fi and log the date on the `rcS` file:

```
wapi psk wlan0 espmint123 3 3
wapi essid wlan0 Nuttx-IOT 1
renew wlan0
ntpcstart
echo "Wait until date is synced..."
sleep 10
date >> /data/log.txt
```

This will connect to Wi-Fi, start the NTP client and sleep for a while so it has time
to update the date information. Then, save the date to a log file.

Build and flash the binary. We should now see the following on the log file:

```
*** Booting NuttX ***
[...]
rc.sysinit is called!
rcS file is called!
Started the NTP daemon as PID=10
Wait until date is synced...

NuttShell (NSH) NuttX-12.8.0
nsh> cat /data/log.txt
Mon, Sep 15 12:48:58 2025
nsh> 
```

Rebooting the board, we should get a new line with the correct time, while still retaining
in flash the previous date:

```
nsh> cat /data/log.txt
Mon, Sep 15 12:48:58 2025
Mon, Sep 15 12:51:33 2025
nsh> 
```

## Conclusion

This article has demonstrated how to effectively utilize flash memory for persistent data storage in NuttX-based embedded systems. We've covered the fundamental concepts of SPI Flash NOR memory, explored different file system options (SmartFS, SPIFFS, and LittleFS), and implemented a practical application that logs system boot times to flash storage.

Those are important takeaways:

- **Flash Memory Understanding**: SPI Flash NOR is ideal for storing executable code and small amounts of persistent data, but not suitable for mass storage due to cost and density limitations.

- **File System Selection**: Each file system has distinct characteristics:
  - **SmartFS**: Good balance of features with built-in journaling
  - **SPIFFS**: Lightweight and simple, ideal for read-heavy workloads
  - **LittleFS**: Modern with excellent power-loss resilience and wear leveling

- **Practical Implementation**: The boot time logging example demonstrates how to combine Wi-Fi connectivity, NTP synchronization, and flash storage to create a robust data logging system.

### Date Logging Example Considerations

While the example uses a simple `sleep 10` approach to wait for NTP synchronization, more sophisticated implementations are possible:

- **Polling-based synchronization**: Instead of sleeping, implement a loop that checks if the system time has been updated by NTP
- **Callback mechanisms**: Use NTP client callbacks to trigger logging only after successful time synchronization
- **Timeout handling**: Implement proper timeout mechanisms to avoid indefinite waiting

These approaches would provide more reliable and efficient date logging, especially in production environments where network conditions may change.

## Related Resources

- [NuttX ESP32 Documentation](https://nuttx.apache.org/docs/latest/platforms/risc-v/esp32c6/index.html)
- [ESP32 Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/security/flash-encryption.html)
- [ESP32-C6 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-c6_technical_reference_manual_en.pdf)
- [NuttX File System Documentation](https://nuttx.apache.org/docs/latest/components/filesystem/index.html)
- [Getting Started with NuttX and ESP32](https://developer.espressif.com/blog/nuttx-getting-started/)
- [SPIFFS](https://github.com/pellepl/spiffs/wiki)
- [LittleFS](https://github.com/littlefs-project/littlefs)
- [FAT FS](https://nuttx.apache.org/docs/latest/components/filesystem/fat.html)
- [SmartFS](https://cwiki.apache.org/confluence/display/NUTTX/Using+SmartFS)
- [NTP Daemon](https://nuttx.apache.org/docs/latest/applications/system/ntpc/index.html)
- [NTP Client](https://nuttx.apache.org/docs/latest/applications/netutils/ntpclient/index.html)
