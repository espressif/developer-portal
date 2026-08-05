---
title: "AI agent coding for ESP-IDF workshop - Lecture 2: What you should know about ESP-IDF to work better with agents"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 4
showAuthor: false
---

## Lecture 2: What you should know about ESP-IDF to work better with agents

You don't need to be an ESP-IDF expert to work with an AI agent, but knowing the key concepts makes a big difference. The more precisely you can describe what you want, the less the agent has to guess. This lecture covers the ESP-IDF fundamentals that are most useful when writing prompts, plans, and reviewing generated code.

### Project structure

An ESP-IDF project has a consistent layout, and the agent knows it. When you describe a task, you can reference this structure directly:

```
my_project/
├── CMakeLists.txt          # top-level build config
├── sdkconfig               # resolved configuration (generated)
├── sdkconfig.defaults      # your default config values (committed)
├── main/
│   ├── CMakeLists.txt      # registers main as a component
│   └── app_main.c          # entry point: void app_main(void)
└── components/
    └── my_component/       # your custom components live here
```

The entry point is always `void app_main(void)`. Everything else is organised as components, including `main` itself.

### Components

Components are the building blocks of an ESP-IDF project. Every piece of reusable code (a driver, a protocol handler, a utility library) should be a component. The agent is good at generating them, but it needs you to tell it the component name and what the public API should look like.

There are two kinds:

