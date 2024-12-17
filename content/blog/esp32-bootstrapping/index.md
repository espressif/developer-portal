---
title: "ESP32 bootstrapping in Zephyr"
date: 2024-10-30T10:18:10+02:00
showAuthor: false
authors:
  - "marek-matej"
tags: ["ESP32", "ESP32-S2", "ESP32-S3", "ESP32-C3", "ESP32-C6", "ESP-IDF", "Zephyr"]
---

Those acquainted with the ESP32 system-on-chip (SoC) family know the complexity involved in analyzing its booting process. From navigating the embedded ROM bootloader, facilitated by comprehensive tooling, to initiating the 2nd stage bootloader, which subsequently launches the user application. The procedure deviates significantly from the the straightforward "jump-to-reset-vector" way of starting the user program, as we can see on the ARM architecture.

In this article, I'll explore the details of how the Espressif SoC boots up. I'll focus on how it's done specifically within the popular Zephyr RTOS, which has become a go-to choice for many vendors, including Espressif, the brains behind the ESP32.

## Introduction

Our goal is to understand each boot stage and to recognize and fix the issues that come from the particular component or boot stage. So, let's roll up our sleeves and explore how these pieces fit together!

The main building blocks of the article we will be investigating are:

- **ROM code & loader** *(image loader, reserved memory regions)*
- **2nd stage loader** *(build types, bootstrap flow)*
- **Building** *(linking, memory utilization)*
- **Tooling** *(esptool.py, image formats)*

## ROM code

The ESP32 SoCs have external flash memory which need certain attention prior to use. That is one of the reasons why ESP32 has on-chip ROM memory. All necessary startup, communication and the flash access libraries are stored and directly accessed from there.

There are certain functions available in the ROM code that are particularly useful (debugging, loading purposes) and can have an impact on the overall code footprint. However, using or not using the ROM functions during the application runtime is completely up to the user.

### ROM loader

Main feature of ROM code is to load the image present at the flash non-volatile memory. Therefore we can refer to it as the *1st stage bootloader*.

The binary image loaded by the ROM code must take a form recognizable by the loader. It uses the ESP image header and ESP segment header to identify the image and its subsequent segments.

The ***ESP image format*** header (24 Bytes):

```cpp
typedef struct {
  uint8_t magic;              /* Magic word 0xE9 */
  uint8_t segment_count;      /* Count of memory segments */
  uint8_t spi_mode;           /* flash read mode */
  uint8_t spi_speed: 4;       /* flash frequency */
  uint8_t spi_size: 4;        /* flash chip size */
  uint32_t entry_addr;        /* Entry address */
  uint8_t wp_pin;             /* WP pin when SPI pins set via efuse
                               * 0xEE=disabled
			       */
  uint8_t spi_pin_drv[3];     /* Drive settings for the SPI flash pins */
  uint16_t chip_id;           /* Chip identification number */
  uint8_t min_chip_rev;       /* Minimal chip revision supported by image */
  uint16_t min_chip_rev_full; /*   format: major * 100 + minor */
  uint16_t max_chip_rev_full; /*   format: major * 100 + minor */
  uint8_t reserved[4];        /* Reserved bytes in additional header space */
  uint8_t hash_appended;      /* If 1, a SHA256 digest "simple hash"
                               * is appended after the checksum.
                               */
} esp_image_header_t;

```

The ***ESP image format*** segment header (8 Bytes):
```cpp
typedef struct {
    uint32_t load_addr;     /* Address of segment */
    uint32_t data_len;      /* Length of data */
} esp_image_segment_header_t;

```

Graphical representation of the ESP image format:

{{< figure
    default=true
    src="img/esp-image-format.webp"
    alt=""
    caption="The ESP image format."
    >}}

This binary image format is used in 1st stage image loading, but can be adopted and used for other purposes as well. For example when providing an additional images for asymmetric multi processing (AMP).

## 2nd stage

One of the roles of 2nd stage loader code is to initialize hardware for the user application code. The first loader only initialize the basic sets of functionality which is needed to load the code from the external flash memory. There are other peripherals and resources that can be set-up, but they are out of the scope of first loader.
Implementation of those additional resources depends on used build scenario.

