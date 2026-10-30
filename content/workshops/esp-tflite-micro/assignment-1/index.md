---
title: "ESP-TFLite-Micro workshop - Assignment 1: Collect and prepare gesture data"
date: 2026-09-07T00:00:00+01:00
lastmod: 2026-09-07
draft: true
showTableOfContents: true
series: ["WS004EN"]
series_order: 6
showAuthor: false
---

## Assignment steps

In this assignment, you will define a gesture, record repeated BMI270 gyroscope samples, and save them as a CSV dataset. Each captured sample contains 200 readings from the x, y, and z axes, for a total of 600 values.

### Get the training scripts

The [workshop gesture recognition project](https://github.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-tflite-micro/gesture_recognition) already includes the training workspace. To refresh it with the latest capture, validation, training, conversion, and embedding scripts, download the [training script bundle](https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/training.zip) and extract it from the `gesture_recognition` project directory:

{{< tabs group="os" >}}
  {{< tab label="macOS and Linux" >}}

```bash {lineNos=true}
curl -fL \
  https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/training.zip \
  -o training.zip
unzip -o training.zip
rm training.zip
```

  {{< /tab >}}
  {{< tab label="Windows PowerShell" >}}

```powershell {lineNos=true}
Invoke-WebRequest `
  -Uri "https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/training.zip" `
  -OutFile "training.zip"
Expand-Archive -Path "training.zip" -DestinationPath "." -Force
Remove-Item "training.zip"
```

  {{< /tab >}}
{{< /tabs >}}

**Graphical alternative:** Download the ZIP archive in a browser and extract its `training` folder into the `gesture_recognition` project directory. Confirm replacement if your archive manager asks whether to overwrite scripts already supplied by the code repository.

### Step 1: Create the dataset folder

From the `gesture_recognition` project directory, create the folder that will contain the original datasets and your newly collected gesture:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Open the `gesture_recognition` project in VS Code.
2. In the Explorer, create a folder named `training`.
3. Create `shuttle_dataset` inside `training`.

  {{< /tab >}}
  {{< tab label="macOS" >}}

```bash
mkdir -p training/shuttle_dataset
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

```bash
mkdir -p training/shuttle_dataset
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

PowerShell:

```powershell
New-Item -ItemType Directory -Force training\shuttle_dataset
```

  {{< /tab >}}
{{< /tabs >}}

The resulting path is:

```text
gesture_recognition/training/shuttle_dataset/
```

You will save the CSV collected in this assignment in this folder. Assignment 2 will add the three original gesture datasets alongside it.

### Step 2: Enter data collection mode

Keep the serial monitor open after flashing the gesture recognition example. The application starts in automatic inference mode.

Try a V and a counterclockwise circle before changing mode. Each detected movement should print a class name, such as `V` or `Counterclockwise circle`, and a confidence value. Reference output:

```text
I (...) Model Pipeline: Motion detected: V (confidence: 99.7%)
I (...) Model Pipeline: Motion detected: Counterclockwise circle (confidence: 87.6%)
```

Timestamps and confidence values vary between runs. Other movements are often classified as `Unknown`.

Press and hold the **Boot** button for at least two seconds, then release it. The monitor should confirm the mode change:

```text
I (...) APP_BTN: Mode switched to COLLECT
```

Long-press and release Boot again whenever you want to return to automatic inference mode.

### Step 3: Define a new gesture

Choose a movement that you can repeat consistently. Give it a short, descriptive name, such as `clockwise_circle`, `horizontal_line`, or `letter_s`.

Keep the new gesture distinct from the counterclockwise circle (`o`) and the V (`v`) already in the example. Avoid a similar shape, and avoid a path that contains either of them. With the same grip, an M includes the motion of a V, so those samples also contain the data that identifies V.

Before collecting data, decide:

- How you will hold the board
- The starting and ending positions
- The direction and size of the movement
- Which hand you will use
- How quickly you will perform it

{{< alert icon="triangle-exclamation" >}}
**Keep the board orientation consistent.** The BMI270 measures motion along axes fixed to the board. Holding the board from another side, rotating it, or turning it over changes which axes receive the motion and may reverse their signs. The same hand gesture can therefore produce substantially different data.

Choose one grip and orientation for the full dataset, and use the same setup when testing the trained model. If the application must work with several orientations, collect and label enough examples in every supported orientation.
{{< /alert >}}

Try to complete the gesture within approximately one second. The application records 200 samples at 200 Hz, so each row represents one second of motion.

### Step 4: Capture one sample

1. Briefly press and release the **Boot** button.
2. Immediately perform the gesture.
3. Wait for the movement to exceed the configured gyroscope threshold.
4. Keep the board still after finishing until the values appear in the serial monitor.

When the application detects enough motion, it prints:

```text {lineNos=true}
I (...) Model Pipeline: Trigger met (...), collecting 200 samples (include trigger sample)

=== Data Collection Results ===
12.34567,-8.90123,4.56789,...,1.23456,-2.34567,3.45678
=== End of Data Collection ===
```

The line between the two markers contains exactly **600 comma-separated floating-point values**, ordered as:

```text
x0,y0,z0,x1,y1,z1,...,x199,y199,z199
```

If the trigger is not reached, the monitor prints `Trigger not met`. Press Boot and try the movement again with a clearer or faster motion.

### Step 5: Repeat the gesture

Capture the same gesture at least **25 times**. Twenty-five samples are not enough for a production-quality model, but they are sufficient to complete this workshop and observe the full training workflow.

Use a similar starting position and overall shape each time, but allow small natural variations in speed, angle, and amplitude. If the gesture is complex or the repetitions vary significantly, collect more samples.

Discard a capture and repeat it when:

- You started too late or stopped before completing the gesture
- The board hit an object or slipped in your hand
- The output contains an incomplete row
- You accidentally performed a different movement

Copying 25 lines of 600 numbers from the serial monitor is easy to get wrong. You can optionally let a script copy each valid line into `training/shuttle_dataset/new_gesture.csv`. You still perform the gesture 25 times. Step 6 explains how to paste the lines yourself if you do not use the script.

The code repository and training bundle provide `training/capture_gesture.py`. Its implementation is shown below for reference:

```python {lineNos=true}
import argparse
import re
import sys
from pathlib import Path

import serial
from serial.tools import list_ports

START = "=== Data Collection Results ==="
END = "=== End of Data Collection ==="
ANSI = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")
ESPRESSIF_VID = 0x303A


def board_ports():
    skipped = ("bluetooth", "debug-console")
    candidates = []
    for info in list_ports.comports():
        device = info.device or ""
        label = f"{device} {info.description or ''}".lower()
        if any(word in label for word in skipped):
            continue
        candidates.append(info)

    espressif = [info.device for info in candidates if info.vid == ESPRESSIF_VID]
    if espressif:
        return espressif

    usb_marks = ("usbmodem", "usbserial", "ttyACM", "ttyUSB", "COM", "wchusb", "SLAB")
    return [info.device for info in candidates if any(mark in info.device for mark in usb_marks)]


def open_board():
    names = board_ports()
    if not names:
        print("No board serial port found.", file=sys.stderr)
        return None
    for name in names:
        try:
            port = serial.Serial(name, 115200, timeout=0.2)
        except serial.SerialException as exc:
            print(f"Skipping {name}: {exc}")
            continue
        print(f"Using {name}")
        return port
    print("Could not open a board serial port.", file=sys.stderr)
    return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--count", type=int, default=25)
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=Path("shuttle_dataset/new_gesture.csv"),
    )
    args = parser.parse_args()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    capturing = False
    pending = ""

    print("Long-press Boot for about 2 seconds, then release.")
    print("Short-press Boot and perform the gesture once for each sample.")
    print(f"Need {args.count} rows. Press Ctrl+C to stop early.")

    port = open_board()
    if port is None:
        return 1

    try:
        while len(rows) < args.count:
            chunk = port.read(4096)
            if not chunk:
                continue
            pending += ANSI.sub("", chunk.decode("utf-8", "replace"))
            while "\n" in pending:
                line, pending = pending.split("\n", 1)
                line = line.strip()
                if "Mode switched to" in line:
                    print(line)
                if START in line:
                    capturing = True
                    continue
                if END in line:
                    capturing = False
                    continue
                if not capturing or "," not in line:
                    continue
                values = [item for item in line.split(",") if item]
                if len(values) != 600:
                    print(f"Skipped a row with {len(values)} numbers.")
                    continue
                rows.append(",".join(values))
                print(f"Saved {len(rows)}/{args.count}")
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        port.close()

    text = "\n".join(rows)
    if text:
        text += "\n"
    args.output.write_text(text)
    print(f"Wrote {len(rows)} rows to {args.output}")
    return 0 if len(rows) >= args.count else 2


if __name__ == "__main__":
    raise SystemExit(main())
```

Exit the serial monitor with `Ctrl+]` before you start the script. Only one program can use the board's serial port. Install `pyserial`, then run the script from the `training` directory. It scans the serial ports on the computer and prints the one it uses. You do not pass a port name.

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Install the Microsoft **Python** extension if it is not already installed.
2. Open `training/capture_gesture.py`.
3. Open a new terminal with **Terminal → New Terminal** and run:

```bash
cd training
python -m pip install pyserial
python capture_gesture.py
```

  {{< /tab >}}
  {{< tab label="macOS" >}}

```bash
cd training
python3 -m pip install pyserial
python3 capture_gesture.py
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

```bash
cd training
python3 -m pip install pyserial
python3 capture_gesture.py
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

PowerShell, from the `gesture_recognition` directory:

```powershell
Set-Location training
py -3 -m pip install pyserial
py -3 capture_gesture.py
```

  {{< /tab >}}
{{< /tabs >}}

While the script is running:

1. Press and hold **Boot** for about two seconds, then release it. The terminal prints `Mode switched to COLLECT` when the board changes mode.
2. Briefly press **Boot** and perform the gesture immediately.
3. Wait until the terminal prints `Saved 1/25`. Repeat until it prints `Saved 25/25`.

The script writes only lines that contain 600 values. It skips log lines, marker lines, and incomplete rows. Press `Ctrl+C` to stop early and keep the rows already saved. When it finishes, the CSV file already exists, so skip the manual copy in Step 6 and continue with Step 7.

### Step 6: Create the CSV file

Inside `training/shuttle_dataset`, create a file named `new_gesture.csv`. This is the filename used by the training script in Assignment 2:

```text
gesture_recognition/training/shuttle_dataset/new_gesture.csv
```

Skip this step if `capture_gesture.py` already created the file.

For each valid capture:

1. Copy only the line between `=== Data Collection Results ===` and `=== End of Data Collection ===`.
2. Paste it into the CSV file as a new row.
3. Do not copy timestamps, log messages, marker lines, or a column header.

After 25 captures, the file should contain at least 25 rows. Every row represents one gesture and must contain exactly 600 values.

### Step 7 (optional): Validate and save the dataset

This validation is optional but recommended. The code repository and training bundle provide `training/shuttle_dataset/validate_dataset.py`; its implementation is shown below for reference:

```python {lineNos=true}
import pandas as pd

data = pd.read_csv("new_gesture.csv", header=None)

print("Samples:", data.shape[0])
print("Values per sample:", data.shape[1])

assert data.shape[0] >= 25
assert data.shape[1] == 600
assert not data.isnull().any().any()
```

Run the script:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Install the Microsoft **Python** extension.
2. Open `validate_dataset.py`.
3. Select a Python interpreter that has `pandas` installed.
4. Click **Run Python File** (the triangular play button) in the editor toolbar.

The output appears in the VS Code Terminal panel.

  {{< /tab >}}
  {{< tab label="CLI" >}}

```bash
python validate_dataset.py
```

  {{< /tab >}}
{{< /tabs >}}

**Spreadsheet alternative:** Open the CSV in LibreOffice Calc, Microsoft Excel, or another spreadsheet application. Confirm that it contains at least 25 rows, exactly 600 populated columns, and no empty cells. Do not save it in a format that adds a header or changes the comma-separated numeric values.

Expected result:

```text
Samples: 25
Values per sample: 600
```

Save the validated CSV file. Repeat this collection process for every gesture class used by your model. A three-class classifier also needs an **unknown** class containing varied movements that do not match either defined gesture. Keep the class sizes reasonably balanced.

## Acceptance criteria

- The serial monitor confirms that the application is in `COLLECT` mode.
- The new gesture has a clear name and can be repeated consistently.
- `training/shuttle_dataset/new_gesture.csv` contains at least 25 valid samples.
- Each CSV row contains exactly 600 floating-point values with no header.
- The dataset contains no empty or incomplete values.
- Separate, reasonably balanced CSV files exist for every model class.

## Next step

[Assignment 2: Train and evaluate the model](../assignment-2/)

[Back to workshop home](/workshops/esp-tflite-micro/)
