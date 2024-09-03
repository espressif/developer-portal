---
title: "Zephyr RTOS on ESP32 —First Steps"
date: 2021-02-24
showAuthor: false
authors: 
  - glauber-ferreira
---
![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*yyC5ZPSpUSEvVfpN.png)

> __Attention:__  The installation process outlined in this article has become obsolete. To ensure accurate and up-to-date instructions, kindly consult the [new installation link](https://docs.zephyrproject.org/latest/develop/getting_started/index.html). Your understanding is greatly appreciated.

Zephyr is a very low footprint RTOS maintained by the Linux Foundation and ported to several architectures. This RTOS has been gaining massive support from many silicon manufacturers and an ever-growing list of contributors on its mainline.

Espressif has been expanding support for Zephyr RTOS on ESP32, an extremely popular SoC among hobbyists but also widely used in commercial applications. Since its release, this SoC became famous for integrating both Wifi and Bluetooth stacks on a single chip and for being very cost-competitive. In this post, all the required steps to prepare your host’s environment to use Zephyr on ESP32 will be explained. In the end, we will run a __hello world__  application to validate our setup. In this step-by-step guide, the __ESP32 DevKitC__  board will be used.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*29MFNYBkDFWU8jQdf-lE7g.png)

The first thing to do is to prepare Zephyr’s development environment. I briefly list the steps required for Linux (Ubuntu 20.04.1 LTS), for the most up-to-date documentation, and for support for other Operating Systems you can see Zephyr’s official [Getting Started](https://docs.zephyrproject.org/latest/getting_started/index.html) guide and, specifically, you can see most of the original instructions included in this post in the [ESP32 SoC section](https://docs.zephyrproject.org/latest/boards/xtensa/esp32/doc/index.html) of the Zephyr Project documentation.

## Updating Linux

Before we start, update your repositories list.

```
sudo apt update
sudo apt upgrade
```

## Installing dependencies

Run __apt__  to install dependencies:

```
sudo apt install --no-install-recommends git cmake \
ninja-build gperf ccache dfu-util device-tree-compiler wget \
python3-dev python3-pip python3-setuptools python3-tk \
python3-wheel xz-utils file make gcc gcc-multilib \
g++-multilib libsdl2-dev
```

Check the __CMake__  version on your host.

```
cmake --version
```

If the version displayed is __3.13.1__  or above then skip to the next section. Otherwise, follow these three steps to update CMake:

Add the Kitware signing key:

```
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -
```

Add the Kitware apt repository for your OS release. For Ubuntu 20.04 LTS:

```
sudo apt-add-repository \
'deb https://apt.kitware.com/ubuntu/ focal main'
```

Reinstall CMake

```
sudo apt update
sudo apt install cmake
```

## Getting Zephyr and installing Python dependencies

Install __west__ and ensure that __~/.local/bin__  is part of your __PATH__  environment variable:

```
pip3 install -- user -U west
echo ‘export PATH=~/.local/bin:”$PATH”’ >> ~/.bashrc
source ~/.bashrc
```

Here is a worthy observation: west is the tool that manages the entire life-cycle of a Zephyr-based project. This is made clearer below. Now, get Zephyr’s source code:

```
west init ~/zephyrproject
cd ~/zephyrproject
west update
west espressif update
```

Be patient, these last commands will fetch Zephyr’s repository and all the HALs (including ESP32’s) already ported to this RTOS. Note that we do not explicitly call a git command to clone the repositories, __west__  takes care of everything. Now, export a Zephyr CMake package. This causes CMake to automatically load some boilerplate code.

```
west zephyr-export
```

Zephyr’s __requirements.txt__  file declares additional Python dependencies. Install them through pip3.

```
pip3 install --user -r \
~/zephyrproject/zephyr/scripts/requirements.txt
```

## Installing Zephyr’s toolchain

Zephyr’s SDK adds several additional tools for the host. Download the SDK installer:

```
cd ~
wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.12.2/zephyr-sdk-0.12.2-x86_64-linux-setup.run
```

Run the installer, this will install the SDK under the __~/zephyr-sdk-0.12.2__  folder.

```
chmod +x zephyr-sdk-0.12.2-x86_64-linux-setup.run
./zephyr-sdk-0.12.2-x86_64-linux-setup.run -- -d ~/zephyr-sdk-0.12.2
```

This is one of the default locations recommended for SDK installation, for other locations check Zephyr’s official documentation.

## Adding ESP32 toolchain to the project

Before building, we need to tell Zephyr where to find the toolchain for ESP32’s Xtensa architecture. Open your terminal, and type the following commands:

```
export ZEPHYR_TOOLCHAIN_VARIANT="espressif"
export ESPRESSIF_TOOLCHAIN_PATH="${HOME}/.espressif/tools/xtensa-esp32-elf/esp-2020r3-8.4.0/xtensa-esp32-elf"
export PATH=$PATH:$ESPRESSIF_TOOLCHAIN_PATH/bin
```

Alternatively, you can add the above commands to your __~/.bashrc__  configuration file, making those variables available at any time on your current working session. Finally, install the toolchain:

```
cd ~/zephyrproject
west espressif install
```

## Building the application

Remember I mentioned __west__  takes part in all stages of a Zephyr’s project life-cycle? Well, we’ll see it in action here again. Build the __hello_world__  project for the ESP32 board from the sample code folder.

```
cd ~/zephyrproject/zephyr/samples/hello_world
west build -p auto -b esp32
```

If the previous build fails with a message indicating missing Python packages, your OS likely uses __python2.x__ by default. If so, make __python3__  its preferred choice by running the following:

```
sudo update-alternatives --install \
/usr/bin/python python /usr/bin/python3 10 && alias pip=pip3
```

Then, run the build command again.

We will need a serial program utility to see the logs, use the one of your preference. Here I use __minicom__ .

```
sudo apt install minicom
```

To open minicom’s serial settings, type this command:

```
sudo minicom -s
```

After __minicom__  is opened, chose the __serial port setup__  option and set it to __115200 8N1__ .

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*9DGveFzFRn6_QDKt)

## Flashing the binary

Flashing the binary is quite simple, just do the following:

```
west flash; minicom
```

In older ESP32 DevKitC boards, the chip may run to standby mode until the __BOOT__  button is pressed, which triggers the flashing action. Newer boards start flashing immediately.

If you have been following everything up to this point, after some ESP32’s boot messages, you should see the expected hello message.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/0*qr4Vy3H49QFKHaKF)

There you have it! Your development environment was properly configured and you have run your first application using Zephyr on ESP32!

## Supported Features

ESP32 support for Zephyr is growing. By the time I am writing this post, it includes basic peripherals such as:

- UART
- I2C
- GPIO
- SPI Master
- Timers

WiFi native driver support for ESP32 is also coming to Zephyr’s upstream, you can check it by clicking on its [PR link](https://github.com/zephyrproject-rtos/zephyr/pull/32081). Additionally, please follow [here](https://github.com/zephyrproject-rtos/zephyr/issues/29394) for overall future road-map for ESP32 support.

## Summary

In this post, we saw how to set the environment for Zephyr RTOS and how to build a sample project for an ESP32 based board. The whole process has been greatly simplified since Xtensa’s toolchain installation has been incorporated into the west tool commands.

Stay tuned to Zephyr’s documentation and repository for the most recent supported peripherals. Espressif Team keeps actively working on porting and supporting its SoCs on Zephyr.
