---
title: "TinyGo Embedded Workshop - Assignment 6: WiFi Server"
date: 2026-04-22T00:00:00+01:00
showTableOfContents: false
series: ["WS002EN"]
series_order: 7
showAuthor: false
---

## Assignment 6: WiFi Server

In this assignment, you'll create an HTTP server running on your ESP32, serving web pages and controlling devices remotely.

## HTTP Server with TinyGo

TinyGo supports the standard `net/http` package on WiFi-enabled boards, allowing you to create web servers easily.

### What You'll Build

- HTTP server with multiple endpoints
- Serve static HTML pages
- Control LED via web interface
- Display sensor data on web page
- Handle multiple concurrent clients

## Basic HTTP Server

### Step 1: Create Project

```bash
mkdir wifi-server
cd wifi-server
go mod init wifi-server
```

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
    serial.WriteString("HTTP Server\r\n")

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

    // Get IP address
    addr, _ := radioLink.Addr()
    serial.WriteString("Server: http://")
    serial.WriteString(addr.String())
    serial.WriteString(":8080\r\n")

    // Setup HTTP routes
    http.Handle("/", logRequest(root))
    http.Handle("/led/on", logRequest(ledOn))
    http.Handle("/led/off", logRequest(ledOff))
    http.Handle("/status", logRequest(status))

    // Start server
    serial.WriteString("Starting server...\r\n")
    err = http.ListenAndServe(":8080", nil)
    if err != nil {
        serial.WriteString("Server error: ")
        serial.WriteString(err.Error())
        serial.WriteString("\r\n")
    }

    for {
        time.Sleep(time.Second)
    }
}

func logRequest(h http.HandlerFunc) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        serial := machine.Serial
        serial.WriteString(r.Method)
        serial.WriteString(" ")
        serial.WriteString(r.URL.Path)
        serial.WriteString("\r\n")
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
  {{% tab name="M5Stack StampC3" %}}
```bash
tinygo flash -target m5stack-stampc3 \
  -ldflags="-X main.ssid=YourSSID -X main.password=YourPassword" \
  -port /dev/ttyUSB0 .
```
  {{% /tab %}}

  {{% tab name="XIAO-ESP32C3" %}}
```bash
tinygo flash -target xiao-esp32c3 \
  -ldflags="-X main.ssid=YourSSID -X main.password=YourPassword" \
  -port /dev/ttyACM0 .
```
  {{% /tab %}}

  {{% tab name="XIAO-ESP32S3" %}}
```bash
tinygo flash -target xiao-esp32s3 \
  -ldflags="-X main.ssid=YourSSID -X main.password=YourPassword" \
  -port /dev/ttyACM0 .
```
  {{% /tab %}}
{{< /tabs >}}

### Step 4: Access Web Server

1. Watch serial output for IP address
2. Open browser: `http://<IP_ADDRESS>:8080`
3. Click buttons to control LED
4. Check status

## Advanced Server with Sensor Data

### Combine WiFi Server with Sensors

