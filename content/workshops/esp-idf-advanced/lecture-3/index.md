---
title: "ESP-IDF Adv. - Lecture 3"
date: "2025-08-05"
series: ["WS00B"]
series_order: 9
showAuthor: false
summary: "In this article, we cover size analysis and core dumps. You’ll learn what they do, why they matter, and how to use them to build more efficient and reliable applications."

---

## Introduction

We’ll focus on two useful tools:

* __Size analysis__: Understand and manage your application’s memory footprint.
* __Core dump__: Capture the system state after a crash for detailed post-mortem debugging.

Let's take a closer look at each.

## Size analysis

Size analysis is the process of examining how much flash and RAM your firmware consumes. This helps ensure the application fits within the target hardware and leaves enough memory available for runtime operations such as task scheduling, buffer management, and peripheral interaction.

### Performing size analysis

When building a project with ESP-IDF, the build system automatically provides a memory usage summary. After running:

* `ESP-IDF: Build Your Project`

You’ll see output like this:

```
Total sizes:
 DRAM .data size:   1234 bytes
 DRAM .bss  size:   5678 bytes
 IRAM   size:       9101 bytes
 Flash code size:   11213 bytes
 Flash rodata size: 1415 bytes
```

This breakdown gives insight into where your application is consuming resources. For deeper analysis, ESP-IDF offers additional commands:

* `idf.py size`: Provides a summary of statically-allocated memory usage.
* `idf.py size-components`: Shows per-component memory usage.
* `idf.py size-files`: Breaks down usage by source file.
* `idf.py size-symbols`: Lists symbol-level memory usage (useful for pinpointing heavy functions or variables).

These tools help identify memory hotspots and guide you in optimizing your codebase.

Once you know the memory usage of your firmware, you can begin pruning both the configuration and code to reduce it. After making your changes, test the memory usage again to see how much impact they had.

## Core dumps

A __core dump__ is a snapshot of the device’s memory and processor state at the time of a crash. It includes:

* Call stacks of all tasks
* CPU register contents
* Relevant memory regions

This data allows developers to analyze what went wrong, even after the device resets, making core dumps an invaluable tool for diagnosing hard-to-reproduce bugs.

### Enabling and using core dumps

To enable core dumps on an Espressif device using ESP-IDF, you need to
1. Enable the core dump in the `menuconfig`
2. Trigger and analyze the core dump
    When a crash occurs, the Espressif chip saves the core dump to flash or shows it in UART. You can analyze it using:

    ```sh
    idf.py coredump-info
    ```

These commands decode the core dump and present a readable backtrace, variable states, and register values. This makes it easier to identify the root cause of a failure.

Core dumps are an invaluable tool to be used alongside debugging.

## Conclusion

Mastering __size analysis__ and __core dumps__ is extremely useful for embedded developers. Size analysis helps ensure your application remains within resource limits and runs efficiently, while core dumps provide a powerful mechanism for post-crash diagnostics.

By integrating these tools into your development workflow, you'll be better prepared to build robust, high-performance applications.


> Next step: [Assignment 3.1](../assignment-3-1/)

> Or [go back to navigation menu](../#agenda)

## Further Reading

* [ESP-IDF Core Dump Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/core_dump.html)
