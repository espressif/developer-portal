---
title: "TinyGo Embedded Workshop - Assignment 5: Wi-Fi Client"
date: 2026-04-22T00:00:00+01:00
lastmod: 2026-04-22
showTableOfContents: false
series: ["WS002EN"]
series_order: 6
showAuthor: false
---

## Assignment 5: Wi-Fi Client

In this assignment, you'll learn to connect your ESP32 to Wi-Fi networks using the new `espradio` package introduced in TinyGo 0.41.

{{< alert icon="lightbulb" cardColor="#d1ecf1" iconColor="#0c5460" >}}
**Source Code Available:** All Wi-Fi examples are available in the [developer-portal-codebase](https://github.com/espressif/developer-portal-codebase) repository. See `content/workshops/tinygo/assignment_5/` for scan, connect, and HTTP client examples.
{{< /alert >}}

## Wi-Fi on ESP32 with TinyGo 0.41

TinyGo 0.41 introduces native Wi-Fi support for ESP32-C3 and ESP32-S3 through the `espradio` package.

### Key Features

- **Wi-Fi scanning**: Discover available networks
- **Wi-Fi connection**: Connect to WPA/WPA2 networks
- **HTTP client**: Fetch data from web servers
- **TCP/UDP**: Network communication
- **Direct flashing**: No external tools needed (espflasher)

### espradio Package

The `tinygo.org/x/espradio` package provides Wi-Fi functionality:
- **netdev**: Network device interface
- **netlink**: Network configuration
- **Wi-Fi**: 802.11 wireless networking

### espradio Package

The `tinygo.org/x/espradio` package provides Wi-Fi functionality:
- **netdev**: Network device interface
- **netlink**: Network configuration
- **Wi-Fi**: 802.11 wireless networking

### Board Support

**Wi-Fi is supported on:**
- **ESP32-C3**: esp32c3-generic target
- **ESP32-S3**: esp32s3-generic target

**NOT supported:**
- ESP32 (original) - use ESP32-C3 or ESP32-S3 for Wi-Fi

### Prerequisites

Before using Wi-Fi examples, download required dependencies:

```bash
go mod download tinygo.org/x/espradio
go mod download tinygo.org/x/drivers
go mod download tinygo.org/x/espradio/netlink
```

This ensures the Wi-Fi radio, network driver, and netlink packages are available for TinyGo.

### Radio Initialization

The `NetConnect()` method handles radio initialization automatically. No manual `espradio.Enable()` or `espradio.Start()` calls needed.

## Get the Source Code

The complete source code for this assignment is available in the [developer-portal-codebase](https://github.com/espressif/developer-portal-codebase) repository:

```bash
git clone https://github.com/espressif/developer-portal-codebase.git
cd developer-portal-codebase/content/workshops/tinygo/assignment_5
```

Available examples:
- `scan.go` - Wi-Fi network scanner (no credentials needed)
- `connect.go` - Wi-Fi connection with IP display
- `http_client.go` - HTTP client fetching webpage

**Workshop credentials:**
- SSID: `tinygo`
- Password: `gophercamp`

Build examples:
```bash
# Scan for networks (no credentials needed)
tinygo flash -target esp32c3-generic scan.go

# Connect to Wi-Fi
tinygo flash -target esp32c3-generic \
  -ldflags="-X main.ssid=tinygo -X main.password=gophercamp" \
  connect.go
```

See the README.md in the assignment directory for detailed instructions.

## Wi-Fi Scanner

### Step 1: Create Project

```bash
mkdir wifi-scan
cd wifi-scan
go mod init wifi-scan
```

### Step 2: Scan Wi-Fi Networks

Create `scan.go`:

```go
package main

import (
    "machine"
    "time"

    "tinygo.org/x/drivers/netdev"
    link "tinygo.org/x/espradio/netlink"
    "tinygo.org/x/espradio"
)

func main() {
    // Initialize serial for output
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})
    serial.Write([]byte("Wi-Fi Scanner\r\n"))

    // Wait for serial to be ready
    time.Sleep(2 * time.Second)

    // Initialize espradio link for netdev
    radioLink := link.Esplink{}
    netdev.UseNetdev(&radioLink)

    // Initialize espradio link for netdev
    radioLink := link.Esplink{}
    netdev.UseNetdev(&radioLink)

    serial.Write([]byte("Scanning for networks...\r\n"))

    // Scan for networks
    networks, err := espradio.Scan()
    if err != nil {
        serial.Write([]byte("Scan failed: "))
        serial.Write([]byte(err.Error()))
        serial.Write([]byte("\r\n"))
        return
    }

    serial.Write([]byte("Found "))
    writeInt(serial, len(networks))
    serial.Write([]byte(" networks:\r\n\r\n"))

    // Display networks
    for i, net := range networks {
        writeInt(serial, i+1)
        serial.Write([]byte(". SSID: "))
        serial.Write([]byte(net.SSID))
        serial.Write([]byte("\r\n   RSSI: "))
        writeInt(serial, net.RSSI)
        serial.Write([]byte(" dBm\r\n\r\n"))
    }

    serial.Write([]byte("Scan complete!\r\n"))

    for {
        time.Sleep(time.Second)
    }
}

func writeInt(serial machine.Serialer, n int) {
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

### Step 3: Build and Flash

{{< tabs groupId="board" >}}
  {{% tab name="ESP32-C3" %}}
```bash
tinygo flash -target esp32c3-generic scan.go
```
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
```bash
tinygo flash -target esp32s3-generic scan.go
```
  {{% /tab %}}
{{< /tabs >}}

Note: Wi-Fi scanning does not require credentials.

{{< alert icon="triangle-exclamation" cardColor="#fff3cd" iconColor="#856404" >}}
**Note:** Wi-Fi is not supported on ESP32 (original). Use ESP32-C3 or ESP32-S3 boards.
{{< /alert >}}

## Connecting to Wi-Fi

### Wi-Fi Connection Example

Create `connect.go`:

```go
package main

import (
    "machine"
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
    serial.Write([]byte("Wi-Fi Connection Test\r\n"))

    time.Sleep(2 * time.Second)

    // Initialize radio link for netdev
    radioLink := link.Esplink{}
    netdev.UseNetdev(&radioLink)

    // Connect to Wi-Fi
    serial.Write([]byte("Connecting to "))
    serial.Write([]byte(ssid))
    serial.Write([]byte("...\r\n"))

    err := radioLink.NetConnect(&nl.ConnectParams{
        Ssid:       ssid,
        Passphrase: password,
    })

    if err != nil {
        serial.Write([]byte("Connection failed\r\n"))
        return
    }

    serial.Write([]byte("Connected!\r\n"))

    // Get IP address
    addr, err := radioLink.Addr()
    if err != nil {
        serial.Write([]byte("Error getting address\r\n"))
        return
    }

    serial.Write([]byte("IP Address: "))
    serial.Write([]byte(addr.String()))
    serial.Write([]byte("\r\n"))

    // Keep connection alive
    for {
        time.Sleep(time.Second)
    }
}
```

### Passing Credentials at Compile Time

Workshop credentials for this session:
- **SSID**: `tinygo`
- **Password**: `gophercamp`

Build with credentials:
```bash
# ESP32-C3
tinygo flash -target esp32c3-generic \
  -ldflags="-X main.ssid=tinygo -X main.password=gophercamp" \
  connect.go

# ESP32-S3
tinygo flash -target esp32s3-generic \
  -ldflags="-X main.ssid=tinygo -X main.password=gophercamp" \
  connect.go
```

## HTTP Client

### Fetch Web Page

Create `http_client.go`:

```go
package main

import (
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
    serial.Write([]byte("HTTP Client Test\r\n"))

    time.Sleep(2 * time.Second)

    // Connect to Wi-Fi
    radioLink := link.Esplink{}
    netdev.UseNetdev(&radioLink)

    serial.Write([]byte("Connecting to Wi-Fi...\r\n"))
    err := radioLink.NetConnect(&nl.ConnectParams{
        Ssid:       ssid,
        Passphrase: password,
    })

    if err != nil {
        serial.Write([]byte("Connection failed\r\n"))
        return
    }

    serial.Write([]byte("Connected!\r\n"))

    // Wait for DHCP
    time.Sleep(5 * time.Second)

    // Fetch webpage from local gateway
    serial.Write([]byte("Fetching http://192.168.4.1...\r\n"))

    resp, err := http.Get("http://192.168.4.1")
    if err != nil {
        serial.Write([]byte("HTTP GET failed: "))
        serial.Write([]byte(err.Error()))
        serial.Write([]byte("\r\n"))
        return
    }
    defer resp.Body.Close()

    serial.Write([]byte("Status: "))
    writeInt(serial, resp.StatusCode)
    serial.Write([]byte("\r\n\r\n"))

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

    serial.Write([]byte("\r\n\r\nDone!\r\n"))

    for {
        time.Sleep(time.Second)
    }
}

func writeInt(serial machine.Serialer, n int) {
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

**Build and flash:**
```bash
# ESP32-C3
tinygo flash -target esp32c3-generic \
  -ldflags="-X main.ssid=tinygo -X main.password=gophercamp" \
  http_client.go

# ESP32-S3
tinygo flash -target esp32s3-generic \
  -ldflags="-X main.ssid=tinygo -X main.password=gophercamp" \
  http_client.go
```

## Wi-Fi Connection Management

### Check Connection Status

```go
// Check if connected
if radioLink.NetIsConnected() {
    serial.Write([]byte("Connected\r\n"))

    // Get signal strength
    rssi := radioLink.RSSI()
    serial.Write([]byte("RSSI: "))
    writeInt(serial, int(rssi))
    serial.Write([]byte(" dBm\r\n"))
} else {
    serial.Write([]byte("Not connected\r\n"))
}
```

### Disconnect

```go
err := radioLink.NetDisconnect()
if err != nil {
    serial.Write([]byte("Disconnect failed\r\n"))
}
```

## Troubleshooting

### "Wi-Fi not supported"

- Check board target (ESP32-C3 or ESP32-S3 only)
- Verify TinyGo 0.41+ installed
- ESP32 (original) doesn't support Wi-Fi in TinyGo

### "Connection timeout"

- Verify SSID and password are correct
- Check network is 2.4GHz (ESP32 doesn't support 5GHz)
- Ensure Wi-Fi router is within range
- Try moving closer to router

### "DHCP timeout"

- Wait longer after connection (up to 30 seconds)
- Check router has DHCP enabled
- Verify network has available IP addresses
- Try static IP configuration

### "HTTP request failed"

- Ensure Wi-Fi connection is established
- Check DNS is working (try IP address instead of hostname)
- Verify firewall allows outbound connections
- Check URL is correct (http:// not https://)

### Board not detected

- Check USB cable (must support data)
- Try different USB port
- Verify correct port (`/dev/ttyUSB0`, `/dev/ttyACM0`)
- Check board is powered (LED lit)

## Wi-Fi Security Notes

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
- How to scan for Wi-Fi networks
- Connect to WPA/WPA2 networks
- Configure Wi-Fi with credentials
- Use HTTP client to fetch web pages
- Send HTTP POST requests
- Manage Wi-Fi connection status
- Troubleshoot Wi-Fi connectivity

You can now connect your ESP32 to the internet!

## Simulation with Wokwi

You can simulate Wi-Fi projects using Wokwi! Wokwi provides simulated Wi-Fi connectivity for testing.

### Wokwi Web Simulator

1. Visit [wokwi.com/esp32](https://wokwi.com/esp32)
2. ESP32-C3 board is pre-configured with Wi-Fi
3. Copy your Wi-Fi code to the editor
4. Click "Run" to start simulation
5. View serial output to see Wi-Fi connection status

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
  "author": "TinyGo Wi-Fi Workshop",
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
tinygo build -target m5stack-stampc3 -o firmware.bin \
  -ldflags="-X main.ssid=YourSSID -X main.password=YourPassword" .

# Or for ESP32-S3:
# tinygo build -target esp32s3-generic -o firmware.bin \
#   -ldflags="-X main.ssid=YourSSID -X main.password=YourPassword" .

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

### Wi-Fi Simulation in Wokwi

**Important Notes:**
- Wokwi simulates Wi-Fi connectivity (no actual network)
- HTTP requests are simulated with mock responses
- Perfect for testing code logic without hardware
- Always test on real hardware before deployment

**Testing Wi-Fi Code:**

```go
// This code will work in Wokwi simulation
// Wi-Fi connection will be simulated
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

[Assignment 6: Wi-Fi Server](../assignment-6/)
