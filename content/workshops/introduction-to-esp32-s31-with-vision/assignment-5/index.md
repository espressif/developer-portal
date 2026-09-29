---
title: "Introduction to the ESP32-S31 with Vision: Assignment 5"
date: 2026-09-28
showTableOfContents: true
series: ["ESP32-S31-VISION"]
series_order: 7
showAuthor: false
---

## Assignment 5: Your first camera application

In this assignment, you will create two ESP-Vision camera applications. The first continuously sends camera frames to the IDE preview. The second displays the live camera image on the ESP32-S31-Korvo-1 LCD.

> [!TIP]
> You can complete this assignment with either the [ESP-Vision Web IDE](https://vision.espressif.com/en) or the ESP-Vision extension for [Visual Studio Code](https://code.visualstudio.com/).

## How the script works

The application uses the `sensor` module:

| API | Purpose |
|-----|---------|
| `sensor.reset()` | Initializes the board camera |
| `sensor.set_pixformat(sensor.RGB565)` | Selects the 16-bit color format |
| `sensor.set_framesize(...)` | Selects the frame resolution |
| `sensor.skip_frames(...)` | Allows exposure and white balance to settle |
| `sensor.snapshot()` | Captures one frame from the live camera |
| `frame.flush()` | Sends the frame to the IDE preview |
| `display.Display()` | Initializes the board LCD |
| `lcd.write(frame)` | Writes the frame to the LCD |
| `lcd.deinit()` | Releases the LCD |
| `sensor.shutdown()` | Stops the camera stream during cleanup |

Both applications use QVGA (320 × 240), which provides a responsive preview while keeping memory requirements moderate.

## Step 1: Stream the camera to the IDE preview

Create `camera_preview.py`:

```python
# SPDX-FileCopyrightText: 2026 Espressif Systems (Shanghai) CO LTD
# SPDX-License-Identifier: Apache-2.0

import sensor
import time


# Initialize the board camera.
sensor.reset()
# Capture frames in 16-bit RGB color at 320 x 240.
sensor.set_pixformat(sensor.RGB565)
sensor.set_framesize(sensor.QVGA)
# Let automatic exposure and white balance settle.
sensor.skip_frames(time=1000)

while True:
    # Capture a frame and send it to the connected IDE preview.
    img = sensor.snapshot()
    img.flush()
    # Yield briefly to keep the IDE responsive.
    time.sleep_ms(20)
```

This is the ESP-Vision `helloworld.py` example. `img.flush()` sends every captured frame to the connected IDE preview. The 20 ms delay yields between frames and keeps the development interface responsive.

## Step 2: Open the IDE preview

{{< tabs group="esp-vision-ide" >}}
  {{< tab label="Web IDE" >}}

1. Connect the Web IDE to the ESP32-S31-Korvo-1.
2. Create `camera_preview.py`.
3. Paste the script and save it to the device.
4. Select **Run**.
5. Open the camera preview in the Web IDE.
6. Confirm that the live camera image appears.
7. Stop the script before continuing.

  {{< /tab >}}
  {{< tab label="Visual Studio Code" >}}

1. Connect with **ESP-VISION: Connect**.
2. Create and open `camera_preview.py`.
3. Paste and save the script.
4. Run **ESP-VISION: Run Current File**.
5. Run **ESP-VISION: Show Preview**.
6. Confirm that the live camera image appears.
7. Run **ESP-VISION: Stop Script** before continuing.

  {{< /tab >}}
{{< /tabs >}}

## Step 3: Show the camera on the LCD

Create a second file named `lcd_preview.py`. This application initializes the LCD and continuously writes camera frames to it:

```python
import display
import sensor
import time


def main():
    # Initialize the board LCD.
    lcd = display.Display()
    try:
        # Initialize and configure the camera for 320 x 240 RGB frames.
        sensor.reset()
        sensor.set_pixformat(sensor.RGB565)
        sensor.set_framesize(sensor.QVGA)
        # Let automatic exposure and white balance settle.
        sensor.skip_frames(time=1000)
        print("LCD_PREVIEW:READY")

        while True:
            # Capture a frame and draw it on the LCD.
            frame = sensor.snapshot()
            lcd.write(frame)
            # Yield briefly between frames.
            time.sleep_ms(20)
    finally:
        # Release both peripherals when the script stops or fails.
        sensor.shutdown()
        lcd.deinit()


main()
```

Run `lcd_preview.py`. The live camera image appears on the board's LCD instead of the IDE preview. Stop the script to verify that both the camera and LCD are released cleanly.

## Complete working examples

<details><summary>Show the complete camera_preview.py for the IDE preview</summary>

```python
# SPDX-FileCopyrightText: 2026 Espressif Systems (Shanghai) CO LTD
# SPDX-License-Identifier: Apache-2.0

import sensor
import time


# Initialize the board camera.
sensor.reset()
# Capture frames in 16-bit RGB color at 320 x 240.
sensor.set_pixformat(sensor.RGB565)
sensor.set_framesize(sensor.QVGA)
# Let automatic exposure and white balance settle.
sensor.skip_frames(time=1000)

while True:
    # Capture a frame and send it to the connected IDE preview.
    img = sensor.snapshot()
    img.flush()
    # Yield briefly to keep the IDE responsive.
    time.sleep_ms(20)
```

</details>

<details><summary>Show the complete lcd_preview.py for the LCD</summary>

```python
import display
import sensor
import time


def main():
    # Initialize the board LCD.
    lcd = display.Display()
    try:
        # Initialize and configure the camera for 320 x 240 RGB frames.
        sensor.reset()
        sensor.set_pixformat(sensor.RGB565)
        sensor.set_framesize(sensor.QVGA)
        # Let automatic exposure and white balance settle.
        sensor.skip_frames(time=1000)
        print("LCD_PREVIEW:READY")

        while True:
            # Capture a frame and draw it on the LCD.
            frame = sensor.snapshot()
            lcd.write(frame)
            # Yield briefly between frames.
            time.sleep_ms(20)
    finally:
        # Release both peripherals when the script stops or fails.
        sensor.shutdown()
        lcd.deinit()


main()
```

</details>

## What you will see

- The first application shows a live 320 × 240 camera image in the IDE preview.
- In the second stage, the board LCD shows the live camera image and the output reports `LCD_PREVIEW:READY`.

## What you learned

In this assignment, you:

- Initialized the board camera with the ESP-Vision `sensor` module
- Selected a pixel format and frame size
- Streamed live camera frames to the IDE with `img.flush()`
- Created a separate live LCD application with `lcd.write(frame)`
- Released camera and display resources during cleanup
- Used the Web IDE or Visual Studio Code for the same development workflow

## Next step

[Lecture 2: Available models for ESP-Vision](../lecture-2)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-with-vision/)
