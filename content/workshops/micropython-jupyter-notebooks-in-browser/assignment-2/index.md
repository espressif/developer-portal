---
title: "Assignment 2: Button Input"
date: 2025-10-17T00:00:00+01:00
showTableOfContents: true
series: ["WS00M"]
series_order : 3
showAuthor: false
---

Navigate to `workshops/2025-10-17` directory and open Assignment 2 in the MicroPython Jupyter Notebook browser interface.

If prompted with selecting kernel, select `Embedded Kernel`, click on the ESP Control Panel and connect your device.

In this assignment, you will learn to read button inputs and generate interactive responses with LEDs.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
You will be configuring a `boot` button located on Pin 9.
{{< /alert >}}

## Understanding Pull-up Resistors

On the ESP32-C3-DevKit-RUST-2 board, pressing the **boot** button connects pin 9 to ground. When the button is not pressed, the pin is left floating, which leads to an undefined logic level. Pull-up resistors ensure that the pin maintains a defined logic high level when the button is released.

In summary:
* Button not pressed: GPIO reads HIGH (1) thanks to pull-up resistor.
* Button pressed: GPIO reads LOW (0) because the pin is connected to ground.

The ESP32-C3-DevKit-RUST-2 has internal pull-up resistors that can be enabled in software.

## Task 1: Configure button

In this task, you’ll initialize the onboard button so your program can read its state.
The pin is configured as an input (`machine.Pin.IN`) with an internal pull-up resistor (`machine.Pin.PULL_UP`).


```python
button = machine.Pin(9, machine.Pin.IN, machine.Pin.PULL_UP)
```

## Task 2: Simple Button Press Detection

Here you’ll write a function that waits until the button is pressed.
The loop continuously checks the pin’s value — when it changes from HIGH to LOW, the program detects a press and prints a message.

```python
def wait_for_button_press():
    """Wait until button is pressed"""
    while button.value() == 1:
        time.sleep(0.05)
    print("Button pressed!")
```

Now you’ll make the LED respond to button input.
Each time the button is pressed, the LED toggles between ON and OFF.
A small delay is added to handle “debouncing” — preventing multiple rapid triggers from one press.

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5">}}
“Bouncing” happens when you press a button and instead of sending a single clean signal, it wiggles a little and makes the system think you pressed it many times really fast. Debouncing is just a way to make the system listen to only one press, no matter how wobbly the button is.”
{{< /alert >}}


## Task 3: Toggle LED on Button Press

```python
led_state = False

while True:
    if button.value() == 0:  # Button pressed
        led_state = not led_state
        if led_state:
            set_color(255, 0, 0)
        else:
            clear_led()

        # Wait for button release (debounce)
        while button.value() == 0:
            time.sleep(0.05)
        time.sleep(0.1)  # Additional debounce delay
```

## Task 4: Measure Press duration

In this task, you’ll measure how long the button is held down.
The program records the start time when pressed and calculates the total duration once released.

```python
def measure_press_duration():
    """Measure how long the button is held down"""
    start = time.ticks_ms()
    while button.value() == 0:
        time.sleep(0.05)
    duration = time.ticks_diff(time.ticks_ms(), start) / 1000.0
    return duration

wait_for_button_press()
duration = measure_press_duration()
print(f"Button held for {duration:.2f} seconds")
```

## Bonus Challenge

Create a visual feedback based on duration.

Change LED color based on how long the button is pressed:
- Short press (< 1s): Blue
- Medium press (1-3s): Yellow
- Long press (> 3s): Red


#### Next step

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Click on the ESP Control Panel and `Disconnect device` the device from the Jupyter notebook.
{{< /alert >}}

> Next step: [Assignment 3](../assignment-3).
