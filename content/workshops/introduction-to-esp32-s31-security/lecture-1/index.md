---
title: "Lecture 1: TLS for Secure Communication"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 5
showAuthor: false
---

## TLS for secure communication

**TLS** authenticates the remote server and encrypts traffic in transit. [Assignment 1](../assignment-1) uses the ESP-IDF example [`https_mbedtls`](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_mbedtls): an HTTPS client on the [ESP32-S31-Function-CoreBoard-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp32-s31-function-coreboard-1/user_guide.html) that calls **mbedTLS** directly (`mbedtls_ssl_*`, `mbedtls_net_*`), GETs `https://www.howsmyssl.com/a/check`, and prints the JSON response.

Other examples wrap the same crypto in [ESP-TLS](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/protocols/esp_tls.html) (for example [`https_request`](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_request)). We use **https_mbedtls** so the handshake and certificate checks stay visible in one source file.

> [!NOTE]
> Set `idf.py --preview set-target esp32s31` on **ESP-IDF v6.1** even if the example README target list does not yet name ESP32-S31. The ESP32-S31 is a preview target in ESP-IDF, so `set-target` needs the `--preview` option.

## Learning objectives

- Say what TLS protects on the network path (and what it does not)
- Enable the [certificate bundle](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/protocols/esp_crt_bundle.html) and explain `esp_crt_bundle_attach()`
- Outline the flow in `https_mbedtls_example_main.c`: connect, handshake, verify, HTTP read
- Relate hostname setting and verify mode to Assignment 1 failure tests

## Threat model (short)

TLS helps when someone on the LAN or path could **sniff** traffic, run a **fake server**, or steer the device to the **wrong host**. Server authentication plus a correct **hostname check** addresses that for the TLS session.

It does not fix a **compromised device**, a **bad trust store**, **disabled verification**, or missing **backend authorization**. Wi-Fi credentials only reach the AP; TLS protects the app’s session to the service.

## Reference example architecture

**`app_main`:** NVS, `esp_netif`, then [`example_connect()`](https://github.com/espressif/esp-idf/blob/master/examples/protocols/README.md) (Wi-Fi from menuconfig in this workshop) and a task that runs the client.

**`https_get_task`:** defaults to `www.howsmyssl.com:443`. In order: attach the cert bundle to the SSL config, set hostname, require peer verification, TCP connect, **handshake**, check **`mbedtls_ssl_get_verify_result`**, send a small HTTP GET, read the response. The task loops after a delay.

Look for `esp-x509-crt-bundle: Certificate validated`, `Certificate verified`, and a cipher suite line in the monitor. Sample output is in the example [README](https://github.com/espressif/esp-idf/blob/master/examples/protocols/https_mbedtls/README.md).

## Network setup (menuconfig)

Under **Example Connection Configuration**, select **Wi-Fi** and set the lab **SSID** and **password** ([protocols README](https://github.com/espressif/esp-idf/blob/master/examples/protocols/README.md)).

The network needs **outbound TCP 443**. The baseline lab uses the public howsmyssl endpoint; no lab TLS server is required.

## Trust anchors and the certificate bundle

Public HTTPS servers chain to CAs. Enable **Component config → mbedTLS → Certificate Bundle** ([CONFIG_MBEDTLS_CERTIFICATE_BUNDLE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-mbedtls-certificate-bundle)). In code, **`esp_crt_bundle_attach(&conf)`** supplies the roots.

Optional: [CONFIG_MBEDTLS_CUSTOM_CERTIFICATE_BUNDLE_PATH](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-mbedtls-custom-certificate-bundle-path) for a private CA or lab server. Products need a plan to **update** the bundle when CAs change.

## Hostname and certificate verification

Validation is two parts: the chain must trust a CA in the bundle, and the cert must match the name you meant to reach. **`mbedtls_ssl_set_hostname()`** sets that name (SNI and CN/SAN check). Use **`MBEDTLS_SSL_VERIFY_REQUIRED`** so an unverified peer cannot pass.

Wrong hostname or missing CA should fail with verify flags and log lines from `mbedtls_x509_crt_verify_info`. Assignment 1 exercises those cases on purpose; do not disable verification in shipping firmware.

Certificate dates need a sensible clock; use SNTP before optional **expiry** tests in the assignment.

## One-way TLS vs mutual TLS (mTLS)

This example is **one-way TLS** (client verifies the server only). **mTLS** adds a client certificate and is not in the stock project; Assignment 1 Step 4 is optional. See [Mbed TLS](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/protocols/mbedtls.html) and ESP-TLS docs if you extend the lab.

## CRA relevance

TLS supports **protection in transit** in a product technical file: trust store policy, success logs, and recorded failure tests (wrong hostname, untrusted cert). That is evidence for gap analysis, not CRA conformity by itself. See the TLS row in the [EU CRA overview](../overview-eu-cra) and the [introduction](../introduction) disclaimer.

For production, also plan trust store updates, protected client keys ([Lecture 2](../lecture-2)), and separate handling of Wi-Fi credentials.

## After Assignment 1 (instructor demo)

When TLS exercises are complete, the instructor may run the **TLS power consumption** closing demo in [Assignment 1](../assignment-1/#closing-demo-tls-power-consumption) using Qoitech Otii. You observe supply current during Wi-Fi bring-up and the handshake on the same **https_mbedtls** flow; no student wiring is required.

## Previous and next steps

[Previous: Overview of the EU Cyber Resilience Act](../overview-eu-cra)

[Next: Assignment 1: Establish and verify a TLS connection](../assignment-1)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
