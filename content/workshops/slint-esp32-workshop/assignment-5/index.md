---
title: "Assignment 5: Add Wi-Fi scan on ESP32"
weight: 5
---

Now that we have our desktop application showing placeholder or local Wi-Fi list, it's time to fetch **real scan results** from the ESP32 device itself.

## Objective

Connect the Slint frontend with a backend task that performs a Wi-Fi scan and updates the UI with real network data.

## Step 1: Choose Your WiFi Implementation Path

Unlike the desktop environment, the embedded environment requires different approaches for WiFi depending on whether you chose `no_std` or `std`:

### `no_std` Path (Recommended) ✅

**Crates used:**
- `esp-hal` for hardware abstraction
- `esp-wifi` for WiFi functionality  
- `embassy` for async runtime (optional)

**Benefits:**
- Direct hardware control
- Lower memory usage
- Faster boot times
- Predictable behavior

### `std` Path (Alternative)

**Crates used:**
- `esp-idf-hal` for hardware abstraction
- `esp-idf-svc` for WiFi services
- Standard Rust `std` library

**Use when:**
- You need existing ESP-IDF C/C++ components
- You require std-only crates

## Step 2: Implement Wi-Fi Scan Task

### `no_std` Implementation (Recommended)

A simplified flow using `esp-wifi` in blocking mode:

```rust
use esp_wifi::wifi::WifiController;
use esp_hal::prelude::*;

// Initialize WiFi controller
let mut wifi = WifiController::new(...);

// Perform scan
let networks = wifi.scan().unwrap();

// Process results
for net in networks {
    esp_println::println!("SSID: {:?}, RSSI: {}", net.ssid, net.rssi);
}
```

### `std` Implementation (Alternative)

Using ESP-IDF services:

```rust
use esp_idf_svc::wifi::{EspWifi, WifiConfiguration};
use esp_idf_hal::peripherals::Peripherals;

// Initialize WiFi service
let peripherals = Peripherals::take().unwrap();
let mut wifi = EspWifi::new(peripherals.modem, ...);

// Perform scan
let scan_result = wifi.scan().unwrap();

// Process results
for ap in scan_result {
    println!("SSID: {:?}, RSSI: {}", ap.ssid, ap.signal_strength);
}
```

Your code should fetch the list, filter or map it into a simple Rust data structure, and push it to the Slint view model (typically through an FFI bridge, or via `slint::SharedVector`).

## Step 3: Bridge Data to UI

Use the same `WiFiNetwork` model and expose it via `set_network_list()` call or bind it to a `SharedVector`.

Ensure any updates are done in a safe way (outside ISR) — it's common to poll or await the scan completion and then call UI updates from main or spawned tasks.

## Step 4: Flash and Verify

Navigate to your board's directory and flash the updated application:

### `no_std` Path (Recommended)

```bash
# For M5Stack CoreS3
cd slint-esp-workshop/esp32/no_std/m5stack-cores3
cargo run --release

# For ESoPe Board
cd slint-esp-workshop/esp32/no_std/esope-sld-c-w-s3
cargo run --release

# For ESP32-S3-BOX-3
cd slint-esp-workshop/esp32/no_std/esp32-s3-box-3
cargo run --release
```

### `std` Path (Alternative)

```bash
# For M5Stack CoreS3
cd slint-esp-workshop/esp32/std/m5stack-cores3
cargo run --release

# For ESP32-S3-BOX-3
cd slint-esp-workshop/esp32/std/esp32-s3-box-3
cargo run --release
```

### Bootloader Mode (if needed)

**For ESoPe board users:**
- Connect ESP-Prog
- Hold **BOOT**, press **RESET**, then release **BOOT**

**For M5Stack CoreS3 and other boards:**
- Usually enters bootloader mode automatically
- If issues occur, press and hold BOOT, then press RESET

After flashing, check the logs and verify that real networks are displayed in the UI.

## Notes

- You may need to allocate enough memory for scan results
- Use `heapless` or `alloc` containers for passing data into Slint view models
- Ensure Wi-Fi driver is initialized before scanning

## Extra Credit

- Add a button to trigger a new scan
- Highlight the strongest signal
- Sort by RSSI
