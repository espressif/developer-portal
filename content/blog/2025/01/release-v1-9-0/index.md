---
title: "ESP-IDF VS Code Extension v1.9.0 release"
date: 2025-01-17
showAuthor: false
disableComments: false
featureAsset: "img/featured/featured-vscode-extension-release.webp"
tags: ["News", "ESP-IDF extension", "VSCode", "Visual Studio Code", "IDE"]
authors:
- "radu-rentea"
---
We’re excited to announce the release of the [ESP-IDF VS Code Extension](https://github.com/espressif/vscode-esp-idf-extension) v1.9.0!
This update brings powerful new features, performance enhancements, and numerous improvements to streamline your development experience.
{{< youtube BdQzsFRoG2s >}}

## New Features and Improvements

**Enhanced User Experience**

- Added two new interactive walkthroughs: "Basic Usage Guide" and "Advanced Features" for better user onboarding.
- Improved project creation from examples with enhanced UI/UX.
- Enhanced framework selection in examples and new projects.
- Optimized UX/UI for creating projects from examples.

**Serial Device Management**

- Introduced new configuration options for serial port filtering with `idf.useSerialPortVendorProductFilter` and `idf.enableSerialPortChipIdRequest`.
- Added customizable USB PID/VID filters through `idf.usbSerialPortFilters`.
- Default filtering now shows only known USB serial ports based on product and vendor IDs.
- Added option to disable chip ID display in serial port list.

**Project Configuration**

- Enhanced support for multiple sdkconfig files in Project Configuration Editor with multiple profiles.
- Automated environment setup by computing ESP-IDF tools from `IDF_PATH` and `IDF_TOOLS_PATH`.
- Removed redundant configuration options in favor of automated path computation.
- Added notification for missing **compile_commands.json** file with generation option for better IntelliSense support.
- Improved ESP-IDF variables handling using `idf_tools.py export --format key-value`.

**Development Features**

- Added linker (ld) error display in VS Code 'Problems' window (Thanks to contributor [@GillesZunino](https://github.com/GillesZunino)).
- Implemented support for new ESP-IDF Size JSON format in binary analysis (ESP-IDF v5.3+).
- Added validation to prevent device reset during active debug sessions.
- Updated QEMU implementation with support for both ESP32 and ESP32-C3 targets.
- Enhanced telemetry reporting

## Bug Fixes

- Fixed monitor terminal reset issues when using separate window layouts.
- Fixed unit tests not refreshing when using the Refresh tests button.
- Fixed ESP-IDF constraint file version parsing to match ESP-IDF's naming convention (major.minor only).
- Fixed monitoring message display during flash failures.
- Fixed monitor device reset behavior during debug sessions.
- Fixed Docker configuration by using ESP-IDF tools version of QEMU.

Check the full [release notes](https://github.com/espressif/vscode-esp-idf-extension/releases/tag/v1.9.0) for more detailed information.

We value your feedback! If you encounter any issues or have suggestions for further improvements, don’t hesitate to let us know by creating a [GitHub issue](https://github.com/espressif/vscode-esp-idf-extension/issues).

Thank you for being part of the Espressif developer community—happy coding!
