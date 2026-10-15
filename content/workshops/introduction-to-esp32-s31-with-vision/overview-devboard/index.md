---
title: "Introduction to the ESP32-S31 with Vision: Overview of the ESP32-S31-Korvo-1 devboard"
date: 2026-09-28
showTableOfContents: true
series: ["ESP32-S31-VISION"]
series_order: 2
showAuthor: false
---

## The map for your board

The [ESP32-S31-Korvo-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-korvo-1/user_guide.html) is a multimedia development board built around the ESP32-S31-WROOM-3 module. It combines the camera, display, touch, audio, local storage, controls, and memory needed to prototype smart audio and vision products.

The installed module has 16 MB flash and 16 MB PSRAM. ESP32-S31-Korvo-1 boards can ship with either a 3-megapixel OV3660 DVP camera, supporting up to 2048 × 1536, or an SC101IOT DVP camera, supporting up to 1280 × 720. The package also includes a 4.3-inch, 800 × 480 LCD subboard. These are the primary peripherals used in this workshop.

## Board overview

{{< figure
    src="assets/esp32-s31-korvo-1-callouts.webp"
    alt="Annotated ESP32-S31-Korvo-1 V1.1 board showing its main components"
    caption="ESP32-S31-Korvo-1 V1.1 main components."
>}}

| Hardware | Details | Workshop use |
|----------|---------|--------------|
| Module | ESP32-S31-WROOM-3, PCB antenna, 16 MB flash, 16 MB PSRAM | Application, inference, and frame buffers |
| Camera | OV3660 up to 2048 × 1536, or SC101IOT up to 1280 × 720, over an 8-bit DVP interface | Captures face and hand images |
| LCD subboard | 4.3-inch, 800 × 480 parallel RGB display with GT1151 touch | Live camera view and overlays |
| RGB LED | Addressable LED on GPIO37 | Normal and intrusion status |
| Audio | Two analog microphones, ES8389 codec, two 3 W amplifiers | Available for future multimodal applications |
| Controls | PLAY, SET, VOL-, VOL+, Boot, and Reset | User input and recovery |
| Storage | 16 MB module flash plus optional 4-bit microSD, SDIO 3.0 capable | Stores scripts and models; microSD is reserved for large model files |
| USB | Type-C power, Type-C UART, and Type-A USB 2.0 Host | Power, flashing, logs, and USB devices |

### Block diagram

{{< figure
    src="assets/esp32-s31-korvo-1-block-diagram.webp"
    alt="Electrical block diagram of the ESP32-S31-Korvo-1 V1.1"
    caption="ESP32-S31-Korvo-1 V1.1 peripheral connections."
>}}

## Camera and display

The OV3660 and SC101IOT send pixels to the ESP32-S31 through eight parallel data signals plus pixel clock, frame synchronization, and line synchronization. ESP-Vision registers the installed camera as a V4L2-compatible video device through [`esp_video`](https://github.com/espressif/esp-video-components). The default camera configuration enables both sensors so `esp_video` can auto-detect the populated module at runtime.

The OV3660 supports resolutions up to 2048 × 1536, while the SC101IOT supports up to 1280 × 720. Workshop applications use lower frame sizes to reduce frame-buffer size and processing load for live display and inference.

The camera is mounted with a 180-degree board rotation. Applications that render the frame should account for this orientation when processing or displaying an image.

The LCD subboard uses a 16-bit parallel RGB data bus. Its GT1151 touch controller communicates over I2C. ESP-Vision provides APIs for displaying camera frames and graphics on the LCD without requiring you to configure these interfaces.

This division is important:

- The **camera driver** produces frames.
- The **PPA** can scale or rotate frames.
- [**ESP-DL**](https://github.com/espressif/esp-dl) performs inference.
- **LVGL** renders the frame and annotations.

## Audio, controls, and storage

The dual analog microphones and left/right speaker outputs connect through the ES8389 codec. Audio samples use TDM over I2S; codec control uses I2C. Each speaker output can drive a 4 Ω, 3 W speaker through an NS4150B amplifier.

> [!NOTE]
> The ESP32-S31 MCLK signal is not connected on this board. The board documentation recommends a 16 kHz audio sampling rate.

The four function buttons share an ADC input through a resistor divider. Each button produces a different voltage level that software can identify through a single ADC channel.

The RGB LED is a WS2812-compatible addressable LED controlled by GPIO37. It requires a color value rather than a simple high/low GPIO level.

The microSD slot uses the SDIO interface by default. Its GPIOs are shared with an unpopulated SPI NAND footprint, so both interfaces cannot be used simultaneously without hardware rework.

## Power, USB, and flashing

The board has two USB Type-C connectors:

| Connector | Power | Data |
|-----------|:-----:|------|
| Power | Yes | No |
| UART | Yes | USB-to-UART flashing and serial logs |

For normal workshop use, connect a data-capable cable to the **UART** connector and move the power switch to **ON**. Use the separate Power connector when the display, speakers, or a downstream USB device requires more current. Espressif recommends ensuring up to 3 A input capacity when high-power audio and USB Host power are used together.

The USB Type-A connector is connected to the ESP32-S31 USB 2.0 High-Speed OTG peripheral and can supply up to 500 mA in Host mode.

> [!IMPORTANT]
> When the USB Type-A connector is used in device mode with a Type-A to Type-A cable, it can also power the board. This supply bypasses the board's power switch, so moving the switch to **OFF** does not turn the board off. Disconnect the Type-A cable to fully remove power.

Automatic download normally uses the USB-to-UART bridge. If automatic download fails:

1. Hold **Boot**.
2. Press and release **Reset**.
3. Release **Boot**.
4. Retry the flash command.

## Resources

- [ESP32-S31-Korvo-1 User Guide](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-korvo-1/user_guide.html)
- [ESP32-S31 Datasheet](https://documentation.espressif.com/esp32-s31_datasheet_en.html)
- [ESP32-S31 product page](https://www.espressif.com/en/products/socs/esp32-s31)

## What you learned

In this overview, you learned:

- Which ESP32-S31-Korvo-1 peripherals support the vision exercises
- How the camera, display, touch controller, LED, audio codec, and microSD card connect to the SoC
- Which USB connector carries flashing and serial data
- How ESP-Vision simplifies access to the board's camera and display

## Next step

[Tooling: Getting started with ESP-Vision](../tooling-esp-vision)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-with-vision/)
