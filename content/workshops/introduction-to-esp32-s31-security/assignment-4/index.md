---
title: "Assignment 4: Establish and Verify a TLS Connection"
date: 2026-10-06
showTableOfContents: true
series: ["ESP32-S31-SECURITY"]
series_order: 6
showAuthor: false
---

## Assignment 4: Establish and verify a TLS connection

In this assignment, you will configure a TLS client, authenticate a server, and test certificate-validation failures.

## Before you begin

TODO: Define the Wi-Fi setup, test endpoint, certificate authority, and handling of local credentials.

> [!IMPORTANT]
> **Workshop tier A:** This assignment does not burn eFuses. If you merge Kconfig from other labs, keep `CONFIG_EFUSE_VIRTUAL=y` in the shared workshop project so later Tier B assignments stay safe.

> [!IMPORTANT]
> Never commit Wi-Fi passwords, production certificates, private keys, tokens, or service credentials.

## Step 1: Configure the trust anchor

TODO: Add the validated ESP-IDF v6.1 certificate-bundle or embedded-certificate configuration.

## Step 2: Connect with server authentication

TODO: Add the client code and expected successful response.

## Step 3: Test certificate validation

TODO: Demonstrate safe failure for an untrusted certificate, wrong hostname, and invalid lifetime.

## Step 4: Add mutual TLS

TODO: Add an optional mTLS flow using demonstration credentials and protected key storage.

## What you learned

TODO: Summarize peer authentication, confidentiality, and the captured evidence.

## Previous and next steps

[Previous: Lecture 7](../lecture-7)

[Next: Lecture 6: HMAC-based NVS encryption](../lecture-6)

[Return to the workshop main page](/workshops/introduction-to-esp32-s31-security/)
