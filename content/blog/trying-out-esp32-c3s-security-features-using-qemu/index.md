---
title: "Trying out ESP32-C3’s security features using QEMU"
date: 2024-04-04
showAuthor: false
featureAsset: "img/featured/featured-tutorial.webp"
authors:
  - harshal-patil
tags:
  - latest release
  - releases section
  - Esp32
  - Esp Idf
  - Security
  - Emulator
  - IoT

---
## Overview

ESP32 series of SoCs supports multiple [security features ](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/security/security.html)like trusted boot, flash encryption, secure storage etc. There are also dedicated peripherals to support use-cases like HMAC and digital signature. For most of these features the eFuse storage in the ESP32-C3 is responsible for storing the private keys and also the configuration bits.

eFuse memory is one time programmable and hence care must be taken whilst enabling the security features. eFuse programming being an irreversible operation, it is desired to have some playground available to first try out security features (e.g., under emulator) and then move to the real hardware.

This article talks about exercising different security features in ESP32-C3 under QEMU (emulator).

## QEMU

> QEMU, which stands for Quick EMUlator, is an open-source virtualization tool that allows users to create and run virtual machines (VMs) on a host system. It can emulate various architectures, including x86, ARM, RISCV, and others, enabling users to run operating systems and software designed for different hardware platforms.

