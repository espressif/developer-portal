---
title: "Assignment 1: Blink - Control the addressable LED"
date: 2025-10-17T00:00:00+01:00
showTableOfContents: true
series: ["WS00M"]
series_order : 2
showAuthor: false
---

In this assignment you will initialize and control the onboard addressable LED in three different ways.

## Understanding addressable LEDs

WS2812 are individually addressable RGB LEDs. Each LED can display any color by mixing red, green, and blue values (0-255 each). The ESP32-C3-DevKit-RUST-2 board has one addressable LED on GPIO 2.

Work through the following tasks in your Assignment 1 Jupyter notebook:

## Task 1: Initialize the addressable LED
In this task, you’ll set up the addressable LED so your code can communicate with it. The `neopixel.NeoPixel(machine.Pin(2), 1)` line tells the chip which pin the LED is connected to (GPIO 2) and how many LEDs are being controlled (1 in this case).

```python
neopixel_led = neopixel.NeoPixel(machine.Pin(2), 1)
```

## Task 2: Set the Solid Colors

Here, you’ll write helper functions to change the LED’s color.
The `set_color()` function lets you set any RGB color by adjusting red, green, and blue brightness values from 0–255.
The `clear_led()` function turns the LED off.
You’ll then test the LED by cycling through a few example colors.


```python
def set_color(r, g, b):
    """Set the addressable LED to a specific RGB color"""
    neopixel_led[0] = (r, g, b)
    neopixel_led.write()

def clear_led():
    """Turn off the LED"""
    set_color(0, 0, 0)


# Try different colors
set_color(255, 0, 0)  # Red
time.sleep(1)
set_color(0, 255, 0)  # Green
time.sleep(1)
set_color(0, 0, 255)  # Blue
time.sleep(1)
set_color(255, 255, 0)  # Yellow
time.sleep(1)
clear_led()
```

## Task 3: Rainbow cycle effect

This task adds a simple animation.
You’ll create a rainbow_cycle() function that loops through a list of predefined colors — red, orange, yellow, green, blue, indigo, and violet — so the LED smoothly transitions through the rainbow spectrum.

```python
def rainbow_cycle():
    """Cycle through rainbow colors"""
    colors = [
        (255, 0, 0),    # Red
        (255, 127, 0),  # Orange
        (255, 255, 0),  # Yellow
        (0, 255, 0),    # Green
        (0, 0, 255),    # Blue
        (75, 0, 130),   # Indigo
        (148, 0, 211)   # Violet
    ]

    for color in colors:
        set_color(*color)
        time.sleep(0.3)
    clear_led()

rainbow_cycle()
```

## Task 4: Breathing Effect

Now you’ll create a more dynamic lighting effect.
The breathing_effect() function gradually fades the LED in and out using brightness scaling, giving a “breathing” glow.
You can adjust the color, duration, and smoothness by changing the parameters.

```python
def breathing_effect(r, g, b, duration=2, steps=50):
    """
    Create a breathing effect with the specified color
    """
    step_delay = duration / (steps * 2)

    # Fade in
    for i in range(steps):
        brightness = i / steps
        set_color(int(r * brightness), int(g * brightness), int(b * brightness))
        time.sleep(step_delay)

    # Fade out
    for i in range(steps, 0, -1):
        brightness = i / steps
        set_color(int(r * brightness), int(g * brightness), int(b * brightness))
        time.sleep(step_delay)

    clear_led()

breathing_effect(0, 100, 255)
```

#### Next step

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Click on the ESP Control Panel and `Disconnect device` the device from the Jupyter notebook.
{{< /alert >}}


> Next step: [Assignment 2](../assignment-2/).
