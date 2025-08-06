---
title: "ESP-IDF Adv. - Lecture 1"
date: "2025-08-05"
series: ["WS00B"]
series_order: 2
showAuthor: false
summary: "In this lecture, we explore the ESP-IDF build system, built on CMake and Ninja. We focus on modular components, the Component Manager, and Board Support Packages (BSPs) for hardware abstraction. We also cover how to create custom components and manage configurations using sdkconfig files and build profiles, enabling flexible and reproducible builds."
---

## Introduction

In this lecture, we will explore ESP-IDF build system.

The ESP-IDF build system is built on top of __CMake__ and __Ninja__, two powerful tools that make project configuration and compilation fast and efficient. CMake is responsible for setting up your project and generating the necessary build files, while Ninja handles the actual building process with speed and minimal overhead.

To simplify development, ESP-IDF provides a command-line tool called `idf.py`. This tool acts as a front-end to CMake and Ninja, managing project setup, building, and flashing the firmware to your device using `esptool.py`. It also gives you access to a configuration menu where you can customize your project's settings, which are saved in a single `sdkconfig` file. IDEs like VSCode and Espressif IDE (Eclipse) usually offer wrappers around the `idf.py` tool.

In this workshop we will use the VSCode plugin.

## Modular development

To streamline the development of layered code, ESP-IDF offers a components system, paired with a powerful component manager.

### ESP-IDF Components

In ESP-IDF, projects are organized into __components__ --- self-contained, modular blocks of code that provide specific functionality such as drivers, libraries, protocols, utilities, or application logic. This structure simplifies code reuse, organization, and maintenance across complex applications.

For example, interfacing with a sensor can be handled by a dedicated component that encapsulates all communication and data processing logic, eliminating the need to rewrite code in every project.

The ESP-IDF framework itself is kept separate from your project and is referenced using the `IDF_PATH` environment variable. To build and flash your code, you’ll need the appropriate toolchain installed and accessible via your system’s `PATH`.

A typical component includes:

- Source code
- Header files
- `CMakeLists.txt` file for build configuration
- `idf_component.yml` file that describes dependencies and version information

