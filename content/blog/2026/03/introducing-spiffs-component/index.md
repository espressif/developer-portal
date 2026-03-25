---
title: Introducing the SPIFFS component
date: 2026-03-23
summary: Learn what the ESP-IDF SPIFFS component is, how it works with the VFS layer and standard C file APIs, and how to use the SPIFFSgen tool to embed files. This article is a practical guide with references to the official example.
tags:
  - ESP-IDF
  - beginner
  - tutorial
  - storage
  - SPIFFS
  - filesystem
authors:
  - "radek-tandler"
---

## Introduction

Storing files on flash—configuration, web assets, or firmware data—is common in embedded applications. Based on the original [SPIFFS project](https://github.com/pellepl/spiffs), the **SPIFFS** component in ESP-IDF provides a lightweight filesystem for SPI NOR flash: it supports wear levelling, consistency checks, and integrates with the rest of ESP-IDF so you can use familiar C and POSIX file APIs.

This article introduces the SPIFFS component, how it collaborates with the **VFS** (Virtual File System) component and with tools like **SPIFFSgen**, and points you to a working example.


SPIFFS comes bundled with ESP-IDF rather than being distributed via the Component Registry. You use it by mounting a SPIFFS partition through VFS, then reading and writing files via `fopen`, `fprintf`, `fread`, and similar functions.

## Key Features

The SPIFFS component offers:

- **Standard file I/O API**: Use familiar C and POSIX calls—`fopen`, `fread`, `fwrite`, `fprintf`, `stat`, `unlink`, `rename`, and the like—so you can read and write SPIFFS files without any filesystem-specific API. This is provided via the [VFS](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/storage/vfs.html) layer once SPIFFS is mounted.
- **Partition-based**: You define a SPIFFS partition in your [partition table](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/partition-tables.html); the component uses that partition for all file data.
- **Wear levelling**: Helps extend flash lifetime by spreading writes across the partition.
- **File system consistency checks**: You can run an explicit integrity check (and repair) via the `esp_spiffs_check()` function; see [Discussion: integrity check](#integrity-check) below.
- **Format-on-mount option**: `format_if_mount_failed` lets you automatically format the partition if mount fails (e.g. first boot or after erase).

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
SPIFFS is flat meaning it doesn't offer real directories—path segments become part of the file name. It reliably uses about 75% of the partition space. Under low space, garbage collection can take noticeable time; see the [SPIFFS documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/storage/spiffs.html) for configuration and behavior.
{{< /alert >}}

### Application use cases

SPIFFS is often used for:

- **Web server assets**: HTML, CSS, JavaScript for an ESP32 web server
- **Configuration and calibration**: Device config or calibration data in files, updated without reflashing the whole app
- **Scripts and data**: Lua scripts, JSON config, or small datasets read at runtime
- **OTA and assets**: Firmware metadata or asset packs updated separately from the main app

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Security note: The SPIFFS lightweight implementation does not offer data encryption. To keep sensitive data safe, ESP-IDF offers other storage components that support data encryption. These include FATFS, LittleFS, and NVS. A quick comparison of features can be found on the [File System Considerations](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/file-system-considerations.html) page in the ESP-IDF documentation.
{{< /alert >}}

## Basic example: mount, write, and read

The [storage/spiffs](https://github.com/espressif/esp-idf/tree/master/examples/storage/spiffs) example in ESP-IDF shows the minimal flow: register SPIFFS with VFS, write a file, rename it, then read it back. No special hardware is required; any board with a SPIFFS partition in the partition table will work.

### What the example does

1. Prepares a compile-time partition layout that includes a SPIFFS partition labeled `storage`.
2. Calls `esp_vfs_spiffs_register()` to initialize SPIFFS, mount it, and register it with VFS at a path prefix (e.g. `/spiffs`).
3. Creates a file with `fopen` and writes a line with `fprintf`.
4. Renames the file (after checking for an existing destination with `stat` and removing it with `unlink` if needed).
5. Opens the renamed file, reads the line back with `fgets`, and prints it to the console.
6. Unregisters SPIFFS with `esp_vfs_spiffs_unregister()`.

Partition size and label are defined in `partitions_example.csv` in the example. You can run it with `idf.py -p PORT flash monitor`. To erase the SPIFFS partition and start fresh, run `idf.py erase-flash` before flashing again.

### Prerequisites

- A project with a partition table that includes a SPIFFS partition (see the example’s `partitions_example.csv`).
- No special hardware; the example runs on any supported target (ESP32, ESP32-C3, etc.).

### Step 1: Prepare partition table at compile time

Before mounting SPIFFS in code, make sure your build uses a partition table that contains a SPIFFS partition with the label used by your code (here: `storage`).

In `idf.py menuconfig`:

- Go to `Partition Table`.
- Set `Partition Table` to `Custom partition table CSV`.
- Set `Custom partition CSV file` to your file (for example, `partitions_example.csv`).

The ESP-IDF example uses the following `partitions_example.csv`:

```csv
# Name, Type, SubType, Offset, Size, Flags
# Note: if you have increased the bootloader size, make sure to update the offsets to avoid overlap
nvs, data, nvs, 0x9000, 0x6000,
phy_init, data, phy, 0xf000, 0x1000,
factory, app, factory, 0x10000, 1M,
storage, data, spiffs, , 0xF0000,
```

The key line for SPIFFS is:

```csv
storage, data, spiffs, , 0xF0000,
```

At build time, ESP-IDF compiles this CSV into the partition table binary and flashes it with your app.

### Step 2: Include and configure

Include the SPIFFS/VFS header and set the partition label and mount path:

```c
#include "esp_vfs_spiffs.h"

static const char *TAG = "example";

#define PARTITION_LABEL  "storage"
#define BASE_PATH        "/spiffs"
```

### Step 3: Register SPIFFS with VFS

In `app_main()` (or after NVS/other init), fill the configuration and register:

```c
esp_vfs_spiffs_conf_t conf = {
    .base_path = BASE_PATH,
    .partition_label = PARTITION_LABEL,
    .max_files = 5,
    .format_if_mount_failed = true
};

esp_err_t ret = esp_vfs_spiffs_register(&conf);
if (ret != ESP_OK) {
    ESP_LOGE(TAG, "Failed to initialize SPIFFS (%s)", esp_err_to_name(ret));
    return;
}
```

Setting `format_if_mount_failed` to `true` formats the partition on first use or when mount fails, which is convenient for development.

### Step 4: Use standard file APIs

Once mounted, use C library functions with paths under `BASE_PATH`:

```c
FILE *f = fopen("/spiffs/hello.txt", "w");
if (f != NULL) {
    fprintf(f, "Hello World!\n");
    fclose(f);
}

// Later: open for read, rename with stat/unlink as needed, etc.
```

All of this goes through VFS to the SPIFFS driver; no SPIFFS-specific read/write calls are needed.

### Step 5: Unregister when done

Before shutting down or if you need to remount:

```c
esp_vfs_spiffs_unregister(PARTITION_LABEL);
```

The example also demonstrates getting partition info with `esp_spiffs_info()` and, optionally, running an integrity check with `esp_spiffs_check()` — we discuss that option and alternatives in [Integrity check](#integrity-check).

### Complete source code

The full example is in the ESP-IDF repository:

- [esp-idf/examples/storage/spiffs](https://github.com/espressif/esp-idf/tree/master/examples/storage/spiffs)

For embedding files with SPIFFSgen in the build (an alternative to creating files only at runtime):

- [esp-idf/examples/storage/spiffsgen](https://github.com/espressif/esp-idf/tree/master/examples/storage/spiffsgen)

## Discussion: options in the example and alternatives

The example above uses a small set of SPIFFS and VFS options. This section walks through those choices and the alternatives the component offers so you can adapt them to your project.

### Registration, base_path, and partition_label

The example registers SPIFFS with `base_path = "/spiffs"` and `partition_label = "storage"`. Those two values answer different questions: **where** the file data lives on flash, and **how** your application refers to it by path.

#### partition_label — "Which region of flash?" (esp_partition)

Your [partition table](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/partition-tables.html) divides flash into named regions. Each region has a **label** (e.g. `storage` or `spiffs`). When you set `partition_label` to `"storage"`, the SPIFFS component uses the **esp_partition** API under the hood: it looks up the partition by that label and gets the **offset** and **size** of that region in flash. SPIFFS then uses that region exclusively for all file data. So **partition_label** is the link between your config and the physical flash layout. If you have two SPIFFS partitions (e.g. `storage` and `assets`), register each with its own label; each gets its own region of flash.

As an alternative, you can pass `partition_label = NULL` to use the **first** SPIFFS partition in the table (the example’s code can use `NULL`; the snippet above uses `"storage"` for clarity). Useful when you have only one SPIFFS partition and don’t care about the name.

#### base_path — "How do I name files in code?" (VFS)

The **base_path** (e.g. `/spiffs`) is the **mount point** in the [VFS](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/storage/vfs.html) layer. VFS routes path-based calls to the driver that registered with that prefix. When you call `fopen("/spiffs/hello.txt", "r")`, VFS hands the request to the SPIFFS driver registered with `base_path = "/spiffs"`; the driver sees the relative part (`hello.txt`) and uses the partition it already knows from **partition_label**. So **base_path** is a naming convention: the “directory” under which all files for this SPIFFS instance appear. It doesn’t change where data is stored.

As an alternative, you can set `base_path` to any path that doesn’t clash with another mount point (e.g. `/data`, `/assets`). The example uses `/spiffs` by convention.

**How they work together:** partition_label selects *which* flash partition holds the data (via esp_partition); base_path selects *which* path prefix in VFS points to that data. Both are needed at registration so VFS can route requests and the driver can use the right partition.

### format_if_mount_failed and max_files

The example sets `format_if_mount_failed = true` and `max_files = 5`.

- **format_if_mount_failed**: If mount fails (e.g. unformatted or corrupted partition), the component will format the partition and try again. Convenient for development and first boot; you can set it to `false` in production if you prefer to handle mount failure yourself (e.g. call `esp_spiffs_format()` or `esp_spiffs_check()` and retry).
- **max_files**: Maximum number of files open at the same time. The example uses 5; increase this if your application opens more files concurrently.

The `esp_vfs_spiffs_conf_t` struct has no other fields—only `base_path`, `partition_label`, `max_files`, and `format_if_mount_failed`.

### Integrity check

SPIFFS can be corrupted if power is lost during a write. The component does **not** run an automatic integrity check at mount time; it exposes a function you call when you need it.

**What the example does:** The storage/spiffs example can run `esp_spiffs_check(partition_label)` in two situations:

1. **Optional check on start**: The example’s menuconfig (“SPIFFS Example” menu) has **Perform SPIFFS consistency check on start** (`CONFIG_EXAMPLE_SPIFFS_CHECK_ON_START`). When enabled, the example calls `esp_spiffs_check(conf.partition_label)` once after a successful mount, before any file I/O.
2. **Recovery when info is inconsistent**: If `esp_spiffs_info()` reports `used > total`, the example calls `esp_spiffs_check()` as a recovery path (independent of the menuconfig option).

**`esp_spiffs_check(partition_label)`**
This function must be called manually on an already **mounted** partition. It scans the filesystem to repair corrupted files and clean up unreferenced pages (for example, after a power loss), returning `ESP_OK`, `ESP_ERR_INVALID_STATE` (if not mounted), or `ESP_FAIL`. Note that this check is **expensive**, requiring multiple full scans—on large partitions, it can introduce noticeable delays. Unlike some filesystems, `esp_vfs_spiffs_conf_t` does not include an automatic "check on mount" flag; you control when the check runs.

**Alternatives:** In your own project you can: call `esp_spiffs_check()` after mount only when you want a boot-time check (like the example option); call it only when you detect a problem (e.g. `used > total` or after detected power loss); or run it as periodic maintenance. Trade-off: better recovery vs. longer, blocking boot on large partitions. The [SPIFFS FAQ](https://github.com/pellepl/spiffs/wiki/FAQ) has more detail on when to run the check.

### Populating the partition: SPIFFSgen

The example creates files only at runtime (e.g. with `fprintf`). To **embed** host files (HTML, config, assets) into the SPIFFS partition and flash them with the app, the recommended tool is **SPIFFSgen** (spiffsgen.py).

[spiffsgen.py](https://github.com/espressif/esp-idf/blob/master/components/spiffs/spiffsgen.py) is a write-only Python tool that builds a SPIFFS image from a host directory. It is part of the `spiffs` component and you can use it standalone or via the build system.

**Standalone:**

```bash
python spiffsgen.py <image_size> <base_dir> <output_file>
```

The image can be flashed with `esptool` or `parttool.py`. Run `python spiffsgen.py --help` for optional arguments (page size, block size, etc.).

**Build system:**

Invoke it from CMake so the image is built (and optionally flashed) with your app:

```cmake
spiffs_create_partition_image(<partition> <base_dir> [FLASH_IN_PROJECT] [DEPENDS dep dep ...])
```

Use the partition name from your partition table; image size is taken from the table. With `FLASH_IN_PROJECT`, `idf.py flash` will flash the SPIFFS image together with the app. The [storage/spiffsgen](https://github.com/espressif/esp-idf/tree/master/examples/storage/spiffsgen) example demonstrates this workflow.

**Other tools:** **mkspiffs** can create and unpack SPIFFS images; use it when you need to unpack an image or when Python is not available. There is no built-in ESP-IDF build integration for mkspiffs. The [SPIFFS documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/storage/spiffs.html) describes when to prefer SPIFFSgen vs mkspiffs.

Whether files are created at runtime or embedded with SPIFFSgen, you use the same VFS file API (`fopen`, `fread`, etc.) to read and write them.

## Conclusion

The SPIFFS component gives you a simple, partition-based filesystem for SPI NOR flash, with wear levelling and optional consistency checks. By registering SPIFFS with the VFS layer, you use standard C and POSIX file APIs for all read/write operations. The example shows the minimal mount–write–read flow; the discussion above outlines the options it uses and alternatives (partition_label/base_path, integrity check, SPIFFSgen for embedded files) so you can adapt SPIFFS to your project.

## Learn More

- [How to use custom partition tables on ESP32](https://developer.espressif.com/blog/how-to-use-custom-partition-tables-on-esp32/) — define partitions including SPIFFS
- [Using Lua as ESP-IDF component with ESP32](https://developer.espressif.com/blog/using-lua-as-esp-idf-component-with-esp32/) — uses SPIFFS to store Lua scripts

## Resources

- [SPIFFS Filesystem (ESP-IDF documentation)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/storage/spiffs.html)
- [Virtual Filesystem (VFS)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/storage/vfs.html)
- [Partition Tables](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/partition-tables.html)
- [storage/spiffs example](https://github.com/espressif/esp-idf/tree/master/examples/storage/spiffs)
- [storage/spiffsgen example](https://github.com/espressif/esp-idf/tree/master/examples/storage/spiffsgen)
- [spiffsgen.py in ESP-IDF](https://github.com/espressif/esp-idf/blob/master/components/spiffs/spiffsgen.py)
