---
title: "TinyGo Embedded Workshop - Assignment 3: Display"
date: 2026-04-22T00:00:00+01:00
lastmod: 2026-04-22
showTableOfContents: false
series: ["WS002EN"]
series_order: 4
showAuthor: false
---

## Assignment 3: Display

In this assignment, you'll learn to drive an LCD display, draw graphics, display text, and show images. The M5Stack Core2 features a 2.0" ILI9342C TFT display (320x240 pixels).

## M5Stack Core2 Display Overview

### Display Specifications

- **Controller**: ILI9342C
- **Resolution**: 320 x 240 pixels
- **Interface**: SPI (Serial Peripheral Interface)
- **Color**: 16-bit RGB565 (65,536 colors)
- **Backlight**: Controlled by AXP192 PMIC

### Pin Connections

The display connects via SPI:
- **SCK**: GPIO18 (Serial Clock)
- **MOSI/SDO**: GPIO23 (Master Out Slave In)
- **MISO/SDI**: GPIO38 (Master In Slave Out)
- **CS (SS)**: GPIO5 (Chip Select)
- **DC**: GPIO15 (Data/Command)
- **RST**: Controlled by AXP192

### Power Management

The AXP192 power management IC controls:
- LCD voltage (3.3V)
- Backlight enable
- LCD reset sequence

## Display Initialization

### Step 1: Create Project

```bash
mkdir display-demo
cd display-demo
go mod init display-demo
```

### Step 2: Initialize Display

Create `main.go`:

```go
package main

import (
    "image/color"
    "machine"
    "time"

    "tinygo.org/x/drivers/axp192/m5stack-core2-axp192"
    "tinygo.org/x/drivers/i2csoft"
    "tinygo.org/x/drivers/ili9341"
)

func main() {
    // Initialize serial for debug output
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})
    serial.WriteString("Initializing display...\r\n")

    // Initialize I2C for AXP192 power management
    i2c := i2csoft.New(machine.SCL0_PIN, machine.SDA0_PIN)
    i2c.Configure(i2csoft.I2CConfig{Frequency: 100e3})

    // Initialize AXP192 PMIC (powers display and backlight)
    axp := axp192.New(i2c)
    axp.Begin()
    axp.SetLCDVoltage(3300)  // 3.3V for LCD
    axp.SetLDO2Voltage(3300)  // LDO2 for peripherals
    axp.SetDCDC3(3300)        // DCDC3 for LCD backlight
    axp.EnableLCD(true)       // Enable LCD power
    axp.EnableBacklight(true) // Enable backlight

    serial.WriteString("AXP192 initialized\r\n")

    // Initialize SPI for display
    machine.SPI2.Configure(machine.SPIConfig{
        SCK:       machine.LCD_SCK_PIN,
        SDO:       machine.LCD_SDO_PIN,
        SDI:       machine.LCD_SDI_PIN,
        Frequency: 40e6, // 40MHz
    })

    serial.WriteString("SPI initialized\r\n")

    // Initialize ILI9342C display
    display := ili9341.NewSPI(
        machine.SPI2,
        machine.LCD_DC_PIN,
        machine.LCD_SS_PIN,
        machine.NoPin,
    )

    display.Configure(ili9341.Config{
        Width:            320,
        Height:           240,
        DisplayInversion: true,
    })

    display.SetRotation(ili9341.Rotation0Mirror)

    serial.WriteString("Display initialized!\r\n")

    // Clear screen with blue background
    display.FillScreen(color.RGBA{20, 20, 60, 255})

    // Keep display on
    for {
        time.Sleep(time.Second)
    }
}
```

### Step 3: Build and Flash

```bash
tinygo flash -target m5stack-core2 -port /dev/ttyUSB0 .
```

The screen should turn blue with a slight purple tint.

## Drawing Shapes

### Fill Screen

```go
// Fill entire screen with a color
display.FillScreen(color.RGBA{20, 20, 60, 255})
```

### Draw Pixels

```go
// Draw a single pixel at (x, y)
display.SetPixel(160, 120, color.RGBA{255, 0, 0, 255})
```

### Draw Lines

