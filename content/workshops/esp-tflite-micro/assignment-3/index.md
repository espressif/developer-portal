---
title: "ESP-TFLite-Micro workshop - Assignment 3: Convert and embed the model"
date: 2026-09-07T00:00:00+01:00
lastmod: 2026-09-07
draft: true
showTableOfContents: true
series: ["WS004EN"]
series_order: 8
showAuthor: false
---

## Recap from Assignment 2

In the previous assignment, you trained a 1D convolutional neural network with four classes:

| Output index | Class |
| ---: | --- |
| `0` | Counterclockwise circle |
| `1` | V gesture |
| `2` | Unknown movement |
| `3` | New gesture collected in Assignment 1 |

The model accepts a `float32` tensor with shape `(1, 200, 3)`: one sample containing 200 time steps from the BMI270 x, y, and z gyroscope axes. Its output is a `float32` tensor with shape `(1, 4)`, containing one score for each class.

Assignment 2 saved the trained model here:

```text
gesture_recognition/
└── training/
    └── simple_1dcnn_model.h5
```

## What you will do

In this assignment, you will:

1. Convert the Keras H5 model to TensorFlow Lite.
2. Inspect the converted model's size, tensor shapes, types, and operators.
3. Optionally compare Keras and TensorFlow Lite predictions.
4. Convert the `.tflite` file to a C++ byte array.
5. Replace the model embedded in the ESP-IDF application.

## Assignment steps

