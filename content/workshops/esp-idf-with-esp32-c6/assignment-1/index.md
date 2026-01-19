---
title: "ESP-IDF and ESP32-C6 Workshop - Assignment 1: Install the Espressif-IDE"
date: 2024-06-30T00:00:00+01:00
lastmod: 2026-01-20
showTableOfContents: false
series: ["WS001EN"]
series_order: 2
showAuthor: false
---

## Assignment 1: Install Visual Studio Code and ESP-IDF plugin

---

You will need [Visual Studio Code](https://code.visualstudio.com/) and the installed ESP-IDF framework for this workshop. The first task will therefore be to install all the necessary tools.

In both cases, we will follow the instructions on the [GitHub pages of the ESP-IDF plugin for VS Code](https://github.com/espressif/vscode-esp-idf-extension?tab=readme-ov-file#how-to-use).

{{< tabs groupId="config" >}}
  {{% tab name="Windows" %}}
**Installation for Windows**

1. Install [Visual Studio Code](https://code.visualstudio.com/download)
2. Install the necessary [drivers](https://www.silabs.com/documents/public/software/CP210x_Universal_Windows_Driver.zip)
3. In VS Code, open **Extensions** (Ctrl + Shift + X or ⇧ + ⌘ + X)
4. Find the [ESP-IDF plugin](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension) and install it
5. Open *View -> Command Palette* (Ctrl + Shift + P or ⇧ + ⌘ + P) and type *Configure ESP-IDF Extension* in the newly opened line
6. Select the **Express** option and then select Github as download server and release/v5.5 as ESP-IDF version
7. Click "Install"

  {{% /tab %}}
  {{% tab name="Linux and Mac" %}}
**Installation for Linux and Mac**

1. Install [Visual Studio Code](https://code.visualstudio.com/download)
2. Install [prerequisites according to your distribution](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-macos-setup.html#step-1-install-prerequisites) (**Only step 1**, the entire guide deals with installing standalone ESP-IDF, which we don't need right now)
3. In VS Code, open **Extensions** (Ctrl + Shift + X or ⇧ + ⌘ + X)
4. Find the [ESP-IDF plugin](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension) and install it
5. Open *View -> Command Palette* (Ctrl + Shift + P or ⇧ + ⌘ + P) and type *Configure ESP-IDF Extension* in the newly opened line
6. Select the **Express** option and then select Github as download server and release/v5.5 as *ESP-IDF version*
7. Click "Install"
  {{% /tab %}}
{{< /tabs >}}

### Installing ESP BLE Prov

During one of the tasks, we will also try Wi-Fi provisioning. For this we will need an application through which we will tell our ESP chip the SSID and password for the network.

You can either search for the app in the app store of the respective system, or through the links below:

- Android: [ESP BLE Provisioning](https://play.google.com/store/apps/details?id=com.espressif.provble&pcampaignid=web_share)
- iOS: [ESP BLE Provisioning](https://apps.apple.com/us/app/esp-ble-provisioning/id1473590141)

### VSCode, ESP-IDF plugin and ESP-IDF itself

You may have noticed that during the ESP-IDF plugin installation, you also selected the version of ESP-IDF itself and had the option to choose a local ESP-IDF installation. So how do the ESP-IDF plugin and ESP-IDF itself relate?

ESP-IDF is a **standalone framework** that can be used without VSCode and plugin. It is controlled from the command line (so it has no GUI) and contains all the logic for building, flashing and monitoring the application. So when you press e.g. the *Build* button in *ESP-IDF Explorer* (don't worry, we'll explain what that means in the next lessons), the `idf.py build` command is called in the end.

The ESP-IDF VSCode plugin is a **wrapper/adapter** that makes ESP-IDF functionality available in VSCode. In other words, it connects VSCode and the ESP-IDF framework: it creates a GUI in the form of *ESP-IDF Explorer* and at the same time ensures that the buttons perform their function, the output of commands is correctly displayed in VSCode, that the framework configuration is correctly reflected and so on. However, it needs the framework that runs in the background to function.

{{< alert icon="circle-info">}}
The ESP-IDF framework itself can be used in other ways than just with the VSCode plugin. It has support for [Clion](https://developer.espressif.com/blog/clion/), [Eclipse](https://developer.espressif.com/blog/eclipse-plugin-for-esp-idf/), and last but not least, you can use it standalone, [directly from the command line](https://developer.espressif.com/blog/getting-started-with-esp-idf/).

However, in this workshop we will be using exclusively the **VSCode plugin**.
{{< /alert >}}


You should now have a working ESP-IDF plugin for VSCode and ESP-IDF set up. So we can start with the second part of the tutorial:

[Assignment 2: Create a new project with Components](../assignment-2)