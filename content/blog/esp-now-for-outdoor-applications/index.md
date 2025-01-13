---
title: "Exploring wireless communication protocols on ESP32 platform for outdoor applications"
date: 2024-12-20
showAuthor: false         # Hide default Espressif author
authors:
  - "gancarcik-samuel"
  - "sumsky-jan"
  - "kubascik-michal"
tags:
    - IoT
    - Wireless
    - ESP-NOW
    - ESP32-C6
---

## Introduction

The ESP32-C6-DevKitM-1 was chosen for testing Wi-Fi, ESP-NOW, and ESP-NOW-LR due to its cutting-edge features and suitability for real-world evaluations. While its compact design and integrated capabilities make it an excellent choice, it should be noted that the board does not natively support external antennas. Instead, it features a high-quality PCB antenna optimized for typical IoT applications. Here are the key highlights:
-	__Support for Wi-Fi 6 (802.11ax)__ - Provides enhanced speed, improved efficiency in congested environments, and reduced latency, making it a future-ready option for testing modern Wi-Fi capabilities.
-	__2.4GHz Capability__ - Essential for evaluating long-range communication performance with ESP-NOW-LR, especially in challenging environments like forests or rugged terrains.
-	__Integrated PCB Antenna__ - While limited to an on-board antenna, the design ensures a compact and reliable setup for short- to medium-range testing. The board does not include a U.FL connector or external antenna support, which may limit range in certain scenarios.
-	__Power Efficiency__ - Designed for low-power operation, enabling prolonged testing in remote areas without frequent recharging, simulating real-world IoT deployment scenarios.
-	__Development Ecosystem__ - Fully compatible with Espressif’s ESP-IDF framework and third-party tools, making configuration, programming, and analysis straightforward and efficient.

By combining these features, the ESP32-C6-DevKitM-1 offers a reliable platform for benchmarking wireless communication protocols in various conditions, from open fields to dense forests. While its lack of external antenna support is a limitation, the integrated PCB antenna performs well under typical testing ranges, making it a strong choice for general-purpose evaluations.


## Concept of data transmission and evaluation

To ensure accurate and consistent testing results, a carefully designed setup was implemented using the ESP32-C6-DevKitM-1 development boards. Two devices were employed, with one configured as the transmitter to send data packets and the other as the receiver to record performance metrics. This configuration allowed us to simulate real-world communication scenarios while isolating the behavior of each wireless protocol under test.

The experiments were carried out in two distinct environments to capture performance variations: open fields, which provided minimal interference and clear line-of-sight for communication, and forested areas, which introduced dense obstructions such as trees and foliage to mimic challenging conditions. These environments ensured that the protocols could be evaluated for both optimal and adverse conditions.

Three key performance metrics were collected during testing:
-	__Latency__ - This was measured as the time taken for a message to travel from the transmitter to the receiver. By evaluating latency across various distances, we could assess the responsiveness of each protocol under different environmental and range conditions.
-	__Speed__ - The maximum throughput, or data transfer rate, was determined to understand how well each protocol supported high-speed communication. This was measured in both environments to identify the impact of interference and signal attenuation.
-	__Packet Success Rate__ - The reliability of each protocol was monitored by tracking the percentage of data packets successfully transmitted and received over increasing distances. This metric was critical for understanding the stability and robustness of each protocol in real-world use cases.


## Results

### Wi-Fi

Wi-Fi exhibited a steady degradation in performance as distance increased. In open fields, latency started at around 20 ms at 30 meters and rose to approximately 35 ms at 150 meters, while in forested areas, latency climbed more steeply, starting at 25 ms at 20 meters and reaching nearly 40 ms at 100 meters.
{{< figure
    default=true
    src="img/wifi_latency.webp"
    >}}
Speed in open fields was strong at shorter distances, peaking at 12 Mbps at 30 meters, but declined sharply to below 6 Mbps by 150 meters. In dense forests, speeds were lower, starting at 8 Mbps at 20 meters and dropping to under 4 Mbps at 100 meters due to interference.
{{< figure
    default=true
    src="img/wifi_speed.webp"
    >}}

Success rates in open fields remained high at close ranges but fell to around 60% by 150 meters. In forested conditions, Wi-Fi success rates declined more quickly, dropping below 50% at 80 meters, highlighting its vulnerability to obstructions. 
{{< figure
    default=true
    src="img/wifi_success.webp"
    >}}

###	ESP-NOW

ESP-NOW demonstrated excellent performance for mid-range communication. Latency in open fields remained consistently low, averaging under 20 ms even at distances up to 300 meters, and stayed manageable at about 30 ms in forests at 150 meters. 
{{< figure
    default=true
    src="img/now_latency.webp"
    >}}

Speed in open fields reached a maximum of 400 kbps at close ranges, gradually dropping to 50 kbps at 300 meters. In dense forests, speeds started at around 350 kbps at 25 meters but declined more quickly, reaching just 50 kbps by 150 meters. 
{{< figure
    default=true
    src="img/now_speed.webp"
    >}}

Success rates in open fields were near 100% up to 150 meters, gradually dropping to 60% by 300 meters. In forested conditions, success rates declined more sharply, falling below 50% at 125 meters. Overall, ESP-NOW performed well for moderate distances and offered reasonable resilience to environmental challenges. 
{{< figure
    default=true
    src="img/now_success.webp"
    >}}

### ESP-NOW-LR

ESP-NOW-LR excelled in long-range and challenging environments, showing remarkable stability over extended distances. In open fields, latency remained under 25 ms even at 900 meters, while in forests, it stayed consistent at around 30 ms up to 600 meters, despite environmental obstacles. 
{{< figure
    default=true
    src="img/now_lr_latency.webp"
    >}}

Speed in open fields started at 100 kbps at 150 meters and declined steadily to about 10 kbps at 900 meters. In dense forests, the speed remained at 80 kbps up to 200 meters but saw a sharp decline beyond 400 meters. 
{{< figure
    default=true
    src="img/now_lr_speed.webp"
    >}}


Success rates in open fields were near 100% up to 450 meters and dropped to 40% by 900 meters, while in forests, success rates followed a similar trend, starting near 100% but falling below 50% at 400 meters. These results highlight ESP-NOW-LR’s outstanding long-range performance and its ability to maintain connectivity in obstructed terrains.
{{< figure
    default=true
    src="img/now_lr_success.webp"
    >}}

## Conclusion

The ESP32 platform offers powerful and flexible communication protocols that cater to a wide range of applications. Wi-Fi provides high-throughput and internet connectivity for bandwidth-heavy applications. ESP-NOW excels in low-power, connectionless communication for peer-to-peer networks, ideal for local applications without requiring infrastructure. ESP-NOW-LR, powered by Espressif technology, extends the range of ESP-NOW to up to a kilometer, making it the perfect choice for long-range, low-power IoT applications in remote or challenging environments.

The ESP32-C6-DevKitM-1 provides a robust and versatile platform for evaluating Wi-Fi, ESP-NOW, and ESP-NOW-LR in diverse environments. Our tests reveal that:
-	Wi-Fi is ideal for high-speed communication in controlled environments.
-	ESP-NOW balances power efficiency and responsiveness for local IoT networks.
-	ESP-NOW-LR excels in long-range, low-power communication, especially in dense forests.