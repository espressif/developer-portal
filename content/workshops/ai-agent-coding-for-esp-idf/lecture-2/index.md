---
title: "AI Agent Coding for ESP-IDF Workshop - Lecture 2: What You Should Know About ESP-IDF to Work Better with Agents"
date: 2026-07-30T00:00:00+01:00
lastmod: 2026-07-30
showTableOfContents: false
series: ["WS003EN"]
series_order: 4
showAuthor: false
---

## Lecture 2: What You Should Know About ESP-IDF to Work Better with Agents

You don't need to be an ESP-IDF expert to work with an AI agent, but knowing the key concepts makes a big difference. The more precisely you can describe what you want, the less the agent has to guess. This lecture covers the ESP-IDF fundamentals that are most useful when writing prompts, plans, and reviewing generated code.

### Project Structure

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

`sdkconfig.defaults` is where you store the values you want committed with the project. The `sdkconfig` file itself is generated and should not be committed (add it to `.gitignore`). When prompting the agent to add a configurable option, mention the Kconfig name, type, default value, and valid range — the agent will generate a correct entry.

### Error Handling

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

### What to Always Tell the Agent

These four pieces of context make a meaningful difference in output quality:

| Context | Example |
|---|---|
| **Target chip** | `ESP32-C5` |
| **ESP-IDF version** | `v6.0.2` |
| **Component name** | `temperature_sensor` |
| **Log tag** | `"temp_sensor"` |

If your `AGENTS.md` is up to date with the target chip, IDF version, and project conventions, you won't need to repeat most of this in every prompt — the agent reads it automatically. Keep it current and it pays for itself immediately.

## Next step

[Lecture 3: Spec-Driven Development](../lecture-3)

[Back to workshop home](/workshops/ai-agent-coding-for-esp-idf/)
