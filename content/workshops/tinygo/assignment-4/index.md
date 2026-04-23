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

In this assignment, you'll learn to read data from sensors using I2C communication and ADC (Analog-to-Digital Converter). You'll work with IMU sensors, joystick input, and build an interactive game controlled by analog input.

{{< alert icon="lightbulb" cardColor="#d1ecf1" iconColor="#0c5460" >}}
**Source Code Available:** All example code for this assignment is available in the [developer-portal-codebase](https://github.com/espressif/developer-portal-codebase) repository. See `content/workshops/tinygo/assignment_4/` for complete working examples including sensor reading, joystick ADC input, and an interactive game.
{{< /alert >}}

## Understanding I2C Communication

I2C (Inter-Integrated Circuit) is a popular serial communication protocol for sensors and peripherals.

### How I2C Works

I2C uses two wires for communication:

- **SDA (Serial Data)**: Transmits data bidirectionally
- **SCL (Serial Clock)**: Provides clock signal for synchronization

**Key Characteristics:**

- **Multiple devices**: Up to 127 devices on same bus
- **Addressing**: Each device has unique 7-bit address
- **Master-slave**: Master initiates all transactions
- **Speed modes**: Standard (100kHz), Fast (400kHz), High Speed (3.4MHz)

### I2C Communication Protocol

1. **Start condition**: Master pulls SDA low while SCL is high
2. **Address transmission**: Master sends 7-bit device address + R/W bit
3. **Acknowledge**: Slave pulls SDA low to acknowledge
4. **Data transfer**: 8 bits of data with acknowledge after each byte
5. **Stop condition**: Master pulls SDA high while SCL is high

### I2C Limitations

{{< alert icon="triangle-exclamation" cardColor="#fff3cd" iconColor="#856404" >}}
**I2C Constraints:**
- **Pull-up resistors required**: Typically 2.2kΩ to 10kΩ on SDA and SCL
- **Capacitance limits**: Bus capacitance < 400pF for standard mode
- **Speed vs length**: Longer wires require slower speeds
- **Address conflicts**: Ensure no two devices share same address
{{< /alert >}}

### Common I2C Sensor Addresses

| Device Type | Part Number | I2C Address |
|-------------|-------------|-------------|
| IMU/Accelerometer | MPU6050 | 0x68 |
| IMU/Accelerometer | BMI160/BMI260 | 0x68 |
| IMU/Accelerometer | ICM-42670-P | 0x68 |
| Temperature & Humidity | SHT30/SHT31 | 0x44 |
| Pressure | BMP280/BME280 | 0x76 |
| Temperature & Humidity | SHTC3 | 0x70 |

### I2C Bus Connection (esp-rust-board standard)

| Signal | GPIO  |
|--------|-------|
| SDA    | GPIO10 |
| SCL    | GPIO8  |

## Understanding ADC (Analog-to-Digital Converter)

ADC converts analog voltage signals (continuous) into digital values (discrete) that microcontrollers can process.

### How ADC Works

1. **Sampling**: Measures voltage at specific point in time
2. **Quantization**: Maps continuous voltage to discrete digital value
3. **Encoding**: Represents value as binary number

**Key Parameters:**

- **Resolution**: Number of bits (ESP32-S3: 12-bit = 0-4095)
- **Range**: Voltage range (ESP32: 0-3.3V)
- **Sampling rate**: How fast conversions occur
- **Accuracy**: How close measurement is to true value

### ADC Limitations

{{< alert icon="triangle-exclamation" cardColor="#fff3cd" iconColor="#856404" >}}
**ADC Constraints:**
- **Pin restrictions**: Some GPIO pins have ADC, some don't
- **Shared ADC channels**: Multiple pins may share same ADC channel
- **Noise**: Electrical noise affects accuracy
- **Non-linearity**: Response may not be perfectly linear
- **Special pins**: Some pins used by internal peripherals (strapping pins, XTAL)
{{< /alert >}}

### ESP32-S3 ADC Specifics

- **Scaled output**: Returns 0-65520 (not raw 12-bit 0-4095)
- **ADC1 vs ADC2**: ADC1 channels more flexible, ADC2 shared with Wi-Fi
- **XTAL constraints**: GPIO15/16 used by 32kHz crystal (avoid for ADC)
- **Recommended ADC1 pins**: GPIO4 (ADC1_CH0), GPIO6 (ADC1_CH2)

### ADC Applications

**Common analog sensors:**
- **Joysticks**: Two potentiometers (X and Y axes)
- **Temperature sensors**: TMP36 (10mV/°C)
- **Light sensors**: Photoresistors with voltage dividers
- **Potentiometers**: User input controls
- **Distance sensors**: Analog IR distance sensors

## Get the Source Code

The complete source code for this assignment is available in the [developer-portal-codebase](https://github.com/espressif/developer-portal-codebase) repository:

```bash
git clone https://github.com/espressif/developer-portal-codebase.git
cd developer-portal-codebase/content/workshops/tinygo/assignment_4
```

Available examples:
- `main.go` - Basic ICM-42670-P IMU sensor reading
- `motion.go` - Motion detection with threshold triggering
- `joystick.go` - Dual-axis joystick ADC reader with oversampling
- `game.go` - Interactive ASCII art game controlled by joystick
- `display.go` - Display accelerometer readings on LCD (M5Stack Core2)

Each example is a complete working program. Build by specifying the source file:

```bash
# Example: Build joystick reader for ESP32-S3
tinygo flash -target esp32s3-generic joystick.go
```

## Example 1: Reading IMU Sensors

This example demonstrates I2C sensor reading using raw I2C commands. Works with ICM-42670-P, BMI160, or compatible IMU sensors.

### Hardware Setup

**IMU Sensor Connection:**
```
Sensor Module          ESP32-S3
┌─────────────┐         ┌──────────┐
│ VCC         ├─────────┤ 3.3V     │
│ GND         ├─────────┤ GND      │
│ SCL         ├─────────┤ GPIO8    │
│ SDA         ├─────────┤ GPIO10   │
└─────────────┘         └──────────┘
```

### Code

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/i2csoft"
)

// GPIO Configuration for I2C bus
const (
    I2C_SDA = machine.GPIO10 // I2C SDA pin
    I2C_SCL = machine.GPIO8  // I2C SCL pin
)

// I2C Sensor Address
const (
    IMU_I2C_ADDR = 0x68 // ICM-42670-P or BMI160
)

func main() {
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})

    i2c := i2csoft.New(I2C_SCL, I2C_SDA)
    i2c.Configure(i2csoft.I2CConfig{Frequency: 1e3}) // 1kHz for safety

    // Wake up ICM-42670-P
    i2c.WriteRegister(uint8(IMU_I2C_ADDR), 0x4D, 0x0F)
    time.Sleep(time.Millisecond * 50)

    serial.WriteString("IMU initialized\r\n")

    for {
        // Read accelerometer data via raw I2C
        data := make([]byte, 6)
        i2c.ReadRegister(uint8(IMU_I2C_ADDR), 0x1D, data)

        accelXRaw := int16(uint16(data[0])<<8 | uint16(data[1]))
        accelYRaw := int16(uint16(data[2])<<8 | uint16(data[3]))
        accelZRaw := int16(uint16(data[4])<<8 | uint16(data[5]))

        // Convert to g-force (ICM-42670-P: 2048 LSB/g)
        accelX := float32(accelXRaw) / 2048.0
        accelY := float32(accelYRaw) / 2048.0
        accelZ := float32(accelZRaw) / 2048.0

        // Output to serial
        serial.WriteString("X: ")
        printFloat(serial, accelX)
        serial.WriteString(" Y: ")
        printFloat(serial, accelY)
        serial.WriteString(" Z: ")
        printFloat(serial, accelZ)
        serial.WriteString("\r\n")

        time.Sleep(time.Millisecond * 100)
    }
}
```

**Build and flash:**

```bash
# ESP32-S3 (Recommended)
tinygo flash -target esp32s3-generic main.go

