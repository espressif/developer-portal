---
title: "Try Zephyr on Espressif chips with QEMU (no board required)"
date: 2026-08-25
tags: ["Zephyr", "QEMU", "tutorial", "emulator"]
showAuthor: false
authors:
  - "tiago-medicci"
summary: "Install Espressif’s QEMU fork and run Zephyr’s hello_world on ESP32, ESP32-S3, ESP32-C3, and ESP32-C6 without a physical board."
---

Want to try [Zephyr](https://docs.zephyrproject.org/) on an Espressif SoC before you have the hardware on your desk? Now, we can!

Zephyr can now use [Espressif’s QEMU](https://github.com/espressif/qemu/) to emulate ESP32, ESP32-S3, ESP32-C3, and ESP32-C6—so you can build and run firmware without a physical board.

In this tutorial, we will install Espressif’s QEMU, enable it in a Zephyr build, and run `hello_world` on those four emulated targets—with both Simple Boot and MCUboot/sysbuild. Along the way, we will also attach GDB through `debugserver` and locate the Zephyr SDK toolchain. If you have used QEMU with ESP-IDF before (for example [Trying out ESP32-C3’s security features using QEMU]({{< ref "blog/trying-out-esp32-c3s-security-features-using-qemu/index.md" >}})), the emulator side will feel familiar; the Zephyr wiring is new.

## Overview

With Espressif’s QEMU you can boot Zephyr on emulated ESP32, ESP32-S3, ESP32-C3, and ESP32-C6 targets, run samples such as `hello_world` from the command line, and attach a debugger—without flashing a board. That is only possible with [Espressif’s fork](https://github.com/espressif/qemu/): the QEMU that ships with the Zephyr SDK (and most Linux distro packages) does not model these chips.

Emulation covers the usual bring-up path (boot, flash, UART console, and related core blocks). Wireless stacks and many peripherals are still out of scope; see the [Espressif QEMU feature matrix](https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/) for what is and is not supported today.

## Requirements

### Zephyr workspace

You need a working Zephyr installation (west workspace + Zephyr SDK) and the ability to build `samples/hello_world` for an Espressif board. If you are new to Zephyr, start with [Zephyr RTOS on ESP32 — first steps]({{< ref "blog/2021/02/zephyr-rtos-on-esp32-first-steps/index.md" >}}).

Also install `xxd` on the host (used to generate the ESP32 ECO3 eFuse blob).

### Espressif QEMU (required)

Xtensa and RISC-V use **different** QEMU packages. They are not interchangeable:

- **ESP32 / ESP32-S3** → `qemu-system-xtensa` (Xtensa softmmu package)
- **ESP32-C3 / ESP32-C6** → `qemu-system-riscv32` (RISC-V softmmu package)

Docs and source of truth:

- Releases and source: [espressif/qemu](https://github.com/espressif/qemu/)
- Per-target notes: [esp-toolchain-docs/qemu](https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/) ([ESP32](https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/esp32), [ESP32-S3](https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/esp32s3), [ESP32-C3](https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/esp32c3))

#### Download pre-built binaries (Linux x86_64)

Grab the latest `esp-develop-*` assets from [espressif/qemu releases](https://github.com/espressif/qemu/releases). Example with `esp-develop-9.2.2-20260417`:

```bash
mkdir -p ~/Downloads ~/opt
cd ~/Downloads
wget https://github.com/espressif/qemu/releases/download/esp-develop-9.2.2-20260417/qemu-xtensa-softmmu-esp_develop_9.2.2_20260417-x86_64-linux-gnu.tar.xz
wget https://github.com/espressif/qemu/releases/download/esp-develop-9.2.2-20260417/qemu-riscv32-softmmu-esp_develop_9.2.2_20260417-x86_64-linux-gnu.tar.xz
tar -xf qemu-xtensa-softmmu-*.tar.xz -C ~/opt --one-top-level=qemu-xtensa-softmmu
tar -xf qemu-riscv32-softmmu-*.tar.xz -C ~/opt --one-top-level=qemu-riscv32-softmmu
```

Put both `bin` directories on `PATH`, or set `ESPRESSIF_QEMU_PATH` / `QEMU_BIN_PATH` to the directory that contains the binary you need:

```bash
export PATH="$HOME/opt/qemu-xtensa-softmmu/qemu/bin:$HOME/opt/qemu-riscv32-softmmu/qemu/bin:$PATH"
# optional: export ESPRESSIF_QEMU_PATH=$HOME/opt/qemu-xtensa-softmmu/qemu/bin
```

Zephyr does not trust the first `qemu-system-*` on `PATH` blindly. At configure time it probes candidates from `ESPRESSIF_QEMU_PATH`, `QEMU_BIN_PATH`, and `PATH` with `-machine help`, and picks the first binary that actually lists the SoC machine. That skips the Zephyr SDK `hosttools` QEMU (upstream build, no `esp32` machines). You should see something like:

```text
-- Espressif QEMU: /home/user/opt/qemu-xtensa-softmmu/qemu/bin/qemu-system-xtensa (-machine esp32)
```

Because the lookup is configure-time, install or move QEMU **before** configuring, or re-run with `--pristine` after changing paths.

Quick sanity check:

```bash
qemu-system-xtensa -machine help | grep esp32
qemu-system-riscv32 -machine help | grep esp32
```

#### Build from source (needed for ESP32-C6 today)

Published release tarballs (as of `esp-develop-9.2.2-*`) include `esp32`, `esp32s3`, and `esp32c3`. **ESP32-C6** (`-machine esp32c6`) is in the `esp-develop` tree but not yet in those binaries—so for C6 you build QEMU yourself from [espressif/qemu](https://github.com/espressif/qemu/).

Follow [esp-toolchain-docs](https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/) for prerequisites (`libgcrypt`, etc.). Xtensa and RISC-V use different `--target-list` values.

**RISC-V** (ESP32-C3 / ESP32-C6), configure example that works on a typical Linux host:

```bash
git clone https://github.com/espressif/qemu.git
cd qemu
CFLAGS="-Wno-unused-but-set-variable -Wno-discarded-qualifiers -Wno-format-truncation" \
./configure --target-list=riscv32-softmmu \
    --enable-gcrypt \
    --enable-slirp \
    --enable-sdl \
    --disable-strip --disable-user \
    --disable-capstone --disable-vnc \
    --disable-gtk
ninja -C build
```

Then put `build/` (where `qemu-system-riscv32` lives) on `PATH` or point `ESPRESSIF_QEMU_PATH` at it, and confirm:

```bash
./build/qemu-system-riscv32 -machine help | grep esp32c6
```

**Xtensa** (ESP32 / ESP32-S3) uses `--target-list=xtensa-softmmu` instead—see the [ESP32 QEMU README](https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/esp32).

## Build and run `hello_world`

All examples assume your shell is inside the Zephyr west workspace (where `zephyr/samples/hello_world` exists), with Espressif QEMU on `PATH` as above. Quit QEMU with **Ctrl-A** then **X**.

`--no-sysbuild` forces Simple Boot even if your west config has `build.sysbuild=true`. For MCUboot, use `--sysbuild` and always pass `--domain hello_world` when invoking `run` / `debugserver`.

### ESP32

**Simple Boot:**

```bash
west build -b esp32_devkitc/esp32/procpu zephyr/samples/hello_world \
  -d build-qemu-esp32 --no-sysbuild --pristine -- \
  -DCONFIG_ESPRESSIF_QEMU=y
west build -d build-qemu-esp32 -t run
```

Flash image: `build-qemu-esp32/zephyr/flash_image.bin`.

**Sysbuild / MCUboot:**

```bash
west build -b esp32_devkitc/esp32/procpu zephyr/samples/hello_world \
  -d build-qemu-esp32-sb --sysbuild --pristine -- \
  -DCONFIG_ESPRESSIF_QEMU=y
west build -d build-qemu-esp32-sb --domain hello_world -t run
```

Flash image: `build-qemu-esp32-sb/hello_world/zephyr/flash_image.bin`. Expect MCUboot messages, then `Hello World!`.

Here is a recorded Simple Boot session on ESP32:

{{< asciinema
  key="asciinema/hello-world-esp32-run"
  idleTimeLimit="2"
  speed="1.5"
>}}

### ESP32-S3

**Simple Boot:**

```bash
west build -b esp32s3_devkitc/esp32s3/procpu zephyr/samples/hello_world \
  -d build-qemu-esp32s3 --no-sysbuild --pristine -- \
  -DCONFIG_ESPRESSIF_QEMU=y
west build -d build-qemu-esp32s3 -t run
```

**Sysbuild / MCUboot:**

```bash
west build -b esp32s3_devkitc/esp32s3/procpu zephyr/samples/hello_world \
  -d build-qemu-esp32s3-sb --sysbuild --pristine -- \
  -DCONFIG_ESPRESSIF_QEMU=y
west build -d build-qemu-esp32s3-sb --domain hello_world -t run
```

Use the Xtensa QEMU package (`qemu-system-xtensa`, `-machine esp32s3`).

### ESP32-C3

**Simple Boot:**

```bash
west build -b esp32c3_devkitc zephyr/samples/hello_world \
  -d build-qemu-esp32c3 --no-sysbuild --pristine -- \
  -DCONFIG_ESPRESSIF_QEMU=y
west build -d build-qemu-esp32c3 -t run
```

**Sysbuild / MCUboot:**

```bash
west build -b esp32c3_devkitc zephyr/samples/hello_world \
  -d build-qemu-esp32c3-sb --sysbuild --pristine -- \
  -DCONFIG_ESPRESSIF_QEMU=y
west build -d build-qemu-esp32c3-sb --domain hello_world -t run
```

Use the RISC-V package (`qemu-system-riscv32`). `-icount 3` is added automatically.

### ESP32-C6

Requires a RISC-V QEMU build that lists `-machine esp32c6` (see [Build from source](#build-from-source-needed-for-esp32-c6-today)).

**Simple Boot:**

```bash
west build -b esp32c6_devkitc/esp32c6/hpcore zephyr/samples/hello_world \
  -d build-qemu-esp32c6 --no-sysbuild --pristine -- \
  -DCONFIG_ESPRESSIF_QEMU=y
west build -d build-qemu-esp32c6 -t run
```

**Sysbuild / MCUboot:**

```bash
west build -b esp32c6_devkitc/esp32c6/hpcore zephyr/samples/hello_world \
  -d build-qemu-esp32c6-sb --sysbuild --pristine -- \
  -DCONFIG_ESPRESSIF_QEMU=y
west build -d build-qemu-esp32c6-sb --domain hello_world -t run
```

## Debugging with GDB

`debugserver` starts QEMU with the CPU held and a GDB stub on port **1234**.

**Simple Boot** (example after the ESP32 Simple Boot build above):

```bash
west build -d build-qemu-esp32 -t debugserver
```

ELF: `build-qemu-esp32/zephyr/zephyr.elf`

**Sysbuild:**

```bash
west build -d build-qemu-esp32-sb --domain hello_world -t debugserver
```

ELF: `build-qemu-esp32-sb/hello_world/zephyr/zephyr.elf`

### Finding the Zephyr SDK GDB

Do **not** attach a generic host `gdb`. Use the GDB that ships with the Zephyr SDK for your architecture.

1. If the environment already has it:

```bash
echo "$ZEPHYR_SDK_INSTALL_DIR"
```

2. If that is empty, read it from the build cache after a successful configure/build:

```bash
grep '^ZEPHYR_SDK_INSTALL_DIR:PATH=' build-qemu-esp32/CMakeCache.txt
export ZEPHYR_SDK_INSTALL_DIR=…   # value from that line
```

3. Confirm the binary exists (newer SDKs use a `gnu/` prefix under the install dir):

```bash
# ESP32 / ESP32-S3
ls "$ZEPHYR_SDK_INSTALL_DIR/gnu/xtensa-espressif_esp32_zephyr-elf/bin/"*gdb

# ESP32-C3 / ESP32-C6
ls "$ZEPHYR_SDK_INSTALL_DIR/gnu/riscv64-zephyr-elf/bin/riscv64-zephyr-elf-gdb"
```

### Attach GDB

In a second terminal (ESP32 Simple Boot):

```bash
"$ZEPHYR_SDK_INSTALL_DIR/gnu/xtensa-espressif_esp32_zephyr-elf/bin/xtensa-espressif_esp32_zephyr-elf-gdb" \
  build-qemu-esp32/zephyr/zephyr.elf \
  -ex "target remote :1234" \
  -ex "tb main" -ex "c"
```

For ESP32-C3 / ESP32-C6:

```bash
"$ZEPHYR_SDK_INSTALL_DIR/gnu/riscv64-zephyr-elf/bin/riscv64-zephyr-elf-gdb" \
  build-qemu-esp32c3/zephyr/zephyr.elf \
  -ex "target remote :1234" \
  -ex "tb main" -ex "c"
```

Recorded ESP32 debugserver (terminal A):

{{< asciinema
  key="asciinema/hello-world-esp32-debugserver-terminal-A"
  idleTimeLimit="2"
  speed="1.5"
>}}

And GDB attach (terminal B):

{{< asciinema
  key="asciinema/hello-world-esp32-debugserver-terminal-B"
  idleTimeLimit="2"
  speed="1.5"
>}}

## Wrapping up

You now have a hardware-free path to boot Zephyr on four Espressif DevKitC targets under Espressif QEMU—Simple Boot or MCUboot—and to break into `main` with the Zephyr SDK GDB. That is useful for prototyping board-agnostic application logic, CI-style smoke tests, or bring-up scripts before the PCB arrives.

Keep the emulator limits in mind: Wi-Fi and Bluetooth are not modeled, flash images must use a size Espressif QEMU accepts (2 / 4 / 8 / 16 MB), and `PATH` / `ESPRESSIF_QEMU_PATH` must point at a binary that lists your target machine. For straps, eFuses, PSRAM (`-m`), and networking extras, see the per-SoC pages under [esp-toolchain-docs/qemu](https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/) and Zephyr’s board documentation for Espressif QEMU usage.
