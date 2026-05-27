---
title: "Inkplate: Open-Source ESP32 E-Paper Development Boards"
date: "2026-05-25"
summary: "Inkplate is a family of all-in-one, open-source e-paper development boards built around the ESP32. This article introduces the Inkplate lineup, covers the hardware, the Arduino and MicroPython libraries, and the kinds of projects you can build — and explains why ESP32 makes e-paper development accessible for everyone."
authors:
  - "borna-zelenika"
tags:
  - development board
  - Arduino
  - community contribution
  - e-paper
  - MicroPython
  - low power
---

## What is Inkplate?

[Inkplate](https://soldered.com/inkplate/) is a family of ready-to-use e-paper development boards made by [Soldered Electronics](https://soldered.com/), a hardware company based in the EU. Each board ships with a genuine e-paper display, an ESP32 microcontroller, an onboard battery charger, a real-time clock (RTC), a microSD slot, and a Qwiic expansion connector — everything integrated and ready to program out of the box.

What makes Inkplate unique is its sustainability angle: most displays are **recycled from decommissioned e-readers**. This keeps costs down, reduces e-waste, and means you get a real-world-tested screen with no soldering or driver board fiddling required. Just plug in USB-C and start writing code.

## Why ESP32?

The ESP32 is the microcontroller at the heart of nearly every Inkplate model, and it is an ideal fit for e-paper applications:

- **Wi-Fi + Bluetooth** — Inkplate boards can fetch live data (weather, calendar events, news, stock prices) over Wi-Fi and display it on a screen that consumes zero power to hold the image.
- **Deep sleep as low as 18–25 µA** — Combined with e-paper's zero-power image retention, a battery-powered Inkplate can run for **weeks or months** on a single charge.
- **Arduino IDE and MicroPython support** — The official Inkplate Arduino library is Adafruit GFX compatible, so any developer familiar with the Arduino ecosystem can get started in minutes.
- **Rich peripheral support** — I²C, SPI, UART, and the Qwiic connector make it easy to attach sensors, actuators, and other modules.

## The Inkplate Lineup

Soldered offers a range of models to match different project needs:

| Model | Screen | Resolution | Highlights |
|---|---|---|---|
| **Inkplate 2** | 2.13″ | 202×104 | Tri-color (B/W/Red), tiny form factor |
| **Inkplate 4TEMPERA** | 3.8″ | 600×600 | Touchscreen, frontlight, 0.18 s fast refresh |
| **Inkplate 5V2** | 5.2″ | 1280×720 | High resolution, 0.26 s fast refresh |
| **Inkplate 6** | 6.0″ | 800×600 | Classic workhorse, 8 grayscale levels |
| **Inkplate 6FLICK** | 6.0″ | 1024×758 | Multi-touch, 64-step frontlight, 0.23 s fast refresh |
| **Inkplate 6COLOR** | 5.8″ | 600×448 | 7-color e-paper (B/W/Red/Yellow/Green/Blue/Orange) |
| **Inkplate 10** | 9.7″ | 1200×825 | Largest display, great for dashboards |
| **Inkplate 6MOTION** | 6.0″ | 1024×758 | 16 grayscale levels, 91 ms partial refresh (up to 11 FPS) |

All models share these traits: open-source hardware and software, USB-C, Li-Ion battery support with onboard charger, RTC (PCF85063A), Qwiic connector, and are designed and manufactured in the EU.

### Inkplate 6MOTION — A Special Case

The 6MOTION is the most powerful board in the lineup. Unlike the others, it uses a **dual-processor architecture**: an STM32H743 handles the display and peripherals at high speed, while an **ESP32-C3 acts as the Wi-Fi and Bluetooth co-processor**. It achieves a **91 ms partial refresh** — fast enough for smooth animations and interactive UI at up to 11 FPS on e-paper, which is a significant breakthrough for this display technology.

On top of that, it packs:
- LSM6DSO32 accelerometer + gyroscope
- APDS-9960 gesture & proximity sensor
- SHTC3 temperature & humidity sensor
- Rotary encoder with backlit indicator
- 2× WS2812B RGB LEDs
- 3× side push buttons
- 30+ GPIO pins

## Getting Started

All Inkplate models are supported by the [Inkplate Arduino Library](https://github.com/SolderedElectronics/Inkplate-Arduino-library), which abstracts the e-paper driver and exposes a simple, Adafruit GFX-compatible API.

### 1. Install the board definition

In Arduino IDE, add the following URL to *File → Preferences → Additional Boards Manager URLs*:

```
https://github.com/SolderedElectronics/Dasduino-Board-Definitions-for-Arduino-IDE/raw/master/package_Dasduino_Boards_index.json
```

Then open *Tools → Board → Boards Manager*, search for **Inkplate Boards**, and install.

### 2. Hello World

```cpp
#include "Inkplate.h"

Inkplate display(INKPLATE_1BIT);

void setup() {
    display.begin();
    display.clearDisplay();
    display.setCursor(100, 100);
    display.setTextSize(5);
    display.print("Hello, World!");
    display.display();
}

void loop() {}
```

### 3. Fetching live data over Wi-Fi

Because ESP32 Wi-Fi is natively available, pulling live data is straightforward. This example fetches a weather summary and displays it, then goes to deep sleep for 30 minutes:

```cpp
#include "Inkplate.h"
#include <WiFi.h>
#include <HTTPClient.h>

Inkplate display(INKPLATE_1BIT);

void setup() {
    display.begin();
    WiFi.begin("your-ssid", "your-password");
    while (WiFi.status() != WL_CONNECTED) delay(500);

    HTTPClient http;
    http.begin("http://wttr.in/?format=3");
    if (http.GET() == HTTP_CODE_OK) {
        display.clearDisplay();
        display.setCursor(10, 10);
        display.setTextSize(3);
        display.print(http.getString());
        display.display();
    }
    http.end();

    // Deep sleep for 30 minutes, then wake up and refresh
    esp_sleep_enable_timer_wakeup(30ULL * 60 * 1000000);
    esp_deep_sleep_start();
}

void loop() {}
```

## MicroPython Support

Most Inkplate models also support MicroPython via the [Inkplate MicroPython library](https://github.com/SolderedElectronics/Inkplate-micropython). After flashing the provided firmware, you can drive the display with familiar Python syntax:

```python
from inkplate6 import Inkplate

display = Inkplate()
display.begin()
display.clearDisplay()
display.printText(10, 10, "Hello from MicroPython!")
display.display()
```

## Project Ideas

The combination of ESP32, Wi-Fi, ultra-low power consumption, and a sunlight-readable e-paper display opens up a wide range of applications:

- **Smart home dashboard** — display temperature, energy usage, or Home Assistant data; update every few minutes while sleeping in between
- **E-reader** — load text files from microSD or a web server and display them page by page
- **Weather station** — fetch data from Open-Meteo or OpenWeatherMap and render a multi-day forecast
- **Google Calendar display** — show upcoming events on your desk, powered by a small battery for months
- **AI image frame** — use the OpenAI API to generate a new image daily and display it as a "digital painting"
- **IoT sensor node** — attach I²C sensors via Qwiic and report readings to an MQTT broker or cloud dashboard

Soldered's documentation includes complete, ready-to-run examples for several of these use cases — browse them in the [Inkplate Arduino library examples](https://github.com/SolderedElectronics/Inkplate-Arduino-library/tree/master/examples).

## Open Source

All Inkplate hardware designs (KiCad schematics and PCB layouts) and software are fully open source:

- **Arduino library & hardware files:** [github.com/SolderedElectronics](https://github.com/SolderedElectronics)
- **Full documentation:** [docs.soldered.com/inkplate](https://docs.soldered.com/inkplate)
- **Store:** [soldered.com/categories/inkplate](https://soldered.com/categories/inkplate/)

## Conclusion

Inkplate proves that e-paper development doesn't have to be complicated. By pairing the ESP32 with a recycled e-paper display and all the supporting hardware on a single board, Soldered has made it possible to go from idea to a working, Wi-Fi-connected, battery-powered display in an afternoon. Whether you're building a smart home panel, a minimalist e-reader, or pushing the limits with 11 FPS animations on the 6MOTION, Inkplate gives you the full power of the ESP32 ecosystem with the unique advantages of e-paper.
