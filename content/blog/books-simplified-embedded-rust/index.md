---
title: "Simplified Embedded Rust: A Comprehensive Guide to Embedded Rust Development"
date: 2024-06-07
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
    - "juraj-michalek"
tags: ["Rust", "Embedded Systems", "ESP32", "ESP32-C3", "Espressif", "Wokwi", "Book", "Review"]
---

## Simplified Embedded Rust: A Comprehensive Guide to Embedded Rust Development

### By Omar Hiari

Omar Hiari's "Simplified Embedded Rust" series offers two books, each tailored to different stages of a developer's Rust and embedded systems journey. The two books, "ESP Core Library Edition" and "ESP Standard Library Edition," provide comprehensive guidance on using Rust for embedded development on Espressif chips, specifically the ESP32-C3.

### Why Two Books?
[The Core Library Edition](http://ser-book.com/espnostd) focuses on a no_std environment, giving developers complete control over their code, ideal for performance-critical applications. [The Standard Library Edition](http://ser-book.com/espstd), on the other hand, leverages the ESP-IDF framework, making it easier for beginners by providing access to all features supported by ESP-IDF.

### Key Features of Both Books

- **Comprehensive Content**: Each book spans 200+ pages, covering topics such as GPIO, ADCs, Timers, PWM, Serial Communication, and many more.
- **Hands-On Learning**: Each chapter includes conceptual background, configuration steps, practical examples, and exercises.
- **Example Compatibility with Wokwi**: All examples can run on the Wokwi simulator, accessible via web, VS Code, and JetBrains. This allows learners to simulate projects without physical hardware, using pre-wired templates to simplify the learning process.

### ESP Core Library Edition
**Overview**:
The ESP Core Library Edition is designed for developers with some embedded experience. This book uses the no_std environment, offering a lean and efficient approach suitable for performance-critical applications.

**Expectations**:
Readers should be aware that this edition is ideal for those who are comfortable with Rust and looking to leverage its performance in a bare-metal environment. The focus on no_std means it’s geared towards developers who need complete control over their code for efficiency and performance.

### ESP Standard Library Edition
**Overview**:
The ESP Standard Library Edition is aimed at beginners in embedded systems and Rust developers transitioning to embedded development. This book uses the standard library, making it easier to grasp fundamental concepts without the complexities of a no_std environment.

**Expectations**:
This edition is perfect for those new to embedded systems or Rust. It provides a gentle introduction to embedded Rust development using the standard library, making it accessible and less daunting for beginners.

### Conclusion
Omar Hiari’s "Simplified Embedded Rust" series is a valuable resource for developers at various stages of their learning journey. Both books offer structured and practical insights into embedded Rust development, suited for different levels of expertise. For anyone looking to dive into embedded Rust with Espressif chips, these books provide a robust foundation, leveraging the power of the Wokwi simulator for an accessible and immersive learning experience.

Additionally, while the books are written with the ESP32-C3 in mind, the knowledge and skills gained from these resources are applicable to other Espressif chips, including the newly announced ESP32-P4, ensuring that developers are well-prepared for future projects.

### Recent Developments
An update has been rolled out on 10/20/2024 to support the latest ESP crate and Rust compiler versions, along with expanded support for more ESP devices. Updates include the following:

- `no-std` edition: compatibility with the `esp-hal` v0.21 crate.
- `std` edition: compatibility with the `esp-idf-svc` v0.49 crate.
- `no-std` repositories: new embassy-sync examples added compatible with the `esp-hal-embassy` 0.4.0 crate.
- `std` and `no-std` repositories: Expanded support for ESP32, ESP32-S2, ESP32-S3, and the existing ESP32-C3.
- Various typo, code, and reference fixes across both editions.

### Additional Resources
- [The Core Library Edition](http://ser-book.com/espnostd)
- [The Standard Library Edition](http://ser-book.com/espstd)
- [The Embedded Rustacean Blog](https://blog.theembeddedrustacean.com/)
- [The Embedded Rustacean Newsletter](https://www.theembeddedrustacean.com/subscribe)
- [Wokwi Simulator](https://wokwi.com/rust)
- [ESP-RS Community Resources](https://github.com/esp-rs)

By addressing the community's needs and continuously updating content, "Simplified Embedded Rust" aims to be an indispensable guide for mastering embedded Rust development on Espressif devices.
