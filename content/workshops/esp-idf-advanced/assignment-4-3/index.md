---
title: "ESP-IDF Adv. - Assign.  4.3"
date: "2025-08-05"
series: ["WS00B"]
series_order: 16
showAuthor: false
---

In this assignment, we will enable flash encryption.

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Enabling flash encryption (and secure bootloader) is an irreversible operation. Double check before doing any step.
{{< /alert >}}


## Assignment steps

In this assignment, we will:

1. Check your device encryption status
2. Enable flash encryption (development mode)
3. Set partition table
3. Check the encryption status again

### Check your device encryption status

* Open an ESP-IDF terminal : `> ESP-IDF: Open ESP-IDF Terminal`
* Inside the terminal, run `idf.py efuse-summary`

Now check the relevant eFuses listed in the table below. They must all be at their default zero state.

| **eFuse**                    | **Description**                                                                                                                                             |
|-----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `BLOCK_KEYN`                | AES key storage. N is between 0 and 5.                                                                                                                       |
| `KEY_PURPOSE_N`             | Control the purpose of eFuse block `BLOCK_KEYN`, where N is between 0 and 5.         |
| `DIS_DOWNLOAD_MANUAL_ENCRYPT` | Disables flash encryption when in download boot modes.                                                                                             |
| `SPI_BOOT_CRYPT_CNT`        | Enables encryption and decryption when an SPI boot mode is set. Feature is enabled if 1 or 3 bits are set in the eFuse.                  |


<details>
<summary>Show the eFuse blocks</summary>

```bash
EFUSE_NAME (Block) Description  = [Meaningful Value] [Readable/Writeable] (Hex Value)
----------------------------------------------------------------------------------------
Calibration fuses:
K_RTC_LDO (BLOCK1)                                 BLOCK1 K_RTC_LDO                                   = 96 R/W (0b0011000)
K_DIG_LDO (BLOCK1)                                 BLOCK1 K_DIG_LDO                                   = 20 R/W (0b0000101)
V_RTC_DBIAS20 (BLOCK1)                             BLOCK1 voltage of rtc dbias20                      = 172 R/W (0x2b)
V_DIG_DBIAS20 (BLOCK1)                             BLOCK1 voltage of digital dbias20                  = 32 R/W (0x08)
DIG_DBIAS_HVT (BLOCK1)                             BLOCK1 digital dbias when hvt                      = -12 R/W (0b10011)
THRES_HVT (BLOCK1)                                 BLOCK1 pvt threshold when hvt                      = 1600 R/W (0b0110010000)
TEMP_CALIB (BLOCK2)                                Temperature calibration data                       = -9.0 R/W (0b101011010)
OCODE (BLOCK2)                                     ADC OCode                                          = 96 R/W (0x60)
ADC1_INIT_CODE_ATTEN0 (BLOCK2)                     ADC1 init code at atten0                           = 1736 R/W (0b0110110010)
ADC1_INIT_CODE_ATTEN1 (BLOCK2)                     ADC1 init code at atten1                           = -272 R/W (0b1001000100)
ADC1_INIT_CODE_ATTEN2 (BLOCK2)                     ADC1 init code at atten2                           = -368 R/W (0b1001011100)
ADC1_INIT_CODE_ATTEN3 (BLOCK2)                     ADC1 init code at atten3                           = -824 R/W (0b1011001110)
ADC1_CAL_VOL_ATTEN0 (BLOCK2)                       ADC1 calibration voltage at atten0                 = -204 R/W (0b1000110011)
ADC1_CAL_VOL_ATTEN1 (BLOCK2)                       ADC1 calibration voltage at atten1                 = -4 R/W (0b1000000001)
ADC1_CAL_VOL_ATTEN2 (BLOCK2)                       ADC1 calibration voltage at atten2                 = -160 R/W (0b1000101000)
ADC1_CAL_VOL_ATTEN3 (BLOCK2)                       ADC1 calibration voltage at atten3                 = -332 R/W (0b1001010011)

Config fuses:
WR_DIS (BLOCK0)                                    Disable programming of individual eFuses           = 0 R/W (0x00000000)
RD_DIS (BLOCK0)                                    Disable reading from BlOCK4-10                     = 0 R/W (0b0000000)
DIS_ICACHE (BLOCK0)                                Set this bit to disable Icache                     = False R/W (0b0)
DIS_TWAI (BLOCK0)                                  Set this bit to disable CAN function               = False R/W (0b0)
DIS_DIRECT_BOOT (BLOCK0)                           Disable direct boot mode                           = False R/W (0b0)
UART_PRINT_CONTROL (BLOCK0)                        Set the default UARTboot message output mode
   = Enable when GPIO8 is high at reset R/W (0b10)
ERR_RST_ENABLE (BLOCK0)                            Use BLOCK0 to check error record registers         = without check R/W (0b0)
BLOCK_USR_DATA (BLOCK3)                            User data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_SYS_DATA2 (BLOCK10)                          System data part 2 (reserved)
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W

Flash fuses:
FLASH_TPUW (BLOCK0)                                Configures flash waiting time after power-up; in u = 0 R/W (0x0)
                                                   nit of ms. If the value is less than 15; the waiti
                                                   ng time is the configurable value; Otherwise; the
                                                   waiting time is twice the configurable value
FORCE_SEND_RESUME (BLOCK0)                         Set this bit to force ROM code to send a resume co = False R/W (0b0)
                                                   mmand during SPI boot
FLASH_CAP (BLOCK1)                                 Flash capacity                                     = 4M R/W (0b001)
FLASH_TEMP (BLOCK1)                                Flash temperature                                  = 105C R/W (0b01)
FLASH_VENDOR (BLOCK1)                              Flash vendor                                       = XMC R/W (0b001)

Identity fuses:
DISABLE_WAFER_VERSION_MAJOR (BLOCK0)               Disables check of wafer version major              = False R/W (0b0)
DISABLE_BLK_VERSION_MAJOR (BLOCK0)                 Disables check of blk version major                = False R/W (0b0)
WAFER_VERSION_MINOR_LO (BLOCK1)                    WAFER_VERSION_MINOR least significant bits         = 3 R/W (0b011)
PKG_VERSION (BLOCK1)                               Package version                                    = 0 R/W (0b000)
BLK_VERSION_MINOR (BLOCK1)                         BLK_VERSION_MINOR                                  = 1 R/W (0b001)
WAFER_VERSION_MINOR_HI (BLOCK1)                    WAFER_VERSION_MINOR most significant bit           = False R/W (0b0)
WAFER_VERSION_MAJOR (BLOCK1)                       WAFER_VERSION_MAJOR                                = 0 R/W (0b00)
OPTIONAL_UNIQUE_ID (BLOCK2)                        Optional unique 128-bit ID
   = 7c c7 9b 3a 4c 1f e1 be 56 79 19 20 4f ff cd 0e R/W
BLK_VERSION_MAJOR (BLOCK2)                         BLK_VERSION_MAJOR of BLOCK2                        = With calibration R/W (0b01)
WAFER_VERSION_MINOR (BLOCK0)                       calc WAFER VERSION MINOR = WAFER_VERSION_MINOR_HI  = 3 R/W (0x3)
                                                   << 3 + WAFER_VERSION_MINOR_LO (read only)

Jtag fuses:
SOFT_DIS_JTAG (BLOCK0)                             Set these bits to disable JTAG in the soft way (od = 0 R/W (0b000)
                                                   d number 1 means disable ). JTAG can be enabled in
                                                    HMAC module
DIS_PAD_JTAG (BLOCK0)                              Set this bit to disable JTAG in the hard way. JTAG = False R/W (0b0)
                                                    is disabled permanently

Mac fuses:
MAC (BLOCK1)                                       MAC address
   = 84:f7:03:42:8c:a8 (OK) R/W
CUSTOM_MAC (BLOCK3)                                Custom MAC address
   = 00:00:00:00:00:00 (OK) R/W

Security fuses:
DIS_DOWNLOAD_ICACHE (BLOCK0)                       Set this bit to disable Icache in download mode (b = False R/W (0b0)
                                                   oot_mode[3:0] is 0; 1; 2; 3; 6; 7)
DIS_FORCE_DOWNLOAD (BLOCK0)                        Set this bit to disable the function that forces c = False R/W (0b0)
                                                   hip into download mode
DIS_DOWNLOAD_MANUAL_ENCRYPT (BLOCK0)               Set this bit to disable flash encryption when in d = False R/W (0b0)
                                                   ownload boot modes
SPI_BOOT_CRYPT_CNT (BLOCK0)                        Enables flash encryption when 1 or 3 bits are set  = Disable R/W (0b000)
                                                   and disables otherwise
SECURE_BOOT_KEY_REVOKE0 (BLOCK0)                   Revoke 1st secure boot key                         = False R/W (0b0)
SECURE_BOOT_KEY_REVOKE1 (BLOCK0)                   Revoke 2nd secure boot key                         = False R/W (0b0)
SECURE_BOOT_KEY_REVOKE2 (BLOCK0)                   Revoke 3rd secure boot key                         = False R/W (0b0)
KEY_PURPOSE_0 (BLOCK0)                             Purpose of Key0                                    = USER R/W (0x0)
KEY_PURPOSE_1 (BLOCK0)                             Purpose of Key1                                    = USER R/W (0x0)
KEY_PURPOSE_2 (BLOCK0)                             Purpose of Key2                                    = USER R/W (0x0)
KEY_PURPOSE_3 (BLOCK0)                             Purpose of Key3                                    = USER R/W (0x0)
KEY_PURPOSE_4 (BLOCK0)                             Purpose of Key4                                    = USER R/W (0x0)
KEY_PURPOSE_5 (BLOCK0)                             Purpose of Key5                                    = USER R/W (0x0)
SECURE_BOOT_EN (BLOCK0)                            Set this bit to enable secure boot                 = False R/W (0b0)
SECURE_BOOT_AGGRESSIVE_REVOKE (BLOCK0)             Set this bit to enable revoking aggressive secure  = False R/W (0b0)
                                                   boot
DIS_DOWNLOAD_MODE (BLOCK0)                         Set this bit to disable download mode (boot_mode[3 = False R/W (0b0)
                                                   :0] = 0; 1; 2; 3; 6; 7)
ENABLE_SECURITY_DOWNLOAD (BLOCK0)                  Set this bit to enable secure UART download mode   = False R/W (0b0)
SECURE_VERSION (BLOCK0)                            Secure version (used by ESP-IDF anti-rollback feat = 0 R/W (0x0000)
                                                   ure)
BLOCK_KEY0 (BLOCK4)
  Purpose: USER
               Key0 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_KEY1 (BLOCK5)
  Purpose: USER
               Key1 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_KEY2 (BLOCK6)
  Purpose: USER
               Key2 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_KEY3 (BLOCK7)
  Purpose: USER
               Key3 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_KEY4 (BLOCK8)
  Purpose: USER
               Key4 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_KEY5 (BLOCK9)
  Purpose: USER
               Key5 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W

Spi Pad fuses:
SPI_PAD_CONFIG_CLK (BLOCK1)                        SPI PAD CLK                                        = 0 R/W (0b000000)
SPI_PAD_CONFIG_Q (BLOCK1)                          SPI PAD Q(D1)                                      = 0 R/W (0b000000)
SPI_PAD_CONFIG_D (BLOCK1)                          SPI PAD D(D0)                                      = 0 R/W (0b000000)
SPI_PAD_CONFIG_CS (BLOCK1)                         SPI PAD CS                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_HD (BLOCK1)                         SPI PAD HD(D3)                                     = 0 R/W (0b000000)
SPI_PAD_CONFIG_WP (BLOCK1)                         SPI PAD WP(D2)                                     = 0 R/W (0b000000)
SPI_PAD_CONFIG_DQS (BLOCK1)                        SPI PAD DQS                                        = 0 R/W (0b000000)
SPI_PAD_CONFIG_D4 (BLOCK1)                         SPI PAD D4                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_D5 (BLOCK1)                         SPI PAD D5                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_D6 (BLOCK1)                         SPI PAD D6                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_D7 (BLOCK1)                         SPI PAD D7                                         = 0 R/W (0b000000)

Usb fuses:
DIS_USB_JTAG (BLOCK0)                              Set this bit to disable function of usb switch to  = False R/W (0b0)
                                                   jtag in module of usb device
DIS_USB_SERIAL_JTAG (BLOCK0)                       USB-Serial-JTAG                                    = Enable R/W (0b0)
USB_EXCHG_PINS (BLOCK0)                            Set this bit to exchange USB D+ and D- pins        = False R/W (0b0)
DIS_USB_SERIAL_JTAG_ROM_PRINT (BLOCK0)             USB printing                                       = Enable R/W (0b0)
DIS_USB_SERIAL_JTAG_DOWNLOAD_MODE (BLOCK0)         Disable UART download mode through USB-Serial-JTAG = False R/W (0b0)

Vdd fuses:
VDD_SPI_AS_GPIO (BLOCK0)                           Set this bit to vdd spi pin function as gpio       = False R/W (0b0)

Wdt fuses:
WDT_DELAY_SEL (BLOCK0)                             RTC watchdog timeout threshold; in unit of slow cl = 40000 R/W (0b00)
                                                   ock cycle
```
</details>


