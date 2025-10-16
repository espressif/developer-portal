---
title: "Assignment 3: ESP-NOW Communication - Sender"
date: 2025-10-17T00:00:00+01:00
showTableOfContents: true
series: ["WS00M"]
series_order : 4
showAuthor: false
---

Navigate to `workshops/2025-10-17` directory and open Assignment 3 - Sender in the MicroPython Jupyter Notebook browser interface.

If prompted with selecting kernel, select `Embedded Kernel`, click on the ESP Control Panel and connect your device.

In this assignment, you will send Morse code to the receiver based on the length of the button presses. Ask your partner for their MAC address and replace `<MAC_ADDRESS>` with it in your code. They can get this information by initializing station interface and running `print(sta.config('mac'))` (see [here](../assignment-3-receiver#task-1-initialize-receiver))

## Task 1: Initialize ESP-NOW

Set up your ESP32 as a Wi-Fi station and initialize ESP-NOW communication.
Add your partner’s MAC address as a peer so you can send Morse code directly to their board.

```python
# Create Wi-Fi station interface
sta = network.WLAN(network.STA_IF)
sta.active(True)

# Initialize ESP-NOW
e = espnow.ESPNow()
e.active(True)

# MAC address of receiver (replace <MAC_ADDRESS> receiver's MAC!)
peer_mac = b'<MAC_ADDRESS>'

# Try to delete any existing peer
try:
    e.del_peer(peer_mac)
except OSError:
    pass

e.add_peer(peer_mac)
```

## Task 2: Implement Morse Detection

Here you’ll configure the button and define functions to detect how long it’s pressed.
Short presses will be interpreted as dots, long presses as dashes.
Debouncing ensures that tiny accidental presses are ignored.

```python
# Button configuration
button = machine.Pin(9, machine.Pin.IN, machine.Pin.PULL_UP)

DOT_THRESHOLD = 0.3  # seconds
DEBOUNCE = 0.05

def wait_for_button_press():
    """Wait until button is pressed"""
    while button.value() == 1:
        time.sleep(0.05)

def measure_press_duration():
    """Measure how long the button is held down"""
    start = time.ticks_ms()
    while button.value() == 0:
        time.sleep(0.05)
    duration = time.ticks_diff(time.ticks_ms(), start) / 1000.0
    return duration

def determine_morse_symbol(duration):
    """Determine if press was dot or dash"""
    if duration < DEBOUNCE:
        return None
    symbol = '.' if duration < DOT_THRESHOLD else '-'
    return symbol

def send_morse_symbol(symbol):
    """Send morse symbol via ESP-NOW"""
    print("Sending:", symbol)
    e.send(peer_mac, symbol.encode())
```

Finally, you’ll write the main loop that waits for button presses, detects the duration, determines the Morse symbol, and sends it to the receiver.
The program prints each symbol for confirmation.

## Task 3: Send Morse Symbols

```python
print("Morse Code Sender Ready!")
print("Press button: short = dot (.), long = dash (-)")
print("Press the stop button on the toolbar to terminate the while loop.")

while True:
    # Wait for button press
    wait_for_button_press()

    # Measure duration
    duration = measure_press_duration()

    # Determine symbol
    symbol = determine_morse_symbol(duration)
    if symbol:
        # Send symbol via ESP-NOW
        send_morse_symbol(symbol)
```

#### Next step

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Click on the ESP Control Panel and `Disconnect device` the device from the Jupyter notebook.
{{< /alert >}}

> Next step: [Assignment 4](../assignment-4/).