```go
package main

import (
    "io"
    "machine"
    "net/http"
    "strconv"
    "time"

    "tinygo.org/x/drivers/bmi260"
    "tinygo.org/x/drivers/i2csoft"
    "tinygo.org/x/drivers/netdev"
    nl "tinygo.org/x/drivers/netlink"
    link "tinygo.org/x/espradio/netlink"
)

var ssid string
var password string

// Sensor data
var accelX, accelY, accelZ float32
var temperature float32

func main() {
    // Initialize I2C and sensors
    i2c := i2csoft.New(machine.SCL0_PIN, machine.SDA0_PIN)
    i2c.Configure(i2csoft.I2CConfig{Frequency: 100e3})

    sensor := bmi260.New(i2c)
    sensor.Configure()

    // Initialize serial
    serial := machine.Serial
    serial.Configure(machine.UARTConfig{BaudRate: 115200})

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

    time.Sleep(5 * time.Second)

    // Get IP address
    addr, _ := radioLink.Addr()
    serial.WriteString("Server: http://")
    serial.WriteString(addr.String())
    serial.WriteString(":8080\r\n")

    // Setup routes
    http.Handle("/", logRequest(root))
    http.Handle("/data", logRequest(data))
    http.Handle("/json", logRequest(jsonData))

    // Start background sensor reading
    go readSensors(sensor)

    // Start server
    serial.WriteString("Starting server...\r\n")
    http.ListenAndServe(":8080", nil)
}

func readSensors(sensor *bmi260.Device) {
    for {
        accelX, accelY, accelZ = sensor.ReadAcceleration()
        time.Sleep(time.Millisecond * 100)
    }
}

func logRequest(h http.HandlerFunc) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        serial := machine.Serial
        serial.WriteString(r.Method)
        serial.WriteString(" ")
        serial.WriteString(r.URL.Path)
        serial.WriteString("\r\n")
        h(w, r)
    })
}

func root(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/html; charset=utf-8")
    io.WriteString(w, `<!DOCTYPE html>
<html>
<head>
    <title>ESP32 Sensor Server</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        h1 { color: #333; }
        .data { margin: 10px 0; padding: 10px; background: #f0f0f0; }
        button { padding: 10px 20px; font-size: 16px; }
    </style>
    <script>
        setInterval(function() {
            fetch('/json')
                .then(r=>r.json())
                .then(d=> {
                    document.getElementById('accel').innerText =
                        'X: ' + d.accelX.toFixed(2) + ' ' +
                        'Y: ' + d.accelY.toFixed(2) + ' ' +
                        'Z: ' + d.accelZ.toFixed(2);
                });
        }, 200);
    </script>
</head>
<body>
    <h1>ESP32 Sensor Server</h1>
    <div class="data">
        <strong>Accelerometer:</strong>
        <span id="accel">Loading...</span>
    </div>
    <button onclick="location.reload()">Refresh</button>
</body>
</html>`)
}

func data(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/plain")
    io.WriteString(w, "Accelerometer:\n")
    io.WriteString(w, "X: "+formatFloat(accelX)+"\n")
    io.WriteString(w, "Y: "+formatFloat(accelY)+"\n")
    io.WriteString(w, "Z: "+formatFloat(accelZ)+"\n")
}

func jsonData(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    io.WriteString(w, `{"accelX":`+formatFloat(accelX)+`,"accelY":`+formatFloat(accelY)+`,"accelZ":`+formatFloat(accelZ)+`}`)
}

func formatFloat(f float32) string {
    // Simple float formatting (same as Assignment 4)
    return "0.00" // Simplified
}
```

## WebSocket Support (Advanced)

For real-time updates, consider using WebSockets:

```go
// Note: WebSocket support may require additional packages
// This is a conceptual example

func wsHandler(w http.ResponseWriter, r *http.Request) {
    // Upgrade to WebSocket
    // Send sensor data in real-time
    // Handle client connections
}
```

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

- Verify WiFi connection is established
- Check firewall allows incoming connections
- Ensure browser uses correct IP and port (http://IP:8080)
- Try accessing from different device

### "Connection refused"

- Verify server is running
- Check port 8080 is not blocked
- Ensure IP address is correct
- Try restarting the board

### "Page not loading"

- Check HTTP handler is registered
- Verify HTML syntax is correct
- Ensure `Content-Type` header is set
- Check serial output for errors

### "Slow response"

- Reduce sensor update rate
- Optimize HTML page size
- Check WiFi signal strength
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
- ✅ How to create an HTTP server on ESP32
- ✅ Serve static HTML pages
- ✅ Handle multiple routes and endpoints
- ✅ Control GPIO pins via web interface
- ✅ Display sensor data on web page
- ✅ Handle concurrent client requests
- ✅ Debug network issues

You can now create IoT devices with web interfaces!

[Assignment 7: AI Edge Models](../assignment-7/)
