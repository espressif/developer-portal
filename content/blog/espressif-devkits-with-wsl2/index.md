---
title: "Working with Espressif's devkits using WSL2"
date: 2024-10-10
showAuthor: false
tags: ["ESP-IDF", "Windows", "WSL2"]
authors:
    - "jakub-kocka"
---

## Introduction

[WSL](https://learn.microsoft.com/en-us/windows/wsl/) (Windows Subsystem for Linux) is a great way to run Linux alongside Windows. However, when there is a need to use it with Espressif's devkits, it can be a bit tricky due to the required serial port forwarding. In this short article, a step-by-step guide is provided to help you work with Espressif's devkits using WSL.

### Alternatives

Many common operations (e.g., flashing, monitoring, etc. ) can be handled by the [esp_rfc2217_server](https://docs.espressif.com/projects/esptool/en/latest/esp32/esptool/remote-serial-ports.html?highlight=rfc) (Telnet) where the host Windows machine acts as the server and the WSL terminal acts as the client. However, tools like OpenOCD (Open On-Chip Debugger) cannot be used with this approach.

## Step-by-step Guide

The following steps describe a serial port forwarding method for WSL using [usbipd-win](https://github.com/dorssel/usbipd-win).
It is assumed that the latest version of WSL is already installed. A detailed guide and troubleshooting can be found in [Microsoft documentation](https://learn.microsoft.com/en-us/windows/wsl/connect-usb).

(*tested with:* Windows 11 (23H2), usbipd-win 4.3.0)

### 1. Install the USBIPD-WIN

Using package manager in the host terminal

    winget install usbipd

Or download the .msi file from the [latest releases](https://github.com/dorssel/usbipd-win/releases).
After the installation the terminal will be needed to restart.

### 2. Attach a devkit

In the host terminal run

    usbipd list

For example the used devkit is ESP32-C6 (**1-1 is the BUSID** which will be needed in the following commands)

    BUSID  VID:PID    DEVICE                                                        STATE
    1-1    303a:1001  USB Serial Device (COM4), USB JTAG/serial debug unit          Not shared


Bind the listed devkit with following command in host terminal (needs administrative privileges)

    usbipd bind --busid 1-1

Attach the device in the host terminal (needs already running instance of WSL)

    usbipd attach --wsl --busid 1-1

Now you should be able to see the devkit in the WSL terminal (run *lsusb* to check) and that should be everything needed. You can start using the attached serial port directly in the WSL.

### Troubleshooting note

If the devkit is not possible to use even after attaching (and is visible with the *lsusb* command) you can run the following command in the WSL terminal

    sudo modprobe cp210x

this will add kernel module with the needed controller but only for the instance. To add this permanently, it can be done with the following command

    echo "cp210x" | sudo tee -a /etc/modules

### Detach a devkit

When working with the devkit is completed, you can detach the devkit with the command in the host terminal

    usbipd detach --busid 1-1

## Conclusion

Working with WSL and Espressif's devkits for certain use cases may not be that simple. While for basic operations, using the esp_rfc2217_server might be enough (where the host machine acts as the server and the WSL terminal as the client) this method may not be always sufficient. In some cases, direct interaction with the devkit from within WSL becomes necessary. When that happens, serial port forwarding can be employed. With the help of this guide, we hope the process is now clearer, making it easier for you to work with Espressif's devkits in a WSL.

## Resources

- [Windows Subsystem for Linux Documentation](https://learn.microsoft.com/en-us/windows/wsl/)
- [Microsoft documentation WSL - Connect USB devices](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)
- [USBIPD-WIN](https://github.com/dorssel/usbipd-win)
