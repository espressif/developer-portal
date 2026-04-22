---
title: "TinyGo Embedded Workshop - Assignment 2: Blinky"
date: 2026-04-22T00:00:00+01:00
showTableOfContents: false
series: ["WS002EN"]
series_order: 3
showAuthor: false
---

## Assignment 2: Blinky

Blinking an LED is the "Hello, World!" of embedded development. In this assignment, you'll write your first TinyGo program to blink an LED.

## Understanding GPIO

GPIO (General Purpose Input/Output) pins are the interface between your microcontroller and the physical world. They can be:

- **Inputs**: Read digital signals (buttons, switches)
- **Outputs**: Control digital signals (LEDs, relays, motors)

### LED Basics

An LED (Light Emitting Diode) is a simple output device:
- **Anode (+)**: Connects to positive voltage through a resistor
- **Cathode (-)**: Connects to ground (GND)
- **Resistor**: Limits current (typically 220Ω-1kΩ)

**Digital Logic:**
- **HIGH (1)**: Pin outputs VCC (3.3V on ESP32)
- **LOW (0)**: Pin outputs GND (0V)

## Finding the LED Pin

Different boards have built-in LEDs on different pins:

{{< tabs groupId="board" >}}
  {{% tab name="M5Stack Core2" %}}
**M5Stack Core2 Built-in LED:**

- Pin: GPIO10
- Type: Active LOW (LED on when pin is LOW)

Also has an RGB LED on GPIO8 (requires PWM control).
  {{% /tab %}}

  {{% tab name="M5Stack StampC3" %}}
**M5Stack StampC3 Built-in LED:**

- Pin: GPIO10
- Type: Active LOW (LED on when pin is LOW)

RGB LED on GPIO2 (requires NeoPixel driver).
  {{% /tab %}}

  {{% tab name="XIAO-ESP32C3" %}}
**XIAO ESP32-C3 Built-in LED:**

- Pin: GPIO10
- Type: Active LOW (LED on when pin is LOW)

RGB LED on GPIO7 (requires NeoPixel driver).
  {{% /tab %}}
{{< /tabs >}}

## Creating Your Blinky Program

### Step 1: Create Project Directory

```bash
mkdir blinky
cd blinky
go mod init blinky
```

### Step 2: Write the Code

Create `main.go`:

{{< tabs groupId="board" >}}
  {{% tab name="M5Stack Core2" %}}
**main.go for M5Stack Core2:**

```go
package main

import (
    "machine"
    "time"
)

func main() {
    // M5Stack Core2: LED on GPIO10 (active LOW)
    led := machine.GPIO10
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    for {
        led.Low()  // LED ON (active LOW)
        time.Sleep(time.Millisecond * 500)

        led.High() // LED OFF
        time.Sleep(time.Millisecond * 500)
    }
}
```
  {{% /tab %}}

  {{% tab name="M5Stack StampC3" %}}
**main.go for M5Stack StampC3:**

```go
package main

import (
    "machine"
    "time"
)

func main() {
    // M5Stack StampC3: LED on GPIO10 (active LOW)
    led := machine.GPIO10
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    for {
        led.Low()  // LED ON (active LOW)
        time.Sleep(time.Millisecond * 500)

        led.High() // LED OFF
        time.Sleep(time.Millisecond * 500)
    }
}
```
  {{% /tab %}}

  {{% tab name="XIAO-ESP32C3" %}}
**main.go for XIAO ESP32-C3:**

```go
package main

import (
    "machine"
    "time"
)

func main() {
    // XIAO ESP32-C3: LED on GPIO10 (active LOW)
    led := machine.GPIO10
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    for {
        led.Low()  // LED ON (active LOW)
        time.Sleep(time.Millisecond * 500)

        led.High() // LED OFF
        time.Sleep(time.Millisecond * 500)
    }
}
```
  {{% /tab %}}
{{< /tabs >}}

### Code Explanation

**Importing packages:**
```go
import (
    "machine"  // Hardware access (GPIO, I2C, SPI, etc.)
    "time"     // Time and sleep functions
)
```

**Configuring the LED pin:**
```go
led := machine.GPIO10                    // Select pin 10
led.Configure(machine.PinConfig{         // Configure pin
    Mode: machine.PinOutput,             //   as output
})
```

