---
title: "ESP-IDF Adv. - Lecture 4"
date: "2025-08-05"
series: ["WS00B"]
series_order: 13
showAuthor: false
summary: "In this article, we explore the advanced features required for security: OTA update, flash encryption, and secure bootloader"
---

## Introduction

As IoT devices become more widespread in homes, industries, and critical infrastructure, the need for robust security is growing rapidly. These connected systems often handle personal data, control physical processes, and operate in untrusted environments—making them attractive targets for attackers.

In response to these risks, new regulations like the EU’s __Radio Equipment Directive Delegated Act (RED DA)__ are raising the bar for IoT security, requiring manufacturers to implement stronger protections by design.

To meet these evolving demands, three core technologies have become staples of modern IoT security: __over-the-air (OTA) updates__, __flash encryption__, and __secure bootloaders__.

* __OTA Updates__ allow devices to receive firmware updates remotely, enabling timely security patches and feature enhancements without requiring physical access. This is crucial for maintaining device integrity over its lifecycle, especially once deployed in the field.

* __Flash Encryption__ protects data stored in the device’s flash memory by encrypting it at the hardware level. This ensures that sensitive information (such as cryptographic keys or user data) remains inaccessible even if an attacker gains physical access to the device.

* __Secure Bootloaders__ verify the integrity and authenticity of firmware before execution. By checking digital signatures during the boot process, they prevent unauthorized or malicious code from running on the device

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
In the following assignments, you will enable these features on the hardware. If you don't feel comfortable, you can follow the developer portal article to [emulate security features using QEMU](https://developer.espressif.com/blog/trying-out-esp32-c3s-security-features-using-qemu/).
{{< /alert >}}

Together, these features form a foundational security layer, helping developers build devices that are compliant with new regulations and resilient against real-world threats.

In this article we'll see what each of these features. To use the OTA we need to first change the partition table. For this reason, before we start, we need to spend a few words about partition tables.

## Partition Tables

The partition table defines how the flash memory is organized, specifying where applications, data, filesystems, and other resources are stored. This logical separation allows developers to manage firmware, persistent data, and update mechanisms efficiently.

ESP-IDF uses partition tables because they enable:

- __Separation of code and data:__ Application and persistent data are isolated, allowing firmware updates without erasing user data.
- __OTA updates:__ Multiple app partitions and OTA data management for robust remote firmware upgrades.
- __Flexible storage:__ Support for filesystems and custom data regions for certificates, logs, or configuration.

### Structure and Location

The partition table is typically flashed at offset `0x8000` in the device’s SPI flash. It occupies `0xC00` bytes, supporting up to 95 entries, and includes an MD5 checksum for integrity verification. The table itself takes up a full 4 KB flash sector, so any partition following it must start at least at offset `0x9000`, depending on the table size and alignment requirements. Each entry in the table includes a name (label), type (such as app or data), subtype, offset, and size in flash memory.

### Built-in Partition Schemes

ESP-IDF provides several predefined partition tables for common use cases, selectable via `menuconfig`:

- __Single factory app, no OTA__: Contains a single application partition and basic data partitions (NVS, PHY init).
- __Factory app, two OTA definitions__: Adds support for over-the-air (OTA) updates, with two OTA app partitions and an OTA data slot. We will use this predefined partition table in the [assignment 4.1](../assignment-4-1/)

For example, the "Factory app, two OTA definitions" scheme typically looks like this:

```
Name      Type   SubType  Offset    Size
nvs       data   nvs      0x9000    0x4000
otadata   data   ota      0xd000    0x2000
phy_init  data   phy      0xf000    0x1000
factory   app    factory  0x10000   1M
ota_0     app    ota_0    0x110000  1M
ota_1     app    ota_1    0x210000  1M
```

The bootloader uses the partition table to locate the application to boot and the data regions for NVS, PHY calibration, and OTA management.

### Custom Partition Tables

For advanced use cases, developers can define custom partition tables in CSV format. This allows for additional partitions, such as extra NVS storage, SPIFFS, or FAT filesystems, tailored to the application’s needs. The custom CSV is specified in the project configuration, and ESP-IDF tools will flash and use it accordingly.

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
Use custom partition table to increase the size of OTA partitions to the maximum available space (after all other partition sizes are known): This way you have the most space available when doing OTA updates in the future!
{{< /alert >}}

We will test this option in [assignment 4.2](../assignment-4-2/).

## Over-the-Air (OTA) Updates on Espressif Devices

