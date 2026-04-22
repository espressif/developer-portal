---
title: "TinyGo Embedded Workshop - Assignment 5: WiFi Client"
date: 2026-04-22T00:00:00+01:00
showTableOfContents: false
series: ["WS002EN"]
series_order: 6
showAuthor: false
---

## Assignment 5: WiFi Client

In this assignment, you'll learn to connect your ESP32 to WiFi networks using the new `espradio` package introduced in TinyGo 0.41.

## WiFi on ESP32 with TinyGo 0.41

TinyGo 0.41 introduces native WiFi support for ESP32-C3 and ESP32-S3 through the `espradio` package.

### Key Features

- **WiFi scanning**: Discover available networks
- **WiFi connection**: Connect to WPA/WPA2 networks
- **HTTP client**: Fetch data from web servers
- **TCP/UDP**: Network communication
- **Direct flashing**: No external tools needed (espflasher)

### espradio Package

The `tinygo.org/x/espradio` package provides WiFi functionality:
- **netdev**: Network device interface
- **netlink**: Network configuration
- **WiFi**: 802.11 wireless networking

## WiFi Scanner

### Step 1: Create Project

```bash
mkdir wifi-scan
cd wifi-scan
go mod init wifi-scan
```

### Step 2: Scan WiFi Networks

Create `main.go`:

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/netdev"
    nl "tinygo.org/x/drivers/netlink"
    link "tinygo.org/x/espradio/netlink"
)

func main() {
    // Initialize serial for output
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})
    serial.WriteString("WiFi Scanner\r\n")

    // Wait for serial to be ready
    time.Sleep(2 * time.Second)

    // Initialize espradio link
    radioLink := link.Esplink{}
    netdev.UseNetdev(&radioLink)

    serial.WriteString("Scanning for networks...\r\n")

    // Scan for networks
    networks := radioLink.ScanNetworks()

    serial.WriteString("Found ")
    printInt(serial, len(networks))
    serial.WriteString(" networks:\r\n\r\n")

    // Display networks
    for i, net := range networks {
        printInt(serial, i+1)
        serial.WriteString(". SSID: ")
        serial.WriteString(net.Ssid)
        serial.WriteString("\r\n   BSSID: ")
        for j := 0; j < len(net.Bssid); j++ {
            printHex(serial, net.Bssid[j])
            if j < len(net.Bssid)-1 {
                serial.WriteString(":")
            }
        }
        serial.WriteString("\r\n   Channel: ")
        printInt(serial, int(net.Channel))
        serial.WriteString("\r\n   RSSI: ")
        printInt(serial, int(net.Rssi))
        serial.WriteString(" dBm\r\n")
        serial.WriteString("   Auth: ")
        serial.WriteString(authModeToString(net.AuthMode))
        serial.WriteString("\r\n\r\n")
    }

    serial.WriteString("Scan complete!\r\n")

    for {
        time.Sleep(time.Second)
    }
}

func authModeToString(auth nl.AuthMode) string {
    switch auth {
    case nl.AUTH_OPEN:
        return "Open"
    case nl.AUTH_WEP:
        return "WEP"
    case nl.AUTH_WPA_PSK:
        return "WPA-PSK"
    case nl.AUTH_WPA2_PSK:
        return "WPA2-PSK"
    case nl.AUTH_WPA_WPA2_PSK:
        return "WPA/WPA2-PSK"
    default:
        return "Unknown"
    }
}

