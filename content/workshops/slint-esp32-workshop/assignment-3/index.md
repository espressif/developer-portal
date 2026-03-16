---
title: "Assignment 3: Run GUI on ESP32-S3"
date: 2025-06-03T00:00:00+01:00
showTableOfContents: true
series: ["slint-no-std"]
series_order: 3
showAuthor: false
---

In this assignment, you will run the same Slint-based application on your embedded hardware — specifically targeting the ESP32-S3 microcontroller.

## Supported Boards

This workshop supports the following boards:

- **M5Stack CoreS3** (recommended - touchscreen, speakers, microphone)
- **ESoPe Board (SLD_C_W_S3)** with RGB interface display (Schukat Smartwin concept)
- **ESP32-S3-BOX-3**
- **ESP32-S3-LCD-EV-Board**

Make sure you have a working USB connection to the board and necessary permissions set (e.g., dialout group on Linux).

## Step-by-Step Instructions

### 1. Connect Your Board

Plug in your ESP32-S3-based board via USB. If you're using the **ESoPe board**, ensure your ESP-Prog programmer is connected to both UART lines.

### 2. Choose Your Development Path

This workshop supports both **`no_std` (recommended)** and **`std`** development approaches:

#### `no_std` Path (Recommended) ✅

Navigate to the `no_std` directory for your specific board:

```bash
# For M5Stack CoreS3 (recommended)
cd slint-esp-workshop/esp32/no_std/m5stack-cores3

# For ESoPe Board
cd slint-esp-workshop/esp32/no_std/esope-sld-c-w-s3

# For ESP32-S3-BOX-3
cd slint-esp-workshop/esp32/no_std/esp32-s3-box-3

# For ESP32-S3-LCD-EV-Board
cd slint-esp-workshop/esp32/no_std/esp32-s3-lcd-ev-board
```

#### `std` Path (Alternative)

If you specifically need ESP-IDF features, navigate to the `std` directory:

```bash
# For M5Stack CoreS3
cd slint-esp-workshop/esp32/std/m5stack-cores3

# For ESP32-S3-BOX-3
cd slint-esp-workshop/esp32/std/esp32-s3-box-3

# Other boards available in std/ directory
```

### 3. Flash the Application

Run the following command to build and flash the application:

```bash
cargo run --release
```

This will compile the `no_std` firmware and flash it via `espflash`. On first use, this may take a bit longer due to compilation and linking.

---

## Entering Bootloader Mode

In order to flash the board, it must be in **bootloader mode**. If you encounter issues flashing, use the following guide:

### Built-in USB UART Boards

For boards with built-in USB-to-serial (e.g. S3-BOX-3 or LCD-Ev-Board):

1. Press and **hold** the **BOOT** button
2. While holding BOOT, **press and release** the **RESET** button
3. **Release BOOT**

This sequence ensures the chip enters bootloader mode.

### ESoPe with ESP-Prog

If you're using an external ESP-Prog programmer, bootloader mode is usually handled automatically. However, **after flashing is complete**, you will need to press **RESET** manually to start the application.

---

## What to Expect

After the board boots, you should see the same two-tab Slint UI as on the desktop:

- The first tab displays the **Slint logo**
- The second tab shows a **placeholder** for the Wi-Fi list

If your display remains blank:
- Double-check display connections and power supply
- Ensure `espflash` selected the correct port
- Use verbose logging `cargo run --release -v` to debug

---

## Summary

At this point, you’ve successfully run a Slint GUI on embedded hardware. In the next assignment, we’ll expand the application to include dynamic Wi-Fi scanning.

[Continue to Assignment 4 →](../assignment-4/)
