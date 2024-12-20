---
title: "Getting Started with NuttX and ESP32"
date: 2024-06-20T16:54:43-03:00
tags: ["NuttX", "Apache", "ESP32", "POSIX", "Linux"]
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
    - "tiago-medicci"
    - "eren-terzioglu"
    - "filipe-cavalcanti"
---

## Introduction to Apache NuttX RTOS

In this tutorial, we will do a quick overview of NuttX and its compatibility with Espressfi SoCs. After that, we will build and flash NuttX onto the ESP32-DevKitC board and connect to a Wi-Fi network. Along the way, we will also install the required dependencies for NuttX, set up the toolchains to build applications for Espressif SoCs, get NuttX's source code, and configure the project before building.

According to the Apache NuttX website:
<cite>[NuttX is a real-time operating system (RTOS) with an emphasis on standards compliance and small footprint. Scalable from 8-bit to 64-bit microcontroller environments, the primary governing standards in NuttX are Posix and ANSI standards.][1] </cite>

NuttX is the 2nd most popular community-based RTOS (along with Zephyr in the 1st position):

| Operating system | First commit | Governance    | License                    | Contributors | Pulse (jun10/2024) |
|------------------|--------------|---------------|----------------------------|--------------|--------------------|
| Zephyr           | 2014         | community     | Apache 2.0                 | 100+         | 942                |
| NuttX            | 2007         | community     | Apache 2.0                 | 100+         | 135                |
| RT-Thread        | 2009         | community     | Apache 2.0                 | 100+         | 67                 |
| RIOT             | 2010         | community     | LGPL2.1                    | 100+         | 71                 |
| Tyzen RT         | 2015         | Samsung       | Apache 2.0                 | 100+         | 36                 |
| myNewt           | 2015         | Community     | Apache 2.0                 | 100+         | 25                 |
| mbed OS          | 2013         | ARM           | Apache 2.0 or BSD-3 Clause | 100+         | 7                  |
| FreeRTOS         | 2004         | Richard Barry | MIT                        | 100+         | 6                  |
| Contiki-NG       | 2016         | community     | BSD-3 Clause               | 100+         | 4                  |
| CMSIS-5          | 2016         | ARM           | Apache 2.0                 | 100+         | 0                  |
| Azure-RTOS       | 2020         | Microsoft     | Microsoft Software License | 10+          | archived           |

— <cite>[Table by Alin Jerpelea, presented on NuttX Workshop 2024][2]</cite>

Its standards conformance (POSIX and ANSI, mostly) allows software developed under other OSes (under the same standards, such as software developed for Linux) to be easily ported to NuttX, enabling embedded applications to reuse tested applications. In such a sense, NuttX can be seen as the closest alternative to Linux for embedded software, providing interfaces similar to the ones used by Embedded Linux applications to SoCs that do not require running Linux directly.

NuttX supports more than 300 boards from different architectures and its active community keeps providing support for newer devices and boards.Espressif SoCs are supported on NuttX!

### NuttX Documentation

The primary source of information for NuttX is its documentation, which is accessible at https://nuttx.apache.org/docs/.

## Supported Espressif SoCs in NuttX

NuttX currently supports Espressif's ESP32, ESP32-C and ESP32-S series. Peripheral support is increasing constantly. Those include but are not limited to GPIO, DAC, DMA, SPI, I2C, I2S, Wi-Fi, Bluetooth and many more.

Currently, Espressif SoCs supported on NuttX are divided into two different architectures: RISC-V and Xtensa.

### RISC-V

