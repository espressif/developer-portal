---
title: "ESP-TFLite-Micro workshop - Bosch Sensortec sensors"
date: 2026-09-07T00:00:00+01:00
lastmod: 2026-09-07
draft: true
showTableOfContents: true
series: ["WS004EN"]
series_order: 3
showAuthor: false
---

## Bosch Sensortec sensors

These sensors mount on the **Shuttle Board 3.0** connector described in [Hardware: The ESP32-C5 and ESP-SensairShuttle](../hardware/). The ESP-SensairShuttle accepts interchangeable daughterboards:

- **BMI270 + BMM350** — six-axis inertial measurement and three-axis magnetic field sensing on one module.
- **BME690** — temperature, humidity, barometric pressure, and gas resistance.

## BMI270 and BMM350 daughterboard

The motion shuttle board stacks a **BMI270** IMU and **BMM350** magnetometer on one Shuttle Board 3.0 module. Espressif routes the IMU to the ESP32-C5 over **I²C** (CS tied for I²C mode; address **0x68** or **0x69** from the SDO strap). The magnetometer is a separate I²C device (**0x14** on this board with ADSEL grounded) and is often accessed through the BMI270 **AUX I²C master** for time-aligned 9-DoF data.

{{< figure
  src="../assets/esp-sensairshuttle-bmi270-bmm350-front.webp"
  caption="ShuttleBoard-BMI270 and BMM350 (front). Image source: Espressif ESP-Dev-Kits documentation."
>}}

{{< alert icon="triangle-exclamation" >}}
**Always disconnect power before handling the daughterboard.** Before powering on the ESP-SensairShuttle, double-check that the daughterboard is correctly aligned and fully seated in its connector. Never connect, disconnect, or reposition the daughterboard while the mainboard is powered.
{{< /alert >}}

| Sensor | Function | Used in this workshop? |
| --- | --- | --- |
| **BMI270** | 16-bit triaxial accelerometer and gyroscope; up to 6.4 kHz gyro ODR; optional on-chip motion features | **Yes** — gyroscope at **200 Hz**, **±2000 dps**, **200-sample** windows for the classifier |
| **BMM350** | 16-bit triaxial magnetometer (±2000 µT typ.); I²C/I³C | **No** — present on the daughterboard but not read by the gesture example |

The BME690 is also not part of the gesture pipeline.

## BMI270 — six-axis IMU

