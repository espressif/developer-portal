---
title: "Edge-AI with ESP32-S3 Workshop: Assignment 1"
date: 2026-07-07
showTableOfContents: true
series: ["EDGEAI-VISION"]
series_order: 2
showAuthor: false
---

## Assignment 1: Install ESP-IDF and ESP-WHO

In this assignment you will set up everything you need to build and flash ESP-WHO applications on the ESP32-S3-EYE. By the end, you will have ESP-IDF installed and managed with EIM, and the ESP-WHO repository cloned and ready to use.

---

## Step 1: Install ESP-IDF

The recommended way to install and manage ESP-IDF is through the **ESP-IDF Installation Manager (EIM)**, available in both a graphical and a command-line edition. Download either from the official page:

**[dl.espressif.com/dl/eim/](https://dl.espressif.com/dl/eim/)**

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

**CLI** — install via the Espressif APT repository:

```bash
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | sudo tee /etc/apt/sources.list.d/espressif.list
sudo apt update
sudo apt install eim-cli
```

**GUI** — install the full package (includes the CLI):

```bash
echo "deb [trusted=yes] https://dl.espressif.com/dl/eim/apt/ stable main" | sudo tee /etc/apt/sources.list.d/espressif.list
sudo apt update
sudo apt install eim
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

**CLI** — install with winget:

```powershell
winget install Espressif.EIM-CLI
```

**GUI** — download the Windows installer from the EIM download page and run the setup wizard:

[Download EIM for Windows](https://dl.espressif.com/dl/eim/)

  {{< /tab >}}
{{< /tabs >}}

Once EIM is installed, use it to install ESP-IDF. Run the following command to install the version required by ESP-WHO:

```bash
eim install v5.5.3
```

Alternatively, if you prefer a guided setup, use the interactive wizard:

```bash
eim wizard
```

> [!NOTE]
> You can also install ESP-IDF directly from within **VS Code** using the ESP-IDF extension. Open the Command Palette (`F1` or `Ctrl+Shift+P`), type `Configure ESP-IDF Extension`, and follow the on-screen steps. The extension uses EIM under the hood.

For a full step-by-step walkthrough of the installation process, refer to the dedicated setup workshop:

[ESP-IDF Preliminary Setup Workshop](https://developer.espressif.com/workshops/esp-idf-setup/)

> [!IMPORTANT]
> ESP-WHO requires **ESP-IDF v5.5.x**. When EIM asks you to select a version, choose `v5.5.3` or the latest available `v5.5.x` release.

Once you are done, verify that ESP-IDF is active in your terminal:

```bash
idf.py --version
```

You should see output similar to:

```
ESP-IDF v5.5.3
```

---

## Step 2: Clone ESP-WHO

Clone the ESP-WHO repository from GitHub:

```bash
git clone --recursive https://github.com/espressif/esp-who.git
```

> [!NOTE]
> The `--recursive` flag is required to also clone the ESP-WHO submodules. If you already cloned without it, run `git submodule update --init --recursive` inside the repository folder.

---

## Step 3: Set the ESP-WHO environment variable

ESP-WHO uses a custom `idf.py` action to simplify project configuration. You need to point the `IDF_EXTRA_ACTIONS_PATH` variable to the `tools/` folder inside your ESP-WHO clone.

{{< tabs group="os" >}}
  {{< tab label="Windows (PowerShell)" >}}

```powershell
$Env:IDF_EXTRA_ACTIONS_PATH = "C:\path\to\esp-who\tools"
echo $Env:IDF_EXTRA_ACTIONS_PATH
```

  {{< /tab >}}
  {{< tab label="Windows (cmd)" >}}

```cmd
set IDF_EXTRA_ACTIONS_PATH=C:\path\to\esp-who\tools
echo %IDF_EXTRA_ACTIONS_PATH%
```

  {{< /tab >}}
  {{< tab label="macOS / Linux" >}}

```bash
export IDF_EXTRA_ACTIONS_PATH=/path/to/esp-who/tools
echo $IDF_EXTRA_ACTIONS_PATH
```

  {{< /tab >}}
{{< /tabs >}}

> [!IMPORTANT]
> Make sure the `echo` command returns the correct path before continuing. If it is empty, the project configuration step in later assignments will fail.

---

## Step 4: Verify the setup

Let's do a quick build check using one of the ESP-WHO examples to confirm everything is wired up correctly. Navigate to the face recognition example:

```bash
cd esp-who/examples/human_face_recognition
```

Configure the project for the ESP32-S3-EYE board:

```bash
idf.py -DSDKCONFIG_DEFAULTS=sdkconfig.bsp.esp32_s3_eye set-target esp32s3
```

Build the project:

```bash
idf.py build
```

If the build completes without errors, your environment is ready.

> [!TIP]
> You do not need to flash the firmware at this stage. We will do that in the later assignments when we go through each example in detail.

---

## Next step

You now have a working ESP-IDF and ESP-WHO setup. Time to learn about the camera sensor on the ESP32-S3-EYE before we run our first vision application.

[Assignment 2: Camera sensor introduction](../assignment-2)