Over-the-Air (OTA) updates allow you to remotely upgrade the firmware of embedded devices without requiring physical access. This capability is especially important for IoT deployments, where devices are often distributed across wide or hard-to-reach areas. OTA ensures your devices stay up to date with the latest features, bug fixes, and security patches long after they've been deployed.

In the OTA process, the Espressif device downloads the firmware from a given location, as depicted in Fig.1.

{{< figure
default=true
src="../assets/lecture_4_ota_diagram.webp"
width=350
caption="Fig.1 -- OTA basic diagram"
    >}}

Key benefits of OTA include:

* __Remote maintenance:__ Update firmware without on-site visits.
* __Improved security:__ Quickly patch known vulnerabilities.
* __Feature updates:__ Seamlessly deliver new functionality to users.
* __Lower maintenance costs:__ Avoid expensive manual recalls or servicing.

### Implementing OTA with ESP-IDF

ESP-IDF offers built-in support for OTA through two main methods:

* __Native API__: Using the `app_update` component for full control over the update process.
* __Simplified API__: Using the `esp_https_ota` component for a higher-level interface that handles HTTPS download and flashing automatically.

In most cases, application needs to interact with public interface of `esp_https_ota` and `app_update` components only.
In Fig.2 you can find a simplified diagram of the OTA key components.

{{< figure
default=true
src="../assets/lecture_4_ota.webp"
height=500
caption="Fig.2 -- OTA key components (simplified diagram)"
    >}}

A typical OTA workflow includes:

1. Downloading the new firmware image over Wi-Fi or Ethernet.
2. Writing it to an unused OTA partition in flash.
3. Updating the OTA data partition to mark the new firmware as the active version.
4. Rebooting the device to apply the update.

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
To use OTA, you must add an appropriate partition table.
{{< /alert >}}


#### Example code snippet using `esp_https_ota`

Using `esp_https_ota` is straightforward and typically requires just a few lines of code.

```c
#include "esp_https_ota.h"

esp_err_t do_firmware_upgrade()
{
    esp_http_client_config_t config = {
        .url = "https://example.com/firmware.bin",
        .cert_pem = (char *)server_cert_pem_start,
    };
    esp_https_ota_config_t ota_config = {
        .http_config = &config,
    };
    esp_err_t ret = esp_https_ota(&ota_config);
    if (ret == ESP_OK) {
        esp_restart();
    } else {
        return ESP_FAIL;
    }
    return ESP_OK;
}
```
This code downloads a new firmware image and, if successful, restarts the device to boot into the new firmware. For more advanced usage, refer to the [ESP-IDF OTA documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/ota.html).

#### OTA partition table layout

OTA requires a specific partition table layout. At minimum, you need:

- __NVS partition:__ For non-volatile storage.
- __OTA Data partition:__ To track which firmware partition is active.
- __Two OTA app partitions:__ For active/passive firmware images.

An example of valid partition table is the following.

```
Name,   Type, SubType, Offset,  Size, Flags
nvs,      data, nvs,     ,        0x6000,
otadata,  data, ota,     ,        0x2000,
phy_init, data, phy,     ,        0x1000,
ota_0,    app,  ota_0,   ,        1M,
ota_1,    app,  ota_1,   ,        1M,
```

This layout ensures safe updates: the new firmware is written to the inactive partition, and only after verification is it marked as active for the next boot. The OTA data partition is two flash sectors (0x2000 bytes) to prevent corruption in case of power failure during updates.

Besides the already mentioned (`data`,`nvs`), this partition table contains a (`data`,`ota`) field which plays an important role in OTA updates.

#### otadata partition

The __otadata partition__ (also referred to as the __OTA Data partition__) is a special partition in the ESP-IDF partition table, required for projects that use Over-The-Air (OTA) firmware updates. Its main purpose is to store information about which OTA app slot (such as `ota_0` or `ota_1`) should be booted by the device. It's typical size is `0x2000` bytes (two flash sectors)

The otadata partition is used as follows:
- On first boot (or after erasing), the otadata partition is empty (all bytes set to 0xFF). In this state, the bootloader will boot the factory app if present, or the first OTA slot if not.
- After a successful OTA update, the otadata partition is updated to indicate which OTA app slot should be booted next.
- The partition is designed to be robust against power failures: it uses two sectors, and a counter field to determine the most recent valid data if the sectors disagree.

## Flash encryption

Flash encryption is a critical security feature, designed to protect the contents of flash memory. When enabled, all data stored in flash is encrypted, making it extremely difficult for unauthorized parties to extract sensitive information, even if they have physical access to the device.

