---
title: "How to create a simple HTTPd server"
date: 2025-02-17T08:49:13+01:00
showAuthor: false
authors:
  - francesco-bez 
summary: "In this two parts tutorial, you will learn how to set up an HTTP server on the Espressif platform. The example application will guide you through starting an access point (Soft-AP), launching an HTTP server, and serving an HTML page."

---

HTTP is one of the most common internet protocols we interact with. While it’s often associated with complex web pages and advanced products, it’s also one of the most effective interfaces you can provide as an embedded IoT developer.

To learn how to start an HTTP server on an Espressif module, you will build a basic provisioning application. The goal is to launch a Soft-AP, allow the user to connect to it, and serve an HTML page where they can enter their router credentials (SSID and password). This process, known as provisioning, is supported by several Espressif frameworks for real-world applications. However, in this tutorial, you’ll build a simple provisioning application to understand each step of the process.


In this two-part tutorial, you will also encounter:  

- **Event loops** – A design pattern used throughout the Espressif ESP-IDF library to simplify the management of complex applications.  
- **esp-netif** – Espressif's abstraction layer for TCP/IP networking.  
- **Non-volatile storage (NVS)** – For saving credentials

## Prerequisites

Before starting this tutorial, ensure that you

- Can compile and flash the [`hello_world`](https://github.com/espressif/esp-idf/tree/master/examples/get-started/hello_world) example.
- Have an Espressif EVK or another compatible board for flashing code.
- Understand the difference between a Wi-Fi access point and a Wi-Fi station.
- Are familiar with the basics of HTTP, including GET and POST requests.
- Have a basic understanding of HTML and its basic tags.

## Tutorial parts

The tutorial is divided into two parts
1. Setting up a soft-AP and managing Wi-Fi events
2. Creating an HTTP server and implementing basic GET and POST routes

