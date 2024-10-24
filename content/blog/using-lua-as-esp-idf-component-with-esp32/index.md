---
title: "Using Lua as ESP-IDF Component with ESP32"
date: 2024-10-22
showAuthor: false
tags: ["ESP32", "ESP-IDF", "Lua", "Scripting"]
authors:
    - "juraj-michalek"
---

## Introduction

Lua is a lightweight scripting language ideal for embedded systems like the ESP32. Integrating Lua into your ESP-IDF project allows you to run scripts directly on the ESP32, providing flexibility and ease of development. This guide explains how to use Lua as an ESP-IDF component with the stable branch of Lua 5.4, focusing on running Lua scripts from files stored in the filesystem. We'll provide a link to a ready-to-use repository so you can get started quickly.

## Repository Link

You can find the complete example project at [ESP32 Lua Example Repository](https://github.com/georgik/esp32-lua-example)

Clone the repository to get started:

```bash
git clone https://github.com/yourusername/esp32-lua-example.git
cd esp32-lua-example
```

## Project Overview

The project demonstrates:

- Integrating Lua 5.4 as an ESP-IDF component.
- Running Lua scripts from files stored in the filesystem (SPIFFS).
- Monitoring memory usage when Wi-Fi is enabled.
- Examples of Lua scripts to illustrate how to execute code on the ESP32.


### Key Components

#### Lua 5.4 ESP-IDF Component

Lua 5.4 is included as a component in the ESP-IDF project.
The component is configured to work seamlessly with the ESP32.
The Lua interpreter can execute scripts and interact with ESP-IDF functionalities.

### Filesystem Support (SPIFFS)

The SPIFFS filesystem is used to store Lua scripts on the ESP32.
Scripts can be easily added, updated, or removed without modifying the firmware.
This approach allows developers to manage Lua scripts separately from the main application code.

#### Memory Usage Insights

The project logs memory usage at various stages to provide insights into how much memory is available, especially when Wi-Fi is enabled.
Understanding memory consumption is crucial for developing stable applications on resource-constrained devices like the ESP32.

## Understanding the Code

Main Application (main/esp32-lua-example.c) initializes the SPIFFS filesystem.
Optionally initializes Wi-Fi and logs memory usage.
Runs Lua scripts from files using the run_lua_file function.
Key Function: `run_lua_file`

```c
void run_lua_file(const char *file_name, const char *description) {
    ESP_LOGI(TAG, "Running Lua script: %s", description);

    lua_State *L = luaL_newstate();
    if (L == NULL) {
        ESP_LOGE(TAG, "Failed to create Lua state");
        return;
    }

    luaL_openlibs(L);

    // Set Lua module search path
    if (luaL_dostring(L, "package.path = package.path .. ';./?.lua;/spiffs/?.lua'")) {
        ESP_LOGE(TAG, "Failed to set package.path: %s", lua_tostring(L, -1));
        lua_pop(L, 1);
    }

    // Load and execute the Lua script from file
    if (luaL_dofile(L, file_name) != LUA_OK) {
        ESP_LOGE(TAG, "Error executing Lua script '%s': %s", file_name, lua_tostring(L, -1));
        lua_pop(L, 1);
    }

    lua_close(L);
    ESP_LOGI(TAG, "Finished running Lua script: %s", description);
}
```

Creates a new Lua state and opens standard libraries.
Sets the package.path to include the filesystem path where Lua scripts are stored.
Executes the Lua script from the specified file.

### Filesystem Initialization

Function: `init_spiffs`

```c
void init_spiffs(void) {
    ESP_LOGI(TAG, "Initializing SPIFFS");

    esp_vfs_spiffs_conf_t conf = {
        .base_path = "/spiffs",
        .partition_label = NULL,
        .max_files = 5,
        .format_if_mount_failed = true
    };

    esp_err_t ret = esp_vfs_spiffs_register(&conf);

    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to mount or format filesystem");
        return;
    }

    size_t total = 0, used = 0;
    ret = esp_spiffs_info(NULL, &total, &used);
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "SPIFFS total: %d, used: %d", total, used);
    } else {
        ESP_LOGE(TAG, "Failed to get SPIFFS partition information");
    }
}
```


### Getting Started

Clone the Repository

```bash
git clone https://github.com/yourusername/esp32-lua-example.git
cd esp32-lua-example
```

Configure the Project

Use idf.py menuconfig to configure the project settings if necessary.

Build, flash and monitor

```bash
idf.py build flash monior
```

Expected output:

```shell
The answer is: 42
Fibonacci of 10 is: 55
QR Code for: https://developer.espressif.com/tags/lua
```


## Integrating Lua as an ESP-IDF Component

To incorporate Lua into your ESP32 project seamlessly, you can use the ESP-IDF Component Registry, which simplifies dependency management and ensures you're using a stable version of Lua.

### Adding Lua to Your Project
In your project's main directory, create or edit the idf_component.yml file to specify Lua as a dependency:

```yaml
# main/idf_component.yml

dependencies:
  georgik/lua: "==5.4.7"
  joltwallet/littlefs: "==1.14.8"

idf:
  version: ">=5.0.0"
```
This configuration tells the ESP-IDF build system to include version 5.4.7 of the Lua component maintained by georgik, as well as version 1.14.8 of the LittleFS component for filesystem support. The idf section ensures compatibility with ESP-IDF version 5.0.0 or newer.

### Utilizing the ESP-IDF Component Registry

By specifying Lua in your idf_component.yml, the ESP-IDF build system automatically downloads and integrates the Lua component during the build process. There's no need to manually clone or manage the Lua source code.

You can find more information about the Lua component in the [ESP-IDF Component Registry](https://components.espressif.com/components/georgik/lua/) and the [Lua ESP-IDF Component repository](https://github.com/georgik/esp-idf-component-lua/).

### Conclusion

Integrating Lua into your ESP-IDF project with the ESP32 provides a flexible way to execute scripts and manage application behavior. By using the filesystem to store Lua scripts, you can easily update and manage your code without recompiling the entire application. The provided examples demonstrate how to run Lua scripts from files, monitor memory usage, and manage resources effectively.

## References

- ESP-IDF Component Registry: [Lua Component](https://components.espressif.com/components/georgik/lua/)
- Lua ESP-IDF Component Repository: [esp-idf-component-lua](https://github.com/georgik/esp-idf-component-lua/)