**Blinking loop:**
```go
for {                                   // Infinite loop
    led.Low()                           // Set pin LOW (LED ON)
    time.Sleep(time.Millisecond * 500)  // Wait 500ms

    led.High()                          // Set pin HIGH (LED OFF)
    time.Sleep(time.Millisecond * 500)  // Wait 500ms
}
```

### Step 3: Build and Flash

**Build the firmware:**
{{< tabs groupId="board" >}}
  {{% tab name="M5Stack Core2" %}}
```bash
tinygo build -target m5stack-core2 -o firmware.bin .
```
  {{% /tab %}}

  {{% tab name="M5Stack StampC3" %}}
```bash
tinygo build -target m5stack-stampc3 -o firmware.bin .
```
  {{% /tab %}}

  {{% tab name="XIAO-ESP32C3" %}}
```bash
tinygo build -target xiao-esp32c3 -o firmware.bin .
```
  {{% /tab %}}
{{< /tabs >}}

**Flash to board:**
{{< tabs groupId="board" >}}
  {{% tab name="M5Stack Core2" %}}
```bash
tinygo flash -target m5stack-core2 -port /dev/ttyUSB0 .
```

**On Windows:**
```bash
tinygo flash -target m5stack-core2 -port COM3 .
```
  {{% /tab %}}

  {{% tab name="M5Stack StampC3" %}}
```bash
tinygo flash -target m5stack-stampc3 -port /dev/ttyUSB0 .
```

**On Windows:**
```bash
tinygo flash -target m5stack-stampc3 -port COM3 .
```
  {{% /tab %}}

  {{% tab name="XIAO-ESP32C3" %}}
```bash
tinygo flash -target xiao-esp32c3 -port /dev/ttyACM0 .
```

**On Windows:**
```bash
tinygo flash -target xiao-esp32c3 -port COM3 .
```
  {{% /tab %}}
{{< /tabs >}}

### Step 4: Observe the LED

The built-in LED should blink at 1Hz (500ms on, 500ms off).

{{< alert icon="lightbulb" cardColor="#fff3cd" iconColor="#856404" >}}
**Note:** M5Stack Core2's LED is on the back of the board. The StampC3 and XIAO LEDs are visible on the top.
{{< /alert >}}

## Understanding Active LOW

Most built-in LEDs on ESP32 boards are "active LOW":
- **LED ON**: Pin output LOW (0V, GND)
- **LED OFF**: Pin output HIGH (3.3V, VCC)

This seems backward but is common in electronics:
- Sinks current to ground instead of sourcing from VCC
- Compatible with more logic families
- Easier PCB routing

To use an external LED (active HIGH):
```go
led.Low()  // LED OFF
led.High() // LED ON
```

## Experiment: Change Blink Rate

Modify the delay to change blink rate:

```go
// Fast blink (100ms)
time.Sleep(time.Millisecond * 100)

// Slow blink (1000ms = 1 second)
time.Sleep(time.Millisecond * 1000)

// Blink in Hz (2Hz = 2 times per second)
time.Sleep(time.Second / 2)
```

## Experiment: Morse Code

Blink "SOS" in Morse code:
- S: *** (three short blinks)
- O: --- (three long blinks)

```go
func shortBlink() {
    led.Low()
    time.Sleep(time.Millisecond * 200)
    led.High()
    time.Sleep(time.Millisecond * 200)
}

func longBlink() {
    led.Low()
    time.Sleep(time.Millisecond * 600)
    led.High()
    time.Sleep(time.Millisecond * 200)
}

func main() {
    for {
        // S: ***
        shortBlink()
        shortBlink()
        shortBlink()
        time.Sleep(time.Millisecond * 400)

        // O: ---
        longBlink()
        longBlink()
        longBlink()
        time.Sleep(time.Millisecond * 400)

        time.Sleep(time.Second * 2) // Pause between SOS
    }
}
```

## Serial Output

Add debug output to monitor via USB:

```go
package main

import (
    "machine"
    "time"
)

func main() {
    // Initialize serial (USB)
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{
        BaudRate: 115200,
    })

    led := machine.GPIO10
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    serial.WriteString("Blinky starting!\r\n")

    for {
        serial.WriteString("LED ON\r\n")
        led.Low()
        time.Sleep(time.Millisecond * 500)

        serial.WriteString("LED OFF\r\n")
        led.High()
        time.Sleep(time.Millisecond * 500)
    }
}
```