Espressif has been developing a system-level emulation of RISC-V based ESP32-C3 using [QEMU](https://github.com/qemu/qemu/) and its [latest release](https://github.com/espressif/qemu/releases/tag/esp-develop-8.2.0-20240122) supports all the security features for ESP32-C3. Binary compatibility has been maintained to directly run the firmware built for ESP32-C3 target under QEMU.

Emulator approach provides an advantage to iterate various security configurations without risk of bricking the hardware. Once the workflow is established under QEMU, it can be easily adapted for the real hardware.

## How does QEMU help in trying out the security features?

QEMU is a system-level emulator composed of instruction set emulation, memory and MMU emulation, and peripheral emulation. It also supports various virtual disk formats and networking configurations as well.

{{< figure
    default=true
    src="img/trying-1.webp"
    >}}

This helps us to emulate the complete hardware SoC that includes peripherals emulation as well. Peripherals like eFuses, XTS-AES, RSA play a key role in supporting security features.

We will deep-dive into how to use these emulated host files while using QEMU in the upcoming sections.

## Trying out the security features

Espressif’s [security guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/security/index.html) mentions two workflows for enabling the security features:

- Internal first boot-up workflow
- [Host-based workflow](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/security/host-based-security-workflows.html)

We will use a [demo example](https://github.com/Harshal5/esp-idf-security-example) which enabled and allows us to try out all the supported security features:

- [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/security/secure-boot-v2.html)
- [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/security/flash-encryption.html)
- [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-reference/storage/nvs_encryption.html) ([using the HMAC based workflow](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-reference/storage/nvs_encryption.html#nvs-encryption-hmac-peripheral-based-scheme))

Let us check out the boot internal first boot-up workflow:

## Installing QEMU release versions

```
# Linux
wget https://github.com/espressif/qemu/releases/download/esp-develop-8.2.0-20240122/qemu-riscv32-softmmu-esp_develop_8.2.0_20240122-x86_64-linux-gnu.tar.xz -P ~/Downloads
tar xvf ~/Downloads/qemu-riscv32-softmmu-esp_develop_8.2.0_20240122-x86_64-linux-gnu.tar.xz -C ~/Downloads

# MacOS (M1 silicon)
wget https://github.com/espressif/qemu/releases/download/esp-develop-8.2.0-20240122/qemu-riscv32-softmmu-esp_develop_8.2.0_20240122-aarch64-apple-darwin.tar.xz -P ~/Downloads
tar xvf ~/Downloads/qemu-riscv32-softmmu-esp_develop_8.2.0_20240122-aarch64-apple-darwin.tar.xz -C ~/Downloads
```

You could also consider adding it to your environment’s $PATH variable for ease of use. For example, in case of Linux/MacOS, if after extracting the downloaded release file is in the Downloads directory, you may run following command:

```
export PATH=$PATH:~/Downloads/qemu/bin
```

2. In case you are interested in trying out the development versions you could also opt for cloning and building Espressif’s GitHub QEMU [fork](https://github.com/espressif/qemu) using the configuration instructions mentioned in the [documentation](https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/esp32c3).

3. In case you are using ESP-IDF’s master branch for developing your firmware, the easiest way to install the QEMU is getting the release binaries that are packaged with ESP-IDF (master) using the following command:

```
python $IDF_PATH/tools/idf_tools.py install qemu-riscv32
```

The above command exports the path to the ESP-IDF packaged QEMU release binaries into your $PATH variable as well.

## Internal first boot-up workflow

In this workflow, the security features are incrementally enabled during the first boot up by the bootloader.

1. __Clone the demo project__ 

In a new terminal window, activate the ESP-IDF environment, using the . ./export.sh as mentioned in the ESP-IDF installation [section](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/linux-macos-setup.html#step-4-set-up-the-environment-variables).

Use the following commands to clone the [demo](https://github.com/Harshal5/esp-idf-security-example) project:

```
git clone https://github.com/Harshal5/esp-idf-security-example.git
cd esp-idf-security-example
```

2. __Enable the security related configs__ 

Starting off with the first step, set project target to esp32c3 by entering the command:

```
idf.py set-target esp32c3
```

The project we are using already has all the security configs listed below enabled by default (sdkconfig.defaults), so you do not need to enable them by yourselves.

Security-related configs that have been enabled:

```
# Secure Boot related configs
CONFIG_SECURE_SIGNED_ON_BOOT=y
CONFIG_SECURE_SIGNED_ON_UPDATE=y
CONFIG_SECURE_SIGNED_APPS=y

CONFIG_SECURE_BOOT_V2_RSA_ENABLED=y
CONFIG_SECURE_SIGNED_APPS_RSA_SCHEME=y
CONFIG_SECURE_BOOT=y
CONFIG_SECURE_BOOT_V2_ENABLED=y
CONFIG_SECURE_BOOT_BUILD_SIGNED_BINARIES=y
CONFIG_SECURE_BOOT_SIGNING_KEY="secure_boot_signing_key.pem"
CONFIG_SECURE_BOOT_FLASH_BOOTLOADER_DEFAULT=y

# Flash Encryption related configs
CONFIG_SECURE_FLASH_ENC_ENABLED=y
CONFIG_FLASH_ENCRYPTION_ENABLED=y
CONFIG_SECURE_FLASH_ENCRYPTION_MODE_RELEASE=y
CONFIG_SECURE_FLASH_HAS_WRITE_PROTECTION_CACHE=y
CONFIG_SECURE_FLASH_ENCRYPT_ONLY_IMAGE_LEN_IN_APP_PART=y
CONFIG_SECURE_FLASH_CHECK_ENC_EN_IN_APP=y
CONFIG_SECURE_ENABLE_SECURE_ROM_DL_MODE=y

# NVS Encryption related configs
CONFIG_NVS_ENCRYPTION=y
CONFIG_NVS_SEC_KEY_PROTECT_USING_HMAC=y
CONFIG_NVS_SEC_HMAC_EFUSE_KEY_ID=3
```

Setting these configs assume that we have a pre-generated secure boot key named *secure_boot_signing_key.pem*, flash encryption key would be generated by the device (esp32c3), and an HMAC key (say *hmac_key.bin*) that would be used to derive the NVS encryption key needs to be pre-burnt in the eFuse KEY_BLOCK3.

The secure boot signing key being an RSA key, can be generated using the command:

```
espsecure.py generate_signing_key --version 2 secure_boot_signing_key.pem
```

whereas the NVS encryption key being an HMAC key can be created using the command:

```
dd if=/dev/random of=hmac_key.bin bs=1 count=32
```

3. __Generate the flash image__ 

Once we are done with the configurations, we need to build the firmware using the command:

```
idf.py build
```

that would create the bootloader, partition-table, and the application images individually in the build directory.

The QEMU flash image should be generated by merging the boot loader, partition-table and the application binary images present in the project'sbuild directory of the project. A straightforward way to generate such a flash image is by using the esptool.py merge_bin command with the parameter flash_args file, which contains the entries of all the binary images that are needed to be flash using the command idf.py flash.

Use the below command to generate a complete flash image (flash_image) for the firmware:

```
(cd build; esptool.py --chip esp32c3 merge_bin --fill-flash-size 4MB -o flash_image.bin @flash_args)
```

As we have already enabled the config CONFIG_SECURE_BOOT_FLASH_BOOTLOADER_DEFAULT, the bootloader entry gets added into the flash_args file, which is needed because as mentioned in secure boot [guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/security/secure-boot-v2.html), bootloader does not get flashed by default with the idf.py flash command when secure boot is enabled.

4. __Get the eFuses file ready__ 

A simple eFuses file could be created using:

```
dd if=/dev/zero bs=1K count=1 of=build/qemu_efuse.bin
```

This command creates a 1KB (1024 bytes) file, which is the total size of ESP32-C3 eFuse blocks, filled with zeros.

Now you have your eFuse file ready and you can view the eFuses summary by running QEMU ESP32-C3 in download mode and attaching the above generated eFuses file. Run QEMU in the download mode using the following command in the terminal in which we have updated the *PATH *variable:

```
qemu-system-riscv32 -nographic \
                    -machine esp32c3 \
                    -global driver=esp32c3.gpio,property=strap_mode,value=0x02 \
                    -drive file=build/qemu_efuse.bin,if=none,format=raw,id=efuse \
                    -global driver=nvram.esp32c3.efuse,property=drive,value=efuse \
                    -serial tcp::5555,server,nowait
```

(Once you run the above command you will be able to see the version of the QEMU binary in such format QEMU 8.2.0 monitor. Make sure the version is ≥ 8.2.0)

Once QEMU is up running in the download mode, you should be able to check the eFuses summary using espefuse.py in the ESP-IDF environment terminal window:

```
export ESPPORT=socket://localhost:5555

espefuse.py -p $ESPPORT --before=no_reset summary
```

Note: While running QEMU in the download mode the serial output can be redirected to a TCP port. As done in the above QEMU command we have used port 5555, thus you need to set the variable ESPPORT to socket://localhost:5555 or use the port directly for all the related operations.

You should now be able to view an empty or clean eFuses summary similar to a physical hardware chip.

__You would also need to set the ECO version as required__ . For example, if an ESP32-C3 v0.3 is to be used, you need to set the eFuse WAFER_VERSION_MINOR_LO to value 3.

```
espefuse.py -p $ESPPORT --before=no_reset burn_efuse WAFER_VERSION_MINOR_LO 3
```

Finally burn the HMAC key in KEY_BLOCK3 with the key purpose HMAC_UP that would be used for NVS encryption:

```
espefuse.py -p $ESPPORT --before=no_reset burn_key BLOCK_KEY3 hmac_key.bin HMAC_UP
```

Once you are done with burning all the required eFuses, you need to close QEMU by entering the “quit” command.

5. __Run the firmware using QEMU__

We are now ready to run the firmware by running QEMU in the boot mode using the command:

```
qemu-system-riscv32 -nographic \
                    -M esp32c3 \
                    -drive file=build/flash_image.bin,if=mtd,format=raw \
                    -drive file=build/qemu_efuse.bin,if=none,format=raw,id=efuse \
                    -global driver=nvram.esp32c3.efuse,property=drive,value=efuse \
                    -serial mon:stdio
```

Note: Supply the same merged flash image and the updated eFuses file generated in the previous steps.

As we have used stdio as output destination to the serial port, we should now be able to see the following success logs of enabling secure boot, flash encryption and NVS encryption respectively along with their corresponding eFuses burned in the eFuse file, and the merged flash_image being encrypted:

```
> qemu-system-riscv32 -nographic \
                    -M esp32c3 \      
                    -drive file=build/flash_image.bin,if=mtd,format=raw \       
                    -drive file=build/qemu_efuse.bin,if=none,format=raw,id=efuse \
                    -global driver=nvram.esp32c3.efuse,property=drive,value=efuse \
                    -serial mon:stdio
       
Adding SPI flash device
ESP-ROM:esp32c3-api1-20210207
Build:Feb  7 2021
rst:0x1 (POWERON),boot:0x8 (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:1
load:0x3fcd5990,len:0x3b48
load:0x403cc710,len:0xb9c
load:0x403ce710,len:0x5b78
entry 0x403cc71a
I (1) boot: ESP-IDF v5.3-dev-2547-g8b3821ca67 2nd stage bootloader
I (2) boot: compile time Mar 14 2024 15:09:57
I (5) boot: chip revision: v0.3
I (7) boot.esp32c3: SPI Speed      : 80MHz
I (7) boot.esp32c3: SPI Mode       : SLOW READ
I (8) boot.esp32c3: SPI Flash Size : 2MB
I (11) boot: Enabling RNG early entropy source...
I (17) boot: Partition Table:
I (17) boot: ## Label            Usage          Type ST Offset   Length
I (18) boot:  0 nvs              WiFi data        01 02 0000e000 00006000
I (18) boot:  1 storage          Unknown data     01 ff 00014000 00001000
I (19) boot:  2 factory          factory app      00 00 00020000 00100000
I (19) boot:  3 nvs_key          NVS keys         01 04 00120000 00001000
I (20) boot:  4 custom_nvs       WiFi data        01 02 00121000 00006000
I (20) boot: End of partition table
I (22) esp_image: segment 0: paddr=00020020 vaddr=3c030020 size=0c1d8h ( 49624) map
I (36) esp_image: segment 1: paddr=0002c200 vaddr=3fc8b600 size=01548h (  5448) load
I (38) esp_image: segment 2: paddr=0002d750 vaddr=40380000 size=028c8h ( 10440) load
I (42) esp_image: segment 3: paddr=00030020 vaddr=42000020 size=21034h (135220) map
I (76) esp_image: segment 4: paddr=0005105c vaddr=403828c8 size=08c84h ( 35972) load
I (86) esp_image: segment 5: paddr=00059ce8 vaddr=00000000 size=062e8h ( 25320) 
I (93) esp_image: Verifying image signature...
I (95) secure_boot_v2: Secure boot V2 is not enabled yet and eFuse digest keys are not set
I (97) secure_boot_v2: Verifying with RSA-PSS...
I (103) secure_boot_v2: Signature verified successfully!
I (104) boot: Loaded app from partition at offset 0x20000
I (105) secure_boot_v2: enabling secure boot v2...
I (109) efuse: Batch mode of writing fields is enabled
I (110) esp_image: segment 0: paddr=00000020 vaddr=3fcd5990 size=03b48h ( 15176) 
I (114) esp_image: segment 1: paddr=00003b70 vaddr=403cc710 size=00b9ch (  2972) 
I (116) esp_image: segment 2: paddr=00004714 vaddr=403ce710 size=05b78h ( 23416) 
I (122) esp_image: Verifying image signature...
I (124) secure_boot_v2: Secure boot V2 is not enabled yet and eFuse digest keys are not set
I (125) secure_boot_v2: Verifying with RSA-PSS...
I (127) secure_boot_v2: Signature verified successfully!
I (127) secure_boot_v2: Secure boot digests absent, generating..
I (141) secure_boot_v2: Digests successfully calculated, 1 valid signatures (image offset 0x0)
I (141) secure_boot_v2: 1 signature block(s) found appended to the bootloader.
I (142) secure_boot_v2: Burning public key hash to eFuse
I (143) efuse: Writing EFUSE_BLK_KEY0 with purpose 9
I (208) secure_boot_v2: Digests successfully calculated, 1 valid signatures (image offset 0x20000)
I (209) secure_boot_v2: 1 signature block(s) found appended to the app.
I (210) secure_boot_v2: Application key(0) matches with bootloader key(0).
I (210) secure_boot_v2: Revoking empty key digest slot (1)...
I (211) secure_boot_v2: Revoking empty key digest slot (2)...
I (211) secure_boot_v2: blowing secure boot efuse...
I (212) secure_boot: Enabling Security download mode...
I (212) secure_boot: Disable hardware & software JTAG...
I (215) efuse: BURN BLOCK4
I (236) efuse: BURN BLOCK4 - OK (write block == read block)
I (236) efuse: BURN BLOCK0
I (256) efuse: BURN BLOCK0 - OK (all write block bits are set)
I (259) efuse: Batch mode. Prepared fields are committed
I (259) secure_boot_v2: Secure boot permanently enabled
I (260) boot: Checking flash encryption...
I (263) efuse: Batch mode of writing fields is enabled
I (264) flash_encrypt: Generating new flash encryption key...
I (265) efuse: Writing EFUSE_BLK_KEY1 with purpose 4
I (266) flash_encrypt: Disable UART bootloader encryption...
I (266) flash_encrypt: Disable UART bootloader cache...
I (266) flash_encrypt: Disable JTAG...
I (267) efuse: BURN BLOCK5
I (293) efuse: BURN BLOCK5 - OK (write block == read block)
I (293) efuse: BURN BLOCK0
I (313) efuse: BURN BLOCK0 - OK (all write block bits are set)
I (316) efuse: Batch mode. Prepared fields are committed
I (316) esp_image: segment 0: paddr=00000020 vaddr=3fcd5990 size=03b48h ( 15176) 
I (321) esp_image: segment 1: paddr=00003b70 vaddr=403cc710 size=00b9ch (  2972) 
I (322) esp_image: segment 2: paddr=00004714 vaddr=403ce710 size=05b78h ( 23416) 
I (329) esp_image: Verifying image signature...
I (331) secure_boot_v2: Verifying with RSA-PSS...
I (333) secure_boot_v2: Signature verified successfully!
I (479) flash_encrypt: bootloader encrypted successfully
I (492) flash_encrypt: partition table encrypted and loaded successfully
I (493) flash_encrypt: Encrypting partition 1 at offset 0x14000 (length 0x1000)...
I (505) flash_encrypt: Done encrypting
I (505) esp_image: segment 0: paddr=00020020 vaddr=3c030020 size=0c1d8h ( 49624) map
I (518) esp_image: segment 1: paddr=0002c200 vaddr=3fc8b600 size=01548h (  5448) 
I (520) esp_image: segment 2: paddr=0002d750 vaddr=40380000 size=028c8h ( 10440) 
I (524) esp_image: segment 3: paddr=00030020 vaddr=42000020 size=21034h (135220) map
I (558) esp_image: segment 4: paddr=0005105c vaddr=403828c8 size=08c84h ( 35972) 
I (567) esp_image: segment 5: paddr=00059ce8 vaddr=00000000 size=062e8h ( 25320) 
I (574) esp_image: Verifying image signature...
I (575) secure_boot_v2: Verifying with RSA-PSS...
I (577) secure_boot_v2: Signature verified successfully!
I (577) flash_encrypt: Encrypting partition 2 at offset 0x20000 (length 0x100000)...
I (3532) flash_encrypt: Done encrypting
I (3532) flash_encrypt: Encrypting partition 3 at offset 0x120000 (length 0x1000)...
I (3544) flash_encrypt: Done encrypting
I (3545) flash_encrypt: Setting CRYPT_CNT for permanent encryption
I (3548) efuse: BURN BLOCK0
I (3568) efuse: BURN BLOCK0 - OK (all write block bits are set)
I (3573) flash_encrypt: Flash encryption completed
I (3574) boot: Resetting with flash encryption enabled...
ESP-ROM:esp32c3-api1-20210207
Build:Feb  7 2021
rst:0x3 (RTC_SW_SYS_RST),boot:0x8 (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:1
Valid secure boot key blocks: 0
secure boot verification succeeded
load:0x3fcd5990,len:0x3b48
load:0x403cc710,len:0xb9c
load:0x403ce710,len:0x5b78
entry 0x403cc71a
I (3657) boot: ESP-IDF v5.3-dev-2547-g8b3821ca67 2nd stage bootloader
I (3658) boot: compile time Mar 14 2024 15:09:57
I (3662) boot: chip revision: v0.3
I (3664) boot.esp32c3: SPI Speed      : 80MHz
I (3664) boot.esp32c3: SPI Mode       : SLOW READ
I (3665) boot.esp32c3: SPI Flash Size : 2MB
I (3668) boot: Enabling RNG early entropy source...
I (3673) boot: Partition Table:
I (3673) boot: ## Label            Usage          Type ST Offset   Length
I (3674) boot:  0 nvs              WiFi data        01 02 0000e000 00006000
I (3674) boot:  1 storage          Unknown data     01 ff 00014000 00001000
I (3675) boot:  2 factory          factory app      00 00 00020000 00100000
I (3675) boot:  3 nvs_key          NVS keys         01 04 00120000 00001000
I (3676) boot:  4 custom_nvs       WiFi data        01 02 00121000 00006000
I (3676) boot: End of partition table
I (3678) esp_image: segment 0: paddr=00020020 vaddr=3c030020 size=0c1d8h ( 49624) map
I (3694) esp_image: segment 1: paddr=0002c200 vaddr=3fc8b600 size=01548h (  5448) load
I (3698) esp_image: segment 2: paddr=0002d750 vaddr=40380000 size=028c8h ( 10440) load
I (3704) esp_image: segment 3: paddr=00030020 vaddr=42000020 size=21034h (135220) map
I (3741) esp_image: segment 4: paddr=0005105c vaddr=403828c8 size=08c84h ( 35972) load
I (3752) esp_image: segment 5: paddr=00059ce8 vaddr=00000000 size=062e8h ( 25320) 
I (3761) esp_image: Verifying image signature...
I (3765) secure_boot_v2: Verifying with RSA-PSS...
I (3767) secure_boot_v2: Signature verified successfully!
I (3768) boot: Loaded app from partition at offset 0x20000
I (3769) secure_boot_v2: enabling secure boot v2...
I (3769) secure_boot_v2: secure boot v2 is already enabled, continuing..
I (3770) boot: Checking flash encryption...
I (3770) flash_encrypt: flash encryption is enabled (0 plaintext flashes left)
I (3771) boot: Disabling RNG early entropy source...
I (3776) cpu_start: Unicore app
I (3802) cpu_start: Pro cpu start user code
I (3802) cpu_start: cpu freq: 160000000 Hz
I (3803) app_init: Application information:
I (3803) app_init: Project name:     security
I (3803) app_init: App version:      26b03ca
I (3803) app_init: Compile time:     Mar 14 2024 15:09:53
I (3803) app_init: ELF file SHA256:  5ed173a2f...
I (3804) app_init: ESP-IDF:          v5.3-dev-2547-g8b3821ca67
I (3804) efuse_init: Min chip rev:     v0.3
I (3804) efuse_init: Max chip rev:     v1.99 
I (3804) efuse_init: Chip rev:         v0.3
I (3805) heap_init: Initializing. RAM available for dynamic allocation:
I (3806) heap_init: At 3FC8DCD0 len 00032330 (200 KiB): RAM
I (3806) heap_init: At 3FCC0000 len 0001C710 (113 KiB): Retention RAM
I (3806) heap_init: At 3FCDC710 len 00002950 (10 KiB): Retention RAM
I (3806) heap_init: At 50000010 len 00001FD8 (7 KiB): RTCRAM
I (3815) spi_flash: detected chip: gd
I (3815) spi_flash: flash io: dio
W (3816) spi_flash: Detected size(4096k) larger than the size in the binary image header(2048k). Using the size in the binary image header.
I (3817) flash_encrypt: Flash encryption mode is RELEASE
I (3820) nvs_sec_provider: NVS Encryption - Registering HMAC-based scheme...
I (3821) sleep: Configure to isolate all GPIO pins in sleep state
I (3822) sleep: Enable automatic switching of GPIO sleep configuration
I (3827) main_task: Started on CPU0
I (3827) main_task: Calling app_main()

Example to check Flash Encryption status
This is esp32c3 chip with 1 CPU core(s), WiFi/BLE, silicon revision v0.3, 2MB external flash
FLASH_CRYPT_CNT eFuse value is 7
Flash encryption feature is enabled in RELEASE mode
Erasing partition "storage" (0x1000 bytes)
Writing data with esp_partition_write:
I (3827) example: 0x3fc8fa00   00 01 02 03 04 05 06 07  08 09 0a 0b 0c 0d 0e 0f  |................|
I (3827) example: 0x3fc8fa10   10 11 12 13 14 15 16 17  18 19 1a 1b 1c 1d 1e 1f  |................|
Reading with esp_partition_read:
I (3837) example: 0x3fc8fa20   00 01 02 03 04 05 06 07  08 09 0a 0b 0c 0d 0e 0f  |................|
I (3837) example: 0x3fc8fa30   10 11 12 13 14 15 16 17  18 19 1a 1b 1c 1d 1e 1f  |................|
Reading with esp_flash_read:
I (3837) example: 0x3fc8fa20   75 75 ca b0 e6 09 a7 c1  bd c0 8a 08 e3 24 25 47  |uu...........$%G|
I (3837) example: 0x3fc8fa30   a5 e7 94 b4 04 1e 55 d5  ff 04 c9 b8 55 a7 0a 7f  |......U.....U...|
I (3847) nvs: NVS partition "nvs" is encrypted.
I (3857) example: NVS partition "custom_nvs" is encrypted.
I (3857) main_task: Returned from app_main()
```

You can terminate the QEMU session, using *control+A* and then pressing *X.*

__Just to verify__ :

As we have selected Flash Encryption Release mode, if you try checking out the eFuses summary by running QEMU in the download mode, you will come across the following error:

```
A fatal error occurred: Secure Download Mode is enabled. The tool can not read eFuses.
```

As you have the eFuses file with yourself, you can always modify it, and this opens a lot of possibilities to test your firmware with different eFuses combinations.

## Future Work

Currently, you can quickly try out any ESP-IDF (master branch) based application using QEMU by just running the command idf.py qemu. This command handles all the intermediary steps like generation of eFuses file and the merged binary. But as of now it does not support using a pre-programmed eFuses file, instead it creates a new one for every instance of the run. We are trying to support usage of pre-programmed eFuses file as this will surely increase the user experience of using the emulator approach for such use-cases.

## Summary

Thus, we have seen that the emulator approach surely provides an advantage to iterate over and debug various security configurations and speed up the testing process to finally develop a production-ready configuration that can be tested on the real hardware, without the risk of bricking it due to any misconfigurations.

In part 2 of this blog, we would go through the host-based workflow for enabling the security features using QEMU.

Till then, in case you are unsure about the boot loader boot workflow to enable security features, you could safely try it out using ESP32-C3 QEMU first to avoid any hardware damage.

We are actively working to enable support for any other remaining peripherals of an ESP32-C3 as well, do let us know your feedback and if you come across any issues, feel free to open a discussion/issue at our GitHub repository.
