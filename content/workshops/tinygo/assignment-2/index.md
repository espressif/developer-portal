---
title: "TinyGo Embedded Workshop - Assignment 2: Blinky"
date: 2026-04-22T00:00:00+01:00
lastmod: 2026-04-22
showTableOfContents: false
series: ["WS002EN"]
series_order: 3
showAuthor: false
---

## Assignment 2: Blinky

Blinking an LED is the "Hello, World!" of embedded development. In this assignment, you'll write your first TinyGo program to blink an LED.

{{< alert icon="lightbulb" cardColor="#d1ecf1" iconColor="#0c5460" >}}
**Source Code Available:** All example code for this assignment is available in the [developer-portal-codebase](https://github.com/espressif/developer-portal-codebase) repository. See `content/workshops/tinygo/assignment_2/` for complete working examples including blinky, morse code, serial output, and RGB LED control.
{{< /alert >}}

## Understanding GPIO

GPIO (General Purpose Input/Output) pins are the interface between your microcontroller and the physical world. They can be:

- **Inputs**: Read digital signals (buttons, switches)
- **Outputs**: Control digital signals (LEDs, relays, motors)

### LED Basics

An LED (Light Emitting Diode) is a simple output device:
- **Anode (+)**: Longer leg, connects to positive voltage through a resistor
- **Cathode (-)**: Shorter leg with flat side on casing, connects to ground (GND)
- **Resistor**: Limits current to prevent LED damage

**Resistor Values for ESP32 (3.3V):**

| LED Color | Forward Voltage | Resistor Range | Common Value |
|-----------|-----------------|----------------|--------------|
| Red | 1.8-2.2V | 330Ω - 1kΩ | 470Ω |
| Green | 2.0-3.0V | 220Ω - 680Ω | 330Ω |
| Blue | 3.0-3.3V | 100Ω - 330Ω | 220Ω |
| Orange/Yellow | 2.0-2.2V | 330Ω - 680Ω | 470Ω |

**Wiring for External LED:**
ESP32 GPIO → Resistor → LED Anode → LED Cathode → GND

**Digital Logic:**
- **HIGH (1)**: Pin outputs VCC (3.3V on ESP32) - LED ON
- **LOW (0)**: Pin outputs GND (0V) - LED OFF

## Finding the LED Pin

Different boards have built-in LEDs on different pins:

{{< tabs groupId="board" >}}
  {{% tab name="ESP32" %}}
**ESP32 Built-in LED:**

- Pin: GPIO2 (most common) or GPIO10 (some boards)
- Type: Active HIGH (LED on when pin is HIGH)

For external RGB LEDs: WS2812/NeoPixel on GPIO8
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
**ESP32-S3 Built-in LED:**

- Pin: GPIO2 (most common)
- Type: Active HIGH (LED on when pin is HIGH)

Many boards also include RGB LEDs.
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
**ESP32-C3 Built-in LED:**

- Pin: GPIO2 (most boards, active HIGH)
- Type: Built-in LED

For external RGB LEDs: WS2812/NeoPixel on GPIO2
  {{% /tab %}}
{{< /tabs >}}

## Get the Source Code

The complete source code for this assignment is available in the [developer-portal-codebase](https://github.com/espressif/developer-portal-codebase) repository:

```bash
git clone https://github.com/espressif/developer-portal-codebase.git
cd developer-portal-codebase/content/workshops/tinygo/assignment_2
```

Available examples:
- `blinky.go` - Basic LED blink
- `morse.go` - Morse code SOS signal
- `serial.go` - Serial output debugging
- `rgb_led_esp32.go` - RGB LED for ESP32
- `rgb_led_esp32c3.go` - RGB LED for ESP32-C3

Each example is a complete working program. Build by specifying the source file:

```bash
# Example: Build blinky for ESP32-C3
tinygo flash -target esp32c3-generic blinky.go
```

See the README.md in the assignment directory for detailed build instructions.

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
  {{% tab name="ESP32" %}}
**main.go for ESP32:**

```go
package main

import (
    "machine"
    "time"
)

func main() {
    // ESP32: LED on GPIO2 (active HIGH)
    led := machine.GPIO2
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    for {
        led.High()  // LED ON
        time.Sleep(time.Millisecond * 500)

        led.Low() // LED OFF
        time.Sleep(time.Millisecond * 500)
    }
}
```
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
**main.go for ESP32-S3:**

```go
package main

import (
    "machine"
    "time"
)

func main() {
    // ESP32-S3: LED on GPIO2 (active HIGH)
    led := machine.GPIO2
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    for {
        led.High()  // LED ON
        time.Sleep(time.Millisecond * 500)

        led.Low() // LED OFF
        time.Sleep(time.Millisecond * 500)
    }
}
```
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
**main.go for ESP32-C3:**

```go
package main

import (
    "machine"
    "time"
)

func main() {
    // ESP32-C3: LED on GPIO2 (active HIGH)
    led := machine.GPIO2
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    for {
        led.High()  // LED ON
        time.Sleep(time.Millisecond * 500)

        led.Low() // LED OFF
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
led := machine.GPIO2                     // Select pin (varies by board)
led.Configure(machine.PinConfig{         // Configure pin
    Mode: machine.PinOutput,             //   as output
})
```

**Note:** Different boards use different GPIO pins for the built-in LED:
- ESP32: GPIO2
- ESP32-S3: GPIO2
- ESP32-C3: GPIO2
```

**Blinking loop:**
```go
for {                                   // Infinite loop
    led.High()                          // Set pin HIGH (LED ON)
    time.Sleep(time.Millisecond * 500)  // Wait 500ms

    led.Low()                           // Set pin LOW (LED OFF)
    time.Sleep(time.Millisecond * 500)  // Wait 500ms
}
```

### Step 3: Build and Flash

**Build the firmware:**
{{< tabs groupId="board" >}}
  {{% tab name="ESP32-S3" %}}
```bash
tinygo build -target esp32s3-generic -o firmware.bin .
```
  {{% /tab %}}

  {{% tab name="ESP32" %}}
```bash
tinygo build -target m5stack-core2 -o firmware.bin .
```
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
```bash
tinygo build -target esp32c3-generic -o firmware.bin .
```
  {{% /tab %}}
{{< /tabs >}}

**Flash to board:**
{{< tabs groupId="board" >}}
  {{% tab name="ESP32-S3" %}}
```bash
tinygo flash -target esp32s3-generic .
```
  {{% /tab %}}

  {{% tab name="ESP32" %}}
```bash
tinygo flash -target esp32-generic .
```
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
```bash
tinygo flash -target esp32c3-generic .
```
  {{% /tab %}}
{{< /tabs >}}

**Tip:** TinyGo can auto-detect the port and baudrate, so you don't need to specify them manually.

### Step 4: Observe the LED

The built-in LED should blink at 1Hz (500ms on, 500ms off).

{{< alert icon="lightbulb" cardColor="#fff3cd" iconColor="#856404" >}}
**Note:** LED position varies by board. Some boards have LEDs on the back, others on the front. Check your board documentation.
{{< /alert >}}

## Understanding Active HIGH

Built-in LEDs on ESP32 boards are "active HIGH":
- **LED ON**: Pin output HIGH (3.3V, VCC)
- **LED OFF**: Pin output LOW (0V, GND)

This is straightforward: applying voltage turns the LED on.

To use an external LED with current-limiting resistor:
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

Create a new project:

```bash
mkdir morse
cd morse
go mod init morse
```

Create `morse.go`:

```go
package main

import (
    "machine"
    "time"
)

var led machine.Pin

func shortBlink() {
    led.High()
    time.Sleep(time.Millisecond * 200)
    led.Low()
    time.Sleep(time.Millisecond * 200)
}

func longBlink() {
    led.High()
    time.Sleep(time.Millisecond * 600)
    led.Low()
    time.Sleep(time.Millisecond * 200)
}

func main() {
    // Configure LED pin for your board:
    // ESP32/ESP32-S3: GPIO2
    // ESP32-C3: GPIO2
    led = machine.GPIO2
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

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

        // S: ***
        shortBlink()
        shortBlink()
        shortBlink()

        time.Sleep(time.Second * 2) // Pause between SOS
    }
}
```

**Build and flash:**

```bash
# ESP32
tinygo flash -target esp32-generic morse.go

# ESP32-S3
tinygo flash -target esp32s3-generic morse.go

# ESP32-C3
tinygo flash -target esp32c3-generic morse.go
```

**Build and flash:**

```bash
tinygo flash -target [your-target] .
```

Watch your LED blink the international distress signal: SOS!

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

    // Use appropriate GPIO for your board
    led := machine.GPIO2  // Most boards use GPIO2 for active HIGH
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    serial.Write([]byte("Blinky starting!\r\n"))

    for {
        serial.Write([]byte("LED ON\r\n"))
        led.High()
        time.Sleep(time.Millisecond * 500)

        serial.Write([]byte("LED OFF\r\n"))
        led.Low()
        time.Sleep(time.Millisecond * 500)
    }
}
```

**Monitor serial output:**

{{< tabs groupId="monitor" >}}
  {{% tab name="tinygo monitor" %}}
```bash
tinygo monitor
```

Press `Ctrl+C` to stop monitoring.
  {{% /tab %}}

  {{% tab name="screen" %}}
```bash
screen /dev/ttyUSB0 115200
```

**To quit:** Press `Ctrl+A` then `K` (kill), then confirm with `Y`
  {{% /tab %}}

  {{% tab name="picocom" %}}
```bash
picocom -b 115200 /dev/ttyUSB0
```

**To quit:** Press `Ctrl+A` then `Ctrl+Q`

**Install picocom:**
```bash
# Ubuntu/Debian
sudo apt-get install picocom

# macOS
brew install picocom

# Fedora
sudo dnf install picocom
```
  {{% /tab %}}
{{< /tabs >}}

## RGB LED (NeoPixel)

Many ESP32 boards include RGB LEDs (WS2812B/SK68XX NeoPixels) that can display millions of colors. These are individually addressable LEDs that use a single data line.

{{< alert icon="triangle-exclamation" cardColor="#d1ecf1" iconColor="#0c5460" >}}
**ESP32-S3 Compatibility:** The ws2812 driver requires a small wrapper for ESP32-S3 due to API differences. See the ESP32-S3 tab for the `machine_esp32s3.go` wrapper file.
{{< /alert >}}

### Finding the RGB LED Pin

{{< tabs groupId="board" >}}
  {{% tab name="ESP32" %}}
**ESP32 RGB LED:**
- Pin: GPIO8 (common on many boards)
- Type: WS2812B NeoPixel
- Check your board documentation for exact pin
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
**ESP32-S3 RGB LED:**

**ESP32-S3-DevKitC-1:**
- v1.0: GPIO48
- v1.1: GPIO38 (recommended, works on all versions)

**Important:** The NeoPixel pin changed from GPIO48 to GPIO38 in v1.1 because GPIO47/48 operate at 1.8V on ESP32-S3R8V chips. GPIO38 is safer and works on all versions. Use GPIO38 for compatibility.

**Other ESP32-S3 boards:**
- Check your board documentation for exact pin
- Type: WS2812B NeoPixel

{{< alert icon="triangle-exclamation" cardColor="#fff3cd" iconColor="#856404" >}}
**Note:** ESP32-S3 requires a compatibility wrapper. See the code example below for `machine_esp32s3.go`.
{{< /alert >}}
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
**ESP32-C3 RGB LED:**
- Pin: GPIO2 (common on many boards)
- Type: WS2812B NeoPixel
- Check your board documentation for exact pin
  {{% /tab %}}
{{< /tabs >}}

### RGB LED Example

Create a new project for RGB LED control:

```bash
mkdir rgb-blinky
cd rgb-blinky
go mod init rgb-blinky
```

Add the TinyGo drivers to your `go.mod` file:

```bash
go get tinygo.org/x/drivers@v0.27.0
```

**Prerequisites:**

```bash
go mod download tinygo.org/x/drivers
```

This ensures the ws2812 driver package is available for TinyGo.

{{< tabs groupId="board" >}}
  {{% tab name="ESP32" %}}
**rgb_led.go for ESP32:**

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/ws2812"
    "image/color"
)

