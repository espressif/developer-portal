---
title: Getting Started with ESP32 and NuttX
date: 2020-11-30
showAuthor: false
authors: 
  - sara-monteiro
---
[Sara Monteiro](https://medium.com/@saramonteirosouza44?source=post_page-----fd3e1a3d182c--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F6d272ea832ca&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fgetting-started-with-esp32-and-nuttx-fd3e1a3d182c&user=Sara+Monteiro&userId=6d272ea832ca&source=post_page-6d272ea832ca----fd3e1a3d182c---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*j-XGptYZE3DQ9tV1vJY2Iw.png)

## Introduction

This article is part of the “First Steps with ESP32 and NuttX” series. A series whose objective is to present an overview of the NuttX Operating System and to provide instructions for using NuttX on ESP32.

The first part of the series instructs the preparation of the environment, the compilation, and the building of the Operating System (NuttX) until the firmware upload to the SoC (ESP32).

The second part of the series demonstrates how to run the famous “[Hello World](https://medium.com/the-esp-journal/blink-led-on-esp32-with-rtos-nuttx-d33c7dc62156)” from the Embedded Systems world, i.e., an application that blinks an LED.

This series used the ESP32 DevKit-C v1 development board and the Ubuntu Linux distribution (Ubuntu 18.04.5 LTS). The used NuttX version in this tutorial is the latest from mainline. Although it’s recommended to use the latest stable version, the features that have been implemented for ESP32 are going to be included from release 10.1 on.

If you do not have a development board, but you want to run NuttX on your own computer to test the basic functionality of the system, try using the simulator, the installation guide can be found at [http://nuttx.apache.org/docs/latest/guides/simulator.html](http://nuttx.apache.org/docs/latest/guides/simulator.html) .

## What is NuttX?

NuttX is a Real-Time Operating System specially designed to be used in Embedded Systems with microcontrollers or processors from 8 to 64 bits and which have a small footprint. NuttX is also a customizable Operating System, i.e., the developer can include in the image that will be generated only what is really useful for the project. One of NuttX’s main commitments is to be POSIX and ANSI standards-compliant. Both standards define the generic interface for Operating Systems, which contributes to portability, code reuse, and support for applications that use this interface.

With these characteristics, NuttX has become attractive to be used in microcontrollers and SoCs. And Espressif, ESP32’s manufacturer, is currently investing in support of ESP32 for NuttX.

The official NuttX documentation can be found on the Apache Foundation website where the project is currently incubated: [http://nuttx.apache.org/docs/latest/index.html](http://nuttx.apache.org/docs/latest/index.html).

## Building and Flashing Process

Before starting the NuttX compilation and build, update your repositories and install the dependencies:

```
sudo apt update
sudo apt upgrade
sudo apt-get install automake bison build-essential flex gperf git libncurses5-dev libtool libusb-dev libusb-1.0.0-dev pkg-config
```

1. Create a directory to group all NuttX repositories and access it:

```
mkdir ~/nuttxspace && cd ~/nuttxspace
```

2. Clone the apps repository, which includes examples and other applications and the nuttx repository, that contains the OS source codes:

```
git clone https://github.com/apache/incubator-nuttx.git nuttx
git clone https://github.com/apache/incubator-nuttx-apps.git apps
```

__Note:__  NuttX uses a build system similar to the Linux Kernel ([https://www.kernel.org/doc/html/latest/kbuild/index.html](https://www.kernel.org/doc/html/latest/kbuild/index.html)). And so, It uses kconfig-frontends as its configuration system. The tools repository is another repository that may be used only to install this package. However, if you are using Ubuntu 19.10 or later, these distributions already contain the “kconfig-frontends” package and therefore you do not need to clone this repository, and you may just install the package through the following command:

```
sudo apt-get install kconfig-frontends
```

Otherwise, clone the repository and install kconfig-frontends manually via the tools repository:

```
git clone https://bitbucket.org/nuttx/tools.gitcd ~/nuttxspace/tools/kconfig-frontends
./configure --enable-mconf
make
sudo make install
sudo ldconfig
```

3. The expected result should be this:

```
~/nuttxspace$: ls
apps nuttx tools
```

4. Download and decompress the pre built cross compiler for ESP32 in Linux environment. The cross compiler will be used to convert the source code into an executable code.

```
curl https://dl.espressif.com/dl/xtensa-esp32-elf-gcc8_2_0-esp-2020r2-linux-amd64.tar.gz | tar -xz
```

Since the /opt/ directory is a space commonly used to store third party software, create a directory at /opt/ to keep the cross compiler for xtensa architecture:

```
sudo mkdir /opt/xtensa
```

Move the cross compiler to this new directory:

```
sudo mv xtensa-esp32-elf/ /opt/xtensa/
```

Now you have the cross compiler for ESP32 at this path, in order to invoke the cross compiler binaries as commands, you should add its absolute path to PATH, which is a Linux environment variable that informs the shell where to search for executables or programs that are invoked through commands. To do so, use the following command:

```
export PATH=$PATH:/opt/xtensa/xtensa-esp32-elf/bin
```

5. Install the esptool Python module to perform the download of all binaries to the ESP32 through serial.

```
pip3 install esptool
```

You may have noticed the following warning message at the end of the installation:

*“WARNING: The scripts pyserial-miniterm and pyserial-ports are installed in ‘/home/<user>/.local/bin’ which is not on PATH.”*

This messages warns us that esptool, as well as other programs that are used by esptool, were installed at a path which is not included on PATH, so these programs are not visible at the current shell. To solve this issue, add this path to PATH and load it using the following command (Replace <user> with your user name):

```
export PATH=$PATH:/home/<user>/.local/bin
```

__NOTE:__  Once you leave your terminal session, PATH will loose these paths added to it temporarily and you will need to run the “export” commands again in a new session. It may be a little annoying. If you want to keep these paths permanent to shell sessions, open your *bash* file and add these paths to PATH, through the following command:

```
sudo nano ~/.bashrc
```

Paste it to the end of the file (Replace <user> with your user name):

```
# Add esptool.py and its dependencies directory 
PATH=$PATH:/home/<user>/.local/bin# Add the cross compiler path for ESP32
PATH=$PATH:/opt/xtensa/xtensa-esp32-elf/bin
```

6. Besides the Operating System with the application, ESP32 also requires a bootloader and a partition table. Both of them can be customized and built to answer customer’s expectations. However, for the sake of simplicity, these binaries were previously generated for you from the latest ESP-IDF’s master branch and can be easily downloaded from this [repository](https://github.com/espressif/esp-nuttx-bootloader) kept by Espressif. To do so, create a dedicated directory aside nuttx directory to keep these binaries and download these pre-configured binaries:

```
mkdir esp-binscurl -L "https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/bootloader-esp32.bin" -o esp-bins/bootloader-esp32.bincurl -L "https://github.com/espressif/esp-nuttx-bootloader/releases/download/latest/partition-table-esp32.bin" -o esp-bins/partition-table-esp32.bin
```

In case you want to generate these binaries yourself, take a look at [here](https://github.com/espressif/esp-nuttx-bootloader) and check out the step by step.

7. In the NuttX directory run the configuration script to create a configuration file for ESP32.

```
cd nuttx
./tools/configure.sh esp32-devkitc:nsh
```

8. Since in the next step you will use the serial to download the binaries, run the following command to add your user to the dialout group, which has the permission to access the serial driver.

```
sudo adduser <user name> dialout
```

This addition will only permanently take effect after log out and log in. So, a workaround for it is to temporarily change the current user to the dialout group:

```
newgrp dialout
```

9. Finally, from now on, connect your DevKit to your computer, build and download all the binaries:

```
make download ESPTOOL_PORT=/dev/ttyUSB0 ESPTOOL_BAUD=115200 ESPTOOL_BINDIR=../esp-bins
```

__NOTE:__  adjust the USB port according to your configuration. The last two arguments are optional. In case they’re not specified, the command will download only the application and it will use the default baud rate of 921600. Once the bootloader and partition table binaries are downloaded, it’s not necessary to download them next time.

In case the below command is interrupted because the Pyserial module was not installed, install it running the following command:

```
pip3 install pyserial
```

And make the download again.

## NuttX Shell Access

To access the NuttX shell, you only need a serial terminal. If you don’t have a serial terminal, I suggest the picocom. To install the picocom run the following command:

```
sudo apt-get install -y picocom
```

And finally, access the nsh (NuttX Shell):

```
sudo picocom /dev/ttyUSB0 -b 115200
```

NOTE: adjust the USB port according to your configuration.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*DXgY_u-Ln01PfSyZ)

## Next Steps

If you made it this far and accessed the NuttX shell, and everything is properly installed and configured, move on to the next article in the series and run the [Blink Led example](https://medium.com/the-esp-journal/blink-led-on-esp32-with-rtos-nuttx-d33c7dc62156)!

## NuttX Tips

This section is a bonus in order to summarize the main commands that are most used and show some simple and typical problems that can happen in your journey and how to work around them.

```
make distclean
```

It removes the configuration of the previous board and makes it available for the user to select another board or another configuration of the same board.

```
./tools/configure.sh boardname:configname
```

It selects the board (in this example it was esp32-devkitc) and the configuration to be used (in this example it was nsh config, which includes only the nuttx shell). There are other configurations that include support for certain peripherals and examples.

```
make menuconfig
```

It opens the configuration screen for the user to customize what he/she wants to add or to remove on the board. For example, it allows you to add drivers for a specific device, add debug messages, examples, etc.

```
make clean
```

It removes binary files generated from the previous built.

```
make apps_distclean
```

It cleans only application binaries. Kernel and driver binaries are kept.

```
make
```

It only builds your application.

```
make download ESPTOOL_PORT=<port> [ESPTOOL_BAUD=<baud>] [ ESPTOOL_BINDIR=<dir>]
```

It builds and downloads the application and bootloader and partition table binaries when these ones are specified.

## Troubleshooting

If after running the command *make menuconfig* you get the message like in the image below, it means that your terminal is too small. Just expand the screen and run it again.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*1S6mYFLIc1oSgNSV)

## References

NuttX Documentation: [http://nuttx.apache.org/docs/latest/index.html](http://nuttx.apache.org/docs/latest/index.html)

ESP32: [https://docs.espressif.com/projects/esp-idf/en/stable/get-started/index.html](https://docs.espressif.com/projects/esp-idf/en/stable/get-started/index.html)

Linux’s Build System: [https://www.kernel.org/doc/html/latest/kbuild/index.html](https://www.kernel.org/doc/html/latest/kbuild/index.html)

Simulator: [http://nuttx.apache.org/docs/latest/guides/simulator.html](http://nuttx.apache.org/docs/latest/guides/simulator.html)
