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

Let's first look at the traditional WiFi experience to see how esp-wifi-remote enables the same seamless experience with external WiFi hardware.

### 1. Traditional WiFi Experience

The standard approach where the ESP chip has native WiFi capabilities:

```mermaid
graph LR
    U((User)) --> WIFI["<h3>esp_wifi</h3><br/>esp_wifi_init()<br/>esp_wifi_connect()<br/>..."]

    subgraph "ESP32 with WiFi"
        WIFI
    end


    WIFI -.-> A

    A((Wi-Fi))

    style U fill:#e1f5fe
    style WIFI fill:#e8f5e8
```

This is the conventional setup where applications directly interface with the WiFi hardware through the standard ESP-IDF WiFi APIs. The user experience is seamless—you call `esp_wifi_init()`, `esp_wifi_connect()`, and other familiar functions, and WiFi just works.

### 2. esp-wifi-remote: Same Experience, External Hardware

**esp-wifi-remote** is designed to provide exactly the same user experience as the traditional WiFi setup, but with external WiFi hardware. This works in two scenarios:
* Non-WiFi Chipsets: The traditional use case of providing WiFi functionality on ESP32-P4
* WiFi enabled Chipsets: It is possible to use esp-wifi-remote on ESP32 chips which already have WiFi
  - narrow use case where multiple WiFi interfaces are needed (e.g. for bridging networks, filtering packets, ...)
  - testing: to bootstrap your experience with esp-wifi-remote, just plug two ESP32s and run [two-station](https://github.com/espressif/esp-wifi-remote/tree/main/components/esp_wifi_remote/examples/two_stations) example

#### Scenario A: Non-WiFi Chipsets

For chipsets without native WiFi support (like ESP32-P4, ESP32-H2), esp-wifi-remote provides a transparent bridge to external WiFi hardware:

```mermaid
graph LR
    U((User)) --> REMOTE["<h3>esp_wifi_remote</h3><br/>esp_wifi_init()<br/>esp_wifi_connect()<br/>..."]

    subgraph "Host (ESP32-P4/H2)"
        REMOTE -.-> RPC[RPC Library<br/>host side]
    end


    subgraph "Slave (ESP32 with WiFi)"
        RPC <==UART/SDIO/...==> SLAVE_RPC
    end

    SLAVE_RPC[RPC Library<br/>slave side] -.-> ANT
    ANT((Wi-Fi))


    style U fill:#e1f5fe
    style REMOTE fill:#e8f5e8
    style RPC fill:#fff3e0
    style SLAVE_RPC fill:#fff3e0
```

The magic here is that your application code remains identical to the traditional WiFi case. You still call `esp_wifi_init()`, `esp_wifi_connect()`, and all the familiar functions—esp-wifi-remote transparently redirects these calls through the RPC layer to a WiFi-capable slave device.

#### Scenario B: WiFi-Enabled Chipsets with Additional Interfaces

For chipsets that already have WiFi, esp-wifi-remote can add additional wireless interfaces, giving you both native and remote WiFi capabilities:

```mermaid
graph LR
    U((User)) -->  REMOTE["<h3>esp_wifi_remote</h3><br/>esp_wifi_remote_init()<br/>esp_wifi_remote_connect()<br/>..."]
    U((User)) --> WIFI["<h3>esp_wifi</h3><br/>esp_wifi_init()<br/>esp_wifi_connect()<br/>--..."]

    subgraph "ESP32 with WiFi"
        WIFI
        REMOTE -.-> RPC[RPC Library</br>host side]
    end


    subgraph "Slave (ESP32 with WiFi)"
        RPC <==UART/SDIO/...==> SLAVE_RPC[RPC Library<br/>slave side]
    end

    NATIVE_ANT((Native Wi-Fi))
    REMOTE_ANT((Remote Wi-Fi))

    WIFI -.-> NATIVE_ANT
    SLAVE_RPC -.-> REMOTE_ANT

    style U fill:#e1f5fe
    style WIFI fill:#f3e5f5
    style REMOTE fill:#e8f5e8
    style RPC fill:#fff3e0
    style SLAVE_RPC fill:#fff3e0
```

This scenario enables dual WiFi interfaces—one native and one remote—providing enhanced connectivity options for complex applications that need multiple wireless connections.

## Component breakdown

esp_wifi_remote is just a thin layer that translates esp_wifi API calls into the appropriate implementation, but it's important to understand these basic aspects:
* API
  - Remote WiFi calls: Set of esp_wifi API namespaced with `esp_wifi_remote` prefix
  - Standard WiFi calls: esp_wifi API directly translates to esp_wifi_remote API for targets with no WiFi.
* Configuration: Standard WiFi library Kconfig options and selection of the RPC library

```mermaid
graph TD

    subgraph "esp_wifi_remote"
        Configuration
        API
    end
    subgraph "Configuration"
        C["WiFi config"]
        D["RPC library"]
    end
    subgraph "API"
        A["<h3>esp_wifi_...</h3><br/>only if WiFi not enabled"]
        B["<h3>esp_wifi_remote_...</h3><br/>all targets"]
    end

    D --> E[esp_hosted]
    D --> F[wifi_remote_over_eppp]
    D --> G[wifi_remote_over_at]
```

### WiFi configuration

You can configure the remote WiFi exactly the same way as the local WiFi, the Kconfig options are structured the same way and called exactly the same, but located under ESP WiFi Remote component instead.

#### Local vs. Remote WiFi configuration

The names of Kconfig options are the same, but the identifiers are prefixed differently in order to differentiate between local and remote WiFi.

> [!TIP] Adapt options from sdkconfig
> If you're migrating your project from a WiFi enabled device and used specific configuration options, please make sure the remote config options are prefixed with `WIFI_RMT_` instead of `ESP_WIFI_`, for example:

```
CONFIG_ESP_WIFI_TX_BA_WIN -> CONFIG_WIFI_RMT_TX_BA_WIN
CONFIG_ESP_WIFI_AMPDU_RX_ENABLED -> CONFIG_WIFI_RMT_AMPDU_RX_ENABLED
...
```

> [!IMPORTANT]
> All WiFi remote configuration options are available, but some of them are not directly related to the **host side** configuration and since these are compile time options, wifi-remote cannot automatically reconfigure the **slave side** in runtime.
> It is important to configure the options on the slave side manually and rebuild the slave application.

The RPC libraries could perform a consistency check but cannot reconfigure the slave project.

### Choice of esp-wifi-remote implementation component

The default and recommended option is to use `esp_hosted` as your RPC library for most use-cases, is it provide the best performance, integration, maturity and support.

You can also switch to `eppp` or `at` based implementation or implement your own RPC mechanism.
Here are the reasons you might prefer some other implementation than `esp_hosted`:
* Your application is not aiming for the best network throughput.
* Your slave (or host) device is not an ESP32 target and you want to use some standard protocol -> choose `EPPP` since it uses PPPoS protocol and works seamlessly with `pppd` on linux.
* You prefer encrypted RPC communication between host and slave device, especially when passing WiFi credentials.
* You might need some customization on the slave side

### Internal implementation

The `esp-wifi` component interface and functionality is dependent on the actual WiFi hardware, i.e. the actual target capabilites. The `esp-wifi-remote` needs to follow these dependencies, which are in turn based on the remote target, i.e. slave WiFi hardware.
That's why some wireless and system capability flags and options are replaced internally with `SOC_SLAVE` prefix. Similarly the host side config options are prefixed with `WIFI_RMT` to be used in `esp-wifi-remote` headers. You can read more about the adaptation in [WiFi remote](https://github.com/espressif/esp-wifi-remote/blob/main/components/esp_wifi_remote/README.md#dependencies-on-esp_wifi) documentation.

> [!Note]
> These options and flags are only related to the host side, as `esp-wifi-remote` is a host side layer. For slave side options, please refer to the actual RPC implementation library.

#### Comparison of RPC implementor components

This section focuses on comparing the RPC libraries in more details, mainly how these different methods marshall WiFi commands,events and data to the slave device.

**Principle of operation**


esp-hosted uses a plain text channel to send and receive WiFi API calls and events. It uses other plain text channels for data packets (WiFi station, soft-AP, BT/BLE). The TCP/IP stack runs only on the host side and esp-hosted passes Ethernet frames (802.3) from host to slave, where they are queue directly to the WiFi library.

{{< figure
    default=true
    src="hosted.png"
    >}}

`wifi_remote_over_eppp` creates a point to point link between host and slave device, so each side have their IP addresses. WiFi API calls and events are transmitted using SSL/TLS connection with mutual authentication. The data path uses plain text peer to peer connection by means of IP packets. Both host and slave device run TCP/IP stack. The slave device runs network address translation (NAT) to route the host IP packets to the WiFi network -- this is a limitation, since the host device is behind NAT, so invisible from the outside and the translation has a performance impact (to overcome this, you can enable Ethernet frames via custom channels, so the data are transmitted the same way as for `esp-hosted` method, using 802.3 frames).

{{< figure
    default=true
    src="eppp.png"
    >}}


`wifi_remote_over_at` uses `esp-at` project as the slave device, so the host side only run standard AT commands. It's implemented internally with `esp_modem` component that handles basic WiFi functionality. Note that not all configuration options provided by *esp-wifi-remote* are supported via AT commands, so this method is largely limited.

{{< figure
    default=true
    src="at.png"
    >}}


**Performance**

As mentioned above, the best throughput experience is achieved with `esp_hosted` implementation.

| RPC component  | Maximum TCP throughput | More details |
|----------------|------------------------|---------------|
| esp_hosted_mcu | up to 50Mbps           | [esp-hosted](https://github.com/espressif/esp-hosted-mcu?tab=readme-ov-file#hosted-transports-table) |
| wifi_remote_over_eppp | up to 20Mbps      | [eppp-link](https://github.com/espressif/esp-protocols/blob/master/components/eppp_link/README.md#throughput) |
| wifi_remote_over_at | up to 2Mbps     | [esp-at](https://github.com/espressif/esp-at) |

## Other connectivity options

This blog post focuses on *esp-wifi-remote* solutions only, it doesn't discuss related topics, such as Bluetooth and BLE connectivity, `esp-extconn` component or some other means of using Wi-Fi library on remote targets.

### esp-extconn

This solution doesn't fall into *esp-wifi-remote* category and needs a special target for the slave side (ESP8693), but provides the best throughput (up to 80Mbps). Read more about it [esp-extconn repository](https://github.com/espressif/esp-extconn/)

### Custom connectivity other options

It is also possible to use your own implementation of Wi-Fi connectivity by means of the below components:

| component | Repository | Brief description |
|-----------|------------|-------------------|
| esp-modem | [esp-protocols](https://github.com/espressif/esp-protocols/blob/master/components/esp_modem) | AT command and PPP client |
| esp-at | [esp-at](https://github.com/espressif/esp-at) | serving AT commands on ESP32 |
| eppp-link | [esp-protocols](https://github.com/espressif/esp-protocols/blob/master/components/eppp_link) | PPP/TUN connectivity engine |


## Conclusion

**esp-wifi-remote** bridges the gap between WiFi-enabled and non-WiFi ESP32 chipsets, providing a seamless development experience that maintains API compatibility while extending WiFi functionality to previously WiFi-less devices. Through its transparent translation layer, developers can leverage their existing `esp_wifi` knowledge and codebase with minimal changes.

Two critical considerations emerge from this exploration:

**1. Use esp-hosted as your RPC library** - For most use cases, esp-hosted provides the optimal solution with up to 50Mbps throughput, mature integration, and comprehensive support. While alternatives like `wifi_remote_over_eppp` (20Mbps) and `wifi_remote_over_at` (2Mbps) exist for specific scenarios, esp-hosted delivers the best performance and reliability for general applications.

**2. Mind the WiFi slave configuration** - Since esp-wifi-remote operates as a compile-time configuration system, it cannot automatically reconfigure the slave device at runtime. Developers must manually configure the slave-side WiFi options and rebuild the slave application to ensure consistency between host and slave configurations. This is particularly important when migrating from WiFi-enabled devices, where configuration options must be prefixed with `WIFI_RMT_` instead of `ESP_WIFI_`.

By following these guidelines, developers can successfully implement esp-wifi-remote solutions that provide the same familiar WiFi experience across diverse ESP32 hardware platforms, from traditional WiFi-enabled chipsets to the latest non-WiFi variants like ESP32-P4 and ESP32-H2.
