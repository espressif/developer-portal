---
title: "Linux prerequisites 🐧"
date: "2026-03-20"
summary: "This guide outlines the preliminary steps to set up your work environment and follow the workshops."
---

## VS Code Installation

* Go to the [VS Code download site](https://code.visualstudio.com/downloads)
* Download and install the Linux version (`.deb` for Ubuntu)
  ![](../assets/setup/1-ubuntu-vscode-download.webp)

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
This guide uses the latest LTS version of Ubuntu, 24.04.
{{< /alert >}}

* Once the file is downloaded, check the file name (referred to as `<file>.deb` below)

* Open the terminal (`CTRL+ALT+T`) and type:<br>

  ```console
  sudo apt install ./<file>.deb
  ```

* After installation, create a folder and try opening VS Code from the terminal:<br>

  ```console
  mkdir tmp
  cd tmp
  code .
  ```

* You should now see the VS Code interface

![](../assets/setup/2-vscode-screen.webp)

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
VS Code may ask whether you trust the author of the folder. This is important when working with `git` repositories, but for now it doesn’t matter. Click “Yes.”
{{< /alert >}}

## Installing Prerequisites

To **install** and configure the ESP-IDF toolchain, you need to have Python and git installed.

### Python

To install the ESP-IDF toolchain, Python version `3.12` or higher is required.

To check your Python version:

* Open a terminal (`CTRL+ALT+T`)
* Type `python3 --version`
* The result on Ubuntu 24.04 should be:

  ```console
  espressif@Ubuntu24:~$ python3 --version
  Python 3.12.3
  ```

This satisfies the prerequisite.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
If for some reason it doesn't, you can follow [this guide](https://learnubuntu.com/install-upgrade-python/)
{{< /alert >}}

### `git`

ESP-IDF development is based on [`git`](https://git-scm.com/), the version control tool also used for Linux kernel development. `git` is the foundation upon which GitHub is built.

To install git:

* Open a terminal (`CTRL+ALT+T`)
* Update the repositories:<br>

  ```
  sudo apt-get update
  ```
* Install `git`:<br>

  ```
  sudo apt-get install git
  ```
* Answer `Y` when prompted:

  ```console
     espressif@Ubuntu24:~$ sudo apt-get install git
     Reading package lists... Done
     Building dependency tree... Done
     Reading state information... Done
     The following additional packages will be installed:
     git-man liberror-perl
     Suggested packages:
     git-daemon-run | git-daemon-sysvinit git-doc git-email git-gui gitk gitweb
     git-cvs git-mediawiki git-svn
     The following NEW packages will be installed:
     git git-man liberror-perl
     0 upgraded, 3 newly installed, 0 to remove and 70 not upgraded.
     Need to get 4,806 kB of archives.
     After this operation, 24.5 MB of additional disk space will be used.
     Do you want to continue? [Y/n]
  ```
* Verify that git was installed correctly:<br>

  ```console
  > git --version
  > git version 2.43.0
  ```

### ESP-IDF Prerequisites

To **use** the ESP-IDF toolchain, you need to install some additional tools.

* On Ubuntu, you can install them all with the following command:<br>

  ```bash
  sudo apt-get install git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0
  ```

## Next Steps

> Continue with the [next step](../#installing-the-esp-idf-extension-for-vs-code).
