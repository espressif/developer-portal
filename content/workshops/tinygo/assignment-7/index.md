---
title: "TinyGo Embedded Workshop - Assignment 7: AI Edge Models"
date: 2026-04-22T00:00:00+01:00
lastmod: 2026-04-22
showTableOfContents: false
series: ["WS002EN"]
series_order: 8
showAuthor: false
---

## Assignment 7: AI Edge Models

In this final assignment, you'll explore edge AI concepts, implement simple machine learning in pure Go, and learn about advanced AI capabilities available on ESP32.

## Introduction to Edge AI

### What is Edge AI?

Edge AI (TinyML) brings machine learning to resource-constrained devices:

- **On-device inference**: No cloud connection needed
- **Low latency**: Real-time decision making
- **Privacy**: Data stays on device
- **Low power**: Optimized for battery operation
- **Cost-effective**: No recurring cloud costs

### ESP32 AI Capabilities

**ESP32-S3 AI Acceleration:**
- Vector instructions for neural network operations
- Hardware acceleration for matrix operations
- Optimized for TensorFlow Lite Micro

**Supported by C/C++ Libraries:**
- **ESP-DL**: Espressif Deep Learning Framework
- **TFLite Micro**: TensorFlow Lite for Microcontrollers
- **ESP-NN**: Neural network acceleration functions

## Pure Go Machine Learning

While advanced AI requires C/C++ libraries, we can implement simple ML concepts in pure Go:

### 1. Threshold-Based Classification

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/bmi260"
    "tinygo.org/x/drivers/i2csoft"
)

// Simple gesture detection using thresholds
func detectGesture(accelX, accelY, accelZ float32) string {
    const (
        shakeThreshold = 2.0
        waveThreshold  = 1.0
    )

    motion := calculateMotion(accelX, accelY, accelZ)

    switch {
    case motion > shakeThreshold:
        return "shake"
    case abs(accelX) > waveThreshold:
        return "wave_left"
    case abs(accelY) > waveThreshold:
        return "wave_updown"
    default:
        return "idle"
    }
}

func calculateMotion(x, y, z float32) float32 {
    return sqrt(x*x + y*y + z*z)
}

func sqrt(x float32) float32 {
    // Newton-Raphson square root
    z := float32(1.0)
    for i := 0; i < 10; i++ {
        z -= (z*z - x) / (2 * z)
    }
    return z
}

func abs(x float32) float32 {
    if x < 0 {
        return -x
    }
    return x
}
```

### 2. Pattern Recognition with Moving Average

```go
// Smooth sensor data and detect patterns
type MovingAverage struct {
    buffer [10]float32
    index  int
    sum    float32
}

func (ma *MovingAverage) Update(value float32) float32 {
    ma.sum -= ma.buffer[ma.index]
    ma.buffer[ma.index] = value
    ma.sum += value
    ma.index = (ma.index + 1) % 10
    return ma.sum / 10
}

func detectPeak(data []float32) int {
    if len(data) < 3 {
        return -1
    }

    for i := 1; i < len(data)-1; i++ {
        if data[i] > data[i-1] && data[i] > data[i+1] {
            return i
        }
    }
    return -1
}
```

### 3. Simple Decision Tree

```go
// Decision tree for activity classification
func classifyActivity(x, y, z float32) string {
    magnitude := calculateMotion(x, y, z)

    switch {
    case magnitude > 2.5:
        return "running"
    case magnitude > 1.5:
        return "walking"
    case magnitude > 0.8:
        return "sitting"
    default:
        return "stationary"
    }
}
```

### 4. k-Nearest Neighbors (k-NN)

```go
// Simple k-NN implementation for small datasets
type Point struct {
    X, Y     float32
    Label    string
}

func knnClassify(testPoint Point, trainingData []Point, k int) string {
    distances := make([]float32, len(trainingData))

    // Calculate distances
    for i, point := range trainingData {
        dx := testPoint.X - point.X
        dy := testPoint.Y - point.Y
        distances[i] = sqrt(dx*dx + dy*dy)
    }

    // Find k nearest neighbors
    // Count labels and return most common
    return "class_a" // Simplified
}
```

## Advanced AI with C/C++ Libraries

While TinyGo excels at simplicity, advanced AI requires C/C++ libraries:

### ESP-DL Framework

**Features:**
- Deep learning models (CNN, RNN)
- 8-bit and 16-bit quantization
- Dual-core scheduling
- ESP32-S3/P4 optimized

**Portal Article Reference:**
- [Touchpad Digit Recognition Based on ESP-DL](../../../blog/2025/06/touchpad-digit-recognition/)
- Demonstrates CNN for digit recognition
- Model quantization and deployment
- Complete workflow from training to inference

### TFLite Micro

**Features:**
- Industry standard for edge ML
- Supports various model types
- FlatBuffer model format
- Low memory footprint

**Portal Article Reference:**
- [Gesture Recognition Based on TFLite](../../../blog/2026/04/gesture-recognition-based-on-tflite/)
- IMU gesture classification
- CNN models for time-series data
- ESP32-S3 with ESP-NN acceleration

### ESP-NN Acceleration

**Features:**
- Hardware-accelerated neural network functions
- Optimized for ESP32-S3
- Matrix operations
- Activation functions

**Portal Article Reference:**
- [ESP32-S3 Edge-AI: Human Activity Recognition](../../../blog/esp32-s3-edge-ai-human-activity-recognition-using-accelerometer-data-and-esp-dl/)
- Accelerometer-based activity recognition
- ESP-DL model deployment
- Real-time inference

## TinyGo vs C/C++ for AI

### TinyGo Advantages

**Developer Experience:**
- Simple, readable syntax
- Memory safety
- No manual memory management
- Fast development cycle
- Easy to maintain

**For Simple ML:**
- Threshold-based classification
- Statistical analysis
- Pattern matching
- Data preprocessing

### C/C++ Advantages

**Performance:**
- Direct hardware access
- ESP32-S3 AI acceleration
- Optimized libraries
- Lower memory overhead
- Faster inference

**For Advanced AI:**
- Neural networks
- Deep learning models
- Complex computer vision
- Real-time video processing

## Hybrid Approach: TinyGo + C Libraries

### CGO Interop (Advanced)

TinyGo can interface with C libraries using CGO:

```go
/*
#include "esp-dl.h"
*/
import "C"

