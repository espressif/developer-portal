---
title: "esptool: Updates about the upcoming v5 major release"
date: 2025-04-01
showAuthor: False
authors:
  - "radim-karnis"
tags: ["esptool", "tools"]
summary: "esptool v5, currently under development by Espressif, boosts its new public API and customizable logging capabilities for developers. The new version brings enhancements for users as well. Contributions are welcome, preview out now."
---

## Introduction

[esptool](https://github.com/espressif/esptool) is Espressif's versatile command-line utility and Python library that serves as a Swiss Army knife for ESP chips. If you're flashing any of the ESP8266 or ESP32-series SoCs, you're likely already using `esptool` under the hood of a framework or IDE, even without realizing it.

 This tool provides developers with everything needed to:

- Read, write, erase, and verify binary firmware data.
- Manipulate ROM memory and registers.
- Fetch chip information (MAC, flash chip info, security info, eFuses).
- Convert, analyze, assemble, and merge binary executable images.
- Perform chip diagnostics and provisioning (including secure boot and flash encryption).

You can learn more about `esptool` and how to use it in its [documentation](https://docs.espressif.com/projects/esptool/).

`esptool`'s next evolutionary step is the upcoming `v5` major release, which is currently being developed in the [repository master branch](https://github.com/espressif/esptool). It will bring significant improvements for both developers and users.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
`esptool` `v5` is still under active development, with a planned release in **May 2025**.
{{< /alert >}}

When released, it will first be available in the `ESP-IDF` `v6` major release, with adoption by Arduino and other frameworks to follow.

A [migration guide](https://docs.espressif.com/projects/esptool/en/latest/migration-guide.html) is provided to help users transition from `v4` when the stable release arrives. In the meantime, adventurous users can try a preview by installing the development version:

```bash
pip install esptool~=5.0.dev0
```

## Updates for developers

Until now, `esptool` was primarily a command-line tool with limited Python integration. While powerful when used manually, its convoluted structure made embedding esptool into scripts or applications cumbersome. Developers often resorted to subprocess calls or workarounds, sacrificing reliability and flexibility.

With `v5`, this changes. The new public API transforms esptool into a true library, enabling:

- **Direct programmatic control** – No more CLI wrapping or output parsing.
- **Structured workflows** – Chain operations like `backup flash` -> `erase flash` -> `write flash` -> `verify flash`  in one session.
- **Type-safe API** – Auto-completion and error checking in IDEs.
- **Customizable logging** – Integrate output with GUIs or logging systems.

`esptool` `v5` introduces enhancements for developers who need to integrate ESP chip programming into their Python applications. The new public API provides both high-level convenience functions and low-level control, while the customizable logging enables integration with GUIs and automated systems. Let's have a look at the new features!

### Public API

A set of high-level functions that encapsulate common operations and simplify the interaction with the ESP chip is now introduced as a public API. These functions are designed to be user-friendly and provide an intuitive way to work with the chip. The public API is the recommended way to interact with the chip programmatically.

For most use cases, the `esptool.cmds` module offers simplified access to common operations. The following example demonstrates a chained workflow that would otherwise require 5 individual runs of `esptool` on the command line:

```python
from esptool.cmds import (
   attach_flash, detect_chip, erase_flash, flash_id, read_flash,
   reset_chip, run_stub, verify_flash, write_flash
)

PORT = "/dev/ttyUSB0"
BOOTLOADER = "bootloader.bin"
FIRMWARE = "firmware.bin"

with detect_chip(PORT) as esp:
    esp = run_stub(esp)  # Upload and run the stub flasher (optional)
    attach_flash(esp)    # Attach the flash memory chip, required for flash operations
    flash_id(esp)        # Print information about the flash chip
    read_flash(esp, 0x0, 0x8000, "bl_backup.bin")  # Backup the loaded bootloader
    erase_flash(esp)     # Erase the flash memory
    write_flash(esp, [(0, BOOTLOADER), (0x10000, FIRMWARE)])   # Write binary data
    verify_flash(esp, [(0, BOOTLOADER), (0x10000, FIRMWARE)])  # Verify written data
    reset_chip(esp, "hard_reset")  # Reset the chip and execute the loaded app
```

Key features of the Public API:

- Context manager support for automatic resource cleanup.
- Flexible input types (file paths, bytes, or file-like objects).
- Multiple operations can be chained together as long as an `esp` object exists.

For full instructions and detailed API reference, please see the [related documentation](https://docs.espressif.com/projects/esptool/en/latest/esptool/scripting.html).

### Custom logger integration

`esptool` `v5` introduces a flexible logging system that replaces the previous hardcoded console output. It allows redirecting output by implementing a custom logger class. This can be useful when integrating `esptool` with graphical user interfaces or other systems where the default console output is not appropriate.

By extending or re-implementing the `esptool` logger you can achieve:
- Output redirection to any system (GUI, web, log files).
- Progress reporting hooks for visual feedback (e.g., GUI progress bars filling up during long operations).

For an example of a custom logger class and its specifics, please see the [related documentation](https://docs.espressif.com/projects/esptool/en/latest/esptool/scripting.html#redirecting-output-with-a-custom-logger).

## Updates for users

While the developer-focused improvements in `esptool` `v5` are substantial, users relying on the command-line interface will also benefit from a more polished and user-friendly experience. Here’s what’s in store:

- **Colored and re-imagined output** - The command-line interface now features colored output with indentation to make it easier to use the tool and distinguish between informational messages, warnings, and errors at a glance.

{{< figure
  default=true
  src="colored-output.webp"
>}}

- **Collapsing output stages** - Long operations like flashing or verifying large binaries used to flood the terminal with repetitive status updates. With collapsing output stages, logs are condensed into concise, single-line summaries that update in place when a given operation successfully finishes.

{{< figure
  default=true
  src="folding-stage.webp"
>}}

- **More Error Messages and Bug Fixes** - More edge cases are now covered with meaningful notes, warnings, or error messages.
- **Progress Bars** - To provide better visual feedback, ASCII progress bars are introduced for time-consuming tasks like reading or writing flash memory.

{{< figure
  default=true
  src="warnings-progress.webp"
>}}

- **`espefuse` and `espsecure` improvements** - All of the listed improvements are also happening in the bundled tools for eFuse manipulation (`espefuse`) and flash encryption / secure boot management (`espsecure`).

- The team at Espressif is working hard to polish the mentioned features and to add new ones. Some of the new planned updates include a clean rewrite of the flasher stub and fast-reflashing capabilities (uploading only the changed parts of firmware, instead of the whole binary), among other enhancements.

## Call for contributions

We’re actively seeking contributors to help shape `esptool` `v5`. Whether you’re a developer interested in IDE integrations, a CI/CD expert who can test automation workflows, or a maintainer for less-common platforms, your skills are welcome! To get involved, check out the [esptool GitHub repository](https://github.com/espressif/esptool), and feel free to report issues, suggest features, or submit pull requests.