### Enable encryption

* Open menuconfig: `> ESP-IDF: SDK Configuration Editor (menuconfig)`<br>
   &rarr; `Security Features` &rarr; `Enable flash encryption on boot (READ DOCS FIRST)`

* Make sure you have: `Enable usage mode` &rarr; `Development (Not secure)`

Your configuration should ressemble this:

{{< figure
default=true
src="../assets/assignment_4_2_flash_encryption.webp"
height=500
caption="Flash encryption options"
    >}}


We will also increase the bootloader verbosity to see what happens

* Open menuconfig: `> ESP-IDF: SDK Configuration Editor (menuconfig)`<br>
   &rarr; `Bootloader log verbosity` &rarr; `verbose`

### Set partition table

If you'd try to flash the project, you will get an error.
<details>
<summary>Show error</summary>

```bash
Successfully created esp32c3 image.
Generated <PROJECT_ROOT>/build/bootloader/bootloader.bin
[103/103] cd <PROJECT_ROOT>/build/bootloader/esp-idf/esptool_py && <PYTHON_ENV_PATH>/bin/python <ESP_IDF_PATH>/components/partition_table/check_sizes.py --offset 0x8000 bootloader 0x0 <PROJECT_ROOT>/build/bootloader/bootloader.bin
FAILED: esp-idf/esptool_py/CMakeFiles/bootloader_check_size <PROJECT_ROOT>/build/bootloader/esp-idf/esptool_py/CMakeFiles/bootloader_check_size
cd <PROJECT_ROOT>/build/bootloader/esp-idf/esptool_py && <PYTHON_ENV_PATH>/bin/python <ESP_IDF_PATH>/components/partition_table/check_sizes.py --offset 0x8000 bootloader 0x0 <PROJECT_ROOT>/build/bootloader/bootloader.bin
Error: Bootloader binary size 0x91f0 bytes is too large for partition table offset 0x8000. Bootloader binary can be maximum 0x8000 (32768) bytes unless the partition table offset is increased in the Partition Table section of the project configuration menu.
ninja: build stopped: subcommand failed.
[972/978] Generating ld/sections.ld
ninja: build stopped: subcommand failed.
```
</details>

The reason is that the bootloader now takes more space and does not fit in the space of the standard partition table offset (0x8000). We need to change it to `0xf000` before moving on.

* Open menuconfig: `> ESP-IDF: SDK Configuration Editor (menuconfig)`<br>
   &rarr; `Offset of partition table` &rarr; `0xf000`

Now you can build and flash again and you will get:

```bash
[Flash Encryption]
WARNING: Flash Encryption in Development Mode

This will burn eFuses on your device which is an IRREVERSIBLE operation.

In Development Mode:
Development Mode: Allows re-flashing with plaintext data

The flash encryption process requires two steps:
1. First, you need to confirm by typing "BURN DEV" in the input box at the top of the screen
2. After flashing completes, you MUST reset your device
3. Then flash again to enable encryption
```

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
The flashing logs will be different than usual this time, informing us about the flashing encryption process.
{{< /alert >}}
<details>
<summary>Show flashing logs</summary>