1. **Single image build** creates the image that can be processed by the ROM loader (aka Simpleboot)
2. **Multi image build** consist of 2nd stage bootloader and one *or more* application images

    The bootloader options we will discuss:
    - IDF bootloader
    - MCUboot

You can refer to the table with list of features and boot scenarios for the Zephyr RTOS on ESP32 at the end of this article.

### Simpleboot

The default build scenario in Zephyr RTOS port of ESP32. The configuration option indicating the use of this build scenario:
- `CONFIG_ESP_SIMPLE_BOOT=y`
- `CONFIG_BOOTLOADER_MCUBOOT=n`

***NOTE:** Do not confuse Simple Boot with the `CONFIG_DIRECT_BOOT`, which is native to newest RISC-V based SoCs, such as ESP32-C3.*

```mermaid
flowchart TD
	ROM .->|load| FP0;
	APP .->|load/map| FP0;
	subgraph "ROM code";
	ROM;
	end;
	subgraph "Simpleboot chain";
	ROM ==> APP;
	end;
	subgraph "NV Storage";
	FP0;
	end;
	ROM@{ shape: rounded, label: "**ROM loader**" };
	APP@{ shape: rounded, label: "**Application** </br>*(ESP image format)*" };
	FP0@{ shape: das, label: "**Boot&Application** </br> *(Can use entire flash)*</br>*DT_NODE_LABEL(boot_partition)*</br>*DT_NODE_BY_FIXED_PARTITION_LABEL(mcuboot)*" };
```

The default booting (and building) method employed in Zephyr RTOS for ESP32 SoCs is called Simple Boot. This method generates a single application binary output, thereby streamlining the complexity of the process. Although it may lack certain advanced features, its appeal lies in its straightforwardness, offering an out-of-the-box solution for initiating any application. This simplicity makes it an accessible choice for developers seeking an uncomplicated development experience.


### Bootloaders


#### IDF bootloader

***NOTE:*** *The IDF bootloader is deprecated in Zephyr RTOS but it is discussed here for the reference and because it has been used in early port of ESP32 on Zephyr RTOS*

The IDF bootloader is the default 2nd stage bootloader for the ESP-IDF platform provided by Espressif. In the Zephyr RTOS it was used to load the application image (RAM load and flash map), but further functionalities were not ported so it acts as an accessible and simple loader.

The reasons for removal of IDF bootloader from the Zephyr RTOS port:

- building during each application build in the `ExternalProject` stage. Building multiple binaries in single build turn is not allowed in Zephyr RTOS.
- introduction of MCUboot Zephyr RTOS port, which supports `--sysbuild`.


#### MCUboot

The MCUboot over the years becomes de-facto standard bootloader in IoT realm and Espressif Systems adopted it in several forms depending on used framework.

There are two config options - that are often confused - indicates the usage of the MCUboot bootloader:
- `CONFIG_BOOTLOADER_MCUBOOT` *(it is enabled during the application build, which will be loaded by the MCUboot at runtime)*
- `CONFIG_MCUBOOT` *(it is enabled only during the MCUboot build)*

Currently there are two ESP32 ports of MCUboot that can be used in Zephyr RTOS.
1.  **MCUboot Zephyr RTOS Port (ZP)** - native Zephyr RTOS support via sysbuild
2.  **MCUboot Espressif Port (EP)** - standalone port build separately (*)

***\**** *There is ongoing effort to unify those two ports*

```mermaid
flowchart TD
	ROM .->|load| FP0;
	BL2 .->|load| FP1;
	APP .->|load/map| FP1;
	ROM ==> BL2;
	subgraph RC ["ROM code"];
	ROM;
	end;
	subgraph "Bootloader chain";
	BL2 ==> APP;
	end;
	subgraph "NV Storage";
	FP0;
	FP1;
	end;
	ROM@{ shape: rounded, label: "**ROM loader**" };
	BL2@{ shape: rounded, label: "**MCUboot** </br>*(ESP image format)*" };
	APP@{ shape: rounded, label: "**Application** </br>*(MCUboot format)*" };
	FP0@{ shape: das, label: "**Boot partition**</br>DT_NODE_LABEL(boot_partition)</br>DT_NODE_BY_FIXED_PARTITION_LABEL(mcuboot)" };
	FP1@{ shape: das, label: "**Application partition**</br>*DT_NODE_LABEL(slot0_partition)*</br>*DT_NODE_BY_FIXED_PARTITION_LABEL(image_0)*" };
```

