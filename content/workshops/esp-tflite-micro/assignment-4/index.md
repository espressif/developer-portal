---
title: "ESP-TFLite-Micro workshop - Assignment 4: Deploy and test on-device inference"
date: 2026-09-07T00:00:00+01:00
lastmod: 2026-09-07
draft: true
showTableOfContents: true
series: ["WS004EN"]
series_order: 9
showAuthor: false
---

## Recap from Assignment 3

In the previous assignment, you converted `simple_1dcnn_model.h5` to TensorFlow Lite and verified its interface:

```text
Input:  float32 [1, 200, 3]
Output: float32 [1, 4]
```

You then converted `model.tflite` into `model.cpp` and replaced the model source in the gesture recognition application. The example's existing `model.h` already declares the required symbols:

```text {lineNos=true}
gesture_recognition/
└── main/
    ├── model.cpp
    └── include/
        └── model.h
```

The model now embedded in the ESP-IDF project recognizes the three original classes plus the movement collected in Assignment 1. The remaining task is to synchronize the application labels, build the firmware, and test inference on the ESP-SensairShuttle.

## What you will do

In this assignment, you will:

1. Add the new gesture name to the application label table.
2. Build and flash the updated firmware.
3. Test all four classes and record the results.

## Assignment steps

### Step 1: Update the class labels

Open `main/app_model.cpp` and find `kLabels`. Replace the complete array so its order matches the labels used during training:

```cpp {lineNos=true}
static const char *kLabels[] = {
    "Counterclockwise circle",
    "V",
    "Unknown",
    "YOUR_GESTURE",
};
```

Replace `YOUR_GESTURE` with the name of the movement collected in Assignment 1.

{{< alert icon="triangle-exclamation" >}}
The array order must match the training labels exactly: circle is `0`, V is `1`, unknown is `2`, and the new gesture is `3`. A different order displays the wrong name even when the model predicts the correct output index.
{{< /alert >}}

No other source changes are required for the fourth class:

- `app_model.cpp` reads the class count from `output->dims->data[1]`.
- `app_model_pipeline.cpp` handles class IDs without assuming a fixed count.
- The BMI270 configuration and `200 × 3` input pipeline remain unchanged.
- `model.cpp` was already replaced in Assignment 3; the existing `model.h` remains unchanged.

### Step 2: Build the application

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Select **File → Open Folder** and open the `gesture_recognition` project directory, not its `training` subdirectory.
2. Run `ESP-IDF: Build Your Project` from the Command Palette.
3. Follow the build output in VS Code.

  {{< /tab >}}
  {{< tab label="CLI" >}}

From the `gesture_recognition` project directory, build with the ESP-IDF v6.1 environment activated:

```bash
idf.py build
```

  {{< /tab >}}
{{< /tabs >}}

The first build may take longer while the Component Manager downloads dependencies.

If compilation reports an undefined model symbol, confirm:

- `main/model.cpp` defines `model_tflite` and `model_tflite_len`.
- `main/include/model.h` declares the same names and types.
- `main/CMakeLists.txt` includes the `main` source directory.

### Step 3: Flash and monitor

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Run `ESP-IDF: Select Port to Use` from the Command Palette and select the ESP-SensairShuttle.
2. Run `ESP-IDF: Build, Flash and Start a Monitor on Your Device`.
3. Select **UART** if prompted.
4. Use the trash-can icon in the VS Code Terminal panel to stop the monitor.

  {{< /tab >}}
  {{< tab label="CLI" >}}

Replace `<PORT>` with the serial port used earlier:

```bash
idf.py -p <PORT> flash monitor
```

Press `Ctrl+]` to exit the monitor.

  {{< /tab >}}
{{< /tabs >}}

Move the board using one of the trained gestures. Expected output resembles:

```text
I (...) Model Pipeline: Motion detected: Counterclockwise circle (confidence: 98.4%)
I (...) Model Pipeline: Motion detected: YOUR_GESTURE (confidence: 94.7%)
I (...) Model Pipeline: Motion detected: Unknown (confidence: 91.2%)
```

Class names, confidence values, and timestamps depend on your model and movement.

### Step 4: Validate physical gestures

Use the same grip and board orientation used during data collection. Perform at least **10 trials per class** and record every result, including incorrect classifications and rejected movements.

| Gesture | Trials | Correct | Incorrect | Rejected |
| --- | ---: | ---: | ---: | ---: |
| Counterclockwise circle | 10 | | | |
| V gesture | 10 | | | |
| Unknown movements | 10 | | | |
| New gesture | 10 | | | |

For this workshop, aim for at least **7 correct detections out of 10** for each intentional gesture. This is a workshop checkpoint, not a production-quality acceptance threshold.

If the new gesture performs poorly:

1. Confirm that `kLabels` uses the correct class order.
2. Repeat the movement with the training grip, orientation, speed, and amplitude.
3. Review the confusion matrix from Assignment 2.
4. Collect more varied samples and retrain.
5. Adjust the trigger or confidence threshold only after checking the dataset and model.

## Acceptance criteria

- The project builds successfully for ESP32-C5.
- Tensor allocation completes without errors.
- BMI270 data fills a `float32` input tensor with shape `(1, 200, 3)`.
- Inference returns four class scores.
- `kLabels` contains four names in training-label order.
- Serial output reports class names and confidence values.
- Physical tests include all four classes with at least 10 trials each.

## Going further

- Collect data from more participants and orientations.
- Compare `float32` and fully quantized models.
- Measure tensor arena usage and inference latency.
- Tune trigger and confidence thresholds using recorded results.
- Test the model with gestures performed by people not represented in the training dataset.

## Conclusion

You collected a new gesture, trained and converted a four-class model, embedded it in an ESP-IDF application, and ran inference locally on the ESP32-C5.

[Back to workshop home](/workshops/esp-tflite-micro/)