# ESP32-C3
tinygo flash -target esp32c3-generic main.go

# ESP32
tinygo flash -target esp32-generic main.go
```

## Example 2: Joystick ADC Reader

This example demonstrates ADC input reading using a dual-axis joystick. Features oversampling for noise reduction, deadzone filtering, and value normalization.

### Hardware Setup

**Joystick Connection (ESP32-S3):**
```
Joystick Module          ESP32-S3
┌─────────────┐         ┌──────────┐
│ VCC         ├─────────┤ 3.3V     │
│ GND         ├─────────┤ GND      │
│ VRX (X-axis)├─────────┤ GPIO4    │
│ VRY (Y-axis)├─────────┤ GPIO6    │
└─────────────┘         └──────────┘
```

### How Joystick ADC Works

Joysticks contain two potentiometers (variable resistors), one for each axis:

1. Each potentiometer acts as a voltage divider
2. Wiper output voltage varies from 0V to 3.3V based on position
3. ESP32 ADC converts voltage to digital value (0-65520)

**ADC Value Mapping:**
```
LEFT/UP position:    0 (0V)       → Direction -1.0
Center position:     ~32760 (1.65V)  → Direction 0.0 (in deadzone)
RIGHT/DOWN position: 65520 (3.3V)      → Direction 1.0
```

### Code

{{< tabs groupId="board" >}}
  {{% tab name="ESP32-S3" %}}
**joystick.go for ESP32-S3:**

```go
package main

