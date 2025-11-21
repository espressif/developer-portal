---
title: "Manage multiple ESP-IDF build configurations with ease"
date: "2025-12-05"
showAuthor: false
authors:
  - "marek-fiala"
tags: ["ESP-IDF", "CMake", "Build System", "Configuration"]
summary: "Tired of juggling complex command-line arguments with endless `idf.py` flags? ESP-IDF v6.0 introduces a new feature, letting you switch between multiple build configuration. Learn how to structure your project, isolate sdkconfig files, and migrate from ad-hoc commands to clean, declarative builds."
---

As ESP-IDF projects grow more sophisticated, developers often need multiple build configurations: development builds with debug symbols, optimized production releases, size-constrained builds for specific hardware, and comprehensive testing setups. While ESP-IDF has always supported these scenarios, they typically required remembering complex command-line arguments and managing multiple build directories manually.

ESP-IDF v6.0 introduces a powerful solution: reusable configuration profiles, called presets, that handle all this complexity for you. These configuration presets make switching between development, production, and testing environments effortless. This is how the command changes:
 - Old: `idf.py -B build_prod -D SDKCONFIG_DEFAULTS="prod.cfg" build`
 - New: `idf.py --preset production build`

## Traditional build management

Let's first examine the current approach to managing multiple build configurations. Consider a project that needs:

- **Development builds**: Fast iteration with debug symbols
- **Production builds**: Optimized binaries for various hardware variants
- **Testing builds**: Special configurations for automated testing

Traditionally, you might handle this with complex command lines like:

```bash
# Development build
idf.py build

# Production variant 1
idf.py -B build_prod1 -D SDKCONFIG_DEFAULTS="sdkconfig.prod_common;sdkconfig.prod1" build

# Production variant 2
idf.py -B build_prod2 -D SDKCONFIG_DEFAULTS="sdkconfig.prod_common;sdkconfig.prod2" build

# Testing with custom settings
idf.py -B build_test -D SDKCONFIG_DEFAULTS="sdkconfig.test" -D SDKCONFIG="build_test/sdkconfig" build
```

## How configuration presets work

ESP-IDF v6.0 introduces support for build configuration presets, allowing you to define reusable build settings in JSON files. This feature is built on CMake Presets, a standard CMake feature that ESP-IDF now supports. Each preset can specify:

- **Build directory location** (`binaryDir`)
- **CMake cache variables** (including `SDKCONFIG`, `SDKCONFIG_DEFAULTS`, and optionally `IDF_TARGET`)
- **Generator preferences** (Ninja, Make, etc.)
- **Human-readable metadata** (display names and descriptions)

The key benefit is **declarative configuration**: instead of remembering complex command-line arguments, you define your configurations once in a file and reference them by name.