```bash
D (122) boot: type=1 subtype=2
I (125) boot:  0 nvs              WiFi data        01 02 00010000 00004000
D (132) boot: load partition table entry 0x3c00f020
D (136) boot: type=1 subtype=0
I (139) boot:  1 otadata          OTA data         01 00 00014000 00002000
D (146) boot: load partition table entry 0x3c00f040
D (150) boot: type=1 subtype=1
I (153) boot:  2 phy_init         RF data          01 01 00016000 00001000
D (160) boot: load partition table entry 0x3c00f060
D (164) boot: type=0 subtype=0
I (167) boot:  3 factory          factory app      00 00 00020000 00100000
D (174) boot: load partition table entry 0x3c00f080
D (178) boot: type=0 subtype=10
I (181) boot:  4 ota_0            OTA app          00 10 00120000 00100000
D (188) boot: load partition table entry 0x3c00f0a0
D (192) boot: type=0 subtype=11
I (195) boot:  5 ota_1            OTA app          00 11 00220000 00100000
I (202) boot: End of partition table
D (205) boot: OTA data offset 0x14000
D (208) bootloader_flash: rodata starts from paddr=0x00014000, size=0x2000, will be mapped to vaddr=0x3c000000
V (218) bootloader_flash: after mapping, starting from paddr=0x00010000 and vaddr=0x3c000000, 0x10000 bytes are mapped
D (229) boot: otadata[0]: sequence values 0xffffffff
D (233) boot: otadata[1]: sequence values 0xffffffff
D (238) boot: OTA sequence numbers both empty (all-0xFF) or partition table does not have bootable ota_apps (app_count=2)
I (249) boot: Defaulting to factory image
D (252) boot: Trying partition index -1 offs 0x20000 size 0x100000
D (258) esp_image: reading image header @ 0x20000
D (263) bootloader_flash: mmu set block paddr=0x00020000 (was 0xffffffff)
D (269) esp_image: image header: 0xe9 0x06 0x02 0x02 403802ea
V (275) esp_image: loading segment header 0 at offset 0x20018
V (280) esp_image: segment data length 0x1fd24 data starts 0x20020
V (286) esp_image: MMU page size 0x10000
V (290) esp_image: segment 0 map_segment 1 segment_data_offs 0x20020 load_addr 0x3c0c0020
I (297) esp_image: segment 0: paddr=00020020 vaddr=3c0c0020 size=1fd24h (130340) map
D (305) esp_image: free data page_count 0x00000080
D (309) bootloader_flash: rodata starts from paddr=0x00020020, size=0x1fd24, will be mapped to vaddr=0x3c000000
V (319) bootloader_flash: after mapping, starting from paddr=0x00020000 and vaddr=0x3c000000, 0x20000 bytes are mapped
V (351) esp_image: loading segment header 1 at offset 0x3fd44
D (351) bootloader_flash: mmu set block paddr=0x00030000 (was 0xffffffff)
V (351) esp_image: segment data length 0x2cc data starts 0x3fd4c
V (357) esp_image: MMU page size 0x10000
V (361) esp_image: segment 1 map_segment 0 segment_data_offs 0x3fd4c load_addr 0x3fc93e00
I (369) esp_image: segment 1: paddr=0003fd4c vaddr=3fc93e00 size=002cch (   716) load
D (376) esp_image: free data page_count 0x00000080
D (381) bootloader_flash: rodata starts from paddr=0x0003fd4c, size=0x2cc, will be mapped to vaddr=0x3c000000
V (390) bootloader_flash: after mapping, starting from paddr=0x00030000 and vaddr=0x3c000000, 0x20000 bytes are mapped
V (401) esp_image: loading segment header 2 at offset 0x40018
D (406) bootloader_flash: mmu set block paddr=0x00040000 (was 0xffffffff)
V (413) esp_image: segment data length 0xb4b94 data starts 0x40020
V (419) esp_image: MMU page size 0x10000
V (422) esp_image: segment 2 map_segment 1 segment_data_offs 0x40020 load_addr 0x42000020
--- 0x42000020: esp_app_format_init_elf_sha256 at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_app_format/esp_app_desc.c:88

I (430) esp_image: segment 2: paddr=00040020 vaddr=42000020 size=b4b94h (740244) map
D (438) esp_image: free data page_count 0x00000080
D (442) bootloader_flash: rodata starts from paddr=0x00040020, size=0xb4b94, will be mapped to vaddr=0x3c000000
V (452) bootloader_flash: after mapping, starting from paddr=0x00040000 and vaddr=0x3c000000, 0xc0000 bytes are mapped
V (580) esp_image: loading segment header 3 at offset 0xf4bb4
D (580) bootloader_flash: mmu set block paddr=0x000f0000 (was 0xffffffff)
V (581) esp_image: segment data length 0x2c24 data starts 0xf4bbc
V (587) esp_image: MMU page size 0x10000
V (591) esp_image: segment 3 map_segment 0 segment_data_offs 0xf4bbc load_addr 0x3fc940cc
I (598) esp_image: segment 3: paddr=000f4bbc vaddr=3fc940cc size=02c24h ( 11300) load
D (606) esp_image: free data page_count 0x00000080
D (610) bootloader_flash: rodata starts from paddr=0x000f4bbc, size=0x2c24, will be mapped to vaddr=0x3c000000
V (620) bootloader_flash: after mapping, starting from paddr=0x000f0000 and vaddr=0x3c000000, 0x10000 bytes are mapped
V (633) esp_image: loading segment header 4 at offset 0xf77e0
D (636) bootloader_flash: mmu set block paddr=0x000f0000 (was 0xffffffff)
V (643) esp_image: segment data length 0x13cc8 data starts 0xf77e8
V (649) esp_image: MMU page size 0x10000
V (652) esp_image: segment 4 map_segment 0 segment_data_offs 0xf77e8 load_addr 0x40380000
--- 0x40380000: _vector_table at /Users/francesco/esp/v5.4.2/esp-idf/components/riscv/vectors_intc.S:54

I (660) esp_image: segment 4: paddr=000f77e8 vaddr=40380000 size=13cc8h ( 81096) load
D (668) esp_image: free data page_count 0x00000080
D (672) bootloader_flash: rodata starts from paddr=0x000f77e8, size=0x13cc8, will be mapped to vaddr=0x3c000000
V (682) bootloader_flash: after mapping, starting from paddr=0x000f0000 and vaddr=0x3c000000, 0x20000 bytes are mapped
V (708) esp_image: loading segment header 5 at offset 0x10b4b0
D (708) bootloader_flash: mmu set block paddr=0x00100000 (was 0xffffffff)
V (709) esp_image: segment data length 0x1c data starts 0x10b4b8
V (714) esp_image: MMU page size 0x10000
V (718) esp_image: segment 5 map_segment 0 segment_data_offs 0x10b4b8 load_addr 0x50000000
I (726) esp_image: segment 5: paddr=0010b4b8 vaddr=50000000 size=0001ch (    28) load
D (734) esp_image: free data page_count 0x00000080
D (738) bootloader_flash: rodata starts from paddr=0x0010b4b8, size=0x1c, will be mapped to vaddr=0x3c000000
V (748) bootloader_flash: after mapping, starting from paddr=0x00100000 and vaddr=0x3c000000, 0x10000 bytes are mapped
V (758) esp_image: image start 0x00020000 end of last section 0x0010b4d4
D (764) bootloader_flash: mmu set block paddr=0x00100000 (was 0xffffffff)
D (771) boot: Calculated hash: 95320d19f00e1b0ae9da94d51f205ea7a1731fc9a3252e2a61a665c109798d46
I (785) boot: Loaded app from partition at offset 0x20000
I (785) boot: Checking flash encryption...
D (788) efuse: BLK0 REG2 [18-20], len=3 bits
D (792) efuse: BLK0 REG0 [4-4], len=1 bits
V (796) flash_encrypt: CRYPT_CNT 0, write protection 0
D (801) efuse: BLK0 REG0 [4-4], len=1 bits
D (805) efuse: BLK0 REG2 [18-20], len=3 bits
I (809) efuse: Batch mode of writing fields is enabled
D (814) efuse: BLK0 REG2 [24-27], len=4 bits
D (818) efuse: BLK0 REG2 [28-31], len=4 bits
D (822) efuse: BLK0 REG3 [0-3], len=4 bits
D (825) efuse: BLK0 REG3 [4-7], len=4 bits
D (829) efuse: BLK0 REG3 [8-11], len=4 bits
D (833) efuse: BLK0 REG3 [12-15], len=4 bits
I (837) flash_encrypt: Generating new flash encryption key...
D (843) flash_encrypt: Key generation complete
D (847) efuse: BLK0 REG2 [24-27], len=4 bits
D (851) efuse: BLK0 REG0 [8-8], len=1 bits
D (855) efuse: BLK0 REG1 [0-0], len=1 bits
D (858) efuse: BLK0 REG0 [23-23], len=1 bits
D (862) efuse: BLK4 REG0 [0-31], len=32 bits
D (866) efuse: BLK4 REG1 [0-31], len=32 bits
D (870) efuse: BLK4 REG2 [0-31], len=32 bits
D (874) efuse: BLK4 REG3 [0-31], len=32 bits
D (878) efuse: BLK4 REG4 [0-31], len=32 bits
D (882) efuse: BLK4 REG5 [0-31], len=32 bits
D (886) efuse: BLK4 REG6 [0-31], len=32 bits
D (890) efuse: BLK4 REG7 [0-31], len=32 bits
D (894) efuse: BLK0 REG2 [28-31], len=4 bits
D (898) efuse: BLK0 REG0 [9-9], len=1 bits
D (902) efuse: BLK0 REG1 [1-1], len=1 bits
D (906) efuse: BLK0 REG0 [24-24], len=1 bits
D (910) efuse: BLK5 REG0 [0-31], len=32 bits
D (914) efuse: BLK5 REG1 [0-31], len=32 bits
D (918) efuse: BLK5 REG2 [0-31], len=32 bits
D (922) efuse: BLK5 REG3 [0-31], len=32 bits
D (926) efuse: BLK5 REG4 [0-31], len=32 bits
D (930) efuse: BLK5 REG5 [0-31], len=32 bits
D (934) efuse: BLK5 REG6 [0-31], len=32 bits
D (938) efuse: BLK5 REG7 [0-31], len=32 bits
D (942) efuse: BLK0 REG3 [0-3], len=4 bits
D (946) efuse: BLK0 REG0 [10-10], len=1 bits
D (950) efuse: BLK0 REG1 [2-2], len=1 bits
D (954) efuse: BLK0 REG0 [25-25], len=1 bits
D (958) efuse: BLK6 REG0 [0-31], len=32 bits
D (962) efuse: BLK6 REG1 [0-31], len=32 bits
D (966) efuse: BLK6 REG2 [0-31], len=32 bits
D (970) efuse: BLK6 REG3 [0-31], len=32 bits
D (974) efuse: BLK6 REG4 [0-31], len=32 bits
D (978) efuse: BLK6 REG5 [0-31], len=32 bits
D (982) efuse: BLK6 REG6 [0-31], len=32 bits
D (986) efuse: BLK6 REG7 [0-31], len=32 bits
D (990) efuse: BLK0 REG3 [4-7], len=4 bits
D (993) efuse: BLK0 REG0 [11-11], len=1 bits
D (997) efuse: BLK0 REG1 [3-3], len=1 bits
D (1001) efuse: BLK0 REG0 [26-26], len=1 bits
D (1005) efuse: BLK7 REG0 [0-31], len=32 bits
D (1009) efuse: BLK7 REG1 [0-31], len=32 bits
D (1013) efuse: BLK7 REG2 [0-31], len=32 bits
D (1017) efuse: BLK7 REG3 [0-31], len=32 bits
D (1022) efuse: BLK7 REG4 [0-31], len=32 bits
D (1026) efuse: BLK7 REG5 [0-31], len=32 bits
D (1030) efuse: BLK7 REG6 [0-31], len=32 bits
D (1034) efuse: BLK7 REG7 [0-31], len=32 bits
D (1038) efuse: BLK0 REG3 [8-11], len=4 bits
D (1042) efuse: BLK0 REG0 [12-12], len=1 bits
D (1046) efuse: BLK0 REG1 [4-4], len=1 bits
D (1050) efuse: BLK0 REG0 [27-27], len=1 bits
D (1054) efuse: BLK8 REG0 [0-31], len=32 bits
D (1058) efuse: BLK8 REG1 [0-31], len=32 bits
D (1062) efuse: BLK8 REG2 [0-31], len=32 bits
D (1066) efuse: BLK8 REG3 [0-31], len=32 bits
D (1070) efuse: BLK8 REG4 [0-31], len=32 bits
D (1074) efuse: BLK8 REG5 [0-31], len=32 bits
D (1078) efuse: BLK8 REG6 [0-31], len=32 bits
D (1082) efuse: BLK8 REG7 [0-31], len=32 bits
D (1087) efuse: BLK0 REG3 [12-15], len=4 bits
D (1091) efuse: BLK0 REG0 [13-13], len=1 bits
D (1095) efuse: BLK0 REG1 [5-5], len=1 bits
D (1099) efuse: BLK0 REG0 [28-28], len=1 bits
D (1103) efuse: BLK9 REG0 [0-31], len=32 bits
D (1107) efuse: BLK9 REG1 [0-31], len=32 bits
D (1111) efuse: BLK9 REG2 [0-31], len=32 bits
D (1115) efuse: BLK9 REG3 [0-31], len=32 bits
D (1119) efuse: BLK9 REG4 [0-31], len=32 bits
D (1123) efuse: BLK9 REG5 [0-31], len=32 bits
D (1127) efuse: BLK9 REG6 [0-31], len=32 bits
D (1131) efuse: BLK9 REG7 [0-31], len=32 bits
D (1135) efuse: BLK0 REG2 [24-27], len=4 bits
D (1139) efuse: BLK0 REG0 [8-8], len=1 bits
D (1143) efuse: BLK0 REG1 [0-0], len=1 bits
D (1147) efuse: BLK0 REG0 [23-23], len=1 bits
D (1151) efuse: BLK4 REG0 [0-31], len=32 bits
D (1155) efuse: BLK4 REG1 [0-31], len=32 bits
D (1159) efuse: BLK4 REG2 [0-31], len=32 bits
D (1164) efuse: BLK4 REG3 [0-31], len=32 bits
D (1168) efuse: BLK4 REG4 [0-31], len=32 bits
D (1172) efuse: BLK4 REG5 [0-31], len=32 bits
D (1176) efuse: BLK4 REG6 [0-31], len=32 bits
D (1180) efuse: BLK4 REG7 [0-31], len=32 bits
I (1184) efuse: Writing EFUSE_BLK_KEY0 with purpose 4
D (1189) efuse: BLK0 REG2 [24-27], len=4 bits
D (1193) efuse: BLK0 REG0 [8-8], len=1 bits
D (1197) efuse: BLK0 REG1 [0-0], len=1 bits
D (1201) efuse: BLK0 REG0 [23-23], len=1 bits
D (1205) efuse: BLK4 REG0 [0-31], len=32 bits
D (1209) efuse: BLK4 REG1 [0-31], len=32 bits
D (1213) efuse: BLK4 REG2 [0-31], len=32 bits
D (1217) efuse: BLK4 REG3 [0-31], len=32 bits
D (1221) efuse: BLK4 REG4 [0-31], len=32 bits
D (1225) efuse: BLK4 REG5 [0-31], len=32 bits
D (1229) efuse: BLK4 REG6 [0-31], len=32 bits
D (1233) efuse: BLK4 REG7 [0-31], len=32 bits
D (1237) efuse: BLK4 REG0 [0-31], len=32 bits
D (1241) efuse: BLK4 REG1 [0-31], len=32 bits
D (1245) efuse: BLK4 REG2 [0-31], len=32 bits
D (1250) efuse: BLK4 REG3 [0-31], len=32 bits
D (1254) efuse: BLK4 REG4 [0-31], len=32 bits
D (1258) efuse: BLK4 REG5 [0-31], len=32 bits
D (1262) efuse: BLK4 REG6 [0-31], len=32 bits
D (1266) efuse: BLK4 REG7 [0-31], len=32 bits
D (1270) efuse: BLK0 REG0 [23-23], len=1 bits
D (1274) efuse: BLK0 REG0 [23-23], len=1 bits
D (1278) efuse: BLK0 REG1 [0-0], len=1 bits
D (1282) efuse: BLK0 REG1 [0-0], len=1 bits
D (1286) efuse: BLK0 REG2 [24-27], len=4 bits
D (1290) efuse: BLK0 REG0 [8-8], len=1 bits
D (1294) efuse: BLK0 REG0 [8-8], len=1 bits
W (1298) flash_encrypt: Not disabling UART bootloader encryption
I (1304) flash_encrypt: Disable UART bootloader cache...
D (1309) efuse: BLK0 REG1 [10-10], len=1 bits
D (1313) efuse: BLK0 REG1 [10-10], len=1 bits
I (1317) flash_encrypt: Disable JTAG...
D (1320) efuse: BLK0 REG1 [19-19], len=1 bits
D (1324) efuse: BLK0 REG1 [19-19], len=1 bits
D (1328) efuse: BLK0 REG1 [9-9], len=1 bits
D (1332) efuse: BLK0 REG1 [9-9], len=1 bits
D (1336) efuse: BLK0 REG4 [1-1], len=1 bits
D (1340) efuse: BLK0 REG4 [1-1], len=1 bits
I (1345) efuse: BURN BLOCK4
I (1350) efuse: BURN BLOCK4 - OK (write block == read block)
I (1352) efuse: BURN BLOCK0
I (1357) efuse: BURN BLOCK0 - OK (all write block bits are set)
I (1360) efuse: Batch mode. Prepared fields are committed
D (1365) esp_image: reading image header @ 0x0
D (1369) bootloader_flash: mmu set block paddr=0x00000000 (was 0x00100000)
D (1376) esp_image: image header: 0xe9 0x03 0x02 0x02 403cc71a
V (1382) esp_image: loading segment header 0 at offset 0x18
V (1387) esp_image: segment data length 0x32e8 data starts 0x20
V (1393) esp_image: MMU page size 0x10000
V (1396) esp_image: segment 0 map_segment 0 segment_data_offs 0x20 load_addr 0x3fcd5990
I (1404) esp_image: segment 0: paddr=00000020 vaddr=3fcd5990 size=032e8h ( 13032)
D (1411) esp_image: free data page_count 0x00000080
D (1416) bootloader_flash: rodata starts from paddr=0x00000020, size=0x32e8, will be mapped to vaddr=0x3c000000
V (1426) bootloader_flash: after mapping, starting from paddr=0x00000000 and vaddr=0x3c000000, 0x10000 bytes are mapped
V (1437) esp_image: loading segment header 1 at offset 0x3308
D (1442) bootloader_flash: mmu set block paddr=0x00000000 (was 0xffffffff)
V (1448) esp_image: segment data length 0xcfc data starts 0x3310
V (1454) esp_image: MMU page size 0x10000
V (1458) esp_image: segment 1 map_segment 0 segment_data_offs 0x3310 load_addr 0x403cc710
I (1466) esp_image: segment 1: paddr=00003310 vaddr=403cc710 size=00cfch (  3324)
D (1473) esp_image: free data page_count 0x00000080
D (1477) bootloader_flash: rodata starts from paddr=0x00003310, size=0xcfc, will be mapped to vaddr=0x3c000000
V (1487) bootloader_flash: after mapping, starting from paddr=0x00000000 and vaddr=0x3c000000, 0x10000 bytes are mapped
V (1498) esp_image: loading segment header 2 at offset 0x400c
D (1503) bootloader_flash: mmu set block paddr=0x00000000 (was 0xffffffff)
V (1510) esp_image: segment data length 0x51b8 data starts 0x4014
V (1516) esp_image: MMU page size 0x10000
V (1519) esp_image: segment 2 map_segment 0 segment_data_offs 0x4014 load_addr 0x403ce710
I (1527) esp_image: segment 2: paddr=00004014 vaddr=403ce710 size=051b8h ( 20920)
D (1535) esp_image: free data page_count 0x00000080
D (1539) bootloader_flash: rodata starts from paddr=0x00004014, size=0x51b8, will be mapped to vaddr=0x3c000000
V (1549) bootloader_flash: after mapping, starting from paddr=0x00000000 and vaddr=0x3c000000, 0x10000 bytes are mapped
V (1561) esp_image: image start 0x00000000 end of last section 0x000091cc
D (1566) bootloader_flash: mmu set block paddr=0x00000000 (was 0xffffffff)
D (1573) flash_encrypt: bootloader is plaintext. Encrypting...
I (2151) flash_encrypt: bootloader encrypted successfully
D (2151) flash_parts: partition table verified, 7 entries
D (2151) flash_encrypt: partition table is plaintext. Encrypting...
I (2205) flash_encrypt: partition table encrypted and loaded successfully
I (2206) flash_encrypt: Encrypting partition 1 at offset 0x14000 (length 0x2000)...
I (2331) flash_encrypt: Done encrypting
D (2331) esp_image: reading image header @ 0x20000
D (2331) bootloader_flash: mmu set block paddr=0x00020000 (was 0x00000000)
D (2334) esp_image: image header: 0xe9 0x06 0x02 0x02 403802ea
V (2340) esp_image: loading segment header 0 at offset 0x20018
V (2345) esp_image: segment data length 0x1fd24 data starts 0x20020
V (2351) esp_image: MMU page size 0x10000
V (2355) esp_image: segment 0 map_segment 1 segment_data_offs 0x20020 load_addr 0x3c0c0020
I (2363) esp_image: segment 0: paddr=00020020 vaddr=3c0c0020 size=1fd24h (130340) map
D (2370) esp_image: free data page_count 0x00000080
D (2375) bootloader_flash: rodata starts from paddr=0x00020020, size=0x1fd24, will be mapped to vaddr=0x3c000000
V (2385) bootloader_flash: after mapping, starting from paddr=0x00020000 and vaddr=0x3c000000, 0x20000 bytes are mapped
V (2416) esp_image: loading segment header 1 at offset 0x3fd44
D (2416) bootloader_flash: mmu set block paddr=0x00030000 (was 0xffffffff)
V (2417) esp_image: segment data length 0x2cc data starts 0x3fd4c
V (2423) esp_image: MMU page size 0x10000
V (2427) esp_image: segment 1 map_segment 0 segment_data_offs 0x3fd4c load_addr 0x3fc93e00
I (2435) esp_image: segment 1: paddr=0003fd4c vaddr=3fc93e00 size=002cch (   716)
D (2442) esp_image: free data page_count 0x00000080
D (2447) bootloader_flash: rodata starts from paddr=0x0003fd4c, size=0x2cc, will be mapped to vaddr=0x3c000000
V (2456) bootloader_flash: after mapping, starting from paddr=0x00030000 and vaddr=0x3c000000, 0x20000 bytes are mapped
V (2467) esp_image: loading segment header 2 at offset 0x40018
D (2472) bootloader_flash: mmu set block paddr=0x00040000 (was 0xffffffff)
V (2479) esp_image: segment data length 0xb4b94 data starts 0x40020
V (2485) esp_image: MMU page size 0x10000
V (2489) esp_image: segment 2 map_segment 1 segment_data_offs 0x40020 load_addr 0x42000020
--- 0x42000020: esp_app_format_init_elf_sha256 at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_app_format/esp_app_desc.c:88

I (2497) esp_image: segment 2: paddr=00040020 vaddr=42000020 size=b4b94h (740244) map
D (2504) esp_image: free data page_count 0x00000080
D (2509) bootloader_flash: rodata starts from paddr=0x00040020, size=0xb4b94, will be mapped to vaddr=0x3c000000
V (2519) bootloader_flash: after mapping, starting from paddr=0x00040000 and vaddr=0x3c000000, 0xc0000 bytes are mapped
V (2647) esp_image: loading segment header 3 at offset 0xf4bb4
D (2647) bootloader_flash: mmu set block paddr=0x000f0000 (was 0xffffffff)
V (2648) esp_image: segment data length 0x2c24 data starts 0xf4bbc
V (2654) esp_image: MMU page size 0x10000
V (2658) esp_image: segment 3 map_segment 0 segment_data_offs 0xf4bbc load_addr 0x3fc940cc
I (2666) esp_image: segment 3: paddr=000f4bbc vaddr=3fc940cc size=02c24h ( 11300)
D (2673) esp_image: free data page_count 0x00000080
D (2678) bootloader_flash: rodata starts from paddr=0x000f4bbc, size=0x2c24, will be mapped to vaddr=0x3c000000
V (2687) bootloader_flash: after mapping, starting from paddr=0x000f0000 and vaddr=0x3c000000, 0x10000 bytes are mapped
V (2700) esp_image: loading segment header 4 at offset 0xf77e0
D (2703) bootloader_flash: mmu set block paddr=0x000f0000 (was 0xffffffff)
V (2710) esp_image: segment data length 0x13cc8 data starts 0xf77e8
V (2716) esp_image: MMU page size 0x10000
V (2720) esp_image: segment 4 map_segment 0 segment_data_offs 0xf77e8 load_addr 0x40380000
--- 0x40380000: _vector_table at /Users/francesco/esp/v5.4.2/esp-idf/components/riscv/vectors_intc.S:54

I (2728) esp_image: segment 4: paddr=000f77e8 vaddr=40380000 size=13cc8h ( 81096)
D (2735) esp_image: free data page_count 0x00000080
D (2740) bootloader_flash: rodata starts from paddr=0x000f77e8, size=0x13cc8, will be mapped to vaddr=0x3c000000
V (2750) bootloader_flash: after mapping, starting from paddr=0x000f0000 and vaddr=0x3c000000, 0x20000 bytes are mapped
V (2773) esp_image: loading segment header 5 at offset 0x10b4b0
D (2773) bootloader_flash: mmu set block paddr=0x00100000 (was 0xffffffff)
V (2774) esp_image: segment data length 0x1c data starts 0x10b4b8
V (2780) esp_image: MMU page size 0x10000
V (2784) esp_image: segment 5 map_segment 0 segment_data_offs 0x10b4b8 load_addr 0x50000000
I (2792) esp_image: segment 5: paddr=0010b4b8 vaddr=50000000 size=0001ch (    28)
D (2799) esp_image: free data page_count 0x00000080
D (2804) bootloader_flash: rodata starts from paddr=0x0010b4b8, size=0x1c, will be mapped to vaddr=0x3c000000
V (2813) bootloader_flash: after mapping, starting from paddr=0x00100000 and vaddr=0x3c000000, 0x10000 bytes are mapped
V (2824) esp_image: image start 0x00020000 end of last section 0x0010b4d4
D (2830) bootloader_flash: mmu set block paddr=0x00100000 (was 0xffffffff)
D (2837) boot: Calculated hash: 95320d19f00e1b0ae9da94d51f205ea7a1731fc9a3252e2a61a665c109798d46
I (2845) flash_encrypt: Encrypting partition 3 at offset 0x20000 (length 0xeb500)...
I (16131) flash_encrypt: Done encrypting
D (16131) esp_image: reading image header @ 0x120000
D (16131) bootloader_flash: mmu set block paddr=0x00120000 (was 0x00100000)
D (16135) esp_image: image header: 0x09 0xe5 0x92 0x04 10ef8522
E (16140) esp_image: image at 0x120000 has invalid magic byte (nothing flashed here?)
D (16148) esp_image: reading image header @ 0x220000
D (16153) bootloader_flash: mmu set block paddr=0x00220000 (was 0x00120000)
D (16159) esp_image: image header: 0xff 0xff 0xff 0x0f ffffffff
E (16165) esp_image: image at 0x220000 has invalid magic byte (nothing flashed here?)
D (16172) flash_encrypt: All flash regions checked for encryption pass
D (16179) efuse: BLK0 REG0 [4-4], len=1 bits
D (16183) efuse: BLK0 REG2 [18-20], len=3 bits
D (16187) flash_encrypt: CRYPT_CNT 0 -> 1
D (16191) efuse: BLK0 REG2 [18-20], len=3 bits
I (16195) efuse: BURN BLOCK0
I (16200) efuse: BURN BLOCK0 - OK (all write block bits are set)
I (16204) flash_encrypt: Flash encryption completed
I (16208) boot: Resetting with flash encryption enabled...
ESP-ROM:esp32c3-api1-20210207
Build:Feb  7 2021
rst:0x3 (RTC_SW_SYS_RST),boot:0xc (SPI_FAST_FLASH_BOOT)
Saved PC:0x40048b82
--- 0x40048b82: ets_secure_boot_verify_bootloader_with_keys in ROM

SPIWP:0xee
mode:DIO, clock div:1
load:0x3fcd5990,len:0x32e8
load:0x403cc710,len:0xcfc
load:0x403ce710,len:0x51b8
entry 0x403cc71a
I (31) boot: ESP-IDF v5.4.2-dirty 2nd stage bootloader
I (31) boot: compile time Jul 22 2025 09:21:12
D (31) bootloader_flash: XMC chip detected by RDID (00204016), skip.
D (35) bootloader_flash: mmu set block paddr=0x00000000 (was 0xffffffff)
I (41) boot: chip revision: v0.3
I (44) boot: efuse block revision: v1.1
D (48) boot.esp32c3: magic e9
D (51) boot.esp32c3: segments 03
D (53) boot.esp32c3: spi_mode 02
D (56) boot.esp32c3: spi_speed 0f
D (59) boot.esp32c3: spi_size 02
I (62) boot.esp32c3: SPI Speed      : 80MHz
I (66) boot.esp32c3: SPI Mode       : DIO
I (70) boot.esp32c3: SPI Flash Size : 4MB
D (74) boot: Enabling RTCWDT(9000 ms)
I (77) boot: Enabling RNG early entropy source...
D (82) bootloader_flash: rodata starts from paddr=0x0000f000, size=0xc00, will be mapped to vaddr=0x3c000000
V (91) bootloader_flash: after mapping, starting from paddr=0x00000000 and vaddr=0x3c000000, 0x10000 bytes are mapped
D (101) boot: mapped partition table 0xf000 at 0x3c00f000
D (107) flash_parts: partition table verified, 7 entries
I (112) boot: Partition Table:
I (114) boot: ## Label            Usage          Type ST Offset   Length
D (121) boot: load partition table entry 0x3c00f000
D (125) boot: type=1 subtype=2
I (128) boot:  0 nvs              WiFi data        01 02 00010000 00004000
D (135) boot: load partition table entry 0x3c00f020
D (139) boot: type=1 subtype=0
I (142) boot:  1 otadata          OTA data         01 00 00014000 00002000
D (149) boot: load partition table entry 0x3c00f040
D (153) boot: type=1 subtype=1
I (156) boot:  2 phy_init         RF data          01 01 00016000 00001000
D (163) boot: load partition table entry 0x3c00f060
D (167) boot: type=0 subtype=0
I (170) boot:  3 factory          factory app      00 00 00020000 00100000
D (177) boot: load partition table entry 0x3c00f080
D (181) boot: type=0 subtype=10
I (184) boot:  4 ota_0            OTA app          00 10 00120000 00100000
D (191) boot: load partition table entry 0x3c00f0a0
D (195) boot: type=0 subtype=11
I (198) boot:  5 ota_1            OTA app          00 11 00220000 00100000
I (205) boot: End of partition table
D (208) boot: OTA data offset 0x14000
D (212) bootloader_flash: rodata starts from paddr=0x00014000, size=0x2000, will be mapped to vaddr=0x3c000000
V (221) bootloader_flash: after mapping, starting from paddr=0x00010000 and vaddr=0x3c000000, 0x10000 bytes are mapped
D (232) boot: otadata[0]: sequence values 0xffffffff
D (236) boot: otadata[1]: sequence values 0xffffffff
D (241) boot: OTA sequence numbers both empty (all-0xFF) or partition table does not have bootable ota_apps (app_count=2)
I (252) boot: Defaulting to factory image
D (255) boot: Trying partition index -1 offs 0x20000 size 0x100000
D (261) esp_image: reading image header @ 0x20000
D (266) bootloader_flash: mmu set block paddr=0x00020000 (was 0xffffffff)
D (272) esp_image: image header: 0xe9 0x06 0x02 0x02 403802ea
V (278) esp_image: loading segment header 0 at offset 0x20018
V (283) esp_image: segment data length 0x1fd24 data starts 0x20020
V (289) esp_image: MMU page size 0x10000
V (293) esp_image: segment 0 map_segment 1 segment_data_offs 0x20020 load_addr 0x3c0c0020
I (301) esp_image: segment 0: paddr=00020020 vaddr=3c0c0020 size=1fd24h (130340) map
D (308) esp_image: free data page_count 0x00000080
D (313) bootloader_flash: rodata starts from paddr=0x00020020, size=0x1fd24, will be mapped to vaddr=0x3c000000
V (322) bootloader_flash: after mapping, starting from paddr=0x00020000 and vaddr=0x3c000000, 0x20000 bytes are mapped
V (356) esp_image: loading segment header 1 at offset 0x3fd44
D (356) bootloader_flash: mmu set block paddr=0x00030000 (was 0xffffffff)
V (357) esp_image: segment data length 0x2cc data starts 0x3fd4c
V (362) esp_image: MMU page size 0x10000
V (366) esp_image: segment 1 map_segment 0 segment_data_offs 0x3fd4c load_addr 0x3fc93e00
I (374) esp_image: segment 1: paddr=0003fd4c vaddr=3fc93e00 size=002cch (   716) load
D (382) esp_image: free data page_count 0x00000080
D (386) bootloader_flash: rodata starts from paddr=0x0003fd4c, size=0x2cc, will be mapped to vaddr=0x3c000000
V (396) bootloader_flash: after mapping, starting from paddr=0x00030000 and vaddr=0x3c000000, 0x20000 bytes are mapped
V (406) esp_image: loading segment header 2 at offset 0x40018
D (412) bootloader_flash: mmu set block paddr=0x00040000 (was 0xffffffff)
V (418) esp_image: segment data length 0xb4b94 data starts 0x40020
V (424) esp_image: MMU page size 0x10000
V (428) esp_image: segment 2 map_segment 1 segment_data_offs 0x40020 load_addr 0x42000020
--- 0x42000020: esp_app_format_init_elf_sha256 at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_app_format/esp_app_desc.c:88

I (436) esp_image: segment 2: paddr=00040020 vaddr=42000020 size=b4b94h (740244) map
D (443) esp_image: free data page_count 0x00000080
D (447) bootloader_flash: rodata starts from paddr=0x00040020, size=0xb4b94, will be mapped to vaddr=0x3c000000
V (457) bootloader_flash: after mapping, starting from paddr=0x00040000 and vaddr=0x3c000000, 0xc0000 bytes are mapped
V (598) esp_image: loading segment header 3 at offset 0xf4bb4
D (598) bootloader_flash: mmu set block paddr=0x000f0000 (was 0xffffffff)
V (599) esp_image: segment data length 0x2c24 data starts 0xf4bbc
V (604) esp_image: MMU page size 0x10000
V (608) esp_image: segment 3 map_segment 0 segment_data_offs 0xf4bbc load_addr 0x3fc940cc
I (616) esp_image: segment 3: paddr=000f4bbc vaddr=3fc940cc size=02c24h ( 11300) load
D (623) esp_image: free data page_count 0x00000080
D (628) bootloader_flash: rodata starts from paddr=0x000f4bbc, size=0x2c24, will be mapped to vaddr=0x3c000000
V (638) bootloader_flash: after mapping, starting from paddr=0x000f0000 and vaddr=0x3c000000, 0x10000 bytes are mapped
V (650) esp_image: loading segment header 4 at offset 0xf77e0
D (654) bootloader_flash: mmu set block paddr=0x000f0000 (was 0xffffffff)
V (660) esp_image: segment data length 0x13cc8 data starts 0xf77e8
V (666) esp_image: MMU page size 0x10000
V (670) esp_image: segment 4 map_segment 0 segment_data_offs 0xf77e8 load_addr 0x40380000
--- 0x40380000: _vector_table at /Users/francesco/esp/v5.4.2/esp-idf/components/riscv/vectors_intc.S:54

I (678) esp_image: segment 4: paddr=000f77e8 vaddr=40380000 size=13cc8h ( 81096) load
D (685) esp_image: free data page_count 0x00000080
D (690) bootloader_flash: rodata starts from paddr=0x000f77e8, size=0x13cc8, will be mapped to vaddr=0x3c000000
V (699) bootloader_flash: after mapping, starting from paddr=0x000f0000 and vaddr=0x3c000000, 0x20000 bytes are mapped
V (727) esp_image: loading segment header 5 at offset 0x10b4b0
D (727) bootloader_flash: mmu set block paddr=0x00100000 (was 0xffffffff)
V (727) esp_image: segment data length 0x1c data starts 0x10b4b8
V (733) esp_image: MMU page size 0x10000
V (737) esp_image: segment 5 map_segment 0 segment_data_offs 0x10b4b8 load_addr 0x50000000
I (745) esp_image: segment 5: paddr=0010b4b8 vaddr=50000000 size=0001ch (    28) load
D (752) esp_image: free data page_count 0x00000080
D (757) bootloader_flash: rodata starts from paddr=0x0010b4b8, size=0x1c, will be mapped to vaddr=0x3c000000
V (766) bootloader_flash: after mapping, starting from paddr=0x00100000 and vaddr=0x3c000000, 0x10000 bytes are mapped
V (777) esp_image: image start 0x00020000 end of last section 0x0010b4d4
D (783) bootloader_flash: mmu set block paddr=0x00100000 (was 0xffffffff)
D (790) boot: Calculated hash: 95320d19f00e1b0ae9da94d51f205ea7a1731fc9a3252e2a61a665c109798d46
I (804) boot: Loaded app from partition at offset 0x20000
I (804) boot: Checking flash encryption...
D (807) efuse: BLK0 REG2 [18-20], len=3 bits
D (811) efuse: BLK0 REG0 [4-4], len=1 bits
V (815) flash_encrypt: CRYPT_CNT 1, write protection 0
I (820) flash_encrypt: flash encryption is enabled (1 plaintext flashes left)
I (827) boot: Disabling RNG early entropy source...
D (831) boot: Mapping segment 0 as DROM
D (835) boot: Mapping segment 2 as IROM
D (838) boot: calling set_cache_and_start_app
D (842) boot: configure drom and irom and start
V (847) boot: rodata starts from paddr=0x00020020, vaddr=0x3c0c0020, size=0x1fd24
V (854) boot: after mapping rodata, starting from paddr=0x00020000 and vaddr=0x3c0c0000, 0x20000 bytes are mapped
V (864) boot: mapped one page of the rodata, from paddr=0x00020000 and vaddr=0x3c7f0000, 0x10000 bytes are mapped
V (874) boot: text starts from paddr=0x00040020, vaddr=0x42000020, size=0xb4b94
--- 0x42000020: esp_app_format_init_elf_sha256 at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_app_format/esp_app_desc.c:88

V (881) boot: after mapping text, starting from paddr=0x00040000 and vaddr=0x42000000, 0xc0000 bytes are mapped
D (891) boot: start: 0x403802ea
--- 0x403802ea: call_start_cpu0 at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/port/cpu_start.c:387
```
</details>

