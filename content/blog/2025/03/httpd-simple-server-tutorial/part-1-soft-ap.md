---
title: "Part 1: Create a soft-AP"
date: 2025-03-26
showAuthor: false
featureAsset: "img/featured/featured_httpd.webp"
authors:
  - francesco-bez 
tags: [soft-AP, ESP32-C3, ESP-IDF]
summary: "In this first part, you will set up an access point (soft-AP) and manage a few basic Wi-Fi events. "
---

There are many ways you can do the credentail provisioning for an IoT application, the most common arguably being the provisioning over Bluetooth. But there are several cases where using WiFi provisioning may be the best way to do it. 

<!-- > [!NOTE]
> If you are interested in creating a robust provisioning for an Espressif-based product, the best approach is to use the [Unified Provisioning](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/provisioning/provisioning.html). -->

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5" >}}
If you are interested in creating a robust provisioning for an Espressif-based product, the best approach is to use the [Unified Provisioning](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/provisioning/provisioning.html).
{{< /alert >}}

In this first part tutorial, you will create a new project, include the necessary libraries and catch the Wi-Fi events.

The shortcuts mentioned below refer to VSCode, but you can use any IDE or any editor if compiling through the command line.  

## Create a new project

To start a new project and prepare for the following steps, you will perform these actions: 
1. Create a new project using the [`hello_world`](https://github.com/espressif/esp-idf/tree/master/examples/get-started/hello_world) template.
2. Set the target core.
3. Select right port.
4. Build, flash and start a monitor with `hello_world`.

To start, let's create a new project. Open VSCode, press `CTRL+SHIFT+P`and start typing `ESP-IDF: New Project`. Follow the instructions to create a new project using the `hello_world` template. 

Next, you need to set the target and port for the flashing stage. In this tutorial, we're using an `ESP32-C3-DevKitM-1`. 
Start typing `ESP-IDF: Set Espressif Device Target` and select `esp32c3`. If you are using an EVK or a USB-UART bridge, select `The ESP32-C3 Chip via builtin USB-JTAG`. If you're using one of the `ESP-PROG` programmers, choose the most appropriate option. 

Next, select the right port by typing `ESP-IDF: Select Port to Use (COM, tty, usbserial)`. 
At this point, you can run the command `ESP-IDF: Build, Flash and start a Monitor on your device`. 

If everything runs smoothly, you should see the compilation finish succesfully, followed by the firmware flashing and the `hello_world` example running, displaying `Hello world!` and restarting after 10 seconds. 

Now, update the content of `hello_world_main.c` to the following code:

```C
#include <stdio.h>
#include "sdkconfig.h"

void app_main(void)
{
    printf("Hello tutorial!\n");

}
```

Then build, flash and monitor again to confirm that everything is working correctly. 

Before moving on, it's best rename the file for better clarity. Rename the file `hello_world_main.c` &rarr; `basic_http_server.c`. 
Update CMake to ensure it compiles the new file instead of the old one. Open `main/CMakeLists.txt` and change the content to
```
idf_component_register(SRCS "basic_http_server.c"
                    PRIV_REQUIRES 
                    INCLUDE_DIRS "")
```

After making these changes:

- Perform a full clean: Run `ESP-IDF: Full Clean Project`
- Build, flash and open a monitor again. 

<!-- > [!WARNING]
> Every time you change the CMakeLists.txt, you need to perform a full clean to see the changes take effect. To know more about the build system, consult the [documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html#minimal-component-cmakelists). -->

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Every time you change the CMakeLists.txt, you need to perform a full clean to see the changes take effect. To learn more about the build system, consult the [documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html#minimal-component-cmakelists).
{{< /alert >}}


A final step before moving on: To keep things as simple as possible, this tutorial will not use Non-Volatile Storage (NVS), which is commonly used with Wi-Fi to store credentials and access calibration data.

By default, some configuration variables have NVS enabled, which may cause warnings or errors. To avoid this, you need to disable them in menuconfig.

To access menuconfig, press `CTRL+SHIFT+P`, type `ESP-IDF: SDK Configuration Editor` and select it. In the search bar type `NVS` then uncheck the following options

{{< figure
default=true
src="../img/disable_nvs.webp"
height=500
caption="NVS options to be disabled"
    >}}

Now your project should resemble the [bare-minimum example](https://github.com/FBEZ-docs-and-templates/devrel-tutorials-code/tree/main/tutorial-basic-project) in the repository below. 
{{< github repo="FBEZ-docs-and-templates/devrel-tutorials-code" >}}

## A short detour: Logs

While not strictly necessary for this tutorial, logs are extremely useful when developing applications. 

Espressif logging system is provided by the `esp_log.h` header, which you need to include to use logging features.

### How to Use Logging in Your Code  
1. Include the header: 
   ```c
   #include "esp_log.h"
   ```  
2. Define a module-specific tag:
   Each C file using logging should define a **TAG** string:  
   ```c
   static const char* TAG = "my_module";
   ```  
3. Use the logging macros: 
   You can then log messages using macros like:  
   ```c
   ESP_LOGI(TAG, "Server connection with code %d", server_code);
   ```  

### Logging Levels in ESP-IDF  
In this tutorial, only `ESP_LOGI` (informational logs) will be used, but there are other available logging macros:  
- `ESP_LOGE(TAG, "...")` – Error logs  
- `ESP_LOGW(TAG, "...")` – Warning logs  
- `ESP_LOGD(TAG, "...")` – Debug logs  
- `ESP_LOGV(TAG, "...")` – Verbose logs  

For a detailed explanation of logging functions, refer to the [official documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/log.html). 


## Event loop and esp-netif initialization

Espressif IP stack is managed through an unified interface called [`esp_netif`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_netif.html#esp-netif). This interface was designed to provide an agnostic abstraction for different IP stacks. Currently the only TCP/IP stack available through this interface is lwIP. 

For most application, creating a default network with the default event loop is sufficient - this is the approach used in this tutorial.  

Now create a new function `wifi_init_softap` to keep things clean and provide an easy way to start a new task.

What you need to do:
1. **Initialize `esp_netif`:**  
   Call `esp_netif_init()` to initialize the network interface.  
2. **Initialize the event loop:**  
   Call `esp_event_loop_create_default()` to initialize the standard event loop.  
3. **Register handlers for soft AP:**  
   Register the event handlers needed for a soft AP application.  
4. **Configure and start the Wi-Fi access point (AP):**  
   Set up the Wi-Fi AP configuration and start it.  

<!-- > [!INFO] For a complete implementation with error handling you can refer [here](https://github.com/espressif/esp-idf/blob/master/examples/wifi/getting_started/softAP/main/softap_example_main.c#L47). -->

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
For a complete implementation with error handling you can refer [here](https://github.com/espressif/esp-idf/blob/master/examples/wifi/getting_started/softAP/main/softap_example_main.c#L47).
{{< /alert >}}

Best practices dictate that you should avoid hard-coding credentials directly in your code. Instead, credentials should be stored in the Non-Volatile Storage (NVS) partition. This approach is commonly used in the ESP-IDF examples and is the recommended way to manage credentials.

For the sake of simplicity in this tutorial, however, you will define the AP credentials directly in the code as simple defines.

First, you need to **define all the necessary values** for initialization, including:  

- **SSID** (Wi-Fi network name)  
- **Password**  
- **Wi-Fi Channel**  
- **Maximum number of connections**  

This is done using the `#define` statements:

```c
#define ESP_WIFI_SSID "esp_tutorial"
#define ESP_WIFI_PASS "test_esp"
#define ESP_WIFI_CHANNEL 1
#define MAX_STA_CONN 2
```
<!-- > [!CAUTION] This is not the reccomended way to store credentials. Please store them in NVS when writing a real application.  -->
<!-- 
reached this point -->

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
 This is __not__ the recommended way to store credentials. Please store them securely in NVS or manage them through configuration settings using menuconfig.
{{< /alert >}}

Espressif's Wi-Fi component relies on an [event loop](https://en.wikipedia.org/wiki/Event_loop) to handle asynchronous events. Therefore, you need to:  

1. Start the [default event loop](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/esp_event.html#default-event-loop). 
2. Create and register an event handler function to process Wi-Fi events.  

For now, this function will simply print the `event_id`. 

```c
void wifi_init_softap()
{
    esp_netif_init();
    esp_event_loop_create_default();
    esp_netif_create_default_wifi_ap();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT(); // always start with this

    esp_wifi_init(&cfg);

    esp_event_handler_instance_register(WIFI_EVENT,
                                                        ESP_EVENT_ANY_ID,
                                                        &wifi_event_handler,
                                                        NULL,
                                                        NULL);

    wifi_config_t wifi_config = {
        .ap = {
            .ssid = ESP_WIFI_SSID,
            .ssid_len = strlen(ESP_WIFI_SSID),
            .channel = ESP_WIFI_CHANNEL,
            .password = ESP_WIFI_PASS,
            .max_connection = MAX_STA_CONN,
            .authmode = WIFI_AUTH_WPA2_PSK,
            .pmf_cfg = {
                .required = true,
            },
        },
    };


    esp_wifi_set_mode(WIFI_MODE_AP);
    esp_wifi_set_config(WIFI_IF_AP, &wifi_config);
    esp_wifi_start();

    ESP_LOGI(TAG, "wifi_init_softap finished. SSID:%s password:%s channel:%d",
             ESP_WIFI_SSID, ESP_WIFI_PASS, ESP_WIFI_CHANNEL);
}
```

For now, the function handling Wi-Fi events is as follows:

```c
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                                  int32_t event_id, void* event_data){
    printf("Event nr: %ld!\n", event_id);
}
```

Now compile, flash, start a monitor and run the project. You should start seeing several event numbers appearing on the terminal.

At this point, take your smartphone, open the Wi-Fi list, and select the SSID `esp_tutorial`. When you do so, you should see on the terminal `Event nr: 14!`. 
 
{{< figure
    default=true
    src="../img/ap_list.webp"
    height=500
    caption="Listing of APs"
    >}}

If you check on the `esp-idf` source code related to the event codes ([here](https://github.com/espressif/esp-idf/blob/c5865270b50529cd32353f588d8a917d89f3dba4/components/esp_wifi/include/esp_wifi_types_generic.h#L964)), you will find that 14 corresponds to `WIFI_EVENT_AP_STACONNECTED`. 

This indicates that a station (STA) has connected to the soft-AP. 

<!--  [!NOTE] 
> You can use the `event_id`to discriminate between different events and then use the additional data you are provided with `event_data`.  
 -->


You can use the `event_id`to distinguish between different events and then process the additional data you available in `event_data`.  

This allows you to handle specific Wi-Fi events appropriately, such as when a station connects or disconnects from the soft-AP. 


{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}

`event_data` is a void pointer, you need to cast it to the proper structure if you want to extract data. [Here](https://github.com/espressif/esp-idf/blob/c5865270b50529cd32353f588d8a917d89f3dba4/examples/wifi/getting_started/softAP/main/softap_example_main.c#L36) you can find two examples. 

{{< /alert >}}

<!-- Note that `event_data` is a void pointer, you need to cast it to the proper structure if you want to extract data. [Here](https://github.com/espressif/esp-idf/blob/c5865270b50529cd32353f588d8a917d89f3dba4/examples/wifi/getting_started/softAP/main/softap_example_main.c#L36) you can find two examples. -->

## Summary of Part 1

In this first part you 
1. Created a new project based on the `hello_world` example.
2. Initialized the `esp_netif` library 
3. Started the standard event loop to handle Wi-Fi events
4. Configured and launched a soft-AP, allowing devices to connect via Wi-Fi
5. Verified event ahndling by checking the terminal for connection events. 

This forms the foundation for building an HTTP server, which will be covered in Part 2. There, you'll serve a web page and handle GET/POST requests.
