---
title: "ESP-IDF with ESP32-C6 Workshop - Assignment 5"
date: 2024-06-03T00:00:00+01:00
showTableOfContents: false
series: ["WS001"]
series_order: 6
showAuthor: false
---
## Assignment 5: WiFi provisioning (EXTRA)

WiFi provisioning is a crucial step in the setup of any IoT device. It involves configuring the device with the necessary credentials (like SSID and password) to connect to a WiFi network. This process is typically performed once during the initial setup of the device, but it may also be repeated whenever the device needs to connect to a new network.

There are several methods for WiFi provisioning. Some devices use a physical interface, like buttons or switches, to enter provisioning mode. Others use a web-based interface or a mobile app to guide the user through the process. In some cases, devices may also support automatic provisioning through technologies like Bluetooth Low Energy (BLE).

Espressif offers solutions for provisioning. You will find this process being used in some projects like [ESP RainMaker](https://rainmaker.espressif.com/).

### Hands-on WiFi provisioning

From the NVS assignment, you can see how to set and get the WiFi credentials from the flash memory. This feature is useful but still you will need to set the values somehow.

On this assignment we will show you how to use the mobile phone (Android or iOS) to set the WiFi credentials via BLE.

1. **Install the mobile application**

Install the provisioning application on your smartphone.

- Android: [ESP BLE Provisioning](https://play.google.com/store/apps/details?id=com.espressif.provble&pcampaignid=web_share)
- iOS [ESP BLE Provisioning](https://apps.apple.com/us/app/esp-ble-provisioning/id1473590141)

2. **Create a new project from the examples**

Create a new ESP-IDF project using the example `provisioning` -> `wifi_prov_mgr`.

For existing projects, you can use the component [espressif/network_provisioning](https://components.espressif.com/components/espressif/network_provisioning).

```bash
idf.py add-dependency "espressif/network_provisioning^0.2.0"
```

3. **Build, flash, and monitor**

Now you can build and flash (run) the example to your device.

> You might need to full clean your project before building if you have added the files and the component manually.

After building your application, open the `ESP-IDF Serial Monitor`.

4. **Provisioning**

In the provisioning application, follow the steps to **Provision New Device** using BLE.

{{< gallery >}}
  <img src="../assets/provisioning-app-1.jpg" class="grid-w33" />
  <img src="../assets/provisioning-app-2.jpg" class="grid-w33" />
  <img src="../assets/provisioning-app-3.jpg" class="grid-w33" />
  <img src="../assets/provisioning-app-4.jpg" class="grid-w33" />
  <img src="../assets/provisioning-app-5.jpg" class="grid-w33" />
{{< /gallery >}}

You will need to scan the QRCode or to use the **I don't have a QR code** option. Please make sure you are provisioning your device.

After completing the provisioning process, the device will connect to the selected network.

## Next step
