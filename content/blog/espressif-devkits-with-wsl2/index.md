---
title: "Working with Espressif's SoCs using WSL2"
date: 2024-11-04
showAuthor: false
authors:
    - jakub-kocka
tags: ["ESP-IDF", "devkit", "Windows", "WSL", "WSL2", "USB"]
---

Released in 2016 by Microsoft, the Windows Subsystem for Linux [(WSL)](https://learn.microsoft.com/en-us/windows/wsl/) is a feature that allows the use of a Linux environment with no need of a virtual machine, container or dual boot. The [WSL](https://learn.microsoft.com/en-us/windows/wsl/) is a great way to run Linux alongside Windows.

## Introduction

In some cases, users can't use Windows PowerShell for developing ESP-IDF applications for ESP SoCs, or when WSL is already in use, the flashing and monitoring steps can be tricky.

This article is a step-by-step guide, provided to help you work with Espressif's SoCs when using WSL.

### Alternatives

Many common operations (e.g., flashing, monitoring, etc. ) can be handled by the [ESP_RFC2217_server](https://docs.espressif.com/projects/esptool/en/latest/esp32/remote-serial-ports.html) (Telnet) where the host Windows machine acts as the server and the WSL terminal acts as the client. However, tools like [OpenOCD](https://openocd.org/) (Open On-Chip Debugger) cannot be used with this approach.

## Guide

The following steps describe a serial port forwarding method for WSL using [USBIPD-WIN](https://github.com/dorssel/usbipd-win).
It is assumed that the latest version of WSL2 is already installed. A detailed guide and troubleshooting can be found in [Microsoft documentation](https://learn.microsoft.com/en-us/windows/wsl/connect-usb).

(*tested with:* Windows 11 (23H2), USBIPD-WIN 4.3.0)

### 1. Install the USBIPD-WIN

Using package manager in the host terminal, run:

```bash
winget install usbipd
```

Or download the `.msi` file from the [latest releases](https://github.com/dorssel/usbipd-win/releases) and install it manually.

After the installation, the terminal must be restarted.

### 2. Attach the USB

With the devkit connected, in the host terminal, run:

```bash
usbipd list
```

In this example, the devkit used is the **ESP32-C6-DevKit-C**, with the **1-1 is the BUSID**, which will be needed in the following commands.

```text
BUSID  VID:PID    DEVICE                                                        STATE
1-1    303a:1001  USB Serial Device (COM4), USB JTAG/serial debug unit          Not shared
```

Now, bind the listed devkit with following command in host terminal (needs administrative privileges).

```bash
usbipd bind --busid 1-1
```

Attach the device in the host terminal (needs already running instance of WSL).

```bash
usbipd attach --wsl --busid 1-1
```

Now you should be able to see the devkit in the WSL terminal. You can run `lsusb` command to check it. You can now start using the attached serial port directly in the WSL.

### Troubleshooting note

If is not possible to use the devkit, even after attaching, but it is visible with the `lsusb` command, you can run the following command in the WSL terminal:

```bash
sudo modprobe cp210x
```

This will add kernel module with the needed controller only for the current instance.

To add this permanently, it can be done with the following command:

```bash
echo "cp210x" | sudo tee -a /etc/modules
```

### Detach the USB

When you don't need to keep the devkit connected, you can detach the USB with this command:

```bash
usbipd detach --busid 1-1
```

## Conclusion

Working with WSL and Espressif's SoCs, for certain use cases may not be that simple. While for basic operations, using the `ESP_RFC2217_server` might be enough (where the host machine acts as the server and the WSL terminal as the client) this method may not be always sufficient. In some cases, direct interaction with the devkits from within WSL becomes necessary. When that happens, serial port forwarding can be employed.

With the help of this guide, we hope the process is now clearer, making it easier for you to work with Espressif's devkits in a WSL.

## Resources

- [Windows Subsystem for Linux Documentation](https://learn.microsoft.com/en-us/windows/wsl/)
- [Microsoft documentation WSL - Connect USB devices](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)
- [USBIPD-WIN](https://github.com/dorssel/usbipd-win)
