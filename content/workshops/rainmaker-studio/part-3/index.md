---
title: "Part 3 — Build, Flash, and Test"
date: "2026-06-18"
lastmod: "2026-06-18"
series: ["WSRMS"]
series_order: 3
showAuthor: false
summary: "Build the project with ESP-IDF, flash it to an ESP32-C3 DevKit, provision it through the ESP RainMaker Home app, and verify every control — from app sliders to physical button presses."
---

With the driver implemented, you are ready to build the project, flash it to the ESP32-C3 DevKit, and verify end-to-end cloud connectivity through the RainMaker phone app.

## Build and Flash

```bash
cd rainbow-led-studio        # directory where you extracted the zip
idf.py set-target esp32c3
idf.py build
idf.py -p /dev/cu.usbserial-XXXX flash monitor
```

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
Replace `/dev/cu.usbserial-XXXX` with your actual serial port. On Linux it will typically be `/dev/ttyUSB0` or `/dev/ttyACM0`.
{{< /alert >}}

On the first build the Component Manager automatically downloads `espressif/led_strip` and `espressif/button`. Subsequent builds use the cached components.

## Provision with the Phone App

1. Open the [**ESP RainMaker Home App**](https://docs.rainmaker.espressif.com/docs/product_overview/technical_overview/components/#reference-phone-app).
2. Log in and tap **+** → **Add Device**.
3. Scan the QR code shown in the serial monitor, or enter the proof-of-possession (PoP) manually.
4. Follow the Wi-Fi provisioning steps.

Once provisioned, the **Rainbow LED** device appears in the app with three controls:

| Control | Type | Range |
|---|---|---|
| Power | Toggle | On / Off |
| Brightness | Slider | 0 – 100 |
| Cycle Speed | Slider | 1 – 10 |

## Test Hardware Interactions

Verify that every path — app to device and device to app — works correctly:

| Action | Expected result |
|---|---|
| Tap **Power** in app | LED turns on/off |
| Drag **Brightness** slider | LED dims or brightens |
| Drag **Cycle Speed** slider | Rainbow cycles faster or slower |
| Press BOOT button once | LED toggles; app Power toggle updates |
| Hold BOOT button 1 s | Speed and Brightness randomise; sliders update in app |

## Data Model Reference

| Item | Value |
|---|---|
| Node name | `Node` |
| Node type | `rainbowled` |
| Device name | `Rainbow LED` |
| Device type | `esp.device.rainbow` |

| Parameter | RainMaker type | Data type | Default | UI |
|---|---|---|---|---|
| Power | `esp.param.power` | bool | `false` | Toggle |
| Brightness | `esp.param.brightness` | int | `30` | Slider 0–100 |
| Cycle Speed | `esp.param.cycle_speed` | int | `5` | Slider 1–10, step 1 |

## Why This Approach Scales

### Rapid prototyping

Studio eliminates the most time-consuming part of starting a new RainMaker firmware project — writing all the initialisation boilerplate. A developer goes from blank canvas to a compilable project with full cloud connectivity, provisioning, OTA, and scheduling in minutes, not hours.

### Hardware-first teams

Teams that are strong on hardware but new to RainMaker can define their product's data model visually without needing to understand every RainMaker API. The generated code is clean, readable, and an ideal learning reference as well as a working starting point.

### Custom device types

While standard types (Switch, Light Bulb, Fan, Sensor) are one drag-and-drop away, Studio's **Custom** device and **Custom** parameter types give you full flexibility to model novel products — a robot, an irrigation controller, a custom audio device — with any parameter types and UI widgets you need.

### Prototype to product, same model

The data model you define in Studio is the same model that runs in production on your private ESP RainMaker instance. There is no rework or translation step. You start with Studio, validate on public RainMaker, then carry the same `idf_component.yml`, partition tables, and data model definitions forward into your product firmware.

## Conclusion

Congratulations — you have completed the ESP RainMaker Studio workshop!

You designed a custom device data model visually, had a full ESP-IDF project generated for you, implemented only the hardware-specific driver code, and validated end-to-end cloud connectivity from phone app to physical LED.

The same workflow applies to any product you build with ESP RainMaker: define the model in Studio, fill in the driver, ship.

> [Go back to the workshop overview](../)
