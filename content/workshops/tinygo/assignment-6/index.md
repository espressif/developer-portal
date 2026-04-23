---
title: "TinyGo Embedded Workshop - Assignment 6: Wi-Fi Server"
date: 2026-04-22T00:00:00+01:00
lastmod: 2026-04-22
showTableOfContents: false
series: ["WS002EN"]
series_order: 7
showAuthor: false
---

## Assignment 6: Wi-Fi Server

In this assignment, you'll create an HTTP server running on your ESP32, serving web pages and controlling devices remotely.

{{< alert icon="lightbulb" cardColor="#d1ecf1" iconColor="#0c5460" >}}
**Source Code Available:** The HTTP server example is available in the [developer-portal-codebase](https://github.com/espressif/developer-portal-codebase) repository. See `content/workshops/tinygo/assignment_6/main.go` for the complete working web server.
{{< /alert >}}

## HTTP Server with TinyGo

TinyGo supports the standard `net/http` package on Wi-Fi-enabled boards, allowing you to create web servers easily.

### What You'll Build

- HTTP server with multiple endpoints
- Serve static HTML pages
- Control LED via web interface
- Handle multiple concurrent clients

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

## Get the Source Code

The complete source code for this assignment is available in the [developer-portal-codebase](https://github.com/espressif/developer-portal-codebase) repository:

```bash
git clone https://github.com/espressif/developer-portal-codebase.git
cd developer-portal-codebase/content/workshops/tinygo/assignment_6
```

The HTTP server example (`main.go`) includes:
- Web interface with LED control buttons
- JSON status endpoint
- Multiple route handlers
- ArenaPoolSize configuration for HTTP

**Workshop credentials:**
- SSID: `tinygo`
- Password: `gophercamp`

Build and flash:
```bash
# ESP32-C3
tinygo flash -target esp32c3-generic \
  -ldflags="-X main.ssid=tinygo -X main.password=gophercamp" \
  main.go
```

See the README.md in the assignment directory for detailed instructions.

## Basic HTTP Server

### Step 1: Create Project

```bash
mkdir wifi-server
cd wifi-server
go mod init wifi-server
```

**Workshop credentials for this session:**
- **SSID**: `tinygo`
- **Password**: `gophercamp`

### Step 2: Create HTTP Server

Create `main.go`:

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
var ledPin = machine.GPIO10

func main() {
    // Initialize LED
    ledPin.Configure(machine.PinConfig{Mode: machine.PinOutput})

    // Initialize serial
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})
    serial.Write([]byte("HTTP Server\r\n"))

    time.Sleep(2 * time.Second)

    // Connect to Wi-Fi with larger arena pool for HTTP
    radioLink := link.Esplink{
        ArenaPoolSize: 48 * 1024, // Larger pool for HTTP connections
    }
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

    // Get IP address
    addr, _ := radioLink.Addr()
    host := addr.String()
    serial.Write([]byte("Server: http://"))
    serial.Write([]byte(host))
    serial.Write([]byte(":8080\r\n"))

    // Setup HTTP routes
    http.Handle("/", logRequest(root))
    http.Handle("/led/on", logRequest(ledOn))
    http.Handle("/led/off", logRequest(ledOff))
    http.Handle("/status", logRequest(status))

    // Start server with explicit IP address
    serial.Write([]byte("Starting server...\r\n"))
    err = http.ListenAndServe(host+":8080", nil)
    if err != nil {
        serial.Write([]byte("Server error: "))
        serial.Write([]byte(err.Error()))
        serial.Write([]byte("\r\n"))
    }

    for {
        time.Sleep(time.Second)
    }
}

func logRequest(h http.HandlerFunc) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        serial := machine.Serial
        serial.Write([]byte(r.Method))
        serial.Write([]byte(" "))
        serial.Write([]byte(r.URL.Path))
        serial.Write([]byte("\r\n"))
        h(w, r)
    })
}