The [workshop code repository](https://github.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-tflite-micro/gesture_recognition) and the [training script bundle](https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/training.zip) provide the `convert_model.py` and `embed_model.py` files used in this assignment. The code listings below explain their implementation and provide a manual fallback.

### Step 1: Convert the model

Remain in the `gesture_recognition/training` directory with the Python environment from Assignment 2 activated.

Open the supplied `convert_model.py`. If you are following the exercise without the downloadable assets, create it with this code:

```python {lineNos=true}
from pathlib import Path

import tensorflow as tf
from tensorflow import keras


KERAS_MODEL_PATH = Path("simple_1dcnn_model.h5")
TFLITE_MODEL_PATH = Path("model.tflite")

model = keras.models.load_model(KERAS_MODEL_PATH)
converter = tf.lite.TFLiteConverter.from_keras_model(model)

converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float32]
converter.inference_input_type = tf.float32
converter.inference_output_type = tf.float32

tflite_model = converter.convert()
TFLITE_MODEL_PATH.write_bytes(tflite_model)

print(f"Saved {TFLITE_MODEL_PATH}")
print(f"Model size: {len(tflite_model)} bytes")
```

Run the conversion:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Open `convert_model.py`.
2. Select the `.venv` interpreter created in Assignment 2.
3. Click **Run Python File** in the editor toolbar.

  {{< /tab >}}
  {{< tab label="CLI" >}}

```bash
python convert_model.py
```

  {{< /tab >}}
{{< /tabs >}}

The input and output remain `float32`, matching the gesture application's current preprocessing and inference code. This is not full-integer quantization.

### Step 2: Inspect the TensorFlow Lite model

The supplied `convert_model.py` already includes the following checks. If you created the script manually in Step 1, append them now:

```python {lineNos=true}
interpreter = tf.lite.Interpreter(model_content=tflite_model)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("Input:", input_details[0]["shape"], input_details[0]["dtype"])
print("Output:", output_details[0]["shape"], output_details[0]["dtype"])

assert input_details[0]["shape"].tolist() == [1, 200, 3]
assert input_details[0]["dtype"] == tf.float32.as_numpy_dtype
assert output_details[0]["shape"].tolist() == [1, 4]
assert output_details[0]["dtype"] == tf.float32.as_numpy_dtype

print("Operators:")
for operation in interpreter._get_ops_details():
    print(f"- {operation['op_name']}")
```

Run the script again:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

Click **Run Python File** again after saving the changes to `convert_model.py`.

  {{< /tab >}}
  {{< tab label="CLI" >}}

```bash
python convert_model.py
```

  {{< /tab >}}
{{< /tabs >}}

Expected tensor information:

```text
Input: [  1 200   3] <class 'numpy.float32'>
Output: [1 4] <class 'numpy.float32'>
```

The operator list determines which kernels must be registered in the TensorFlow Lite Micro resolver. The exact list depends on the TensorFlow version and converter output, so use the generated list rather than assuming it matches another model.

### Step 3 (optional): Compare predictions

Before embedding the model, compare both formats with a known sample. Add these imports:

```python
import numpy as np
import pandas as pd
```

Then append:

```python {lineNos=true}
sample = (
    pd.read_csv("./shuttle_dataset/new_gesture.csv", header=None)
    .iloc[0]
    .to_numpy(dtype=np.float32)
    .reshape(1, 200, 3)
)

keras_output = model.predict(sample, verbose=0)

interpreter.set_tensor(input_details[0]["index"], sample)
interpreter.invoke()
tflite_output = interpreter.get_tensor(output_details[0]["index"])

print("Keras output:", keras_output)
print("TFLite output:", tflite_output)
print("Keras class:", int(np.argmax(keras_output)))
print("TFLite class:", int(np.argmax(tflite_output)))

np.testing.assert_allclose(keras_output, tflite_output, rtol=1e-4, atol=1e-5)
```

The output values may differ slightly because conversion can change graph implementation details, but both models should normally select the same class.

### Step 4 (optional): Explore full-integer quantization

Full-integer quantization can reduce model size and may improve inference efficiency, but it requires a representative dataset:

```python {lineNos=true}
import numpy as np
import pandas as pd


representative_data = np.vstack([
    pd.read_csv("./shuttle_dataset/o.csv", header=None).values,
    pd.read_csv("./shuttle_dataset/v.csv", header=None).values,
    pd.read_csv("./shuttle_dataset/unknown.csv", header=None).values,
    pd.read_csv("./shuttle_dataset/new_gesture.csv", header=None).values,
]).reshape(-1, 200, 3).astype(np.float32)


def representative_dataset():
    for sample in representative_data[:100]:
        yield [sample.reshape(1, 200, 3).astype(np.float32)]


converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_dataset
converter.target_spec.supported_ops = [
    tf.lite.OpsSet.TFLITE_BUILTINS_INT8,
]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8
```

This workshop deploys the `float32` model. An `int8` model requires additional input quantization and output dequantization in the ESP-IDF application, so do not replace `model.tflite` with the quantized version unless you also update the inference code.

### Step 5: Convert the model to a C++ array

Use the supplied `embed_model.py` to convert the TensorFlow Lite FlatBuffer into an aligned, constant C++ array:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

Open the supplied `embed_model.py` in the `training` directory. Its implementation is shown below for reference:

```python {lineNos=true}
from pathlib import Path


model_data = Path("model.tflite").read_bytes()
rows = [
    ", ".join(f"0x{value:02x}" for value in model_data[offset:offset + 12])
    for offset in range(0, len(model_data), 12)
]
formatted_data = ",\n    ".join(rows)

Path("model.cpp").write_text(
    '#include "model.h"\n\n'
    "alignas(16) const unsigned char model_tflite[] = {\n"
    f"    {formatted_data}\n"
    "};\n\n"
    "const unsigned int model_tflite_len = sizeof(model_tflite);\n",
    encoding="utf-8",
)

print("Created model.cpp")
```

Open the script in VS Code and click **Run Python File**. This creates the aligned, constant array, so you can continue with Step 6 without editing `model.cpp` manually.

  {{< /tab >}}
  {{< tab label="CLI" >}}

```bash
python embed_model.py
```

If you do not have the supplied script, generate `model.cpp` manually:

```bash
xxd -i model.tflite > model.cpp
```

Because the input file is named `model.tflite`, `xxd` generates these symbols:

```cpp {lineNos=true}
unsigned char model_tflite[] = {
    // Model bytes...
};
unsigned int model_tflite_len = /* model size */;
```

Edit `model.cpp` so the declarations are constant and the byte array is aligned:

```cpp {lineNos=true}
#include "model.h"

alignas(16) const unsigned char model_tflite[] = {
    // Keep all bytes generated by xxd here.
};

const unsigned int model_tflite_len = sizeof(model_tflite);
```

  {{< /tab >}}
{{< /tabs >}}

Alignment gives TensorFlow Lite Micro a suitably aligned FlatBuffer address. The symbol names must remain `model_tflite` and `model_tflite_len` because the application refers to them by those names. The example already contains `main/include/model.h` with the required declarations, so you do not need to create or replace that file.

### Step 6: Add the model to the ESP-IDF project

From the `training` directory, replace the model files in the gesture recognition application:

```bash
cp model.cpp ../main/model.cpp
```

**Graphical alternative:** In Finder, File Explorer, or the VS Code Explorer:

1. Copy `training/model.cpp` to `main/model.cpp`, replacing the existing file.
2. Confirm the replacement when prompted.

The resulting project layout should include:

```text {lineNos=true}
gesture_recognition/
├── main/
│   ├── app_model.cpp
│   ├── model.cpp
│   ├── CMakeLists.txt
│   └── include/
│       └── model.h
└── training/
    ├── simple_1dcnn_model.h5
    ├── model.tflite
    └── model.cpp
```

The example's `main/CMakeLists.txt` registers the whole source directory:

```cmake {lineNos=true}
idf_component_register(
    SRC_DIRS "."
    INCLUDE_DIRS "." "include"
)
```

Because `model.cpp` is inside `main/`, it is compiled automatically. Assignment 4 updates the application labels and deploys the four-class model.

## Acceptance criteria

- The converted `.tflite` model loads in a host-side interpreter.
- Its input tensor is `float32` with shape `(1, 200, 3)`.
- Its output tensor is `float32` with shape `(1, 4)`.
- `model.cpp` defines the constant symbols declared by the example's existing `model.h`.
- The model byte array and length are available to the inference component.

## Next step

[Assignment 4: Deploy and test on-device inference](../assignment-4/)

[Back to workshop home](/workshops/esp-tflite-micro/)