### How Flash Encryption Works

On first boot, firmware is flashed as plaintext and then encrypted in place. The encryption process uses hardware-accelerated algorithms such as XTS-AES-128, XTS-AES-256, or AES-256, depending on the chip series. The encryption key is securely stored in eFuse blocks within the chip and is not accessible by software, ensuring robust key protection. For example, ESP32 uses AES-256, while ESP32-C3, ESP32-C6, and ESP32-H2 use XTS-AES-128 with a 256-bit key stored in eFuse blocks. Some newer chips, like ESP32-S3 and ESP32-P4, also support XTS-AES-256 with a 512-bit key option, using two eFuse blocks for key storage.

Flash access is transparent: any memory-mapped region is automatically decrypted when read, and encrypted when written, without requiring changes to application code.

By default, critical partitions such as the bootloader, partition table, NVS key partition, otadata, and all application partitions are encrypted. Other partitions can be selectively encrypted by marking them with the `encrypted` flag in the partition table.

### Modes and Security Considerations

Flash encryption can be enabled in "Development" or "Release" mode.

* In __development mode__, it is possible to re-flash plaintext firmware for testing, but this is not secure for production.
* In __release mode__, re-flashing plaintext firmware is prevented, and the device is locked down for maximum security.

It is strongly recommended to use release mode for production devices to prevent unauthorized firmware extraction or modification.

### Important Usage Notes

- Do not interrupt power during the initial encryption pass on first boot, as this can corrupt flash contents and require re-flashing.
- Enabling flash encryption increases the bootloader size, which may require updating the partition table offset. We'll see it in detail in [assignment 4.3](../assignment-4-3)
- If secure boot is also enabled, re-flashing the bootloader requires a special "Re-flashable" secure boot digest.


## Secure Bootloader

Espressif devices offer a feature called __Secure Boot__, which is implemented via a secure bootloader. This mechanism forms the foundation of device security, protecting against unauthorized code execution and firmware tampering.

A __secure bootloader__ is a special program that verifies the authenticity and integrity of the firmware before allowing it to run on the device. It does this by checking cryptographic signatures appended to the bootloader and application images. If any part of the code has been altered or is not signed by a trusted key, the device will refuse to execute it.

This process establishes a __chain of trust__:
- The hardware (ROM bootloader) verifies the software bootloader.
- The software bootloader then verifies the application firmware.

This ensures that only code signed by the device manufacturer (or another trusted entity) can run, protecting against malware, unauthorized updates, and physical tampering with the device's flash memory. The private signing key is kept secret, while the public key or its digest is stored securely in the device's eFUSE memory, making it inaccessible to software and attackers.

### How to Use Secure Bootloader

Enabling secure bootloader on Espressif devices involves the following steps

1. __Enable Secure Boot in Configuration:__
   - Use `menuconfig` to enable secure boot under "Security Features".

2. __Generate or Specify a Signing Key:__
   - If a signing key does not exist, generate one using the provided command (e.g., `idf.py secure-generate-signing-key`). For production, generate keys using a trusted tool like OpenSSL.

3. __Build and Flash the Bootloader:__
   - Build the secure boot-enabled bootloader:
     ```sh
     idf.py bootloader
     ```
   - Flash the bootloader manually using the command printed by the build process.

4. __Build and Flash the Application:__
   - Build and flash the application and partition table:
     ```sh
     idf.py flash
     ```
   - The application image will be signed automatically using the specified key.

5. __Verify Secure Boot Activation:__
   - On first boot, the device will enable secure boot, burn the necessary eFUSEs, and verify the signatures. Monitor the serial output to confirm successful activation.


{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Once secure boot is enabled, the bootloader cannot be reflashed (unless using a special "reflashable" mode, which is not recommended for production). Always keep your private signing key secure, as its compromise undermines the entire secure boot process
{{< /alert >}}

<!-- We will trye the secure bootloader in the [Assignment 4.4](assignment-4-3) -->

## Conclusion

In this article, we explored three foundational pillars of modern IoT security: OTA updates, flash encryption, and secure bootloaders. Together, these features ensure that devices can be updated securely, protect sensitive data at rest, and verify firmware integrity from the moment they power on. As IoT security requirements continue to evolve, mastering these tools is essential for building resilient and regulation-compliant embedded systems.
In the next assignments, you will test these features first-hand.

> Next step: [assignment 4.1](../assignment-4-1/)
