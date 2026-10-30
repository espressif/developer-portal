---
title: "ESP-TFLite-Micro workshop - Download and flash the gesture recognition example"
date: 2026-09-07T00:00:00+01:00
lastmod: 2026-09-07
draft: true
showTableOfContents: true
series: ["WS004EN"]
series_order: 5
showAuthor: false
---

## About the example

The [workshop gesture recognition project](https://github.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-tflite-micro/gesture_recognition) demonstrates an end-to-end embedded machine-learning application on the ESP32-C5. It reads three-axis angular velocity from the BMI270 gyroscope and runs a TensorFlow Lite Micro model locally, without sending sensor data to a cloud service. The project is based on the upstream [ESP-SensairShuttle gesture recognition example](https://github.com/espressif/esp-dev-kits/tree/master/examples/esp-sensairshuttle/examples/gesture_recognition) and contains the files used in this workshop.

The included model recognizes three classes:

- Counterclockwise circle
- V gesture
- Unknown movement

The application waits until the combined motion on the three gyroscope axes exceeds a configurable threshold. It then collects 200 samples from each axis and either prints the data for training or passes the resulting `200 × 3` tensor to the model.

The **Boot** button switches between two operating modes:

- **Automatic inference mode** — the default mode. Motion above the threshold starts inference, and the predicted class and confidence are printed to the serial monitor.
- **Data collection mode** — press Boot before performing a gesture. The application prints the captured gyroscope values so they can be added to a training dataset.

On this page, you will download, build, flash, and verify the supplied application. The following assignments use the same example to collect a new dataset, train and convert a model, and deploy it back to the ESP32-C5.

## Download the gesture recognition example

Choose either Git or a ZIP archive to download the source code.

### Option 1: Clone with Git

Clone the workshop code repository:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Open the Command Palette and run `Git: Clone`.
2. Paste `https://github.com/espressif/developer-portal-codebase.git`.
3. Select a destination folder.

VS Code can open the downloaded repository when cloning finishes.

  {{< /tab >}}
  {{< tab label="CLI" >}}

```bash
git clone --depth 1 https://github.com/espressif/developer-portal-codebase.git
cd developer-portal-codebase
```

  {{< /tab >}}
{{< /tabs >}}

### Option 2: Download the ZIP archive

Download the workshop codebase from GitHub:

[Download developer-portal-codebase (ZIP)](https://github.com/espressif/developer-portal-codebase/archive/refs/heads/main.zip)

Extract `developer-portal-codebase-main.zip`, open a terminal, and enter the extracted directory:

```bash
cd /path/to/developer-portal-codebase-main
```

**Graphical alternative:** Extract the archive with Finder, File Explorer, or your desktop archive manager. You do not need to open a terminal; continue with the VS Code instructions in the next step.

## 1. Enter the example directory

From the repository root, enter the gesture recognition project:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

Select **File → Open Folder** and open:

```text
developer-portal-codebase/content/workshops/esp-tflite-micro/gesture_recognition
```

  {{< /tab >}}
  {{< tab label="CLI" >}}

```bash
cd content/workshops/esp-tflite-micro/gesture_recognition
```

  {{< /tab >}}
{{< /tabs >}}

For a ZIP download, the first directory is named `developer-portal-codebase-main`.

## 2. Activate ESP-IDF

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

When the project folder is open, the ESP-IDF extension uses its configured environment automatically.

1. Run `ESP-IDF: Doctor Command` from the Command Palette.
2. Confirm that the report identifies ESP-IDF v6.1.

  {{< /tab >}}
  {{< tab label="CLI" >}}

Open a terminal with the ESP-IDF v6.1 environment activated. If you completed the previous page in another terminal, run the activation command printed by EIM again.

Verify the active version:

```bash
idf.py --version
```

The command should report ESP-IDF v6.1.

  {{< /tab >}}
{{< /tabs >}}

## 3. Connect the hardware

1. Install the BMI270 and BMM350 daughterboard in the Shuttle Board connector.
2. Confirm that the shuttle-board voltage jumper is set to **3.3 V**.
3. Connect the ESP-SensairShuttle to your computer through its USB-C port using a data-capable cable.

The LCD and BME690 daughterboard are not required.

## 4. Set the target and build

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Open the Command Palette and run `ESP-IDF: Set Espressif Device Target`.
2. Select `esp32c5`.
3. Run `ESP-IDF: Build Your Project`.
4. Follow the build output in VS Code until it reports a successful build.

  {{< /tab >}}
  {{< tab label="CLI" >}}

```bash
idf.py set-target esp32c5
idf.py build
```

A successful build ends with instructions for flashing the application.

  {{< /tab >}}
{{< /tabs >}}

## 5. Find the serial port

Identify the board's serial port:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Run `ESP-IDF: Select Port to Use` from the Command Palette.
2. Select the port that appears when the ESP-SensairShuttle is connected.

The selected port is displayed in the VS Code status bar.

  {{< /tab >}}
  {{< tab label="macOS" >}}

```bash
ls /dev/cu.*
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

```bash
ls /dev/ttyUSB* /dev/ttyACM*
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

Open **Device Manager**, expand **Ports (COM & LPT)**, and note the board's `COM` port.

  {{< /tab >}}
{{< /tabs >}}

## 6. Flash and monitor

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Run `ESP-IDF: Build, Flash and Start a Monitor on Your Device` from the Command Palette.
2. Select **UART** if prompted.
3. Use the trash-can icon in the VS Code Terminal panel to stop the monitor.

This command uses the target and serial port selected in the previous steps.

  {{< /tab >}}
  {{< tab label="CLI" >}}

Replace `<PORT>` with the serial port detected above:

```bash
idf.py -p <PORT> flash monitor
```

Press `Ctrl+]` to exit the serial monitor.

  {{< /tab >}}
{{< /tabs >}}

If flashing does not start automatically, hold the **Boot** button, briefly press **Reset**, and release **Boot** when the download begins.

## 7. Check the gesture recognition application

The example starts in **automatic inference mode**. Move the board in a counterclockwise circle or V shape and check the monitor for the predicted class and confidence.

Expected output:

```text
I (9992) Model Pipeline: Motion detected: Counterclockwise circle (confidence: 100.0%)
I (11719) Model Pipeline: Motion detected: Unknown (confidence: 95.0%)
I (13232) Model Pipeline: Motion detected: V (confidence: 99.9%)
```

Timestamps and confidence values vary between runs. Ordinary movements should usually be classified as `Unknown`.

Long-press and release the **Boot** button to switch modes:

- **Collection mode:** Press Boot, then perform the gesture immediately. Collection begins when the sum of the absolute three-axis gyroscope values exceeds the configured trigger threshold. The application prints the sampled values.
- **Automatic inference mode:** No button press is required. Motion above the trigger threshold runs inference automatically.

## Next step

[Assignment 1: Collect and prepare gesture data](../assignment-1/)

[Back to workshop home](/workshops/esp-tflite-micro/)
