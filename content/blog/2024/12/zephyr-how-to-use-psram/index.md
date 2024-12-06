---
title: "Enabling External PSRAM for Zephyr Applications on ESP32 SoCs"
date: 2024-12-04T00:00:00-00:00
showAuthor: false
authors:
  - "marcio-ribeiro"
tags: ["ESP32", "ESP32-S2", "ESP32-S3", "Zephyr", "PSRAM", "SPIRAM"]
---

Although ESP32 SoCs typically feature a few hundred kilobytes of internal SRAM, some embedded IoT applications—such as those featuring sophisticated graphical user interfaces, handling large data volumes, or performing complex data processing—may require much more RAM. To meet these demands, Espressif provides modules that feature external PSRAM.

In this article, you will learn how to configure Zephyr to enable your application take full advantage of the PSRAM available on ESP32 modules. We will explore three different strategies for utilizing this PSRAM: using it as a heap for dynamic memory allocation, integrating it as a section into the memory map, and moving code from FLASH to PSRAM.

## 1. Introduction

Before we start, let’s first understand exactly what PSRAM stands for and what it really is. The acronym PSRAM stands for pseudo-static random-access memory. It is a type of dynamic random-access memory (DRAM) that internally manages memory cell refresh, allowing it to function similarly to static random-access memory (SRAM) while retaining the cost and characteristics of DRAM. PSRAM is typically accessible via high-speed serial buses, and some ESP32 series SoCs can communicate with PSRAM and map its contents into the CPU's virtual memory space through a memory management unit (MMU).

In a simplified way, we can describe the relationship among PSRAM, the MMU, and the CPU as follows:

- Data is automatically copied from PSRAM to the data cache when the CPU attempts to access a memory position not currently in the cache.

- Conversely, when CPU modifies data in the cache, the updated contents are copied back to PSRAM.

As of the time of writing, although ESP32, ESP32-S2, ESP32-S3, ESP32-C61, and ESP32-P4 support external PSRAM, ESP32-C6 and ESP32-P4 are not currently supported on Zephyr yet.

## 2. ESP32 modules and PSRAM

To know which ESP32 modules contain PSRAM we have to undestand how modules part nummber are formed. Let’s use as an example the moduel whose part number is **ESP32-S3N8R8**

| Field           | Contents | Meaning             |
|:---------------:|:--------:|:-------------------:|
| SoC series      | ESP32-S3 | ESP32-S3 SoC series |
| FLASH size      | N8       | 8 MBytes FLASH      |
| PSRAM size [^1] | R8       | 8 MBytes PSRAM      |

 [^1]: If the module does not contain PSRAM, this field is absent

## 3. Custom hardware and PSRAM

Although Espressif offers modules featuring PSRAM across various ESP32 SoC series, there may be cases where creating custom hardware must be developed to meet specific requirements, such as PSRAM capacity or the SPI interface bus width, which impacts the time for each memory operation and overall data access speed. Additionally, there may be other reasons unrelated to PSRAM that necessitate custom hardware.

In this case must be observed PSRAM will share data I/O and clock lines with external FLASH memory, but not chip-select line. PSRAM and FLASH have separated chip select lines. For information related on how to connect off-package PSRAM lines, the respective SoC datasheet must be consulted.

The following SPI modes are supported to access external PSRAM memories:

 - Single SPI
 - Dual SPI
 - Quad SPI
 - QPI
 - Octo SPI
 - OPI

ESP32 can manage PSRAM of capacities up 32Mbytes depending on SoCs series.

Espressif currently offers some PSRAM models:

| Part number  | Memory Capacity | Operationg Voltage |
|:------------:|:---------------:|:------------------:|
| ESP-PSRAM32  | 4MByte          | 1.8V               |
| ESP-PSRAM32H | 4MByte          | 3.3V               |
| ESP-PSRAM64  | 8MByte          | 1.8V               |
| ESP-PSRAM64H | 8MByte          | 3.3V               |

## 4. Configuring PSRAM for use in Zephyr

