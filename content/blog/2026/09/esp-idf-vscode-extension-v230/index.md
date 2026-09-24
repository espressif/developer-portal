---
title: "ESP-IDF Extension for VS Code v2.3.0 Release"
date: "2026-09-30"
summary: "This article describes changes in the v2.3.0 release such as AI Chat integration with extension task output, MCP servers and other changes."
authors:
  - "brian-ignacio"
tags:
  - ESP-IDF
  - Visual Studio Code
  - VS Code
  - Extension
  - AI
  - IDE
showTableOfContents: true
---

## Introduction

[ESP-IDF VS Code Extension](https://github.com/espressif/vscode-esp-idf-extension) has released v2.3.0! It introduces new features and many improvements. If you face any issue or improvement ideas please share them as a [Github issue](https://github.com/espressif/vscode-esp-idf-extension/issues).

This article covers the following key features:

<!-- no toc -->

- [Extension refactoring and AI Chat task output integration](#ai-chat-task-output-integration)
- [Build Flash and monitor for only App partition](#build-flash-and-monitor-for-single-partition)
- [Add ESP Component Registry and Documentation MCP Servers as extension contribution](#espressif-mcp-servers)
- [Use gdbinit files in debug session and fix symbols resolution](#debug-adapter-use-build-gdbinit-files)

For other updates please review [v2.3.0 Release notes](https://github.com/espressif/vscode-esp-idf-extension/releases/tag/v2.3.0). Now let's look into the key features one by one.

## AI Chat task output integration

Since the v1.11.0 release, we have introduced integration with AI Chat to run extension commands from the chat directly and consume the output directly from there. Please review this feature in the [Language Tools documentation](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/additionalfeatures/language-tools.html#esp-idf-chat-commands).

In this release we have finally achieve the possibility for any regular commands, such as the `ESP-IDF: Build your project` to allow the user to send the output to the chat if there is any issue during the task execution. A notification shows the `Ask AI to fix` action to send the task output to the Chat for AI troubleshooting.

An example of this is shown below:

1. Open a ESP-IDF project that would produce a build error in Visual Studio Code or Cursor. For example calling a function that doesn't exist in main().
2. Run the `ESP-IDF: Build your project` (the <img src="https://raw.githubusercontent.com/microsoft/vscode-codicons/refs/heads/main/src/icons/symbol-property.svg" alt="Build command icon" width="16" height="16" style="display: inline !important; margin: 0; vertical-align: middle;"> icon in the status bar).
3. The build task will start and reach a point of failure and a notification will appear:

{{< figure
    src="img/notification.webp"
    alt="Notification on build error"
    caption="If the build produces an error, this notification will appear."
    >}}

4. If you press the **Ask AI to fix** button, the chat will open with the task output copied.

{{< figure
    src="img/chat.webp"
    alt="Generated prompt on chat"
    caption="A new chat will appear with the task output from the build task."
    >}}

## Build Flash and Monitor for single partition

By using the **ESP-IDF: Build, Flash and Start a Monitor on Your Device** (the <img src="https://raw.githubusercontent.com/microsoft/vscode-codicons/refs/heads/main/src/icons/flame.svg" alt="build flash monitor command icon" width="16" height="16" style="display: inline !important; margin: 0; vertical-align: middle;"> icon in the status bar) the user can build the ESP-IDF project, flash the binaries and start a monitor session.

In `.vscode/settings.json`, You can set the `"idf.partitionToUse"` vscode extension configuration setting to `app`, `bootloader` or `partition-table` to use the **ESP-IDF: Build, Flash and Start a Monitor on Your Device** to flash one single partition instead of the whole ESP-IDF project.

In this version we have also introduced the **ESP-IDF: Build App, Flash App and Start Monitor** command to allow you to do the same but only for the **App** partition instead of the whole project.

If you just want to just build or flash one of these partitions, these commands are also available:

- **ESP-IDF: Build App Only**,
- **ESP-IDF: Build Bootloader Only** 
- **ESP-IDF: Build Partition Table**
- **ESP-IDF: Flash App Only (UART)**
- **ESP-IDF: Flash Bootloader Only (UART)**
- **ESP-IDF: Flash Partition Table (UART)**

## Espressif MCP Servers

As described in the [ESP-IDF VS Code extension Language Tools documentation](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/additionalfeatures/language-tools.html#espressif-mcp-servers), the extension registers remote Model Context Protocol (MCP) servers so Chat (for example GitHub Copilot) can call Espressif tools without a separate mcp.json entry.

The following HTTP servers are contributed:

- **Espressif Documentation** (https://mcp.espressif.com/docs) — semantic search over official Espressif documentation in English and Chinese (search_espressif_sources).
- **ESP Component Registry** (https://components.espressif.com/mcp) — search components and fetch component documentation.

These servers do not require a local ESP-IDF project. They are registered when the extension loads, unless `idf.extensionActivationMode` is set to `never` in your VS Code settings.json.

Here are the steps to enable them:

1. Run **MCP: List Servers** from the Command Palette.
2. If they are not already running, start the two separate entries: `Espressif Documentation` and `ESP Component Registry`.
3. VS Code opens a browser for authentication. Sign in with a GitHub or WeChat account. Only an anonymized account ID is used to enforce rate limits. See the Espressif Documentation MCP Server article and Espressif MCP Servers.
4. If the Component Registry server also requests authentication, complete that prompt the same way.
5. Open Chat (`View` > `Chat`) to start a chat session.

After login, the Chat can use the documentation search and component registry tools together with the ESP-IDF command tool described above.

## Debug Adapter use build gdbinit files

We have update the gdb init commands to use the ESP-IDF project build gdbinit files such as symbols, prefix_map (if configured in your ESP-IDF project), python extensions and connect. This should help solve issues such as undefined symbols during a debug session. No need any configuration change from the user side.