This structure allows components to be easily integrated and managed within ESP-IDF projects, supporting modular development and code sharing [Component Management and Usage](https://docs.espressif.com/projects/esp-techpedia/en/latest/esp-friends/advanced-development/component-management.html).

### Component manager

The __IDF Component Manager__ is a tool designed to simplify the management of components in ESP-IDF projects. It allows developers to:

- Add components as dependencies to projects.
- Automatically download and update components from the [ESP Component Registry](https://components.espressif.com) or from git repositories.
- Manage component versions and dependencies reliably.

When you build your project, the Component Manager fetches all required components and places them in a `managed_components` folder, ensuring your project has everything it needs to compile and run. This streamlines the process of extending project functionality and encourages code reuse within the Espressif developer community.

### Board Support Packages (BSP) in ESP-IDF

One kind of ESP-IDF component is the __Board Support Package (BSP)__, a versioned component that encapsulates hardware initialization for a specific development board. BSPs provide pre-configured drivers and a consistent API for accessing onboard peripherals such as LEDs, buttons, displays, touch panels, audio codecs, and SD cards. Like any ESP-IDF component, a BSP can be integrated into a project via the component manager using `idf_component.yml`.

On a basic board like the ESP32-C6-DevKit, the BSP abstracts setup for components like the onboard button and addressable LED. On more complex platforms (e.g., ESP32-S3-BOX-3), it includes initialization for multiple peripherals such as displays and audio devices—packaged as a single, reusable component.

The main reasons for using a BSP are:

* **Peripheral initialization**: BSPs handle low-level setup (GPIOs, I2C, SPI, etc.) for supported hardware.
* **Reusable abstraction**: They expose a common API, enabling code reuse across different projects or board variants.
* **Faster bring-up**: With peripherals already configured, application logic can be developed and tested faster and more efficiently.

#### Custom and Generic BSPs

For unsupported or custom boards, developers can use generic BSPs (e.g., `esp_bsp_generic`, `esp_bsp_devkit`) and adjust hardware mappings via `menuconfig`. This allows BSPs to act as a flexible hardware abstraction layer for both official and custom hardware designs.

## How to create a component

Let's see how to create a component `led_toggle` starting from the `hello_world` example.

After you create a project from the example `hello_world`, your project folder will be as follows:

```bash
.
├── CMakeLists.txt
├── main
│   ├── CMakeLists.txt
│   └── hello_world_main.c
├── pytest_hello_world.py
├── README.md
├── sdkconfig
├── sdkconfig.ci
└── sdkconfig.old
```

To create a component, press <kbd>F1</kbd> to enter the Command palette and type:

* `> ESP-IDF: Create a new ESP-IDF Component`<br>
   &rarr; `led_toggle`

Now the folder tree changed to

```bash
.
├── CMakeLists.txt
├── components   # <--- new folder
│   └── led_toggle
│       ├── CMakeLists.txt
│       ├── include
│       │   └── led_toggle.h
│       └── led_toggle.c
├── main
│   ├── CMakeLists.txt
│   └── hello_world_main.c
├── pytest_hello_world.py
├── README.md
├── sdkconfig
├── sdkconfig.ci
└── sdkconfig.old
```

As you can see, a new `components` folder has been created and inside of it you can find the `led_toggle` component folder.

A component folder contains:

1. `CMakeLists.txt`: configuration used by the build system
2. `include` folder: which contains the headers (automatically passed to the linker)
3. `.c` file: the actual component code

<!-- When using components, you don't need to inform the build system about them, their sources and header files are already known to the build system. -->

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
You need to perform a full clean to see newly added components. In VSCode, run:<br>
`> ESP-IDF: Full Clean Project`.
{{< /alert >}}

Let's assume you have the following component header file:

```c
// led_toggle.h
#include "driver/gpio.h"

typedef struct {
    int gpio_nr;
    bool status;
}led_gpio_t;

esp_err_t config_led(led_gpio_t * led_gpio);
esp_err_t drive_led(led_gpio_t * led_gpio);
esp_err_t toggle_led(led_gpio_t * led_gpio);
```

__After a full clean__, you can simply include it in your main file and call its functions:

```c
#include "led_toggle.h"
//[...]
void app_main(void)
{
    printf("Hello world!\n");

    led_gpio_t led_board = { .gpio_nr = 5, .status = true };

    config_led(led_board)
    drive_led(led_board)
}
```

## Managing Configuration in ESP-IDF Projects

ESP-IDF projects handle configuration management primarily through two key files: `sdkconfig` and `sdkconfig.defaults`.

* `sdkconfig` contains the active configuration for your project. It is automatically generated and updated by configuration tools such as `idf.py menuconfig`, capturing all selected options.
* `sdkconfig.defaults` provides a set of default values for configuration options. It's especially useful for setting up consistent initial configurations for new builds or different environments (e.g., development, testing, production).

You can generate a `sdkconfig.defaults` file that reflects your current configuration using the following VSCode command (in the command palette):

```
> ESP-IDF: Save Default SDKCONFIG File (save-defconfig)
```

Which is a wrapper around:

```sh
idf.py save-defconfig
```

This command saves all configuration values _that differ_ from the ESP-IDF defaults into `sdkconfig.defaults`.


### Performance Optimization

Build configurations can also play a key role in optimizing system performance. The default settings in ESP-IDF represent a balanced compromise between performance, resource usage, and feature availability.

For production systems, designers often have specific optimization goals, e.g. reducing memory usage, increasing speed, or minimizing power consumption. These goals can be achieved by selecting and tuning the appropriate configuration options.

To assist with this, the official documentation provides a helpful [Performance Optimization Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/performance/index.html), which outlines strategies and configuration tips to help you reach your performance targets effectively.


### Using Multiple Default Files and Target-Specific Defaults

ESP-IDF supports multiple defaults files (`skconfig.xxx`), which can be specified via the `SDKCONFIG_DEFAULTS` environment variable or within your project's `CMakeLists.txt`. These files are listed using semicolons as separators and are applied in order. If there are overlapping configuration keys, the values in earlier files are overridden by those in the following ones. This layered approach allows you to:

* Maintain shared settings in one file
* Override them with environment-specific or product-specific defaults in others

You can also define _target-specific defaults_ using files named `sdkconfig.defaults.<chip>`, such as `sdkconfig.defaults.esp32s3`. These are only considered if a generic `sdkconfig.defaults` file exists (even if it’s empty). This mechanism supports fine-grained control over configurations for different Espressif chip variants within the same project.


### Managing Build Scenarios with Profile Files

Profile files allow you to encapsulate build settings for specific scenarios (e.g., development, debugging, production) into reusable files. These profiles contain `idf.py` command-line arguments and can streamline the build process by eliminating repetitive flag specification.

For example:

* `profiles/prod` – for production builds
* `profiles/debug` – for debugging builds

To build using a profile:

```sh
idf.py @profiles/prod build
```

You can also combine profile files with additional command-line arguments for even more flexibility. This approach promotes consistency and simplifies switching between build environments.
For more details, see the [ESP-IDF multi-config example](https://github.com/espressif/esp-idf/blob/master/examples/build_system/cmake/multi_config/README.md).


{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
The VSCode ESP-IDF extension lets you define multiple configurations via JSON file. It's planned to unify this approach with the CLI one in the near future. You can check the detail [in the documentation](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/additionalfeatures/multiple-projects.html#use-multiple-build-configurations-in-the-same-workspace-folder).
{{< /alert >}}

### Practical Example: Isolating Development and Production Builds

To maintain separate configurations for development and production:

1. Create a `sdkconfig.defaults` file for development.
2. Create production-specific files, such as `sdkconfig.prod_common` and `sdkconfig.prod1`.
3. Build with the production configuration using:

   ```sh
   idf.py -B build_prod1 -D SDKCONFIG_DEFAULTS="sdkconfig.prod_common;sdkconfig.prod1" build
   ```

This creates an isolated build directory (`build_prod1`) and applies the specified default configuration layers. As a result, you can maintain reproducible and isolated builds across different environments.


By effectively leveraging `sdkconfig.defaults`, multiple defaults files, and profile-based builds, ESP-IDF projects can achieve greater configurability, repeatability, and clarity across various development scenarios.

We will explore this topic more in-depth in the [assignment 1.3](../assignment-1-3/).

## Conclusion

The ESP-IDF build system provides a powerful foundation for developing embedded applications. With modular components, managed dependencies, and support for reusable Board Support Packages (BSPs), developers can build scalable and maintainable projects. Tools like `idf.py`, the Component Manager, and profile-based build configurations streamline both development and deployment workflows. By mastering these tools and practices, you'll be well-equipped to create robust firmware across a variety of hardware platforms and development scenarios.


> Next Step: [assignment_1_1](../assignment-1-1/)

## Additional information

* [What is the ESP Component Registry?](https://developer.espressif.com/blog/2024/10/what-is-the-esp-registry/)
* [IDF Component Manager and ESP Component Registry Documentation](https://docs.espressif.com/projects/idf-component-manager/en/latest/index.html)
