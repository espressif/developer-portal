---
title: "ESP-TFLite-Micro workshop - Assignment 2: Train and evaluate the model"
date: 2026-09-07T00:00:00+01:00
lastmod: 2026-09-07
draft: true
showTableOfContents: true
series: ["WS004EN"]
series_order: 7
showAuthor: false
---

## Recap from Assignment 1

In the previous assignment, you defined a repeatable movement and recorded at least 25 samples with the BMI270 gyroscope. Each capture became one CSV row containing 600 values:

```text
x0,y0,z0,x1,y1,z1,...,x199,y199,z199
```

The 600 values represent 200 time steps with three axes per step. You also kept the board grip and orientation consistent because changing its orientation changes the sensor axes and therefore the data seen by the model.

The original dataset from the gesture recognition example has three classes:

- `o.csv` — counterclockwise circle
- `v.csv` — V gesture
- `unknown.csv` — movements that are neither circle nor V

Your newly collected CSV adds a **fourth** class. The training code below uses `new_gesture.csv` for the movement collected in Assignment 1. You can keep the gesture's descriptive filename instead, but you must update the corresponding path and label name in the training script and, later, in the application label table.

The [workshop code repository](https://github.com/espressif/developer-portal-codebase/tree/main/content/workshops/esp-tflite-micro/gesture_recognition) and the [training script bundle](https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/training.zip) provide the following training workspace:

```text {lineNos=true}
gesture_recognition/
└── training/
    ├── train_model.py
    ├── requirements.txt
    └── shuttle_dataset/
        ├── o.csv
        ├── v.csv
        ├── unknown.csv
        └── new_gesture.csv
```

## What you will do

In this assignment, you will:

1. Create an isolated Python environment.
2. Load the four CSV files and assign one integer label to each gesture.
3. Reshape every row from 600 values to a `200 × 3` tensor.
4. Split the dataset into training and test sets.
5. Train and evaluate a compact 1D convolutional neural network.
6. Save the trained Keras model for TensorFlow Lite conversion.

## Assignment steps

### Step 1: Create the training workspace

Assignment 1 prepared `training/shuttle_dataset` and saved your collected data as `new_gesture.csv`. If you did not download the workshop project or training bundle, create the workspace now from the `gesture_recognition` project directory:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Open the `gesture_recognition` folder in VS Code.
2. In the Explorer, use **New Folder** to create `training`.
3. Create `shuttle_dataset` inside `training`.
4. Select **File → Open Folder** and open `gesture_recognition/training` before you create or run the files used in the following steps.

Opening the `training` folder makes relative paths such as `./shuttle_dataset/o.csv` resolve correctly.

  {{< /tab >}}
  {{< tab label="macOS" >}}

```bash
mkdir -p training/shuttle_dataset
cd training
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

```bash
mkdir -p training/shuttle_dataset
cd training
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

PowerShell:

```powershell
New-Item -ItemType Directory -Force training\shuttle_dataset
Set-Location training
```

  {{< /tab >}}
{{< /tabs >}}

Download the [original gesture recognition dataset](https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/shuttle_dataset.zip) and extract it:

{{< tabs group="os" >}}
  {{< tab label="macOS" >}}

```bash {lineNos=true}
curl -fL \
  https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/shuttle_dataset.zip \
  -o shuttle_dataset.zip
unzip shuttle_dataset.zip -d shuttle_dataset
rm shuttle_dataset.zip
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

```bash {lineNos=true}
curl -fL \
  https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/shuttle_dataset.zip \
  -o shuttle_dataset.zip
unzip shuttle_dataset.zip -d shuttle_dataset
rm shuttle_dataset.zip
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

PowerShell:

```powershell {lineNos=true}
Invoke-WebRequest `
  -Uri "https://dl.espressif.com/AE/esp-iot-solution/gesture_recognition/shuttle_dataset.zip" `
  -OutFile "shuttle_dataset.zip"
Expand-Archive -Path "shuttle_dataset.zip" -DestinationPath "shuttle_dataset"
Remove-Item "shuttle_dataset.zip"
```

  {{< /tab >}}
{{< /tabs >}}

**Graphical alternative:** Open the dataset link in a browser, save the ZIP archive, and extract it with Finder, File Explorer, or your desktop archive manager. Copy `o.csv`, `v.csv`, and `unknown.csv` into `training/shuttle_dataset` using your file manager or the VS Code Explorer.

The archive adds `o.csv`, `v.csv`, and `unknown.csv` alongside the `new_gesture.csv` file created in Assignment 1. If you saved the collected data elsewhere or used a descriptive filename, use Finder, File Explorer, or the VS Code Explorer to move it into `training/shuttle_dataset` and rename it to `new_gesture.csv`.

If you keep another filename, update the `new_gesture` references in `train_model.py`. Before training, confirm that each CSV row has exactly 600 values and that the new class contains at least 25 rows. Keeping class sizes reasonably balanced prevents a larger class from dominating training.

{{< alert icon="circle-info" >}}
**Open a new terminal session for the Python steps.** Do not create or activate the training environment in the terminal session where you activated ESP-IDF. ESP-IDF uses its own Python environment, which can conflict with the TensorFlow dependencies. In the new terminal, navigate to `gesture_recognition/training` before continuing.
{{< /alert >}}

### Step 2: Create the Python environment

This workshop uses **Python 3.12**. TensorFlow 2.20 does not provide packages for every newer Python release; for example, installation fails with `No matching distribution found for tensorflow` when the environment uses Python 3.14.

Install Python 3.12 if it is not already available:

{{< tabs group="os" >}}
  {{< tab label="macOS" >}}

Install it with Homebrew:

```bash
brew install python@3.12
python3.12 --version
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

On Ubuntu and Debian:

```bash
sudo apt update
sudo apt install python3.12 python3.12-venv
python3.12 --version
```

For other distributions, install Python 3.12 and its `venv` module using the distribution's package manager.

  {{< /tab >}}
  {{< tab label="Windows" >}}

Download and run the [Python 3.12.10 installer](https://www.python.org/downloads/release/python-31210/). Then open PowerShell and verify it:

```powershell
py -3.12 --version
```

  {{< /tab >}}
{{< /tabs >}}

The version command must report `Python 3.12.x`.

{{< alert icon="triangle-exclamation" >}}
If `.venv` was previously created with another Python version, deactivate it and delete the `.venv` folder before continuing. A virtual environment keeps the Python version with which it was created; selecting another interpreter does not upgrade it.
{{< /alert >}}

Create `requirements.txt` in the `training` directory with the following content:

```text {lineNos=true}
numpy
pandas
scikit-learn
tensorflow==2.20.0
matplotlib
```

Create the virtual environment in the `training` directory with Python 3.12:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Install the Microsoft **Python** extension.
2. Open the Command Palette and run `Python: Create Environment`.
3. Select **Venv**, choose **Python 3.12**, and select `requirements.txt` when VS Code asks which dependencies to install.
4. Run `Python: Select Interpreter` and confirm that the `.venv` environment in the `training` directory is selected.

VS Code creates the environment and installs the dependencies, so you can skip the `pip` commands below.

  {{< /tab >}}
  {{< tab label="macOS" >}}

Create the environment:

```bash
python3.12 -m venv .venv
```

Activate it:

```bash
source .venv/bin/activate
```

  {{< /tab >}}
  {{< tab label="Linux" >}}

Create the environment:

```bash
python3.12 -m venv .venv
```

Activate it:

```bash
source .venv/bin/activate
```

  {{< /tab >}}
  {{< tab label="Windows" >}}

Create the environment:

```powershell
py -3.12 -m venv .venv
```

Activate it in PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

Command Prompt:

```cmd
.venv\Scripts\activate.bat
```

  {{< /tab >}}
{{< /tabs >}}

If you created the environment in a terminal, install the dependencies:

```bash
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### Step 3: Load and label the CSV files

Open the supplied `train_model.py` in the `training` directory. The following sections explain how the script works, beginning with the imports and the `extract_data()` function that loads one file per class. If you are following the exercise without the downloadable assets, create the file with this code:

```python {lineNos=true}
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from tensorflow import keras


def extract_data():
    o_data = pd.read_csv("./shuttle_dataset/o.csv", sep=",", header=None)
    v_data = pd.read_csv("./shuttle_dataset/v.csv", sep=",", header=None)
    unknown_data = pd.read_csv("./shuttle_dataset/unknown.csv", sep=",", header=None)
    new_gesture_data = pd.read_csv(
        "./shuttle_dataset/new_gesture.csv",
        sep=",",
        header=None,
    )

    o_label = np.zeros(o_data.shape[0], dtype=int)
    v_label = np.ones(v_data.shape[0], dtype=int)
    unknown_label = np.full(unknown_data.shape[0], 2, dtype=int)
    new_gesture_label = np.full(new_gesture_data.shape[0], 3, dtype=int)

    X_raw = np.vstack([
        o_data.values,
        v_data.values,
        unknown_data.values,
        new_gesture_data.values,
    ])
    y = np.concatenate([
        o_label,
        v_label,
        unknown_label,
        new_gesture_label,
    ])

    num_samples = X_raw.shape[0]
    X = X_raw.reshape(num_samples, 200, 3)

    return X, y
```

The class-to-label mapping is:

| Label | Class |
| ---: | --- |
| `0` | Counterclockwise circle |
| `1` | V gesture |
| `2` | Unknown movement |
| `3` | New gesture collected in Assignment 1 |

`X` has shape `(sample_count, 200, 3)`, while `y` is a one-dimensional array containing the class number for each sample.

### Step 4: Prepare the training and test sets

Convert the arrays to the data types expected by TensorFlow and reserve 30% of the samples for evaluation:

```python {lineNos=true}
def prepare_data():
    X, y = extract_data()

    X = np.array(X, dtype=np.float32)
    y = np.array(y, dtype=np.int32)

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.3,
        random_state=42,
    )

    print(f"Training set: {X_train.shape[0]} samples")
    print(f"Test set: {X_test.shape[0]} samples")

    return X_train, X_test, y_train, y_test
```

The fixed `random_state` makes the split repeatable. For a production dataset collected by several people or in several sessions, split by participant or session instead of randomly mixing related samples. This provides a more realistic test of how the model handles unseen users.

### Step 5: Define the 1D CNN

The reference architecture applies convolution along the time axis:

```python {lineNos=true}
def create_1d_cnn_model():
    model = keras.Sequential([
        keras.layers.Conv1D(
            filters=8,
            kernel_size=5,
            padding="same",
            activation="relu",
            input_shape=(200, 3),
        ),
        keras.layers.MaxPooling1D(pool_size=4),

        keras.layers.Conv1D(
            filters=16,
            kernel_size=5,
            padding="same",
            activation="relu",
        ),
        keras.layers.MaxPooling1D(pool_size=4),

        keras.layers.GlobalAveragePooling1D(),
        keras.layers.Dense(32, activation="relu"),
        keras.layers.Dropout(0.2),
        keras.layers.Dense(4, activation="softmax"),
    ])

    return model
```

The input shape is `(200, 3)`: 200 time steps and three gyroscope axes. The final `Dense(4)` layer produces one score for each of the four classes. If you add or remove classes, change this number and keep the labels in the ESP-IDF application synchronized.

### Step 6: Train the model

Compile and train the model using the settings from the reference script:

```python {lineNos=true}
def train_model(model, X_train, y_train, X_test, y_test, epochs=300):
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )

    model.summary()

    history = model.fit(
        X_train,
        y_train,
        validation_data=(X_test, y_test),
        epochs=epochs,
        batch_size=64,
        verbose=1,
        shuffle=True,
    )

    return history
```

| Setting | Value | Purpose |
| --- | ---: | --- |
| Learning rate | `0.001` | Controls the Adam optimizer's update size |
| Loss | Sparse categorical cross-entropy | Works with integer class labels |
| Epochs | `300` | Number of passes through the training set |
| Batch size | `64` | Samples processed before each parameter update |
| Shuffle | `True` | Changes sample order between epochs |

### Step 7: Evaluate the result

Print the held-out test metrics after training:

```python {lineNos=true}
test_loss, test_accuracy = model.evaluate(X_test, y_test, verbose=0)

print(f"Test loss: {test_loss:.4f}")
print(f"Test accuracy: {test_accuracy:.4f}")
```

#### Optional: Plot the training curves

Plotting is not required to train, save, convert, or deploy the model. It can help you identify overfitting by comparing training and validation loss and accuracy.

Add this function if you want to generate `training_curves.png`:

```python {lineNos=true}
def plot_training_curves(history, save_path="training_curves.png"):
    fig, axes = plt.subplots(1, 2, figsize=(12, 4))
    epochs = range(1, len(history.history["loss"]) + 1)

    axes[0].plot(epochs, history.history["loss"], label="Train Loss")
    axes[0].plot(epochs, history.history["val_loss"], label="Validation Loss")
    axes[0].set_xlabel("Epoch")
    axes[0].set_ylabel("Loss")
    axes[0].set_title("Training and Validation Loss")
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(epochs, history.history["accuracy"], label="Train Accuracy")
    axes[1].plot(
        epochs,
        history.history["val_accuracy"],
        label="Validation Accuracy",
    )
    axes[1].set_xlabel("Epoch")
    axes[1].set_ylabel("Accuracy")
    axes[1].set_title("Training and Validation Accuracy")
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150)
    plt.show()
```

Call it after training:

```python
plot_training_curves(history)
```

Optionally, inspect mistakes per class:

```python {lineNos=true}
from sklearn.metrics import classification_report, confusion_matrix

y_probability = model.predict(X_test)
y_prediction = np.argmax(y_probability, axis=1)

print(confusion_matrix(y_test, y_prediction))
print(classification_report(y_test, y_prediction))
```

Do not judge the model only by training accuracy. Check whether the held-out samples distinguish intentional gestures from unknown movements. If you generate the curves, a large gap between training and validation performance usually indicates overfitting.

### Step 8: Run the training and export the model

Add the save function and main program at the end of `train_model.py`:

```python {lineNos=true}
def save_model_h5(model, filepath):
    model.save(filepath)
    print(f"Model saved to {filepath}")


if __name__ == "__main__":
    keras.utils.set_random_seed(42)

    X_train, X_test, y_train, y_test = prepare_data()
    model = create_1d_cnn_model()
    history = train_model(model, X_train, y_train, X_test, y_test)

    test_loss, test_accuracy = model.evaluate(X_test, y_test, verbose=0)
    print(f"Test loss: {test_loss:.4f}")
    print(f"Test accuracy: {test_accuracy:.4f}")

    # Optional:
    # plot_training_curves(history)

    save_model_h5(model, "simple_1dcnn_model.h5")
```

Run the completed script:

{{< tabs group="tool" default="VS Code" >}}
  {{< tab label="VS Code" >}}

1. Open `train_model.py`.
2. Confirm that the `.venv` interpreter appears in the VS Code status bar.
3. Click **Run Python File** in the editor toolbar.

Training progress and metrics appear in the VS Code Terminal panel.

  {{< /tab >}}
  {{< tab label="CLI" >}}

```bash
python train_model.py
```

  {{< /tab >}}
{{< /tabs >}}

The beginning of the output should show the number of samples per class, the train/test split, and the model summary before training starts.

After the script finishes, the `training` directory should contain:

```text
simple_1dcnn_model.h5
```

If you enable plotting, it also creates `training_curves.png`.

Keep `simple_1dcnn_model.h5`; Assignment 3 converts this file to TensorFlow Lite.

## Complete training script

<details>
<summary>Show complete <code>train_model.py</code></summary>

```python {lineNos=true}
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from tensorflow import keras


def extract_data():
    o_data = pd.read_csv("./shuttle_dataset/o.csv", header=None)
    v_data = pd.read_csv("./shuttle_dataset/v.csv", header=None)
    unknown_data = pd.read_csv("./shuttle_dataset/unknown.csv", header=None)
    new_gesture_data = pd.read_csv(
        "./shuttle_dataset/new_gesture.csv",
        header=None,
    )

    o_label = np.zeros(o_data.shape[0], dtype=int)
    v_label = np.ones(v_data.shape[0], dtype=int)
    unknown_label = np.full(unknown_data.shape[0], 2, dtype=int)
    new_gesture_label = np.full(new_gesture_data.shape[0], 3, dtype=int)

    X_raw = np.vstack([
        o_data.values,
        v_data.values,
        unknown_data.values,
        new_gesture_data.values,
    ])
    y = np.concatenate([
        o_label,
        v_label,
        unknown_label,
        new_gesture_label,
    ])

    print(f"Counterclockwise circle samples: {o_label.shape[0]}")
    print(f"V gesture samples: {v_label.shape[0]}")
    print(f"Unknown samples: {unknown_label.shape[0]}")
    print(f"New gesture samples: {new_gesture_label.shape[0]}")
    print(f"Total samples: {len(y)}")

    X = X_raw.reshape(X_raw.shape[0], 200, 3)
    return X, y


def prepare_data():
    X, y = extract_data()

    X = np.array(X, dtype=np.float32)
    y = np.array(y, dtype=np.int32)

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.3,
        random_state=42,
    )

    print(f"Training set: {X_train.shape[0]} samples")
    print(f"Test set: {X_test.shape[0]} samples")

    return X_train, X_test, y_train, y_test


def create_1d_cnn_model():
    return keras.Sequential([
        keras.layers.Conv1D(
            filters=8,
            kernel_size=5,
            padding="same",
            activation="relu",
            input_shape=(200, 3),
        ),
        keras.layers.MaxPooling1D(pool_size=4),
        keras.layers.Conv1D(
            filters=16,
            kernel_size=5,
            padding="same",
            activation="relu",
        ),
        keras.layers.MaxPooling1D(pool_size=4),
        keras.layers.GlobalAveragePooling1D(),
        keras.layers.Dense(32, activation="relu"),
        keras.layers.Dropout(0.2),
        keras.layers.Dense(4, activation="softmax"),
    ])


def train_model(model, X_train, y_train, X_test, y_test, epochs=300):
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )

    model.summary()

    return model.fit(
        X_train,
        y_train,
        validation_data=(X_test, y_test),
        epochs=epochs,
        batch_size=64,
        verbose=1,
        shuffle=True,
    )


def plot_training_curves(history, save_path="training_curves.png"):
    fig, axes = plt.subplots(1, 2, figsize=(12, 4))
    epochs = range(1, len(history.history["loss"]) + 1)

    axes[0].plot(epochs, history.history["loss"], label="Train Loss")
    axes[0].plot(
        epochs,
        history.history["val_loss"],
        label="Validation Loss",
    )
    axes[0].set_xlabel("Epoch")
    axes[0].set_ylabel("Loss")
    axes[0].set_title("Training and Validation Loss")
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(
        epochs,
        history.history["accuracy"],
        label="Train Accuracy",
    )
    axes[1].plot(
        epochs,
        history.history["val_accuracy"],
        label="Validation Accuracy",
    )
    axes[1].set_xlabel("Epoch")
    axes[1].set_ylabel("Accuracy")
    axes[1].set_title("Training and Validation Accuracy")
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150)
    plt.show()


def save_model_h5(model, filepath):
    model.save(filepath)
    print(f"Model saved to {filepath}")


if __name__ == "__main__":
    keras.utils.set_random_seed(42)

    X_train, X_test, y_train, y_test = prepare_data()
    model = create_1d_cnn_model()
    history = train_model(model, X_train, y_train, X_test, y_test)

    test_loss, test_accuracy = model.evaluate(X_test, y_test, verbose=0)
    print(f"Test loss: {test_loss:.4f}")
    print(f"Test accuracy: {test_accuracy:.4f}")

    # Optional:
    # plot_training_curves(history)

    save_model_h5(model, "simple_1dcnn_model.h5")
```

</details>

## Acceptance criteria

- Training completes without invalid values or tensor-shape errors.
- The model input shape is `(200, 3)`.
- The model output contains four class scores.
- Test-set metrics are recorded.
- `simple_1dcnn_model.h5` is created and can be loaded again for conversion.

## Next step

[Assignment 3: Convert and embed the model](../assignment-3/)

[Back to workshop home](/workshops/esp-tflite-micro/)
