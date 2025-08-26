---
title: "*esp-wifi-remote*: The remote control to your Wi-Fi"
date: 2025-08-28
showAuthor: false
summary: "**esp-wifi-remote** provides traditional `esp_wifi` functionality on non-WiFi targets, allowing them to act as a `host` that communicates with a WiFi-capable `slave` device through a transport layer."
authors:
  - david-cermak
tags: [  "ESP-IDF", "Wi-Fi", "esp-hosted", "ESP32"]
---

This blog post explores the esp-wifi-remote ecosystem, its components, architecture, and how it integrates with esp-hosted to provide seamless WiFi connectivity to previously WiFi-less devices.

## Introduction

The ESP-IDF's `esp_wifi` API is a mature and stable interface that has powered WiFi connectivity across generations of ESP32 chipsets. However, with the introduction of new ESP32 series chips that do not include native WiFi hardware—such as ESP32-P4 and ESP32-H2—developers may wonder: what WiFi API should they use on these devices? The answer is simple: by adding **esp-wifi-remote**, you can use exactly the same `esp_wifi` APIs on non-WiFi ESP chipsets as you would on traditional WiFi-enabled ones. This seamless compatibility allows developers to leverage their existing knowledge and codebase, extending WiFi functionality to a broader range of ESP devices with minimal changes.

## Understanding the WiFi Experience

To appreciate how esp-wifi-remote works, let's first look at the traditional WiFi experience, then see how esp-wifi-remote enables the same seamless experience with external WiFi hardware.

### 1. Traditional WiFi Experience

The standard approach where the ESP chip has native WiFi capabilities:

```mermaid
graph LR
    U((User)) --> API[esp_wifi API]

    subgraph "ESP32 with WiFi"
        API --> WIFI[esp_wifi Library]
    end


    WIFI -.-> A

    A((Wi-Fi📡))

    style U fill:#e1f5fe
    style API fill:#f3e5f5
    style WIFI fill:#e8f5e8
```

This is the conventional setup where applications directly interface with the WiFi hardware through the standard ESP-IDF WiFi APIs. The user experience is seamless—you call `esp_wifi_init()`, `esp_wifi_connect()`, and other familiar functions, and WiFi just works.

### 2. esp-wifi-remote: Same Experience, External Hardware

**esp-wifi-remote** is designed to provide exactly the same user experience as the traditional WiFi setup, but with external WiFi hardware. This works in two scenarios:

#### Scenario A: Non-WiFi Chipsets

For chipsets without native WiFi support (like ESP32-P4, ESP32-H2), esp-wifi-remote provides a transparent bridge to external WiFi hardware:

```mermaid
graph LR
    U((User)) --> API[esp_wifi API]

    subgraph "Host (ESP32-P4/H2)"
        API -.-> REMOTE[esp_wifi_remote]
        REMOTE -.-> RPC[RPC Library<br/>hosted/eppp]
    end


    subgraph "Slave (ESP32 with WiFi)"
        RPC <==UART/SPI/SDIO/...==> SLAVE_RPC
        SLAVE_RPC[RPC Library<br/>slave side] --> SLAVE_WIFI[esp_wifi Library]
    end

    ANT((Wi-Fi📡))

    SLAVE_WIFI -.-> ANT

    style U fill:#e1f5fe
    style API fill:#f3e5f5
    style REMOTE fill:#e8f5e8
    style RPC fill:#fff3e0
    style SLAVE_RPC fill:#fff3e0
    style SLAVE_WIFI fill:#e8f5e8
```

The magic here is that your application code remains identical to the traditional WiFi case. You still call `esp_wifi_init()`, `esp_wifi_connect()`, and all the familiar functions—esp-wifi-remote transparently redirects these calls through the RPC layer to a WiFi-capable slave device.

#### Scenario B: WiFi-Enabled Chipsets with Additional Interfaces

For chipsets that already have WiFi, esp-wifi-remote can add additional wireless interfaces, giving you both native and remote WiFi capabilities:

```mermaid
graph LR
    U((User)) --> API[esp_wifi API]
    U((User)) --> API2[esp_wifi_remote API]

    subgraph "ESP32 with WiFi"
        API --> NATIVE_WIFI[esp_wifi]
        API2 -.-> REMOTE[esp_wifi_remote]
        REMOTE -.-> RPC[RPC Library]
    end


    subgraph "Slave (ESP32 with WiFi)"
        RPC <==UART/SPI/SDIO/...==> SLAVE_RPC[RPC Library<br/>slave side]
        SLAVE_RPC --> SLAVE_WIFI[esp_wifi Library]
    end

    NATIVE_ANT((Native Wi-Fi📡))
    REMOTE_ANT((Remote Wi-Fi📡))

    NATIVE_WIFI -.-> NATIVE_ANT
    SLAVE_WIFI -.-> REMOTE_ANT

    style U fill:#e1f5fe
    style API fill:#f3e5f5
    style API2 fill:#f3e5f5
    style NATIVE_WIFI fill:#e8f5e8
    style REMOTE fill:#e8f5e8
    style RPC fill:#fff3e0
    style SLAVE_RPC fill:#fff3e0
    style SLAVE_WIFI fill:#e8f5e8
```

This scenario enables dual WiFi interfaces—one native and one remote—providing enhanced connectivity options for complex applications that need multiple wireless connections.


---
