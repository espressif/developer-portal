---
title: "TinyGo Embedded Workshop - Assignment 4: Sensors"
date: 2026-04-22T00:00:00+01:00
lastmod: 2026-04-22
showTableOfContents: false
series: ["WS002EN"]
series_order: 5
showAuthor: false
---

## Assignment 4: Sensors

In this assignment, you'll learn to read data from sensors using I2C and communicate with the built-in accelerometer on the M5Stack Core2.

## Understanding I2C

I2C (Inter-Integrated Circuit) is a popular serial communication protocol for sensors:

- **Two wires**: SDA (data) and SCL (clock)
- **Multiple devices**: Up to 127 devices on same bus
- **Addressing**: Each device has unique 7-bit address
- **Speed**: Standard (100kHz), Fast (400kHz), High Speed (3.4MHz)

### I2C Connections on M5Stack Core2

- **SDA**: GPIO21
- **SCL**: GPIO22
- **Pull-up resistors**: Built-in (typically 4.7kΩ)

### Common I2C Sensor Addresses

- **0x44**: SHT30/SHT31 Temperature & Humidity
- **0x76**: BMP280/BME280 Pressure
- **0x68**: MPU6050 IMU (Accelerometer + Gyroscope)
- **0x19**: BMI260 Accelerometer (M5Stack Core2 built-in)

## M5Stack Core2 Built-in Sensors

### BMI260 Accelerometer

The M5Stack Core2 includes a BMI260 6-axis inertial measurement unit:

- **Accelerometer**: ±16g range, 3-axis
- **Gyroscope**: ±2000°/s range, 3-axis
- **I2C Address**: 0x19
- **Interrupts**: Motion detection, tap detection

## Reading Temperature and Humidity

### Hardware Setup (Optional)

For this example, you can use:
- **Built-in**: M5Stack Core2 internal temperature (if available)
- **External**: SHT30/SHT31 sensor connected to I2C

### SHT30 Temperature & Humidity Sensor

**Connections:**
```
VCC  → 3.3V
GND  → GND
SCL  → GPIO22
SDA  → GPIO21
```

### Step 1: Create Project

```bash
mkdir sensor-demo
cd sensor-demo
go mod init sensor-demo
```

### Step 2: Read Temperature

Create `main.go` for SHT30:

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/bmi260"
    "tinygo.org/x/drivers/i2csoft"
)

func main() {
    // Initialize serial
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})
    serial.WriteString("Reading sensor data...\r\n")

    // Initialize I2C
    i2c := i2csoft.New(machine.SCL0_PIN, machine.SDA0_PIN)
    i2c.Configure(i2csoft.I2CConfig{Frequency: 100e3})

    // Initialize BMI260 accelerometer
    sensor := bmi260.New(i2c)
    sensor.Configure()

    for {
        // Read accelerometer data
        accelX, accelY, accelZ := sensor.ReadAcceleration()

        // Output to serial
        serial.WriteString("Accelerometer: X=")
        printFloat(serial, accelX)
        serial.WriteString(" Y=")
        printFloat(serial, accelY)
        serial.WriteString(" Z=")
        printFloat(serial, accelZ)
        serial.WriteString("\r\n")

        time.Sleep(time.Millisecond * 500)
    }
}

func printFloat(serial machine.UART, f float32) {
    // Simple float to string conversion
    buffer := make([]byte, 20)
    neg := f < 0
    if neg {
        f = -f
        serial.WriteByte('-')
    }

    intPart := int(f)
    fracPart := int((f - float32(intPart)) * 100)

    itoa(serial, intPart)
    serial.WriteByte('.')
    itoa(serial, fracPart)
}