The standard MCUboot header is placed at the offset `0x00`. Following structure represent its format:
```cpp
/* MCUboot image header. All fields are in little endian byte order. */
struct image_header {
    uint32_t ih_magic;              /* 0x96f3b83d OR 0x96f3b83c (V1) */
    uint32_t ih_load_addr;          /* Subsequent ESP header is used to hold application entry address */
    uint16_t ih_hdr_size;           /* Size of image header (bytes) */
    uint16_t ih_protect_tlv_size;   /* Size of protected TLV area (bytes) */
    uint32_t ih_img_size;           /* Does not include header */
    uint32_t ih_flags;              /* Image flags */
    struct image_version ih_ver;    /* Image version */
    uint32_t _pad1;                 /* Padding */
} __packed;

```

The application image loaded by the MCUboot has an additional header with the information about used SRAM segments, which is placed at the offset `0x20`, just after the  standard MCUboot header.

```cpp
typedef struct esp_image_load_header {
    uint32_t header_magic;          /* Magic number 0xace637d3 */
    uint32_t entry_addr;            /* Application entry address */
    uint32_t iram_dest_addr;        /* VMA of IRAM region */
    uint32_t iram_flash_offset;     /* LMA of IRAM region */
    uint32_t iram_size;             /* Size of IRAM region */
    uint32_t dram_dest_addr;        /* VMA of DRAM region */
    uint32_t dram_flash_offset;     /* LMA of DRAM region */
    uint32_t dram_size;             /* Size of DRAM region */
} esp_image_load_header_t;
```

Additional information on the flash and/or SPIRAM regions are provided as a linker symbols and are embedded inside the application image.


## Memory utilization

Before we build some example applications, let’s take a moment to discuss how the linking process utilizes SRAM on the ESP32-S3.
It’s important to note that different Espressif SoCs can have unique memory layouts, which can affect how resources are allocated.
Therefore each SoC is using slightly different linker script.

The images below illustrate the process of application linking, focusing on how the ROM code interacts with SRAM. Key details, such as I-Cache and D-Cache allocations, are highlighted for clarity.
Important linker symbols, crucial to understanding the memory layout, are shown in green bubbles.

- Yellow area is the memory used by the 2nd stage bootloader that can be re-claimed by the application code run-time.
- Orange area is the memory used by the 1st stage bootloader (or ROM-loader), that can be re-claimed after the application loading is done.
- Red area is the memory that is not available for the user and should not be used by the linker to spill the code or data.


### ESP32-S3 use-case

Here we are using the ESP32-S3 to illustrate memory utilization, which is **suitable as a reference for most of the newer SoCs**.

The following picture illustrates the memory utilization for an single CPU scenario.

{{< figure
    default=true
    src="img/esp32s3-zephyr-memory-default.webp"
    alt=""
    caption="The ESP32-S3 'default' memory utilization."
    >}}


The following picture illustrates memory utilization in a multi-CPU scenario.

{{< figure
    default=true
    src="img/esp32s3-zephyr-memory-amp.webp"
    alt=""
    caption="The ESP32-S3 'AMP' memory utilization."
    >}}


***NOTE:***
*The I-Cache allocation SRAM blocks (0,1) are set by the **`PMS_INTERNAL_SRAM_ICACHE_USAGE`** bits
and the D-Cache allocation SRAM blocks (9,10) are set by the **`PMS_INTERNAL_SRAM_DCACHE_USAGE`** bits, both in the register `PMC_INTERNAL_SRAM_USAGE_1_REG`*


### ESP32 use-case

Here is the memory utilization for the ESP32 platform as its memory model is significantly different from other Espressif SoCs.

The following picture illustrates memory utilization in a single CPU scenario.

{{< figure
    default=true
    src="img/esp32-zephyr-memory-default.webp"
    alt=""
    caption="The ESP32 'default' memory layout."
    >}}


Following picture illustrates the memory utilization in the multi CPU scenario.