import (
    "machine"
    "time"
)

// GPIO Configuration for Joystick ADC pins
const (
    JOYSTICK_X_PIN = machine.ADC4 // X-axis - GPIO4 (ADC1_CH0)
    JOYSTICK_Y_PIN = machine.ADC6 // Y-axis - GPIO6 (ADC1_CH2)
)

// ADC Configuration
const (
    ADC_RESOLUTION    = 65520 // ESP32-S3 ADC returns scaled 0-65520
    JOYSTICK_CENTER   = 32760 // Center position (approximately 50%)
    JOYSTICK_DEADZONE = 10000 // Deadzone around center
)

func main() {
    machine.InitADC()

    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})

    joystickX := machine.ADC{Pin: JOYSTICK_X_PIN}
    joystickX.Configure(machine.ADCConfig{})

    joystickY := machine.ADC{Pin: JOYSTICK_Y_PIN}
    joystickY.Configure(machine.ADCConfig{})

    time.Sleep(time.Millisecond * 100)

    serial.WriteString("Joystick ADC Reader\r\n")
    serial.WriteString("Format: X=[0-65520] Y=[0-65520] | Dir: [x,y]\r\n\r\n")

    for {
        rawX := readADC(joystickX)
        rawY := readADC(joystickY)

        // Convert to direction (-1.0 to 1.0)
        dirX := getDirection(rawX)
        dirY := getDirection(rawY)

        serial.WriteString("X=")
        printInt(serial, rawX)
        serial.WriteString(" Y=")
        printInt(serial, rawY)
        serial.WriteString(" | Dir: [")
        printFloat(serial, float32(dirX))
        serial.WriteString(",")
        printFloat(serial, float32(dirY))
        serial.WriteString("]\r\n")

        time.Sleep(time.Millisecond * 100)
    }
}

func readADC(adc machine.ADC) uint32 {
    const samples = 10
    var sum uint32

    for i := 0; i < samples; i++ {
        sum += uint32(adc.Get())
        time.Sleep(time.Microsecond * 100)
    }

    return sum / samples
}

