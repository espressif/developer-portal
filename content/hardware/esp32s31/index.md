---
title: "ESP32-S31 status"
date: 2026-03-26
---

**Last updated:** {{< dynamic-block contentPath="persist/chip-support-status/esp32s31.json" jsonKey="timestamp" >}}

This page lists the projects in which the ESP32-S31 is supported.

To show the status of features, the following icons are used:

- :white_check_mark: Supported feature
- :hourglass_flowing_sand: Unsupported feature (IDF-1234)
  - \"IDF-1234\" indicates an internal issue reference to help us keep this list up to date
- :question: Support status unknown
  - Such status issues will be checked and fixed shortly

This page will be periodically updated to reflect the current support status for the ESP32-S31.

{{< alert >}}
  Some links provided below might appear invalid due to being generated as placeholders for documents to be added later.
{{< /alert >}}


## ESP-IDF

Now the master branch contains the latest preview support for ESP32-S31. Until a full support version is released, please update to the HEAD of master branch to develop with ESP32-S31 chips.

If you have an issue to report about any of the ESP32-S31 features, please create an issue in the [ESP-IDF GitHub issue tracker](https://github.com/espressif/esp-idf/issues).

{{< dynamic-block contentPath="persist/chip-support-status/esp32s31.json" jsonKey="idf" >}}


## Other Projects

If you have an issue to report about any of the ESP32-S31 features, please create an issue in the issue tracker of a respective project.

{{< dynamic-block contentPath="persist/chip-support-status/esp32s31.json" jsonKey="other_proj" >}}
