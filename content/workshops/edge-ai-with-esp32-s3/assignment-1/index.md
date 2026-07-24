---
title: "Edge-AI with ESP32-S3 Workshop: Assignment 1"
date: 2026-07-07
showTableOfContents: true
series: ["EAIVEN"]
series_order: 2
showAuthor: false
---

## Assignment 1: Install ESP-IDF and ESP-WHO

In this assignment you will set up everything you need to build and flash ESP-WHO applications on the ESP32-S3-EYE. By the end, you will have ESP-IDF installed and managed with EIM, and the ESP-WHO repository cloned and ready to use.

---

## Step 1: Install ESP-IDF

If you have not installed ESP-IDF yet, follow the dedicated setup workshop first. It covers installing VS Code, the ESP-IDF extension, and the ESP-IDF toolchain using EIM step by step:

[ESP-IDF Preliminary Setup Workshop](https://developer.espressif.com/workshops/esp-idf-setup/)

You can install ESP-IDF either through the **EIM CLI** (as described in the setup workshop) or directly from within **VS Code** using the ESP-IDF extension. Both methods use EIM under the hood. To install from VS Code, open the Command Palette (`F1` or `Ctrl+Shift+P`), type `Configure ESP-IDF Extension`, and follow the on-screen steps.

> [!IMPORTANT]
> ESP-WHO requires **ESP-IDF v5.5.x**. When EIM asks you to select a version, choose `v5.5.3` or the latest available `v5.5.x` release.

Once you are done, come back here and verify that ESP-IDF is active in your terminal:

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
