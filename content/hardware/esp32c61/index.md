---
title: "ESP32-C61 status"
date: 2024-08-29
aliases:
- ../../pages/chip-support-status/esp32c61
---

**Last updated:** {{< dynamic-block contentPath="persist/chip-support-status/esp32c61.json" jsonKey="timestamp" >}}

This page lists the projects in which the ESP32-C61 is supported.

To show the status of features, the following icons are used:

- :white_check_mark: Supported feature
- :hourglass_flowing_sand: Unsupported feature (IDF-1234)
  - \"IDF-1234\" indicates an internal issue reference to help us keep this list up to date
- :question: Support status unknown
  - Such status issues will be checked and fixed shortly

This page will be periodically updated to reflect the current support status for the ESP32-C61.

{{< alert >}}
  Some links provided below might appear invalid due to being generated as placeholders for documents to be added later.
{{< /alert >}}


## ESP-IDF

The **initial mass production support** for ESP32-C61 has been rescheduled from ESP-IDF v5.4 to ESP-IDF v5.5.1, in line with the updated chip production plan. ESP-IDF v5.5.1 is planned for release on Augest 31, 2025.

In the meantime, the ESP-IDF `master` branch contains the latest **preview support** for ESP32-C61 v1.0. To start developing with v1.0 chips now, please pull the latest commits to your ESP-IDF master branch.

The **support for earlier engineering samples** -- ESP32-C61 v0.2 -- has been removed starting from commit [884e54a8](https://github.com/espressif/esp-idf/commit/884e54a8dd97ce9ad2c2b5d6a6c0a744c641157e). If you need to continue developing with v0.2 chips, please check out the earlier commit [b1b99b30](https://github.com/espressif/esp-idf/commit/b1b99b30ef96011e2e72a6532e31ede05f73e55f) from the master branch by running `git checkout b1b99b30`.

If you have an issue to report about any of the ESP32-C61 features, please create an issue in [ESP-IDF GitHub issue tracker](https://github.com/espressif/esp-idf/issues).

{{< dynamic-block contentPath="persist/chip-support-status/esp32c61.json" jsonKey="idf" >}}


## Other Projects

If you have an issue to report about any of the ESP32-C61 features, please create an issue in the issue tracker of a respective project.

{{< dynamic-block contentPath="persist/chip-support-status/esp32c61.json" jsonKey="other_proj" >}}