func main() {
    // ESP32: RGB LED on GPIO8
    led := machine.GPIO8
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    // NeoPixel driver
    neo := ws2812.New(led)

    // Brightness: 0-255 scale. RGB LEDs are extremely bright, so using 20%
    brightness := uint8(51)

    // Base colors at full brightness
    baseColors := []color.RGBA{
        {255, 0, 0, 255},     // Red
        {0, 255, 0, 255},     // Green
        {0, 0, 255, 255},     // Blue
        {255, 255, 0, 255},   // Yellow
        {0, 255, 255, 255},   // Cyan
        {255, 0, 255, 255},   // Magenta
        {255, 255, 255, 255}, // White
    }

    // Apply brightness scaling
    colors := make([]color.RGBA, len(baseColors))
    for i, c := range baseColors {
        colors[i] = color.RGBA{
            R: uint8(uint16(c.R) * uint16(brightness) / 255),
            G: uint8(uint16(c.G) * uint16(brightness) / 255),
            B: uint8(uint16(c.B) * uint16(brightness) / 255),
            A: 255,
        }
    }

    for {
        for _, c := range colors {
            neo.WriteColors([]color.RGBA{c})
            time.Sleep(time.Millisecond * 500)
        }
    }
}
```
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
**ESP32-S3 requires local driver modification:**

Due to API differences, ESP32-S3 needs a locally modified ws2812 driver. Follow these steps:

**Step 1: Copy ws2812 driver locally**
```bash
mkdir -p drivers/ws2812
cp -r $(go env GOMODCACHE)/tinygo.org/x/drivers@*/ws2812/*.go drivers/ws2812/
```

**Step 2: Modify ws2812_xtensa.go**
Create `drivers/ws2812/ws2812_xtensa_esp32s3.go`:

```go
//go:build xtensa && esp32s3

package ws2812

import (
	"device"
	"machine"
	"runtime/interrupt"
	"unsafe"
)

func (d Device) WriteByte(c byte) error {
	portSet, maskSet := d.Pin.PortMaskSet()
	portClear, maskClear := d.Pin.PortMaskClear()
	mask := interrupt.Disable()

	// ESP32-S3 uses GetCPUFrequency()
	cpuFreq, _ := machine.GetCPUFrequency()

	switch cpuFreq {
	case 160e6: // 160MHz
		// (same assembly code as original driver for 160MHz)
		// ... [full assembly code from original driver]
	case 80e6: // 80MHz
		// (same assembly code as original driver for 80MHz)
		// ... [full assembly code from original driver]
	default:
		interrupt.Restore(mask)
		return errUnknownClockSpeed
	}
}
```

**Step 3: Update main.go**
```go
package main

import (
	"machine"
	"time"

	"rgb-blinky/drivers/ws2812"  // Use local driver
	"image/color"
)

func main() {
	// ESP32-S3-DevKitC-1: RGB LED on GPIO38
	led := machine.GPIO38
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})

	neo := ws2812.New(led)
	neo.SetBrightness(51) // 20% brightness

	colors := []color.RGBA{
		{255, 0, 0, 255},    // Red
		{0, 255, 0, 255},    // Green
		{0, 0, 255, 255},    // Blue
		{255, 255, 0, 255},  // Yellow
		{0, 255, 255, 255},  // Cyan
		{255, 0, 255, 255},  // Magenta
		{255, 255, 255, 255}, // White
	}

	for {
		for _, c := range colors {
			neo.WriteColors([]color.RGBA{c})
			time.Sleep(time.Millisecond * 500)
		}
	}
}
```

{{< alert icon="lightbulb" cardColor="#d1ecf1" iconColor="#0c5460" >}}
**Working Example:** A complete working ESP32-S3 RGB example is available at `/Users/georgik/projects/workshop/rgb-blinky` with the modified driver.
{{< /alert >}}
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
**rgb_led.go for ESP32-C3:**

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/ws2812"
    "image/color"
)

func main() {
    // ESP32-C3: RGB LED on GPIO2
    led := machine.GPIO2
    led.Configure(machine.PinConfig{Mode: machine.PinOutput})

    // NeoPixel driver
    neo := ws2812.New(led)

    // Brightness: 0-255 scale. RGB LEDs are extremely bright, so using 20%
    brightness := uint8(51)

    // Base colors at full brightness
    baseColors := []color.RGBA{
        {255, 0, 0, 255},     // Red
        {0, 255, 0, 255},     // Green
        {0, 0, 255, 255},     // Blue
        {255, 255, 0, 255},   // Yellow
        {0, 255, 255, 255},   // Cyan
        {255, 0, 255, 255},   // Magenta
        {255, 255, 255, 255}, // White
    }

    // Apply brightness scaling
    colors := make([]color.RGBA, len(baseColors))
    for i, c := range baseColors {
        colors[i] = color.RGBA{
            R: uint8(uint16(c.R) * uint16(brightness) / 255),
            G: uint8(uint16(c.G) * uint16(brightness) / 255),
            B: uint8(uint16(c.B) * uint16(brightness) / 255),
            A: 255,
        }
    }

    for {
        for _, c := range colors {
            neo.WriteColors([]color.RGBA{c})
            time.Sleep(time.Millisecond * 500)
        }
    }
}
```
  {{% /tab %}}
{{< /tabs >}}

### Build and Flash

Build commands (same as before, just in the new `rgb-blinky` directory):

{{< tabs groupId="board" >}}
  {{% tab name="ESP32" %}}
```bash
tinygo flash -target m5stack-core2 .
```
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
```bash
tinygo flash -target esp32s3-generic .
```

Note: Make sure `machine_esp32s3.go` wrapper file is included in your project.
  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
```bash
tinygo flash -target m5stack-stampc3 .
```
  {{% /tab %}}
{{< /tabs >}}

### Understanding RGB LEDs

**RGB LED Colors:**
- **Red**: `{255, 0, 0}` - Full red, no green, no blue
- **Green**: `{0, 255, 0}` - No red, full green, no blue
- **Blue**: `{0, 0, 255}` - No red, no green, full blue
- **White**: `{255, 255, 255}` - All colors at full

**Brightness:**
- Scale: 0-255 (0 = off, 255 = maximum)
- 20% brightness: `51` (recommended for RGB LEDs)
- RGB LEDs are **extremely bright** - even 20% is plenty!

**Important:** The SetBrightness() method is not available in the ws2812 driver. Use manual brightness scaling instead (see RGB LED examples below).

**Color Mixing:**
```go
// Orange (red + green)
{255, 165, 0, 255}

// Purple (red + blue)
{128, 0, 128, 255}

// Pink (light red)
{255, 192, 203, 255}
```

### Advanced: Rainbow Effect

Create a smooth rainbow transition:

```go
func wheel(pos uint8) color.RGBA {
    if pos < 85 {
        return color.RGBA{255 - pos*3, pos * 3, 0, 255}
    }
    if pos < 170 {
        pos -= 85
        return color.RGBA{0, 255 - pos*3, pos * 3, 255}
    }
    pos -= 170
    return color.RGBA{pos * 3, 0, 255 - pos*3, 255}
}

func main() {
    // ... setup code ...

    var pos uint8 = 0
    for {
        neo.WriteColors([]color.RGBA{wheel(pos)})
        pos++
        time.Sleep(time.Millisecond * 10)
    }
}
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

- Ensure Go 1.26+ installed: `go version`
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

- **ESP32-C3**: Many dev boards supported
- **ESP32-S3**: Many dev boards supported
- **ESP32**: Original ESP32 supported

{{< alert icon="lightbulb" cardColor="#fff3cd" iconColor="#856404" >}}
**Tip:** Wokwi is great for testing and learning, but always verify your code on real hardware before deployment. Simulation may not perfectly match real-world behavior.
{{< /alert >}}

## Summary

In this assignment, you learned:
- What GPIO pins are and how to use them
- How to configure pins as inputs or outputs
- Digital output (HIGH/LOW, 3.3V/0V)
- Active LOW vs active HIGH
- Time delays and loops
- Building and flashing TinyGo programs
- Serial monitoring for debugging
- RGB LED (NeoPixel) control with WS2812 driver
- Color mixing and brightness control
- Simulating projects with Wokwi

You now have the foundation to control any digital output and create colorful LED effects!

[Assignment 3: Display](../assignment-3/)