The [BMI270](https://www.bosch-sensortec.com/en/products/motion-sensors/imus/bmi270/) is a low-power **6-axis IMU** that combines a digital triaxial accelerometer and triaxial gyroscope in one package. Bosch positions it for wearables, hearables, AR/VR, and activity recognition, with on-chip motion features (step counting, wrist-wear detection, gesture hints) that can run while the host sleeps.

### Sensor channels

| Channel | Resolution | Programmable full scale (typ.) |
| --- | --- | --- |
| Accelerometer | 16-bit | ±2 g, ±4 g, ±8 g, ±16 g |
| Gyroscope | 16-bit | ±125, ±250, ±500, ±1000, ±2000 dps |

Typical noise density is about **160 µg/√Hz** on the accelerometer and **0.008 dps/√Hz** on the gyroscope (performance mode targets lower gyro noise, below **7 mdps/√Hz** in the datasheet summary). After soldering, gyro sensitivity can be trimmed with **CRT (Component Re-Trimming)** to roughly **±0.4%** error when the device is stationary.

### Output rate, filtering, and buffering

- **Accelerometer ODR:** about 12.5 Hz to 1.6 kHz (datasheet); extended low rates down to 0.78 Hz are also available.
- **Gyroscope ODR:** 25 Hz to 6.4 kHz.
- **Programmable low-pass filters** on both channels (for example gyro bandwidth roughly 11 Hz to 751 Hz depending on ODR and mode).
- **2 KB FIFO** for accelerometer, gyroscope, auxiliary sensor, and timestamp data.

At full gyro ODR the part draws on the order of **685 µA** (typical, aliasing-free operation). Supply range is **1.71 V to 3.6 V** on VDD and **1.2 V to 3.6 V** on VDDIO. The device comes in a **2.5 × 3.0 × 0.83 mm** 14-pin LGA package and is pin-compatible with BMI160 and BMI260.

### Host interfaces

The BMI270 exposes a **primary** digital interface (I²C or SPI) to the application processor and a **configurable secondary** interface:

- **I²C master (AUX)** — connect one external I²C sensor (for example a magnetometer) with data **hardware-synchronized** to the IMU (sub-microsecond skew in the datasheet).
- **SPI (OIS)** — optional high-speed path for optical image stabilization use cases.

FIFO and timestamping support time-aligned batches of IMU and AUX data on the primary interface, which simplifies 9-DoF fusion without polling two chips independently.

### How the gesture example uses the BMI270

The [ESP-SensairShuttle gesture recognition example](https://github.com/espressif/esp-dev-kits/tree/master/examples/esp-sensairshuttle/examples/gesture_recognition) configures the gyroscope for **200 Hz** output and **±2000 dps** range, then streams **200 consecutive three-axis samples** (600 scalar values) into the TensorFlow Lite model. That window spans **one second** of motion at the chosen ODR.

Collection starts when the sum of absolute gyroscope readings exceeds a **motion threshold** (default **100 dps** combined on x, y, and z). Values are converted to **degrees per second** before inference. The accelerometer is enabled for bring-up and other modes, but the classifier input is **gyroscope-only**.

## BMM350 — three-axis magnetometer

The [BMM350](https://www.bosch-sensortec.com/en/products/motion-sensors/magnetometers/bmm350/) is a **16-bit, three-axis magnetometer** based on Bosch **TMR (tunnel magnetoresistance)** technology. It targets heading, compass, indoor navigation, AR/VR orientation, and robotics dead reckoning when paired with an IMU.

Compared with the earlier BMM150, Bosch cites roughly **3× better sensitivity** and about **20× lower power** in product materials. On the same daughterboard as the BMI270, the BMM350 completes a **9-DoF** sensing set (gyro + accel + mag) for applications that need stable heading or map orientation.

### Field performance and electrical data (typ.)

| Parameter | Typical value |
| --- | --- |
| Magnetic field range (x, y, z) | ±2000 µT |
| Field resolution | ~0.1 µT |
| Output noise (3 dB BW = ODR/2) | ±190 nT rms (x, y); ±450 nT rms (z) |
| Current @ 100 Hz (regular preset) | 200 µA |
| Max ODR (normal mode) | 400 Hz |
| Zero-field offset after soldering | ±25 µT |
| Gain error after soldering | ±1% |
| Operating temperature | −40 °C to +85 °C |

The part uses a **1.28 × 1.28 × 0.5 mm** 9-pin WLCSP. **VDD** is **1.72 V to 1.98 V**; **VDDIO** is **1.72 V to 3.6 V**. Communication is **I²C** or **I³C**, with a **data-ready interrupt** on the INT pin (or in-band interrupt in I³C mode).

### Operating modes

BMM350 supports **normal**, **forced**, and **suspend** modes. You can trade **noise versus power** through ODR and averaging presets; the Bosch sensor API rejects illegal setting combinations and picks the best noise performance for a valid configuration. **Field shock recovery** helps the sensor recover after exposure to strong fields (up to hundreds of millitesla) without the long-term drift seen on some competing parts.

### Integration with the BMI270

On BMI270 + BMM350 shuttle modules, the magnetometer is typically reached through the IMU **AUX I²C master**: the ESP32 talks to the BMI270 on the main bus, and the BMI270 polls or streams BMM350 samples with IMU-aligned timestamps. This workshop does **not** read the BMM350; gesture classification relies on **gyroscope dynamics** only. For products that need compass-assisted rotation or drift control, the same hardware can feed fusion algorithms without changing the board.

## Product documentation

Official Bosch sources for the specifications on this page:

- [BMI270 datasheet (BST-BMI270-DS000)](https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bmi270-ds000.pdf)
- [BMI270 product flyer (BST-BMI270-FL000)](https://www.bosch-sensortec.com/media/boschsensortec/downloads/product_flyer/bst-bmi270-fl000.pdf)
- [BMM350 datasheet (BST-BMM350-DS001)](https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bmm350-ds001.pdf)
- [BMM350 product flyer (BST-BMM350-FL000)](https://www.bosch-sensortec.com/media/boschsensortec/downloads/product_flyer/bst-bmm350-fl000.pdf)

## Next step

[Install ESP-IDF](../setup/)

[Back to workshop home](/workshops/esp-tflite-micro/)