- [ESP32-C3](https://nuttx.apache.org/docs/latest/platforms/risc-v/esp32c3/index.html#peripheral-support)
- [ESP32-C6](https://nuttx.apache.org/docs/latest/platforms/risc-v/esp32c6/index.html#peripheral-support)
- [ESP32-H2](https://nuttx.apache.org/docs/latest/platforms/risc-v/esp32h2/index.html#peripheral-support)

### Xtensa

- [ESP32](https://nuttx.apache.org/docs/latest/platforms/xtensa/esp32/index.html#peripheral-support)
- [ESP32-S2](https://nuttx.apache.org/docs/latest/platforms/xtensa/esp32s2/index.html#peripheral-support)
- [ESP32-S3](https://nuttx.apache.org/docs/latest/platforms/xtensa/esp32s3/index.html#peripheral-support)

## Getting started with NuttX and ESP32

{{< alert >}}
The following steps use Ubuntu 22.04 as an example. Please check the [official documentation](https://nuttx.apache.org/docs/latest/quickstart/install.html#prerequisites) for other Operating Systems.
{{< /alert >}}

### Installing System Dependencies

Install the system dependencies required to build NuttX:

``` bash
sudo apt install \
automake binutils-dev bison build-essential flex g++-multilib gcc-multilib \
genromfs gettext git gperf kconfig-frontends libelf-dev libexpat-dev \
libgmp-dev libisl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev xxd \
libtool picocom pkg-config python3-pip texinfo u-boot-tools util-linux
```

Also, please install some python packages:

```bash
pip install kconfiglib
```

### Espressif Tools and Toolchains

Once the NuttX dependencies are available, it’s time to install the compilation tools for Espressif SoCs.

Install `esptool`:

```bash
pip install esptool==4.8.dev4
```
Finally, install the toolchains to build the Espressif SoCs. It can be installed depending on the SoC being used, but it is highly recommended to keep all of them installed.

#### RISC-V SoCs (ESP32-C3, ESP32-C6, ESP32-H2)

All RISC-V SoCs use the same toolchain. Currently (Jun 2024), NuttX uses the xPack’s prebuilt toolchain based on GCC 13.2.0-2 for RISC-V devices. Please, visit the [ESP32-C3's Toolchain section](https://nuttx.apache.org/docs/latest/platforms/risc-v/esp32c3/index.html#esp32-c3-toolchain) in the NuttX documentation to check for the newest recommended RISC-V toolchain.

Create a directory to install the toolchain. It can be on your home directory:
```bash
mkdir -p ~/riscv-none-elf-gcc
```

Download and extract the toolchain on the new directory:
```bash
cd ~/riscv-none-elf-gcc
wget https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz
tar -zxf xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz
```

Once extracted, add the location of the binaries to the user’s PATH and reload the terminal:

```bash
echo "export PATH=$HOME/riscv-none-elf-gcc/xpack-riscv-none-elf-gcc-13.2.0-2/bin:\$PATH" >> ~/.bashrc
```

This last step is optional and applicable only if you want to make the toolchain available automatically, even after a restart. On the other hand, exporting it to the `PATH` variable before using it is sufficient.
Please also note that the `~.bashrc` is automatically sourced after a logout/login or after restarting the machine.

Make sure to either **1)** export the `PATH` with the toolchain or **2)** source the `~.bashrc` or **3)** logout and login or **4)** restart the machine.

#### Xtensa SoCs (ESP32, ESP32-S2, ESP32-S3)

Each Xtensa-based device has its own toolchain, which needs to be downloaded and configured separately. Please, double-check [ESP32](https://nuttx.apache.org/docs/latest/platforms/xtensa/esp32/index.html#esp32-toolchain), [ESP32-S2](https://nuttx.apache.org/docs/latest/platforms/xtensa/esp32s2/index.html#esp32-s2-toolchain) and [ESP32-S3](https://nuttx.apache.org/docs/latest/platforms/xtensa/esp32s3/index.html#esp32-s3-toolchain) toolchain sections to get the link for the recommended toolchain for each SoC.

##### **ESP32**:

Although ESP32, ESP32-S2 and ESP32-S3 have their own toolchain, the process of downloading and installing is very similar:

First of all, export a variable to identify the toolchain being installed:

```bash
export CHIPNAME=esp32
```

Create a directory to install the toolchain. It can be on your home directory:
```bash
mkdir -p ~/xtensa-$CHIPNAME-elf-gcc
```

Download and extract the toolchain on the new directory:
```bash
cd ~/xtensa-$CHIPNAME-elf-gcc
wget https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/xtensa-$CHIPNAME-elf-12.2.0_20230208-x86_64-linux-gnu.tar.xz
tar -xf xtensa-$CHIPNAME-elf-12.2.0_20230208-x86_64-linux-gnu.tar.xz
```

Once extracted, add the location of the binaries to the user’s PATH and reload the terminal:

```bash
echo "export PATH=$HOME/xtensa-$CHIPNAME-elf-gcc/xtensa-$CHIPNAME-elf/bin:\$PATH" >> ~/.bashrc
```

To check if the toolchain is properly installed:
```bash
xtensa-esp32-elf-gcc --version
```

##### **ESP32-S2**:

Similarly, for ESP32-S2:

```bash
export CHIPNAME=esp32s2
```

And run the same steps to create the directory to install the toolchain, download and extract the toolchain and export it to the `PATH`, as it was done for [ESP32](#esp32).

##### **ESP32-S3**:

Similarly, for ESP32-S3:

```bash
export CHIPNAME=esp32s3
```

And run the same steps to create the directory to install the toolchain, download and extract the toolchain and export it to the `PATH`, as it was done for [ESP32](#esp32).

### Getting NuttX

Clone the NuttX repository and the NuttX Apps repository in a directory called `nuttxspace`. The Apps repository is optional, as it contains mostly example applications.

```bash
mkdir nuttxspace
cd nuttxspace
git clone https://github.com/apache/nuttx.git nuttx
git clone https://github.com/apache/nuttx-apps apps
```

### Building an App to Connect to a Wi-Fi network

NuttX provides ready-to-use board default configurations that enable the required config (from Kconfig) for a use scenario, such as Wi-Fi or I2C. To enter NuttX directory and list all available configurations for the ESP32 DevKitC V4 board you can use the following command:

```bash
cd nuttx
./tools/configure.sh -L | grep esp32-devkitc
```

This command lists all available configurations for the ESP32-DevKitC board. These pre-defined configurations can be modified before building to better suit your application.

More information about this board can be found [here](https://nuttx.apache.org/docs/latest/platforms/xtensa/esp32/boards/esp32-devkitc/index.html). It embeds a USB-to-UART bridge chip to enable accessing the device's UART0 through a micro-USB port. The board is also powered up through the USB.

Connect the board to your computer and check if the associated USB port is available. In Linux:

```bash
ls /dev/tty*
```

The currently logged user should have read and write access to the serial port over USB. This is done by adding the user to dialout group with the following command:

```bash
sudo usermod -a -G dialout $USER
```

#### Connecting to a Wi-Fi Access Point

As an example, let's use the Wi-Fi configuration for the ESP32 DevKitC board with the following command:

```bash
./tools/configure.sh esp32-devkitc:wifi
```

To change some configuration in the default configuration that was just loaded, use `menuconfig`:

```bash
make menuconfig
```

The `menuconfig` utility allows you, for instance, to enable peripherals, modify the NuttX kernel settings, enable support for device drivers, configure the *NuttShell* and the file system, enable example programs and set up the Wi-Fi credentials.

To quickly connect to a known Wi-Fi network, navigate to `Application Configuration -> Network Utilities -> Network Initialization -> WAPI Configuration` and set the SSID (the name of the Wi-Fi Access Point) and the passphrase to connect to it.

It is also necessary to set how to get a valid IP address after connecting to the Wi-Fi network. In this example, DHCP will be used to receive it from the network automatically. In `Application Configuration -> Network Utilities -> Network Initialization -> IP Address Configuration`, select `Use DHCP to get IP address`.

Navigate to the `Exit` and, when prompted, save the current settings.

Before building and flashing the firmware, it is necessary to build the bootloader to boot NuttX:

```bash
make bootloader
```

To build and flash the ESP32 board, use the following command (modifying the USB port accordingly):

```bash
make flash ESPTOOL_PORT=/dev/ttyUSB0 ESPTOOL_BINDIR=./
```

When flashing is complete, you can use *picocom* to open a serial console by running:

```bash
picocom -b115200 /dev/ttyUSB0
```

Please check the following example that shows the device connecting to the Wi-Fi network and other commands that can be used in the *NuttShell*, like `ifconfig`:

{{< asciinema key="nuttx-esp32-getting-started" idleTimeLimit="2" speed="1.5" poster="npt:0:09" >}}

It's worth noting that there is no need to pre-define the SSID/passphrase of the Wi-Fi network in `menuconfig`. NuttX provides the `wapi` application that manages the Wi-Fi subsystem. More information about `wapi` can be found in [NuttX documentation][3]. Experiment with `wapi` for scanning available access points, for instance:

```bash
wapi scan wlan0
```

## Conclusion

NuttX is one of the most preferred RTOS for developers familiar with Linux interfaces (including the so-called "Embedded Linux") because of its POSIX-compliant interface. Most of the features covered by this introductory article rely on usual applications, like the *NuttShell* (or NSH: the shell system used in NuttX, similar to bash) and usual built-in commands, like `ping`. Stay tuned for more articles about NuttX (in special, for the question "Why using NuttX"?).

## Useful Links

- [NuttX Documentation](https://nuttx.apache.org/docs/)
- [NuttX GitHub](https://github.com/apache/nuttx)
- [NuttX channel on Youtube](https://www.youtube.com/nuttxchannel)
- [Developer Mailing List](https://nuttx.apache.org/community/#mailing-list)

[1]: https://nuttx.apache.org/
[2]: https://youtu.be/DXbByNeatcU?si=BhxTyNqiZv3HPztl&t=53
[3]: https://nuttx.apache.org/docs/latest/applications/wireless/wapi/commands