```go
// Draw line from (x1, y1) to (x2, y2)
display.DrawLine(10, 10, 310, 10, color.RGBA{255, 0, 0, 255})    // Red top line
display.DrawLine(310, 10, 310, 230, color.RGBA{0, 255, 0, 255})  // Green right line
display.DrawLine(310, 230, 10, 230, color.RGBA{0, 0, 255, 255})  // Blue bottom line
display.DrawLine(10, 230, 10, 10, color.RGBA{255, 255, 0, 255})  // Yellow left line
```

### Draw Rectangles

```go
// Draw filled rectangle
display.FillRectangle(50, 50, 100, 80, color.RGBA{255, 0, 0, 255})

// Draw rectangle outline
drawRectangle(50, 150, 100, 80, color.RGBA{0, 255, 0, 255})
```

### Draw Circles

```go
// Draw filled circle
display.FillCircle(160, 120, 40, color.RGBA{0, 0, 255, 255})

// Draw circle outline
display.DrawCircle(160, 120, 50, color.RGBA{255, 255, 0, 255})
```

### Draw Rounded Rectangles

```go
// Draw rounded rectangle
display.DrawRoundRect(20, 20, 280, 200, 20, color.RGBA{255, 255, 255, 255})
```

### Draw Triangles

```go
// Draw filled triangle
display.FillTriangle(160, 20, 20, 220, 300, 220, color.RGBA{255, 0, 255, 255})
```

## Complete Graphics Demo

```go
package main

import (
    "image/color"
    "machine"
    "time"

    "tinygo.org/x/drivers/axp192/m5stack-core2-axp192"
    "tinygo.org/x/drivers/i2csoft"
    "tinygo.org/x/drivers/ili9341"
)

func main() {
    // Initialize display (as shown above)
    // ... initialization code ...

    display.FillScreen(color.RGBA{20, 20, 60, 255})

    // Draw shapes
    display.DrawLine(10, 10, 310, 10, color.RGBA{255, 0, 0, 255})
    display.FillRectangle(50, 50, 100, 80, color.RGBA{255, 0, 0, 255})
    display.FillCircle(160, 120, 40, color.RGBA{0, 0, 255, 255})
    display.DrawCircle(160, 120, 50, color.RGBA{255, 255, 0, 255})

    for {
        time.Sleep(time.Second)
    }
}
```

## Displaying Text

### Using Built-in Font

The ILI9341 driver includes a basic 8x8 pixel font:

```go
// Draw text at (x, y) with color and background
display.DrawRGBBitmap(10, 10, []byte("Hello TinyGo!"), color.RGBA{255, 255, 255, 255})
```

### Using tinygl-font

For better text rendering, use the tinygl-font library:

```go
package main

import (
    "image/color"
    "machine"
    "time"

    "tinygo.org/x/drivers/axp192/m5stack-core2-axp192"
    "tinygo.org/x/drivers/i2csoft"
    "tinygo.org/x/drivers/ili9341"
    "tinygo.org/x/drivers/pixel"
    "tinygo.org/x/tinygl-font"
    "tinygo.org/x/tinygl-font/roboto"
)

func main() {
    // Initialize display
    // ... initialization code ...

    // Create off-screen buffer for text
    textDisplay := pixel.NewImage[pixel.RGB565BE](300, 60)

    // Colors
    white := pixel.NewRGB565BE(color.RGBA{255, 255, 255, 255})
    bgColor := pixel.NewRGB565BE(color.RGBA{20, 20, 60, 255})

    // Clear buffer with background color
    textDisplay.FillSolidColor(bgColor)

    // Draw text using Roboto 48pt font
    font.Draw(roboto.Regular48, "Hello!", 0, 48, white, textDisplay)

    // Get pixel data and display
    pixelData := textDisplay.RawBuffer()
    width, height := textDisplay.Size()
    display.DrawRGBBitmap8(10, 90, pixelData, int16(width), int16(height))

    for {
        time.Sleep(time.Second)
    }
}
```

## Displaying Images

### Embedded Image Example

Embed a PNG image as a Go constant:

