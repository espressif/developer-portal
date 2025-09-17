---
title: "ESP32-C5 v1.0 status"
date: 2025-04-24
aliases:
- ../../pages/chip-support-status/esp32c5
---

**Last updated:** {{< dynamic-block contentPath="persist/chip-support-status/esp32c5.json" jsonKey="timestamp" >}}

The ESP32-C5-DevKitC-1-N8R4 development board is now [available for purchase](../../blog/2025/05/news-esp32c5-mp/#where-to-buy).

This page lists the projects in which the ESP32-C5 v1.0 is supported.

To show the status of features, the following icons are used:

- :white_check_mark: Supported feature
- :hourglass_flowing_sand: Unsupported feature (IDF-1234)
  - \"IDF-1234\" indicates an internal issue reference to help us keep this list up to date
- :question: Support status unknown
  - Such status issues will be checked and fixed shortly

This page will be periodically updated to reflect the current support status for the ESP32-C5 v1.0.

{{< alert >}}
  Some links provided below might appear invalid due to being generated as placeholders for documents to be added later.
{{< /alert >}}


## ESP-IDF

Now the master branch contains the latest preview support for ESP32-C5 v1.0. Until a full support version is released, please update to the HEAD of master branch to develop with v1.0 chips.

If you would like to try features with the early samples of the ESP32-C5 v0.1, please refer to the [ESP32-C5 v0.1 support status page](https://github.com/espressif/esp-idf/issues/14021).

If you have an issue to report about any of the ESP32-C5 features, please create an issue in the [ESP-IDF GitHub issue tracker](https://github.com/espressif/esp-idf/issues).

{{< dynamic-block contentPath="persist/chip-support-status/esp32c5.json" jsonKey="idf" >}}


## Other Projects

If you have an issue to report about any of the ESP32-C5 features, please create an issue in the issue tracker of a respective project.

{{< dynamic-block contentPath="persist/chip-support-status/esp32c5.json" jsonKey="other_proj" >}}
