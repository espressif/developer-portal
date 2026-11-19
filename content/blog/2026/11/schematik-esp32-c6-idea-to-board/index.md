---
title: "Schematik: from a one-line idea to an ESP32-C6 touchscreen gadget"
date: 2026-11-24
summary: "This article follows one project built in Schematik, a web app that plans parts, pins, wiring and firmware from a plain-language description, on the Waveshare ESP32-C6-Touch-LCD-1.47. It shows how pins are chosen against the chip's strapping, USB and ADC constraints, how the Arduino firmware is compiled, how it runs in a browser simulator, and how it is flashed to the real board from Chrome. It also lists which Espressif SoCs each step supports."
tags:
  - Arduino
  - AI
  - web app
  - simulation
  - tutorial
authors:
  - "jack-dunn"
---

[Schematik](https://www.schematik.io/) is a web app for building hardware projects. You describe a gadget in plain language. Schematik picks the board and parts, assigns pins, draws the wiring and writes the firmware. You can then run that firmware in a simulator in the browser and flash it to a real board over USB.

In this article we follow one published project from idea to running hardware: Tiny ESP DeskBuddy, a small desk dashboard on the Waveshare ESP32-C6-Touch-LCD-1.47. We look at each step from the chip's point of view: which pins are safe to use, what the firmware is compiled with, what the simulator runs and how flashing works.

## Which Espressif chips are supported where

Support differs by step, so here it is in one place.

| Step | ESP32 | ESP32-S3 | ESP32-C3 | ESP32-C6 | ESP32-S2, ESP32-P4 |
|---|---|---|---|---|---|
| Arduino firmware | Yes | Yes | Yes | Yes | Yes |
| ESPHome firmware | Yes | Yes | Yes | Yes | Yes |
| Native ESP-IDF firmware | Verified boards | Verified boards | No | No | No |
| Browser simulator, Arduino and ESPHome | Yes | Yes | Yes | Yes | No |
| Browser simulator, ESP-IDF | Verified boards | Verified boards | No | No | No |
| USB flashing from Chrome or Edge | Yes | Yes | Yes | Yes | Yes |

Arduino is the default. Boards without a simulator profile can still be built and flashed. ESP8266 boards are also supported for building and flashing.

## The project

DeskBuddy runs on a single board with no external wiring. The Waveshare ESP32-C6-Touch-LCD-1.47 has a 172×320 LCD on SPI, an AXS5106L capacitive touch controller and a QMI8658 IMU, both on I2C. The firmware:

- draws a monochrome face that changes expression when you tap it
- moves the eyes as you tilt the board, using the IMU
- pages between a clock, date, weather, moon phase, a stock quote and GitHub stats when you swipe
- fetches weather from Open-Meteo over Wi-Fi, using credentials in a `secrets.h` file

The [DeskBuddy project page](https://www.schematik.io/projects/build-an-esp-c6-touch-lcd-gadget) shows the full code, the parts list and the pin table. It is public and needs no account. The **Open in Schematik** button on that page copies the project into the editor after you sign in. Schematik is free to start building in the browser, with sign-in required to save and deploy projects.

{{< figure
    default=true
    src="img/deskbuddy-on-desk.webp"
    alt="The Waveshare ESP32-C6-Touch-LCD-1.47 in a blue case next to a laptop keyboard, showing a winking face on its screen"
    caption="DeskBuddy running on the Waveshare ESP32-C6-Touch-LCD-1.47"
    >}}

## Step 1: Describe the idea

A new project starts with one or two sentences in the editor, for example:

> A tiny desk companion on the Waveshare ESP32-C6 touch LCD: a face that reacts when I tap it, and swipe pages for the time, weather and my GitHub followers.

From a request like this, Schematik plans the build. It chooses the board and parts, writes a pin table and generates the firmware. The parts, pin table and wiring appear in the editor, where you can review and change them.

## Step 2: Pins checked against the chip

Most of the work in a reliable ESP32 project is pin selection. Schematik keeps a record for each board. The record lists which GPIOs reach a header, what each one is wired to on the board and which ones the chip needs for itself. When the agent assigns pins, it validates them against that record. The checks catch:

- GPIOs that don't exist or aren't routed to a pin you can reach
- boot, strapping, USB and serial pins
- functions the pin can't perform
- one pin used twice
- required pins left unconnected

The same checks run again before the project is accepted, so a failed check sends the agent back to fix the wiring.

For the ESP32-C6 on this board, the record captures these constraints:

- **Strapping pins.** On the ESP32-C6, GPIO4, GPIO5, GPIO8, GPIO9 and GPIO15 are strapping pins. GPIO9 is the BOOT button, and it must be low at reset for download mode, with GPIO8 high. The record marks both as boot pins, so a sensor or button is never placed there. Waveshare's own wiring uses GPIO15 for the LCD data/command line, which is fine because the board owns that pin. The record reserves it, and no other part can be assigned to it.
- **USB pins.** GPIO12 and GPIO13 are the USB D- and D+ lines to the USB-C connector. The ESP32-C6 has a built-in USB Serial/JTAG controller, and this board flashes and prints serial output through it. Putting anything else on those pins would cut you off from the board, so they are reserved.
- **ADC.** The ESP32-C6 has a single ADC unit, ADC1, on GPIO0 to GPIO6. On this board all seven are already taken: GPIO0 reads the battery voltage, and GPIO1 to GPIO6 drive the LCD, the microSD slot and the IMU interrupts. If you ask for an analog sensor, the checks report it instead of placing it on a pin that is already in use.
- **3.3 V logic.** ESP32 GPIOs are 3.3 V and not 5 V tolerant. The electrical rule check compares each part's logic level with the board's I/O voltage. It flags a 5 V part wired straight to a GPIO, and it flags an analog input that could exceed the ADC range. If a level shifter is in the parts list, the check notes it and moves on.

On the ESP32-S3 the ADC question is different. ADC2 (GPIO11 to GPIO20) is shared with the Wi-Fi driver, so readings can fail while Wi-Fi is active. On a Wi-Fi project, put analog inputs on ADC1 (GPIO1 to GPIO10). GPIO19 and GPIO20 are also the S3's USB lines, and the ESP32-S3-DevKitC-1 record reserves them for that.

DeskBuddy only uses the board's onboard parts, so its pin table is the board's fixed wiring:

| Signal | GPIO |
|---|---|
| LCD SCK, MOSI | 1, 2 |
| LCD CS, DC, RST, backlight | 14, 15, 22, 23 |
| Touch and IMU SDA, SCL | 18, 19 |
| Touch reset, interrupt | 20, 21 |

If you extend the project with an external part, GPIO7 is the free header pin the record recommends first. It is also the default chip select for an external SPI device.

## Step 3: Compile

Firmware is compiled on Schematik's servers. Nothing needs to be installed locally. For this board, the build uses PlatformIO with the pioarduino platform 55.03.38-1, which is [Arduino core for ESP32](https://docs.espressif.com/projects/arduino-esp32/en/latest/index.html) 3.3.8 on ESP-IDF v5.5.4. The board's build flags turn on the native USB CDC port at boot:

```ini
-DARDUINO_USB_MODE=1
-DARDUINO_USB_CDC_ON_BOOT=1
```

Without `ARDUINO_USB_CDC_ON_BOOT`, the firmware runs but the serial monitor stays empty. This is the most common reason a new ESP32-C6 sketch appears silent.

Two other runtimes use the same compile service:

- **ESPHome** projects build with ESPHome 2026.6.5.
- **Native ESP-IDF** projects build with [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/v5.5.4/) v5.5.4, with ccache enabled. These projects use the `main/` component layout and are available on ESP32 and ESP32-S3 boards with a verified native build profile.

DeskBuddy uses three libraries: GFX Library for Arduino for the LCD, ArduinoJson for the API responses and FastIMU for the QMI8658. The touch driver is written inline in the sketch.

## Step 4: Run it in the browser

The simulator is built on [esp32sim](https://github.com/schematik-engineering/esp32sim), an open-source emulator. It boots the chip's mask ROM and the real second-stage bootloader, then runs the compiled firmware unmodified.

To run DeskBuddy:

1. In the editor, open the **Preview** tab. The board and its parts appear on a 3D workbench.
2. Click **Run**. The first run takes a minute or two while the firmware compiles.
3. When the face appears on the LCD, use the touch controls in the side panel to tap or press at a point on the screen. Each tap changes the face's expression.
4. Open **Serial monitor** at the bottom right to see the firmware's log lines.

{{< figure
    default=true
    src="img/preview-touch.webp"
    alt="Schematik's Preview tab showing the ESP32-C6 board's LCD with the DeskBuddy face, and a side panel with touch X and Y sliders and Tap, Press and Release buttons"
    caption="DeskBuddy in Preview. The side panel sends touch events to the emulated AXS5106L controller."
    >}}

The simulated board joins a virtual Wi-Fi network with the SSID and password in your code. It can make public HTTP and HTTPS requests, so pages that call a public API, like the weather page, can fetch live data inside the simulation.

We compared simulator runs with the real boards on our own projects. For a set of 12 OLED builds, the simulator closely matched the real board, down to the scenes, text and timing. On this C6 board's colour LCD, the layout and motion matched, but the colours looked different on camera. The simulator runs firmware and does not model voltage or current, so wiring mistakes such as a missing resistor still need the electrical rule check from Step 2.

## Step 5: Flash the real board from Chrome

Flashing uses [esptool-js](https://github.com/espressif/esptool-js) over Web Serial. It works in Chrome and Edge on a computer.

1. Connect the board's USB-C port with a cable that carries data.
2. Click **Deploy**.
3. In the browser's port dialog, select the board's USB serial port and click **Connect**.

Schematik compiles the firmware, writes it over USB and resets the board. Here is the end of a real Deploy log from flashing DeskBuddy to this board from Chrome on a Mac:

```text
Wrote 1255600 bytes (761599 compressed) at 0x10000 in 4.199 seconds.
Leaving...
[verifying] 95% — Verifying and resetting...
[done] 100% — Flash complete! Board is resetting...
Connected (115200 baud)
ESP32-C6 DeskBuddy starting
Touch controller initialised
```

The serial output after the reset appears in the same log. If the log stops at `Connecting`, put the chip into download mode by hand:

1. Hold **BOOT**.
2. Press and release **RESET**.
3. Release **BOOT**.
4. Click **Deploy** and select the port again.

Native USB boards such as the ESP32-S3, ESP32-C3 and ESP32-C6 can reappear under a new port name after this. If the board stays in download mode after flashing, press **RESET**.

Safari has no Web Serial, so on Safari the Deploy button offers the firmware file or the Schematik desktop app for macOS instead. The [web flasher page](https://www.schematik.io/flash) has the steps for other boards and browsers.

## Try it

To see the finished project, open the [DeskBuddy project page](https://www.schematik.io/projects/build-an-esp-c6-touch-lcd-gadget). It shows the code, parts and pin table. Click **Open in Schematik** to copy it into the editor, then click **Preview** and **Run** to start the simulation. If you have the Waveshare board, plug it in and click **Deploy**. For other ESP32-C6 and ESP32-S3 builds, the [ESP32 projects page](https://www.schematik.io/projects/esp32) lists community projects you can open the same way.