```go
package main

import (
    "image/color"
    "machine"
    "strings"
    "time"

    "tinygo.org/x/drivers/axp192/m5stack-core2-axp192"
    "tinygo.org/x/drivers/i2csoft"
    "tinygo.org/x/drivers/ili9341"
    "tinygo.org/x/drivers/image/png"
)

//go:generate go run ../cmd/embed-png/main.go logo.png > logo.go

func main() {
    // Initialize display
    // ... initialization code ...

    // Decode PNG image
    var logoBuffer [3 * 8 * 8 * 4]uint16
    logoReader := strings.NewReader(tinygoLogoPNG)

    png.SetCallback(logoBuffer[:], func(data []uint16, x, y, w, h, width, height int16) {
        offsetX := int16((320 - 299) / 2) // Center horizontally
        offsetY := int16(0)
        display.DrawRGBBitmap(x+offsetX, y+offsetY, data[:w*h], w, h)
    })

    png.Decode(logoReader)

    for {
        time.Sleep(time.Second)
    }
}
```

## Color Models

### RGB565 Color Format

The display uses 16-bit RGB565:
- **Red**: 5 bits (32 shades)
- **Green**: 6 bits (64 shades)
- **Blue**: 5 bits (32 shades)

**Creating colors:**
```go
// From RGBA (converted to RGB565)
color.RGBA{255, 0, 0, 255}       // Red
color.RGBA{0, 255, 0, 255}       // Green
color.RGBA{0, 0, 255, 255}       // Blue
color.RGBA{255, 255, 255, 255}   // White
color.RGBA{0, 0, 0, 255}         // Black
```

### Common Colors

```go
var (
    Red     = color.RGBA{255, 0, 0, 255}
    Green   = color.RGBA{0, 255, 0, 255}
    Blue    = color.RGBA{0, 0, 255, 255}
    Yellow  = color.RGBA{255, 255, 0, 255}
    Cyan    = color.RGBA{0, 255, 255, 255}
    Magenta = color.RGBA{255, 0, 255, 255}
    White   = color.RGBA{255, 255, 255, 255}
    Black   = color.RGBA{0, 0, 0, 255}
)
```

## Display Rotation

The display supports 4 rotation modes:

```go
display.SetRotation(ili9341.Rotation0)        // Normal
display.SetRotation(ili9341.Rotation0Mirror)  // Normal mirrored
display.SetRotation(ili9341.Rotation90)       // 90 degrees clockwise
display.SetRotation(ili9341.Rotation180)      // 180 degrees
display.SetRotation(ili9341.Rotation270)      // 270 degrees clockwise
```

## Animation Example

Create simple animation:

```go
var ballX int16 = 160
var ballY int16 = 120
var velX int16 = 2
var velY int16 = 3

func main() {
    // Initialize display
    // ... initialization code ...

    for {
        // Clear screen
        display.FillScreen(color.RGBA{20, 20, 60, 255})

        // Update position
        ballX += velX
        ballY += velY

        // Bounce off walls
        if ballX <= 10 || ballX >= 310 {
            velX = -velX
        }
        if ballY <= 10 || ballY >= 230 {
            velY = -velY
        }

        // Draw ball
        display.FillCircle(ballX, ballY, 10, color.RGBA{255, 255, 0, 255})

        time.Sleep(time.Millisecond * 33) // ~30 FPS
    }
}
```

## Troubleshooting

### Display is blank/flickering

- Check AXP192 initialization (powers display)
- Verify SPI connections
- Check backlight is enabled
- Try resetting the board

### Wrong colors

- Ensure RGB565 format (not RGBA)
- Check byte order (RGB565BE vs RGB565LE)
- Verify color values are correct

### Text not visible

- Check Y coordinate allows room for font height
- Ensure text color contrasts with background
- Verify font is loaded correctly

### Compilation errors

- Ensure all imports are correct
- Check `go.mod` has required dependencies
- Verify TinyGo 0.41+ installed

## Summary

In this assignment, you learned:
- How to initialize an LCD display via SPI
- Power management with AXP192
- Drawing shapes: lines, rectangles, circles
- Displaying text with fonts
- Showing images from embedded data
- Understanding RGB565 color format
- Creating simple animations

You can now create visual interfaces for your projects!

[Assignment 4: Sensors](../assignment-4/)
