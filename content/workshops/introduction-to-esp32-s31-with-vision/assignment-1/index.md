---
title: "Introduction to the ESP32-S31 with Vision: Assignment 1"
date: 2026-09-28
showTableOfContents: true
series: ["ESP32-S31-VISION"]
series_order: 5
showAuthor: false
---

## Let's blink

In this assignment, you will create a small hardware application. The onboard RGB LED will blink red for five times and then will stay off. You can enter the provided code manually or optionally use an MCP-enabled coding assistant to generate it.

Although blinking an LED is simple, the exercise verifies three important details: the selected board, the correct GPIO, and an API that exists in its MicroPython firmware.

> [!TIP]
> Create and run the script with the [ESP-Vision Web IDE](https://vision.espressif.com/en).

## The ESP32-S31-Korvo-1 RGB LED

The board has one WS2812-compatible addressable RGB LED on **GPIO37**. A WS2812 receives serialized color data, so treating the pin as a normal on/off GPIO does not produce a stable color.

The current ESP-Vision firmware does not include the optional MicroPython `neopixel` helper module. Instead, use the built-in `machine.bitstream` function to transmit the WS2812 waveform:

```python
bitstream(pin, 0, (400, 850, 800, 450), data)
```

The timing tuple specifies the high and low periods for zero and one bits in nanoseconds. The LED expects color bytes in **GRB** order.

## Step 1: Create the application

Create a file named `led_blink.py`. You do not need an AI coding agent or MCP server to complete this assignment; you can type or copy the verified code in Step 2.

If you want to practice the optional [ESP-Vision MCP workflow](../tooling-mcp), ask your MCP-enabled coding assistant to generate the file with this prompt:

```text
Use the ESP-Vision MCP server before writing code.

Target: ESP32-S31-Korvo-1 running ESP-Vision MicroPython.
Create one self-contained led_blink.py file that blinks the onboard
addressable RGB LED on GPIO37 red five times. Use only APIs verified for
esp32s31. Use machine.Pin and machine.bitstream; do not import neopixel.
Always switch the LED off in a finally block and print LED_TEST:OK only
after all five blinks complete.
```

The hardware, runtime, bounded behavior, cleanup, and success condition are explicit. This gives the assistant less room to make unsafe assumptions.

## Step 2: Add and review the code

Enter the following verified code. If an agent generated your script, compare its output with this structure before running it:

```python
from machine import Pin, bitstream
import time


LED_PIN = 37
BLINKS = 5
RED = (32, 0, 0)
OFF = (0, 0, 0)
WS2812_TIMING = (400, 850, 800, 450)


def set_color(pin, color):
    red, green, blue = color
    bitstream(pin, 0, WS2812_TIMING, bytes((green, red, blue)))
    time.sleep_us(80)


def main():
    led = Pin(LED_PIN, Pin.OUT)
    try:
        for _ in range(BLINKS):
            set_color(led, RED)
            time.sleep_ms(300)
            set_color(led, OFF)
            time.sleep_ms(300)
    finally:
        set_color(led, OFF)

    print("LED_TEST:OK")


main()
```

`RED` uses a deliberately modest intensity. Full brightness is unnecessary for a status LED and can be uncomfortable to look at.

The `finally` block runs whether the loop completes or an exception interrupts it. It prevents the LED from remaining on after most runtime errors.

## Step 3: Run and test

1. Connect to the board in the ESP-Vision Web IDE.
2. Create `led_blink.py`.
3. Paste the reviewed code.
4. Save and run the script.

The LED should blink red exactly five times. The REPL should then print:

```text
LED_TEST:OK
```

If the LED does not light up:

- Confirm that the target is ESP32-S31-Korvo-1.
- Confirm `LED_PIN = 37`.
- If you see `ImportError: no module named 'neopixel'`, use the `machine.bitstream` version above rather than importing `neopixel`.
- Ensure that no previously flashed native ESP-IDF application is still controlling the LED.
- Reset the board and reconnect the Web IDE.

## Exercise: Change the blink pattern

Modify the program to show this sequence:

1. Red for 500 ms
2. Green for 500 ms
3. Blue for 500 ms
4. Repeat the RGB sequence three times
5. Off

Keep each RGB channel at 64 or below. Add a `STATUS_TEST:OK` marker after the full sequence completes.

Suggested colors:

```python
RED = (32, 0, 0)
GREEN = (0, 32, 0)
BLUE = (0, 0, 32)
```

## Complete working code

<details><summary>Show the complete led_blink.py with the exercise pattern</summary>

```python
from machine import Pin, bitstream
import time


LED_PIN = 37
CYCLES = 3
RED = (32, 0, 0)
GREEN = (0, 32, 0)
BLUE = (0, 0, 32)
OFF = (0, 0, 0)
WS2812_TIMING = (400, 850, 800, 450)


def set_color(pin, color):
    red, green, blue = color
    bitstream(pin, 0, WS2812_TIMING, bytes((green, red, blue)))
    time.sleep_us(80)


def main():
    led = Pin(LED_PIN, Pin.OUT)
    try:
        for _ in range(CYCLES):
            for color in (RED, GREEN, BLUE):
                set_color(led, color)
                time.sleep_ms(500)
    finally:
        set_color(led, OFF)

    print("STATUS_TEST:OK")


main()
```

</details>

## What you learned

In this assignment, you:

- Created the application manually or optionally with an MCP-enabled coding assistant
- Controlled the onboard WS2812-compatible LED with `machine.bitstream`
- Reviewed generated code for the correct pin, bounded behavior, and cleanup
- Used an observable success marker to distinguish completion from startup

## Next step

[Assignment 2: Your first camera application](../assignment-2)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-with-vision/)
