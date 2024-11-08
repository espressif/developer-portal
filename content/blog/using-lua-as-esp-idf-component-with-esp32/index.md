---
title: "Using Lua as ESP-IDF Component with ESP32"
date: 2024-10-22
showAuthor: false
tags: ["ESP32", "ESP-IDF", "Lua", "Scripting", "Component"]
authors:
    - "juraj-michalek"
---

Lua is a lightweight and powerful scripting language, making it ideal for use in embedded systems like the ESP32. By integrating Lua into your ESP-IDF project, you can execute scripts directly on the ESP32, offering a flexible way to manage application behavior without recompiling the entire firmware. This guide walks through how to set up Lua 5.4 as a component in an ESP-IDF project, with a focus on running Lua scripts from the filesystem.

## Repository Link

You can find the complete example project at [ESP32 Lua Example Repository](https://github.com/georgik/esp32-lua-example)

## Project Overview

The example project demonstrates:

- Integrating [Lua 5.4 as an ESP-IDF component](https://components.espressif.com/components/georgik/lua/).
- Running Lua scripts from files stored in the filesystem (SPIFFS).
- Monitoring memory usage when Wi-Fi is enabled.
- Examples of Lua scripts to illustrate how to execute code on the ESP32.


### Key Components

#### Lua 5.4 ESP-IDF Component

Lua 5.4 is wrapped as an [ESP-IDF component](https://components.espressif.com/components/georgik/lua/), allowing easy integration with ESP32 applications.Lua’s extensibility makes it suitable for both rapid development and runtime script adjustments.

### Filesystem Support (SPIFFS)

In this project, the SPIFFS filesystem is used to store Lua scripts on the ESP32. This allows scripts to be managed separately from the firmware, enabling easy updates without requiring a full rebuild of the application. Developers can simply upload new Lua scripts to the SPIFFS partition, making it an efficient solution for managing code changes.

#### Memory Usage Insights

Memory management is critical in resource-constrained devices like the ESP32, especially when features like Wi-Fi are active. This project logs memory usage at various stages of execution, helping developers monitor and optimize memory consumption. It’s essential for ensuring stability, particularly in applications that demand more resources.

## Code Overview

Below is an example of the core functionality. The application initializes the SPIFFS filesystem and optionally sets up Wi-Fi. Lua scripts are executed from files using a key function that handles file loading and script execution.

### Running Lua Scripts

The `run_lua_file` function is responsible for loading and executing a Lua script from the specified file.

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

This function does the following:
- Creates a new Lua state.
- Opens the standard Lua libraries.
- Configures the Lua module search path to include the SPIFFS partition.
- Loads and executes the specified Lua script file.

### Filesystem Initialization

The `init_spiffs` function is used to initialize the SPIFFS filesystem, ensuring the ESP32 can store and access Lua scripts.

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


## Getting Started

To get started with this example, follow these steps

### Clone the Repository

First, clone the example project from GitHub:

```shell
git clone https://github.com/georgik/esp32-lua-example.git
cd esp32-lua-example
```

### Configure the Project

If needed, run idf.py menuconfig to adjust project settings before building.

### Build, Flash, and Monitor

Compile and flash the firmware onto your ESP32, then monitor the output:

```shell
idf.py build flash monior
```

You should see output similar to the following:

```shell
The answer is: 42
Fibonacci of 10 is: 55
QR Code for: https://developer.espressif.com/tags/lua
```


## Integrating Lua as an ESP-IDF Component

To integrate Lua into your own ESP-IDF project, follow these steps:

### Adding Lua to Your Project
In your project's main directory, create or edit the `main/idf_component.yml` file to specify Lua as a dependency:

```yaml
dependencies:
  georgik/lua: "==5.4.7"
  joltwallet/littlefs: "==1.14.8"

idf:
  version: ">=5.0.0"
```
This configuration ensures the ESP-IDF build system fetches and includes the Lua 5.4.7 component and the LittleFS component for filesystem support.

### Utilizing the ESP-IDF Component Registry

By specifying Lua in your `main/idf_component.yml`, the ESP-IDF build system will automatically download and integrate the Lua component during the build process. There’s no need to manually manage Lua's source code, making dependency management easier.

You can find more information about the Lua component in the [ESP-IDF Component Registry](https://components.espressif.com/components/georgik/lua/) and the [Lua ESP-IDF Component repository](https://github.com/georgik/esp-idf-component-lua/).

### Conclusion

Lua provides a powerful yet lightweight way to script and manage ESP32 applications. By using the filesystem to store Lua scripts, you can update code on the fly without having to recompile the firmware. This guide shows you how to easily integrate Lua into your ESP32 projects, manage scripts using SPIFFS, and monitor resource usage, all while keeping your development process flexible and efficient.

## References

- ESP-IDF Component Registry: [Lua Component](https://components.espressif.com/components/georgik/lua/)
- Lua ESP-IDF Component Repository: [esp-idf-component-lua](https://github.com/georgik/esp-idf-component-lua/)
