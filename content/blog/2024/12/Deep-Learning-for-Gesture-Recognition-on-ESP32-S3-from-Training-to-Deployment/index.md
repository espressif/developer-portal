---
title: "Deep Learning for Gesture Recognition on ESP32-S3: From Training to Deployment"
date: 2024-12-19
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

Integrating deep learning capabilities into embedded systems has become a crucial aspect of modern IoT applications. Although powerful deep learning models can achieve high recognition accuracy, deploying these models on resource-constrained devices poses considerable challenges. This article presents a gesture recognition system based on the ESP32-S3, detailing the entire workflow from model training to deployment on embedded hardware. The complete project implementation and code are available at [esp32s3-gesture-dl](https://github.com/BlakeHansen130/esp32s3-gesture-dl). By utilizing [ESP-DL](https://github.com/espressif/esp-dl) and incorporating efficient quantization strategies with [ESP-PPQ](https://github.com/espressif/esp-ppq), this study demonstrates the feasibility of achieving gesture recognition on resource-limited devices while maintaining satisfactory accuracy. Additionally, insights and methodologies were inspired by the work described in [Espressif's blog on hand gesture recognition](https://developer.espressif.com/blog/hand-gesture-recognition-on-esp32-s3-with-esp-deep-learning/), which significantly influenced the approach taken in this article.

__*This article provides an overview of the complete development process for a gesture recognition system, encompassing dataset preparation, model training, and deployment.*__

*The content is organized into five main sections. The first section, "System Architecture and Configuration," outlines the overall system architecture and development environment. The second section, "Model Development," addresses the design of the network architecture and the training strategy. The third section discusses techniques for "Quantization Optimization." The fourth section focuses on "Resource-Constrained Deployment," and the final section presents a comprehensive analysis of experimental results.*

## System Architecture and Configuration

The gesture recognition system is built upon the ESP32-S3 platform, leveraging its computational capabilities and memory resources for deep learning inference. The system architecture encompasses both hardware and software components, carefully designed to achieve optimal performance within the constraints of embedded deployment.

### Development Environment

The development process requires two distinct Conda environments to handle different stages of the workflow. The primary training environment, designated as 'dl_env', manages dataset preprocessing, model training, and basic evaluation tasks. A separate quantization environment, 'esp-dl', is specifically configured for model quantization, accuracy assessment, and ESP-DL format conversion.

For the deployment phase, ESP-IDF version 5.3.1 is used. The implementation relies on the master branch of ESP-DL and ESP-PPQ for enhanced quantization capabilities. The specific versions used in this implementation can be obtained through:

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

## LightGestureNet Model Training

### Model Architecture Overview

LightGestureNet is designed as a lightweight convolutional neural network for gesture recognition, drawing inspiration from MobileNetV2's efficient architecture. Here's a detailed look at the implementation:

```python
class LightGestureNet(nn.Module):
    def __init__(self, num_classes=8):
        super().__init__()
        
        self.first = nn.Sequential(
            nn.Conv2d(1, 16, 3, 2, 1, bias=False),  # Input: 96x96, Output: 48x48
            nn.BatchNorm2d(16),
            nn.ReLU6(inplace=True)
        )
        
        self.layers = nn.Sequential(
            InvertedResidual(16, 24, 2, 6),
            InvertedResidual(24, 24, 1, 6),
            InvertedResidual(24, 32, 2, 6),
            InvertedResidual(32, 32, 1, 6)
        )
        
        self.classifier = nn.Sequential(
            nn.AdaptiveAvgPool2d(1),
            nn.Flatten(),
            nn.Linear(32, num_classes)
        )
```

The architecture begins with a single input channel for grayscale images and gradually increases the feature depth while reducing spatial dimensions. The initial convolution layer reduces the spatial dimensions by half while increasing the channel count to 16. The network then employs a series of inverted residual blocks, where each block first expands the channels (multiply by 6) for better feature extraction, then performs depthwise convolution, and finally projects back to a smaller channel count. This expand-reduce pattern has been proven effective for maintaining model expressiveness while reducing parameters.

The inverted residual blocks are implemented as follows:

```python
class InvertedResidual(nn.Module):
    def __init__(self, in_c, out_c, stride, expand_ratio):
        super().__init__()
        hidden_dim = in_c * expand_ratio
        self.use_res = stride == 1 and in_c == out_c
        
        layers = []
        if expand_ratio != 1:
            layers.extend([
                nn.Conv2d(in_c, hidden_dim, 1, bias=False),
                nn.BatchNorm2d(hidden_dim),
                nn.ReLU6(inplace=True)
            ])
            
        layers.extend([
            nn.Conv2d(hidden_dim, hidden_dim, 3, stride, 1, groups=hidden_dim, bias=False),
            nn.BatchNorm2d(hidden_dim),
            nn.ReLU6(inplace=True),
            # Projection phase: reduce channels back using 1x1 conv
            nn.Conv2d(hidden_dim, out_c, 1, bias=False),
            nn.BatchNorm2d(out_c)
        ])
        self.conv = nn.Sequential(*layers)
```

The InvertedResidual block implements the expand-reduce pattern with three main components: channel expansion, depthwise convolution, and channel reduction. This design significantly reduces the number of parameters while maintaining model capacity. The use of groups=hidden_dim in the depthwise convolution ensures each channel is processed independently, reducing computational complexity.

### Dataset Preparation and Augmentation

The dataset implementation focuses on efficient data handling and robust augmentation. Here's the detailed implementation:

```python
class GestureDataset(Dataset):
    def __init__(self, X, y, transform=None):
        # Ensure proper dimensionality for PyTorch
        self.X = torch.FloatTensor(X).unsqueeze(1)
        self.y = torch.LongTensor(y)
        self.transform = transform
    
    def __getitem__(self, idx):
        image = self.X[idx]
        label = self.y[idx]
        
        if self.transform:
            image = self.transform(image)
            
        return image, label

# Comprehensive augmentation pipeline
train_transform = transforms.Compose([
    transforms.RandomRotation(90),
    transforms.RandomAffine(
        0,
        scale=(0.8, 1.2),
        translate=(0.2, 0.2)
    ),
    transforms.RandomHorizontalFlip(),
    transforms.RandomVerticalFlip()
])
```

The dataset class handles the crucial task of preparing our data for training. The unsqueeze(1) operation adds a channel dimension to our grayscale images, converting them from (96, 96) to (1, 96, 96) to match PyTorch's expected format. The transform pipeline is particularly comprehensive, designed to create a robust model that can handle real-world variations in gesture presentations. Each transformation serves a specific purpose: RandomRotation handles different hand orientations, RandomAffine with scaling helps with varying distances from the camera, and the flips help with different viewing angles and hand variations.

### Training Configuration and Optimization

The training configuration implements carefully chosen initialization strategies and optimization parameters:

```python
def weight_init(m):
    if isinstance(m, nn.Conv2d):
        init.kaiming_normal_(m.weight, mode='fan_out', nonlinearity='relu')
        if m.bias is not None:
            init.constant_(m.bias, 0)
    elif isinstance(m, nn.BatchNorm2d):
        init.constant_(m.weight, 1)
        init.constant_(m.bias, 0)
    elif isinstance(m, nn.Linear):
        init.xavier_normal_(m.weight)
        if m.bias is not None:
            init.constant_(m.bias, 0)

model = LightGestureNet().to(device)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(
    model.parameters(),
    lr=0.001,
)
scheduler = optim.lr_scheduler.CosineAnnealingLR(
    optimizer,
    T_max=num_epochs
)
model.apply(weight_init)
```

The weight initialization strategy is carefully designed for each layer type. Convolutional layers use He initialization, which is particularly suitable for ReLU-based networks as it prevents vanishing gradients in deep networks. BatchNorm layers are initialized to initially perform an identity transformation, allowing the network to learn the optimal normalization parameters during training. The final linear layer uses Xavier initialization, which is suitable for the classification head where the activation function is not ReLU.

The Adam optimizer is chosen for its adaptive learning rate properties, making it robust to the choice of initial learning rate. The cosine annealing learning rate scheduler provides a smooth transition from higher to lower learning rates, helping the model converge to better minima. This combination of initialization strategies and optimization choices helps ensure stable and efficient training.

### Training Process and Monitoring

The training process incorporates strategic monitoring mechanisms to optimize model performance. Training and validation accuracy thresholds are set at 95-99% and 90-98% respectively, with a maximum allowable difference to prevent overfitting. An early stopping mechanism with 5 epochs patience period automatically halts training when validation loss plateaus. The system continuously tracks loss and accuracy metrics, saving the best model weights based on validation performance to ensure optimal results.

### Model Export Strategy

The model export process is designed to support deployment across various platforms and frameworks. The trained model is exported in multiple formats, each serving a specific purpose in the deployment pipeline. The PyTorch native format (.pth) is maintained for continued development and fine-tuning scenarios. The ONNX format is chosen for its cross-platform compatibility and widespread support across different deployment environments, particularly in production settings. The export process implements dynamic batch size support, allowing for flexible inference requirements during deployment.

For mobile deployment scenarios, TensorFlow Lite conversion is implemented with optimizations for mobile environments. Each exported format undergoes a verification process to ensure prediction consistency, maintaining the model's accuracy across different runtime environments. This multi-format export strategy ensures maximum deployment flexibility while maintaining model performance integrity across different platforms.

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

### Runtime memory monitoring

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
└── ESP System Settings
    └── (115200) UART console baud rate
```

These settings ensure stable communication during both development and deployment phases. The baud rate selection balances reliable communication with flash programming speed.It has been observed that reinstalling serial port drivers on systems such as Windows 11 and Ubuntu 24.04 can potentially reset the default baud rate and serial port settings. This may lead to issues such as errors in the `idf.py monitor` tool and the inability to view the corresponding output. In the latest versions of ESP-IDF, the baud rate is automatically set to 115200, mitigating this issue. However, in older versions, such as ESP-IDF 4.4, manual adjustment of the baud rate is necessary to avoid such problems. 

### Driver Installation and System Integration

The deployment process requires proper USB driver installation for device communication. The CH340/CH341 driver installation process follows system-specific procedures, ensuring reliable device connectivity.

## Experimental Results

The gesture recognition system on ESP32-S3 performs well in multiple metrics, such as accuracy and model running time. Quantitative and qualitative evaluations are performed.

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
