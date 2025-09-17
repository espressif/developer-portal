---
title: "Getting Started with Wi-Fi on ESP-IDF"
date: "2024-07-31"
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
    - "cheah-hao-yi"
tags: ["ESP32", "ESP-IDF", "Wi-Fi", "Tutorial"]
---

## Learning Objectives
<!--
- **Learning Objective:** Outline the topic in discussion and what kind of project the user can expect at the end of the guide.
-->
In this tutorial, we will be exploring how to connect an Espressif SoC to a Wi-Fi Access Point (AP) using ESP-IDF.

By the end of this tutorial, you will be able to:
- Understand the background of the Wi-Fi technology
- Understand the necessary component needed to enable Wi-Fi connection
- Set up a simple Wi-Fi connection with the Espressif Soc
- Able to implement Wi-Fi connections from scratch on ESP-IDF


## Recommended prerequisite
<!--
- **Prerequisite:** List out the knowledge that the reader is assumed to know prior to starting the guide.
  - Previous guides that would provide the prerequisite knowledge:
-->
The ESP-IDF framework is used extensively for this tutorial, hence it is important to have the framework installed and to have some basic familiarity with it.

To install and get started with ESP-IDF, kindly refer to the tutorial [here](https://developer.espressif.com/blog/getting-started-with-esp-idf).


## Introduction
<!--
- **Introduction:** Provide background knowledge and description of the protocol/technology involved.
- When the protocol/solution is established
- Necessity of the protocol
- In what situations that the protocol is used
-->
Wi-Fi technology, short for Wireless Fidelity, is a method of wirelessly connecting devices to the internet and to each other through a local area network (LAN). It uses radio waves to provide high-speed internet and network connections to a wide array of devices, including smartphones, laptops, tablets, and IoT gadgets.

Wi-Fi has revolutionized how we access information and communicate, enabling seamless internet connectivity without the need for physical cables. As a cornerstone of modern communication, Wi-Fi continues to evolve, bringing faster speeds, greater reliability, and enhanced security features to meet the ever-growing demands of digital connectivity.

Espressif offers various series of SoCs that provides Wi-Fi functionalities. From ESP32-S3 that supports Wi-Fi 4 to [ESP32-C6 that supports Wi-Fi 6](https://blog.espressif.com/leveraging-wi-fi-6-features-for-iot-applications-c23cc6a548aa), there are many options available to integrate Espressif products into projects that builds on Wi-Fi technology.

If you would to like to understand the operating mechanism and various configuration options specified for the Wi-Fi technology, do feel free to consult Chapter 7 of the [ESP32-C3 Wireless Adventure](https://github.com/espressif/esp32-c3-book-en) book written by Espressif Engineers! We have also prepared the documentation on the [ESP32 Wi-Fi Driver](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/wifi.html) where it describes in-depth on the principles of using the Wi-Fi APis.


### Required hardware

- Computer running Windows, Linux, or macOS
- ESP32-C3-DevKitM-1 development board
- USB cable (data + power) compatible with your development board


Other compatible hardware includes:

- ESP32-S Series SoCs
- ESP32-C Series SoCs
- ESP32 Series SoCs

Wi-Fi technology is **not** supported on the following SoC Series.

- ESP32-P Series SoCs
- ESP32-H Series SoCs

For more information about what wireless technology is supported by Espressif products, you can consult the [ESP Product Selector](https://products.espressif.com/#/product-selector?language=en&names=).

### Required software

This tutorial will be using the following software:
- ESP-IDF version 5.2.2


## Step-by-step Guide
<!--
- **Step 1: Setting Up the Project**
  - Describe setting up a blank project.
- **Step 2: Project Description**
  - Describe the project and the steps in which the project will be built.
- **Step 3: Building the Project**
  - Describe building the project in steps, provide code snippets
  - Include checkpoints where readers can run a partial project & look at the output.
  - This is to ensure that the reader is following along the guide and to be able to detect errors early in the project.

** Important! Remember to include notes if
- there are differences in
-->
For this tutorial, we will be establishing Wi-Fi connection on the Espressif SoC via 2 methods:
- Using the simplified helper function `example_connect()` (more on this function [here](https://github.com/espressif/esp-idf/tree/master/examples/protocols#about-the-example_connect-function))
- Using the Wi-Fi APIs

Comparison between the 2 methods:
- `example_connect()` allows user to easily integrate the Wi-Fi functionality without worrying about the details of the Wi-Fi APIs, which allows for quick prototying with the Espressif SoC.
- The Wi-Fi APIs allow user to have finer controls over the behaviour of the Wi-Fi functionality on the Espressif SoC, this includes beacon interval, Channel Switch Announcement Count, FTM Responder mode, and more. This is more appropriate for developing larger and more complex applications.


### Part 1: Using the `example_connect()` function

#### Step 1: Set up the project


> For Linux and macOS user: remember to set up the ESP-IDF environment in the terminal session where `idf.py` is used! This can be done with the command `. $HOME/esp/esp-idf/export.sh`.
>
> Refer [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/linux-macos-setup.html#step-4-set-up-the-environment-variables) for more information on the set up of environment variables for ESP-IDF. It is recommended to create an alias to set up ESP-IDF.


We need to create a new empty ESP-IDF project. Let's name the project `simple_connect`. For this, we can run:

```sh
idf.py create-project simple_connect
```

This command creates a minimal blank ESP-IDF project, with the following structure

```sh
├── CMakeLists.txt  # Build configuration declaring entire project
├── main            # Contains project source code
│   ├── CMakeLists.txt   # File that registers the main component
│   └── simple_connect.c # Contains the main entry point of the program
└── README.md            # File to describe the project
```

A brief overview of the files created:
- Top-level `simple_connect/CMakeLists.txt`: this file sets project-wide CMake variable and integrate the project with the rest of the build system.
- `main` directory: this directory contains the source code of the project.
- Project-level `main/CMakeLists.txt`: this file sets the variable definition to control the build process of the project.
- `simple_connect.c` : this file contain the main entry point of the program, `app_main()`. We will write our source code here.

To understand how an ESP-IDF project is structured, see [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html#build-system). For the list of available commands in the `idf.py` command-line tool, see [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/tools/idf-py.html#idf-frontend-idf-py).


#### Step 2: Add dependencies

First, go to the root of your project directory (in this case, the *simple_connect* folder), and run `idf.py create-manifest`

This would create a manifest file (`main/idf_component.yml`) that defines the dependencies of the project. For more information regarding dependencies and component management in ESP-IDF, see [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/tools/idf-component-manager.html#using-with-a-project)

Add the `protocol_examples_common` dependency in `idf_component.yml` with the following:
``` yml
dependencies:
  protocol_examples_common:
    path: ${IDF_PATH}/examples/common_components/protocol_examples_common
```

#### Step 3: Set up the target SoC

We need to configure the ESP-IDF to build the project for the specifc target (SoC) used.

At the root of the project directory, run `idf.py set-target esp32XX`

> Note:
> `esp32XX` refers to the target SoC used. For this example, we are using an ESP32-C3-DevKitM-1, hence we run the command `idf.py set-target esp32c3`.
>
> A full list of supported targets in your version of ESP-IDF can be seen by running `idf.py --list-targets`.

#### Step 4: Edit Wi-FI credentials

To edit Wi-Fi credentials, do the following (also see the asciinema video below):
- Open the ESP-IDF project configuration tool by running `idf.py menuconfig`
- Go to `Example Connection Configuration`, and update `WiFi SSID` and `WiFi Password` to your respective values

> QuickTip:
> - Press `Enter` to save the changes to the SSID and Password
> - Press `S` to save all the changes made
> - Press `Q` to quit from the project configuration tool

{{< asciinema key="simpleConnectionConfig" idleTimeLimit="2" speed="2" poster=“npt:0:01” >}}


#### Step 5: Edit the source code

Now, let us write a simple program that connects to the Wi-Fi acccess point, then shortly after disconnects from the Wi-Fi access point. The complete code to be placed in `main/simple_connect.c` can be found [here](#part-1-using-the-example_connect-function-1), and below some explanations are provided.

**Header files and Macros**

We'll include the following files and define some macros

```c
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_netif.h"
#include "esp_event.h"

#include "protocol_examples_common.h"
#include "esp_wifi.h"

#define TAG "simple_connect_example"
```

**System Initalization**

Before we utilize any resources for Wi-Fi connections, some initialization steps are required.

```c
// System initialization
ESP_ERROR_CHECK(nvs_flash_init());
ESP_ERROR_CHECK(esp_netif_init());
ESP_ERROR_CHECK(esp_event_loop_create_default());
```

Explanation:
- [`nvs_flash_init()`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/storage/nvs_flash.html?highlight=nvs_flash_init#_CPPv414nvs_flash_initv) : Initializes the Non-Volatile-Storage (NVS) partition in flash, which allows user to store (a small amount of) information needed across reboots. Some common FAQs regarding the NVS are addressed [here](https://docs.espressif.com/projects/esp-faq/en/latest/software-framework/storage/nvs.html#non-volatile-storage-nvs)
- [`esp_netif_int()`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/storage/nvs_flash.html?highlight=nvs_flash_init#_CPPv414nvs_flash_initv): Initialize the network interface (netif), which is the underlying TCP/IP stack.
- [`esp_event_loop_create_default()`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/esp_event.html?highlight=event_loop_create_default#_CPPv429esp_event_loop_create_defaultv): Creates a default event loop to allow components to declare events so that other components can register handlers.

**Connecting and Disconnecting from Wi-Fi**

The functions to connect and disconnect from Wi-Fi are simply:
```c
ESP_ERROR_CHECK(example_connect());
ESP_ERROR_CHECK(example_disconnect());
```

**Print Access Point information**

After stablishing a Wi-Fi connection, we can print out some information about the AP with the following functions.
```c
// Print out Access Point Information
wifi_ap_record_t ap_info;
ESP_ERROR_CHECK(esp_wifi_sta_get_ap_info(&ap_info));
ESP_LOGI(TAG, "--- Access Point Information ---");
ESP_LOG_BUFFER_HEX("MAC Address", ap_info.bssid, sizeof(ap_info.bssid));
ESP_LOG_BUFFER_CHAR("SSID", ap_info.ssid, sizeof(ap_info.ssid));
ESP_LOGI(TAG, "Primary Channel: %d", ap_info.primary);
ESP_LOGI(TAG, "RSSI: %d", ap_info.rssi);
```

The documentation on `wifi_ap_record_t` and `esp_wifi_sta_get_ap_info()` can be found [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_wifi.html?highlight=wifi_ap#_CPPv424esp_wifi_sta_get_ap_infoP16wifi_ap_record_t). It is useful to take a look at the [ESP Logging Library](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/log.html) too!

#### Step 6: Run the application

The full source code for this example can be found [here](#part-1-using-the-example_connect-function-1).


Once we are done writing the source code in `simple_connect.c`, we can build the binaries and flash them onto the Espressif SoC.

This can be done with the following commands:
- Building the binaries: `idf.py build`
- Flashing the binaries onto the Espressif SoC: `idf.py flash`
- Reading the output from the serial port: `idf.py monitor`

The source code provided will output the following on the terminal:
{{< asciinema key="simpleConnectionMonitor" >}}

The `example_connect()` provides a good starting point for establishing Wi-Fi connection on the Espressif SoC.

In the next section, we will look at how to write full Wi-Fi handling code that is more robust, configurable and is able to deal with various error conditions.

### Part 2: Using the Wi-Fi APIs

The `example_connect()` function provides us with a simple method to establish a Wi-Fi connection. However, for developing real applications or more complex projects, it is worth the time and effort to write more robust Wi-Fi code.

In this section, we will go through the various components of the Wi-Fi driver and APIs, then build the Wi-Fi code from scratch.

For additional examples, feel free to refer to the following sources:
- [ESP-IDF Example Connect Implementation](https://github.com/espressif/esp-idf/blob/master/examples/common_components/protocol_examples_common/wifi_connect.c)
- [ESP-IDF Wi-Fi Station example](https://github.com/espressif/esp-idf/tree/master/examples/wifi/getting_started/station)
- [ESP32-C3 IoT book chapter on Wi-Fi configuration](https://github.com/espressif/book-esp32c3-iot-projects/tree/main/device_firmware/3_wifi_connection)

#### Step 1: Set up the project
Let's create another empty ESP-IDF project and call it `wifi_tutorial`. For this, we can run:

`idf.py create-project wifi_tutorial`


#### Step 2: Add files to the project

For this example, let's demonstrate how to add more header and source code files in an ESP-IDF project.

In the `main` folder, create a header file named `tutorial.h` and another file named `tutorial.c`. The project will be structured as such:

```sh
├── CMakeLists.txt
├── main
│   ├── CMakeLists.txt
│   └── wifi_tutorial.c # Source file that contains the entry point
│   └── tutorial.c      # Create this source file
│   └── tutorial.h      # Create this header file
└── README.md
```

We need to edit `main/CMakeLists.txt` so that the files added will be included in the build process. For more information about the ESP-IDF build system, you can refer to this [document](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html).

Include the folowing in `main/CMakeLists.txt`
```txt
idf_component_register(SRCS "tutorial.c" "wifi_tutorial.c"
                    INCLUDE_DIRS ".")
```

In the `main/tutorial.h` file, we will first declare the following functions:

```h
#pragma once

#include "esp_err.h"
#include "esp_log.h"

#include "nvs_flash.h"
#include "esp_event.h"
#include "esp_wifi.h"

#include "freertos/FreeRTOS.h"

esp_err_t tutorial_init(void);

esp_err_t tutorial_connect(char* wifi_ssid, char* wifi_password);

esp_err_t tutorial_disconnect(void);

esp_err_t tutorial_deinit(void);
```

In the subsequent sections, we will go in detail through the steps of properly setting up, connecting, and terminating a Wi-Fi connection in the Espressif SoC.

#### Step 3: Wi-Fi initialization

We will first define the various headers, macros, and static variables in `tutorial.c` needed for the initialization step.

In `tutorial.c`, we first define the following:

```c
// tutorial.c
#include "tutorial.h"

#include <inttypes.h>
#include <string.h>

#include "freertos/event_groups.h"

#define TAG "tutorial"

#define WIFI_AUTHMODE WIFI_AUTH_WPA2_PSK

#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT BIT1

static const int WIFI_RETRY_ATTEMPT = 3;
static int wifi_retry_count = 0;

static esp_netif_t *tutorial_netif = NULL;
static esp_event_handler_instance_t ip_event_handler;
static esp_event_handler_instance_t wifi_event_handler;

static EventGroupHandle_t s_wifi_event_group = NULL;
```

In `tutorial_init()`, we will initialize the hardware and interface needed to set up Wi-FI as shown below:

```c
esp_err_t tutorial_init(void)
{
    // Initialize Non-Volatile Storage (NVS)
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }

    s_wifi_event_group = xEventGroupCreate();

    ret = esp_netif_init();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to initialize TCP/IP network stack");
        return ret;
    }

    ret = esp_event_loop_create_default();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to create default event loop");
        return ret;
    }

    ret = esp_wifi_set_default_wifi_sta_handlers();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to set default handlers");
        return ret;
    }

    tutorial_netif = esp_netif_create_default_wifi_sta();
    if (tutorial_netif == NULL) {
        ESP_LOGE(TAG, "Failed to create default WiFi STA interface");
        return ESP_FAIL;
    }

    // Wi-Fi stack configuration parameters
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT,
                                                        ESP_EVENT_ANY_ID,
                                                        &wifi_event_cb,
                                                        NULL,
                                                        &wifi_event_handler));
    ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT,
                                                        ESP_EVENT_ANY_ID,
                                                        &ip_event_cb,
                                                        NULL,
                                                        &ip_event_handler));
    return ret;
}
```

In particular, we can notice that the initialization step is similar to the previous example that uses `example_connect()`. Furthermore, there are additional initialization steps, such as defining the event loop, registering the event handler, and creating the network interface. The documentation for these additional steps can be found here:
- [Event Loop Library](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/esp_event.html#event-loop-library)
- [Event Handler](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/esp_event.html#event-loop-library)
- [Netif (Network Interface)](https://docs.espressif.com/projects/esp-idf/en/v5.2.2/esp32/api-reference/network/esp_netif.html?highlight=netif_create_default#_CPPv433esp_netif_create_default_wifi_stav)

In this tutorial, we also use Event Bits to indicate what Wi-Fi event has occurred. The details on Event Bits and Event Groups can be found [here](https://docs.espressif.com/projects/esp-idf/en/v5.2.2/esp32/api-reference/system/freertos_idf.html?highlight=eventgroup#_CPPv417xEventGroupCreatev).

#### Step 4: Wi-Fi configuration and connection

To establish a Wi-Fi connection, we can configure the type of connection, security level and hardware mode using the following method:

```c
esp_err_t tutorial_connect(char* wifi_ssid, char* wifi_password)
{
    wifi_config_t wifi_config = {
        .sta = {
            // this sets the weakest authmode accepted in fast scan mode (default)
            .threshold.authmode = WIFI_AUTHMODE,
        },
    };

    strncpy((char*)wifi_config.sta.ssid, wifi_ssid, sizeof(wifi_config.sta.ssid));
    strncpy((char*)wifi_config.sta.password, wifi_password, sizeof(wifi_config.sta.password));

    ESP_ERROR_CHECK(esp_wifi_set_ps(WIFI_PS_NONE)); // default is WIFI_PS_MIN_MODEM
    ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM)); // default is WIFI_STORAGE_FLASH

    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));

    ESP_LOGI(TAG, "Connecting to Wi-Fi network: %s", wifi_config.sta.ssid);
    ESP_ERROR_CHECK(esp_wifi_start());

    EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group, WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
        pdFALSE, pdFALSE, portMAX_DELAY);

    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "Connected to Wi-Fi network: %s", wifi_config.sta.ssid);
        return ESP_OK;
    } else if (bits & WIFI_FAIL_BIT) {
        ESP_LOGE(TAG, "Failed to connect to Wi-Fi network: %s", wifi_config.sta.ssid);
        return ESP_FAIL;
    }

    ESP_LOGE(TAG, "Unexpected Wi-Fi error");
    return ESP_FAIL;
}
```

We can configure the Wi-Fi connection via `wifi_config_t`. To set up a Wi-Fi station on an Espressif SoC, we will need to configure the fields in `wifi_sta_config_t`. Here are some fields that are commonly configured:
- `wifi_config.ssid` : The SSID of target AP
- `wifi_config.password` : The password of target AP
- `wifi_config.scan_method`: Method of AP discovery
- `wifi_config.threshold.authmode` : The weakest authentication mode required to accept the Wi-Fi connection.

The documentation for STA configuration can be found [here](https://docs.espressif.com/projects/esp-idf/en/v5.2.2/esp32/api-reference/network/esp_wifi.html?highlight=wifi_config_t#_CPPv417wifi_sta_config_t). The relative strength of authmodes and the configuration options for each of the field in the Wi-Fi config can be found in `esp_wifi_types_generic.h` [here](https://github.com/espressif/esp-idf/blob/v5.2.2/components/esp_wifi/include/esp_wifi_types.h)

We can also configure the hardware resources allocated for managing Wi-Fi. For instance, we disable any power saving mode using `esp_wifi_set_ps()` in this tutorial to maximize reception and transmission of Wi-Fi data packets. However, there are some scenarios require that we set a specific power safe type, such as those requiring [power saving modes](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/sleep_modes.html#sleep-modes) and [RF coexistence](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/coexist.html#rf-coexistence).

> Note that `xEventGroupWaitBits()` in the code above is a blocking process that waits until one of the bits are set by the event handlers. The documentation can be found [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/freertos_idf.html?highlight=xeventgroup#_CPPv419xEventGroupWaitBits18EventGroupHandle_tK11EventBits_tK10BaseType_tK10BaseType_t10TickType_t).
>
> Some familiarity with FreeRTOS concepts will be helpful to understand the behaviour of the program, refer to the documentation [here](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/freertos_idf.html?highlight=xeventgroup#overview).
> For advanced use cases, it is possible to run the Wi-Fi routine as a RTOS task to avoid it from blocking the rest of the application while waiting for a Wi-Fi connection to be established.

**Event Handler for Wi-FI and IP events**

For this example, we created simple event handlers to log events related to [Wi-Fi](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_wifi.html?highlight=wifi_event#_CPPv412wifi_event_t) (defined under `wifi_event_t`) or [IP layer](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_netif.html#ip-events) (defined under `ip_event_t`).

The important notable events in establishing Wi-Fi are:
- `WIFI_EVENT_STA_START` : The configuration for STA is completed
- `WIFI_EVENT_STA_CONNECTED` : The STA managed to establish a connection with the Wi-Fi Access Point
- `WIFI_EVENT_STA_DISCONNECTED`: The STA lost a connection with an AP or timeout
- `IP_EVENT_STA_GOT_IP`: The Espressif SoC received an IP address assigned by the AP, the Wi-Fi connection is complete.

#### Step 5: Wi-Fi shutdown and cleanup

To disconnect from Wi-Fi, we can simply call the Wi-Fi APIs in the following sequence:
1. `esp_wifi_disconnect()`
2. `esp_wifi_stop()`
3. `esp_wifi_deinit()`

We will need to clear the driver, network interface and unregister the event handlers as well.

Hence, `tutorial_disconnect()` and `tutorial_deinit()` are implemented as follows:

```c
esp_err_t tutorial_disconnect(void)
{
    if (s_wifi_event_group) {
        vEventGroupDelete(s_wifi_event_group);
    }

    return esp_wifi_disconnect();
}

esp_err_t tutorial_deinit(void)
{
    esp_err_t ret = esp_wifi_stop();
    if (ret == ESP_ERR_WIFI_NOT_INIT) {
        ESP_LOGE(TAG, "Wi-Fi stack not initialized");
        return ret;
    }

    ESP_ERROR_CHECK(esp_wifi_deinit());
    ESP_ERROR_CHECK(esp_wifi_clear_default_wifi_driver_and_handlers(tutorial_netif));
    esp_netif_destroy(tutorial_netif);

    ESP_ERROR_CHECK(esp_event_handler_instance_unregister(IP_EVENT, ESP_EVENT_ANY_ID, ip_event_handler));
    ESP_ERROR_CHECK(esp_event_handler_instance_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, wifi_event_handler));

    return ESP_OK;
}
```

#### Step 6: Put everything together

We have finished implementing the Wi-Fi connection according to the desired configuration. To demonstrate the Wi-Fi functionality, we will do the following:
1. Initialization
2. Establish Wi-Fi connection
3. Once connection is established, print out information about the Access Point
4. Terminate Wi-Fi connection
5. Release the resources used for Wi-Fi connection

We encourage you to code out `wifi_tutorial.c` without referring to the answer! The complete code snippet can be found in the [next section](#part-2-using-the-wi-fi-apis-1).

Here is a demonstration of the tutorial:

{{< asciinema key="wifiApiMonitor" >}}


## Code Reference
<!--
- **Code Reference:**
  - Provide the code in whole.
  - Explain why the code is written in a certain way and why it's called.
  - Provide expected output if the portion of code is run.

-->

### Part 1: Using the `example_connect()` function
```c
// simple_connect.c
#include <stdio.h>
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_netif.h"
#include "esp_event.h"

#include "protocol_examples_common.h"
#include "esp_wifi.h"

#define TAG "simple_connect_example"

void app_main(void)
{
	ESP_LOGI(TAG, "Hello from ESP32!");

	// System initialization
	ESP_ERROR_CHECK(nvs_flash_init());
	ESP_ERROR_CHECK(esp_netif_init());
	ESP_ERROR_CHECK(esp_event_loop_create_default());

	// Establish Wi-Fi connection
	ESP_ERROR_CHECK(example_connect());

	// Print out Access Point Information
	wifi_ap_record_t ap_info;
	ESP_ERROR_CHECK(esp_wifi_sta_get_ap_info(&ap_info));
	ESP_LOGI(TAG, "--- Access Point Information ---");
	ESP_LOG_BUFFER_HEX("MAC Address", ap_info.bssid, sizeof(ap_info.bssid));
	ESP_LOG_BUFFER_CHAR("SSID", ap_info.ssid, sizeof(ap_info.ssid));
	ESP_LOGI(TAG, "Primary Channel: %d", ap_info.primary);
	ESP_LOGI(TAG, "RSSI: %d", ap_info.rssi);

	// Disconnect from Wi-Fi
	ESP_ERROR_CHECK(example_disconnect());
}
```

### Part 2: Using the Wi-Fi APIs

```h
// tutorial.h
#pragma once

#include "esp_err.h"
#include "esp_log.h"

#include "nvs_flash.h"
#include "esp_event.h"
#include "esp_wifi.h"

#include "freertos/FreeRTOS.h"

esp_err_t tutorial_init(void);

esp_err_t tutorial_connect(char* wifi_ssid, char* wifi_password);

esp_err_t tutorial_disconnect(void);

esp_err_t tutorial_deinit(void);
```

```c
// tutorial.c
#include "tutorial.h"

#include <inttypes.h>
#include <string.h>

#include "freertos/event_groups.h"

#define TAG "tutorial"

#define WIFI_AUTHMODE WIFI_AUTH_WPA2_PSK

#define WIFI_CONNECTED_BIT BIT0
#define WIFI_FAIL_BIT BIT1

static const int WIFI_RETRY_ATTEMPT = 3;
static int wifi_retry_count = 0;

static esp_netif_t *tutorial_netif = NULL;
static esp_event_handler_instance_t ip_event_handler;
static esp_event_handler_instance_t wifi_event_handler;

static EventGroupHandle_t s_wifi_event_group = NULL;

static void ip_event_cb(void *arg, esp_event_base_t event_base, int32_t event_id, void *event_data)
{
    ESP_LOGI(TAG, "Handling IP event, event code 0x%" PRIx32, event_id);
    switch (event_id)
    {
    case (IP_EVENT_STA_GOT_IP):
        ip_event_got_ip_t *event_ip = (ip_event_got_ip_t *)event_data;
        ESP_LOGI(TAG, "Got IP: " IPSTR, IP2STR(&event_ip->ip_info.ip));
        wifi_retry_count = 0;
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
        break;
    case (IP_EVENT_STA_LOST_IP):
        ESP_LOGI(TAG, "Lost IP");
        break;
    case (IP_EVENT_GOT_IP6):
        ip_event_got_ip6_t *event_ip6 = (ip_event_got_ip6_t *)event_data;
        ESP_LOGI(TAG, "Got IPv6: " IPV6STR, IPV62STR(event_ip6->ip6_info.ip));
        wifi_retry_count = 0;
        xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
        break;
    default:
        ESP_LOGI(TAG, "IP event not handled");
        break;
    }
}

static void wifi_event_cb(void *arg, esp_event_base_t event_base, int32_t event_id, void *event_data)
{
    ESP_LOGI(TAG, "Handling Wi-Fi event, event code 0x%" PRIx32, event_id);

    switch (event_id)
    {
    case (WIFI_EVENT_WIFI_READY):
        ESP_LOGI(TAG, "Wi-Fi ready");
        break;
    case (WIFI_EVENT_SCAN_DONE):
        ESP_LOGI(TAG, "Wi-Fi scan done");
        break;
    case (WIFI_EVENT_STA_START):
        ESP_LOGI(TAG, "Wi-Fi started, connecting to AP...");
        esp_wifi_connect();
        break;
    case (WIFI_EVENT_STA_STOP):
        ESP_LOGI(TAG, "Wi-Fi stopped");
        break;
    case (WIFI_EVENT_STA_CONNECTED):
        ESP_LOGI(TAG, "Wi-Fi connected");
        break;
    case (WIFI_EVENT_STA_DISCONNECTED):
        ESP_LOGI(TAG, "Wi-Fi disconnected");
        if (wifi_retry_count < WIFI_RETRY_ATTEMPT) {
            ESP_LOGI(TAG, "Retrying to connect to Wi-Fi network...");
            esp_wifi_connect();
            wifi_retry_count++;
        } else {
            ESP_LOGI(TAG, "Failed to connect to Wi-Fi network");
            xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
        }
        break;
    case (WIFI_EVENT_STA_AUTHMODE_CHANGE):
        ESP_LOGI(TAG, "Wi-Fi authmode changed");
        break;
    default:
        ESP_LOGI(TAG, "Wi-Fi event not handled");
        break;
    }
}


esp_err_t tutorial_init(void)
{
    // Initialize Non-Volatile Storage (NVS)
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }

    s_wifi_event_group = xEventGroupCreate();

    ret = esp_netif_init();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to initialize TCP/IP network stack");
        return ret;
    }

    ret = esp_event_loop_create_default();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to create default event loop");
        return ret;
    }

    ret = esp_wifi_set_default_wifi_sta_handlers();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to set default handlers");
        return ret;
    }

    tutorial_netif = esp_netif_create_default_wifi_sta();
    if (tutorial_netif == NULL) {
        ESP_LOGE(TAG, "Failed to create default WiFi STA interface");
        return ESP_FAIL;
    }

    // Wi-Fi stack configuration parameters
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT,
                                                        ESP_EVENT_ANY_ID,
                                                        &wifi_event_cb,
                                                        NULL,
                                                        &wifi_event_handler));
    ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT,
                                                        ESP_EVENT_ANY_ID,
                                                        &ip_event_cb,
                                                        NULL,
                                                        &ip_event_handler));
    return ret;
}

esp_err_t tutorial_connect(char* wifi_ssid, char* wifi_password)
{
    wifi_config_t wifi_config = {
        .sta = {
            // this sets the weakest authmode accepted in fast scan mode (default)
            .threshold.authmode = WIFI_AUTHMODE,
        },
    };

    strncpy((char*)wifi_config.sta.ssid, wifi_ssid, sizeof(wifi_config.sta.ssid));
    strncpy((char*)wifi_config.sta.password, wifi_password, sizeof(wifi_config.sta.password));

    ESP_ERROR_CHECK(esp_wifi_set_ps(WIFI_PS_NONE)); // default is WIFI_PS_MIN_MODEM
    ESP_ERROR_CHECK(esp_wifi_set_storage(WIFI_STORAGE_RAM)); // default is WIFI_STORAGE_FLASH

    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));

    ESP_LOGI(TAG, "Connecting to Wi-Fi network: %s", wifi_config.sta.ssid);
    ESP_ERROR_CHECK(esp_wifi_start());

    EventBits_t bits = xEventGroupWaitBits(s_wifi_event_group, WIFI_CONNECTED_BIT | WIFI_FAIL_BIT,
        pdFALSE, pdFALSE, portMAX_DELAY);

    if (bits & WIFI_CONNECTED_BIT) {
        ESP_LOGI(TAG, "Connected to Wi-Fi network: %s", wifi_config.sta.ssid);
        return ESP_OK;
    } else if (bits & WIFI_FAIL_BIT) {
        ESP_LOGE(TAG, "Failed to connect to Wi-Fi network: %s", wifi_config.sta.ssid);
        return ESP_FAIL;
    }

    ESP_LOGE(TAG, "Unexpected Wi-Fi error");
    return ESP_FAIL;
}

esp_err_t tutorial_disconnect(void)
{
    if (s_wifi_event_group) {
        vEventGroupDelete(s_wifi_event_group);
    }

    return esp_wifi_disconnect();
}

esp_err_t tutorial_deinit(void)
{
    esp_err_t ret = esp_wifi_stop();
    if (ret == ESP_ERR_WIFI_NOT_INIT) {
        ESP_LOGE(TAG, "Wi-Fi stack not initialized");
        return ret;
    }

    ESP_ERROR_CHECK(esp_wifi_deinit());
    ESP_ERROR_CHECK(esp_wifi_clear_default_wifi_driver_and_handlers(tutorial_netif));
    esp_netif_destroy(tutorial_netif);

    ESP_ERROR_CHECK(esp_event_handler_instance_unregister(IP_EVENT, ESP_EVENT_ANY_ID, ip_event_handler));
    ESP_ERROR_CHECK(esp_event_handler_instance_unregister(WIFI_EVENT, ESP_EVENT_ANY_ID, wifi_event_handler));

    return ESP_OK;
}
```

```c
// wifi_tutorial.c
#include <stdio.h>

#include "esp_log.h"
#include "esp_wifi.h"

#include "tutorial.h"

#include "freertos/task.h"

#define TAG "main"

// Enter the Wi-Fi credentials here
#define WIFI_SSID "SSID"
#define WIFI_PASSWORD "PASSWORD"

void app_main(void)
{
    ESP_LOGI(TAG, "Starting tutorial...");
    ESP_ERROR_CHECK(tutorial_init());

    esp_err_t ret = tutorial_connect(WIFI_SSID, WIFI_PASSWORD);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to connect to Wi-Fi network");
    }

    wifi_ap_record_t ap_info;
    ret = esp_wifi_sta_get_ap_info(&ap_info);
    if (ret == ESP_ERR_WIFI_CONN) {
        ESP_LOGE(TAG, "Wi-Fi station interface not initialized");
    }
    else if (ret == ESP_ERR_WIFI_NOT_CONNECT) {
        ESP_LOGE(TAG, "Wi-Fi station is not connected");
    } else {
        ESP_LOGI(TAG, "--- Access Point Information ---");
        ESP_LOG_BUFFER_HEX("MAC Address", ap_info.bssid, sizeof(ap_info.bssid));
        ESP_LOG_BUFFER_CHAR("SSID", ap_info.ssid, sizeof(ap_info.ssid));
        ESP_LOGI(TAG, "Primary Channel: %d", ap_info.primary);
        ESP_LOGI(TAG, "RSSI: %d", ap_info.rssi);

        ESP_LOGI(TAG, "Disconnecting in 5 seconds...");
        vTaskDelay(pdMS_TO_TICKS(5000));
    }

    ESP_ERROR_CHECK(tutorial_disconnect());

    ESP_ERROR_CHECK(tutorial_deinit());

    ESP_LOGI(TAG, "End of tutorial...");
}
```

## Conclusion
<!--
- ** Next tutorial **
  - Link to the subsequent sub-module
-->

In this tutorial, we learned various ways to establish a basic Wi-Fi connection from our Espressif Soc to an Access Point.

We delved into the intricacies of initializing the resources needed for the Wi-Fi capabilities on the Espressif Soc, where we explored the sequence of steps in detail needed for a robust configuration.

To gain a better understanding of the Wi-Fi capabilities on Espressif Soc, we invite you to experiment with different Wi-Fi configurations, such as WPA3 or DPP. We hope that this tutorial has given you the necessary tools to explore them!

Espressif SoCs have so much more to offer! Do feel free to explore the other networking examples such as [bluetooth](https://github.com/espressif/esp-idf/tree/master/examples) or [zigbee](https://github.com/espressif/esp-idf/tree/master/examples/zigbee) or build further with [protocol](https://github.com/espressif/esp-idf/tree/master/examples/protocols) examples on ESP-IDF!

## Error & Troubleshooting
<!--
- **Error & Troubleshooting:**
  - Include possible errors that users can encounter and the ways to solve them.
  - Continuously update this section based on comments under the guide and feedback from workshops.
-->
Here are some common errors:

### Error 1: Missing header file for simple connect example
```bash
/home/haoyi/esp/simple_connect/main/main.c:3:10: fatal error: protocol_examples_common.h: No such file or directory
    3 | #include "protocol_examples_common.h"
      |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
compilation terminated.
ninja: build stopped: subcommand failed.
```
- Ensure that the dependency path in `idf_component.yml` is correct.
- Then run `idf.py fullclean` and build again by running `idf.py build`

### Error 2: NVS not initialized
```bash
ESP_ERROR_CHECK failed: esp_err_t 0x1101 (ESP_ERR_NVS_NOT_INITIALIZED) at 0x42008226
file: "/IDF/examples/common_components/protocol_examples_common/wifi_connect.c" line 138
func: example_wifi_start
expression: esp_wifi_init(&cfg)

abort() was called at PC 0x40385c3b on core 0
```
- Call `nvs_flash_init()` before calling `example_connect()`

### Error 3: Fail to initialize Wi-Fi due to invalid state
``` bash
I (487) phy_init: phy_version 1110,9c20f0a,Jul 27 2023,10:42:54
I (527) wifi:mode : sta (48:27:e2:b5:5c:64)
I (527) wifi:enable tsf
E (527) wifi:failed to post WiFi event=2 ret=259
ESP_ERROR_CHECK failed: esp_err_t 0x103 (ESP_ERR_INVALID_STATE) at 0x420089ec
file: "/IDF/examples/common_components/protocol_examples_common/wifi_connect.c" line 183
func: example_wifi_sta_do_connect
expression: esp_event_handler_register(WIFI_EVENT, WIFI_EVENT_STA_DISCONNECTED, &example_handler_on_wifi_disconnect, NULL)

abort() was called at PC 0x40386345 on core 0
```
- Call `esp_netif_init()` and `esp_event_loop_create_default()` before calling `example_connect()`


## References

<!--
- **References:**
  - Links to references on the protocol in discussion.
  - Github example
  - ESP Docs

-->
- **References:**
    - [The ESP Journal: Leveraging Wi-Fi 6 Features for IoT Applications](https://blog.espressif.com/leveraging-wi-fi-6-features-for-iot-applications-c23cc6a548aa)
    - [ESP32-C3 Wireless Adventure: A Comprehensive Guide to IoT](https://github.com/espressif/esp32-c3-book-en)
    - [Espressif Wi-Fi Driver Documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/wifi.html)
    - [Espressif Wi-Fi APIs References](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_wifi.html)
