---
title: "Assignment 1: Establish and Verify a TLS Connection"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 6
showAuthor: false
---

## Assignment 1: Establish and verify a TLS connection

In this assignment, you will run the ESP-IDF [**https_mbedtls**](https://github.com/espressif/esp-idf/tree/master/examples/protocols/https_mbedtls) example on the ESP32-S31-Function-CoreBoard-1: configure trust anchors, complete a TLS handshake to a public HTTPS server, and run controlled tests that should **fail** verification. Read [Lecture 1](../lecture-1) first for the threat model, API flow, and menuconfig paths.

## Before you begin

**Tools:** you can follow every assignment from the command line (CLI) or from the CLion IDE. Pick a tab in any of the boxes below; all boxes on the page switch to the same tool.

**Project:** `$IDF_PATH/examples/protocols/https_mbedtls`. All later assignments build on this project. Set the target once, here:

{{< tabs group="workflow" >}}
  {{< tab label="CLI" >}}
```bash
cd $IDF_PATH/examples/protocols/https_mbedtls
idf.py --preview set-target esp32s31
```

Replace `PORT` in the commands below with your serial port.
  {{< /tab >}}
  {{< tab label="CLion" >}}
CLion instructions will be added soon.
  {{< /tab >}}
{{< /tabs >}}

**Network:** a Wi-Fi access point with internet access and outbound TCP port 443. The example connects to `www.howsmyssl.com`.

## Step 1: Configure the trust anchor

Goal: enable the embedded CA bundle used by `esp_crt_bundle_attach()` (see [Trust anchors and the certificate bundle](../lecture-1/#trust-anchors-and-the-certificate-bundle) in Lecture 1).

Open the project configuration:

{{< tabs group="workflow" >}}
  {{< tab label="CLI" >}}
```bash
idf.py menuconfig
```
  {{< /tab >}}
  {{< tab label="CLion" >}}
CLion instructions will be added soon.
  {{< /tab >}}
{{< /tabs >}}

Then:

1. Open **Component config → mbedTLS → Certificate Bundle**.
2. Enable **Certificate Bundle** ([CONFIG_MBEDTLS_CERTIFICATE_BUNDLE](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-mbedtls-certificate-bundle)).
3. Leave the default **filter list** bundle unless your instructor asks for the full Mozilla set (larger binary, broader coverage).
4. (Optional, for Step 3 untrusted-server tests) Set **Custom Certificate Bundle Path** to a folder with a lab CA PEM file: [CONFIG_MBEDTLS_CUSTOM_CERTIFICATE_BUNDLE_PATH](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/kconfig-reference.html#config-mbedtls-custom-certificate-bundle-path). Use `.pem` or `.der` extensions only, as documented in [ESP x509 Certificate Bundle](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/protocols/esp_crt_bundle.html).

Save the configuration and build the project:

{{< tabs group="workflow" >}}
  {{< tab label="CLI" >}}
```bash
idf.py build
```
  {{< /tab >}}
  {{< tab label="CLion" >}}
CLion instructions will be added soon.
  {{< /tab >}}
{{< /tabs >}}

Confirm the project still fits your flash budget after the bundle is linked.

## Step 2: Connect with server authentication

Goal: bring up the network and complete one successful HTTPS GET (see [Network setup](../lecture-1/#network-setup-menuconfig) and [Reference example architecture](../lecture-1/#reference-example-architecture)).

1. In the project configuration, open **Example Connection Configuration**.
2. Under **Connect using**, select **Wi-Fi**. Set the lab **SSID** and **password** (see [protocols README](https://github.com/espressif/esp-idf/blob/master/examples/protocols/README.md)).
3. Build, flash, and open the monitor:

{{< tabs group="workflow" >}}
  {{< tab label="CLI" >}}
```bash
idf.py -p PORT flash monitor
```

To leave the monitor, press **Ctrl+]**.
  {{< /tab >}}
  {{< tab label="CLion" >}}
CLion instructions will be added soon.
  {{< /tab >}}
{{< /tabs >}}

**Success criteria** (order may vary slightly):

- `example_connect` reports an IPv4 address on Wi-Fi
- Log lines similar to: `Attaching the certificate bundle...`, `Performing the SSL/TLS handshake...`
- `esp-x509-crt-bundle: Certificate validated`
- `Certificate verified.`
- A **cipher suite** line, for example `Cipher suite is TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256`
- HTTP response body containing JSON from howsmyssl (TLS version and cipher list)

Capture a screenshot or log excerpt for your workshop notes. This is useful **test evidence** for protection in transit (see [CRA relevance](../lecture-1/#cra-relevance) in Lecture 1).

## Step 3: Test certificate validation

Goal: confirm that verification **fails closed** when trust or hostname is wrong (see [Hostname and certificate verification](../lecture-1/#hostname-and-certificate-verification)).

Revert to a known-good tree or git stash between tests. Rebuild and flash after each change.

| Test | Change | Expected result |
|------|--------|-----------------|
| Wrong hostname | In `main/https_mbedtls_example_main.c`, call `mbedtls_ssl_set_hostname(&ssl, "invalid.example.com")` while still connecting to `www.howsmyssl.com`, or mismatch `WEB_SERVER` vs the cert name | Non-zero verify flags; `Failed to verify peer certificate!` and `verification info` in the log |
| Untrusted server | Point `WEB_SERVER` / connect target at an HTTPS host that uses a **self-signed** or private-CA certificate, without adding that CA to the bundle | Handshake failure or verify failure; connection must not treat the peer as trusted |
| Invalid lifetime (optional) | With **SNTP** configured so wall time is correct, use an instructor-provided expired server cert or test endpoint | Verification failure related to certificate dates |

> [!WARNING]
> Do not disable `MBEDTLS_SSL_VERIFY_REQUIRED` or set authmode to `VERIFY_NONE` in production firmware. Use misconfiguration only on lab builds to observe failures.

Document each test: what you changed, log output, and whether the device continued to reject the bad case after reboot.

## Step 4: Add mutual TLS (optional)

The stock **https_mbedtls** example does **not** implement mTLS. This step is optional.

If your instructor assigns it:

1. Read [One-way TLS vs mutual TLS](../lecture-1/#one-way-tls-vs-mutual-tls-mtls) in Lecture 1.
2. Follow ESP-IDF guidance for client certificates (for example [ESP-TLS](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s31/api-reference/protocols/esp_tls.html) or mbedTLS `mbedtls_ssl_conf_own_cert` with PEM buffers embedded at build time).
3. Use **demonstration** client cert and key from your instructor. Store keys in encrypted NVS in real products ([Lecture 2](../lecture-2)).

## What you learned

You should now be able to:

- Enable the ESP-IDF **certificate bundle** and attach it with `esp_crt_bundle_attach()`
- Run **https_mbedtls** on ESP32-S31 over Wi-Fi via `example_connect()`
- Interpret success logs (`Certificate validated`, cipher suite, HTTP JSON response)
- Trigger and recognize **verification failures** (hostname, untrusted CA, optional expiry)
- Describe how monitor logs and test notes support a product **trust store policy** and CRA-oriented test evidence

## Closing demo: TLS power consumption

After you finish the TLS exercises above, the instructor will run a live demo of **TLS power consumption** on the ESP32-S31-Function-CoreBoard-1 using a [Qoitech](https://www.qoitech.com/) power profiler (for example [Otii Arc Pro](https://www.qoitech.com/otii-arc-pro/)). The demo shows how supply current changes during Wi-Fi bring-up and the TLS handshake while the device runs the same **https_mbedtls** client flow. You observe the trace; no extra steps are required in this assignment.

## Previous and next steps

[Previous: Lecture 1](../lecture-1)

[Next: Lecture 2: HMAC-based NVS encryption](../lecture-2)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
