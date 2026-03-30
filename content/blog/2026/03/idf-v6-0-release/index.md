---
title: "Announcing ESP-IDF v6.0"
date: 2026-03-20
showAuthor: false
authors:
  - marius-vikhammer
tags:
  - ESP-IDF
  - Release
  - IoT
summary: "We're excited to announce the long-awaited release of ESP-IDF 6.0! This article highlights the key changes and improvements not only to ESP-IDF itself, but also to the broader ESP-IDF tooling ecosystem, all designed to enhance your developer experience."
---
## What's New in ESP-IDF 6.0: The Next Step Forward

ESP-IDF 6.0 introduces improvements across the full development workflow, from easier installation and more flexible tooling to library updates, security changes, and broader hardware support. In this article, we'll walk through the most important highlights of the release and point out a few key breaking changes to keep in mind when upgrading from v5.x.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5" >}}
**Upgrading from v5.x?**

ESP-IDF 6.0 includes breaking changes: removed legacy drivers, compiler warnings treated as errors, and a new crypto API layer. See the [Breaking Changes](#breaking-changes-know-before-you-upgrade) section before upgrading.

We have prepared a [Migration Guide](https://docs.espressif.com/projects/esp-idf/en/v6.0/esp32/migration-guides/release-6.x/6.0/index.html) to help you through the transition.
{{< /alert >}}

Here are the key changes and improvements.

## Getting Started Just Got Easier: ESP-IDF Installation Manager

For new ESP-IDF users, setting up a development environment is now easier than ever. The new ESP-IDF Installation Manager (EIM) is a unified cross-platform tool that simplifies the entire setup process for ESP-IDF and your preferred IDE.

EIM offers both a graphical interface for those who prefer visual workflows and a full-featured CLI for automation and CI/CD pipelines. Install it using familiar package managers, WinGet on Windows, Homebrew on macOS, or APT/RPM on Linux, and you're ready to go.

Key features include:
- **Multiple version management**: Install and switch between different ESP-IDF versions from a single dashboard
- **Offline installation**: Set up your environment in offline environments using pre-downloaded archives
- **CI/CD integration**: Headless installation mode and a GitHub Actions integration make automated builds straightforward
- **Automatic prerequisites**: On Windows, EIM detects and installs missing dependencies automatically, on Linux and macOS the package managers will take care of it

Note that `export.sh` and its siblings is no longer needed, EIM replaces it with version-specific activation scripts, making environment setup consistent across all platforms.

For a full walkthrough of EIM's features, see the [EIM v0.8 release article](https://developer.espressif.com/blog/2026/03/esp-idf-installation-manager/) or jump straight to the [EIM documentation](https://docs.espressif.com/projects/idf-im-ui/en/latest/).


## Smaller and Faster: Picolibc Replaces Newlib

The default C library has changed from Newlib to Picolibc. Designed specifically for embedded systems, Picolibc offers a smaller memory footprint and better performance characteristics for resource-constrained devices. Benchmarks will vary depending on which functonality is used, and if Newlib or Newlib Nano is available in ROM on your chip, but for one such comparision see [Newlib vs Picolibc comparison](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/migration-guides/release-6.x/6.0/system.html#comparison-of-newlib-vs-picolibc).

For most applications, this change is transparent, your code will compile and run without modification. If you encounter any issues, you can switch back to the Newlib implementation using the `CONFIG_LIBC_NEWLIB` Kconfig option.

## Security First: PSA Crypto API

ESP-IDF 6.0 upgrades MbedTLS to version 4.x and migrates cryptographic operations to the PSA Crypto API (Platform Security Architecture). This industry-standard API provides a cleaner, more portable interface for cryptographic operations and future-proofs your security implementations.

Applications relying on legacy `mbedtls_*` cryptographic primitives will need to migrate to PSA Crypto APIs. While this requires changes, the resulting code is more maintainable and is compliant with security standards. The [migration guide](https://docs.espressif.com/projects/esp-idf/en/v6.0/esp32/migration-guides/release-6.x/6.0/security.html) provides detailed guidance for updating your crypto implementations.

## Build System and Tooling Improvements

ESP-IDF 6.0 brings several improvements to the build system and developer tooling, ranging from a next-generation CMake architecture to more flexible configuration management.

### New CMake Build System (Preview)

ESP-IDF Build System v2 is now available in Technical Preview, introducing a more modern and flexible CMake-based architecture that addresses key limitations of the current v1 system while remaining backward compatible with most existing components. By aligning more closely with standard CMake practices, v2 makes it easier to integrate ESP-IDF into larger CMake-based projects and supports native CMake component definitions using familiar commands like `add_library()` and `target_link_libraries()`.

The major architectural shift in v2 is the removal of v1's early component evaluation phase, allowing components to be evaluated on demand and to declare dependencies conditionally using Kconfig variables. This enables more dynamic, configuration-driven builds and simplifies the overall build process by discovering and evaluating components in a single pass. While most v1 components will work unchanged, those relying on v1-specific behaviors may need updates.

For more details, including a migration guide, see the [Build System v2 documentation](https://docs.espressif.com/projects/esp-idf/en/v6.0/esp32/api-guides/build-system-v2.html). We welcome your feedback on the new build system at [GitHub issue #17833](https://github.com/espressif/esp-idf/issues/17833).

### Custom idf.py Extensions

ESP-IDF v6.0 adds a new extension system for `idf.py` that lets you embed your own commands and tools right into the standard ESP-IDF CLI. Instead of juggling separate scripts, you can now define custom subcommands that behave like built-ins and use shared options such as `--port` or `--build-dir`.

There are two ways to extend it: component-based extensions (project-specific tools via an `idf_ext.py` file) and Python package extensions (reusable tools installed into your Python environment). Both approaches integrate seamlessly with `idf.py --help` and task ordering.

For more details, see the Developer Portal article [Extending idf.py: Create custom commands for your ESP-IDF workflow](https://developer.espressif.com/blog/2025/10/idf_py_extension).

### Improved Kconfig Default Value Handling

ESP-IDF v6.0 changes how default configuration values are tracked in `sdkconfig`. Previously, all values were written to `sdkconfig` without any distinction between user-set values and defaults, which could cause stale defaults to persist silently after a component update or Kconfig change.

In v6.0, the configuration system marks each default value with a `# default:` annotation in `sdkconfig`, allowing it to re-evaluate defaults dynamically when dependencies change, for example when running `idf.py menuconfig`. This means that if a Kconfig condition changes, the affected options will correctly reflect the new default rather than silently retaining the old one.

For a deep dive into how this works and what it means when upgrading components, see the full article on the Developer Portal [Changes in the Configuration System in ESP-IDF v6: Default Values](https://developer.espressif.com/blog/2025/12/configuration-in-esp-idf-6-defaults/).

### Build Configuration Presets

Managing multiple build configurations (development, production, size-optimized, testing) has traditionally meant remembering long `idf.py` command lines with multiple `-D` flags and `-B` directories. ESP-IDF v6.0 adds support for **CMake Presets**, letting you define all your build configurations declaratively in a `CMakePresets.json` file and reference them by name:

```bash
# Before
idf.py -B build_prod -D SDKCONFIG_DEFAULTS="sdkconfig.defaults.production" build

# After
idf.py --preset production build
```

Each preset can specify its own build directory, `sdkconfig` location, `SDKCONFIG_DEFAULTS` chain, and other build settings such as IDF_TARGET or additional CMake cache variables. This allows multiple configurations coexist without cross-contamination. A default preset can also be set for your shell session via the `IDF_PRESET` environment variable, which is handy for CI/CD pipelines.

For a full walkthrough including examples and migration tips, see the Developer Portal article [Manage multiple ESP-IDF build configurations with ease](https://developer.espressif.com/blog/2025/12/cmake_presets/).

### AI Integration: MCP Server

ESP-IDF 6.0 ships with a built-in **MCP (Model Context Protocol) server**, enabling AI assistants to interact directly with your ESP-IDF project through a standardized protocol. The server exposes tools for the most common development operations: building, flashing, setting the target, and cleaning, as well as resources to query the current project configuration, build status, and connected devices.

The recommended way to launch the server is via `eim run`, which uses the [ESP-IDF Installation Manager (EIM)](https://github.com/espressif/idf-im-cli) to spawn a new process with the ESP-IDF environment already set up:

```bash
eim run "idf.py mcp-server"
```

This feature is particularly useful for IDE-based AI agents like VS Code Copilot or Cursor, which run outside an active ESP-IDF environment.

To add the MCP server to your IDE, use the following configuration:

{{< tabs groupId="mcp-ide" >}}
{{% tab name="VS Code" %}}
Add the following to your `mcp.json`:
```json
{
  "servers": {
    "esp-idf-eim": {
      "command": "eim",
      "args": [
        "run",
        "idf.py mcp-server"
      ],
      "env": {
        "IDF_MCP_WORKSPACE_FOLDER": "${workspaceFolder}"
      }
    }
  }
}
```
{{% /tab %}}
{{% tab name="Cursor" %}}
Add the following to your `mcp.json`:
```json
{
  "mcpServers": {
    "esp-idf-eim": {
      "command": "eim",
      "args": [
        "run",
        "idf.py mcp-server"
      ],
      "env": {
        "IDF_MCP_WORKSPACE_FOLDER": "${workspaceFolder}"
      }
    }
  }
}
```
{{% /tab %}}
{{< /tabs >}}

The `mcp` feature must be installed via EIM. A dedicated developer portal article with a full walkthrough is coming soon.

For more information about how to install and use the MCP server, see [IDF Programming Guide](https://docs.espressif.com/projects/esp-idf/en/v6.0/esp32/api-guides/tools/idf-py.html#esp-idf-mcp-server)

## Wi-Fi Enhancements

ESP-IDF 6.0 expands Wi-Fi capabilities with new proximity-based service discovery and improved WPA3 support, making it easier to build modern, standards-compliant wireless applications.

### Unsynchronized Service Discovery (USD)

ESP-IDF 6.0 adds support for **Wi-Fi Aware Unsynchronized Service Discovery (USD)**, a lightweight proximity-based service discovery mechanism defined in the Wi-Fi Aware specification. Unlike the existing synchronized NAN support, where devices must first join a cluster and align discovery windows, USD lets devices advertise and find services by exchanging Wi-Fi Action frames directly, with no AP and no cluster synchronization required. Unlike synchronised NAN, USD protocol does not support NAN datapath.

A Publisher broadcasts a service on all channels it supports and permitted by the regulatory domain. A Subscriber - which is typically stationed on a fixed channel - discovers the Publisher and the two devices can exchange communication payloads via Action frames. USD is well-suited for proximity-based discovery and short communication mechanisms such as device commissioning, configuration and status exchange. One of the primary use cases for USD is Wi-Fi based commissioning for Matter devices.

Note that USD is marked as an **experimental feature** in v6.0. The existing synchronized NAN configuration has also been renamed (`wifi_nan_config_t` → `wifi_nan_sync_config_t`, `CONFIG_ESP_WIFI_NAN_ENABLE` → `CONFIG_ESP_WIFI_NAN_SYNC_ENABLE`) to cleanly separate the two modes, so check the migration guide if you use NAN today.

### WPA3 Compatible Mode

For access points that need to serve both WPA2 and WPA3 clients simultaneously, v6.0 adds a new `wpa3_compatible_mode` flag to `wifi_ap_config_t` and  a `disable_wpa3_compatible_mode` flag to `wifi_sta_config_t`. When enabled, the AP advertises WPA3 SAE capabilities via RSN Override vendor IEs (per the [Wi-Fi Alliance WPA3™ Specification Version 3.4](https://www.wi-fi.org/system/files/WPA3%20Specification%20v3.4.pdf)) while continuing to accept WPA2-PSK connections. WPA3-capable clients which support RSN override (compatibility mode) negotiate SAE automatically; legacy clients connect as usual. On the station side, disable_wpa3_compatible_mode controls whether the device can connect to WPA3-Personal RSN override (compatibility mode) APs. This is a standards-based alternative to the existing `WIFI_AUTH_WPA2_WPA3_PSK` mixed mode for deployments that want cleaner WPA2→WPA3 migration

## Safe Bootloader OTA Updates

One of the most requested features for field-deployed devices is the ability to update the bootloader over-the-air. Traditionally, this has been a risky operation, if power is lost during the update, the device could become unbootable.

ESP-IDF 6.0 introduces **recovery bootloader support** on ESP32-C5 and ESP32-C61. On these chips, the ROM bootloader can fall back to a recovery partition if the primary bootloader fails to load. Before updating the bootloader, your application creates a backup in a dedicated recovery partition. If the update fails or power is lost mid-write, the device boots from the recovery bootloader instead of bricking.

The workflow is straightforward:
1. Enable `CONFIG_BOOTLOADER_RECOVERY_ENABLE` and configure the recovery partition offset
2. Define both primary and recovery bootloader partitions in your partition table
3. Use the `esp_https_ota` APIs to download and install the new bootloader

For chips without ROM-level recovery support, bootloader OTA is still possible but carries inherent risk, there's no fallback if the final write is interrupted. The new [partitions_ota](https://github.com/espressif/esp-idf/tree/v6.0/examples/system/ota/partitions_ota) example demonstrates both safe and unsafe update paths, along with OTA for the partition table and storage partitions.

## Release Notes Database

Starting from v6.0, ESP-IDF release notes are published using our new [release notes database](https://release-notes.espressif.tools/). This provides:

- A better viewing experience for release notes
- The ability to compare releases and see all changes between them, helpful when planning an upgrade from an older version to v6.0

## New Chip and Hardware Support

ESP-IDF 6.0 continues to expand hardware coverage, with two chips graduating to full support, two new chips getting preview support and several new silicon revisions across the portfolio.

| Chip | Status |
|------|--------|
| ESP32-C5 | Newly fully supported (graduated from preview) |
| ESP32-C61 | Newly fully supported (graduated from preview) |
| ESP32-H21 | Preview |
| ESP32-H4 | Preview |


## Breaking Changes: Know Before You Upgrade

ESP-IDF 6.0 is a cleanup release that removes deprecated functionality. Key changes include:

- **Legacy drivers removed**: ADC, DAC, I2S, Timer Group, PCNT, MCPWM, RMT, and Temperature Sensor legacy drivers have been removed. Migrate to the new driver APIs.
- **Warnings as errors**: Default compiler warnings are now treated as errors. Disable with `CONFIG_COMPILER_DISABLE_DEFAULT_ERRORS` if needed during migration.
- **Component relocations**: Several components have moved to the ESP Component Registry, including `wifi_provisioning` (now `network_provisioning`), `cJSON`, and `esp-mqtt`.
- **Crypto API changes**: Legacy MbedTLS crypto APIs are being phased out in favor of PSA Crypto.

We highly recommend consulting the [migration guide](https://docs.espressif.com/projects/esp-idf/en/v6.0/) when upgrading from v5.x.

## Get Started with ESP-IDF 6.0

ESP-IDF v6.0 is available now. We encourage you to try it out and share your feedback through [GitHub issues](https://github.com/espressif/esp-idf/issues).

- [ESP-IDF v6.0 Documentation](https://docs.espressif.com/projects/esp-idf/en/v6.0/)
- [Full Release Notes](https://release-notes.espressif.tools/release/6.0)
- [Migration Guide](https://docs.espressif.com/projects/esp-idf/en/v6.0/migration-guides/)

## Conclusion

[ESP-IDF 6.0 is out now](https://github.com/espressif/esp-idf/releases/tag/v6.0). Whether you're starting a new project or upgrading an existing one, we hope you find something useful and interesting in this release. As always—we're excited to see what you'll build with it.
