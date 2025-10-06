---
title: "Introduction and Setup"
date: 2025-10-17T00:00:00+01:00
showTableOfContents: false
series: ["WS00M"]
series_order : 1
showAuthor: false
---

## Introduction

As it has already been announced, this workshop will be using MicroPython and Jupyter Notebooks. Let's quickly introduce them.

### MicroPython

MicroPython is a lean implementation of Python 3 optimized for microcontrollers. It provides an interactive REPL (Read-Eval-Print Loop) and supports most Python standard library features, making embedded development accessible to Python programmers.

### Jupyter Notebook

Jupyter Notebook is a web-based interactive computing environment that allows you to create documents that contain live code, and narrative text. It is composed from a kernel, which is a program that executes the code, and a frontend, which is a user interface that allows you to interact with the kernel.

The code is composed of cells, which can be executed independently or sequentially, either by clicking on the cell and pressing the run button or using a keyboard shortcut `Shift + Enter`. If the code executes a `while True` loop, it can be interrupted by clicking on the stop button in the toolbar.

### Why MicroPython Jupyter Notebooks in the Browser?
Traditional embedded development requires installing toolchains, IDEs, and drivers. Browser-based Jupyter notebooks eliminate this setup by leveraging the WebSerial API, which allows web applications to communicate directly with serial devices. This approach offers several advantages:

- **Zero installation**: No local toolchain required
- **Interactive development**: Execute code cells individually and see immediate results
- **Educational value**: Clear separation of concepts into notebook cells
- **Cross-platform**: Works identically on Windows, macOS, and Linux
- **Version control friendly**: Notebooks can be easily shared and versioned

### How It Works
The browser connects to your ESP32-C3-DevKit-RUST-2 development board via USB using the WebSerial API. Jupyter notebooks send Python code to the MicroPython REPL running on the device. The device executes the code and returns output, which displays in the notebook interface.

### Related documentation

- [MicroPython Documentation](https://docs.micropython.org/en/latest/)
- [ESP32 MicroPython Guide](https://docs.micropython.org/en/latest/esp32/quickref.html)
- [ESP-NOW Protocol](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/network/esp_now.html)
- [ESP-NOW in MicroPython](https://docs.micropython.org/en/latest/library/espnow.html)

## Setup

Let's start by flashing MicroPython firmware.

### Flashing MicroPython Firmware

1. Connect your ESP32-C3-DevKit-RUST-2 development board to your computer via USB cable
2. [Open MicroPython Jupyter Notebook](https://espressif.github.io/jupyter-lite-micropython/lab/index.html) in your chromium based browser
3. Open the sidebar folder, navigate to `workshops/2025-10-17/Assignment 1.ipynb` and open the notebook
4. When prompted with selecting kernel, select `Embedded Kernel`
5. On the ESP Control Panel select `Connect device` and &rarr; `ESP32C3 (USB JTAG)`
6. On the same ESP Control Panel select `Flash Device` and `Flash Selected Firmware` - this will flash MicroPython to your device

Your device is now ready to run MicroPython code.

#### Next step

> Next step: [Assignment 1](../assignment-1)