- **Local components** live under `components/` in your project. They're private to that project and the easiest place to start.
- **Shared components** are standalone packages published to the [ESP Component Registry](https://components.espressif.com/). They can be reused across multiple projects and installed with `idf.py add-dependency`.

A standard component looks like this:

```
components/my_component/
├── CMakeLists.txt
├── Kconfig                 # optional configuration
├── include/
│   └── my_component.h      # public API
└── my_component.c          # implementation
```

The `CMakeLists.txt` uses `idf_component_register` to tell the build system what to compile and where the public headers are:

```cmake
idf_component_register(
    SRCS "my_component.c"
    INCLUDE_DIRS "include"
    REQUIRES driver nvs_flash
)
```

`REQUIRES` lists the ESP-IDF components this component depends on. If you forget one, the build will fail with a missing include. The agent usually gets this right if you tell it which ESP-IDF APIs the component uses.

### Board support packages (BSPs)

A Board Support Package, or BSP, is a versioned ESP-IDF component that knows how a specific development board is wired. It can initialise and expose onboard hardware such as LEDs, buttons, displays, touch panels, audio codecs, sensors, and SD cards.

Without a BSP, your application needs to know details such as which GPIO controls the LED or which I2C bus connects to a touch controller. With a BSP, those details stay in the board layer and your application uses a cleaner API. This gives you:

- Faster board bring-up.
- Fewer pin mapping and peripheral configuration mistakes.
- Reusable application code across projects using the same board.
- Automatic installation of the drivers and components required by the board.

A BSP is a shared component distributed through the [ESP Component Registry](https://components.espressif.com/components?q=Board+Support+Package). Add it to a project with the component manager:

```bash
idf.py add-dependency "espressif/<bsp-name>"
```

The dependency is recorded in `idf_component.yml`. During the next build, the component manager downloads the BSP and its dependencies into `managed_components/`.

Some development boards have a dedicated BSP. For a simple or custom board, you can use `esp_bsp_devkit` or `esp_bsp_generic` and configure the available hardware with `menuconfig`:

```bash
idf.py add-dependency "espressif/esp_bsp_devkit"
idf.py menuconfig
```

When working with an agent, always give it the exact board model, not only the chip name. An ESP32-C5 can be used on many boards with different LEDs, buttons, and pin mappings. A useful request looks like this:

```text
Check the ESP Component Registry for a BSP that supports my board.
If one exists, use it instead of hardcoding the onboard peripherals.
Explain which BSP and version you selected before adding the dependency.
```

{{< alert icon="circle-info" >}}
Do not ask the agent to invent a BSP API from memory. Ask it to check the component documentation and examples first, because the available functions and supported peripherals depend on the selected BSP and version.
{{< /alert >}}

### Kconfig and sdkconfig

Kconfig is how ESP-IDF handles configuration. Instead of hardcoding values like GPIO numbers, baud rates, or buffer sizes, you define them as Kconfig options and reference them in code as `CONFIG_MY_OPTION`.

A typical Kconfig entry looks like this:

```kconfig
config MY_COMPONENT_GPIO_NUM
    int "GPIO pin number"
    default 8
    range 0 48
    help
        GPIO pin connected to the LED. Default is 8 (ESP32-C5 DevKitC RGB LED).
```

`sdkconfig.defaults` is where you store the values you want committed with the project. The `sdkconfig` file itself is generated and should not be committed (add it to `.gitignore`). When prompting the agent to add a configurable option, mention the Kconfig name, type, default value, and valid range, and the agent will generate a correct entry.

### Main idf.py and esptool commands

`idf.py` and `esptool` work at different levels:

- **`idf.py`** manages an ESP-IDF project. It configures CMake, selects the target, builds the project, flashes all generated images at the correct addresses, and opens the serial monitor.
- **`esptool`** communicates directly with the ROM bootloader in an Espressif chip. It identifies devices and reads, writes, or erases flash.

For normal project development, start with `idf.py`. It calls `esptool` with the correct chip, files, and flash offsets when needed. Use `esptool` directly for device inspection, flashing diagnostics, and binary image operations.

#### Main idf.py commands

Run these commands from the root of an ESP-IDF project:

| Command | Purpose |
|---|---|
| `idf.py --version` | Show the active ESP-IDF version |
| `idf.py set-target esp32c5` | Configure the project for ESP32-C5 |
| `idf.py menuconfig` | Open the interactive project configuration menu |
| `idf.py reconfigure` | Regenerate the build configuration |
| `idf.py build` | Configure and build the complete project |
| `idf.py clean` | Remove most generated build files |
| `idf.py fullclean` | Remove the complete build directory |
| `idf.py -p <PORT> flash` | Flash the project to the connected board |
| `idf.py -p <PORT> monitor` | Open the serial monitor |
| `idf.py -p <PORT> flash monitor` | Flash the project and then open the monitor |
| `idf.py -p <PORT> erase-flash` | Erase the complete flash chip |
| `idf.py add-dependency "namespace/component"` | Add a managed component dependency |

You can chain compatible actions in one command. For example:

```bash
idf.py set-target esp32c5
idf.py build
idf.py -p <PORT> flash monitor
```

#### Main esptool commands

Replace `<PORT>` with the serial port connected to your board:

| Command | Purpose |
|---|---|
| `esptool version` | Show the installed esptool version |
| `esptool -p <PORT> chip-id` | Identify the connected chip |
| `esptool -p <PORT> read-mac` | Read the device MAC address |
| `esptool -p <PORT> flash-id` | Show the flash manufacturer, device ID, and detected size |
| `esptool -p <PORT> read-flash <ADDRESS> <SIZE> <FILE>` | Save a region of flash to a file |
| `esptool -p <PORT> write-flash <ADDRESS> <FILE>` | Write a binary file at a flash address |
| `esptool -p <PORT> erase-flash` | Erase the entire flash chip |
| `esptool image-info <FILE>` | Inspect the headers and segments of a firmware image |
| `esptool merge-bin ...` | Combine multiple binaries into one image |

To see all available actions and options:

```bash
idf.py --help
esptool -h
esptool write-flash -h
```

{{< alert icon="triangle-exclamation" >}}
Both `idf.py erase-flash` and `esptool erase-flash` delete the bootloader, partition table, application, NVS data, and everything else stored in flash. Also, do not guess addresses when using `esptool write-flash`. Run `idf.py build` and use the exact flashing command printed at the end of the build output.
{{< /alert >}}

An agent can use both tools as part of the closed-loop workflow. For example:

```text
Use esptool to identify the chip and flash size on <PORT>.
Do not erase or write anything.
Then run idf.py build and report the result.
```

### Error handling

ESP-IDF functions return `esp_err_t`. A successful call returns `ESP_OK`; anything else is an error code. Two patterns come up constantly:

```c
// Abort on error, use for unrecoverable startup failures
ESP_ERROR_CHECK(nvs_flash_init());

// Check and handle, use when you want to log and continue
esp_err_t ret = esp_wifi_start();
if (ret != ESP_OK) {
    ESP_LOGE(TAG, "Wi-Fi start failed: %s", esp_err_to_name(ret));
    return ret;
}
```

When reviewing agent-generated code, check that every ESP-IDF call either uses `ESP_ERROR_CHECK` or checks the return value. Unchecked errors are a common source of silent failures in embedded firmware.

### Logging

Use `ESP_LOGI`, `ESP_LOGW`, and `ESP_LOGE` instead of `printf`. They add a timestamp, log level, and tag, which makes serial output much easier to read.

```c
static const char *TAG = "my_component";

ESP_LOGI(TAG, "Initialised on GPIO %d", CONFIG_MY_COMPONENT_GPIO_NUM);
ESP_LOGW(TAG, "Retrying connection...");
ESP_LOGE(TAG, "Failed to read sensor: %s", esp_err_to_name(ret));
```

Always define `TAG` as a static const string at the top of each source file. When prompting the agent, tell it what tag to use, otherwise it will make one up.

The default log level is `INFO`. You can change it at runtime for a specific tag:

```c
esp_log_level_set("my_component", ESP_LOG_DEBUG);
```

Or set the global default in `sdkconfig.defaults`:

```
CONFIG_LOG_DEFAULT_LEVEL_DEBUG=y
```

This is useful during development when you want more verbose output, and easy to dial back before shipping.

## Next step

[Lecture 3: Spec-driven development](../lecture-3)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