func getDirection(value uint32) int {
    if value < JOYSTICK_CENTER-JOYSTICK_DEADZONE {
        return -1
    } else if value > JOYSTICK_CENTER+JOYSTICK_DEADZONE {
        return 1
    }
    return 0
}
```

**Build:**
```bash
tinygo flash -target esp32s3-generic joystick.go
```

  {{% /tab %}}

  {{% tab name="ESP32-C3" %}}
**joystick.go for ESP32-C3:**

Change pin configuration:
```go
const (
    JOYSTICK_X_PIN = machine.ADC0 // X-axis - GPIO0 (ADC1_CH0)
    JOYSTICK_Y_PIN = machine.ADC3 // Y-axis - GPIO3 (ADC1_CH3)
)
```

**Build:**
```bash
tinygo flash -target esp32c3-generic joystick.go
```

  {{% /tab %}}

  {{% tab name="ESP32" %}}
**joystick.go for ESP32:**

Change pin configuration:
```go
const (
    JOYSTICK_X_PIN = machine.ADC1_CH0 // X-axis - GPIO36
    JOYSTICK_Y_PIN = machine.ADC1_CH3 // Y-axis - GPIO39
)
```

**Build:**
```bash
tinygo flash -target esp32-generic joystick.go
```

  {{% /tab %}}
{{< /tabs >}}

## Example 3: Joystick-Controlled Game

This example demonstrates building an interactive game controlled by joystick input. Features real-time input processing, state management, and ANSI terminal rendering.

### Game Mechanics

The game runs a continuous loop:

1. **Read ADC values** from joystick (5-sample oversampling)
2. **Convert to direction** using deadzone detection
3. **Update player position** at fixed time intervals (150ms)
4. **Check collision** with goal (spawn new goal on collect)
5. **Render game board** using ANSI escape codes

**Direction Detection:**
```
ADC Value < 22760 (center - 10000) → Direction -1 (UP/LEFT)
ADC Value > 42760 (center + 10000) → Direction +1 (DOWN/RIGHT)
ADC Value in range                  → Direction 0 (CENTER/NO MOVE)
```

### Code

```go
package main

import (
    "machine"
    "time"
)

// Game Configuration
const (
    BOARD_WIDTH  = 20
    BOARD_HEIGHT = 10
    ADC_RESOLUTION    = 65520
    JOYSTICK_CENTER   = 32760
    JOYSTICK_DEADZONE = 10000
)

// Game State
type GameState struct {
    playerX   int
    playerY   int
    goalX     int
    goalY     int
    score     int
    joystickX *machine.ADC
    joystickY *machine.ADC
}

func main() {
    machine.InitADC()

    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})

    game := &GameState{
        playerX:   BOARD_WIDTH / 2,
        playerY:   BOARD_HEIGHT / 2,
        goalX:     5,
        goalY:     5,
        score:     0,
        joystickX: &machine.ADC{Pin: machine.ADC4},
        joystickY: &machine.ADC{Pin: machine.ADC6},
    }
    game.joystickX.Configure(machine.ADCConfig{})
    game.joystickY.Configure(machine.ADCConfig{})

    time.Sleep(time.Millisecond * 100)

    // Clear screen
    serial.Write([]byte("\033[2J\033[H"))
    serial.Write([]byte("=== Joystick Game ===\r\n"))
    serial.Write([]byte("Collect stars (*) with @\r\n\r\n"))

    lastMove := time.Now()
    moveDelay := time.Millisecond * 150

    for {
        rawX := readADC(game.joystickX)
        rawY := readADC(game.joystickY)

        dirX := getDirection(rawX)
        dirY := getDirection(rawY)

        if time.Since(lastMove) > moveDelay {
            if dirX != 0 || dirY != 0 {
                game.movePlayer(dirX, dirY)
            }
            lastMove = time.Now()
        }

        game.render(serial, rawX, rawY, dirX, dirY)
        time.Sleep(time.Millisecond * 50)
    }
}

func (g *GameState) movePlayer(dirX, dirY int) {
    g.playerX += dirX
    g.playerY += dirY

    // Keep player in bounds
    if g.playerX < 0 {
        g.playerX = 0
    }
    if g.playerX >= BOARD_WIDTH {
        g.playerX = BOARD_WIDTH - 1
    }
    if g.playerY < 0 {
        g.playerY = 0
    }
    if g.playerY >= BOARD_HEIGHT {
        g.playerY = BOARD_HEIGHT - 1
    }

    // Check if player reached goal
    if g.playerX == g.goalX && g.playerY == g.goalY {
        g.score++
        g.spawnGoal()
    }
}

func (g *GameState) spawnGoal() {
    ticks := time.Now().UnixNano()
    g.goalX = int(ticks % BOARD_WIDTH)
    g.goalY = int((ticks / BOARD_WIDTH) % BOARD_HEIGHT)
}

