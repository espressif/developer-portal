---
title: "Assignment 5: Add Wi-Fi scan on ESP32"
weight: 5
---

Now that we have our desktop application showing placeholder or local Wi-Fi list, it's time to fetch **real scan results** from the ESP32 device itself.

## Objective

Connect the Slint frontend with a backend task that performs a Wi-Fi scan and updates the UI with real network data.

## Step 1: Understand Platform Differences

Unlike the desktop environment, the embedded environment uses `esp-hal` and `esp-wifi` (with or without `embassy`) to access the Wi-Fi stack. The scan process will differ depending on the runtime.

For this version, assume we're using the `no_std` + `esp-wifi` stack, optionally in blocking mode or with async (if you opt for `embassy`).

## Step 2: Implement Wi-Fi Scan Task

A simplified flow using `esp-wifi` in blocking mode might look like:

```rust
let mut wifi = ... // Initialize wifi driver
let networks = wifi.scan().unwrap();

for net in networks {
    log::info!("SSID: {:?}", net.ssid);
}
```

Your code should fetch the list, filter or map it into a simple Rust data structure, and push it to the Slint view model (typically through an FFI bridge, or via `slint::SharedVector`).

## Step 3: Bridge Data to UI

Use the same `WiFiNetwork` model and expose it via `set_network_list()` call or bind it to a `SharedVector`.

Ensure any updates are done in a safe way (outside ISR) — it's common to poll or await the scan completion and then call UI updates from main or spawned tasks.

## Step 4: Flash and Verify

Use `cargo run --release` inside the `esp32` folder (as in Assignment 3).

For ESoPe board users:
- Connect ESP-Prog
- Hold **BOOT**, press **RESET**, then release **BOOT**

After flashing, check the logs and verify that real networks are displayed in the UI.

## Notes

- You may need to allocate enough memory for scan results
- Use `heapless` or `alloc` containers for passing data into Slint view models
- Ensure Wi-Fi driver is initialized before scanning

## Extra Credit

- Add a button to trigger a new scan
- Highlight the strongest signal
- Sort by RSSI