{{< figure
    default=true
    src="img/esp32-zephyr-memory-amp.webp"
    alt=""
    caption="The ESP32-S3 'AMP' memory layout."
    >}}


### Tooling - esptool.py

The *esptool.py* is the essential tool used to manipulate the binaries for the ESP32 SoCs. Among the other features our focus is on the `--elf2image` command, which is used to convert the `.elf` images to the loadable `.bin` images. This tool is used to create the images loadable by the ROM loader.

Process of creation of the ***ESP image format*** compatible image:
```mermaid
flowchart LR
	A -->|linker| B
	B -->|post build| C
	C --> D
	A@{ shape: rounded, label: "**Build**</br>*(west build)*" }
	B@{ shape: rounded, label: "**.elf**</br>*(objcpy .bin discarded)*" }
	C@{ shape: rounded, label: "**esptool.py**</br>*--elf2image*" }
	D@{ shape: rounded, label: "**.bin**</br>*(ESP image format)*" }
```

Resulting binary can be loaded to any LMA location (in flash). Its segments will be processed at the location and SRAM will be copied to the corresponding SRAM location, and possible FLASH or SPIRAM segments will be mapped to the virtual address space VMA.


## Building

Finally let's build some real life examples that can be flashed into the target board to demonstrate what was discussed in previous chapters.
Before that it is important to note the image formats used with the Zephyr port of the Espressif SoCs.

The table shows the image formats used in various build scenarios:

| Image / core                              | Image format    |
| :---------------------------------------: | :-------------: |
| Application (Simple Boot) /<br>`@PRO_CPU` | *ESP image*     |
| MCUboot / `@PRO_CPU`                      | *ESP image*     |
| Application / `@PRO_CPU`                  | *MCUboot image* |
| Application / `@APP_CPU`                  | *MCUboot image* |


### Simpleboot

Single image builds are used as a default build option in the Zephyr RTOS and the CI (unless `--sysbuild` is used).

Building and flashing a WiFi sample application using the Simple Boot:
```shell
cd zephyrproject/zephyr
west build -b esp32s3_devkitm/esp32s3/procpu samples/net/wifi/shell -p
west flash && west espressif monitor
```

The resulting image when boots and shows the output similar to this:
```
ESP-ROM:esp32s3-20210327
Build:Mar 27 2021
rst:0x1 (POWERON),boot:0xa (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:2
load:0x3fc946c8,len:0x36dc
load:0x40374000,len:0x106a8
entry 0x4037d24c
I (98) boot: ESP Simple boot
I (98) boot: compile time Oct 27 2024 09:58:26
W (98) boot: Unicore bootloader
I (98) spi_flash: detected chip: gd
I (99) spi_flash: flash io: dio
W (102) spi_flash: Detected size(8192k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (115) boot: chip revision: v0.2
I (117) boot.esp32s3: Boot SPI Speed : 40MHz
I (121) boot.esp32s3: SPI Mode       : DIO
I (125) boot.esp32s3: SPI Flash Size : 8MB
I (129) boot: Enabling RNG early entropy source...
I (134) boot: DRAM: lma 0x00000020 vma 0x3fc946c8 len 0x36dc   (14044)
I (140) boot: IRAM: lma 0x00003704 vma 0x40374000 len 0x106a8  (67240)
I (146) boot: padd: lma 0x00013db8 vma 0x00000000 len 0xc240   (49728)
I (152) boot: IMAP: lma 0x00020000 vma 0x42000000 len 0x52b68  (338792)
I (159) boot: padd: lma 0x00072b70 vma 0x00000000 len 0xd488   (54408)
I (165) boot: DMAP: lma 0x00080000 vma 0x3c060000 len 0x1481c  (83996)
I (171) boot: Image with 6 segments
I (174) boot: DROM segment: paddr=00080000h, vaddr=3c060000h, size=14820h ( 84000) map
I (182) boot: IROM segment: paddr=00020000h, vaddr=42000000h, size=52B66h (338790) map
I (226) heap_runtime: ESP heap runtime init at 0x3fcab850 size 247 kB.


*** Booting Zephyr OS build v3.7.0-5030-ge7db0f8aff81 ***
uart:~$
```


### MCUboot Zephyr port (ZP)