func itoa(serial machine.UART, n int) {
    if n == 0 {
        serial.WriteByte('0')
        return
    }

    var buf [10]byte
    i := 10
    for n > 0 && i > 0 {
        i--
        buf[i] = byte('0' + n%10)
        n /= 10
    }

    for i < 10 {
        serial.WriteByte(buf[i])
        i++
    }
}
```

## Reading Built-in Accelerometer

### BMI260 Driver Example

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/bmi260"
    "tinygo.org/x/drivers/i2csoft"
    "tinygo.org/x/drivers/ili9341"
    "tinygo.org/x/drivers/axp192/m5stack-core2-axp192"
    "tinygo.org/x/drivers/pixel"
    "tinygo.org/x/tinygl-font"
    "tinygo.org/x/tinygl-font/roboto"
    "image/color"
)

func main() {
    // Initialize serial
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})

    // Initialize I2C
    i2c := i2csoft.New(machine.SCL0_PIN, machine.SDA0_PIN)
    i2c.Configure(i2csoft.I2CConfig{Frequency: 100e3})

    // Initialize BMI260
    sensor := bmi260.New(i2c)
    sensor.Configure()

    serial.WriteString("BMI260 initialized\r\n")

    // Initialize display (as shown in Assignment 3)
    i2cDisp := i2csoft.New(machine.SCL0_PIN, machine.SDA0_PIN)
    i2cDisp.Configure(i2csoft.I2CConfig{Frequency: 100e3})

    axp := axp192.New(i2cDisp)
    axp.Begin()
    axp.SetLCDVoltage(3300)
    axp.SetLDO2Voltage(3300)
    axp.SetDCDC3(3300)
    axp.EnableLCD(true)
    axp.EnableBacklight(true)

    machine.SPI2.Configure(machine.SPIConfig{
        SCK:       machine.LCD_SCK_PIN,
        SDO:       machine.LCD_SDO_PIN,
        SDI:       machine.LCD_SDI_PIN,
        Frequency: 40e6,
    })

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

    display.FillScreen(color.RGBA{20, 20, 60, 255})

    // Text buffer
    textDisplay := pixel.NewImage[pixel.RGB565BE](300, 40)
    white := pixel.NewRGB565BE(color.RGBA{255, 255, 255, 255})

    for {
        // Read accelerometer
        accelX, accelY, accelZ := sensor.ReadAcceleration()

        // Clear text buffer
        textDisplay.FillSolidColor(pixel.NewRGB565BE(color.RGBA{20, 20, 60, 255}))

        // Display readings
        displayText := func(text string, y int16) {
            textDisplay.FillSolidColor(pixel.NewRGB565BE(color.RGBA{20, 20, 60, 255}))
            font.Draw(roboto.Regular16, text, 0, 16, white, textDisplay)
            pixelData := textDisplay.RawBuffer()
            w, h := textDisplay.Size()
            display.DrawRGBBitmap8(10, y, pixelData, int16(w), int16(h))
        }

        displayText("Accelerometer Readings:", 10)
        displayText("X: "+formatFloat(accelX)+" g", 50)
        displayText("Y: "+formatFloat(accelY)+" g", 90)
        displayText("Z: "+formatFloat(accelZ)+" g", 130)

        // Calculate total acceleration
        total := calcMagnitude(accelX, accelY, accelZ)
        displayText("Total: "+formatFloat(total)+" g", 170)

        // Detect orientation
        orientation := detectOrientation(accelX, accelY, accelZ)
        displayText("Orientation: "+orientation, 210)

        // Serial output
        serial.WriteString("X: ")
        serial.WriteString(formatFloat(accelX))
        serial.WriteString(" Y: ")
        serial.WriteString(formatFloat(accelY))
        serial.WriteString(" Z: ")
        serial.WriteString(formatFloat(accelZ))
        serial.WriteString("\r\n")

        time.Sleep(time.Millisecond * 200)
    }
}

func formatFloat(f float32) string {
    // Simple float formatting
    neg := f < 0
    if neg {
        f = -f
    }

    intPart := int(f)
    fracPart := int((f - float32(intPart)) * 100)

    var result [20]byte
    i := 0

    if neg {
        result[i] = '-'
        i++
    }

    // Integer part
    if intPart == 0 {
        result[i] = '0'
        i++
    } else {
        var buf [10]byte
        j := 10
        for intPart > 0 && j > 0 {
            j--
            buf[j] = byte('0' + intPart%10)
            intPart /= 10
        }
        for j < 10 {
            result[i] = buf[j]
            i++
            j++
        }
    }

    result[i] = '.'
    i++

    // Fraction part
    result[i] = byte('0' + fracPart/10)
    i++
    result[i] = byte('0' + fracPart%10)
    i++

    return string(result[:i])
}

func calcMagnitude(x, y, z float32) float32 {
    return sqrt(x*x + y*y + z*z)
}

func sqrt(x float32) float32 {
    // Newton-Raphson square root
    if x == 0 {
        return 0
    }

    z := float32(1.0)
    for i := 0; i < 10; i++ {
        z -= (z*z - x) / (2 * z)
    }
    return z
}

func detectOrientation(x, y, z float32) string {
    const threshold = 0.7

    if x > threshold {
        return "Right"
    } else if x < -threshold {
        return "Left"
    } else if y > threshold {
        return "Down"
    } else if y < -threshold {
        return "Up"
    } else if z > threshold {
        return "Flat"
    } else if z < -threshold {
        return "Upside Down"
    } else {
        return "Tilted"
    }
}
```

