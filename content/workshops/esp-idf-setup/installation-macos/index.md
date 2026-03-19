---
title: "macOS prerequisites 🍎"
date: "2025-11-12"
summary: "This guide outlines the preliminary steps to set up your work environment and follow the workshops."
---

## VS Code Installation

* Go to the [VS Code download site](code.visualstudio.com/downloads)
* Download and install the macOS version
  ![](../assets/setup//1-ubuntu-vscode-download.webp)

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
This guide uses macOS Sequoia.
{{< /alert >}}

* Once the file is downloaded, install VS Code
* Press `CTRL+SPACE` and search for `Code`. Click on the VS Code icon
* You should now see the VS Code interface

![](../assets/setup/2-vscode-screen.webp)

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
VS Code may ask whether you trust the author of the folder. This is important when using `git` repositories, but for now it doesn’t matter. Click “Yes.”
{{< /alert >}}

## Installing Prerequisites

To __install__ and configure the ESP-IDF toolchain, you need to have Python and git installed.
In this guide, we’ll use the [homebrew](https://brew.sh/) package manager (`brew`).

__Installing `homebrew`__

To install `homebrew`:

* Open a terminal
* Type:<br>

  ```console
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

### Python

The ESP-IDF toolchain uses the system version of Python.
You can check the Python version by typing in the terminal:

```console
python3 --version
```

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
If Python is not already installed, you can install it with the following command from the terminal:

```
brew install python3
```

{{< /alert >}}

### `git`

ESP-IDF development is based on [`git`](https://git-scm.com/), the version control tool used, among others, for Linux kernel development. `git` is the foundation upon which GitHub is built.

To install git:

* Open a terminal
* Install `git`:<br>

  ```
  sudo brew install git
  ```
* Verify that git was installed correctly:<br>

  ```console
  > git --version
  > git version 2.43.0
  ```

### Installing Additional Prerequisites

To __use__ the ESP-IDF toolchain, you need to install the remaining tools.

* Open a terminal
* Type:<br>

  ```console
  brew install cmake ninja dfu-util
  ```

During the installation process, you may encounter some issues. Refer to the [Troubleshooting](#troubleshooting) section to see if your error is listed there.

## Next Steps

> Continue with the [next step](../#installing-the-esp-idf-extension-for-vs-code).

---

## Troubleshooting

During the installation process, you may encounter some common errors.
Below are the most frequent ones, along with their causes and solutions.

### Xcode Command Line Tools Not Installed

__Error__

```console
xcrun: error: invalid active developer path (/Library/Developer/CommandLineTools),
missing xcrun at: /Library/Developer/CommandLineTools/usr/bin/xcrun
```

__Cause__
The Xcode command-line tools are not installed or not properly configured.

__Solution__

```console
xcode-select --install
```

### Toolchain Not Found (`xtensa-esp32-elf`)

__Error__

```console
WARNING: directory for tool xtensa-esp32-elf version esp-2021r2-patch3-8.4.0 is present, but tool was not found
ERROR: tool xtensa-esp32-elf has no installed versions. Please run 'install.sh' to install it.
```

__Cause__
On macOS systems with Apple Silicon architecture, some binary tools require Rosetta 2 to work.

__Solution__

```console
/usr/sbin/softwareupdate --install-rosetta --agree-to-license
```

### “Bad CPU type in executable” Error

__Error__

```console
zsh: bad CPU type in executable: ~/.espressif/tools/xtensa-esp32-elf/esp-2021r2-patch3-8.4.0/xtensa-esp32-elf/bin/xtensa-esp32-elf-gcc
```

__Cause__
The executable requires Rosetta 2 to run on macOS M1/M2/M3 systems.

__Solution__

```console
/usr/sbin/softwareupdate --install-rosetta --agree-to-license
```
