---
title: "ESP32 bootstrapping in Zephyr"
date: 2024-08-27T10:18:10+02:00
showAuthor: false
authors:
  - "marek-matej"
tags: ["ESP32", "ESP32-S2", "ESP32-S3", "ESP32-C3", "ESP32-C6", "ESP-IDF", "Zephyr"]
---

Those acquainted with the ESP32 system-on-chip (SoC) family are well aware of the complexity involved in analyzing its booting process. From navigating the embedded ROM bootloader, facilitated by comprehensive tooling, to initiating the 2nd stage bootloader, which subsequently launches the user application. The procedure deviates significantly from the the straightforward "jump-to-reset-vector" way of starting the user program, we can see on the ARM architecture.

In this article, I'll dive into the nitty-gritty of how the Espressif SoC boots up. I'll be focusing on how it's done specifically within the popular Zephyr RTOS which has become a go-to choice for many vendors, including Espressif, the brains behind the ESP32.

## Introduction

Our goal is to understand each boot stage and to recognize and fix the issues that comes from the particular component or boot stage. So, let's roll up our sleeves and explore how these pieces fit together!

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
- `CONFIG_ESP_SIMPLE_BOOT`

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
	ROM@{ shape: round, label: "**ROM loader**" };
	APP@{ shape: round, label: "**Application** </br>*(ESP image format)*" };
	FP0@{ shape: das, label: "**Boot&Application** </br> *(Can use entire flash)*</br>*DT_NODE_LABEL(boot_partition)*</br>*DT_NODE_BY_FIXED_PARTITION_LABEL(mcuboot)*" };
```

The default booting (and building) method employed in Zephyr RTOS for ESP32 SoCs is referred to as Simple Boot. This method generates a single application binary output, thereby streamlining the complexity of the process. Although it may lack certain advanced features, its appeal lies in its straightforwardness, offering an out-of-the-box solution for initiating any application. This simplicity makes it an accessible choice for developers seeking an uncomplicated development experience.


### Bootloaders


#### IDF bootloader

***NOTE:*** *The IDF bootloader is deprecated in Zephyr RTOS but it is discussed here for the reference and because it has been used in early port of ESP32 on Zephyr RTOS*

The IDF bootloader is the default 2nd stage bootloader for the ESP-IDF platform provided by Espressif. In the Zephyr RTOS it was used to load the application image (RAM load and flash map), but further functionalities were not ported so it acts as an accessible and simple loader.

The reasons for removal of IDF bootloader from the Zephyr RTOS port:

- building during each application build in the `ExternalProject` stage. Building multiple binaries in single build turn is not allowed in Zephyr RTOS.
- introduction of MCUboot Zephyr RTOS port, which supports `--sysbuild`.


#### MCUboot

The MCUboot over the years becomes de-facto standard bootloader in IOT realm and Espressif Systems adopted it in several forms depending on used framework.

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
	BL2 .->|load/map| FP1;
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
	ROM@{ shape: round, label: "**ROM loader**" };
	BL2@{ shape: round, label: "**MCUboot** </br>*(ESP image format)*" };
	APP@{ shape: round, label: "**Application** </br>*(MCUboot format)*" };
	FP0@{ shape: das, label: "**Boot partition**</br>DT_NODE_LABEL(boot_partition)</br>DT_NODE_BY_FIXED_PARTITION_LABEL(mcuboot)" };
	FP1@{ shape: das, label: "**Application partition**</br>*DT_NODE_LABEL(slot0_partition)*</br>*DT_NODE_BY_FIXED_PARTITION_LABEL(image_0)*" };
```

The application image loaded by the MCUboot has additional header with information about the SRAM segments.

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

## Building

Following is the description of some basic build steps so you can create the images and scenarios discussed in this article at home.

But first lets talk briefly about how the link process utilize the SRAM memory on the ESP32-S3. Note, that different Espressif SoCs have different memory layout.

### Memory utilization

