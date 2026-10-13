---
title: "Introduction to the ESP32-S31 with Vision: Conclusion"
date: 2026-09-28
showTableOfContents: true
series: ["ESP32-S31-VISION"]
series_order: 13
showAuthor: false
---

## From an edge-vision prototype to a complete application

You started with the ESP32-S31 architecture and finished with a complete local computer-vision application. The exercises connected the SoC's RISC-V and SIMD processing, external memory, camera interface, pixel accelerator, display controller, and security capabilities to practical software.

## What you built

You built two vision paths:

1. An ESP-Vision application that detects and tracks hands, checks a configurable safety zone, and drives LCD and RGB LED warnings.
2. A native ESP-IDF application that uses the ESP32-S31-Korvo-1 BSP and [ESP-DL](https://github.com/espressif/esp-dl) to detect faces.

Both run inference locally. They differ in development level:

| Native ESP-IDF and ESP-DL | ESP-Vision |
|---------------------------|------------|
| Fine control over tasks, memory, components, and hardware accelerators | Fast iteration with concise Python |
| C/C++ build and flash cycle | Edit and run scripts |
| Best suited to optimized product firmware | Best suited to learning, evaluation, and rapid prototypes |

## Key takeaways

- **ESP32-S31:** combines connectivity, multimedia acceleration, vector processing, and hardware security for AIoT applications.
- **ESP32-S31-Korvo-1:** supplies the camera, display, touch, memory, storage, controls, and audio needed for multimedia prototypes.
- **BSP:** centralizes board wiring and peripheral initialization behind stable APIs.
- **ESP-DL:** executes quantized `.espdl` models locally with target-optimized kernels.
- **ESP-Vision:** shortens the camera and inference development loop through MicroPython APIs.
- **MCP server:** grounds coding assistants in target capabilities, API signatures, and official examples.
- **Model selection:** starts from the output the application needs, then balances accuracy, latency, memory, and storage.
- **Tracking:** adds temporal identity to independent frame detections.
- **Safety-zone logic:** converts model output into an application decision, but does not make the demonstration safety-certified.

## Going further

### Improve the pipeline

- Move native inference to a dedicated task and use bounded frame queues.
- Use the PPA for resize, rotation, and pixel-format conversion.
- Measure capture, preprocessing, inference, post-processing, and display latency separately.
- Track memory high-water marks and fragmentation over long runs.

### Add connected behavior

Send compact events over Wi-Fi 6, Thread, Zigbee, Bluetooth, or Ethernet. Avoid transmitting raw frames unless the product needs them and the privacy/security design permits it.

### Productize security

Define a threat model, then configure Secure Boot, flash encryption, protected key provisioning, authenticated updates, rollback protection, TEE/APM boundaries, and secure model updates. Security features must be deliberately enabled and tested.

## Resources

- [ESP32-S31 product page](https://www.espressif.com/en/products/socs/esp32-s31)
- [ESP32-S31 Datasheet](https://documentation.espressif.com/esp32-s31_datasheet_en.html)
- [ESP32-S31-Korvo-1 User Guide](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-korvo-1/user_guide.html)
- [ESP32-S31-Korvo-1 BSP](https://components.espressif.com/components/espressif/esp32_s31_korvo_1)
- [ESP-BSP](https://github.com/espressif/esp-bsp)
- [ESP-DL](https://github.com/espressif/esp-dl)
- [ESP-Vision](https://vision.espressif.com/en)

## Feedback

If you have any feedback about this workshop, feel free to start a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).

## Thank you

Thank you for completing the Introduction to the ESP32-S31 with Vision workshop. You now have a foundation for moving from an edge-vision idea to a hardware-aware prototype and, with appropriate validation and engineering controls, toward a production design.

## Next step

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-with-vision/)