First lets take a look at how to manually build the MCUboot and the subsequent application. Each `west flash` in the code is using its own flash partition and it is not overwritten by each other. 

Building and flashing the MCUboot separately at its location:
```shell
cd zephyrproject/bootloader/mcuboot
west build -b esp32s3_devkitm/esp32s3/procpu boot/zephyr -p
west flash && west espressif monitor
```

Building and flashing the sample application that is loadable by the MCUboot created in previous step:
```shell
cd zephyrproject/zephyr
west build -b esp32s3_devkitm/esp32s3/procpu samples/net/wifi -p -DCONFIG_BOOTLOADER_MCUBOOT=y
west flash && west espressif monitor
```

Now, we can rely on the Sysbuild and build all images at once.

Building and flashing the application with MCUboot (ZP) using ***sysbuild***:
```shell
cd zephyrproject/zephyr
west build -b esp32s3_devkitm/esp32s3/procpu samples/new/wifi -p --sysbuild
west flash && west espressif monitor
```

In both cases (manual build & using `--sysbuild` option) we should see the following console output after the image boots:
```
ESP-ROM:esp32s3-20210327
Build:Mar 27 2021
rst:0x1 (POWERON),boot:0xb (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:2
load:0x3fcc1400,len:0x2c64
load:0x403ba400,len:0xa0d4
load:0x403c6400,len:0x16a0
entry 0x403bd114
I (61) boot: MCUboot 2nd stage bootloader
I (61) boot: compile time Oct 27 2024 10:01:14
W (61) boot: Unicore bootloader
I (61) spi_flash: detected chip: gd
I (63) spi_flash: flash io: dio
W (66) spi_flash: Detected size(8192k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (78) boot: chip revision: v0.2
I (81) boot.esp32s3: Boot SPI Speed : 40MHz
I (85) boot.esp32s3: SPI Mode       : DIO
I (89) boot.esp32s3: SPI Flash Size : 8MB
I (93) boot: Enabling RNG early entropy source...
I (132) spi_flash: flash io: dio
[esp32s3] [INF] Image index: 0, Swap type: none
[esp32s3] [INF] Loading image 0 - slot 0 from flash, area id: 1
[esp32s3] [INF] Application start=4037c0f0h
[esp32s3] [INF] DRAM segment: paddr=0002b22ch, vaddr=3fc8f210h, size=022e4h (  8932) load
[esp32s3] [INF] IRAM segment: paddr=00020040h, vaddr=40374000h, size=0b1ech ( 45548) load
I (165) boot: DROM segment: paddr=00090000h, vaddr=3c060000h, size=14750h ( 83792) map
I (165) boot: IROM segment: paddr=00030000h, vaddr=42000000h, size=52D72h (339314) map
I (205) heap_runtime: ESP heap runtime init at 0x3fca4f70 size 273 kB.


*** Booting Zephyr OS build (tainted) v3.7.0-5030-ge7db0f8aff81 ***
uart:~$
```


### MCUboot Espressif port (EP)

