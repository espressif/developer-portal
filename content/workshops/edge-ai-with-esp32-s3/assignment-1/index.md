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

The recommended way to install and manage ESP-IDF is through the **ESP-IDF Installation Manager (EIM)**, available in both a graphical and a command-line edition. You can [download EIM](https://dl.espressif.com/dl/eim/) from the official page.

Alternatevely, you can download directly from the terminal:

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
  {{< tab label="Windows Terminal" >}}

**CLI** — open Windows Terminal with a PowerShell or Command Prompt profile and run:

```powershell
winget install Espressif.EIM-CLI
```

`winget` works in both PowerShell and Command Prompt profiles.

**GUI** — download the Windows installer from the EIM download page and run the setup wizard:

[Download EIM for Windows](https://dl.espressif.com/dl/eim/)

  {{< /tab >}}
  {{< tab label="Windows (PowerShell)" >}}

**CLI** — install with winget:

```powershell
winget install Espressif.EIM-CLI
```

**GUI** — download the Windows installer from the EIM download page and run the setup wizard:

[Download EIM for Windows](https://dl.espressif.com/dl/eim/)

  {{< /tab >}}
  {{< tab label="Windows (cmd)" >}}

**CLI** — install with winget:

```cmd
winget install Espressif.EIM-CLI
```

**GUI** — download the Windows installer from the EIM download page and run the setup wizard:

[Download EIM for Windows](https://dl.espressif.com/dl/eim/)

  {{< /tab >}}
{{< /tabs >}}

Once EIM is installed, use it to install ESP-IDF. Run the following command to install the version required by ESP-WHO:

```bash
eim install v5.5.4
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
> ESP-WHO officially supports ESP-IDF **v5.4.x and v5.5.x**. ESP-IDF v6.x is not yet supported and will cause build errors due to component API changes. For this workshop, use **ESP-IDF v5.5.4**. Select `v5.5.4` when running `eim install`.

After installation, check which versions are available on your machine:

```bash
eim list
```

You should see output similar to:

```
Installed ESP-IDF versions:
  v5.5.4   ~/.espressif/frameworks/esp-idf-v5.5.4
```

If you have multiple versions installed, set the active one with:

```bash
eim select v5.5.4
```

This prints the activation command for your OS. Run it to make `idf.py` available in your terminal:

{{< tabs group="os" >}}
  {{< tab label="macOS / Linux" >}}

```bash
source ~/.espressif/tools/activate_idf_v5.5.4.sh
```

  {{< /tab >}}
  {{< tab label="Windows Terminal" >}}

If using the **PowerShell** profile (default):

```powershell
. $HOME\.espressif\tools\activate_idf_v5.5.4.ps1
```

If using the **Command Prompt** profile:

```cmd
%USERPROFILE%\.espressif\tools\activate_idf_v5.5.4.bat
```

  {{< /tab >}}
  {{< tab label="Windows (PowerShell)" >}}

```powershell
. $HOME\.espressif\tools\activate_idf_v5.5.4.ps1
```

  {{< /tab >}}
  {{< tab label="Windows (cmd)" >}}

```cmd
%USERPROFILE%\.espressif\tools\activate_idf_v5.5.4.bat
```

  {{< /tab >}}
{{< /tabs >}}

Once the environment is active, verify it in your terminal:

```bash
idf.py --version
```

You should see output similar to:

```
ESP-IDF v5.5.4
```

---

## Step 2: Clone ESP-WHO

Choose a suitable location for the ESP-WHO repository — for example, your home directory or a dedicated `~/esp/` workspace folder. **Do not clone it inside an existing project folder**, as ESP-WHO is a shared framework used across multiple projects in this workshop.

```bash
# Example: clone into ~/esp/
mkdir -p ~/esp && cd ~/esp
git clone --recursive https://github.com/espressif/esp-who.git
```

After cloning, check out the specific commit validated for this workshop:

```bash
cd esp-who
git checkout 1681a1ce7dd356dfa541138d4b25d2ae1395472f
git submodule update --init --recursive
```

This commit is the version of ESP-WHO that has been validated for the **ESP32-S3-EYE** with **ESP-IDF v5.5.4**. It includes the correct BSP configuration, component versions, and example code that match the instructions throughout this workshop.

> [!IMPORTANT]
> Always use this exact commit when following this workshop. Newer commits may introduce breaking changes that are not yet reflected in these instructions.

---

## Step 3: Set the ESP-WHO environment variable

ESP-WHO uses a custom `idf.py` action to simplify project configuration. You need to point the `IDF_EXTRA_ACTIONS_PATH` variable to the `tools/` folder inside your ESP-WHO clone.

{{< tabs group="os" >}}
  {{< tab label="Windows Terminal" >}}

Windows Terminal defaults to a PowerShell profile. Open a new tab with the PowerShell profile and run:

```powershell
$Env:IDF_EXTRA_ACTIONS_PATH = "C:\path\to\esp-who\tools"
echo $Env:IDF_EXTRA_ACTIONS_PATH
```

If you are using the Command Prompt profile instead, use:

```cmd
set IDF_EXTRA_ACTIONS_PATH=C:\path\to\esp-who\tools
echo %IDF_EXTRA_ACTIONS_PATH%
```

  {{< /tab >}}
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

The `-DSDKCONFIG_DEFAULTS` flag tells CMake which default configuration file to use when generating `sdkconfig`. ESP-WHO examples ship with one `sdkconfig.bsp.*` file per supported board, each containing the correct pin assignments, clock speeds, and peripheral settings for that specific hardware. By passing `sdkconfig.bsp.esp32_s3_eye`, you ensure the project is configured for the ESP32-S3-EYE without having to set each option manually through `menuconfig`. You will use this flag every time you configure a new ESP-WHO example.

Build the project:

```bash
idf.py build
```

If the build completes without errors, your environment is ready.

> [!TIP]
> You do not need to flash the firmware at this stage. We will do that in the later assignments when we go through each example in detail.

---

## Next step

You now have a working ESP-IDF and ESP-WHO setup. Time to run your first vision AI application.

[Assignment 2: ESP-WHO - Working with face detection](../assignment-2)
