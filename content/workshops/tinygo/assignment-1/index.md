---
title: "TinyGo Embedded Workshop - Assignment 1: Install TinyGo"
date: 2026-04-22T00:00:00+01:00
lastmod: 2026-04-22
showTableOfContents: false
series: ["WS002EN"]
series_order: 2
showAuthor: false
---

## Assignment 1: Install TinyGo

You will need Go and TinyGo installed on your computer for this workshop. This assignment will guide you through the installation process.

## Install Go

First, install the Go programming language if you don't have it already.

{{< tabs groupId="os" >}}
  {{% tab name="Windows" %}}
**Installing Go on Windows**

1. Download the Go installer from [https://go.dev/dl/](https://go.dev/dl/)
2. Run the installer (e.g., `go1.22.5.windows-amd64.msi`)
3. Follow the installation wizard
4. Verify installation:
```bash
go version
```

Expected output:
```
go version go1.26.x windows/amd64
```
  {{% /tab %}}

  {{% tab name="macOS" %}}
**Installing Go on macOS**

1. Download the Go installer from [https://go.dev/dl/](https://go.dev/dl/)
2. Open the PKG file (e.g., `go1.26.x.darwin-amd64.pkg`)
3. Follow the installation wizard
4. Verify installation:
```bash
go version
```

Expected output:
```
go version go1.26.x darwin/amd64
```

**Alternative: Homebrew**
```bash
brew install go
```
  {{% /tab %}}

  {{% tab name="Linux" %}}
**Installing Go on Linux**

1. Download the Go archive from [https://go.dev/dl/](https://go.dev/dl/)
2. Extract the archive:
```bash
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.26.x.linux-amd64.tar.gz
```

3. Add Go to PATH by adding this to your `~/.profile` or `~/.bashrc`:
```bash
export PATH=$PATH:/usr/local/go/bin
```

4. Reload your profile:
```bash
source ~/.profile
```

5. Verify installation:
```bash
go version
```

Expected output:
```
go version go1.26.x linux/amd64
```
  {{% /tab %}}
{{< /tabs >}}

## Install TinyGo

TinyGo requires additional setup depending on your operating system.

{{< tabs groupId="os" >}}
  {{% tab name="Windows" %}}
**Installing TinyGo on Windows**

1. Install LLVM:
   - Download from [https://releases.llvm.org/](https://releases.llvm.org/)
   - Extract to `C:\Program Files\LLVM`
   - Add `C:\Program Files\LLVM\bin` to your PATH

2. Install TinyGo:
```powershell
# Download latest release
# Visit: https://github.com/tinygo-org/tinygo/releases

# Extract to C:\Program Files\tinygo
# Add C:\Program Files\tinygo\bin to your PATH
```

3. Verify installation:
```bash
tinygo version
```

Expected output:
```
tinygo version 0.41.0 linux/amd64 (using go version go1.22.5)
```
  {{% /tab %}}

  {{% tab name="macOS" %}}
**Installing TinyGo on macOS**

1. Install LLVM via Homebrew:
```bash
brew install llvm
```

2. Install TinyGo via Homebrew:
```bash
brew tap tinygo-org/tools
brew install tinygo
```

**Upgrading TinyGo:**
When upgrading TinyGo, first update Homebrew's cache:
```bash
brew update
brew upgrade tinygo
```

3. Verify installation:
```bash
tinygo version
```

Expected output:
```
tinygo version 0.41.0 darwin/amd64 (using go version go1.26.x)
```
  {{% /tab %}}

  {{% tab name="Linux" %}}
**Installing TinyGo on Linux**

1. Install LLVM:
```bash
# Ubuntu/Debian
sudo apt-get install llvm clang liblld-dev

# Fedora
sudo dnf install llvm clang lld

# Arch Linux
sudo pacman -S llvm clang lld
```

2. Install TinyGo:
```bash
# Download latest release
wget https://github.com/tinygo-org/tinygo/releases/download/v0.41.0/tinygo_0.41.0_amd64.deb

# Install package
sudo dpkg -i tinygo_0.41.0_amd64.deb
```

3. Verify installation:
```bash
tinygo version
```

Expected output:
```
tinygo version 0.41.0 linux/amd64 (using go version go1.22.5)
```
  {{% /tab %}}
{{< /tabs >}}

## Install USB Drivers (Windows Only)

If you're on Windows, you may need USB drivers for your board.

**M5Stack Core2:**
- Uses CP2104 USB-to-serial chip
- Download drivers from [SiLabs](https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers)

**M5Stack StampC3 / XIAO-ESP32C3:**
- Uses native USB (no drivers needed)

## Install IDE (Optional)

Choose your preferred development environment. JetBrains GoLand offers excellent TinyGo support, or you can use Visual Studio Code with the TinyGo extension.

### JetBrains GoLand (Recommended)

JetBrains GoLand provides comprehensive TinyGo support with intelligent code completion, debugging, and project management.

1. Download and install [GoLand](https://www.jetbrains.com/go/)
2. Install the TinyGo plugin:
   - Open GoLand
   - Go to `File` > `Settings` > `Plugins`
   - Search for "TinyGo"
   - Install the official TinyGo plugin
3. Configure TinyGo SDK in GoLand settings

### Visual Studio Code (Alternative)

Visual Studio Code with the TinyGo extension provides a lightweight development experience.

1. Download and install [VS Code](https://code.visualstudio.com/download)
2. Install the TinyGo extension:
   - Open VS Code
   - Press `Ctrl+Shift+X` (Windows/Linux) or `Cmd+Shift+X` (macOS)
   - Search for "TinyGo"
   - Install the extension

## Verify Board Detection

Connect your board via USB-C cable and verify it's detected:

{{< tabs groupId="os" >}}
  {{% tab name="Windows" %}}
**List COM ports:**
```powershell
[System.IO.Ports.SerialPort]::GetPortNames()
```

Or check Device Manager for "COM ports".
  {{% /tab %}}

  {{% tab name="macOS" %}}
**List serial ports:**
```bash
ls -la /dev/cu.usb*
```

Expected output:
```
crw-rw-rw-  1 root  wheel   9,  3 Apr 22 10:00 /dev/cu.usbserial-1420
```
  {{% /tab %}}

  {{% tab name="Linux" %}}
**List serial ports:**
```bash
ls -la /dev/ttyUSB* /dev/ttyACM*
```

Expected output:
```
crw-rw----  1 uucp dialout 188,  0 Apr 22 10:00 /dev/ttyUSB0
```

**Add user to dialout group (if needed):**
```bash
sudo usermod -a -G dialout $USER
# Log out and log back in for changes to take effect
```
  {{% /tab %}}
{{< /tabs >}}

## Test Installation

Create a test file to verify your installation:

1. Create a new directory:
```bash
mkdir tinygo-test
cd tinygo-test
go mod init tinygo-test
```

2. Create `main.go`:
```go
package main

import (
    "fmt"
    "time"
)

func main() {
    for i := 0; i < 5; i++ {
        fmt.Println("Hello from TinyGo!", i)
        time.Sleep(time.Millisecond * 500)
    }
}
```

3. Build for your host:
```bash
tinygo build .
```

4. Run:
```bash
./tinygo-test
```

Expected output:
```
Hello from TinyGo! 0
Hello from TinyGo! 1
Hello from TinyGo! 2
Hello from TinyGo! 3
Hello from TinyGo! 4
```

## Available Targets

TinyGo supports many boards. Check available targets:

```bash
tinygo list-targets
```

Common ESP32 targets:
- `m5stack-core2` - M5Stack Core2 (ESP32)
- `m5stack-coreink` - M5Stack CoreInk (ESP32)
- `m5stack-stampc3` - M5Stack StampC3 (ESP32-C3)
- `xiao-esp32c3` - Seeed Studio XIAO ESP32-C3
- `xiao-esp32s3` - Seeed Studio XIAO ESP32-S3

## Troubleshooting

### "tinygo: command not found"

- Ensure TinyGo is installed and in your PATH
- Try opening a new terminal window
- Check your PATH environment variable

### "llvm-config not found"

- Install LLVM for your operating system
- Ensure LLVM is in your PATH
- Try reinstalling TinyGo after installing LLVM

### Board not detected

- Check USB cable (must support data, not just power)
- Try a different USB port
- Install USB drivers (Windows only)
- Check board is powered (LED should be lit)

### Permission denied accessing serial port

**Linux:**
```bash
sudo usermod -a -G dialout $USER
# Log out and log back in
```

**macOS:**
```bash
sudo chmod 666 /dev/cu.usbserial-*
```

**Windows:**
- Run as Administrator
- Check Device Manager for port conflicts

## Summary

You should now have:
- Go 1.22+ installed
- TinyGo 0.41 installed
- VS Code with TinyGo extension (optional)
- USB drivers installed (Windows)
- Board detected and ready

Let's verify everything is working with our first embedded program!

[Assignment 2: Blinky](../assignment-2/)