Following image illustrates the application linking process. Highlighted are details of ROM code usage in SRAM1, and I-Cache, D-Cache placement.
The illustration is covering an single CPU scenario and does not cover the AMP case.

- Yellow hatched area is the memory that can't be rewritten during the 2nd stage loading (it can be re-claimed during the runtime)
- Orange hatched area is the memory that can be re-claimed after the application loading is done.
- Red hatched areas are the memory parts that are not available for the user and should be avoided by the linker.

{{< figure
    default=true
    src="img/esp32s3-zephyr-memory-usage.webp"
    alt=""
    caption="The ESP32-S3 memory utilization."
    >}}

***NOTE:***
*The I-Cache allocation SRAM blocks (0,1) are set by the **`PMS_INTERNAL_SRAM_ICACHE_USAGE`** bits
and the D-Cache allocation SRAM blocks (9,10) are set by the **`PMS_INTERNAL_SRAM_DCACHE_USAGE`** bits, both in the register `PMC_INTERNAL_SRAM_USAGE_1_REG`*

### Tooling - esptool.py

The *esptool.py* is the essential tool used to manipulate the binaries for the ESP32 SoCs. Among the other features our focus is on the `--elf2image` command, which is used to convert the `.elf` images to the loadable `.bin` images. This tool is used to create the images loadable by the ROM loader.

Process of creation of the ***ESP image format*** compatible image:
```mermaid
flowchart LR
	A -->|linker| B
	B -->|post build| C
	C --> D
	A@{ shape: round, label: "**Build**</br>*(west build)*" }
	B@{ shape: round, label: "**.elf**</br>*(objcpy .bin discarded)*" }
	C@{ shape: round, label: "**esptool.py**</br>*--elf2image*" }
	D@{ shape: round, label: "**.bin**</br>*(ESP image format)*" }
```

Resulting binary can be loaded to any LMA location (in flash). Its segments will be processed at the location and SRAM will be copied to the corresponding SRAM location, and possible FLASH or SPIRAM segments will be mapped to the virtual address space VMA.

### Simpleboot

Single image builds are used as a default build option in the Zephyr RTOS and the CI, unless `--sysbuild` is used.

```shell
cd zephyrproject/zephyr
west build -b esp32s3_devkitm/esp32s3/procpu samples/net/wifi -p
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
I (98) boot: compile time Aug 23 2024 09:58:26
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


### MCUboot Zephyr RTOS port (ZP)

First lets take a look at how to manually build the MCUboot and the subsequent application. Each `west flash` in the code is using its own flash partition and it is not overwritten by each other. 

Building MCUboot separately at its location:
```shell
cd zephyrproject/bootloader/mcuboot
west build -b esp32s3_devkitm/esp32s3/procpu boot/zephyr -p
west flash && west espressif monitor
```

Building the sample application that is loadable by the MCUboot created in previous step:
```shell
cd zephyrproject/zephyr
west build -b esp32s3_devkitm/esp32s3/procpu samples/net/wifi -p -DCONFIG_BOOTLOADER_MCUBOOT=y
west flash && west espressif monitor
```

Now, we can rely on the Sysbuild and build all images at once.

Building the application with MCUboot(ZP) using sysbuild:
```shell
cd zephyrproject/zephyr
west build -b esp32s3_devkitm/esp32s3/procpu samples/new/wifi -p --sysbuild
west flash && west espressif monitor
```

In both cases (manual & sysbuild) we should see the following console output after the image boots:
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
I (98) boot: compile time Aug 23 2024 09:58:26
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

### MCUboot Espressif port (EP)

How-to build MCUboot Espressif port [article](https://docs.mcuboot.com/readme-espressif.html)

## Feature table

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


## Additional resources

- [Zephyr RTOS and ESP32](https://www.zephyrproject.org/zephyr-rtos-on-esp32/)
- [ESP32's memory map](https://developer.espressif.com/blog/esp32-memory-map-101/)
- [ESP32 Programmers memory model](https://developer.espressif.com/blog/esp32-programmers-memory-model/)
- [ESP32-S3 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf)
