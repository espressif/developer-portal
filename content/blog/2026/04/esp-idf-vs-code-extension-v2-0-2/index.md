---
title: "ESP-IDF VS Code Extension: What's New in v2.0.2"
date: 2026-04-15
authors:
  - radu-rentea
tags:
  - ESP-IDF
  - "VS Code Extension"
  - Release
  - Tooling
summary: "ESP-IDF VS Code Extension v2.0.2 introduces a new setup flow powered by Espressif Installation Manager and rounds up the major improvements delivered across the v1.10.x and v1.11.x releases, from AI-assisted workflows to richer debugging and project setup tools."
---

This article covers releases v1.10.0, v1.10.1, v1.11.0, v1.11.1, and v2.0.2 of the [ESP-IDF VS Code Extension](https://github.com/espressif/vscode-esp-idf-extension).

We are excited to share a roundup of everything that has landed in the ESP-IDF VS Code Extension across the past several releases, culminating in v2.0.2, the most significant update to the extension's setup experience since its initial release.

From deeper debugging tools and AI-assisted development to an entirely new way of installing ESP-IDF, these releases represent a major step forward for Espressif's VS Code developer experience.

## v2.0.2 - EIM Integration and Setup Overhaul

The headline change in v2.0.2 is the full integration of the [Espressif Installation Manager (EIM)](https://docs.espressif.com/projects/idf-im-ui/en/latest/) into the extension's setup flow. This replaces the old `ESP-IDF: Configure ESP-IDF extension` wizard and the manual `idf.espIdfPath` / `idf.toolsPath` extension settings.

> If you haven't read our dedicated EIM release article, we recommend starting there: [ESP-IDF Installation Manager v0.8](https://developer.espressif.com/blog/2026/03/esp-idf-installation-manager/).

### Why We Made This Change

Previously, installing ESP-IDF via the extension required users to navigate a custom setup wizard embedded directly in VS Code. It worked, but it was hard to maintain, inconsistent across platforms, and disconnected from ESP-IDF installations done outside of VS Code, for example on the command line, in CI, or by another IDE.

EIM solves all of this. It is a standalone, cross-platform tool available via `winget`, `brew`, `apt`, `dnf`, or a direct binary download that manages ESP-IDF installations uniformly regardless of which tool triggered the install. Once EIM has installed ESP-IDF, any tool that understands EIM's `eim_idf.json` manifest can discover and use those installations.

### How It Works Now

After installing the extension, open the Command Palette and run:

```text
ESP-IDF: Open ESP-IDF Installation Manager
```

Depending on your environment, EIM will open in one of two ways:

- **Graphical interface (GUI):** On a desktop machine, EIM opens as a standalone window that guides you step by step through selecting and installing an ESP-IDF version, with no command line required.
- **Terminal wizard (WSL):** On WSL, the extension automatically runs EIM as an interactive terminal program that walks you through the same steps in your console.

Once ESP-IDF is installed through EIM, the extension reads the `eim_idf.json` file it produces and discovers all installed versions automatically, with no manual path configuration needed.

> **Note:** Full terminal wizard support for other remote environments such as SSH, Dev Containers, and Codespaces is not yet available in v2.0.2 and is planned for v2.1.0. If you need to force the terminal wizard mode in the meantime, you can set the `idf.eimExecutableArgs` extension setting to `["wizard"]`.

> TODO: Add a screen recording showing `ESP-IDF: Open ESP-IDF Installation Manager` from the Command Palette, the EIM GUI launch, ESP-IDF version selection and installation, and a return to VS Code to select the installed version.

For a detailed walkthrough of each step in the GUI installer, refer to the [Online Installation using EIM GUI](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/windows-setup.html#online-installation-using-eim-gui) guide.

To switch between multiple installed ESP-IDF versions, use:

```text
ESP-IDF: Select Current ESP-IDF Version
```

The selected version is stored in the workspace state as `idf.currentSetup`, and all required environment variables are set automatically.

> **Backward compatibility:** Existing setups using environment variables in `idf.customExtraVars` continue to work. The extension will use those over any EIM-managed setup when present. See the updated [installation documentation](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/installation.html) for full details.

### What Was Removed

This release cleans up a significant amount of legacy surface area:

- **Old Setup Wizard** (`ESP-IDF: Configure ESP-IDF extension`) - replaced by EIM
- **`idf.espIdfPath` and `idf.toolsPath` settings** - replaced by environment variables derived from the selected EIM setup
- **Old debug adapter** - replaced by the Eclipse CDT Debug Adapter, added in v1.8.0
- **ESP-MDF, ESP-Matter, ESP-HomeKit framework integrations** - these frameworks are now available in the [ESP Component Registry](https://components.espressif.com/), which is accessible directly from the extension. Note that **ESP-ADF support is retained**.
- The `ESP-IDF: Show Examples` command has been removed in favor of `ESP-IDF: New Project`, which now provides a superset of its functionality with better customization options.

### New Project Wizard: Templates First

The New Project Wizard now shows available project templates before asking for configuration details. This makes it much easier to browse and choose a starting point before committing to a configuration.

### Debug Image Viewer

v2.0.2 also ships a new **Debug Image Viewer** that lets you visualize C image arrays directly from your debugging session or from files on disk.

Out of the box, the viewer supports **OpenCV** and **LVGL** image formats. You can also configure custom image data types as long as you can provide a `UInt8Array` and a size or length, making it adaptable to any frame buffer layout your firmware uses.

> TODO: Add a screen recording showing a paused debug session, a right-click on a `UInt8Array` image variable, the `View Image` action, and the rendered output. Optionally include loading a `.c` image file directly.

## v1.11.0 / v1.11.1 - AI, DevKits, and a Richer Developer Experience

### AI Integration with GitHub Copilot Chat

v1.11.0 introduces a **Language Tool API integration** for GitHub Copilot Chat. When you use Copilot Chat in a project with the ESP-IDF extension active, it gains ESP-IDF-specific context such as your IDF version, target chip, and project configuration, enabling more accurate and relevant suggestions for embedded development tasks.

> TODO: Add a screen recording showing Copilot Chat answering an ESP-IDF-specific question with extension-provided context.

### DevKit Support

A long-requested feature: the extension now has explicit **DevKit support**. When you select your target chip and board, the extension can recognize official Espressif development kits and apply board-specific defaults, reducing the manual configuration needed when starting a project on a known board.

> TODO: Add a screenshot of the `Set Espressif Device Target` flow with DevKit options visible in the board selection list.

### Classic Menuconfig in the Editor Panel

The SDK Configuration Editor now includes a **classic Menuconfig view** embedded directly inside VS Code, alongside the existing graphical editor. This gives developers who prefer the terminal-style navigation of `idf.py menuconfig` a familiar experience without leaving the IDE.

> TODO: Add a GIF showing the `Open Classic Menuconfig Terminal` command in use.

### Modernized UI: VS Code Native Styling

All extension webviews have been updated to use **VS Code's native UI toolkit**, making panels like the New Project Wizard, SDK Configuration Editor, and others feel consistent with the rest of VS Code and properly respect your color theme, whether light, dark, or custom.

### Unity Test Runner

v1.11.0 replaces the previous Pytest-based test runner with a dedicated **Unity Test Runner and Parser** built specifically for ESP-IDF unit tests. The Unity framework is the standard testing framework used in ESP-IDF, and this native integration provides accurate test discovery, execution, and result parsing within VS Code's Test Explorer.

### OpenOCD Hints in the Hints Viewer

OpenOCD error messages are now surfaced in the **Hints Viewer** panel alongside ESP-IDF compile hints. If a debug session fails to start or encounters a hardware connection issue, the Hints Viewer will show contextual guidance from OpenOCD rather than requiring you to parse raw output logs.

### Smarter Serial Port Detection

The extension now supports **auto-detecting the serial port** using `esptool.py`, and you can configure a default port with a new setting. This is particularly useful in environments with multiple USB-serial adapters connected, where previously you had to manually select the right port on every build and flash cycle.

### Disassembly View: Function Names

The Disassembly view now displays **function names** alongside addresses, making it significantly easier to navigate and understand disassembled code during debugging sessions.

### Create Empty Project Command

A new `ESP-IDF: Create Empty Project` command is available for users who want a minimal starting point with just the `CMakeLists.txt` and main component skeleton, without any sample code.

### `.gitignore` Generated on Project Creation

All new projects now include a sensible `.gitignore` by default, preventing build artifacts, optional `sdkconfig`, and `managed_components` from being accidentally committed to version control.

### Other Notable v1.11.x Additions

- **Clang install prompt**: If Clang is needed but not installed, the extension now proactively prompts for installation.
- **Customize PyPI index URL** in the setup wizard - useful for networks requiring a private PyPI mirror.
- **Extend JTAG flash arguments** via a new configuration setting.
- **Check OpenOCD is running** before launching a debug session, preventing confusing startup failures.
- **Allow additional files and directories** in the Full Clean command.
- **Customize Pytest glob pattern** and unit test services.
- **Pre-release campaign notification** - users can now opt into pre-release builds directly from within VS Code.

## v1.10.0 / v1.10.1 - Debugging Power and Partition Flexibility

### Variable Inspection Enhancements

v1.10.1 brings three improvements to the debugging experience:

- **Evaluate variables on hover**: Hover over a variable in your source code during a debug session to instantly see its current value without needing to add it to the Watch panel.
- **View variables as Hex**: Toggle the display of integer variables between decimal and hexadecimal directly in the Variables panel, essential when working with register values, addresses, or bitmasks.
- **Data breakpoints**: Set breakpoints that trigger when a specific memory location is read or written, enabling powerful watchpoint-style debugging without leaving VS Code.

> TODO: Add a screen recording showing hover evaluation, hex display toggling, and creation of a data breakpoint.

### Partition-Specific Flashing

v1.10.0 introduces granular control over the flash process:

- **Build, flash, and read individual partitions** such as the app, bootloader, or partition table independently.
- **Read the partition table directly from a connected device.**
- **Flash a specific binary to a specific partition** without reflashing the entire device.

This is a significant workflow improvement for iterative development, especially when the bootloader is stable and you only need to update the application.

> TODO: Add a screen recording showing partition-specific flashing from the ESP-IDF sidebar or command flow.

### Clang Project Settings Configuration

Clang-based toolchain support for static analysis and IntelliSense now has a **dedicated configuration UI** in the extension settings, making it easier to configure the Clang path and related options on a per-project basis.

### ESP-IDF VS Code Profile Templates

v1.10.1 introduces **VS Code Profile templates** tailored for ESP-IDF development. VS Code Profiles let you save and share specific extension configurations, settings, and keybindings, and these templates give you a curated starting point optimized for Espressif development.

### Active OpenOCD Board Indicator

When selecting an OpenOCD board configuration, the extension now **highlights the currently active board** in the selection list, making it immediately clear which configuration is in use and reducing accidental mismatches.

### QEMU Integration Improvements

v1.10.0 extends QEMU support by using `idf qemu` for both debug and monitor workflows, and introduces a new `idf.qemuExtraArgs` setting for passing additional arguments to the QEMU emulator, enabling more fine-grained emulation configuration without modifying launch tasks directly.

### `idf.monitorPort` Setting

A dedicated `idf.monitorPort` setting lets you specify a different serial port for the IDF Monitor separately from the flash port, useful when working with setups where flash and monitor use different physical connections.

## Looking Ahead

With v2.0.2, the ESP-IDF VS Code Extension has shed a significant amount of legacy code and is now anchored to a consistent, cross-platform toolchain management story through EIM. The old setup wizard path has been retired, and the extension is now leaner and more focused on the editing, building, flashing, and debugging experience.

Future improvements will continue to build on this foundation, including better AI-assisted development and richer debugging tools.

## Resources

- **Extension on VS Code Marketplace**: [espressif.esp-idf-extension](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension)
- **Extension Documentation**: [docs.espressif.com/projects/vscode-esp-idf-extension](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/index.html)
- **EIM Documentation**: [docs.espressif.com/projects/idf-im-ui](https://docs.espressif.com/projects/idf-im-ui/en/latest/)
- **EIM Downloads**: [dl.espressif.com/dl/eim](https://dl.espressif.com/dl/eim/index.html)
- **Extension GitHub Repository**: [github.com/espressif/vscode-esp-idf-extension](https://github.com/espressif/vscode-esp-idf-extension)
- **Report an Issue**: [GitHub Issues](https://github.com/espressif/vscode-esp-idf-extension/issues)

*Thank you to all community contributors across these releases, including [@SinglWolf](https://github.com/SinglWolf), [@jonsambro](https://github.com/jonsambro), and [@wormyrocks](https://github.com/wormyrocks) for their pull requests, and everyone who filed issues and provided feedback.*
