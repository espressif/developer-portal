---
title: "Assignment 3: ESP-NOW Communication - Receiver"
date: 2025-10-17T00:00:00+01:00
showTableOfContents: true
series: ["WS00M"]
series_order : 4
showAuthor: false
---

Navigate to `workshops/2025-10-17` directory and open Assignment 3 - Receiver in the MicroPython Jupyter Notebook browser interface.

If prompted with selecting kernel, select `Embedded Kernel`, click on the ESP Control Panel and connect your device.

In this assignment, you will be to receive Morse code sent by the sender and display it on an LED. To do this, you will need to initialize the ESP-NOW communication protocol and set up a callback function to handle incoming messages. The sender will need your MAC address to send the Morse code. You can obtain it by initializing your station interface and running `print(sta.config('mac'))` (see [Task 1](#task-1-initialize-receiver))

## Task 1: Initialize Receiver

In this task, you’ll set up the chip as a Wi-Fi station and retrieve its MAC address.
This MAC address will be used by the sender device to target your board when sending data.

```python
# Setup Wi-Fi and ESP-NOW
sta = network.WLAN(network.STA_IF)
sta.active(True)

# Get and print MAC address
print("My MAC address:", sta.config('mac'))
```

## Task 2: Initialize addressable LED

Here you’ll set up the addressable LED to visualize incoming Morse code signals.

```python
# Setup addressable LED
neopixel_led = neopixel.NeoPixel(machine.Pin(2), 1)
```

## Task 3: Initialize ESP-NOW

Now you’ll initialize the ESP-NOW communication protocol, which allows direct device-to-device messaging without Wi-Fi networking.
You’ll also define timing constants that control how long each LED flash lasts.

```python
# Initialize ESP-NOW
e = espnow.ESPNow()
e.active(True)

# Timing constants
DOT_TIME = 0.2   # Green LED duration
DASH_TIME = 0.6  # Red LED duration
PAUSE = 0.2      # Gap after symbol
```

## Task 4: LED Display Functions

In this task, you’ll implement helper functions to show Morse code visually.
Dots will flash green for a short time, dashes will flash red for longer, and each symbol will include a short pause after it.

```python
def set_color(r, g, b):
    """Set the addressable LED to a specific RGB color"""
    neopixel_led[0] = (r, g, b)
    neopixel_led.write()

def clear_led():
    """Turn off the addressable LED"""
    set_color(0, 0, 0)

def blink_dot():
    """Display dot: green LED"""
    set_color(0, 255, 0)
    time.sleep(DOT_TIME)
    clear_led()

def blink_dash():
    """Display dash: red LED"""
    set_color(255, 0, 0)
    time.sleep(DASH_TIME)
    clear_led()

def blink_morse_symbol(symbol):
    """
    Display the received Morse symbol with appropriate color and timing.
    Includes pause after each symbol.
    """
    if symbol == ".":
        blink_dot()
    elif symbol == "-":
        blink_dash()

```

## Task 5: Receive Morse Code

Finally, you’ll write the main loop that waits for incoming ESP-NOW messages.
Each received symbol (dot or dash) is decoded, printed, and displayed on the LED.

```python
print("Morse Code Receiver ready...")
print("Dot = Green LED, Dash = Red LED")

while True:
    host, msg = e.recv(0)  # Non-blocking receive
    if msg:
        symbol = msg.decode()
        print("Received:", symbol)
        blink_morse_symbol(symbol)

        time.sleep(PAUSE)
```

## Bonus Challenge

Extend the receiver to decode complete Morse code letters and display them. You can use a dictionary mapping Morse patterns (e.g., ".-" → "A") to actual text output.

#### Next step

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Click on the ESP Control Panel and `Disconnect device` the device from the Jupyter notebook.
{{< /alert >}}

> Next step: [Assignment 4](../assignment-4/).
