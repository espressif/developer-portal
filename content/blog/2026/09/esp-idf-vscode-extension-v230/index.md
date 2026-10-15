---
title: "ESP-IDF Extension for VS Code v2.3.0 Release"
date: "2026-09-30"
summary: "This article describes changes in the v2.3.0 release such as AI Chat integration with extension task output, MCP servers and other changes."
authors:
  - "brian-ignacio"
featureAsset: "img/featured/featured-espressif.webp"
tags:
  - ESP-IDF Extension for VS Code
  - release
  - ESP-IDF tool
  - VS Code
  - AI
showTableOfContents: true
---

## Introduction

[ESP-IDF VS Code Extension](https://github.com/espressif/vscode-esp-idf-extension) v2.3.0 has been released! It introduces new features and many improvements. If you encounter an issue or have improvement ideas, please share them as a [GitHub issue](https://github.com/espressif/vscode-esp-idf-extension/issues).

This article covers the following key features:

<!-- no toc -->

- [AI Chat task output integration](#ai-chat-task-output-integration)
- [Build Flash and Monitor for single partition](#build-flash-and-monitor-for-single-partition)
- [Espressif MCP Servers](#espressif-mcp-servers)
- [Improved debug symbols resolution](#improved-debug-symbols-resolution)

For other updates please review [v2.3.0 Release notes](https://github.com/espressif/vscode-esp-idf-extension/releases/tag/v2.3.0). Let's look into the key features one by one.

## AI Chat task output integration

In Visual Studio Code, you can enable Chat and connect it to Copilot, another AI provider, or your own models. Read more in the [VS Code guide to enabling AI features](https://code.visualstudio.com/docs/getstarted/overview#_enable-ai-features) and the [AI Chat view documentation](https://code.visualstudio.com/docs/agents/run/chat-view).

Since the v1.11.0 release, the extension has supported running ESP-IDF commands directly from Chat and viewing their output there. You can build a project by typing **build the project** or **#espIdfCommands build** in Chat. For more information about these and other Chat commands, see the [Language Tools documentation](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/additionalfeatures/language-tools.html#esp-idf-chat-commands).

In the ESP-IDF VS Code extension v2.3.0 release, commands such as `ESP-IDF: Build your project` now offer AI troubleshooting if there are any issues during task execution. You can select `Ask AI to fix` from the task output notification to send output to the VS Code Chat for troubleshooting with AI. This will open a new AI Chat view with the task output included in a prompt to help fix the issue.

An example of this is shown below:

1. Open an ESP-IDF project that would produce a build error in Visual Studio Code or Cursor. For example, call a function that doesn't exist in main().
2. Run the `ESP-IDF: Build your project` (the <img src="https://raw.githubusercontent.com/microsoft/vscode-codicons/refs/heads/main/src/icons/symbol-property.svg" alt="Build command icon" width="16" height="16" style="display: inline !important; margin: 0; vertical-align: middle;"> icon in the status bar).
3. The build task will start and reach a point of failure and a notification will appear:

{{< figure
    src="img/notification.webp"
    alt="Notification on build error"
    caption="If the build produces an error, this notification will appear."
    >}}

4. Press **Ask AI to fix**. A new AI Chat view opens with the task output included in a prompt to help diagnose the issue.

{{< figure
    src="img/chat.webp"
    alt="Generated prompt on chat"
    caption="A new chat will appear with the task output from the build task."
    >}}

## Build Flash and Monitor for single partition

The `"idf.partitionToUse"` ESP-IDF extension setting selects the partition to use: `app`, `bootloader`, or `partition-table`. When you run **ESP-IDF: Build, Flash and Start a Monitor on Your Device** (the <img src="https://raw.githubusercontent.com/microsoft/vscode-codicons/refs/heads/main/src/icons/flame.svg" alt="build flash monitor command icon" width="16" height="16" style="display: inline !important; margin: 0; vertical-align: middle;"> status bar icon), the command builds the project, flashes the selected partition, and starts a monitor session.

For example, when `"idf.partitionToUse": "app"`, the **ESP-IDF: Build, Flash and Start a Monitor on Your Device** will build only the app partition, flash the app partition and start a monitor session.

In the v2.3.0 release we have introduced the **ESP-IDF: Build App, Flash App and Start Monitor** command to allow you to do the same but only for the **App** partition and without needing to set `"idf.partitionToUse"` in your settings.json.

If you just want to build or flash one of these partitions, several commands are also available:

- **ESP-IDF: Build App Only**
- **ESP-IDF: Build Bootloader Only**
- **ESP-IDF: Build Partition Table**
- **ESP-IDF: Flash App Only (UART)**
- **ESP-IDF: Flash Bootloader Only (UART)**
- **ESP-IDF: Flash Partition Table (UART)**

## Espressif MCP servers

The Model Context Protocol (MCP) is an open standard that lets AI models connect to external tools, including those in the [Espressif MCP Servers collection](https://mcp.espressif.com). As described in the [ESP-IDF VS Code extension Language Tools documentation](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/additionalfeatures/language-tools.html#espressif-mcp-servers), this extension registers remote MCP servers so the [VS Code Chat view](https://code.visualstudio.com/docs/agents/run/chat-view) can call Espressif tools without a separate `mcp.json` entry.

The following HTTP servers are contributed:

- **Espressif Documentation** (https://mcp.espressif.com/docs) — semantic search over official Espressif documentation in English and Chinese (search_espressif_sources).
- **ESP Component Registry** (https://components.espressif.com/mcp) — search components and fetch component documentation.

These servers do not require a local ESP-IDF project. They are registered when the extension loads, unless `idf.extensionActivationMode` is set to `never` in your VS Code settings.json.

Here are the steps to enable them:

1. Run **MCP: List Servers** from the Command Palette.
2. If they are not already running, start the two separate entries: `Espressif Documentation` and `ESP Component Registry`.
3. VS Code opens a browser for authentication. Sign in with a GitHub or WeChat account. Only an anonymized account ID is used to enforce rate limits. See [Espressif Documentation MCP Server](https://developer.espressif.com/blog/2026/04/doc-mcp-server/).
4. If the Component Registry server also requests authentication, complete that prompt the same way.
5. Open Chat (`View` > `Chat`) to start a chat session.

After login, the Chat can use the documentation search and component registry tools together with the ESP-IDF command tool described above.

## Improved debug symbols resolution

During a debug session, users could see `?? Unknown Source` in the call stack or an error saying the bounds of the current function could not be found.

{{< figure
    src="img/debugUnknownSource.webp"
    alt="Unknown source on call stack during debug session"
    caption="Unknown source on call stack during ESP-IDF debug session"
    >}}

Previously, you had to configure `launch.json` manually to include ROM symbols.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "gdbtarget",
      "request": "attach",
      "name": "Eclipse CDT GDB Adapter",
      "imageAndSymbols": {
        "symbolFileName": "/home/user/.espressif/tools/esp-rom-elfs/20241011/esp32s3_rev0_rom.elf",
        "symbolOffset": "0"
      }
    }
  ]
}
```

or run this gdb command in the VS Code debug console:

```
add-symbol-file /home/user/.espressif/tools/esp-rom-elfs/20241011/esp32s3_rev0_rom.elf
```

The debug adapter now loads the ESP-IDF project's gdbinit files from its build directory when you start a debug session. These files contain GDB configuration instructions and symbol information that help resolve source locations, without requiring manual setup.