The Kconfig parameters related to PSRAM usage in Zephyr can be found in [zephyr/soc/espressif/commom/Kconfig.spiram](https://github.com/zephyrproject-rtos/zephyr/blob/main/soc/espressif/common/Kconfig.spiram)

Below are the main parameters related to PSRAM, along with a brief description of each.

### 4.1. ESP_SPIRAM

This configuration parameter enables support for an external SPI RAM chip, connected in parallel with the main SPI flash chip. If enabled it automatically enables CONFIG_SHARED_MULTI_HEAP.

### 4.2. ESP_HEAP_SEARCH_ALL_REGIONS

This configuration parameter enables searching all available heap regions. If the region of desired capability is exhausted, memory will be allocated from other available region.

### 4.3. ESP_SPIRAM_HEAP_SIZE

This configuration parameter specifies SPIRAM heap size.

### 4.4. ESP_SPIRAM_MEMTEST

This configuration parameter controls SPIRAM memory test during initialization. It is enabled by default and can be disabled to permits a faster stasrtup.

### 4.5. SPIRAM_MODE

This configuration parameter selects the mode of SPI RAM chip in use. The permitted values are SPIRAM_MODE_QUAD and SPIRAM_MODE_OCT [^2].

[^2]: SPIRAM_MODE_OCT is available only in ESP32-S3

### 4.6. SPIRAM_TYPE

This configuration select the type of SPI RAM chip in use:

 - SPIRAM_TYPE_ESPPSRAM16 if your PSRAM capacity is 2MBytes
 - SPIRAM_TYPE_ESPPSRAM32 if your PSRAM capacity is 4MBytes
 - SPIRAM_TYPE_ESPPSRAM64 if your PSRAM capacity is 8MBytes

### 4.7. SPIRAM_SPEED

This configuration sets SPIRAM clock speed:
 - SPIRAM_SPEED_20M
 - SPIRAM_SPEED_26M
 - SPIRAM_SPEED_40M
 - SPIRAM_SPEED_80M
 - SPIRAM_SPEED_120M

### 4.8. SPIRAM_FETCH_INSTRUCTIONS

This configuration parameter allows miving Instructions from FLASH to PSRAM. If enabled, instructions in flash will be moved into PSRAM on startup. If SPIRAM_RODATA is also enabled, code that requires execution during an SPI1 flash operation can forgo being placed in IRAM, thus optimizing RAM usage. By default this parameter is disabled.

### 4.9. SPIRAM_RODATA

This configuration parameter allows moving read-only data from FLASH to PSRAM. If SPIRAM_FETCH_INSTRUCTIONS is also enabled, code that requires execution during an SPI1 flash operation  can forgo being placed in IRAM, thus optimizing RAM usage.

## 5. Installing Zephyr and its dependencies

To install Zephyr RTOS and the necessary tools, follow the instructions in the Zephyr [Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html). By the end of the process, you will have a command-line Zephyr development environment set up and ready to build your application with `west` tha is the meta-tool responsible for the build your application and flashing the generated binary, and other tasks.

Additionally, you need to execute the following command to prepare your environment for building applications for Espressif SoCs:

```sh
west blobs fetch hal_espressif
```
**West** is the meta-tool responsible for the build process in Zephyr.

## 6. Dynamically Allocating PSRAM Memory

PSRAM memory blocks can be made available to applications through Zephyr's shared multi-heap library.  The shared multi-heap memory pool manager uses the multi-heap allocator to manage a set of reserved memory regions with varying capabilities and attributes. For PSRAM, enabling the **ESP_SPIRAM** and **SHARED_MULTI_HEAP** configuration parameters causes the external PSRAM to be mapped into the data virtual memory space during Zephyr's early initialization stage. The shared multi-heap framework is initialized, and the PSRAM memory region is added to the pool.

When application needs a memory block allocated from PSRAM, it must call **shared_multi_heap_alloc()** whith **SMH_REG_ATTR_EXTERNAL** as a parameter. This function will return  an address pointing to a  memory block inside PSRAM. If an aligned memory block is required, **shared_multi_heap_aligned_alloc()** should be called instead.

With the ownership of this memory block the application is granted permission to read from and write to its addresses. Once the memory block is no longer needed, it can be returned to the pool from which it was allocated by calling `shared_multi_heap_free()` and passing the pointer to the block as parameter.

The following sample code shows how to use Zephyr's shared multi-heap API to allocate, use and free memory from PSRAM:

prj.conf:

```sh
CONFIG_LOG=y
CONFIG_ESP_SPIRAM=y
CONFIG_SHARED_MULTI_HEAP=y
CONFIG_SPIRAM_MODE_OCT=y
CONFIG_SPIRAM_TYPE_ESPPSRAM64=y
CONFIG_SPIRAM_SPEED_80M=y
CONFIG_ESP32S3_DATA_CACHE_64KB=y
CONFIG_ESP_SPIRAM_MEMTEST=y
```
main.c:

```c
#include <zephyr/kernel.h>
#include <soc/soc_memory_layout.h>
#include <zephyr/multi_heap/shared_multi_heap.h>
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(PSRAM_SAMPLE, LOG_LEVEL_INF);

int main(void)
{
	uint32_t *p_mem, k;

	LOG_INF("Sample started");

	p_mem = shared_multi_heap_aligned_alloc(SMH_REG_ATTR_EXTERNAL, 32, 1024*sizeof(uint32_t));

	if (p_mem == NULL) {
		LOG_ERR("PSRAM memory allocation failed!");
		return -ENOMEM;
	}

	for (k = 0; k < 1024; k++) {
		p_mem[k] = k;
	}

	for (k = 0; k < 1024; k++) {
		if (p_mem[k] != k) {
			LOG_ERR("p_mem[%"PRIu32"]: %"PRIu32" (expected value %"PRIu32")", k, p_mem[k], k);
			break;
		}
	}

	shared_multi_heap_free(p_mem);

	if (k < 1024) {
		LOG_ERR("Failed checking memory contents.");
		return -1;
	}

	LOG_INF("Sample finished successfully!");

	return 0;
}
```

To build a project containing these two files targeting a `ESP32-S3-DevKitC-1` board:

```sh
west build -b esp32s3_devkitc/esp32s3/procpu <project folder path> --pristine
```
This command will create a directory called `build`, which will contain the binary file of our sample along with other intermediate files produced during the building process

To flash the generated binary into the `ESP32-S3-DevKitC-1` board:

```sh
west flash
```

To open a console and see the log messages produced during the sample execution:

```sh
west espressif monitor
```
Here are the sample messages:

```sh
ESP-ROM:esp32s3-20210327
Build:Mar 27 2021
rst:0x1 (POWERON),boot:0x8 (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:2
load:0x3fc90530,len:0x227c
load:0x40374000,len:0xc510
SHA-256 comparison failed:
Calculated: f86c212b1724fcb97b17dbf917ed164707f67d52c2f4fffe151bd21081c9d03d
Expected: 0000000030180000000000000000000000000000000000000000000000000000
Attempting to boot anyway...
entry 0x40379b3c
I (79) soc_init: ESP Simple boot
I (79) soc_init: compile time Dec  4 2024 17:19:37
W (80) soc_init: Unicore bootloader
I (80) spi_flash: detected chip: gd
I (82) spi_flash: flash io: dio
W (85) spi_flash: Detected size(8192k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (97) soc_init: chip revision: v0.2
I (100) flash_init: Boot SPI Speed : 40MHz
I (104) flash_init: SPI Mode       : DIO
I (108) flash_init: SPI Flash Size : 8MB
I (111) soc_random: Enabling RNG early entropy source
I (116) boot: DRAM: lma 0x00000020 vma 0x3fc90530 len 0x227c   (8828)
I (122) boot: IRAM: lma 0x000022a4 vma 0x40374000 len 0xc510   (50448)
I (129) boot: padd: lma 0x0000e7c8 vma 0x00000000 len 0x1830   (6192)
I (135) boot: IMAP: lma 0x00010000 vma 0x42000000 len 0x4568   (17768)
I (141) boot: padd: lma 0x00014570 vma 0x00000000 len 0xba88   (47752)
I (147) boot: DMAP: lma 0x00020000 vma 0x3c010000 len 0x16d0   (5840)
I (153) boot: Image with 6 segments
I (157) boot: DROM segment: paddr=00020000h, vaddr=3c010000h, size=016D0h (  5840) map
I (164) boot: IROM segment: paddr=00010000h, vaddr=42000000h, size=04566h ( 17766) map
I (183) soc_random: Disabling RNG early entropy source
I (183) boot: Disabling glitch detection
I (183) boot: Jumping to the main image...
I (184) octal_psram: vendor id    : 0x0d (AP)
I (188) octal_psram: dev id       : 0x02 (generation 3)
I (193) octal_psram: density      : 0x03 (64 Mbit)
I (198) octal_psram: good-die     : 0x01 (Pass)
I (202) octal_psram: Latency      : 0x01 (Fixed)
I (206) octal_psram: VCC          : 0x01 (3V)
I (210) octal_psram: SRF          : 0x01 (Fast Refresh)
I (215) octal_psram: BurstType    : 0x01 (Hybrid Wrap)
I (220) octal_psram: BurstLen     : 0x01 (32 Byte)
I (225) octal_psram: Readlatency  : 0x02 (10 cycles@Fixed)
I (230) octal_psram: DriveStrength: 0x00 (1/1)
I (235) MSPI Timing: PSRAM timing tuning index: 6
I (239) esp_psram: Found 8MB PSRAM device
I (242) esp_psram: Speed: 80MHz
I (651) esp_psram: SPI SRAM memory test OK
I (708) heap_runtime: ESP heap runtime init at 0x3fcacae0 size 243 kB.

*** Booting Zephyr OS build v4.0.0-1471-ge60f04096cd8 ***
[00:00:00.708,000] <inf> PSRAM_SAMPLE: Sample started
[00:00:00.708,000] <inf> PSRAM_SAMPLE: Sample finished successfully!
```

Once the sample finishes executing successfully, we can conclude that the memory allocated from PSRAM was read and written without any issues.

## 7. Integrating PSRAM memory as a section into the memory map

Once **CONFIG_ESP_SPIRAM** is enabled there will be a section called **.ext_ram.bss** available to hold non initialized global variables that will be placed in PSRAM. To have sush variables placed in this section it is necessary add **__attribute__ ((section (".ext_ram.bss"))** before its declaration.

prj.conf:

```sh
CONFIG_LOG=y
CONFIG_ESP_SPIRAM=y
CONFIG_SPIRAM_MODE_OCT=y
CONFIG_SPIRAM_TYPE_ESPPSRAM64=y
CONFIG_SPIRAM_SPEED_80M=y
CONFIG_ESP32S3_DATA_CACHE_64KB=y
CONFIG_ESP_SPIRAM_MEMTEST=n
```
main.c:

```c
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(PSRAM_SAMPLE, LOG_LEVEL_INF);

#define PSRAM_TEST_VECTOR_LEN (512*1024)

__attribute__ ((section (".ext_ram.bss"))) uint8_t psram_vector[PSRAM_TEST_VECTOR_LEN];

int main(void)
{
	uint32_t k;

	LOG_INF("Sample started");

	LOG_DBG("Writing...");
	for (k = 0; k < PSRAM_TEST_VECTOR_LEN; k++) {
		psram_vector[k] = (uint8_t)k;
		LOG_DBG("psram_vector[%"PRIu32"]: %"PRIu8, k, psram_vector[k]);
	}

	LOG_DBG("Reading...");
	for (k = 0; k < PSRAM_TEST_VECTOR_LEN; k++) {
		if (psram_vector[k] != (uint8_t)k) {
			LOG_ERR("psram_vector[%"PRIu32"]: %"PRIu8" (expected value %"PRIu8")", k, psram_vector[k], (uint8_t)k);
			LOG_ERR("Verification failed!");
			return -1;
		}
	}

	LOG_INF("Sample finished successfully!");

	return 0;
}
```

To build a project containing these two files targeting a **ESP32-S3-DevKitC-1** board:

```sh
$ west build -b esp32s3_devkitc/esp32s3/procpu <project folder path> --pristine
```

This command will create a directory called **build**, which will contain the binary file of our sample along with other intermediate files produced during the building process

Before continue, let's take a look inside the `build/zephyr/zephyr.map` file:

```
...

10086 .ext_ram.bss    0x000000003c020000   0x100000
10087   	      0x000000003c020000		_ext_ram_bss_start = ABSOLUTE (.)
10088  *(SORT_BY_ALIGNMENT(.ext_ram.bss*))
10089  .ext_ram.bss   0x000000003c020000    0x80000 app/libapp.a(main.c.obj)
10090   	      0x000000003c020000		psram_vector
10091   	      0x000000003c0a0000		. = ALIGN (0x4)
10092   	      0x000000003c0a0000		_spiram_heap_start = ABSOLUTE (.)
10093   	      0x000000003c120000		. = ((. + 0x100000) - (_spiram_heap_start - _ext_ram_bss_start))
10094  *fill*	      0x000000003c0a0000    0x80000
10095   	      0x000000003c120000		. = ALIGN (0x4)
10096   	      0x000000003c120000		_ext_ram_bss_end = ABSOLUTE (.)

...
```

Here we can ovserve that first position of **psram_vector** is at addres **0x3c020000** which is inside the region mapping external PSRAM on ESP32-C3. Beyond that we can observe that although **CONFIG_SHARED_MULTI_HEAP** was not explicitaly enable, it was reserved area for spiram_head because **CONFIG_SHARED_MULTI_HEAP** is enabled by defaul once **CONFIG_ESP_SPIRAM** is enabled.

Now let's flash the binary onto the **ESP32-S3-DevKitC-1** board and observe the messages from the sample:

```sh
$ west flash
$ west espressif monitor
```

```sh
ESP-ROM:esp32s3-20210327
Build:Mar 27 2021
rst:0x1 (POWERON),boot:0x8 (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:2
load:0x3fc90520,len:0x227c
load:0x40374000,len:0xc500
SHA-256 comparison failed:
Calculated: 339e38ef89806c3327cd031629506600bfdbcee657c9337751c78707c3bcc339
Expected: 0000000040180000000000000000000000000000000000000000000000000000
Attempting to boot anyway...
entry 0x40379b2c
I (79) soc_init: ESP Simple boot
I (79) soc_init: compile time Dec  4 2024 17:35:34
W (80) soc_init: Unicore bootloader
I (80) spi_flash: detected chip: gd
I (82) spi_flash: flash io: dio
W (85) spi_flash: Detected size(8192k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (97) soc_init: chip revision: v0.2
I (100) flash_init: Boot SPI Speed : 40MHz
I (104) flash_init: SPI Mode       : DIO
I (108) flash_init: SPI Flash Size : 8MB
I (111) soc_random: Enabling RNG early entropy source
I (116) boot: DRAM: lma 0x00000020 vma 0x3fc90520 len 0x227c   (8828)
I (122) boot: IRAM: lma 0x000022a4 vma 0x40374000 len 0xc500   (50432)
I (129) boot: padd: lma 0x0000e7b8 vma 0x00000000 len 0x1840   (6208)
I (135) boot: IMAP: lma 0x00010000 vma 0x42000000 len 0x43ec   (17388)
I (141) boot: padd: lma 0x000143f4 vma 0x00000000 len 0xbc04   (48132)
I (147) boot: DMAP: lma 0x00020000 vma 0x3c010000 len 0x1690   (5776)
I (153) boot: Image with 6 segments
I (157) boot: DROM segment: paddr=00020000h, vaddr=3c010000h, size=01690h (  5776) map
I (164) boot: IROM segment: paddr=00010000h, vaddr=42000000h, size=043EAh ( 17386) map
I (183) soc_random: Disabling RNG early entropy source
I (183) boot: Disabling glitch detection
I (183) boot: Jumping to the main image...
I (184) octal_psram: vendor id    : 0x0d (AP)
I (188) octal_psram: dev id       : 0x02 (generation 3)
I (193) octal_psram: density      : 0x03 (64 Mbit)
I (198) octal_psram: good-die     : 0x01 (Pass)
I (202) octal_psram: Latency      : 0x01 (Fixed)
I (206) octal_psram: VCC          : 0x01 (3V)
I (210) octal_psram: SRF          : 0x01 (Fast Refresh)
I (215) octal_psram: BurstType    : 0x01 (Hybrid Wrap)
I (220) octal_psram: BurstLen     : 0x01 (32 Byte)
I (225) octal_psram: Readlatency  : 0x02 (10 cycles@Fixed)
I (230) octal_psram: DriveStrength: 0x00 (1/1)
I (235) MSPI Timing: PSRAM timing tuning index: 6
I (238) esp_psram: Found 8MB PSRAM device
I (242) esp_psram: Speed: 80MHz
I (301) heap_runtime: ESP heap runtime init at 0x3fcacad0 size 243 kB.

*** Booting Zephyr OS build v4.0.0-1471-ge60f04096cd8 ***
[00:00:00.301,000] <inf> PSRAM_SAMPLE: Sample started
[00:00:00.373,000] <inf> PSRAM_SAMPLE: Sample finished successfully!
```

Here, we can observe that the application now starts earlier compared to the previous sample. This improvement results from disabling the **CONFIG_ESP_SPIRAM_MEMTEST** parameter, which bypasses the PSRAM memory test that previously took a few hundred milliseconds.

## 8. Moving code from FLASH to PSRAM

Enabling **CONFIG_SPIRAM_FETCH_INSTRUCTIONS** will move instructions from FLASH to PSRAM during startup, and if **CONFIG_SPIRAM_RODATA** is also enabled, code that requires execution during an SPI1 Flash operation can forgo being placed in IRAM, thus optimizing RAM usage.

To check the effects of **CONFIG_SPIRAM_FETCH_INSTRUCTIONS** and **CONFIG_SPIRAM_RODATA** let's build **hello_world** first without enabling such parameters and then enable them.

### 8.1. Building hello_world without enable CONFIG_SPIRAM_FETCH_INSTRUCTIONS and CONFIG_SPIRAM_RODATA

```sh
west build -b esp32s3_devkitc/esp32s3/procpu zephyr/samples/hello_world/  --pristine
```

```sh
Memory region         Used Size  Region Size  %age Used
           FLASH:      135376 B    8388352 B      1.61%
     iram0_0_seg:       39056 B     343552 B     11.37%
     dram0_0_seg:       39072 B     327168 B     11.94%
     irom0_0_seg:       14642 B         8 MB      0.17%
     drom0_0_seg:       69840 B         8 MB      0.83%
    rtc_iram_seg:          0 GB         8 KB      0.00%
    rtc_data_seg:          0 GB         8 KB      0.00%
    rtc_slow_seg:          0 GB         8 KB      0.00%
        IDT_LIST:          0 GB         8 KB      0.00%
```

```sh
ESP-ROM:esp32s3-20210327
Build:Mar 27 2021
rst:0x1 (POWERON),boot:0xa (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:2
load:0x3fc8d8a0,len:0x176c
load:0x40374000,len:0x9880
SHA-256 comparison failed:
Calculated: 695635a387a5684addee1fafb971b13abbd4e67842bcf1cd46cd6df6e2ad5250
Expected: 00000000d04f0000000000000000000000000000000000000000000000000000
Attempting to boot anyway...
entry 0x40377bd0
I (67) soc_init: ESP Simple boot
I (68) soc_init: compile time Dec  4 2024 19:25:19
W (68) soc_init: Unicore bootloader
I (68) spi_flash: detected chip: gd
I (70) spi_flash: flash io: dio
W (73) spi_flash: Detected size(8192k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (85) soc_init: chip revision: v0.2
I (88) flash_init: Boot SPI Speed : 40MHz
I (92) flash_init: SPI Mode       : DIO
I (96) flash_init: SPI Flash Size : 8MB
I (99) soc_random: Enabling RNG early entropy source
I (104) boot: DRAM: lma 0x00000020 vma 0x3fc8d8a0 len 0x176c   (5996)
I (110) boot: IRAM: lma 0x00001794 vma 0x40374000 len 0x9880   (39040)
I (116) boot: padd: lma 0x0000b028 vma 0x00000000 len 0x4fd0   (20432)
I (123) boot: IMAP: lma 0x00010000 vma 0x42000000 len 0x3934   (14644)
I (129) boot: padd: lma 0x0001393c vma 0x00000000 len 0xc6bc   (50876)
I (135) boot: DMAP: lma 0x00020000 vma 0x3c010000 len 0x10d0   (4304)
I (141) boot: Image with 6 segments
I (144) boot: DROM segment: paddr=00020000h, vaddr=3c010000h, size=010D0h (  4304) map
I (152) boot: IROM segment: paddr=00010000h, vaddr=42000000h, size=03932h ( 14642) map
I (171) soc_random: Disabling RNG early entropy source
I (171) boot: Disabling glitch detection
I (171) boot: Jumping to the main image...
I (208) heap_runtime: ESP heap runtime init at 0x3fc918a0 size 351 kB.

*** Booting Zephyr OS build v4.0.0-1471-ge60f04096cd8 ***
Hello World! esp32s3_devkitc/esp32s3/procpu
```

### 8.2. Building hello_world enabling CONFIG_SPIRAM_FETCH_INSTRUCTIONS and CONFIG_SPIRAM_RODATA

```sh
west build -b esp32s3_devkitc/esp32s3/procpu zephyr/samples/hello_world/ -DCONFIG_ESP_SPIRAM=y -DCONFIG_SPIRAM_TYPE_ESPPSRAM64=y -DCONFIG_SPIRAM_MODE_OCT=y -DCONFIG_SPIRAM_SPEED_80M=y -DCONFIG_ESP32S3_DATA_CACHE_64KB=y -DCONFIG_ESP_SPIRAM_MEMTEST=y -DCONFIG_SPIRAM_FETCH_INSTRUCTIONS=y -DCONFIG_SPIRAM_RODATA=y --pristine
```

```sh
Memory region         Used Size  Region Size  %age Used
           FLASH:      135916 B    8388352 B      1.62%
     iram0_0_seg:       43384 B     343552 B     12.63%
     dram0_0_seg:       45104 B     327168 B     13.79%
     irom0_0_seg:       15942 B         8 MB      0.19%
     drom0_0_seg:       70380 B         8 MB      0.84%
     ext_ram_seg:       1152 KB    8388544 B     14.06%
    rtc_iram_seg:          0 GB         8 KB      0.00%
    rtc_data_seg:          0 GB         8 KB      0.00%
    rtc_slow_seg:          0 GB         8 KB      0.00%
        IDT_LIST:          0 GB         8 KB      0.00%
```

```sh
ESP-ROM:esp32s3-20210327
Build:Mar 27 2021
rst:0x1 (POWERON),boot:0x8 (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:2
load:0x3fc8e988,len:0x1c2c
load:0x40374000,len:0xa968
SHA-256 comparison failed:
Calculated: 8196087d6087abb51d92ad226e9d134e19497a3447ffb32faca13f70679ea728
Expected: 00000000303a0000000000000000000000000000000000000000000000000000
Attempting to boot anyway...
entry 0x40377dcc
I (72) soc_init: ESP Simple boot
I (72) soc_init: compile time Dec  4 2024 19:32:57
W (72) soc_init: Unicore bootloader
I (72) spi_flash: detected chip: gd
I (75) spi_flash: flash io: dio
W (78) spi_flash: Detected size(8192k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (90) soc_init: chip revision: v0.2
I (93) flash_init: Boot SPI Speed : 40MHz
I (97) flash_init: SPI Mode       : DIO
I (100) flash_init: SPI Flash Size : 8MB
I (104) soc_random: Enabling RNG early entropy source
I (109) boot: DRAM: lma 0x00000020 vma 0x3fc8e988 len 0x1c2c   (7212)
I (115) boot: IRAM: lma 0x00001c54 vma 0x40374000 len 0xa968   (43368)
I (121) boot: padd: lma 0x0000c5c8 vma 0x00000000 len 0x3a30   (14896)
I (127) boot: IMAP: lma 0x00010000 vma 0x42000000 len 0x3e48   (15944)
I (134) boot: padd: lma 0x00013e50 vma 0x00000000 len 0xc1a8   (49576)
I (140) boot: DMAP: lma 0x00020000 vma 0x3c010000 len 0x12ec   (4844)
I (146) boot: Image with 6 segments
I (149) boot: DROM segment: paddr=00020000h, vaddr=3c010000h, size=012F0h (  4848) map
I (157) boot: IROM segment: paddr=00010000h, vaddr=42000000h, size=03E46h ( 15942) map
I (176) soc_random: Disabling RNG early entropy source
I (176) boot: Disabling glitch detection
I (176) boot: Jumping to the main image...
I (177) octal_psram: vendor id    : 0x0d (AP)
I (181) octal_psram: dev id       : 0x02 (generation 3)
I (186) octal_psram: density      : 0x03 (64 Mbit)
I (190) octal_psram: good-die     : 0x01 (Pass)
I (195) octal_psram: Latency      : 0x01 (Fixed)
I (199) octal_psram: VCC          : 0x01 (3V)
I (203) octal_psram: SRF          : 0x01 (Fast Refresh)
I (208) octal_psram: BurstType    : 0x01 (Hybrid Wrap)
I (213) octal_psram: BurstLen     : 0x01 (32 Byte)
I (217) octal_psram: Readlatency  : 0x02 (10 cycles@Fixed)
I (223) octal_psram: DriveStrength: 0x00 (1/1)
I (227) MSPI Timing: PSRAM timing tuning index: 6
I (231) esp_psram: Found 8MB PSRAM device
I (235) esp_psram: Speed: 80MHz
I (245) mmu_psram: Instructions copied and mapped to SPIRAM
I (252) mmu_psram: Read only data copied and mapped to SPIRAM
I (652) esp_psram: SPI SRAM memory test OK
I (708) heap_runtime: ESP heap runtime init at 0x3fc93030 size 345 kB.

*** Booting Zephyr OS build v4.0.0-1471-ge60f04096cd8 ***
Hello World! esp32s3_devkitc/esp32s3/procpu

```

Here, we can confirm that instructions and read-only data were copied and mapped to PSRAM, which can optimize RAM usage when there is code that needs to execute during an SPI1 Flash operation.

## 9. Conclusion

Throughout this article, we explored three different strategies for utilizing PSRAM: using it as a heap for dynamic memory allocation, integrating it as a section in the memory map, and moving code from FLASH to PSRAM. In addition to these three strategies, it is also possible to leverage PSRAM to execute external code compiled as Position Independent Code (PIC), which can be placed in PSRAM by a loader for execution. Another potential use of PSRAM to reduce SRAM usage is by enabling **CONFIG_ESP32_WIFI_NET_ALLOC_SPIRAM**, allowing the ESP32 Wi-Fi stack to dynamically allocate memory from PSRAM. However, as of the time of writing, there is an unfixed bug preventing applications built with **CONFIG_ESP32_WIFI_NET_ALLOC_SPIRAM** from functioning properly.

## 10. References

 - [Espressif Official Site](https://www.espressif.com/en)

    - [Zephyr on ESP Devices](https://www.espressif.com/en/sdks/esp-zephyr)

    - [SPI Flash and External SPI RAM Configuration](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/api-guides/flash_psram_config.html)

    - Support for External RAM

      - [ESP32](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/external-ram.html)

      - [ESP32-S2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s2/api-guides/external-ram.html)

      - [ESP32-S3](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/api-guides/external-ram.html)

      - [ESP32-P4](https://docs.espressif.com/projects/esp-idf/en/latest/esp32p4/api-guides/external-ram.html)

 - [Zephyr Project Official Site](https://www.zephyrproject.org)

 - [Zephyr Project Documentation Site](https://docs.zephyrproject.org/latest/index.html)

   - [Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html)

   - Supported Boards and Shields

     - [Espressif](https://docs.zephyrproject.org/latest/boards/espressif/index.html)

       - [ESP32-DevKitC-WROVER](https://docs.zephyrproject.org/latest/boards/espressif/esp32_devkitc_wrover/doc/index.html)

       - [ESP32-S2-DevKitC](https://docs.zephyrproject.org/latest/boards/espressif/esp32s2_devkitc/doc/index.html)

       - [ESP32-S3-DevKitC-1](https://docs.zephyrproject.org/latest/boards/espressif/esp32s3_devkitc/doc/index.html)

   - [Shared Multi Heap](https://docs.zephyrproject.org/latest/kernel/memory_management/shared_multi_heap.html)

   - [Code And Data Relocation](https://docs.zephyrproject.org/latest/kernel/code-relocation.html)
