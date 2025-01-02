---
title: "ESP32-C61 support status"
date: 2024-08-29T16:40:07+08:00
draft: false
---

This page lists the projects in which the ESP32-C61 is supported.

In the list below, the supported features are marked with a checkbox (:white_check_mark:), while unsupported features are marked with an hourglass (:hourglass_flowing_sand:). An internal issue reference (such as \"IDF-1234\") is listed at the end of the feature description to help us keep this list up to date:

- :hourglass_flowing_sand: Unsupported feature (IDF-1234)
- :white_check_mark: Supported feature

This page will be periodically updated to reflect the current support status for the ESP32-C61.

{{< alert >}}
  Some links provided below might appear invalid due to being generated as placeholders for documents to be added later.
{{< /alert >}}


## ESP-IDF

According to the chip mass production plan, the planned support for ESP32-C61 in ESP-IDF v5.4 has been rescheduled to ESP-IDF v5.5. Thank you for your understanding.

- ESP-IDF v5.5, whose planned release date is June 30th 2025, will include the initial support for the mass production version of ESP32-C61.
- If you would like to try features with the early samples of the ESP32-C61, suggest to use the master branch of ESP-IDF.

If you have an issue to report about any of the ESP32-C61 features, please create an issue in [ESP-IDF GitHub issue tracker](https://github.com/espressif/esp-idf/issues).

{{< chipstatus contentPath="persist/chip-support-status/esp32c61.json" jsonKey="idf" >}}


## External projects

{{< chipstatus contentPath="persist/chip-support-status/esp32c61.json" jsonKey="ext_proj" >}}