**Monitor serial output:**
```bash
tinygo monitor -port /dev/ttyUSB0 -baudrate 115200
```

Or use `screen`:
```bash
screen /dev/ttyUSB0 115200
```

## Troubleshooting

### "Board not found"

- Check USB cable (must support data)
- Try different USB port
- Verify port with `tinygo ports`
- Check board is powered (LED lit)

### "Permission denied"

**Linux:**
```bash
sudo usermod -a -G dialout $USER
# Log out and in
```

**macOS:**
```bash
sudo chmod 666 /dev/cu.usbserial-*
```

### LED not blinking

- Check code compiles without errors
- Verify correct target (`-target` flag)
- Try pressing RESET button on board
- Check LED is working (try different pin)

### Compilation errors

- Ensure Go 1.22+ installed: `go version`
- Ensure TinyGo 0.41 installed: `tinygo version`
- Check imports are correct
- Verify board is supported

## Simulation with Wokwi

Don't have an ESP32 board? You can simulate this project using Wokwi!

### What is Wokwi?

Wokwi is an online electronics simulator that supports ESP32 boards. It's perfect for testing code without hardware.

### Using Wokwi Web Interface

1. Visit [wokwi.com/esp32](https://wokwi.com/esp32)
2. The ESP32 board with LED is pre-configured
3. Copy your `main.go` code to the `sketch.ino` file
4. Click "Run" to start simulation

### Using Wokwi with VS Code

**Install Wokwi VS Code Extension:**

1. Open VS Code
2. Press `Ctrl+Shift+X` (Windows/Linux) or `Cmd+Shift+X` (macOS)
3. Search for "Wokwi for ESP-IDF"
4. Install the extension

**Create Wokwi Configuration:**

Create `wokwi.toml` in your project directory:

```toml
[wokwi]
version = 1
firmware = 'firmware.bin'
elf = 'firmware.elf'
```

**Create Diagram Configuration:**

Create `diagram.json`:

```json
{
  "version": 1,
  "author": "TinyGo Workshop",
  "editor": "wokwi",
  "parts": [
    {
      "type": "board-esp32-c3-devkitm-1",
      "id": "esp",
      "top": 0,
      "left": 0,
      "attrs": {}
    },
    {
      "type": "wokwi-led",
      "id": "led1",
      "top": -150,
      "left": 150,
      "attrs": { "color": "red" }
    }
  ],
  "connections": [
    [ "led1:A", "esp:10", "red", [ "v0" ] ],
    [ "led1:C", "esp:GND.2", "black", [ "v0" ] ],
    [ "esp:TX", "$serialMonitor:RX", "", [] ],
    [ "esp:RX", "$serialMonitor:TX", "", [] ]
  ]
}
```

**Build and Run:**

```bash
# Build firmware
tinygo build -target xiao-esp32c3 -o firmware.bin .

# Start Wokwi simulation
# Press F1 in VS Code, type "Wokwi: Start Simulator"
```

### Supported Boards in Wokwi

- **ESP32-C3**: `xiao-esp32c3` (Seeed Studio XIAO)
- **ESP32-S3**: `xiao-esp32s3` (Seeed Studio XIAO)
- **ESP32**: `esp32` (Original ESP32)

{{< alert icon="lightbulb" cardColor="#fff3cd" iconColor="#856404" >}}
**Tip:** Wokwi is great for testing and learning, but always verify your code on real hardware before deployment. Simulation may not perfectly match real-world behavior.
{{< /alert >}}

## Summary

In this assignment, you learned:
- ✅ What GPIO pins are and how to use them
- ✅ How to configure pins as inputs or outputs
- ✅ Digital output (HIGH/LOW, 3.3V/0V)
- ✅ Active LOW vs active HIGH
- ✅ Time delays and loops
- ✅ Building and flashing TinyGo programs
- ✅ Serial monitoring for debugging
- ✅ Simulating projects with Wokwi

You now have the foundation to control any digital output!

[Assignment 3: Display](../assignment-3/)
