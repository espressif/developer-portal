---
title: "Espressif-IDE v3.0.0 — LSP Support for C/C++ Editor"
date: 2024-06-28
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
tags: ["News", "Espressif IDE", "LLVM", "Eclipse"]
authors:
  - "kondal-kolipaka"
---


This article briefly covers the most important features introduced in Espressif-IDE v3.0.0 and some of their implementation details. If you have further improvement ideas or if you encounter any issues while using Espressif-IDE, do not hesitate to report them in the project's [GitHub issues][github-issues].

The article consists of the following major sections:

- [Introduction](#introduction)
- [Deciphering the alphabet soup](#deciphering-the-alphabet-soup)
- [Why moving to LSP-based editor?](#why-moving-to-lsp-based-editor)
- [clangd setup](#clangd-setup)
- [LSP C/C++ Editor features](#lsp-cc-editor-features)
- [Conclusion](#conclusion)

[github-issues]: https://github.com/espressif/idf-eclipse-plugin/issues


## Introduction

We are excited to announce the release of Espressif-IDE v3.0.0 - a cross-platform integrated development environment (IDE) which simplifies and enhances the development experience of IoT applications for Espressif chips, such as the ESP32 or the ESP32-P4.

Espressif-IDE v3.0.0 is a significant update that brings the long-awaited features:

- **Eclipse CDT-LSP plugins** bringing support for the latest C/C++ standards
- New **LSP C/C++ Editor** powered by the LLVM clangd C/C++ language server and offering advanced editor features for ESP-IDF developers

For other updates, see the [Release notes](https://github.com/espressif/idf-eclipse-plugin/releases/tag/v3.0.0).


## Deciphering the alphabet soup

The article includes a number of concepts and abbreviations that might look somewhat intimidating, such as LLVM, LSP, CDT-LSP, Clang, clangd, esp-clang, etc. The uninitiated reader might easily get lost. Let's go through those quickly.

{{< figure
    default=true
    src="img/arch.svg"
    alt=""
    caption=""
    >}}

- [ESP-IDF Eclipse Plugin](https://github.com/espressif/idf-eclipse-plugin) (a.k.a. IEP plugin) is an easy-to-use Eclipse-based development environment which simplifies and enhances standard Eclipse CDT for developing IoT applications on Espressif chips.
- [Espressif-IDE](https://github.com/espressif/idf-eclipse-plugin/releases/tag/v3.0.0) is a cross-platform integrated development environment that combines Eclipse CDT, Eclipse CDT LSP, the ESP-IDF Eclipse Plugin, and more. It is the recommended way to install and use the ESP-IDF Eclipse Plugin.
- [Eclipse CDT](https://projects.eclipse.org/projects/tools.cdt) (C/C++ Development Tooling) is a fully functional C and C++ Integrated Development Environment (IDE). However, it integrates the GCC (GNU Compiler Collection) development tools that are not as advanced or user-friendly as Clang tools. Although, Clang tools can only be accessed using the Language Server Protocol (LSP) which is missing here.
- [Eclipse CDT LSP](https://github.com/eclipse-cdt/cdt-lsp) (LSP based C/C++ Editor) integrates the Language Server Protocol (LSP) within the Eclipse CDT environment. It enables access to Clang tools that support newer C/C++ standards required by more recent versions of ESP-IDF.
- [Clang](https://clang.llvm.org/) is a compiler front-end and tooling infrastructure for C, C++ and other C family languages within the LLVM project. Compared to the GCC (GNU Compiler Collection), Clang offers better support for the newer C++ standards. Instead of Clang, we use its customized version -- esp-clang.
- [esp-clang](https://github.com/espressif/llvm-project) is a customized version of the Clang compiler specifically tailored for developing IoT applications on Espressif chips. It also includes the clangd server required by the LSP protocol for communication. The esp-clang toolchain is installed as a dependency of [ESP-IDF](https://github.com/espressif/esp-idf).
- [clangd](https://clangd.llvm.org/) is a language server that provides IDE-like features, such as code completion, navigation, and documentation, for C, C++, and C family languages. It is part of the LLVM project and leverages the Clang front end to parse and analyze code. In our case, it fetches information from esp-clang and uses the Language Server Protocol (LSP) to communicate with the LSP C/C++ editor.
- [LLVM](https://llvm.org/) (just for completeness) is an open-source collection of modular and reusable compiler and toolchain technologies. Initially designed as a set of compiler tools, LLVM has evolved to encompass a broad range of components for developing compilers and other language-related tools.

{{< alert >}}
  Even though the C/C++ editor uses esp-clang for editor features in Espressif-IDE 3.0.0, **the projects are built with the GCC toolchain**. Building projects using the esp-clang toolchain is currently an experimental feature.
{{< /alert >}}


## Why moving to LSP-based editor?

Many users have been reporting that the Eclipse CDT Editor/Indexer is unable to resolve headers and compilation units when working with ESP-IDF v5.0 and higher. This issue arises because the Eclipse CDT only supports the versions up to C++14. However, ESP-IDF v5.0 uses C++20 (with GCC 11.2) and ESP-IDF v5.2 uses C++23 (with GCC 13.1).

By adopting an LSP-based editor, Espressif-IDE v3.0.0 enables support for newer C/C++ standards required by more recent versions of ESP-IDF. Conversely, the old CDT C/C++ editor and its Indexer are not supported for ESP-IDF projects anymore. However, you can still use the CDT C/C++ editor for non-ESP-IDF projects as-is.


## clangd setup

The LSP C/C++ Editor is configured to work with LSP and clangd by default. Here are some additional setup instructions that might be helpful if you encounter any challenges.


<!-- omit in toc -->
### clangd server setup

The clangd path is configured in the preferences. The `Drivers` path and `--compile-commands-dir` path will be set based on the selected target (e.g., esp32, esp32c6) and the project you’re building.

However, if there are any issues with the configuration, see the [clangd configuration][clangd-config] document.

[clangd-config]: https://github.com/espressif/idf-eclipse-plugin/blob/master/docs_readme/clangd_cdt_support.md#clangd-configuration

<!-- omit in toc -->
### `.clangd` configuration

For a new project, a `.clangd` configuration file is created by default with the contents provided below. For an existing project, create a `.clangd` file in its root folder yourself and add required parameters.

```yaml
CompileFlags:
  CompilationDatabase: build
  Remove: [-m*, -f*]
```

- `CompileFlags`: This key indicates the start of a dictionary (or map) containing compilation flag settings.
- `CompilationDatabase`: This key specifies the location of the compilation database, which, in our case, is the `compile_commands.json` file generated by CMake. The value indicates that `compile_commands.json` is located in the `build` directory relative to the root of the project. For other paths, see [Custom build directory](#custom-build-directory).

  A compilation database (`compile_commands.json`) is a file that contains an array of command objects, each representing a single compilation unit, providing details like the compiler executable, the compiler flags used, the source files, and the working directory. This database is used by clangd to determine how the source code is compiled.

- `Remove`: This key lists the patterns, meaning that any compilation flags that start with `-m` or `-f` should be removed from the compilation commands. This is needed to remove some errors reported by clangd because Espressif-IDE uses the **GCC toolchain** by default to build projects. If you choose to use the experimental **esp-clang toolchain**, this key is not needed.

  Here are the errors you may find in the file if you haven’t added the remove flags as mentioned above.

  {{< figure
      default=true
      src="img/errors-without-flags.webp"
      alt=""
      caption=""
      >}}

For information about other `.clangd` configuration options, see [Configuration](https://clangd.llvm.org/config).


<!-- omit in toc -->
### Custom build directory

If you use a custom build directory:

- Set the `CompilationDatabase` key in the `.clangd` config file.
- Set the correct build directory `--compile-commands-dir` in the additional args in the clangd preferences.

Normally, these settings are configured by default, but if something goes wrong, you can double-check them.


## LSP C/C++ Editor features

<!-- omit in toc -->
### Errors and warnings

The clangd server runs your code through esp-clang as you type and displays errors and warnings in-place.

{{< figure
    default=true
    src="img/dispaly-errors-warnings.webp"
    alt=""
    caption=""
    >}}


<!-- omit in toc -->
### Fixes

The clangd server can suggest fixes for many common problems automatically and update the code for you.

{{< video src="video/lsp-fixes" >}}


<!-- omit in toc -->
### Code completion

As you type, you will see suggestions based on the methods, variables, etc. available in this context.

{{< video src="video/lsp-code-completion" >}}


<!-- omit in toc -->
### Find definition/declaration

To jump to the definition or declaration of a specific compilation unit, hold *Ctrl* and click the desired unit.

{{< video src="video/lsp-find-def" >}}


<!-- omit in toc -->
### Hover

Hover over a compilation unit to see more information about it, such as its type, documentation, and definition.

{{< video src="video/lsp-hover" >}}


<!-- omit in toc -->
### Formatting

The clangd server can reformat your code -- fix indentation, break lines, and reflow comments -- by using the embedded [ClangFormat](https://clang.llvm.org/docs/ClangFormat.html). The clangd language server searches for a `.clang-format` config in the source folder and its parents.

A file can be formatted using two ways:

- Right-click your file and choose *Source* > *Format*

  OR
-  On file save if you enable [Save Actions](https://github.com/eclipse-cdt/cdt-lsp?tab=readme-ov-file#save-actions-using-clang-format) in the preferences.

{{< video src="video/lsp-format" >}}

{{< alert >}}
  Note that you cannot use the CDT C/C++ formatting styles with the LSP C/C++ editor.
{{< /alert >}}

However, you can use a feature of [ClangFormat][clang-format] to generate the default formatting styles, such as LLVM, GNU, Google, Chromium, Microsoft,Mozilla, WebKit. For example, to generate the GNU formatting style, run in your terminal:

[clang-format]: https://clang.llvm.org/docs/ClangFormat.html

```sh
clang-format -style=GNU -dump=config > .clang-format
```

{{< video src="video/lsp-format-generate" >}}


<!-- omit in toc -->
### Editor colors

The LSP C/C++ Editor is derived from the standard Eclipse Text Editor, so you can change the editor color options from the Text Editor preferences. For example, you can modify the line number foreground color and the current line highlight color, among other options available in the Text Editor preferences.

{{< figure
    default=true
    src="img/editor-color-options.webp"
    alt=""
    caption=""
    >}}


## Conclusion

We believe that the new features and enhancements in Espressif-IDE v3.0.0 will significantly improve the development experience for ESP-IDF developers. The transition to an LSP-based editor brings robust support for the latest C/C++ standards and offers powerful IDE-like capabilities that address previous limitations.
