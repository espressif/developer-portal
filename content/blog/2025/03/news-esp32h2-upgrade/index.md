---
title: "ESP32-H2 Upgrade: Enhanced Security and Protection"
date: 2025-03-12T19:27:36+08:00
featureAsset: "img/featured/featured-announcement.webp"
summary: Espressif has released ESP32-H2 v1.2, bringing significant cryptographic and hardware security improvements.
---

Espressif has released ESP32-H2 v1.2, bringing significant cryptographic and hardware security improvements. These features enhance protection, including from power and time analysis attacks, ensuring better reliability and security for IoT applications.


## Why Upgrade?

The ESP32-H2 v1.2 introduces key enhancements focused on improving resistance to attacks like Differential Power Analysis (DPA) and Correlation Power Analysis (CPA). These upgrades are designed to help developers ensure robust security for applications that require high levels of data protection.

To utilize the new features of ESP32-H2 v1.2, ensure you're using the compatible ESP-IDF version. If you're on a pre-v1.2 chip, upgrading ESP-IDF is required for compatibility. This will ensure your binary supports both v1.2 and earlier chip versions.


## Key Benefits

- Power Glitch Detector -- The addition of a Power Glitch Detector helps safeguard against power-related attacks that could manipulate device behaviour.
- Anti-Attack Pseudo-Round for AES/XTS-AES -- This function enhances the security of cryptographic operations, making the device more resistant to power analysis attacks like DPA and CPA.
- Constant-Time/Power Mode for ECC/ECDSA -- This mode ensures constant timing and power consumption during cryptographic operations, providing stronger defence against power-based analysis attacks.


## Product Upgrade Comparison

|   Category   |     After Upgrade   |     Before Upgrade   |
|:---:| --- | --- |
|     Product Name   |     No change: e.g., [ESP32-H2](https://www.espressif.com/sites/default/files/documentation/esp32-h2_datasheet_en.pdf), [ESP32-H2-MINI-1](https://www.espressif.com/en/support/documents/technical-documents?keys=&field_type_tid_parent=esp32hSeries-Modules&field_type_tid%5B%5D=1217&field_type_tid%5B%5D=1521&field_type_tid%5B%5D=1535&field_type_tid%5B%5D=1523&field_download_document_type_tid%5B%5D=510)   |  |
|     Product Variants   |     the  product ordering code is based on the pre-upgrade code with an "S"  added at the end, indicating Security. e.g., ESP32-H2FH2S,  ESP32-H2-MINI-1-H2S   |     e.g., ESP32-H2FH2, ESP32-H2-MINI-1-H2   |
|     Chip Hardware Version   |     Chip Revision v1.2   |     Chip Revision v0.1   |
|     [ESP-IDF Version](https://github.com/espressif/esp-idf/tags)   |     v5.1.6 and v5.2.5 , v5.3.3 (expected on 3/27), v5.4.1 (expected on 4/4), and above   |     v5.1 and above   |
|     Optimization   |     enhanced security   |     --   |

## Getting Support and More Information

Upgrade now to benefit from these critical security improvements. For detailed technical information, guidelines, and the latest software versions, visit Espressif’s [official website](https://www.espressif.com/) and our [forum](https://www.esp32.com/).

For more details, please refer to [PCN20250104: Upgrade of ESP32-H2 Series Products](https://www.espressif.com/sites/default/files/pcn_downloads/PCN20250104_Upgrade_of_ESP32-H2_Series_Products.pdf). If you have any questions about this upgrade or need any assistance during the upgrade process, please feel free to contact your Espressif account manager or [reach out to us](https://www.espressif.com/zh-hans/contact-us/sales-questions) through our official website. Let’s move forward to an even better development experience!


## References

- [Press Release](https://www.espressif.com/en/news/ESP32_H2_Upgrade)