func (g *GameState) render(serial machine.Serialer, rawX, rawY uint32, dirX, dirY int) {
    serial.Write([]byte("\033[6;0f")) // Move cursor

    // Draw board
    serial.Write([]byte("+"))
    for i := 0; i < BOARD_WIDTH; i++ {
        serial.Write([]byte("-"))
    }
    serial.Write([]byte("+\r\n"))

    for y := 0; y < BOARD_HEIGHT; y++ {
        serial.Write([]byte("|"))
        for x := 0; x < BOARD_WIDTH; x++ {
            if x == g.playerX && y == g.playerY {
                serial.Write([]byte("@")) // Player
            } else if x == g.goalX && y == g.goalY {
                serial.Write([]byte("*")) // Goal
            } else {
                serial.Write([]byte("."))
            }
        }
        serial.Write([]byte("|\r\n"))
    }

    serial.Write([]byte("+"))
    for i := 0; i < BOARD_WIDTH; i++ {
        serial.Write([]byte("-"))
    }
    serial.Write([]byte("+\r\n")

    serial.Write([]byte("\r\nScore: "))
    printInt(serial, uint32(g.score))
}

func readADC(adc *machine.ADC) uint32 {
    const samples = 5
    var sum uint32

    for i := 0; i < samples; i++ {
        sum += uint32(adc.Get())
        time.Sleep(time.Microsecond * 50)
    }

    return sum / samples
}

func getDirection(value uint32) int {
    if value < JOYSTICK_CENTER-JOYSTICK_DEADZONE {
        return -1
    } else if value > JOYSTICK_CENTER+JOYSTICK_DEADZONE {
        return 1
    }
    return 0
}
```

**Build and run:**

```bash
tinygo flash -target esp32s3-generic game.go
```

**Monitoring the game:**

Use `screen` or `picocom` for proper ANSI terminal support:
```bash
screen /dev/ttyUSB0 115200
picocom -b 115200 /dev/ttyUSB0
```

{{< alert icon="triangle-exclamation" cardColor="#fff3cd" iconColor="#856404" >}}
**Note:** ANSI escape codes may not display correctly in `tinygo monitor` or basic serial terminals. Use a VT100-compatible terminal like `screen` or `picocom`.
{{< /alert >}}

## Troubleshooting

### I2C Sensor Issues

**"Sensor not found"**
- Check I2C address matches your sensor
- Verify wiring (SDA, SCL, VCC, GND)
- Ensure pull-up resistors are present (2.2kΩ - 10kΩ)
- Try slower I2C frequency (1kHz for testing)

**"Readings are zero/incorrect"**
- Check sensor is properly initialized (wake-up command)
- Verify I2C frequency - some sensors need slower speed
- Check sensor datasheet for correct register addresses
- Ensure proper data type conversion (little-endian vs big-endian)

### ADC Issues

**"ADC values stuck at ~30400"**
- Pin may be used by internal peripheral (XTAL, strapping pin)
- Try different ADC pin (avoid GPIO15/16 on ESP32-S3)
- Use ADC1 channels instead of ADC2

**"ADC readings noisy"**
- Use oversampling (average 5-10 samples)
- Add hardware filtering capacitor (10nF to 100nF)
- Keep wires short away from noise sources
- Use proper voltage divider for high-impedance sensors

### Game Display Issues

**"Screen not refreshing properly"**
- Use VT100-compatible terminal (`screen` or `picocom`)
- Check baud rate matches (115200)
- Verify ANSI escape codes supported by terminal

## Summary

In this assignment, you learned:
- How I2C communication works and its limitations
- Reading data from I2C sensors using raw commands
- ADC principles and ESP32-S3 ADC characteristics
- Building joystick input systems with deadzone filtering
- Creating interactive games with real-time input processing
- Oversampling techniques for noise reduction
- State management in game loops
- ANSI terminal rendering for console games

You can now gather data from both digital (I2C) and analog (ADC) sensors, and build interactive applications!

[Assignment 5: Wi-Fi Client](../assignment-5/)
