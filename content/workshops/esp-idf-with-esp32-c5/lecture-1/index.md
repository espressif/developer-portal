---
title: "ESP-IDF C5 - Lecture 1"
date: "2026-07-29"
lastmod: "2026-07-29"
series: ["WS00C"]
series_order: 2
showAuthor: false
summary: "This lecture introduces the ESP32-C5 and its dual-band Wi-Fi 6 radio, then explains how to configure the 2.4 GHz and 5 GHz bands using the ESP-IDF Wi-Fi driver."
---

## Introduction

The `ESP32-C5` is one of the latest Espressif SoCs, and it stands out for its wide range of connectivity options. In addition to Bluetooth Low Energy (LE) and the IEEE 802.15.4 protocol (used by Thread and Zigbee), it's the first Espressif SoC to support dual-band Wi-Fi 6, covering both the 2.4 GHz and 5 GHz bands.

## Wi-Fi 6 and the 5 GHz Band

Wi-Fi 6, also known as 802.11ax, is the latest generation of the Wi-Fi standard. Compared to previous generations, it introduces several improvements that are particularly useful for IoT applications, such as:

* __Target Wake Time (TWT)__: allows devices to negotiate when and how often they wake up to send or receive data, reducing power consumption.
* __OFDMA (Orthogonal Frequency-Division Multiple Access)__: lets multiple devices share the same channel more efficiently, lowering latency in crowded networks.
* __MU-MIMO (Multi-User, Multiple Input, Multiple Output)__: increases network capacity by allowing the access point to communicate with several devices at the same time.
* __BSS coloring__: helps maintain stable connectivity in areas with many overlapping Wi-Fi networks.

The 5 GHz band adds another advantage on top of these Wi-Fi 6 features. Since it's less commonly used than the 2.4 GHz band, it typically suffers from less interference and congestion. This makes it a good fit for applications that need lower latency and more reliable throughput, such as live streaming, IP cameras, or other high-bandwidth IoT use cases. Being able to choose between 2.4 GHz and 5 GHz also lets you assign different devices to different bands depending on how critical their connectivity is.

> [!NOTE]
> The `ESP32-C5` does not support simultaneous dual-band operation. It can operate on only one band, 2.4 GHz or 5 GHz, at any given time.

## Configuring the Wi-Fi Band Mode

To use the 5 GHz band on the `ESP32-C5`, you need to set the Wi-Fi band mode using the [`esp_wifi_set_band_mode()`](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c5/api-reference/network/esp_wifi.html) API, which is part of the `esp_wifi` component. This function accepts a `wifi_band_mode_t` value:

* `WIFI_BAND_MODE_2G_ONLY`: restricts operation to the 2.4 GHz band.
* `WIFI_BAND_MODE_5G_ONLY`: restricts operation to the 5 GHz band.
* `WIFI_BAND_MODE_AUTO`: the default mode, it scans both bands and connects to the access point with the strongest signal when the same SSID is broadcast on both.

```c
#include "esp_wifi.h"

// Restrict the ESP32-C5 to the 5 GHz band only
esp_wifi_set_band_mode(WIFI_BAND_MODE_5G_ONLY);
```

## Conclusion

In this lecture, you learned that the `ESP32-C5` is Espressif's first SoC with dual-band Wi-Fi 6 support, and why the 5 GHz band can be a good choice for latency-sensitive or high-throughput IoT applications. You also saw how to select the Wi-Fi band using `esp_wifi_set_band_mode()`. In the next assignment, you will apply this knowledge to connect your `ESP32-C5` DevKit to a 5 GHz Wi-Fi network.

### Next Step
> Next assignment &rarr; __[assignment 1.1](assignment-1-1)__

> Or [go back to navigation menu](.#agenda)