To learn how to build the MCUboot Espressif Port, check out this [article](https://docs.mcuboot.com/readme-espressif.html)


### AMP enabled sample code

AMP builds require several images to be built and flashed onto a target SoC. Let's use ESP32-S3 as our test platform and demonstrate the sysbuild capabilities on the sample code provided by the Zephyr RTOS sources.
The Zephyr sample code (`samples/drivers/ipm/ipm_esp32`) uses IPM (Inter-Processor Mailbox) to demonstrate a simple two-way communication between the `PRO_CPU` core and `APP_CPU` core. Images for both CPU cores must be loaded using the MCUboot.
Note that there is no support for running AMP if the Simple Boot mechanism is used.

Now we can build and flash a complete set of images running the IPM sample:
```shell
cd zephyrproject/zephyr
west build -b esp32s3_devkitm/esp32s3/procpu samples/drivers/ipm/ipm_esp32/ -p --sysbuild
west flash && west espressif monitor
```

As a result, three images should be created:

- `ipm_esp32` - the image for the `PRO_CPU` core
- `ipm_esp32_remote` - the image for the `APP_CPU` core
- `mcuboot` - the MCUboot image, which is run by `PRO_CPU`


After flashing and connecting to a target using the serial port, we should be able to see the following output in the console:
```
ESP-ROM:esp32s3-20210327
Build:Mar 27 2021
rst:0x1 (POWERON),boot:0x8 (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:2
load:0x3fcb5400,len:0x2bd8
load:0x403ba400,len:0xa1fc
load:0x403c6400,len:0x15c4
entry 0x403bd044
I (61) soc_init: MCUboot 2nd stage bootloader
I (61) soc_init: compile time Dec 12 2024 16:26:23
W (61) soc_init: Unicore bootloader
I (61) spi_flash: detected chip: generic
I (65) spi_flash: flash io: dio
W (68) spi_flash: Detected size(8192k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (80) soc_init: chip revision: v0.1
I (83) flash_init: Boot SPI Speed : 40MHz
I (87) flash_init: SPI Mode       : DIO
I (90) flash_init: SPI Flash Size : 8MB
I (94) soc_random: Enabling RNG early entropy source
I (99) soc_random: Disabling RNG early entropy source
I (103) boot: Disabling glitch detection
I (107) boot: Jumping to the main image...
I (145) spi_flash: flash io: dio
[esp32s3] [INF] Image index: 0, Swap type: none
[esp32s3] [INF] Loading image 0 - slot 0 from flash, area id: 1
[esp32s3] [INF] Application start=40378a48h
[esp32s3] [INF] DRAM segment: paddr=00026ee8h, vaddr=3fc8aec8h, size=010e4h (  4324) load
[esp32s3] [INF] IRAM segment: paddr=00020040h, vaddr=40374000h, size=06ea8h ( 28328) load
I (177) boot: DROM segment: paddr=00040000h, vaddr=3c010000h, size=016A0h (  5792) map
I (177) boot: IROM segment: paddr=00030000h, vaddr=42000000h, size=042A2h ( 17058) map
I (193) soc_random: Disabling RNG early entropy source
I (193) boot: Disabling glitch detection
I (193) boot: Jumping to the main image...
I (228) heap_runtime: ESP heap runtime init at 0x3fc8f960 size 154 kB.

APPCPU image, area id: 2, offset: 0x170000, hdr.off: 0x20, size: 512 kB
IRAM segment: paddr=00170040h, vaddr=403a6400h, size=0571ch ( 22300) load
DRAM segment: paddr=0017575ch, vaddr=3fcbbb20h, size=00a58h (  2648) load
Application start=403a6924h

*** Booting Zephyr OS build v4.0.0-1981-g5e6b13a7bbff ***
PRO_CPU is sending a request, waiting remote response...
PRO_CPU received a message from APP_CPU : APP_CPU uptime ticks 501

PRO_CPU is sending a request, waiting remote response...
PRO_CPU received a message from APP_CPU : APP_CPU uptime ticks 10503

PRO_CPU is sending a request, waiting remote response...
PRO_CPU received a message from APP_CPU : APP_CPU uptime ticks 20504
```


## Bootloader Feature table

The ESP32 port in Zephyr RTOS has variety of booting options.

| Features            | IDFboot  <br>(deprecated) | MCUboot  <br>(Zephyr port) | MCUboot  <br>(Espressif port) | Simple Boot |
| ------------------: | :-----------------------: | :------------------------: | :---------------------------: | :---------: |
| Sysbuild            | N                         | Y                          | N                             | Y           |
| HW Initialization   | Y                         | Y                          | Y                             | Y           |
| Application Loading | Y                         | Y                          | Y                             | Y           |
| Slots Manipulation  | N                         | Y                          | Y                             | N           |
| OTA                 | N                         | Y                          | Y                             | N           |
| Flash Encryption    | \-                        | N                          | Y                             | N           |
| Basic Security      | \-                        | Y                          | Y                             | N           |
| Secure Boot V2      | \-                        | N                          | Y                             | N           |


## Additional reading

- [Zephyr RTOS and ESP32](https://www.zephyrproject.org/zephyr-rtos-on-esp32/)
- [ESP32's memory map](https://developer.espressif.com/blog/esp32-memory-map-101/)
- [ESP32 Programmers memory model](https://developer.espressif.com/blog/esp32-programmers-memory-model/)
- [ESP32-S3 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf)