func runInference(data []float32) int {
    // Call C function
    result := C.esp_dl_inference(/* ... */)
    return int(result)
}
```

**Note:** CGO interop is complex and may not work on all embedded targets.

## Complete Example: Motion Detector

### Pure Go Motion Classification

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/bmi260"
    "tinygo.org/x/drivers/i2csoft"
    "tinygo.org/x/drivers/ili9341"
    "tinygo.org/x/drivers/axp192/m5stack-core2-axp192"
    "tinygo.org/x/drivers/pixel"
    "tinygo.org/x/tinygl-font"
    "tinygo.org/x/tinygl-font/roboto"
    "image/color"
)

var currentState string = "unknown"
var stateCount int = 0
const stateThreshold = 5

func main() {
    // Initialize sensors and display
    // ... (code from previous assignments) ...

    maX := MovingAverage{}
    maY := MovingAverage{}
    maZ := MovingAverage{}

    for {
        // Read accelerometer
        accelX, accelY, accelZ := sensor.ReadAcceleration()

        // Smooth data
        smoothX := maX.Update(accelX)
        smoothY := maY.Update(accelY)
        smoothZ := maZ.Update(accelZ)

        // Classify motion
        newState := classifyMotion(smoothX, smoothY, smoothZ)

        // Debounce state changes
        if newState == currentState {
            stateCount++
        } else {
            stateCount = 0
            currentState = newState
        }

        // Display if stable
        if stateCount >= stateThreshold {
            displayActivity(currentState)
        }

        time.Sleep(time.Millisecond * 100)
    }
}

func classifyMotion(x, y, z float32) string {
    magnitude := calculateMotion(x, y, z)

    switch {
    case magnitude > 2.0:
        return "running"
    case magnitude > 1.2:
        return "walking"
    case magnitude > 0.5:
        return "sitting"
    default:
        return "stationary"
    }
}

func displayActivity(activity string) {
    // Display on screen
    // ... (code from Assignment 3) ...
}
```

## Real-World AI Applications

### 1. Smart Home

- **Voice commands**: Wake word detection
- **Gesture control**: Remote control via gestures
- **Occupancy detection**: Room usage monitoring

### 2. Wearables

- **Activity tracking**: Step counting, workout detection
- **Fall detection**: Safety alerts for elderly
- **Health monitoring**: Heart rate anomalies

### 3. Industrial

- **Predictive maintenance**: Machine vibration analysis
- **Quality control**: Defect detection
- **Safety monitoring**: Worker behavior analysis

### 4. Automotive

- **Driver monitoring**: Fatigue detection
- **Gesture control**: Infotainment system
- **Collision avoidance**: Object detection

## Further Learning

### Portal Articles

**Gesture Recognition:**
- [Gesture Recognition Based on TFLite](../../../blog/2026/04/gesture-recognition-based-on-tflite/)
- CNN-based gesture classification
- IMU data processing
- Model deployment workflow

**Digit Recognition:**
- [Touchpad Digit Recognition Based on ESP-DL](../../../blog/2025/06/touchpad-digit-recognition/)
- CNN for image classification
- Model quantization
- ESP-DL framework usage

**Activity Recognition:**
- [ESP32-S3 Edge-AI: Human Activity Recognition](../../../blog/esp32-s3-edge-ai-human-activity-recognition-using-accelerometer-data-and-esp-dl/)
- Accelerometer data analysis
- Deep learning models
- Real-time inference

**Advanced Topics:**
- [Hand Gesture Recognition with ESP-DL](../../../blog/hand-gesture-recognition-on-esp32-s3-with-esp-deep-learning/)
- [ESP32-S3 SparkBot AI Applications](../../../blog/2025/04/esp32-s3-sparkBot/)

### Resources

- [ESP-DL GitHub](https://github.com/espressif/esp-dl)
- [TFLite Micro](https://ai.google.dev/edge/litert/)
- [TinyGo ML Examples](https://github.com/tinygo-org/drivers)

## Summary

In this final assignment, you explored:
- Edge AI concepts and applications
- Pure Go implementations of simple ML
- Threshold-based classification
- Pattern recognition and statistical analysis
- Overview of advanced AI frameworks (ESP-DL, TFLite)
- Portal articles with production AI implementations
- Understanding when to use Go vs C/C++ for AI

You now have a foundation in embedded development with TinyGo, from basic GPIO to advanced AI concepts!

## Workshop Complete!

Congratulations! You've completed the TinyGo Embedded Workshop. You've learned:

1. **Environment Setup**: Go, TinyGo, VS Code
2. **GPIO Control**: LED blinky, digital I/O
3. **Display**: Graphics, text, images
4. **Sensors**: I2C communication, accelerometer
5. **Wi-Fi**: Client and server programming
6. **AI**: Simple ML and overview of advanced techniques

### Next Steps

- Build your own IoT projects
- Explore TinyGo drivers ecosystem
- Read portal articles for advanced topics
- Join TinyGo community
- Contribute to open source projects

Thank you for participating, and happy coding!

---

**Back to:** [TinyGo Embedded Workshop](../)
