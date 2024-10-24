---
title: "Hand Gesture Recognition on ESP32-S3 with ESP-Deep Learning"
date: 2022-12-02
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - ali-hassan-shah
tags:
  - Deep Learning
  - AI
  - Espressif
  - ESP-ID
  - ESP32
---
Artificial intelligence transforms the way computers interact with the real world. Decisions are carried by getting data from Tiny low-powered devices and sensors into the cloud. Connectivity, high cost and data privacy are some of the demerits of this method. [Edge artificial intelligence](https://www.youtube.com/watch?v=DAPgDuw1uZM) is another way to process the data right on the physical device without sending data back and forth improving the latency and security and reducing the bandwidth and power.

Espressif System provides a framework [ESP-DL](https://github.com/espressif/esp-dl) that can be used to deploy your high-performance deep learning models on Espressif chip ESP32-S3.

In this article, we will understand how to use [ESP-DL](https://github.com/espressif/esp-dl) and [deploy](https://github.com/espressif/esp-dl/tree/master/) a deep-learning model on [ESP32-S3](https://www.espressif.com/en/products/socs/esp32-s3).


## Prerequisite for using ESP-DL

Before getting a deep dive into ESP-DL, we assume that readers have;

1. Knowledge about building and training neural networks. (Check out basics of deep-learning)
2. Configure the ESP-IDF release 4.4 environment. (Follow setting-up ESP-IDF environment or tool chain for ESP-IDF for more details)
3. Working knowledge of basic C and C++ language.’

Note: Please use ESP-IDF release/v4.4 on the commit “cc71308e2fdce1d6d27fc52d39943f5d0fb83f35” to reproduce the same results

## Model Development
For the sake of simplicity, a classification problem is selected and developed a simple deep-learning model to classify 6 different hand gestures. Many open-source pre trained [models](https://github.com/filipefborba/HandRecognition) are available however for this demonstration we prefer to build a model from scratch to get a better understanding of each layer of the model.
* we are using Google [Co-lab](https://colab.research.google.com/) for model development

### Dataset
For this classification problem, We are using an open-source dataset from the Kaggle [Hand Gesture recognition Dataset](https://www.kaggle.com/datasets/gti-upm/leapgestrecog). The original dataset includes 10 classes however we are using only 6 classes that are easy to recognize and more useful in daily life. The hand gesture classes are represented in the table below. One more difference is related to the image size, the original dataset has an image size of (240 , 640) however for the sake of simplicity resized the dataset to (96 , 96). The dataset used in this article can be found at [ESP-DL repo](https://github.com/alibukharai/Blogs/tree/main/ESP-DL).

### Test/Train Split

We need to divide our dataset into test, train and calibration datasets. These datasets are nothing but the subsets of our original [dataset](https://github.com/alibukharai/Blogs/blob/main/ESP-DL/building_with_espdl.md#11-dataset). The training dataset is used to train the model while the testing dataset is to test the model performance similarly calibration dataset is used during the [model quantization](https://github.com/alibukharai/Blogs/blob/main/ESP-DL/building_with_espdl.md#22-optimization-and-quantization) stage for calibration purposes. The procedure to generate all these datasets is the same. We used train_test_split for this purpose.

```python
from sklearn.model_selection import train_test_split

ts = 0.3 # Percentage of images that we want to use for testing.
X_train, X_test1, y_train, y_test1 = train_test_split(X, y, test_size=ts, random_state=42)
X_test, X_cal, y_test, y_cal = train_test_split(X_test1, y_test1, test_size=ts, random_state=42)
```

*For more details about how train_test_split works please check out [scikit-learn.org](https://scikit-learn.org/).

For the reproduction of this tutorial you can find the data from (GitHub) and open data in your working environment.

```python
import pickle

with open('X_test.pkl', 'rb') as file:
    X_test = pickle.load(file)

with open('y_test.pkl', 'rb') as file:
    y_test = pickle.load(file)

with open('X_train.pkl', 'rb') as file:
    X_train = pickle.load(file)

with open('y_train.pkl', 'rb') as file:
    y_train = pickle.load(file)
```

### Building a Model

```python
import tensorflow as tf
from tensorflow import keras
from keras.models import Sequential
from keras.layers.convolutional import Conv2D, MaxPooling2D
from keras.layers import Dense, Flatten, Dropout

print(tf.__version__)

model = Sequential()
model.add(Conv2D(32, (5, 5), activation='relu', input_shape=(96, 96, 1)))
model.add(MaxPooling2D((2, 2)))
model.add(Dropout(0.2))
model.add(Conv2D(64, (3, 3), activation='relu'))
model.add(MaxPooling2D((2, 2)))
model.add(Dropout(0.2))
model.add(Conv2D(64, (3, 3), activation='relu'))
model.add(MaxPooling2D((2, 2)))
model.add(Flatten())
model.add(Dense(128, activation='relu'))
model.add(Dense(6, activation='softmax'))

model.compile(optimizer='adam',loss='sparse_categorical_crossentropy',metrics=['accuracy'])

model.summary()
```

### Training a Model

The model is running for 5 epochs, with a final accuracy of around 99%.

```python
history=model.fit(X_train, y_train, epochs=5, batch_size=64, verbose=1, validation_data=(X_test, y_test))
```

### Saving a Model

The trained model is saved in Hierarchical Data format (.h5). For more details on how the Keras model be saved check out click [tensorflow.org](https://www.tensorflow.org/guide/keras/save_and_serialize#how_to_save_and_load_a_model).

```python
model.save('handrecognition_model.h5')
```

### Model Conversion

ESP-DL uses model in Open Neural Network Exchange (ONXX) format. For more details on how ONNX is working click here. To be compatible with ESP-DL convert the trained .h5 format of the model into ONXX format by using the below lines of code.

```shell
model = tf.keras.models.load_model("/content/handrecognition_model.h5")
tf.saved_model.save(model, "tmp_model")
!python -m tf2onnx.convert --saved-model tmp_model --output "handrecognition_model.onnx"
!zip -r /content/tmp_model.zip /content/tmp_model
```

In the end, H5 format model, ONNX format model and model checkpoints are downloaded for future use.

```pythonn
from google.colab import files
files.download("/content/handrecognition_model.h5")
files.download("/content/handrecognition_model.onnx")
files.download("/content/tmp_model.zip")
```

## ESP-DL format

Once the ONNX format of the model is ready, follow the steps below to convert the model into ESP-DL format.

* We are using [Pychram](https://www.jetbrains.com/pycharm/) IDE for ESP-DL format conversion.

### Requirements

Setting up an environment and installing the correct version of the modules is always a key to start with. If the modules are not installed in the correct version it gives an error.

Next, need to download ESP-DL. clone the ESP-DL from the GitHub repository.

```shell
git clone --recursive https://github.com/espressif/esp-dl.git
```

### Optimization and Quantization

To run the optimizer provided by ESP-DL, we need to find and

- calibrator.pyd
- calibrator_acc.pyd
- evaluator.pyd
- optimizer.py

place these files into the working directory of pychram — IDE. Furthermore, also place the calibration dataset generated in the previous section 1.2 and ONNX format model saved in previous section 1.5 .

Follow the below steps for generating optimized and quantize model.


```python
from optimizer import *
from calibrator import *
from evaluator import *

# Load the ONNX model
onnx_model = onnx.load("handrecognition_model.onnx")
optimized_model_path = optimize_fp_model("handrecognition_model.onnx")

# Load Calibration dataset
with open('X_cal.pkl', 'rb') as f:
    (test_images) = pickle.load(f)
with open('y_cal.pkl', 'rb') as f:
    (test_labels) = pickle.load(f)

calib_dataset = test_images[0:1800:20]
pickle_file_path = 'handrecognition_calib.pickle'

# Calibration
model_proto = onnx.load(optimized_model_path)
print('Generating the quantization table:')

calib = Calibrator('int16', 'per-tensor', 'minmax')
# calib = Calibrator('int8', 'per-channel', 'minmax')

calib.set_providers(['CPUExecutionProvider'])

# Obtain the quantization parameter
calib.generate_quantization_table(model_proto,calib_dataset, pickle_file_path)
# Generate the coefficient files for esp32s3
calib.export_coefficient_to_cpp(model_proto, pickle_file_path, 'esp32s3', '.', 'handrecognition_coefficient', True)
```

If everything is alright, at this stage two files with an extension .cpp and .hpp is generated in the path, and the output should look like this.

### Evaluate

This step is not necessary however if you want to evaluate the performance of the optimized model the following code can be used.

```python
print('Evaluating the performance on esp32s3:')
eva = Evaluator('int16', 'per-tensor', 'esp32s3')
eva.set_providers(['CPUExecutionProvider'])
eva.generate_quantized_model(model_proto, pickle_file_path)

output_names = [n.name for n in model_proto.graph.output]
providers = ['CPUExecutionProvider']
m = rt.InferenceSession(optimized_model_path, providers=providers)

batch_size = 64
batch_num = int(len(test_images) / batch_size)
res = 0
fp_res = 0
input_name = m.get_inputs()[0].name
for i in range(batch_num):
    # int8_model
    [outputs, _] = eva.evalaute_quantized_model(test_images[i * batch_size:(i + 1) * batch_size], False)
    res = res + sum(np.argmax(outputs[0], axis=1) == test_labels[i * batch_size:(i + 1) * batch_size])

    # floating-point model
    fp_outputs = m.run(output_names, {input_name: test_images[i * batch_size:(i + 1) * batch_size].astype(np.float32)})
    fp_res = fp_res + sum(np.argmax(fp_outputs[0], axis=1) == test_labels[i * batch_size:(i + 1) * batch_size])
print('accuracy of int8 model is: %f' % (res / len(test_images)))
print('accuracy of fp32 model is: %f' % (fp_res / len(test_images)
```

## Model Deployment

Model deployment is the final and crucial step. In this step, we will implement our model in C-language to run on the top of ESP32-S3 micro-controller and gets the results.

### ESP-IDF Project Hierarchy
The first step is to create a new project in VS-Code based on ESP-IDF standards. For more details about how to create a VS-Code project for ESP32 please click here or here

Copy the files.cpp and .hpp generated in the previous section 2.2 to your current working directory.

Add all the dependent components to the components folder of your working directory.
sdkconfig files are default files from ESP-WHO example. These files are also provided in linked GitHub repository.

The Project directory should look like this;
```
├── CMakeLists.txt
├── components
│   ├── esp-dl
│   └── esp-who
├── dependencies.lock
├── main
│   ├── app_main.cpp
│   └── CMakeLists.txt
├── model
│   ├── handrecognition_coefficient.cpp
│   ├── handrecognition_coefficient.hpp
│   └── model_define.hpp
├── partitions.csv
├── sdkconfig
├── sdkconfig.defaults
├── sdkconfig.defaults.esp32
├── sdkconfig.defaults.esp32s2
└── sdkconfig.defaults.esp32s3
```

### Model define

We will define our model in the ‘model_define.hpp’ file. Follow the below steps for a details explanation of defining the model.

#### Import libraries

Firstly import all the relevant libraries. Based on our model design or another way to know which particular libraries need to use an open source tool Netron and open your optimized ONNX model generated at the end of previous section 2.2 . Please check here for all the currently supported libraries by ESP-DL.

```cpp
#pragma once
#include <stdint.h>
#include "dl_layer_model.hpp"
#include "dl_layer_base.hpp"
#include "dl_layer_max_pool2d.hpp"
#include "dl_layer_conv2d.hpp"
#include "dl_layer_reshape.hpp"
#include "dl_layer_softmax.hpp"
#include "handrecognition_coefficient.hpp"

using namespace dl;
using namespace layer;
using namespace handrecognition_coefficient;
```

#### Declare layers

The next is to declare each layer.

Input is not considered a layer so not defined here.

Except for the output layer, all the layers are declared as private layers.

Remember to place each layer in order as defined in previous section 1.3 while building the model.

```cpp
class HANDRECOGNITION : public Model<int16_t>
{
private:
    Reshape<int16_t> l1;
    Conv2D<int16_t> l2;
    MaxPool2D<int16_t> l3;
    Conv2D<int16_t> l4;
    MaxPool2D<int16_t> l5;
    Conv2D<int16_t> l6;
    MaxPool2D<int16_t> l7;
    Reshape<int16_t> l8;
    Conv2D<int16_t> l9;
    Conv2D<int16_t> l10;
public:
    Softmax<int16_t> l11; // output layer
```

####  Initialize layers

After declaring the layers, we need to initialize each layer with its weight, biases activation functions and shape. let us check each layer in detail.

Before getting into details, let us look into how our model looks like when opening in Netron that is somehow imported to get some parameters for initializing.

The first layer is reshaped layer (note that the input is not considered as a layer) and gives an output shape of (96 , 96, 1) for this layer. These parameters must be the same as you used during model training see section 1.3. Another way to know the parameter and layer is to use an open source tool Netron and open your optimized ONNX model generated at the end of previous section 2.2.

For the convolution 2D layer we can get the name of this layer for the filter, bias and activation function from the .hpp file generated at the end of the previous section 2.2, However for the exponents, we need to check the output generated in section 2.2.5.

For the max-pooling layer, we can use the same parameters as we use during building our model see section 1.3. or another way to know the parameter and layer is to use an open-source tool Netron and open your optimized ONNX model generated at the end of the previous section 2.2.

For the dense layer or fully connected layer, conv2D block is used and we can get the name of this layer for the filter, bias and activation function from the .hpp file generated at the end of previous section 2.2, However for the exponents, we need to check the output generated in section 2.2.5.

The output layer is a SoftMax layer weight and the name can be taken from the output generated in section 2.2.5.

```cpp
HANDRECOGNITION () : l1(Reshape<int16_t>({96,96,1})),
  l2(Conv2D<int16_t>(-8, get_statefulpartitionedcall_sequential_1_conv2d_3_biasadd_filter(), get_statefulpartitionedcall_sequential_1_conv2d_3_biasadd_bias(), get_statefulpartitionedcall_sequential_1_conv2d_3_biasadd_activation(), PADDING_VALID, {}, 1,1, "l1")),
  l3(MaxPool2D<int16_t>({2,2},PADDING_VALID, {}, 2, 2, "l2")),
  l4(Conv2D<int16_t>(-9, get_statefulpartitionedcall_sequential_1_conv2d_4_biasadd_filter(), get_statefulpartitionedcall_sequential_1_conv2d_4_biasadd_bias(), get_statefulpartitionedcall_sequential_1_conv2d_4_biasadd_activation(), PADDING_VALID,{}, 1,1, "l3")),
  l5(MaxPool2D<int16_t>({2,2},PADDING_VALID,{}, 2, 2, "l4")),
  l6(Conv2D<int16_t>(-9, get_statefulpartitionedcall_sequential_1_conv2d_5_biasadd_filter(), get_statefulpartitionedcall_sequential_1_conv2d_5_biasadd_bias(), get_statefulpartitionedcall_sequential_1_conv2d_5_biasadd_activation(), PADDING_VALID,{}, 1,1, "l5")),
  l7(MaxPool2D<int16_t>({2,2},PADDING_VALID,{}, 2, 2, "l6")),
  l8(Reshape<int16_t>({1,1,6400},"l7_reshape")),
  l9(Conv2D<int16_t>(-9, get_fused_gemm_0_filter(), get_fused_gemm_0_bias(), get_fused_gemm_0_activation(), PADDING_VALID, {}, 1, 1, "l8")),
  l10(Conv2D<int16_t>(-9, get_fused_gemm_1_filter(), get_fused_gemm_1_bias(), NULL, PADDING_VALID,{}, 1,1, "l9")),
  l11(Softmax<int16_t>(-14,"l10")){}
```

#### Build layers

The next step is to build each layer.

```cpp
void build(Tensor<int16_t> &input)
  {
    this->l1.build(input);
    this->l2.build(this->l1.get_output());
    this->l3.build(this->l2.get_output());
    this->l4.build(this->l3.get_output());
    this->l5.build(this->l4.get_output());
    this->l6.build(this->l5.get_output());
    this->l7.build(this->l6.get_output());
    this->l8.build(this->l7.get_output());
    this->l9.build(this->l8.get_output());
    this->l10.build(this->l9.get_output());
    this->l11.build(this->l10.get_output());
  }
```

#### Call layers

In the end, we need to connect these layers and call them one by one by using a call function.

```cpp
oid call(Tensor<int16_t> &input)
    {
        this->l1.call(input);
        input.free_element();

        this->l2.call(this->l1.get_output());
        this->l1.get_output().free_element();

        this->l3.call(this->l2.get_output());
        this->l2.get_output().free_element();

        this->l4.call(this->l3.get_output());
        this->l3.get_output().free_element();

        this->l5.call(this->l4.get_output());
        this->l4.get_output().free_element();

        this->l6.call(this->l5.get_output());
        this->l5.get_output().free_element();

        this->l7.call(this->l6.get_output());
        this->l6.get_output().free_element();

        this->l8.call(this->l7.get_output());
        this->l7.get_output().free_element();

        this->l9.call(this->l8.get_output());
        this->l8.get_output().free_element();

        this->l10.call(this->l9.get_output());
        this->l9.get_output().free_element();

        this->l11.call(this->l10.get_output());
        this->l10.get_output().free_element();
    }
};
```

###  Model Run

#### Import Libraries

After building our Model need to run and give input to our model. ‘app_main.cpp’ file is used to generate the input and run our model on ESP32-S3.

```cpp
#include <stdio.h>
#include <stdlib.h>
#include "esp_system.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "dl_tool.hpp"
#include "model_define.hpp"
```

#### Declare Input

We trained our model by giving an input of size (96, 96, 1) see section 1.3. However, the input_exponent can get its exponent value from the output generated in section 2.2.5. Another thing is to write the pixels of the input/test picture here.

```cpp
int input_height = 96;
int input_width = 96;
int input_channel = 1;
int input_exponent = -7;

__attribute__((aligned(16))) int16_t example_element[] = {

    //add your input/test image pixels
};
```

#### Set Input Shape

Each pixel of the input is adjusted based on the input_exponent declared above.

```cpp
extern "C" void app_main(void)
{
Tensor<int16_t> input;
  input.set_element((int16_t *)example_element).set_exponent(input_exponent).set_shape({input_height,input_width,input_channel}).set_auto_free(false);
```

#### Call a Model

Call the model by calling the method forward and passing input to it. Latency is used to calculate the time taken by ESP32-S3 to run the neural network.

```cpp
HANDRECOGNITION model;
  dl::tool::Latency latency;
  latency.start();
  model.forward(input);
  latency.end();
  latency.print("\nSIGN", "forward");
```

#### Monitor Output

The output is taken out from the public layer i.e. l11. and you can print the result in the terminal.

```cpp
float *score = model.l11.get_output().get_element_ptr();
float max_score = score[0];
int max_index = 0;
for (size_t i = 0; i < 6; i++)
{
    printf("%f, ", score[i]*100);
    if (score[i] > max_score)
    {
        max_score = score[i];
        max_index = i;
    }
}
printf("\n");

switch (max_index)
{
    case 0:
    printf("Palm: 0");
    break;
    case 1:
    printf("I: 1");
    break;
    case 2:
    printf("Thumb: 2");
    break;
    case 3:
    printf("Index: 3");
    break;
    case 4:
    printf("ok: 4");
    break;
    case 5:
    printf("C: 5");
    break;
    default:
    printf("No result");
}
printf("\n");
```

The model latency is around 0.7 Seconds on ESP32-S3, whereas each neuron output and finally the predicted result is shown.

## Future Work

In future, we will design a model for [ESP32-S3 EYE](https://www.espressif.com/en/products/devkits/esp-eye/resourceswww.espressif.com2) devkit which could capture images in real time and performs hand gesture recognition. Check out the [GitHub](https://github.com/alibukharai/Blogs/tree/main/ESP-DL) repository for source code.