func printInt(serial machine.UART, n int) {
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

func printHex(serial machine.UART, b byte) {
    hex := "0123456789ABCDEF"
    serial.WriteByte(hex[b>>4])
    serial.WriteByte(hex[b&0x0F])
}
```

### Step 3: Build and Flash

{{< tabs groupId="board" >}}
  {{% tab name="M5Stack StampC3" %}}
```bash
tinygo flash -target m5stack-stampc3 -port /dev/ttyUSB0 .
```
  {{% /tab %}}

  {{% tab name="XIAO-ESP32C3" %}}
```bash
tinygo flash -target xiao-esp32c3 -port /dev/ttyACM0 .
```
  {{% /tab %}}

  {{% tab name="XIAO-ESP32S3" %}}
```bash
tinygo flash -target xiao-esp32s3 -port /dev/ttyACM0 .
```
  {{% /tab %}}
{{< /tabs >}}

{{< alert icon="triangle-exclamation" cardColor="#f8d7da" iconColor="#721c24" >}}
**Important:** WiFi is not supported on M5Stack Core2 (ESP32 original). Use ESP32-C3 or ESP32-S3 boards.
{{< /alert >}}

## Connecting to WiFi

### WiFi Connection Example

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/netdev"
    nl "tinygo.org/x/drivers/netlink"
    link "tinygo.org/x/espradio/netlink"
)

// WiFi credentials (compile-time flags)
var ssid string = "YourWiFiSSID"
var password string = "YourWiFiPassword"

func main() {
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})
    serial.WriteString("WiFi Connection Test\r\n")

    time.Sleep(2 * time.Second)

    // Initialize radio
    radioLink := link.Esplink{}
    netdev.UseNetdev(&radioLink)

    // Connect to WiFi
    serial.WriteString("Connecting to ")
    serial.WriteString(ssid)
    serial.WriteString("...\r\n")

    err := radioLink.NetConnect(&nl.ConnectParams{
        Ssid:       ssid,
        Passphrase: password,
    })

    if err != nil {
        serial.WriteString("Connection failed: ")
        serial.WriteString(err.Error())
        serial.WriteString("\r\n")
        return
    }

    serial.WriteString("Connected!\r\n")

    // Get IP address
    addr, err := radioLink.Addr()
    if err != nil {
        serial.WriteString("Error getting address\r\n")
        return
    }

    serial.WriteString("IP Address: ")
    serial.WriteString(addr.String())
    serial.WriteString("\r\n")

    // Keep connection alive
    for {
        time.Sleep(time.Second)
    }
}
```

### Passing Credentials at Compile Time

Instead of hardcoding credentials, pass them at compile time:

```go
var ssid string
var password string
```

Build with credentials:
```bash
tinygo flash -target xiao-esp32c3 \
  -ldflags="-X main.ssid=YourSSID -X main.password=YourPassword" \
  -port /dev/ttyACM0 .
```

## HTTP Client

### Fetch Web Page

```go
package main

import (
    "io"
    "machine"
    "net/http"
    "time"

    "tinygo.org/x/drivers/netdev"
    nl "tinygo.org/x/drivers/netlink"
    link "tinygo.org/x/espradio/netlink"
)

var ssid string
var password string

func main() {
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})
    serial.WriteString("HTTP Client Test\r\n")

    time.Sleep(2 * time.Second)

    // Connect to WiFi
    radioLink := link.Esplink{}
    netdev.UseNetdev(&radioLink)

    serial.WriteString("Connecting to WiFi...\r\n")
    err := radioLink.NetConnect(&nl.ConnectParams{
        Ssid:       ssid,
        Passphrase: password,
    })

    if err != nil {
        serial.WriteString("Connection failed\r\n")
        return
    }

    serial.WriteString("Connected!\r\n")

    // Wait for DHCP
    time.Sleep(5 * time.Second)

    // Fetch webpage
    serial.WriteString("Fetching http://example.com...\r\n")

    resp, err := http.Get("http://example.com")
    if err != nil {
        serial.WriteString("HTTP GET failed: ")
        serial.WriteString(err.Error())
        serial.WriteString("\r\n")
        return
    }
    defer resp.Body.Close()

    serial.WriteString("Status: ")
    printInt(serial, resp.StatusCode)
    serial.WriteString("\r\n\r\n")

    // Read response
    buf := make([]byte, 256)
    for {
        n, err := resp.Body.Read(buf)
        if n > 0 {
            serial.Write(buf[:n])
        }
        if err != nil {
            break
        }
    }

    serial.WriteString("\r\n\r\nDone!\r\n")

    for {
        time.Sleep(time.Second)
    }
}

func printInt(serial machine.UART, n int) {
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

## HTTP POST Request

### Send Data to Server

```go
serial.WriteString("Sending POST request...\r\n")

resp, err := http.Post(
    "http://httpbin.org/post",
    "application/json",
    strings.NewReader(`{"sensor": "temperature", "value": 23.5}`),
)

if err != nil {
    serial.WriteString("POST failed\r\n")
    return
}
defer resp.Body.Close()

serial.WriteString("Response: ")
printInt(serial, resp.StatusCode)
serial.WriteString("\r\n")
```

## WiFi Connection Management

### Check Connection Status

```go
// Check if connected
if radioLink.NetIsConnected() {
    serial.WriteString("Connected\r\n")

    // Get signal strength
    rssi := radioLink.RSSI()
    serial.WriteString("RSSI: ")
    printInt(serial, int(rssi))
    serial.WriteString(" dBm\r\n")
} else {
    serial.WriteString("Not connected\r\n")
}
```

### Disconnect

```go
err := radioLink.NetDisconnect()
if err != nil {
    serial.WriteString("Disconnect failed\r\n")
}
```

## Troubleshooting

### "WiFi not supported"

- Check board target (ESP32-C3 or ESP32-S3 only)
- Verify TinyGo 0.41+ installed
- M5Stack Core2 (ESP32) doesn't support WiFi in TinyGo

### "Connection timeout"

- Verify SSID and password are correct
- Check network is 2.4GHz (ESP32 doesn't support 5GHz)
- Ensure WiFi router is within range
- Try moving closer to router

### "DHCP timeout"

- Wait longer after connection (up to 30 seconds)
- Check router has DHCP enabled
- Verify network has available IP addresses
- Try static IP configuration

### "HTTP request failed"

- Ensure WiFi connection is established
- Check DNS is working (try IP address instead of hostname)
- Verify firewall allows outbound connections
- Check URL is correct (http:// not https://)

### Board not detected

- Check USB cable (must support data)
- Try different USB port
- Verify correct port (`/dev/ttyUSB0`, `/dev/ttyACM0`)
- Check board is powered (LED lit)

## WiFi Security Notes

{{< alert icon="shield-halved" cardColor="#d1ecf1" iconColor="#0c5460" >}}
**Security Best Practices:**

1. Never hardcode credentials in production code
2. Use compile-time flags for credentials
3. Store credentials in secure storage (NVS)
4. Use WPA2-PSK or WPA3 when available
5. Avoid open networks for production devices
{{< /alert >}}

## Summary

In this assignment, you learned:
- ✅ How to scan for WiFi networks
- ✅ Connect to WPA/WPA2 networks
- ✅ Configure WiFi with credentials
- ✅ Use HTTP client to fetch web pages
- ✅ Send HTTP POST requests
- ✅ Manage WiFi connection status
- ✅ Troubleshoot WiFi connectivity

You can now connect your ESP32 to the internet!

## Simulation with Wokwi

You can simulate WiFi projects using Wokwi! Wokwi provides simulated WiFi connectivity for testing.

### Wokwi Web Simulator

1. Visit [wokwi.com/esp32](https://wokwi.com/esp32)
2. ESP32-C3 board is pre-configured with WiFi
3. Copy your WiFi code to the editor
4. Click "Run" to start simulation
5. View serial output to see WiFi connection status

### Wokwi CLI (Command Line Interface)

For automated testing and CI/CD integration, use `wokwi-cli`.

**Installation:**

```bash
# Linux/macOS
curl -L https://wokwi.com/ci/install.sh | sh

# Windows
iwr https://wokwi.com/ci/install.ps1 -useb | iex
```

**Setup:**

1. Get API token from [Wokwi CI Dashboard](https://wokwi.com/dashboard/ci)
2. Set environment variable:
```bash
export WOKWI_CLI_TOKEN=your_token_here
```

**Create Configuration:**

Create `wokwi.toml`:

```toml
[wokwi]
version = 1
firmware = 'firmware.bin'
elf = 'firmware.elf'
```

Create `diagram.json`:

```json
{
  "version": 1,
  "author": "TinyGo WiFi Workshop",
  "editor": "wokwi",
  "parts": [
    {
      "type": "board-esp32-c3-devkitm-1",
      "id": "esp",
      "top": 0,
      "left": 0,
      "attrs": {}
    }
  ],
  "connections": [
    [ "esp:TX", "$serialMonitor:RX", "", [] ],
    [ "esp:RX", "$serialMonitor:TX", "", [] ]
  ]
}
```

**Build and Simulate:**

```bash
# Build firmware
tinygo build -target xiao-esp32c3 -o firmware.bin \
  -ldflags="-X main.ssid=YourSSID -X main.password=YourPassword" .

# Run simulation
wokwi-cli .
```

### VS Code with Wokwi Extension

**Install Extension:**
1. Open VS Code
2. Press `Ctrl+Shift+X` (Windows/Linux) or `Cmd+Shift+X` (macOS)
3. Search for "Wokwi for ESP-IDF"
4. Install the extension

**Run Simulation:**
1. Open your project folder in VS Code
2. Ensure `wokwi.toml` and `diagram.json` exist
3. Press `F1` and select "Wokwi: Start Simulator"
4. View simulation in browser

### WiFi Simulation in Wokwi

**Important Notes:**
- Wokwi simulates WiFi connectivity (no actual network)
- HTTP requests are simulated with mock responses
- Perfect for testing code logic without hardware
- Always test on real hardware before deployment

**Testing WiFi Code:**

```go
// This code will work in Wokwi simulation
// WiFi connection will be simulated
// HTTP requests return mock data
```

### Advanced: Initialize Wokwi Project

Use `wokwi-cli init` to create a new project:

```bash
# Interactive setup
wokwi-cli init my-wifi-project

# Creates wokwi.toml and diagram.json
# Prompts for board type, parts, etc.
```

### Lint Diagram

Validate your `diagram.json`:

```bash
wokwi-cli lint
```

{{< alert icon="lightbulb" cardColor="#fff3cd" iconColor="#856404" >}}
**Tip:** Wokwi simulation is excellent for learning and testing, but always verify your code on real hardware. Network behavior may differ between simulation and reality.
{{< /alert >}}

[Assignment 6: WiFi Server](../assignment-6/)
