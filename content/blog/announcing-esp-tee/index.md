---
title: "Announcing ESP-TEE Framework for ESP32-C6"
date: 2025-02-04
showAuthor: false
authors:
  - mahavir-jain
tags:
  - ESP32-C6
  - Security
  - IoT
  - RISC-V
  - ESP-TEE

---

We are thrilled to announce the availability of the **ESP-TEE (Trusted Execution Environment)** framework for the **ESP32-C6**! Designed to enhance security on Espressif's SoCs, ESP-TEE enables a protected execution environment to safeguard sensitive information and operations.

## The Importance of the ESP-TEE

Security is paramount in the IoT landscape, where billions of devices exchange sensitive information daily. The ESP-TEE framework empowers developers by offering:

- **Hardware-Enforced Isolation**: The TEE ensures a secure enclave where sensitive computations and data remain protected from the rest of the system.
- **Feature-Rich Security**: ESP-TEE provides a comprehensive set of security features, including secure storage, secure OTA updates and attestation.
- **Compliance with Security Certifications**: The framework helps products meet the latest IoT security standards, fostering trust and reliability.
- **Enhanced Flexibility**: Developers can separate trusted and untrusted components, improving maintainability and scalability of their solutions.

## Architecture

<figure style="width: 80%; margin: 0 auto; text-align: center;">
    <img
        src="img/esp-tee.webp"
        alt="ESP-TEE Architecture"
        title="ESP-TEE Architecture"
        style="width: 100%;"
    />
</figure>

As shown in the diagram, system resources are divided into two domains:

- The **Trusted Execution Environment (TEE)** - forms the secure sub-system and runs in Machine mode
- The **Rich Execution Environment (REE)** - contains the user application on top of ESP-IDF and runs in User mode

Trusted Mode hosting TEE firmware provides secure execution environment for sensitive operations. REE application runs in the untrusted domain and interacts with the TEE firmware through secure interface. Hardware enforced isolation is achieved using the **RISC-V architecture** primitives and the security peripherals in ESP32-C6.

## Why isolation matters

Isolation is a cornerstone of modern IoT security. By isolating sensitive operations and data in a trusted execution environment, ESP-TEE ensures that even if the main application is compromised, critical assets remain protected. This approach aligns with the latest **IoT security certifications** and compliance standards, making ESP-TEE an ideal choice for developing robust and secure IoT applications.

## A Secure Enclave in action

Imagine a smart home controller managing a variety of devices—from lighting to security cameras. The controller uses cryptographic keys to authenticate devices and encrypt communications, ensuring that only authorized components participate in the ecosystem.

With ESP-TEE on ESP32-C6:

- The secure enclave protects cryptographic operations and sensitive keys from unauthorized access.
- Hardware isolation ensures that even if an untrusted component is compromised, critical data (e.g., cryptographic keys) remains safe.
- Compliance with IoT security standards strengthens user confidence in the system's reliability.

The result? A smart home controller that complies with stringent security certifications required in IoT, building trust with end users.

## Get Started Today

1. **Learn More**: Visit the [ESP-TEE Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/security/tee/index.html) to explore the framework's features and implementation details.
2. **Explore Examples**: Find practical use cases and sample projects in the [ESP-TEE Examples](https://github.com/espressif/esp-idf/tree/cc9fb5bd/examples/security/tee).

## Roadmap

We plan to enable more RISC-V based Espressif SoCs with the ESP-TEE framework in the future. Additionally, some enhancements are in the pipeline and the framework would be officially be part of ESP-IDF v5.5 release.

---

Secure your IoT applications today with ESP-TEE framework and build solutions that stand out in security, compliance, and user trust!
