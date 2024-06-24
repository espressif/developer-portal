---
title: "Contributing to ESP-BSP: A Step-by-Step Guide for Developers"
date: 2024-06-25
showAuthor: false
authors:
    - "juraj-michalek"
tags: ["Embedded Systems", "ESP32", "ESP32-S3", "Espressif", "BSP", "Contributing"]
---

# Contributing to ESP-BSP: A Step-by-Step Guide for Developers

## Introduction

The ESP Board Support Package (ESP-BSP) is a powerful tool that simplifies the development of applications for various ESP32-based boards. If you're interested in contributing to this open-source project, this guide will walk you through the process, from setting up your development environment to submitting your contributions.

## Prerequisites

Before you start, ensure you have the following:

- **ESP-IDF**: The official development framework for the ESP32, properly installed and sourced in your shell.
- **Git**: Version control system to manage your contributions.
- **GitHub Account**: Required for forking the repository and submitting pull requests.

## Setting Up Your Development Environment

1. **Fork the ESP-BSP Repository**:

   Go to the [ESP-BSP GitHub repository](https://github.com/espressif/esp-bsp) and fork the repository to your own GitHub account.

2. **Clone Your Fork**:

   Clone your forked repository to your local machine:

   ```bash
   git clone https://github.com/your-username/esp-bsp.git
   cd esp-bsp
   ```

3. **Set Up Pre-Commit Hooks**:

   ESP-BSP uses pre-commit hooks to ensure code quality. Set them up with the following commands:

   ```bash
   pip install pre-commit
   pre-commit install
   ```

## Developing a New BSP

### 1. Creating a New BSP

Use the `idf.py create-component` command to create a new BSP component:

```bash
idf.py create-component your_bsp_name
cd components/your_bsp_name
```

### 2. Implementing the BSP

Follow the conventions described in the [BSP development guide](https://github.com/espressif/esp-bsp/blob/master/BSP_development_guide.md). Ensure your BSP includes the following:

- **Public API Header**: Include a header file with the public API, e.g., `bsp/your_bsp.h`.
- **Capabilities Macro**: Define the board's capabilities in the header file, similar to `SOC_CAPS_*` macros.
- **Initialization Functions**: Implement initialization functions for I2C, display, touch, etc.

Example of capabilities definition in `your_bsp.h`:

```c
/**************************************************************************************************
 *  BSP Capabilities
 **************************************************************************************************/

#define BSP_CAPS_DISPLAY        1
#define BSP_CAPS_TOUCH          1
#define BSP_CAPS_BUTTONS        1
#define BSP_CAPS_AUDIO          1
#define BSP_CAPS_AUDIO_SPEAKER  1
#define BSP_CAPS_AUDIO_MIC      1
#define BSP_CAPS_SDCARD         0
#define BSP_CAPS_IMU            1
```

### 3. Adding the BSP to the ESP-BSP Repository

1. **Update the `idf_component.yml` File**:

   Include the new BSP in the `idf_component.yml` file with appropriate metadata:

   ```yaml
   name: your_bsp_name
   version: "1.0.0"
   description: "Board support package for Your BSP"
   targets:
     - esp32
     - esp32s2
     - esp32s3
   ```

2. **Update the Root README.md**:

   Add your new BSP to the table of supported boards in the root `README.md` file:

   ```markdown
   | [Your BSP](components/your_bsp) | ESP32 | Description of features | <img src="docu/pics/your_bsp.png" width="150"> |
   ```

## Testing Your BSP

1. **Create an Example Project**:

   Develop an example project to test and demonstrate your BSP. Place the example in the `examples` directory of your BSP.

2. **Run the Example**:

   Build and flash the example project to ensure your BSP works as expected:

   ```bash
   idf.py build flash monitor
   ```

3. **Ensure Compatibility**:

   Ensure your BSP works with multiple supported IDF versions. Refer to the [CI workflow file](https://github.com/espressif/esp-bsp/blob/master/.github/workflows/build_test.yml) for the list of supported versions.

## Submitting Your Contribution

1. **Commit Your Changes**:

   Commit your changes with a meaningful commit message:

   ```bash
   git add .
   git commit -m "Add support for Your BSP"
   ```

2. **Push to Your Fork**:

   Push your changes to your forked repository:

   ```bash
   git push origin main
   ```

3. **Open a Pull Request**:

   Go to the ESP-BSP repository on GitHub and open a pull request from your fork. Ensure your pull request includes:

   - A clear title and description of your changes.
   - Reference to any related issues or discussions.
   - Pass all automated checks and tests.

## Conclusion

Contributing to ESP-BSP is a great way to help the community and enhance your skills in embedded systems development. By following this guide, you can successfully develop and submit new BSPs, helping to expand the ecosystem of supported boards.

## Useful Links

- [ESP-BSP GitHub Repository](https://github.com/espressif/esp-bsp)
- [ESP-BSP Documentation](https://github.com/espressif/esp-bsp/blob/master/README.md)
- [ESP-IDF Installation Guide](https://docs.espressif.com/projects/esp-idf/en/release-v5.3/esp32/get-started/index.html)
- [BSP Development Guide](https://github.com/espressif/esp-bsp/blob/master/BSP_development_guide.md)
