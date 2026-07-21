---
title: "ESP-GMF v1.0: General Multimedia Framework, First Official Release"
date: 2026-07-21
summary: "ESP-GMF v1.0 is the first official release of Espressif's General Multimedia Framework, a lightweight, unified framework for building audio, video, and AI multimedia applications on Espressif chips. This post introduces the release, walks through what is new for each component area, and lists the full v1.0 component set."
tags:
  - ESP-GMF
  - multimedia
  - audio
  - video
  - AI
  - release
authors:
  - "jason-mao"
---

## Introduction

We are releasing **[ESP-GMF](https://github.com/espressif/esp-gmf) (General Multimedia Framework) v1.0**, the first official release of Espressif's unified software platform for developing multimedia applications.

In the past, multimedia applications were often built on separate frameworks, each with its own development model, interface design, and runtime mechanism. This limited code reuse and made it harder to extend functionality across products and the wider ecosystem.

ESP-GMF was created to change that. It brings Espressif's previously scattered multimedia capabilities under a single software architecture, with a unified data-flow model, component system, and development framework — covering use cases from playback and recording to AI voice, video calling, Bluetooth audio, and rendering, all built on the same framework. Compared with our earlier audio framework, [ESP-ADF](https://github.com/espressif/esp-adf), ESP-GMF offers a more modular architecture, broader hardware and media support, and better code reuse across audio, video, and AI applications.

Alongside ESP-GMF, we have also completed the **[ESP Multimedia Core](https://components.espressif.com/components?q=tags%3Amultimedia)** — a unified library that consolidates foundational multimedia building components such as media protocols, audio/video codecs, and audio/image processing algorithms. It gives ESP-GMF, and the products built on it, a stable, long-term foundation, and we will keep expanding it together with the framework and the wider ecosystem.

## Overview

ESP-GMF v1.0 is the first official, API-stable release of the framework. It consolidates the earlier development versions, promotes every official component to a 1.0.x baseline, and introduces several new advanced modules — all of which are summarized in the [ESP-GMF components summary](#esp-gmf-components-summary) below. Key updates by area:

- **Promoted all components to 1.0.x** — public APIs are now considered stable.
- **Added 4 new advanced/atomic modules**: `esp_player`, `esp_asrc`, `esp_video_render`, and `gmf_fft`.
- **New elements**: `aud_muxer`, `aud_howl`, `aud_asrc` (`gmf_audio`) and `ai_vad`, `ai_ns`, `ai_doa` (`gmf_ai_audio`).
- **`gmf_core`** adds an `esp_gmf_data_queue` + data-bus factory for variable-sized block queues, stronger memory-alignment handling for data_bus/payload, and HOWL/DOA/MUXER capability definitions.
- **`gmf_audio`** adds muxer/howl/ASRC elements, decoder input-PTS support, and bumps `esp_audio_codec` to v2.5 (G722 encode/decode, OGG decode).
- **`gmf_video` / `esp_video_render`** add hardware-blend and multi-region overlay, PPA software color-convert, manual compose, and broader display-backend support.
- **`esp_capture` / `esp_bt_audio`** add ESP32-S31 v4l2 + MJPEG→RGB decode, LE Audio (BLE) and Auracast PAST support, and adopt the shared `esp_gmf_data_queue`.
- **Board management migration**: `esp_board_manager` is now the standalone [`espressif/esp-board-manager`](https://github.com/espressif/esp-board-manager) component, and examples use [`esp-bmgr-assist`](https://pypi.org/project/esp-bmgr-assist/) (`idf.py bmgr`) instead of per-example prebuild / `idf_ext.py` scripts.

## ESP-GMF components summary

All official components in this repo:

| Component | Category | Version | Highlights |
| :--- | :--- | :--- | :--- |
| [`esp_player`](https://components.espressif.com/components/espressif/esp_player) | New Module | v1.0.1 | New embedded multimedia player: demux + decode + audio/video render with seek; decoder/IO stability fixes |
| [`esp_audio_simple_player`](https://components.espressif.com/components/espressif/esp_audio_simple_player) | Enhancements | v1.0.0 | Breaking `esp_asp_prev_func_t` signature change, weak-typed URL playback detection, dynamic URI→IO mapping, `esp_audio_simple_player_get_pool`, bit-depth conversion Kconfig |
| [`esp_capture`](https://components.espressif.com/components/espressif/esp_capture) | Enhancements | v1.0.0 | Shared `esp_gmf_data_queue` adoption, esp-sr v2.4, ESP32-S31 v4l2 + MJPEG→RGB decode, multi-region overlay & share_overlay, restart-bypass fix |
| [`esp_bt_audio`](https://components.espressif.com/components/espressif/esp_bt_audio) | Enhancements | v1.0.0 | LE Audio (BLE) support, Auracast PAST + clock-sync check, Classic/LE UI in the bt_audio example, standalone board-manager |
| [`esp_audio_render`](https://components.espressif.com/components/espressif/esp_audio_render) | Enhancements | v1.0.0 | ESP32-S31 example support, payload-clear memory-access fix, standalone board-manager example migration |
| [`esp_video_render`](https://components.espressif.com/components/espressif/esp_video_render) | New Module | v1.0.0 | New video + UI composition module: multi-backend display, dual stream, overlay/widget system, and manual compose |
| [`esp_asrc`](https://components.espressif.com/components/espressif/esp_asrc) | New Module | v1.0.1 | New audio sample-rate converter (sample rate / bit depth / channel count) with HW–SW cooperative architecture; ESP32-P4 & S31 support |
| [`esp_board_manager`](https://github.com/espressif/esp-board-manager) | External (standalone repo) | 0.5.15 | Migrated out of esp-gmf into its own repository; examples integrate it via `esp-bmgr-assist` (`idf.py bmgr`) |
| [`gmf_loader`](https://components.espressif.com/components/espressif/gmf_loader) | Enhancements | v1.0.0 | Loader setup for muxer/howl/asrc and standalone AI elements (VAD/NS/DOA), G722/OGG and HOWL effect configuration, standalone board-manager |
| [`gmf_app_utils`](https://components.espressif.com/components/espressif/gmf_app_utils) | Enhancements | v1.0.0 | Adopted the standalone esp-board-manager component (`>=0.5`) |
| [`gmf_examples`](https://components.espressif.com/components/espressif/gmf_examples) | Enhancements | v1.0.0 | New `pipeline_record_audio_muxer` & `pipeline_howl` examples; migrated examples to standalone esp-board-manager + `esp-bmgr-assist` (`idf.py bmgr`) |
| [`gmf_audio`](https://components.espressif.com/components/espressif/gmf_audio) | Enhancements | v1.0.0 | New `aud_muxer`/`aud_howl`/`aud_asrc` elements, decoder input-PTS support, `esp_audio_codec` v2.5 (G722/OGG), finer-grained mutex protection |
| [`gmf_video`](https://components.espressif.com/components/espressif/gmf_video) | Enhancements | v1.0.0 | `vid_overlay` hardware blend & multi-region, ESP32-S31 v4l2, PPA software color-convert, plus alignment/bypass and IDF v5.x/6.x build fixes |
| [`gmf_ai_audio`](https://components.espressif.com/components/espressif/gmf_ai_audio) | Enhancements | v1.0.0 | New `ai_vad`/`ai_ns`/`ai_doa` elements, esp-sr v2.4.4, ESP32-S31 support, board-manager-based example configuration |
| [`gmf_io`](https://components.espressif.com/components/espressif/gmf_io) | Enhancements | v1.0.0 | Default HTTPS certificate-bundle support for HTTP IO and IDF v6.0+ build fixes |
| [`gmf_misc`](https://components.espressif.com/components/espressif/gmf_misc) | Enhancements | v1.0.0 | No functional delta in v1.0; version aligned with the v1.0 ecosystem |
| [`gmf_fft`](https://components.espressif.com/components/espressif/gmf_fft) | New Module | v1.0.0 | New fixed-point Q15 real FFT/IFFT with PIE acceleration (S3/P4/S31) and a scalar fallback covering all ESP32 series |
| [`gmf_core`](https://components.espressif.com/components/espressif/gmf_core) | Enhancements | v1.0.0 | Variable-sized block data queue + data-bus factory, stronger data_bus/payload alignment (breaking `esp_gmf_fifo_set_align`), HOWL/DOA/MUXER caps, IO seek/reload & resource-leak fixes, FourCC additions/corrections |

## Where to go next

- [Full Release Notes](https://github.com/espressif/esp-gmf/releases/tag/v1.0) — detailed changelog and upgrade notes.
- [ESP-GMF GitHub repository](https://github.com/espressif/esp-gmf) — source, components, and examples.
- Read the documentation in [English](https://docs.espressif.com/projects/esp-gmf/en/latest/) or [中文](https://docs.espressif.com/projects/esp-gmf/zh_CN/latest/).
- [Open an issue](https://github.com/espressif/esp-gmf/issues) — feature requests, documentation suggestions, and bug reports are welcome.

If you build something on top of ESP-GMF, we would love to see it — share it on the [esp32.com](https://esp32.com/viewforum.php?f=20) forum.
