


---
title: "Assignment 4: Add Wi-Fi List on Desktop"
date: 2025-06-03T00:00:00+01:00
showTableOfContents: true
series: ["slint-no-std"]
series_order: 4
showAuthor: false
---

In this assignment, we’ll enhance the desktop version of our GUI application by populating the **Wi-Fi list tab** with actual network data retrieved from the host operating system.

This gives users a realistic preview of how the application will behave on embedded targets — but in a convenient desktop environment for rapid development and UI testing.

---

## Objectives

- Update the Slint ViewModel to accept dynamic Wi-Fi data
- Use the host OS to scan for available Wi-Fi networks
- Feed that data into the UI via Slint model bindings

---

## Step 1: Add Desktop Wi-Fi Backend

On desktop, the simplest way to access Wi-Fi network data is to run system-specific commands. For example:

- On **Linux**: `nmcli -t -f SSID dev wifi`
- On **Windows**: `netsh wlan show networks mode=bssid`

Your Rust application can invoke these commands using `std::process::Command`.

---

## Step 2: Populate the Model

Update your `viewmodel.rs` to use a `ModelRc<WifiNetwork>` and expose it to the Slint UI.

```rust
#[derive(Clone, slint::VecModel, slint::Model)]
pub struct WifiNetwork {
    pub ssid: String,
}

pub fn get_wifi_list() -> Vec<WifiNetwork> {
    vec![
        WifiNetwork { ssid: "winkelmann.site".into() },
        WifiNetwork { ssid: "slint.dev".into() },
        WifiNetwork { ssid: "developer.respressif.com".into() },
    ]
}
```

---

## Step 3: Update the Slint UI

Use a `ListView` inside the Wi-Fi tab in your `.slint` file:

```slint
ListView {
    for data[i] in wifi_model: WifiNetwork {
        Text { text: data[i].ssid; }
    }
}
```

Then, bind the model from your `main.rs`:

```rust
let model = Rc::new(slint::VecModel::from(get_wifi_list()));
ui.set_wifi_model(model.into());
```

Make sure the `wifi_model` property is declared in your `.slint` root component.

---

## Step 4: Run It

To see it in action, go to the desktop version of the workshop and run:

```bash
cd slint-esp-workshop/winit
cargo run --release
```

You should now see real or mocked Wi-Fi networks in the second tab.

---

## Summary

In this assignment, you’ve connected system data with your UI — an essential step when developing embedded user interfaces. In the next assignment, we’ll bring this logic to the ESP32-S3 and scan real networks using the embedded Wi-Fi stack.

[Continue to Assignment 5 →](../assignment-5/)