ESP-IDF will automatically detect and use configuration presets when either `CMakePresets.json` or `CMakeUserPresets.json` is present in your project root directory. Example of how preset configuration file looks like can be found later in section [Getting started with configuration presets.](#getting-started-with-configuration-presets)

### Working with build directories

One of the biggest advantages of this feature is clean build directory management. Each preset can specify its own build directory, allowing you to maintain multiple configurations simultaneously:

```bash
project/
├── CMakePresets.json
├── build/
│   ├── default/          # Development builds
│   ├── release/          # Release builds
│   ├── size-opt/         # Size-optimized builds
│   └── testing/          # Test builds
├── sdkconfig.defaults.common
├── sdkconfig.defaults.release
└── sdkconfig.defaults.size-opt
```

This structure provides several benefits:

- **Parallel builds**: Switch between configurations without rebuilding
- **Clean separation**: No cross-contamination between build types
- **Easy cleanup**: Remove specific build types without affecting others
- **Flexible configuration**: Presets can specify different optimization levels, debug settings, and target chips for various build scenarios

### Custom sdkconfig locations

By default, ESP-IDF places the `sdkconfig` file in your project root. With presets, you can keep configuration files organized by placing them in build directories:

```json
{
    "name": "isolated-config",
    "binaryDir": "build/isolated",
    "cacheVariables": {
        "SDKCONFIG": "./build/isolated/sdkconfig"
    }
}
```

This approach provides the following advantages:
- Keeps your project root clean
- Prevents accidental commits of development configurations
- Makes it clear which sdkconfig belongs to which build
- Enables easier automated testing of different configurations

### Setting default selection with environment variable

For team workflows, you can set default preset using the environment variable `IDF_PRESET`, for your shell session.

Unix:
```bash
export IDF_PRESET=release  # bash
```

Windows:
```PowerShell
$ENV:IDF_PRESET=release  # PowerShell
```

```bash
# Now these commands use the 'release' preset automatically
idf.py build
idf.py flash monitor
```

This is particularly useful in CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Build production firmware
  env:
    IDF_PRESET: release
  run: |
    idf.py build
    idf.py size
```

### Selection logic

ESP-IDF follows a clear precedence order for preset selection:

1. **Command-line argument**: `idf.py --preset my-preset build`
2. **Environment variable**: set environmental variable `IDF_PRESET`.
3. **Automatic selection**:
   - If a preset named `default` exists, use it
   - Otherwise, use the first preset in the preset configuration file

This makes preset usage flexible while providing sensible defaults.

## Getting started with configuration presets

### Step 1: Create your JSON file

Create a `CMakePresets.json` file in your project root directory. Here's a comprehensive example that demonstrates multiple production variants:

```json
{
    "version": 3,
    "configurePresets": [
        {
            "name": "default",
            "binaryDir": "build/default",
            "displayName": "Development Configuration",
            "description": "Fast builds for development and debugging",
            "cacheVariables": {
                "IDF_TARGET": "esp32s3",
                "SDKCONFIG": "./build/default/sdkconfig"
            }
        },
        {
            "name": "release",
            "binaryDir": "build/release",
            "displayName": "Release Build",
            "cacheVariables": {
                "SDKCONFIG_DEFAULTS": "sdkconfig.defaults.common;sdkconfig.defaults.release",
                "SDKCONFIG": "./build/release/sdkconfig"
            }
        },
        {
            "name": "size-opt",
            "binaryDir": "build/size-opt",
            "displayName": "Size Optimized Build",
            "cacheVariables": {
                "SDKCONFIG_DEFAULTS": "sdkconfig.defaults.common;sdkconfig.defaults.size-opt",
                "SDKCONFIG": "./build/size-opt/sdkconfig"
            }
        },
        {
            "name": "testing",
            "binaryDir": "build/testing",
            "displayName": "Testing Configuration",
            "cacheVariables": {
                "SDKCONFIG_DEFAULTS": "sdkconfig.defaults.testing",
                "SDKCONFIG": "./build/testing/sdkconfig"
            }
        }
    ]
}
```

> **Note**: The `version` field is set to `3` to match the CMake Presets schema supported by ESP-IDF's minimum required CMake version (3.22.1). If you're using a newer CMake version, you can use a higher version number for additional features.

### Step 2: Create your configuration files

Alongside your JSON file, create the corresponding configuration files:

**sdkconfig.defaults.common**:
```bash
# Common settings for all build variants
CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ_160=y
CONFIG_ESP_MAIN_TASK_STACK_SIZE=3584
CONFIG_FREERTOS_HZ=100
```

**sdkconfig.defaults.release**:
```bash
# Release build optimizations
CONFIG_COMPILER_OPTIMIZATION_SIZE=y
CONFIG_LOG_DEFAULT_LEVEL_WARN=y
```

**sdkconfig.defaults.size-opt**:
```bash
# Aggressive size optimizations
CONFIG_COMPILER_OPTIMIZATION_SIZE=y
CONFIG_BOOTLOADER_LOG_LEVEL_NONE=y
```

Notice how different presets use different combinations of configuration files through `SDKCONFIG_DEFAULTS`. The common settings are shared via `sdkconfig.defaults.common`, while build-specific optimizations are applied through additional files like `sdkconfig.defaults.release` or `sdkconfig.defaults.size-opt`. Additionally, the `default` preset shows how to set the `IDF_TARGET` variable to specify the target chip, which is optional but helps maintain a consistent development target.

**sdkconfig.defaults.testing**:
```bash
# Testing and debugging settings
CONFIG_LOG_DEFAULT_LEVEL_DEBUG=y
CONFIG_ESP_SYSTEM_PANIC_PRINT_HALT=y
CONFIG_FREERTOS_CHECK_STACKOVERFLOW_CANARY=y
```

### Step 3: Use your presets

Now you can build, flash, and monitor with clean, simple commands:

```bash
# Development build (automatically selects 'default' preset)
idf.py build

# Production builds with different optimizations
idf.py --preset release build
idf.py --preset size-opt build

# Flash and monitor with specific preset
idf.py --preset release -p /dev/ttyUSB0 flash monitor

# Testing build
idf.py --preset testing build
```

## Current limitations

There is one current limitation to be aware of: the `inherits` field for preset inheritance isn't currently supported. If you try to use it, ESP-IDF will show a warning and the inheritance will be ignored.

## Migrating from manual build configurations

If you're currently using complex build scripts or manual command-line arguments, here's how to migrate:

### Step 1: Audit your current configurations

List all the different ways you currently build your project:

```bash
# Current manual commands
idf.py build                                                    # Development
idf.py -B build_prod -D SDKCONFIG_DEFAULTS="sdkconfig.defaults.production"  # Production
idf.py -B build_test -D SPECIAL_FLAG=1                          # Testing
```

### Step 2: Extract common patterns

Identify shared settings and create defaults files:

 - **sdkconfig.defaults** (development - already exists)
 - **sdkconfig.defaults.production**
 - **sdkconfig.defaults.testing**

### Step 3: Create equivalent presets

Convert each command pattern to an equivalent entry:

```json
{
    "version": 3,
    "configurePresets": [
        {
            "name": "default",
            "binaryDir": "build",
            "displayName": "Development"
        },
        {
            "name": "production",
            "binaryDir": "build_prod",
            "cacheVariables": {
                "SDKCONFIG_DEFAULTS": "sdkconfig.defaults.production"
            }
        },
        {
            "name": "testing",
            "binaryDir": "build_test",
            "cacheVariables": {
                "SDKCONFIG_DEFAULTS": "sdkconfig.defaults.testing",
                "SPECIAL_FLAG": "1"
            }
        }
    ]
}
```

### Step 4: Update documentation and scripts

Replace build instructions:
- Old: "Run `idf.py -B build_prod -D SDKCONFIG_DEFAULTS="sdkconfig.defaults.production" build`"
- New: "Run `idf.py --preset production build`"

## Conclusion

Configuration presets transform ESP-IDF build management from a manual, error-prone process into a declarative, maintainable system. By defining your build configurations once in `CMakePresets.json`, you can:

- **Eliminate command-line complexity** with simple preset names
- **Maintain multiple configurations** without cross-contamination
- **Standardize team workflows** with shared preset definitions
- **Integrate seamlessly** with IDEs and CI/CD pipelines
- **Scale** as your project grows more complex

Whether you're managing a simple project with development and production builds, or a complex system with different optimization levels and testing configurations, this approach provides the structure and simplicity you need to focus on building great products instead of wrestling with build systems.

## What's next?

- Explore the [ESP-IDF multi-config example](https://github.com/espressif/esp-idf/tree/release/v6.0/examples/build_system/cmake/multi_config) for hands-on practice
- Check out the [CMake Presets documentation](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) for advanced features
- Consider contributing preset examples for common ESP-IDF use cases

Start small with a simple development/production split, then expand your build configurations as your workflow matures. Your future self (and your teammates) will thank you for the clarity and consistency that configuration presets brings to your ESP-IDF projects.