## Motion Detection

### Simple Motion Detection

Detect significant movement:

```go
var lastX, lastY, lastZ float32
const motionThreshold = 0.5

func detectMotion(x, y, z float32) bool {
    deltaX := abs(x - lastX)
    deltaY := abs(y - lastY)
    deltaZ := abs(z - lastZ)

    lastX = x
    lastY = y
    lastZ = z

    return (deltaX > motionThreshold ||
            deltaY > motionThreshold ||
            deltaZ > motionThreshold)
}

func abs(x float32) float32 {
    if x < 0 {
        return -x
    }
    return x
}
```

## Troubleshooting

### "Sensor not found"

- Check I2C address is correct
- Verify wiring (SDA, SCL, VCC, GND)
- Ensure pull-up resistors are present
- Try scanning I2C bus with `i2cscan` tool

### "Readings are zero/incorrect"

- Check sensor is properly initialized
- Verify I2C frequency (some sensors need slower speed)
- Check sensor datasheet for register addresses
- Ensure correct data type conversion

### "Compilation errors"

- Ensure driver packages are imported
- Check `go.mod` has dependencies
- Verify TinyGo version (0.41+ recommended)
- Check board supports the sensor

## Simulation with Wokwi

You can simulate sensor projects using Wokwi with BMI260 support!

### Wokwi Diagram for Accelerometer

Create `diagram.json` for accelerometer simulation:

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
      "type": "wokwi-bmi160",
      "id": "bmi1",
      "top": -80,
      "left": 150,
      "attrs": {}
    }
  ],
  "connections": [
    [ "bmi1:SDO", "esp:21", "green", [ "v0" ] ],
    [ "bmi1:SDA", "esp:22", "green", [ "v0" ] ],
    [ "bmi1:GND", "esp:GND.1", "black", [ "v0" ] ],
    [ "bmi1:VCC", "esp:3V3", "red", [ "v0" ] ],
    [ "esp:TX", "$serialMonitor:RX", "", [] ],
    [ "esp:RX", "$serialMonitor:TX", "", [] ]
  ]
}
```

{{< alert icon="triangle-exclamation" cardColor="#f8d7da" iconColor="#721c24" >}}
**Note:** Wokwi supports BMI160 which is compatible with BMI260 for basic accelerometer readings. Some advanced features may differ.
{{< /alert >}}

### Running in Wokwi

1. Create `wokwi.toml` configuration
2. Build firmware:
```bash
tinygo build -target xiao-esp32c3 -o firmware.bin .
```

3. Open project folder in VS Code
4. Press F1, select "Wokwi: Start Simulator"
5. See accelerometer data in serial monitor

### Testing Without Hardware

Wokwi provides simulated sensor data:
- Accelerometer values change automatically
- Test your code logic without physical hardware
- Verify I2C communication works
- Debug display and formatting

## Summary

In this assignment, you learned:
- How I2C communication works
- Reading data from I2C sensors
- Using built-in accelerometer
- Formatting and displaying sensor data
- Simple motion detection
- Orientation detection
- Combining sensors with display
- Simulating sensor projects with Wokwi

You can now gather data from the physical world!

[Assignment 5: Wi-Fi Client](../assignment-5/)