You need to do the last two steps.

* Click the reset button on your device
* Flash the project again: `> ESP-IDF: Flash (UART) Your Project`


### Check the device encryption status

* Open an ESP-IDF terminal : `> ESP-IDF: Open ESP-IDF Terminal`
* Inside the terminal, run `idf.py efuse-summary`


<details>
<summary>Show eFuses summary</summary>

```bash
espefuse.py v4.9.0
Connecting...

=== Run "summary" command ===
EFUSE_NAME (Block) Description  = [Meaningful Value] [Readable/Writeable] (Hex Value)
----------------------------------------------------------------------------------------
Calibration fuses:
K_RTC_LDO (BLOCK1)                                 BLOCK1 K_RTC_LDO                                   = 96 R/W (0b0011000)
K_DIG_LDO (BLOCK1)                                 BLOCK1 K_DIG_LDO                                   = 20 R/W (0b0000101)
V_RTC_DBIAS20 (BLOCK1)                             BLOCK1 voltage of rtc dbias20                      = 172 R/W (0x2b)
V_DIG_DBIAS20 (BLOCK1)                             BLOCK1 voltage of digital dbias20                  = 32 R/W (0x08)
DIG_DBIAS_HVT (BLOCK1)                             BLOCK1 digital dbias when hvt                      = -12 R/W (0b10011)
THRES_HVT (BLOCK1)                                 BLOCK1 pvt threshold when hvt                      = 1600 R/W (0b0110010000)
TEMP_CALIB (BLOCK2)                                Temperature calibration data                       = -9.0 R/W (0b101011010)
OCODE (BLOCK2)                                     ADC OCode                                          = 96 R/W (0x60)
ADC1_INIT_CODE_ATTEN0 (BLOCK2)                     ADC1 init code at atten0                           = 1736 R/W (0b0110110010)
ADC1_INIT_CODE_ATTEN1 (BLOCK2)                     ADC1 init code at atten1                           = -272 R/W (0b1001000100)
ADC1_INIT_CODE_ATTEN2 (BLOCK2)                     ADC1 init code at atten2                           = -368 R/W (0b1001011100)
ADC1_INIT_CODE_ATTEN3 (BLOCK2)                     ADC1 init code at atten3                           = -824 R/W (0b1011001110)
ADC1_CAL_VOL_ATTEN0 (BLOCK2)                       ADC1 calibration voltage at atten0                 = -204 R/W (0b1000110011)
ADC1_CAL_VOL_ATTEN1 (BLOCK2)                       ADC1 calibration voltage at atten1                 = -4 R/W (0b1000000001)
ADC1_CAL_VOL_ATTEN2 (BLOCK2)                       ADC1 calibration voltage at atten2                 = -160 R/W (0b1000101000)
ADC1_CAL_VOL_ATTEN3 (BLOCK2)                       ADC1 calibration voltage at atten3                 = -332 R/W (0b1001010011)

Config fuses:
WR_DIS (BLOCK0)                                    Disable programming of individual eFuses           = 8388864 R/W (0x00800100)
RD_DIS (BLOCK0)                                    Disable reading from BlOCK4-10                     = 1 R/W (0b0000001)
DIS_ICACHE (BLOCK0)                                Set this bit to disable Icache                     = False R/W (0b0)
DIS_TWAI (BLOCK0)                                  Set this bit to disable CAN function               = False R/W (0b0)
DIS_DIRECT_BOOT (BLOCK0)                           Disable direct boot mode                           = True R/W (0b1)
UART_PRINT_CONTROL (BLOCK0)                        Set the default UARTboot message output mode
   = Enable when GPIO8 is high at reset R/W (0b10)
ERR_RST_ENABLE (BLOCK0)                            Use BLOCK0 to check error record registers         = without check R/W (0b0)
BLOCK_USR_DATA (BLOCK3)                            User data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_SYS_DATA2 (BLOCK10)                          System data part 2 (reserved)
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W

Flash fuses:
FLASH_TPUW (BLOCK0)                                Configures flash waiting time after power-up; in u = 0 R/W (0x0)
                                                   nit of ms. If the value is less than 15; the waiti
                                                   ng time is the configurable value; Otherwise; the
                                                   waiting time is twice the configurable value
FORCE_SEND_RESUME (BLOCK0)                         Set this bit to force ROM code to send a resume co = False R/W (0b0)
                                                   mmand during SPI boot
FLASH_CAP (BLOCK1)                                 Flash capacity                                     = 4M R/W (0b001)
FLASH_TEMP (BLOCK1)                                Flash temperature                                  = 105C R/W (0b01)
FLASH_VENDOR (BLOCK1)                              Flash vendor                                       = XMC R/W (0b001)

Identity fuses:
DISABLE_WAFER_VERSION_MAJOR (BLOCK0)               Disables check of wafer version major              = False R/W (0b0)
DISABLE_BLK_VERSION_MAJOR (BLOCK0)                 Disables check of blk version major                = False R/W (0b0)
WAFER_VERSION_MINOR_LO (BLOCK1)                    WAFER_VERSION_MINOR least significant bits         = 3 R/W (0b011)
PKG_VERSION (BLOCK1)                               Package version                                    = 0 R/W (0b000)
BLK_VERSION_MINOR (BLOCK1)                         BLK_VERSION_MINOR                                  = 1 R/W (0b001)
WAFER_VERSION_MINOR_HI (BLOCK1)                    WAFER_VERSION_MINOR most significant bit           = False R/W (0b0)
WAFER_VERSION_MAJOR (BLOCK1)                       WAFER_VERSION_MAJOR                                = 0 R/W (0b00)
OPTIONAL_UNIQUE_ID (BLOCK2)                        Optional unique 128-bit ID
   = 7c c7 9b 3a 4c 1f e1 be 56 79 19 20 4f ff cd 0e R/W
BLK_VERSION_MAJOR (BLOCK2)                         BLK_VERSION_MAJOR of BLOCK2                        = With calibration R/W (0b01)
WAFER_VERSION_MINOR (BLOCK0)                       calc WAFER VERSION MINOR = WAFER_VERSION_MINOR_HI  = 3 R/W (0x3)
                                                   << 3 + WAFER_VERSION_MINOR_LO (read only)

Jtag fuses:
SOFT_DIS_JTAG (BLOCK0)                             Set these bits to disable JTAG in the soft way (od = 0 R/W (0b000)
                                                   d number 1 means disable ). JTAG can be enabled in
                                                    HMAC module
DIS_PAD_JTAG (BLOCK0)                              Set this bit to disable JTAG in the hard way. JTAG = True R/W (0b1)
                                                    is disabled permanently

Mac fuses:
MAC (BLOCK1)                                       MAC address
   = 84:f7:03:42:8c:a8 (OK) R/W
CUSTOM_MAC (BLOCK3)                                Custom MAC address
   = 00:00:00:00:00:00 (OK) R/W

Security fuses:
DIS_DOWNLOAD_ICACHE (BLOCK0)                       Set this bit to disable Icache in download mode (b = True R/W (0b1)
                                                   oot_mode[3:0] is 0; 1; 2; 3; 6; 7)
DIS_FORCE_DOWNLOAD (BLOCK0)                        Set this bit to disable the function that forces c = False R/W (0b0)
                                                   hip into download mode
DIS_DOWNLOAD_MANUAL_ENCRYPT (BLOCK0)               Set this bit to disable flash encryption when in d = False R/W (0b0)
                                                   ownload boot modes
SPI_BOOT_CRYPT_CNT (BLOCK0)                        Enables flash encryption when 1 or 3 bits are set  = Enable R/W (0b001)
                                                   and disables otherwise
SECURE_BOOT_KEY_REVOKE0 (BLOCK0)                   Revoke 1st secure boot key                         = False R/W (0b0)
SECURE_BOOT_KEY_REVOKE1 (BLOCK0)                   Revoke 2nd secure boot key                         = False R/W (0b0)
SECURE_BOOT_KEY_REVOKE2 (BLOCK0)                   Revoke 3rd secure boot key                         = False R/W (0b0)
KEY_PURPOSE_0 (BLOCK0)                             Purpose of Key0                                    = XTS_AES_128_KEY R/- (0x4)
KEY_PURPOSE_1 (BLOCK0)                             Purpose of Key1                                    = USER R/W (0x0)
KEY_PURPOSE_2 (BLOCK0)                             Purpose of Key2                                    = USER R/W (0x0)
KEY_PURPOSE_3 (BLOCK0)                             Purpose of Key3                                    = USER R/W (0x0)
KEY_PURPOSE_4 (BLOCK0)                             Purpose of Key4                                    = USER R/W (0x0)
KEY_PURPOSE_5 (BLOCK0)                             Purpose of Key5                                    = USER R/W (0x0)
SECURE_BOOT_EN (BLOCK0)                            Set this bit to enable secure boot                 = False R/W (0b0)
SECURE_BOOT_AGGRESSIVE_REVOKE (BLOCK0)             Set this bit to enable revoking aggressive secure  = False R/W (0b0)
                                                   boot
DIS_DOWNLOAD_MODE (BLOCK0)                         Set this bit to disable download mode (boot_mode[3 = False R/W (0b0)
                                                   :0] = 0; 1; 2; 3; 6; 7)
ENABLE_SECURITY_DOWNLOAD (BLOCK0)                  Set this bit to enable secure UART download mode   = False R/W (0b0)
SECURE_VERSION (BLOCK0)                            Secure version (used by ESP-IDF anti-rollback feat = 0 R/W (0x0000)
                                                   ure)
BLOCK_KEY0 (BLOCK4)
  Purpose: XTS_AES_128_KEY
    Key0 or user data
   = ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? -/-
BLOCK_KEY1 (BLOCK5)
  Purpose: USER
               Key1 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_KEY2 (BLOCK6)
  Purpose: USER
               Key2 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_KEY3 (BLOCK7)
  Purpose: USER
               Key3 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_KEY4 (BLOCK8)
  Purpose: USER
               Key4 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W
BLOCK_KEY5 (BLOCK9)
  Purpose: USER
               Key5 or user data
   = 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 R/W

Spi Pad fuses:
SPI_PAD_CONFIG_CLK (BLOCK1)                        SPI PAD CLK                                        = 0 R/W (0b000000)
SPI_PAD_CONFIG_Q (BLOCK1)                          SPI PAD Q(D1)                                      = 0 R/W (0b000000)
SPI_PAD_CONFIG_D (BLOCK1)                          SPI PAD D(D0)                                      = 0 R/W (0b000000)
SPI_PAD_CONFIG_CS (BLOCK1)                         SPI PAD CS                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_HD (BLOCK1)                         SPI PAD HD(D3)                                     = 0 R/W (0b000000)
SPI_PAD_CONFIG_WP (BLOCK1)                         SPI PAD WP(D2)                                     = 0 R/W (0b000000)
SPI_PAD_CONFIG_DQS (BLOCK1)                        SPI PAD DQS                                        = 0 R/W (0b000000)
SPI_PAD_CONFIG_D4 (BLOCK1)                         SPI PAD D4                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_D5 (BLOCK1)                         SPI PAD D5                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_D6 (BLOCK1)                         SPI PAD D6                                         = 0 R/W (0b000000)
SPI_PAD_CONFIG_D7 (BLOCK1)                         SPI PAD D7                                         = 0 R/W (0b000000)

Usb fuses:
DIS_USB_JTAG (BLOCK0)                              Set this bit to disable function of usb switch to  = True R/W (0b1)
                                                   jtag in module of usb device
DIS_USB_SERIAL_JTAG (BLOCK0)                       USB-Serial-JTAG                                    = Enable R/W (0b0)
USB_EXCHG_PINS (BLOCK0)                            Set this bit to exchange USB D+ and D- pins        = False R/W (0b0)
DIS_USB_SERIAL_JTAG_ROM_PRINT (BLOCK0)             USB printing                                       = Enable R/W (0b0)
DIS_USB_SERIAL_JTAG_DOWNLOAD_MODE (BLOCK0)         Disable UART download mode through USB-Serial-JTAG = False R/W (0b0)

Vdd fuses:
VDD_SPI_AS_GPIO (BLOCK0)                           Set this bit to vdd spi pin function as gpio       = False R/W (0b0)

Wdt fuses:
WDT_DELAY_SEL (BLOCK0)                             RTC watchdog timeout threshold; in unit of slow cl = 40000 R/W (0b00)
                                                   ock cycle
```

