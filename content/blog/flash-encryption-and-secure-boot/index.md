---
title: "【ESP32-S3】Use ESP Flash Download Tool to finish the Flash Encryption + Secure Boot + NVS Encryption"
date: 2024-08-15T18:00:17+08:00
showAuthor: false
authors:
  - "Cai Guanhong"
tags: ["ESP32-S3", "ESP-IDF", "Flash Encryption", "Secure Boot", "NVS Encryption"]
---


## Introduction

This document records the implementation of "[Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption) + [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2) + [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption)" functions on the ESP32-S3 using the [Flash Download Tool](https://www.espressif.com/en/support/download/other-tools?keys=flash).

### Overview of [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption)

[Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption)  is used to encrypted the firmware in the external Flash chip used with ESP32 series products, which can protect the security of applications firmware. For more instructions, please read the [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption) user guide.


### Products that Support `Flash Encryption`

| Chip | Supported Key Types |
|--|--|
| [ESP32](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32/security/flash-encryption.html#flash)       | XTS_AES_128               |
| [ESP32-S2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s2/security/flash-encryption.html#flash)  | XTS_AES_128 & XTS_AES_256 |
| [ESP32-S3](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash)  | XTS_AES_128 & XTS_AES_256 |
| [ESP32-C2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32c2/security/flash-encryption.html#flash)  |    SHA256   & XTS_AES_128 |
| [ESP32-C3](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32c3/security/flash-encryption.html#flash)  | XTS_AES_128               |
| [ESP32-C6](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32c6/security/flash-encryption.html#flash)  | XTS_AES_128               |
| [ESP32-H2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32h2/security/flash-encryption.html#flash)  | XTS_AES_128               |


- Verify Flash  Encryption code：[esp-idf/components/bootloader_support/src/flash_encrypt.c](https://github.com/espressif/esp-idf/blob/v5.2.1/components/bootloader_support/src/flash_encrypt.c)

- Flash Encryption Test Example：[esp-idf/examples/security/flash_encryption](https://github.com/espressif/esp-idf/tree/v5.2.1/examples/security/flash_encryption)


### Overview of [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2)

Secure Boot protects a device from running any unauthorized (i.e., unsigned) code by checking that each piece of software that is being booted is signed. For more instructions, please read the [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2) user guide.


### Products that Support `Secure Boot`

|  Product  |  Secure Boot Version  |
|--|--|
| ESP32 ECO V3 and above versions |  [Secure Boot V1](https://docs.espressif.com/projects/esp-idf/en/release-v5.1/esp32/security/secure-boot-v1.html#secure-boot) & [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32/security/secure-boot-v2.html#secure-boot-v2) （ RSA-PSS ）|
| ESP32-S2 All versions | [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s2/security/secure-boot-v2.html#secure-boot-v2) （ RSA-PSS ）|
| ESP32-S3 All versions | [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2) （ RSA-PSS ）|
| ESP32-C2 All versions | [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32c2/security/secure-boot-v2.html#secure-boot-v2) （ ECDSA ）  |
| ESP32-C3 ECO V3 and above versions | [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32c3/security/secure-boot-v2.html#secure-boot-v2) （ RSA-PSS）|
| ESP32-C6 All versions | [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32c6/security/secure-boot-v2.html#secure-boot-v2) （RSA-PSS or ECDSA）     |
| ESP32-H2 All versions | [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32h2/security/secure-boot-v2.html#secure-boot-v2) （RSA-PSS or ECDSA）     |


### Overview of [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption)

NVS Encryption supports [HMAC Peripheral-Based Schem](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption-hmac-peripheral-based-scheme) and [Flash Encryption-Based Schemes](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption-flash-encryption-based-scheme). For more instructions, please read the [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption) user guide.

In this case, the [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption) is based on the [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption)  scheme. 




## Create a partition table for your project.

A single ESP chip's Flash can contain multiple apps, as well as many different kinds of data (calibration data, filesystems, parameter storage, etc). For this reason ， we need to create a partition table to plan the Flash space properly for our project. For partitioned table instructions, please read [Partition Tables](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-guides/partition-tables.html#partition-tables) user guide.

In this case, suppose the partition table setting as follows:

```c
# Name,   Type, SubType, Offset,   Size, Flags
# Note: if you have increased the bootloader size, make sure to update the offsets to avoid overlap
nvs,      data, nvs, 0x10000 , 0x4000 ,
otadata,  data, ota, 0x14000 , 0x2000 ,
phy_init, data, phy, 0x16000 , 0x1000 , encrypted
factory,  app,  factory, 0x20000 , 1M ,
ota_0,    app,  ota_0, 0x120000  , 1M ,
ota_1,    app,  ota_1, 0x220000  , 1M ,
nvs_key,  data, nvs_keys, 0x320000 , 0x1000 , encrypted
# Custom NVS data partition
custom_nvs, data, nvs, 0x321000    , 0x6000 ,
```

This partition table setting includes two `NVS` partitions, the default `nvs` and the `custom_nvs` partition.

- The default `nvs` partition is used to store per-device PHY calibration data (different to initialisation data) and store Wi-Fi data if the esp_wifi_set_storage(WIFI_STORAGE_FLASH) initialization function is used. As well as write data through the [nvs_set](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_flash.html#api) API on the software. This `nvs` partition does not need to download the corresponding `nvs.bin` when the firmware downloading. The default `nvs` partition will be `encrypted` while writing data to the `nvs` partition via the [nvs_set](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32s3/api-reference/storage/nvs_flash.html#api)  API (Note: The [nvs_get](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_flash.html#_CPPv410nvs_get_i812nvs_handle_tPKcP6int8_t) (read) API does not support NVS encryption).

- The `custom_nvs` partition can used to store multiple files which by the `custom_nvs.csv` file managed . The types of files that can be managed can refer to the [CSV File Format](https://docs.espressif.com/projects/esp-idf/en/release-v5.1/esp32/api-reference/storage/nvs_partition_gen.html#csv-file-format)  instructions. And the `custom_nvs.bin` needs to be `encrypted` with `nvs_key` and downloaded the `encrypt_custom_nvs.bin` to the `custom_nvs` partition. Use a `custom_nvs.csv` file to Manage multiple files as follows:

```c
key,type,encoding,value
server_cert,namespace,,
server_cert,file,binary,E:\esp\test\customized\server_cert\server_cert.crt
server_key,namespace,,
server_key,file,binary,E:\esp\test\customized\server_key\server.key
server_ca,namespace,,
server_ca,file,binary,E:\esp\test\customized\server_ca\server_ca.crt
```

You can also refer to [esp-idf/examples/storage/nvsgen](https://github.com/espressif/esp-idf/tree/v5.3/examples/storage/nvsgen) example. This example use a [nvs_data.csv](https://github.com/espressif/esp-idf/blob/v5.3/examples/storage/nvsgen/nvs_data.csv) file to manage some data to write in `nvs` partition.

With [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption) enabled, the following types of data are `encrypted` by default:

- [Second Stage Bootloader (Firmware Bootloader)](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-guides/startup.html#second-stage-bootloader)
- [Partition Table](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-guides/partition-tables.html#id1)
- [NVS Key Partition](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encr-key-partition)
- [Otadata](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/system/ota.html?highlight=ota#ota-data-partition)
- All [app type](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-guides/partition-tables.html#subtype) partitions

> The [NVS key partition](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encr-key-partition) (`nvs_key` partition) is used to store the `nvs_key`, and the `nvs_key` is used to encrypt the `nvs` type partitions. In this case ， they are default `nvs` partition and the `custom_nvs` partition.

Other types of data can be encrypted conditionally:

- Any partition marked with the `encrypted` flag in the partition table. For details, see [Encrypted Partition Flag](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#encrypted-partition-flag).
- If Secure Boot is enabled，the `public key digest` will be `encrypted`.

If you are using the ESP32 series chip and want to enable the  [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption) and [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2) and [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption) functions , from the perspective of mass production environment, we recommend using the [Flash Download Tool](https://www.espressif.com/en/support/download/other-tools?keys=flash) to complete all process.

Utilizing the [Flash Download Tool](https://www.espressif.com/en/support/download/other-tools?keys=flash) to complete the [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption) and [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2) and [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption) functions have the following advantages on the operational steps :

- Once the firmware download is completed, all the security and encrypted process are also finished.
- When the chip is powered on for the first time, it is will runing the `ciphertext firmware` directly.
- The risk of `Power Failure` or `Power Supply Instability` in security and encrypted processes can be avoided.

Using the  [Flash Download Tool](https://www.espressif.com/en/support/download/other-tools?keys=flash) to complete [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption) and [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2) and [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption) functions steps are as follows:

- First, you need to obtain the corresponding keys for Flash encryption and Secure boot and NVS encryption.
- Next, you need to enable the [Flash Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#flash-encryption) and [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2) and [NVS Encryption](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/storage/nvs_encryption.html#nvs-encryption) functions configuration option on the software and get the signed firmware.
- Then, if you need to download `custom_nvs.bin` when you download all firmware, you will also need to manually encrypt `custom_nvs.bin`.


## Obtain the different keys

## How to Obtain different types of [Flash Encryption Keys](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/flash-encryption.html#pregenerated-flash-encryption-key) ?

Users can use  [esptool](https://github.com/espressif/esptool) and running the `espsecure.py generate_flash_encryption_key` commands to generate the different types Flash Encryption keys . As follows:

> You can use `espsecure.py generate_flash_encryption_key --help` command to query the commands instructions.

- Running the follows command to generate the `SHA-256` key

```bash
espsecure.py generate_flash_encryption_key --keylen 128 flash_encrypt_key.bin
```

- Running the follows command to generate the  `AES-128` key

Please note:

- The Flash Download Tool only support `AES-128` key on ESP32-S3, so we recommend to use the `AES-128` key for ESP32-S3 Flash Encryption .

```bash
espsecure.py generate_flash_encryption_key flash_encrypt_key.bin
```

> When the `--keylen` parameter is not specified, It will generated the `AES-128` key by default

- Running the follows command to generate the   `AES-256` key

```bash
espsecure.py generate_flash_encryption_key --keylen 512 flash_encrypt_key.bin
```

### How to Obtain [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/host-based-security-workflows.html?highlight=secure_boot_signing_key%20pem#enable-secure-boot-v2-externally) key ?

Base on the `ESP32S3`  chip to enable [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2) function will requires a [rsa3072](https://docs.espressif.com/projects/esp-idf/zh_CN/release-v5.0/esp32/security/secure-boot-v2.html#generating-secure-boot-signing-key) type key.

Users can use the [esptool](https://github.com/espressif/esptool) ，and running the `espsecure.py generate_signing_key` command to generate the [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32s3/security/secure-boot-v2.html#secure-boot-v2)  key.

> You can use `espsecure.py generate_signing_key --help` command to query the commands instructions.

```bash
espsecure.py generate_signing_key secure_boot_signing_key.pem --version 2 --scheme rsa3072
```

Alternatively, you can also install the [OpenSSL](https://www.openssl.org/source/) environment and to generate an [RSA 3072 type private key for Secure Boot signing ](https://docs.espressif.com/projects/esp-idf/en/release-v5.1/esp32s3/security/secure-boot-v2.html#generating-secure-boot-signing-key) with the following command:

```bash
openssl genrsa -out secure_boot_signing_key.pem 3072
```

### How to Obtain [Secure Boot V2](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/security/host-based-security-workflows.html?highlight=secure_boot_signing_key%20pem#enable-secure-boot-v2-externally) public key digest?

When enable Secure Boot V2 function on  [Flash Download Tool](https://www.espressif.com/en/support/download/other-tools?keys=flash)  ， you need to add the Secure Boot V2 Key Digest. So you need to base on the Secure Boot V2 Key to generate the digest of the `public key`.  Please see: [Enable Secure Boot V2 Externally](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.2.1/esp32/security/host-based-security-workflows.html?highlight=secure_boot_signing_key%20pem#enable-secure-boot-v2-externally).

> You can use `espsecure.py digest_rsa_public_key --help` command to query the commands instructions.

For example:

```bash
espsecure.py digest_rsa_public_key --keyfile secure_boot_signing_key.pem --output public_key_digest.bin
```

### How to Obtain `nvs_key` ?

You can use the `nvs partition tool` （[esp-idf/components/nvs_flash/nvs_partition_generator](https://github.com/espressif/esp-idf/tree/v5.1.2/components/nvs_flash/nvs_partition_generator)）and running the `nvs_partition_gen.py`  command to obtain the `nvs_key` file. 

> You can use `nvs_partition_gen.py --help` command to query the commands instructions.

For example:

```bash
python E:\esp\Espressif\frameworks\esp-idf-5.2.1\esp-idf\components\nvs_flash\nvs_partition_generator\nvs_partition_gen.py generate-key --keyfile nvs_key.bin
```

### How to use `nvs_key` to encrypt the `custom_nvs.csv` file ?

If you need to download `custom_nvs.bin` when you download all firmware, you also need to manually encrypt `custom_nvs.bin` use `nvs_key`. You can running the follows command to use `nvs_key.bin` to encrypt the `custom_nvs.csv`  file and get the encrypted `encrypt_custom_nvs.bin`.

For example:

```bash
python E:\esp\Espressif\frameworks\esp-idf-5.2.1\esp-idf\components\nvs_flash\nvs_partition_generator\nvs_partition_gen.py encrypt custom_nvs.csv encrypt_custom_nvs.bin 0x6000 --inputkey keys\nvs_key.bin
```

> - `0x6000` is size of `encrypt_custom_nvs.bin` firmware

## Software Configuration

On the Software Configuration，you need to enable `Flash Encryption` and `Secure Boot V2` and `NVS  Encryption` setting.

`idf.py menuconfig → Security features`
  
- Enable Seucre Boot 
    [*] Enable hardware Secure Boot in bootloader (READ DOCS FIRST)
        Select secure boot version (Enable Secure Boot version 2)  --->
    [*] Sign binaries during build (NEW)
    (secure_boot_signing_key.pem) Secure boot private signing key (NEW) 

![Enable Secure Boot V2](./img/enable-secure-boot.webp "Enable Secure Boot V2")

Please note you need to add the `secure_boot_signing_key.pem` path.

- Enable Flash Encryption
    [*] Enable flash encryption on boot (READ DOCS FIRST) 
        Size of generated XTS-AES key (AES-128 (256-bit key))  ---> 
        Enable usage mode (Release)  ---> 
    [*] Encrypt only the app image that is present in the partition of type app (NEW) 
    [*] Check Flash Encryption enabled on app startup (NEW) 
        UART ROM download mode (UART ROM download mode (Enabled (not recommended)))  --->

![Enable Flash Encryption](./img/enable-flash-encryption.webp "Enable Flash Encryption")

- `Flash Encryption` support `Release` or `Development (NOT SECURE)` mode.
    - When select the Flash Encryption `Release` mode, It is will setting the `SPI_BOOT_CRYPT_CNT` eFuse bit to `0b111`. The `Release` mode is recommended for mass production.
	- When select the Flash Encryption `Development (NOT SECURE)` mode, It is will setting the `SPI_BOOT_CRYPT_CNT` eFuse bit to `0b001`.  If select the  `Development (NOT SECURE)` mode, the chip support provides one chance for disable Flash encryption . After enabled  Flash Encryption `Development (NOT SECURE)` mode, if you want to disable the Flash Encryption , you can running the follows command to disable the Flash Encryption.

    ```bash
	espefuse.py -p port burn_efuse SPI_BOOT_CRYPT_CNT 0x3
	```

    - Because of the Flash Download Tool only support AES-128 on ESP32-S3, so select the AES-128 key on the software.
    - At the same time, please pay attention to the `UART ROM download mode`  setting. If you do not want to disable the download mode, it is recommended to select `UART ROM download mode (Enabled (not recommended))`  configuration. Different download modes configuration options instructions can refer to [CONFIG_SECURE_UART_ROM_DL_MODE](https://docs.espressif.com/projects/esp-idf/en/v5.2.1/esp32s3/api-reference/kconfig.html#config-secure-uart-rom-dl-mode) instructions.

- Enable NVS Encryption

    `idf.py menuconfig → Component config → NVS`
    [*] Enable NVS encryption 

![Enable NVS Encryption](./img/nvs-encryption.webp "Enable NVS Encryption")

## Increase the partition table offset

Since the Flash Encryption and Secure Boot V2 function will increase the size of the bootloader firmware, so you need to increase the partition table offset(Default is `0x8000`) setting. As follows:

`idf.py menuconfig → Partition Table → (0xF000) Offset of partition table`

![Increase Partition Table Offset](./img/partition-table-offset.webp "Increase Partition Table Offset")


## Compile the project to get the compiled firmware

Then , you need compile the project to get the compiled firmware.

```bash
idf.py build
```

Because of the secure boot function is enabled. After compiled , you will get the `bootloader.bin` and `bootloader-unsigned.bin` and `app.bin` and `app-unsigned.bin` and other partition firmware bin files. The `bootloader.bin` and `app.bin` are signed firmware. The `bootloader-unsigned.bin` and `app-unsigned.bin` are unsigned firmware. We need to downlaod the signed firmware and other partition firmware bin files.

From the compilation completion log, you can see the firmware path and firmware download address. The firmware and firmware download address are need to be imported to the Flash Download tool . As follows:

![Firmware Offset Adress](./img/firmware-offset-address.webp "Firmware Offset Address")

![Firmware PATH](./img/firmware-path.webp "Firmware PATH")


## [Flash Download Tools](https://www.espressif.com/en/support/download/other-tools?keys=flash)   Configuration

Put the `Flash Encryption Key` and the `digest of the Secure boot V2 public key` into the `flash_download_tool\secure` directory. As follows：

![Secure Keys](./img/secure-keys.webp "Secure Keys")

In the `configure\esp32s3\security.conf` configuration file of the [Flash Download Tool](https://www.espressif.com/en/support/download/other-tools?keys=flash) , enable the `Flash Encryption` and `Secure Boot V2` configuration option . 

![Security Config File](./img/flash-security-config-file.webp "Security Config File")

The security configurations to be modified are as follows:

```c
[SECURE BOOT]
secure_boot_en = True                                    \\ Enable Secure Boot         
public_key_digest_path = .\bin\public_key_digest.bin     \\ Setting public_key_digest.bin path for Secure Boot
public_key_digest_block_index = 0                        \\ Index of the eFuse block where the public key digest file is stored. Default: 0.

[FLASH ENCRYPTION]
flash_encryption_en = True                               \\ Enable Flash Encryption
reserved_burn_times = 0                                  \\ Configures how many times [0 in this case when config Flash Encryption Release mode on the software] are reserved for the flashing operation
flash_encrypt_key_block_index = 1                     \\ Index of the eFuse block where the Flash Encrypt Key file is stored. Default: 0. Range: 0~4. Note that this option can only be set to 0 for ESP32-C2. 

[SECURE OTHER CONFIG]
flash_encryption_use_customer_key_enable = True          \\ Configures whether to enable the use of a customer-specified encryption key
flash_encryption_use_customer_key_path = .\bin\flash_encrypt_key.bin          \\ Setting customer-specified Flash Encryption key file path
flash_force_write_enable = True                          \\ Configures whether to skip encryption and secure boot checks during flashing. If it is set to False (default), an error message may pop up when attempting to flash products with enabled flash encryption or secure boot.

[FLASH ENCRYPTION KEYS LOCAL SAVE]
keys_save_enable = False
encrypt_keys_enable = False
encrypt_keys_aeskey_path = 

// On the first boot, the flash encryption process burns by default the following eFuses:

[ESP32S3 EFUSE BIT CONFIG]
dis_usb_jtag = True                       \\ Configures whether to disable USB JTAG
hard_dis_jtag = True                      \\ Configures whether to hard-disable JTAG
soft_dis_jtag = 7                         \\ Configures whether to soft-disable JTAG
dis_usb_otg_download_mode = False         \\ Configures whether to disable USB OTG download
dis_direct_boot = True                    \\ Configures whether to disable direct boot mode
dis_download_icache = True                \\ Configures whether to disable the entire MMU flash instruction cache when running in UART bootloader mode
dis_download_dcache = True                \\ Configures whether to disable the entire MMU flash data cache in the UART bootloader mode
dis_download_manual_encrypt = True        \\ Configures whether to disable flash encryption operation when running in UART bootloader boot mode
```

## Restart the [Flash Download Tools](https://www.espressif.com/en/support/download/other-tools?keys=flash)  

After restart the [Flash Download Tools](https://www.espressif.com/en/support/download/other-tools?keys=flash) ，it is will read the  `configure\esp32s3\security.conf`  configuration informations. As follows：

![Flash Download Tool Boot Security Config](./img/flash-download-tool-boot-security-config.webp "Flash Download Tool Boot Security Config")


## Import all firmware to be Downloaded

According to partition table setting, add all the firmware and firmware downloade address . As follows:

![Add Bin Files](./img/bin-file.webp "Add Bin Files")

## Downloading all firmware

The Flash download tool will write the `Flash encryption key`  and  `Secure boot V2 Key public key digest` to the chip `eFuse BLOCK` during the firmware downloading process.
- And wirting the（`SPI_BOOT_CRYPT_CNT`） eFuse bit to enable `Flash Encryption` and writing the `SECURE_BOOT_EN` eFuse bit to enable `Secure Boot V2`.
- Then writing all （`configure\esp32s3\security.conf` ）`[ESP32S3 EFUSE BIT CONFIG]` configuration setting to chip eFuse. As follows log from black box :

```c
test offset :  0 0x0
case ok
test offset :  61440 0xf000
case ok
test offset :  81920 0x14000
case ok
test offset :  90112 0x16000
case ok
test offset :  131072 0x20000
case ok
test offset :  3276800 0x320000
case ok
test offset :  3280896 0x321000
case ok
.
Uploading stub...
Running stub...
Stub running...
Changing baud rate to 115200
Changed.
NO XMC flash  detected!
SPI_BOOT_CRYPT_CNT 0
SECURE_BOOT_EN False
ESP32 secure boot v2 skip generate key
Encrypting bin file ...please wait!!!
Using 256-bit key
Encrypting bin file ...please wait!!!
Using 256-bit key
Encrypting bin file ...please wait!!!
Using 256-bit key
Encrypting bin file ...please wait!!!
Using 256-bit key
Encrypting bin file ...please wait!!!
Using 256-bit key
Encrypting bin file ...please wait!!!
Using 256-bit key
Encrypting bin file ...please wait!!!
Using 256-bit key
burn secure key ...
Burn keys to blocks:
 - BLOCK_KEY1 -> [5f 4d 93 00 10 24 fd c4 3e ff 04 49 53 e2 88 83 c0 bc 2b d6 7e f1 81 0e f6 84 cd b7 0b 72 ae df]
        Reversing byte order for AES-XTS hardware peripheral
        'KEY_PURPOSE_1': 'USER' -> 'XTS_AES_128_KEY'.
        Disabling write to 'KEY_PURPOSE_1'.
        Disabling read to key block
        Disabling write to key block

 - BLOCK_KEY0 -> [c3 f6 4b 2e 84 92 f1 fc 86 d0 17 17 fe 62 04 6f e0 83 17 36 19 1a f4 9e 86 df e5 50 74 44 86 bf]
        'KEY_PURPOSE_0': 'USER' -> 'SECURE_BOOT_DIGEST0'.
        Disabling write to 'KEY_PURPOSE_0'.
        Disabling write to key block


Check all blocks for burn...
idx, BLOCK_NAME,          Conclusion
[00] BLOCK0               is not empty
        (written ): 0x0000000000000000000000000000d1f50000000000000000
        (to write): 0x000000000000000000000000490000000000000201800300
        (coding scheme = NONE)
[04] BLOCK_KEY0           is empty, will burn the new value
[05] BLOCK_KEY1           is empty, will burn the new value
.
This is an irreversible operation!
BURN BLOCK5  - OK (write block == read block)
BURN BLOCK4  - OK (write block == read block)
BURN BLOCK0  - OK (all write block bits are set)
Reading updated efuses...
Successful
The efuses to burn:
  from BLOCK0
     - SPI_BOOT_CRYPT_CNT
     - SECURE_BOOT_EN

Burning efuses:

    - 'SPI_BOOT_CRYPT_CNT' (Enables flash encryption when 1 or 3 bits are set and disabled otherwise) 0b000 -> 0b111

    - 'SECURE_BOOT_EN' (Set this bit to enable secure boot) 0b0 -> 0b1


Check all blocks for burn...
idx, BLOCK_NAME,          Conclusion
[00] BLOCK0               is not empty
        (written ): 0x0000000000000000000000004900d1f50000000201800300
        (to write): 0x000000000000000000100000001c00000000000000000000
        (coding scheme = NONE)
.
This is an irreversible operation!
BURN BLOCK0  - OK (all write block bits are set)
Reading updated efuses...
Checking efuses...
Successful

WARNING: - compress and encrypt options are mutually exclusive
Will flash uncompressed

 is stub and send flash finish
The efuses to burn:
  from BLOCK0
     - DIS_USB_JTAG
     - DIS_PAD_JTAG
     - SOFT_DIS_JTAG
     - DIS_DIRECT_BOOT
     - DIS_DOWNLOAD_ICACHE
     - DIS_DOWNLOAD_DCACHE
     - DIS_DOWNLOAD_MANUAL_ENCRYPT

Burning efuses:

    - 'DIS_USB_JTAG' (Set this bit to disable function of usb switch to jtag in module of usb device) 0b0 -> 0b1

    - 'DIS_PAD_JTAG' (Set this bit to disable JTAG in the hard way. JTAG is disabled permanently) 0b0 -> 0b1

    - 'SOFT_DIS_JTAG' (Set these bits to disable JTAG in the soft way (odd number 1 means disable ). JTAG can be enabled in HMAC module) 0b000 -> 0b111

    - 'DIS_DIRECT_BOOT' (Disable direct boot mode) 0b0 -> 0b1

    - 'DIS_DOWNLOAD_ICACHE' (Set this bit to disable Icache in download mode (boot_mode[3:0] is 0; 1; 2; 3; 6; 7)) 0b0 -> 0b1

    - 'DIS_DOWNLOAD_DCACHE' (Set this bit to disable Dcache in download mode ( boot_mode[3:0] is 0; 1; 2; 3; 6; 7)) 0b0 -> 0b1

    - 'DIS_DOWNLOAD_MANUAL_ENCRYPT' (Set this bit to disable flash encryption when in download boot modes) 0b0 -> 0b1


Check all blocks for burn...
idx, BLOCK_NAME,          Conclusion
[00] BLOCK0               is not empty
        (written ): 0x000000000000000000100000491cd1f50000000201800300
        (to write): 0x00000000000000020040000000000000001f0c0000000000
        (coding scheme = NONE)
.
This is an irreversible operation!
BURN BLOCK0  - OK (all write block bits are set)
Reading updated efuses...
Checking efuses...
Successful
```

After the firmware is downloaded, all the Flash Encryption and Secure Boot V2 process are completed. The firmware download process will complete the following process:

- Writing the  `Secure boot V2 Key public key digest`  to chip eFuse `BLOCK_KEY0 （KEY_PURPOSE_0）`
- Writing the  `Flash Encryption key`  to chip eFuse `BLOCK_KEY1 （KEY_PURPOSE_1）`
- Wirting the（`SPI_BOOT_CRYPT_CNT`） eFuse bit to `0b111`
- Writing the `SECURE_BOOT_EN` eFuse bit to `0b1`
- Writing the `DIS_USB_JTAG`  eFuse bit to `0b1`
- Writing the `DIS_PAD_JTAG` eFuse bit to `0b1`
- Writing the `SOFT_DIS_JTAG` eFuse bit to `0b111`
- Writing the `DIS_DIRECT_BOOT` eFuse bit to `0b1`
- Writing the `DIS_DOWNLOAD_ICACHE` eFuse bit to `0b1`
- Writing the `DIS_DOWNLOAD_DCACHE` eFuse bit to `0b1`
- Writing the `DIS_DOWNLOAD_MANUAL_ENCRYPT` eFuse bit to `0b1`

## Running the Firmware

Upon the first power-up startup, the firmware will :
  - Check whether the Secure Boot V2 feature is enabled
  - Check whether the Flash Encryption feature is enabled
  - Check whether the NVS Encryption feature is enabled
  - Then，verify Signed and Encrypted firmware
  - If the verification succeeds, the firmware will running normally

### The firmware running log at the first time as following:

```c
ESP-ROM:esp32s3-20210327
Build:Mar 27 2021
rst:0x1 (POWERON),boot:0x8 (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:1
Valid secure boot key blocks: 0
secure boot verification succeeded
load:0x3fce3980,len:0x3a1c
load:0x403c9700,len:0x4
load:0x403c9704,len:0xcbc
load:0x403cc700,len:0x52a0
entry 0x403c9914
I (73) boot: ESP-IDF v5.2.2-520-g9d6583f763 2nd stage bootloader
I (73) boot: compile time Aug 16 2024 15:58:33
I (74) boot: Multicore bootloader
I (78) boot: chip revision: v0.1
I (81) boot.esp32s3: Boot SPI Speed : 80MHz
I (86) boot.esp32s3: SPI Mode       : DIO
I (91) boot.esp32s3: SPI Flash Size : 8MB
I (96) boot: Enabling RNG early entropy source...
I (101) boot: Partition Table:
I (105) boot: ## Label            Usage          Type ST Offset   Length
I (112) boot:  0 nvs              WiFi data        01 02 00010000 00004000
I (120) boot:  1 otadata          OTA data         01 00 00014000 00002000
I (127) boot:  2 phy_init         RF data          01 01 00016000 00001000
I (135) boot:  3 factory          factory app      00 00 00020000 00100000
I (142) boot:  4 ota_0            OTA app          00 10 00120000 00100000
I (150) boot:  5 ota_1            OTA app          00 11 00220000 00100000
I (157) boot:  6 nvs_key          NVS keys         01 04 00320000 00001000
I (165) boot:  7 custom_nvs       WiFi data        01 02 00321000 00006000
I (173) boot: End of partition table
I (177) boot: Defaulting to factory image
I (182) esp_image: segment 0: paddr=00020020 vaddr=3c090020 size=20e68h (134760) map
I (217) esp_image: segment 1: paddr=00040e90 vaddr=3fc98700 size=047f8h ( 18424) load
I (221) esp_image: segment 2: paddr=00045690 vaddr=40374000 size=0a988h ( 43400) load
I (233) esp_image: segment 3: paddr=00050020 vaddr=42000020 size=81db8h (531896) map
I (339) esp_image: segment 4: paddr=000d1de0 vaddr=4037e988 size=09cd0h ( 40144) load
I (349) esp_image: segment 5: paddr=000dbab8 vaddr=00000000 size=04518h ( 17688)
I (353) esp_image: Verifying image signature...
I (354) secure_boot_v2: Verifying with RSA-PSS...
I (360) secure_boot_v2: Signature verified successfully!
I (371) boot: Loaded app from partition at offset 0x20000
I (371) secure_boot_v2: enabling secure boot v2...
I (374) secure_boot_v2: secure boot v2 is already enabled, continuing..
I (382) boot: Checking flash encryption...
I (386) flash_encrypt: flash encryption is enabled (0 plaintext flashes left)
I (394) boot: Disabling RNG early entropy source...
I (411) cpu_start: Multicore app
I (421) cpu_start: Pro cpu start user code
I (421) cpu_start: cpu freq: 160000000 Hz
I (421) cpu_start: Application information:
I (424) cpu_start: Project name:     wifi_softAP
I (430) cpu_start: App version:      v5.2.2-520-g9d6583f763
I (436) cpu_start: Compile time:     Aug 16 2024 15:58:16
I (442) cpu_start: ELF file SHA256:  d89b197be...
Warning: checksum mismatch between flashed and built applications. Checksum of built application is 6d559abf84b1d704bc99214866ff8708cf910cc472ec5ec9ca1557ca7d430710
I (447) cpu_start: ESP-IDF:          v5.2.2-520-g9d6583f763
I (454) cpu_start: Min chip rev:     v0.0
I (458) cpu_start: Max chip rev:     v0.99
I (463) cpu_start: Chip rev:         v0.1
I (468) heap_init: Initializing. RAM available for dynamic allocation:
I (475) heap_init: At 3FCA0AF8 len 00048C18 (291 KiB): RAM
I (481) heap_init: At 3FCE9710 len 00005724 (21 KiB): RAM
I (487) heap_init: At 3FCF0000 len 00008000 (32 KiB): DRAM
I (494) heap_init: At 600FE010 len 00001FD8 (7 KiB): RTCRAM
I (501) spi_flash: detected chip: generic
I (504) spi_flash: flash io: dio
I (509) flash_encrypt: Flash encryption mode is RELEASE
I (515) efuse: Batch mode of writing fields is enabled
W (520) secure_boot: Unused SECURE_BOOT_DIGEST1 should be revoked. Fixing..
W (528) secure_boot: Unused SECURE_BOOT_DIGEST2 should be revoked. Fixing..
I (536) efuse: BURN BLOCK0
I (541) efuse: BURN BLOCK0 - OK (all write block bits are set)
I (546) efuse: Batch mode. Prepared fields are committed
I (551) secure_boot: Fixed
I (555) nvs_sec_provider: NVS Encryption - Registering Flash encryption-based scheme...
I (564) sleep: Configure to isolate all GPIO pins in sleep state
I (570) sleep: Enable automatic switching of GPIO sleep configuration
I (578) main_task: Started on CPU0
I (588) main_task: Calling app_main()
I (628) nvs: NVS partition "nvs" is encrypted.
I (628) wifi softAP: ESP_WIFI_MODE_AP
I (628) pp: pp rom version: e7ae62f
I (628) net80211: net80211 rom version: e7ae62f
I (658) wifi:wifi driver task: 3fcaae94, prio:23, stack:6656, core=0
I (658) wifi:wifi firmware version: e60360a19
I (658) wifi:wifi certification version: v7.0
I (658) wifi:config NVS flash: enabled
I (658) wifi:config nano formating: disabled
I (668) wifi:Init data frame dynamic rx buffer num: 32
I (668) wifi:Init static rx mgmt buffer num: 5
I (678) wifi:Init management short buffer num: 32
I (678) wifi:Init dynamic tx buffer num: 32
I (678) wifi:Init static tx FG buffer num: 2
I (688) wifi:Init static rx buffer size: 1600
I (688) wifi:Init static rx buffer num: 10
I (698) wifi:Init dynamic rx buffer num: 32
I (698) wifi_init: rx ba win: 6
I (698) wifi_init: tcpip mbox: 32
I (708) wifi_init: udp mbox: 6
I (708) wifi_init: tcp mbox: 6
I (708) wifi_init: tcp tx win: 5760
I (718) wifi_init: tcp rx win: 5760
I (718) wifi_init: tcp mss: 1440
I (728) wifi_init: WiFi IRAM OP enabled
I (728) wifi_init: WiFi RX IRAM OP enabled
I (1258) phy_init: phy_version 680,a6008b2,Jun  4 2024,16:41:10
W (1258) phy_init: failed to load RF calibration data (0x1102), falling back to full calibration
W (1318) phy_init: saving new calibration data because of checksum failure, mode(2)
I (1338) wifi:mode : softAP (68:b6:b3:4e:3f:f1)
I (1388) wifi:Total power save buffer number: 16
I (1388) wifi:Init max length of beacon: 752/752
I (1398) wifi:Init max length of beacon: 752/752
I (1398) wifi softAP: wifi_init_softap finished. SSID:myssid password:mypassword channel:1
I (1398) esp_netif_lwip: DHCP server started on interface WIFI_AP_DEF with IP: 192.168.4.1
I (1408) main_task: Returned from app_main()
```