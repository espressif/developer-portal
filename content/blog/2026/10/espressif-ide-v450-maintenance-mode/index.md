---
title: "Espressif-IDE v4.5.0 Released: Transitioning to Maintenance Mode"
date: "2026-10-27"
summary: "Espressif-IDE v4.5.0 is the final feature release. It adds Eclipse 2026-09 and Java 25 support, then enters maintenance until 14 October 2027. New projects should use the ESP-IDF extension for VS Code."
authors:
  - "kondal-kolipaka"
featureAsset: "img/featured/featured-espressif-ide.webp"
tags:
  - Espressif-IDE
  - release
  - migration
  - Eclipse
  - VS Code
  - AI
showTableOfContents: true
---

## Espressif-IDE v4.5.0

**Espressif-IDE v4.5.0** and the **ESP-IDF Eclipse Plugin v4.5.0** were released on 14 October 2026. This is the final feature release for both the standalone IDE and the plugin installed from the update site.

New projects should start with the [ESP-IDF extension for VS Code](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension). You can add that extension from VS Code.

## Support through 14 October 2027

| Lifecycle milestone | Detail |
| :--- | :--- |
| **Release date** | 14 October 2026 |
| **Status** | Maintenance only |
| **Recommended for new projects?** | No |
| **Maintenance and end of life** | 14 October 2027 |

Until 14 October 2027, high-severity bugs and security fixes ship as `4.5.x` releases. There will be no new features, and releases before v4.5.0 receive no further updates. The full terms are in the [Espressif-IDE support policy](https://docs.espressif.com/projects/espressif-ide/en/latest/support-policy.html).

## What changed in v4.5.0

- **Eclipse 2026-09 and Java 25:** The standalone IDE moves from the Eclipse 2026-03 release to Eclipse platform 4.41 and includes OpenJDK 25.0.4. Installing the plugin into an existing Eclipse installation requires Java 25 or later. See the [prerequisites](https://docs.espressif.com/projects/espressif-ide/en/latest/prerequisites.html).
- **Project workflows:** Launch and debug configurations are unified, and switching the ESP-IDF target is safer.
- **Editor support:** The default `.clangd` file generated for ESP-IDF projects now sets `BuiltinHeaders: QueryDriver`, so clangd uses the toolchain driver’s built-in headers with `--query-driver`.
- **ESP-IDF Manager:** If the required ESP-IDF tools are missing, the wizard can open the ESP-IDF Manager to install or configure them. See the [EIM documentation](https://docs.espressif.com/projects/idf-im-ui/en/latest/).

The [v4.5.0 release notes](https://github.com/espressif/idf-eclipse-plugin/releases/tag/v4.5.0) list the complete set of changes.

## Why Espressif-IDE is entering maintenance mode

### Fewer developers are using Espressif-IDE

Espressif-IDE remains useful for current Eclipse users, but fewer ESP-IDF developers are choosing it for new work. More of that work is happening in editors with built-in AI assistance.

### AI-assisted editing has moved to other tools

[Visual Studio Code](https://code.visualstudio.com/) with GitHub Copilot, and [Cursor](https://cursor.com/), are now common choices for writing ESP-IDF code, including code generation and refactoring. The [ESP-IDF extension for VS Code](https://github.com/espressif/vscode-esp-idf-extension) continues to add workflow support for those environments, including the AI features described in the [v2.3.0 release](https://developer.espressif.com/blog/2026/10/esp-idf-vscode-extension-v230/). Eclipse does not currently offer the same level of AI-assisted editing.

### Development effort is moving to the tools in active use

We're focusing on the [ESP-IDF extension for VS Code](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/) and [ESP-IDF Installation Manager (EIM)](https://dl.espressif.com/dl/eim/), with continued investment in AI-assisted workflows and debugging capabilities. In parallel, we are exploring the [Web IDE](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-web) experience.

## Moving an existing project

You do not need to recreate your ESP-IDF project. Most project-level ESP-IDF configuration is portable and can be reused directly in VS Code.

Follow the [migration guide](https://docs.espressif.com/projects/espressif-ide/en/latest/migrate-to-vscode.html), which also includes the [`AGENTS.md`](https://docs.espressif.com/projects/espressif-ide/en/latest/_downloads/ce3c58bcd116ebc5dbf6fbff43989856/AGENTS.md) file for AI-assisted migration. After opening the project, use the [ESP-IDF extension for VS Code](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/) to select the ESP-IDF version, target, and device.

We want to thank everyone who has used, contributed to, and reported issues for Espressif-IDE.
