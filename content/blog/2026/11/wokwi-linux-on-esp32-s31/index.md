---
title: "Simulate Linux on the ESP32-S31 with Wokwi"
date: "2026-12-08"
summary: "Advancements to Wokwi's simulation engine and Espressif's Yocto BSP layer now allow Linux to boot on the ESP32-S31, completely inside the browser."
authors:
  - "wokwi"
tags:
  - DevKit
  - Linux
  - IDE
  - practitioner
  - tutorial
  - Wokwi
---

[Wokwi](https://wokwi.com)'s portfolio of simulated Espressif devices has grown with the addition of the ESP32-S31, and
with it, comes the ability to run embedded Linux within the browser. We'll explore what RISC-V features on the ESP32-S31
enable Linux, what it took to add it to Wokwi, how you can experiment with it today, and some of the pitfalls you might
encounter.


{{< figure
  src="img/esp32-s31-function-coreboard-1-isometric.webp"
  alt="ESP32-S31-FunctionCoreBoard-1 development kit"
  caption="ESP32-S31-FunctionCoreBoard-1 development kit"
>}}

## Firmware Approaches

Traditionally, firmware is executed directly on bare metal or within the framework of a real-time operating system (RTOS),
but this poses several challenges:
- Hardware revisions can cause breaking changes to firmware, even within the same family of microcontrollers
- Vendor & knowledge lock-in could make migrating or updating firmware difficult
- Lack of process isolation and privileged memory access, risking unauthorised code execution

Linux is a potential solution to these challenges: it can provide an abstraction layer to reduce board-specific code,
its open-source nature removes the risk of vendor lock-in, and security patches alongside the memory management unit (MMU)
requirement help provide a safe home for your code to run.

## How RISC-V Helps

ESP32-S31's RISC-V cores implement the [privileged architecture specification](https://docs.riscv.org/reference/isa/v20260120/priv/priv-intro.html),
providing a set of privilege levels: user/application (`U`), supervisor (`S`) and machine (`M`), where `U` is the least
privileged, and `M` is the most privileged. Critically, the [`Sv32` extension](https://docs.riscv.org/reference/isa/v20260120/priv/supervisor.html#sv32)
is also implemented -- this enables 32-bit virtual address spaces, providing each process with its own isolated memory region.
`Sv32` is backed by an MMU, which checks and enforces privileges on each memory access by evaluating the [page-table
entry read/write/execute fields](https://docs.riscv.org/reference/isa/v20260120/priv/supervisor.html#translation) alongside
[`MXR` and `SUM` within the `sstatus` register](https://docs.riscv.org/reference/isa/v20260120/priv/supervisor.html#sum).
These features provide process isolation, system stability and security, which enable mainline Linux to run.

This didn't stop people from trying to run Linux on them, but this was only achievable via "NOMMU". As the name implies,
it strips the kernel of the MMU requirement and therefore any benefits of process and memory isolation that it provided.
Not ideal for real world applications!

### Improving Wokwi's Simulation Engine

Wokwi has supported a subset of the RISC-V instruction set architecture (ISA) since 2022, with the addition of the ESP32-C3,
but unlike the ESP32-S31, it lacked any privileged architecture features. Therefore, in order to support the ESP32-S31,
the simulation engine was improved by implementing:
- `U`/`S`/`M` privilege levels
- `Sv32` page-tables with translation lookaside buffer (TLB) support
- [CLIC](https://lists.riscv.org/g/tech-fast-int/attachment/76/0/clic_v0.9_20200423.pdf) (core local interrupt controller) with supervisor-mode interrupt routing

A TLB improves memory access performance by caching virtual-to-physical address translations. On a successful hit, the
translation is returned faster than it would take to traverse the page-tables.

The CLIC prioritises and masks interrupts per core, and on the ESP32-S31, it decides whether each one is handled in
machine or supervisor mode -- this is how OpenSBI hands the timer and UART interrupts to Linux.

## Espressif + Linux

Espressif is venturing into the big world of embedded Linux with the ESP32-S31, focusing on an "upstream-first" approach
for their kernel development. For more details, check out the talk given by Gustavo Henrique Nihei titled
"[Entering Linux Upstream-First: How a Newcomer MCU Vendor Builds Its Kernel Development Processes](https://www.youtube.com/watch?v=9e8vATloP1c)"
([PDF](https://hosted-files.sched.co/osselceu2026/d6/GustavoHNihei-elc-europe-2026.pdf)) at the Open Source Summit +
Embedded Linux Conference Europe 2026.

Gustavo details the development, framework and testing strategies that Espressif has developed in order to bring Linux to
the ESP32-S31. We won't repeat the entire talk here, but we'd like to briefly touch upon the frameworks which were mentioned.

### Build Frameworks

An update to Espressif's kernel repository kicks off three separate CI jobs, one for each supported build framework.

{{< figure
  src="img/slide-21.webp"
  alt="Framework Choice (slide 21) from Gustavo's talk"
  caption="Framework Choice (slide 21) from Gustavo's talk"
>}}

BuildRoot, OpenWrt and Yocto all offer a different approach to how the installation and its packages are managed, and what
features it offers to both the developer and end-user. For example, BuildRoot's workflow of rebuild and reflash mimics
what you already do with `idf.py build` and `idf.py flash`, whereas OpenWrt could allow package installation during
runtime. No matter which one you prefer, they all are built using the same board support package (BSP) and use the
exact same kernel version.

#### Developer Preview

You can experiment with Linux on the ESP32-S31 right now -- the Yocto BSP layer is available at
[github.com/espressif/meta-espressif](https://github.com/espressif/meta-espressif). It is experimental right now, so be
sure to report any issues you run into!

{{< github repo="espressif/meta-espressif" >}}

After downloading and setting up the prerequisites, you're just a command away from building the image: `bitbake esp-image-core`.

This repository will build a musl-based userspace featuring an OpenEmbedded toolchain, execute-in-place (XIP) kernel and
a read-only `cramfs` root filesystem stored in the flash.


## Wokwi + ESP32-S31

Currently Linux support is only available for the ESP32-S31, so you'll need to have access to a
[development board](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/index.html) to try it. Don't
worry if you can't get your hands on a physical board however, as Wokwi supports the ESP32-S31 as the
ESP32-S31-Function-CoreBoard-1 and the [ESP-Mosaico](https://docs.wokwi.com/parts/board-esp-mosaico)!

We've prepared a demo using an image built using the `meta-espressif` layer to run Linux inside the browser. You
can interact with it at home, too. Just head to [our online viewer](https://wokwi.com/experimental/viewer?diagram=https://raw.githubusercontent.com/wokwi/esp32-s31-linux-demo/main/diagram.json&firmware=https://raw.githubusercontent.com/wokwi/esp32-s31-linux-demo/main/s31_full_flash.bin)
and the serial console should begin filling with boot information once the image (~16MB) is downloaded.

{{< figure
  src="img/wokwi-sim.webp"
  alt="ESP32-S31-based development board running Linux inside Wokwi"
  caption="ESP32-S31-based development board running Linux inside Wokwi"
>}}

Try running some of these commands and see what happens:
- `cat /proc/cpuinfo`
- `cat /proc/interrupts`
- `cat /proc/iomem`
- `free`
- `mount`

Feel free to poke around, and if anything breaks, just restart the simulation!

Accompanying the online viewer is the source repository for this project, which is available on GitHub at
[github.com/wokwi/esp32-s31-linux-demo](https://github.com/wokwi/esp32-s31-linux-demo). Here you can explore a little
bit of how Wokwi works -- `diagram.json` contains the microcontroller, wires and other components, whilst `wokwi.toml`
defines the firmware to load when the simulation is started.

{{< github repo="wokwi/esp32-s31-linux-demo" >}}

### Wokwi-in-the-loop (WITL)

[Wokwi offers powerful CI/CD integration](https://docs.wokwi.com/wokwi-ci/getting-started) which enables automated
testing of your embedded firmware. Wokwi-in-the-loop (WITL) is a testing methodology that combines the speed and
convenience of unit testing alongside the realism of hardware testing. In short, you can run your firmware on a
simulated hardware platform, interact with the firmware via buttons and sensors, and verify the behaviour via serial output.

In the aforementioned GitHub repository, WITL is used to verify that Linux boots properly, automatically pressing the
enter key when necessary, then executing `uname -a` in the shell. These are called [automation scenarios](https://docs.wokwi.com/wokwi-ci/automation-scenarios),
and this example can be seen under [`scenarios/linux-boot.test.yaml`](https://github.com/wokwi/esp32-s31-linux-demo/blob/main/scenarios/linux-boot.test.yaml),
or in the code block below.

```yaml
name: 'Linux boots to a shell'
version: 1
author: 'Uri Shaked'

steps:
  # Boot chain: U-Boot SPL, OpenSBI, U-Boot, then the kernel
  - wait-serial: 'U-Boot SPL'
  - wait-serial: 'OpenSBI'
  - wait-serial: 'Linux version 6.18'
  - wait-serial: 'Run /sbin/init as init process'
  # busybox init asks for a key press before it starts the shell
  - wait-serial: 'Please press Enter to activate this console.'
  - write-serial: "\n"
  - wait-serial: 'root@esp32s31:~#'
  - write-serial: "uname -a\n"
  - wait-serial: 'Linux esp32s31 6.18.0'
```

## Conclusion

Improvements to Wokwi's simulation engine, `Sv32` support in the ESP32-S31, and Espressif's first steps to supporting
embedded Linux now bring us closer to running Linux-flavoured firmware on our beloved microcontrollers. Initial Linux
support is shaky but promising, and anyone with an internet browser (you!) can experiment with it thanks to Wokwi. An
[online demo](https://wokwi.com/experimental/viewer?diagram=https://raw.githubusercontent.com/wokwi/esp32-s31-linux-demo/main/diagram.json&firmware=https://raw.githubusercontent.com/wokwi/esp32-s31-linux-demo/main/s31_full_flash.bin)
and the [accompanying repository](https://github.com/wokwi/esp32-s31-linux-demo) showcase how it all works together. These
provide a starting point for those wanting to get started today.