</details>

You should spot the following differences:

```bash
[...]
WR_DIS (BLOCK0)                                    Disable programming of individual eFuses           = 8388864 R/W (0x00800100)
RD_DIS (BLOCK0)                                    Disable reading from BlOCK4-10                     = 1 R/W (0b0000001)
[...]
DIS_DIRECT_BOOT (BLOCK0)                           Disable direct boot mode                           = True R/W (0b1)
[...]
DIS_PAD_JTAG (BLOCK0)                              Set this bit to disable JTAG in the hard way. JTAG = True R/W (0b1)
[...]
DIS_DOWNLOAD_ICACHE (BLOCK0)                       Set this bit to disable Icache in download mode (b = True R/W (0b1))
[...]
SPI_BOOT_CRYPT_CNT (BLOCK0)                        Enables flash encryption when 1 or 3 bits are set  = Enable R/W (0b001)
[...]
KEY_PURPOSE_0 (BLOCK0)                             Purpose of Key0                                    = XTS_AES_128_KEY R/- (0x4)
[...]
BLOCK_KEY0 (BLOCK4)
  Purpose: XTS_AES_128_KEY
    Key0 or user data
   = ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? -/-
[...]
DIS_USB_JTAG (BLOCK0)                              Set this bit to disable function of usb switch to  = True R/W (0b1)
```

We can see that:

* The flash encryption is set (`SPI_BOOT_CRYPT_CNT`).
* One of the eFuse blocks has been reserved to store the encryption key.

Now your device has flash encryption. Since we selected the development, you can still flash it again using the serial port.

## Conclusion

In this assignment, we added flash encryption to the project by enabling the appropriate options in the `menuconfig` and by accommodating the partition table offset as required.

> Next step: [Conclusion](../#conclusion)

> Or [go back to navigation menu](../#agenda)