func root(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/html; charset=utf-8")
    io.WriteString(w, `<!DOCTYPE html>
<html>
<head>
    <title>ESP32 TinyGo Server</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        h1 { color: #333; }
        button { padding: 10px 20px; font-size: 16px; margin: 5px; }
        .on { background: #4CAF50; color: white; }
        .off { background: #f44336; color: white; }
    </style>
</head>
<body>
    <h1>ESP32 TinyGo Web Server</h1>
    <p>Welcome to the TinyGo HTTP Server!</p>

    <h2>LED Control</h2>
    <button class="on" onclick="fetch('/led/on')">LED ON</button>
    <button class="off" onclick="fetch('/led/off')">LED OFF</button>

    <h2>Status</h2>
    <button onclick="fetch('/status').then(r=>r.text()).then(d=>alert(d))">Check Status</button>

    <h2>About</h2>
    <p>This server is running on ESP32 with TinyGo 0.41</p>
    <p>Board: ESP32-C3 / ESP32-S3</p>
</body>
</html>`)
}

func ledOn(w http.ResponseWriter, r *http.Request) {
    ledPin.Low() // Active LOW
    w.Header().Set("Content-Type", "text/plain")
    io.WriteString(w, "LED ON")
}

func ledOff(w http.ResponseWriter, r *http.Request) {
    ledPin.High() // Active LOW
    w.Header().Set("Content-Type", "text/plain")
    io.WriteString(w, "LED OFF")
}

func status(w http.ResponseWriter, r *http.Request) {
    ledState := "OFF"
    if ledPin.Get() {
        ledState = "OFF" // Active LOW
    } else {
        ledState = "ON"
    }

    w.Header().Set("Content-Type", "application/json")
    io.WriteString(w, `{"led":"`+ledState+`","uptime":"`+getUptime()+`"}`)
}

func getUptime() string {
    return "unknown" // Simplified for example
}
```

### Step 3: Build and Flash

{{< tabs groupId="board" >}}
  {{% tab name="ESP32-C3" %}}
```bash
tinygo flash -target esp32c3-generic \
  -ldflags="-X main.ssid=tinygo -X main.password=gophercamp" \
  main.go
```
  {{% /tab %}}

  {{% tab name="ESP32-S3" %}}
```bash
tinygo flash -target esp32s3-generic \
  -ldflags="-X main.ssid=tinygo -X main.password=gophercamp" \
  main.go
```
  {{% /tab %}}
{{< /tabs >}}

### Step 4: Access Web Server

1. Watch serial output for IP address
2. Open browser: `http://YOUR_BOARD_IP:8080` (replace YOUR_BOARD_IP with actual IP)
3. Click buttons to control LED
4. Check status

## Troubleshooting

## Multiple Clients

The `net/http` server handles multiple concurrent clients automatically:

```go
// Server handles multiple requests concurrently
// Each request runs in its own goroutine
func data(w http.ResponseWriter, r *http.Request) {
    // Simulate long operation
    time.Sleep(time.Second * 2)
    io.WriteString(w, "Data after 2 seconds")
}
```

## Troubleshooting

### "Server not accessible"

- Verify Wi-Fi connection is established
- Check firewall allows incoming connections
- Ensure browser uses correct IP and port (http://YOUR_BOARD_IP:8080)
- Try accessing from different device

### "Connection refused"

- Verify server is running
- Check port 8080 is not blocked
- Ensure IP address is correct
- Try restarting the board

### "Server not accessible"

- Verify Wi-Fi connection is established
- Check firewall allows incoming connections
- Ensure browser uses correct IP and port (http://YOUR_BOARD_IP:8080)
- Try accessing from different device
- Server binds to actual IP address, not wildcard

### "Slow response"

- Reduce sensor update rate
- Optimize HTML page size
- Check Wi-Fi signal strength
- Reduce concurrent requests

## Security Considerations

{{< alert icon="shield-halved" cardColor="#d1ecf1" iconColor="#0c5460" >}}
**Security Notes:**

1. HTTP is not encrypted (use HTTPS for production)
2. No authentication by default (add password protection)
3. Open ports can be accessed by anyone on network
4. Validate all user inputs
5. Consider using API keys or tokens
{{< /alert >}}

## Performance Tips

1. **Keep responses small**: Minimize HTML and JSON size
2. **Cache static content**: Avoid regenerating same data
3. **Use appropriate timeouts**: Don't let connections hang
4. **Monitor memory**: ESP32 has limited RAM
5. **Test concurrent load**: Verify server handles multiple clients

## Summary

In this assignment, you learned:
- How to create an HTTP server on ESP32
- Serve static HTML pages
- Handle multiple routes and endpoints
- Control GPIO pins via web interface
- Display sensor data on web page
- Handle concurrent client requests
- Debug network issues

You can now create IoT devices with web interfaces!

[Assignment 7: AI Edge Models](../assignment-7/)
