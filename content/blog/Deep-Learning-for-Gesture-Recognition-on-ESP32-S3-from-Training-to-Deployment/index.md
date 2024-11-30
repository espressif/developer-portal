---
title: "Deep Learning for Gesture Recognition on ESP32-S3 from Training to Deployment"
date: 2024-11-30
showAuthor: false
authors:
  - gao-jiaxuan
tags:
  - ESP32-S3
  - Deep Learning
  - Gesture Recognition
  - ESP-DL
  - Model Quantization
---
Integrating deep learning capabilities into embedded systems has become a crucial aspect of modern IoT applications. Although powerful deep learning models can achieve high recognition accuracy, deploying these models on resource-constrained devices poses considerable challenges. This article presents a gesture recognition system based on the ESP32-S3, detailing the entire workflow from model training to deployment on embedded hardware. The complete project implementation and code are available at [gesture-recognition-model](https://github.com/BlakeHansen130/gesture-recognition-model). By utilizing ESP-DL(master branch) and incorporating efficient quantization strategies with ESP-PPQ, this study demonstrates the feasibility of achieving gesture recognition on resource-limited devices while maintaining satisfactory accuracy. Additionally, insights and methodologies were inspired by the work described in [Espressif's blog on hand gesture recognition](https://developer.espressif.com/blog/hand-gesture-recognition-on-esp32-s3-with-esp-deep-learning/), which significantly influenced the approach taken in this article.

__*This article provides an overview of the complete development process for a gesture recognition system, encompassing dataset preparation, model training, and deployment.*__

*The content is organized into five main sections. The first section, "System Design," outlines the overall system architecture and development environment. The second section, "Model Development," addresses the design of the network architecture and the training strategy. The third section discusses techniques for "Quantization Optimization." The fourth section focuses on "Resource-Constrained Deployment," and the final section presents a comprehensive analysis of experimental results.*

## System Design

The gesture recognition system is built upon the ESP32-S3 platform, leveraging its computational capabilities and memory resources for deep learning inference. The system architecture encompasses both hardware and software components, carefully designed to achieve optimal performance within the constraints of embedded deployment.

### Development Environment

The development process requires two distinct Conda environments to handle different stages of the workflow. The primary training environment, designated as 'dl_env', manages dataset preprocessing, model training, and basic evaluation tasks. A separate quantization environment, 'esp-dl', is specifically configured for model quantization, accuracy assessment, and ESP-DL format conversion.

For the deployment phase, ESP-IDF version 5.x is used, with specific testing conducted on v5.3.1. The implementation relies on the master branch of ESP-DL and ESP-PPQ for enhanced quantization capabilities. The specific versions used in this implementation can be obtained through:

```bash
git clone -b v5.3.1 https://github.com/espressif/esp-idf.git
git clone https://github.com/espressif/esp-dl.git
git clone https://github.com/espressif/esp-ppq.git
```

For reproducibility purposes, the exact commits used in this implementation are:
- ESP-IDF: c8fc5f643b7a7b0d3b182d3df610844e3dc9bd74
- ESP-DL: ac58ec9c0398e665c9b1d66d3760ac47d1676018
- ESP-PPQ: edfd2d685f88e5b17f773981647172d0ea628ae3

It is important to note that using released versions of ESP-DL (such as idfv4.4 or v1.1) may not yield the same quantization performance as the latest master branch. The system configuration requires careful memory management, particularly in handling the ESP32-S3's PSRAM. This is configured through the ESP-IDF menuconfig system with specific attention to flash size and SPIRAM settings.

### Memory Management

The system implements a sophisticated memory management strategy to optimize resource utilization. The CMake configuration is structured to properly integrate the ESP-DL library:

```cmake
cmake_minimum_required(VERSION 3.5)

set(EXTRA_COMPONENT_DIRS
"$ENV{HOME}/esp/esp-dl/esp-dl"
)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(gesture_recognition)
```
__Note: Ensure that CMake can locate the esp-dl library cloned from GitHub by using relative paths to reference the esp-dl directory.

Component registration is handled through a dedicated CMakeLists.txt configuration:

```cmake
idf_component_register(
SRCS
"app_main.cpp"
INCLUDE_DIRS
"."
"model"
REQUIRES
esp-dl
)
```

The memory architecture prioritizes efficient PSRAM utilization, with model weights and input/output tensors strategically allocated to optimize performance. Runtime monitoring of memory usage is implemented through built-in ESP-IDF functions:

```cpp
size_t free_mem = heap_caps_get_free_size(MALLOC_CAP_SPIRAM);
ESP_LOGI(TAG, "Available PSRAM: %u bytes", free_mem);
```

This comprehensive system design forms the foundation for subsequent model development and deployment stages, ensuring robust performance within the constraints of embedded hardware. The careful consideration of memory management and environment configuration is crucial for successful deep learning deployment on resource-constrained devices.

## Model Development

The gesture recognition model employs a lightweight architecture optimized for embedded deployment while maintaining high accuracy. Based on MobileNetV2's inverted residual blocks, the network architecture, termed LightGestureNet, is specifically designed for efficient execution on the ESP32-S3 platform.

The model architecture processes grayscale images of size 96x96 pixels and classifies them into eight distinct gesture classes. The network structure begins with an initial convolutional layer, followed by a series of inverted residual blocks, and concludes with a classifier layer. The implementation details are illustrated in the following code:

```python
first_layer = Conv2d(1, 16, 3, stride=2)
inverted_residual_blocks = [
    (16, 24, stride=2, expand_ratio=6),
    (24, 24, stride=1, expand_ratio=6),
    (24, 32, stride=2, expand_ratio=6),
    (32, 32, stride=1, expand_ratio=6)
]
classifier = Linear(32, num_classes=8)
```

The initial convolutional layer processes single-channel grayscale input with 16 output channels and a stride of 2. The inverted residual blocks follow a systematic pattern of channel expansion and compression, with carefully chosen stride values to control spatial dimension reduction. The expand ratio of 6 in each block provides a balance between model capacity and computational efficiency.

The training process incorporates comprehensive data preprocessing and augmentation strategies. Input images undergo several transformations including resizing to 96x96 pixels, grayscale conversion, and normalization to the [0,1] range. Data augmentation techniques enhance model robustness through random rotation, scaling, and translation operations.

The training configuration utilizes the Adam optimizer with an initial learning rate of 0.001, implementing cosine annealing for learning rate decay. The following code demonstrates the model loading and inference process:

```python
import torch
from model import LightGestureNet

model = LightGestureNet()
model.load_state_dict(torch.load('gesture_model.pth'))
model.eval()

input_tensor = torch.randn(1, 1, 96, 96)
output = model(input_tensor)
```

For deployment flexibility, the model supports multiple export formats. The ONNX format enables cross-platform inference capabilities, as demonstrated in the following implementation:

```python
import onnxruntime

session = onnxruntime.InferenceSession('gesture_model.onnx')

input_name = session.get_inputs()[0].name
output = session.run(None, {input_name: input_array})
```

The ONNX runtime session initialization creates an optimized execution environment for the model. The inference process requires proper input name extraction and tensor formatting to ensure correct model execution.

The gesture classification system encompasses eight distinct classes, mapped through a standardized dictionary:

```python
CLASS_NAMES = {
    0: 'palm',
    1: 'l',
    2: 'fist',
    3: 'thumb',
    4: 'index',
    5: 'ok',
    6: 'c',
    7: 'down'
}
```

This class mapping ensures consistent interpretation of model outputs across different deployment scenarios. 

The model development phase establishes a robust foundation for subsequent quantization and deployment stages, achieving an optimal balance between recognition accuracy and computational efficiency within the constraints of embedded systems.

## Quantization Optimization

Model quantization serves as a critical bridge between high-precision deep learning models and resource-constrained embedded systems. For the ESP32-S3 platform, three distinct quantization strategies have been developed and implemented, each offering unique advantages for different deployment scenarios.

### INT8 Quantization Implementation

The baseline quantization method implements uniform 8-bit quantization across all layers. This fundamental approach provides a solid starting point for model compression:

```python
import onnxruntime
import numpy as np
from ppq import *

def quantize_int8(model):

    with open('cal.pkl', 'rb') as f:
        X_cal, _ = pickle.load(f)
    
    settings = QuantizationSettingFactory.default_setting()
    settings.quantize_parameter_setting.bit_width = 8
    settings.quantize_parameter_setting.symmetrical = True
    settings.quantize_parameter_setting.per_channel = True

    quantum = quantize_torch_model(
        model=model,
        calib_dataloader=X_cal,
        setting=settings,
        platform=TargetPlatform.PPL_CUDA_INT8
    )
    
    return quantum
```

In this implementation, the calibration data plays a crucial role in determining optimal quantization parameters. The `bit_width` parameter sets the quantization precision to 8 bits, while `symmetrical=True` ensures the quantization scheme maintains zero at the center of the range. The `per_channel=True` setting enables more fine-grained quantization by treating each channel independently, which helps preserve model accuracy.

### Mixed Precision Strategy

The mixed precision approach provides more flexibility by allowing different quantization precisions for different layers based on their sensitivity to quantization:

```python
def mixed_precision_quantize(model):

    precision_config = {
        'conv1': {'w_bits': 8, 'a_bits': 8},
        'conv2': {'w_bits': 16, 'a_bits': 8},
        'fc': {'w_bits': 16, 'a_bits': 16}
    }
    
    settings = QuantizationSettingFactory.mixed_precision_setting()
    settings.optimization_level = 1
    
    for layer, config in precision_config.items():
        settings.quantize_parameter_setting[layer] = LayerQuantSetting(
            w_bits=config['w_bits'],
            a_bits=config['a_bits']
        )
    
    quantum = quantize_torch_model(
        model=model,
        calib_dataloader=X_cal,
        setting=settings,
        platform=TargetPlatform.PPL_CUDA_MIX
    )
    
    return quantum
```

This strategy allows precise control over the quantization of each layer. The `precision_config` dictionary defines both weight (`w_bits`) and activation (`a_bits`) precision for each layer. Early layers and critical feature extraction components often benefit from higher precision, while later layers can typically tolerate more aggressive quantization. The optimization level parameter controls how aggressively the quantization algorithm searches for optimal bit assignments.

### Equalization-Aware Quantization

The equalization-aware approach introduces an advanced quantization method that considers the distribution of values across layers:

```python
def equalization_quantize(model):
    settings = QuantizationSettingFactory.default_setting()
    settings.equalization = True
    settings.equalization_setting.iterations = 4
    settings.equalization_setting.value_threshold = 0.4
    settings.optimization_level = 2
    
    model = convert_relu6_to_relu(model)

    quantum = quantize_torch_model(
        model=model,
        calib_dataloader=X_cal,
        setting=settings,
        platform=TargetPlatform.PPL_CUDA_INT8
    )
    
    return quantum
```

The equalization process iteratively adjusts scaling factors across layers to minimize quantization error. The `iterations` parameter controls how many times the equalization algorithm runs, while `value_threshold` determines when the algorithm considers values significant enough to influence scaling decisions. The conversion from ReLU6 to ReLU is necessary for compatibility with the equalization process, as the capped activation function can interfere with proper scale determination.

### Performance Evaluation

To assess the effectiveness of each quantization strategy, a comprehensive evaluation framework has been implemented:

```python
def evaluate_quantized_model(model, test_data):
    metrics = {}

    metrics['size'] = get_model_size(model)

    predictions = model.predict(test_data)
    metrics['accuracy'] = calculate_accuracy(predictions, test_labels)

    metrics['latency'] = measure_inference_time(model, test_data[0])
    
    return metrics
```

This evaluation framework examines three critical aspects of each quantized model: memory footprint, accuracy retention, and inference latency. The modular design allows for easy comparison between different quantization strategies and helps in selecting the most appropriate approach for specific deployment requirements.

Each quantization method presents its own set of trade-offs, and the choice between them depends on specific application requirements such as memory constraints, accuracy requirements, and inference speed needs. The systematic implementation and evaluation of these strategies ensure optimal deployment on the ESP32-S3 platform.

## Resource-Constrained Deployment

The deployment phase of the gesture recognition system on ESP32-S3 requires careful consideration of hardware constraints and system configurations. The implementation focuses on optimal memory utilization and efficient inference execution while maintaining system stability.

### Memory and Partition Configuration

The ESP32-S3's memory architecture necessitates specific configurations through the ESP-IDF menuconfig system. The following memory settings are crucial for optimal model deployment:

```
Serial Flasher Configuration
└── Flash Size: 8MB
Component Configuration
└── ESP PSRAM
    ├── Support for external, SPI-connected RAM
    ├── SPI RAM config
    │   ├── SPIRAM_MODE: Octal
    │   ├── SPIRAM_SPEED: 40 MHz
    │   └── Enable SPI RAM during startup
    └── Allow .bss Segment Placement in PSRAM: Enabled
```

These configurations enable efficient utilization of external RAM for model weight storage and inference operations. The partition table configuration requires customization to accommodate the model data:

```
Partition Table
└── Partition Table: Custom Partition Table CSV
└── Custom Partition CSV File: partitions.csv
```

The custom partition layout ensures adequate space allocation for both the application and model data, facilitating efficient model loading during runtime.

### Build System Integration

The project's CMake configuration integrates the ESP-DL framework and establishes proper component relationships. The build system setup requires careful attention to include paths and dependencies:

```cmake
idf_component_register(
    SRCS
        "app_main.cpp"
    INCLUDE_DIRS
        "."
        "model"
    REQUIRES
        esp-dl
)
```

This configuration ensures proper compilation of the application components and correct linking with the ESP-DL framework. The integration of model files and headers follows a systematic approach through the build system.

### Runtime Memory Management

The implementation employs strategic memory allocation to optimize resource utilization during model inference. Memory monitoring capabilities are integrated into the system to ensure stable operation:

```cpp
size_t free_mem = heap_caps_get_free_size(MALLOC_CAP_SPIRAM);
ESP_LOGI(TAG, "Available PSRAM: %u bytes", free_mem);
```

Model weights are stored in PSRAM while keeping critical runtime buffers in internal RAM for optimal performance. The system implements memory monitoring to prevent allocation failures and maintain stable operation during continuous inference.

### Serial Communication Configuration

The deployment setup includes specific serial communication parameters for reliable device interaction:

```
Component config
└── ESP System Settings
    └── Channel for console output
        └── Default: UART0

Component config
└── Bluetooth
    └── NimBLE Options
        └── Host-controller Transport
            └── Enable Uart Transport
                └── Uart Hci Baud Rate: 115200
```

These settings ensure stable communication during both development and deployment phases. The baud rate selection balances reliable communication with flash programming speed.

### Driver Installation and System Integration

The deployment process requires proper USB driver installation for device communication. The CH340/CH341 driver installation process follows system-specific procedures, ensuring reliable device connectivity.

## Experimental Results

The gesture recognition system on ESP32-S3 showed strong performance across multiple metrics. Both quantitative and qualitative evaluations were conducted.

The baseline model (prior to quantization) established high accuracy across eight gesture classes, particularly distinguishing distinct gestures like 'palm' and 'fist'. This floating-point model served as a benchmark for subsequent optimizations.

After quantization, the mixed-precision approach balanced resource use and recognition accuracy effectively. INT8 quantization minimized model size, while selectively using 16-bit precision in key layers maintained feature discrimination. Equalization-aware quantization helped keep consistent performance across all gestures.

On the ESP32-S3, the optimized model achieved moderate power consumption and efficient memory use, leveraging both internal RAM and PSRAM effectively. These results confirm that the optimization strategies are suitable for deploying advanced gesture recognition on resource-constrained platforms.

## References

1. ESP official resources
- [ESP-DL main repository and documents](https://github.com/espressif/esp-dl)
- [ESP-IDF development framework](https://github.com/espressif/esp-idf)
- [ESP32-S3 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-s3_technical_reference_manual_en.pdf)
- [ESP-IDF Programming Guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/)

2. ESP-PPQ toolchain
- [ESP-PPQ project](https://github.com/espressif/esp-ppq/) Contains:
  - Core API
  - Quantizer documentation
  - Executor implementation
  - Usage guide

3. Tutorials and guides
- [ESP-DL Complete Workflow](https://github.com/alibukharai/Blogs/tree/main/ESP-DL)
- [Model Loading Tutorial](https://github.com/espressif/esp-dl/blob/master/tutorial/how_to_load_model_cn.md)
- [MobileNet V2 Deployment Guide](https://github.com/espressif/esp-dl/blob/master/tutorial/how_to_deploy_mobilenet_v2_cn.md)
- [Model Quantization Guide](https://github.com/espressif/esp-dl/blob/master/tutorial/how_to_quantize_model_cn.md)

4. Datasets
- [LeapGestRecog Dataset](https://www.kaggle.com/datasets/gti-upm/leapgestrecog)
