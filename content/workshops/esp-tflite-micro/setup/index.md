---
title: "ESP-TFLite-Micro workshop - Install ESP-IDF"
date: 2026-09-07T00:00:00+01:00
lastmod: 2026-09-07
draft: true
showTableOfContents: true
series: ["WS004EN"]
series_order: 4
showAuthor: false
---

## Install ESP-IDF

{{< alert icon="circle-info" >}}
If ESP-IDF v6.1 is already installed and activated on your computer, you can skip the installation steps on this page. Run `idf.py --version` to confirm the active version before continuing.
{{< /alert >}}

Use the **ESP-IDF Installation Manager (EIM)** to install and manage ESP-IDF. EIM is available as a command-line tool and a desktop application from the [EIM download page](https://dl.espressif.com/dl/eim/).

### Graphical setup with VS Code

If you are not familiar with command-line tools, use the official [ESP-IDF extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=espressif.esp-idf-extension):

1. Install [Visual Studio Code](https://code.visualstudio.com/download).
2. Open **Extensions** from the Activity Bar.
3. Search for **ESP-IDF**, select the extension published by Espressif Systems, and click **Install**.
4. Open the Command Palette with **View → Command Palette**.
5. Run `ESP-IDF: Open ESP-IDF Installation Manager`.
6. Follow the graphical installer and select ESP-IDF v6.1.
7. When installation finishes, let the extension use the newly installed ESP-IDF tools.

Commands written as `ESP-IDF: ...` in this workshop are VS Code commands. Open the Command Palette, type the command name, and select it; you do not need to type them in a terminal.

To inspect the configured environment, run `ESP-IDF: Doctor Command` from the Command Palette and confirm that it reports ESP-IDF v6.1. After completing this graphical setup, skip the terminal installation commands below and continue to the [gesture recognition example](../gesture-example/).

### Command-line setup

You can also install EIM from a terminal:

{{< tabs group="os" >}}
  {{< tab label="macOS" >}}

**CLI** — install with Homebrew:

```bash
brew tap espressif/eim
brew install eim
```

**GUI** — install the desktop application with Homebrew:

```bash
brew tap espressif/eim
brew install --cask eim-gui
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

**CLI** — install through the Espressif APT repository:

```bash
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | sudo tee /etc/apt/sources.list.d/espressif.list
sudo apt update
sudo apt install eim-cli
```

**GUI** — install the full package, which includes the CLI:

```bash
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | sudo tee /etc/apt/sources.list.d/espressif.list
sudo apt update
sudo apt install eim
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

**CLI** — open Windows Terminal with a PowerShell or Command Prompt profile and run:

```powershell
winget install Espressif.EIM-CLI
```

**GUI** — download the Windows installer and run the setup wizard:

[Download EIM for Windows](https://dl.espressif.com/dl/eim/)

  {{< /tab >}}
{{< /tabs >}}

Install the ESP-IDF version used in this workshop:

```bash
eim install v6.1
```

For a guided setup, run:

```bash
eim wizard
```

For a detailed walkthrough, see the [ESP-IDF Preliminary Setup Workshop](https://developer.espressif.com/workshops/esp-idf-setup/).

Check the installed versions:

```bash
eim list
```

If more than one version is installed, select ESP-IDF v6.1:

```bash
eim select v6.1
```

Run the activation command printed by EIM. For the default installation path, use:

{{< tabs group="os" >}}
  {{< tab label="macOS" >}}

```bash
source ~/.espressif/tools/activate_idf_v6.1.sh
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

```bash
source ~/.espressif/tools/activate_idf_v6.1.sh
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

PowerShell:

```powershell
. $HOME\.espressif\tools\activate_idf_v6.1.ps1
```

Command Prompt:

```cmd
%USERPROFILE%\.espressif\tools\activate_idf_v6.1.bat
```

  {{< /tab >}}
{{< /tabs >}}

Verify the active version:

```bash
idf.py --version
```

The command should report ESP-IDF v6.1.

## Next step

[Download and flash the gesture recognition example](../gesture-example/)

[Back to workshop home](/workshops/esp-tflite-micro/)
