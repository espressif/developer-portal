---
title: "Visual Studio Code ESP-IDF v1.8.0 extension"
date: 2024-07-12T16:07:09+08:00
showAuthor: false
tags: ["News", "ESP-IDF extension", "VSCode", "Visual Studio Code"]
authors:
  - "brian-ignacio"
---

## Introduction

With the v1.8.0 of [Espressif ESP-IDF for Visual Studio Code extension](https://github.com/espressif/vscode-esp-idf-extension) we introduce a few new features and lot of bug fixes as described in [v1.8.0 Release](https://github.com/espressif/vscode-esp-idf-extension/releases/tag/v1.8.0). If you face any issue or improvement ideas please share them as a [Github issue](https://github.com/espressif/vscode-esp-idf-extension/issues).

The v1.8.0 release bring the following key features;

- **Add the Eclipse CDT Debug Adapter and update the debugging documentation**

- **Add ESP-IDF version switcher**

- **Add ESP-IDF: idf.py reconfigure task command**

- **Add ESP-IDF Hints viewer output tab and source code editor highlight**

For other updates please review [v1.8.0 Release notes](https://github.com/espressif/vscode-esp-idf-extension/releases/tag/v1.8.0).

## What is a debug adapter in Visual Studio Code

As described in Visual Studio Code documentation, VS Code implements a generic (language-agnostic) debugger UI based on an abstract protocol that was introduced to communicate with debugger backends. Because debuggers typically do not implement this protocol, some intermediary is needed to "adapt" the debugger to the protocol. This intermediary is typically a standalone process that communicates with the debugger.

{{< figure
    default=true
    src="img/debug-arch.webp"
    alt=""
    caption=""
    >}}

This intermediary is called the Debug Adapter (or DA for short) and the abstract protocol that is used between the DA and VS Code is the Debug Adapter Protocol (DAP for short). Since the Debug Adapter Protocol is independent from VS Code, it has its own [web site](https://microsoft.github.io/debug-adapter-protocol/) and many developers have implemented.

## Eclipse CDT Debug Adapter

Before we have implemented our own [ESP-IDF Debug Adapter](https://github.com/espressif/esp-debug-adapter) in Python. While this debug adapter works, our users have report many issues regarding configuration, responsiveness and runtime errors. In our search for solution we encountered that the Eclipse CDT Cloud team have published a [CDT-GDB-Adapter](https://github.com/eclipse-cdt-cloud/cdt-gdb-adapter) which is written in TypeScript and is using [NPM serialport package](https://www.npmjs.com/package/serialport) underneath. We added a few changes in order to make it work with our tools but it is mostly the same as the original.

To use it in a ESP-IDF project `.vscode/launch.json`, you can add this configuration:

```JSON
{
  "configurations": [
    {
      "type": "gdbtarget",
      "request": "attach",
      "name": "Eclipse CDT GDB Adapter"
    }
  ]
}
```

After you build (**ESP-IDF: Build your Project**), flash (**ESP-IDF: Flash your Project**) you can go to menu `Run` and press `Start debugging`. You can check how to use the new debugger by following the [debug tutorial](https://github.com/espressif/vscode-esp-idf-extension/blob/master/docs/tutorial/debugging.md).

{{< figure
    default=true
    src="img/debug-example.webp"
    alt=""
    caption=""
    >}}

## Advanced configuration of Eclipse CDT Debug Adapter

There are many configurable options to customize the debug adapter if desired. You can view a deeper description in the [debugging documentation](https://github.com/espressif/vscode-esp-idf-extension/blob/master/docs/DEBUGGING.md).

## ESP-IDF version switcher

Whenever you use the **ESP-IDF: Configure ESP-IDF Extension** to install ESP-IDF in your system, these installation are saved in our extension as global state IDF setup. You can now use the **ESP-IDF: Select Current ESP-IDF Version** to set in your current project (workspace folder in Visual Studio Code language) the ESP-IDF version you desire to use. If you want to delete these IDF setups from the extension global state you can use the **ESP-IDF: Clear Saved ESP-IDF Setups**.

{{< figure
    default=true
    src="img/idf-version-list.webp"
    alt=""
    caption=""
    >}}

The current ESP-IDF version for currently open ESP-IDF project is shown in the status bar items like this:

{{< figure
    default=true
    src="img/idf-version-status-bar.webp"
    alt=""
    caption=""
    >}}

## Add ESP-IDF: idf.py reconfigure task command

For code navigation the [Microsoft C/C++ Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools) or [Clangd extension](https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd) can be used for C/C++ language support. These extensions provide feature such as syntax highlight, go to definition/declaration and other common language feature you would expect in an IDE. Many of these extensions rely on a `compile_commands.json` file, a JSON compilation database which consist of an array of “command objects”, where each command object specifies one way a translation unit is compiled in the project. More information about JSON compilation database can be found [here](https://clang.llvm.org/docs/JSONCompilationDatabase.html).

The **ESP-IDF: idf.py reconfigure task** will execute ESP-IDF reconfigure task, which generate a compile_commands.json so the language extension can work properly. This is useful in case the user doesn't want to fully build the project but wants to see code navigation and other language features.

## ESP-IDF Hints viewer support

This feature enhances your development experience by providing helpful hints for errors detected in your code generated from ESP-IDF during the build task.

In the source code editor, errors that match a line will be shown when the user mouse is hovering that line.

{{< video src="video/hints-hover" >}}

The ESP-IDF bottom panel automatically updates to display hints based on the errors in your currently opened file.

{{< figure
    src="img/hints-bottom-panel.webp"
    alt=""
    caption=""
    >}}

You can manually search for hints by copy pasting errors with the **ESP-IDF: Search Error Hint**.

{{< video src="video/hints-manual-search" >}}