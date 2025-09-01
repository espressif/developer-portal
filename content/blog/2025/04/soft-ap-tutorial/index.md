---
title: "ESP-IDF Tutorials: Soft-AP"
date: 2025-04-18
showAuthor: false
authors:
  - francesco-bez 
tags: [soft-AP, ESP32-C3, ESP-IDF]
summary: "This tutorial guides you through setting up a soft-AP using an Espressif module and ESP-IDF. It covers the process of creating a project, configuring Wi-Fi, and handling connection events through event loops. Upon completion, you’ll be able to establish a soft-AP and manage Wi-Fi connections. It is the first step to building more advanced networking applications."
---

### Introduction  

In any Wi-Fi-enabled application, the first step is always to establish a connection between the device and the router. In Wi-Fi terminology, the device is referred to as a **Station (STA)**, while the router functions as an **Access Point (AP)**. In most applications, the Espressif module operates as a station, connecting to an existing router. However, before it can do so, the end user must perform **provisioning**—providing the module with the router's SSID and password.  

There are multiple ways to handle provisioning, but the two most common methods are via Bluetooth and via Wi-Fi. When using Wi-Fi for provisioning, the process typically follows these steps:  

1. The Espressif module starts a soft-AP (temporary access point).  
2. The user connects to this soft-AP.  
3. The module serves an HTTP page that prompts the user to enter the SSID and password.  
4. The user provides the necessary credentials.  
5. The module shuts down the soft-AP and switches to station mode, connecting to the router.  

Even if your application primarily runs the Espressif module in station mode, you'll still might need to set up a soft-AP for provisioning.  

Because provisioning is such a common requirement, this tutorial will be followed by another tutorial that explains how to set up an HTTP server to collect the SSID and password from the user.  


<!-- > [!NOTE]
> If you are interested in creating a robust provisioning for an Espressif-based product, the best approach is to use the [Unified Provisioning](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/provisioning/provisioning.html). -->

{{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5" >}}
This and the following tutorials use a simple provisioning technique, which is inherently less secure.

For real-world applications, it is better to use a  __robust__ provisioning solution, such as the [Unified Provisioning](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/provisioning/provisioning.html) framework. It allows configuring ESP devices with Wi-Fi credentials and custom settings using various transport methods (Wi-Fi SoftAP or Bluetooth LE) and security schemes.
{{< /alert >}}


This tutorial lays the groundwork for building more advanced Wi-Fi connectivity applications by ensuring a smooth and reliable connection setup.

In the steps that follow, we will:

1. Create a new project based on the `hello_world` example.
2. Rename the project and remove any unnecessary libraries and configurations.
3. Start the Soft-AP and set up handlers to manage Wi-Fi events.
4. Verify the connection using your smartphone

In this tutorial, we will also encounter

- **menuconfig** - The tool which handles the configuration in ESP-IDF projects
- **Event loops** – A design pattern used throughout the Espressif ESP-IDF framework to simplify the management of complex applications.  
- **[esp-netif](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-reference/network/esp_netif.html)** – Espressif's abstraction layer for TCP/IP networking.  
- **[Non-volatile storage (NVS)](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-reference/storage/nvs_flash.html)** – For saving credentials

<!-- {{< alert icon="circle-info" cardColor="#b3e0f2" iconColor="#04a5e5" >}}
Most commands in VSCode are executed through the Command Palette, which you can open by pressing `CTRL+SHIFT+P` (or `CMD+SHIFT+P` if you’re on mac-os). In this guide, commands to enter in the Command Palette are marked with the symbol `>` .
{{< /alert >}} -->


## Prerequisites

Before starting this tutorial, ensure that you

- Can compile and flash the [`hello_world`](https://github.com/espressif/esp-idf/tree/master/examples/get-started/hello_world) example. Two main methods followed below are using `idf.py` directly (CLI approach) or using the VS Code ESP-IDF Extension. If required, you can follow the instructions in the  [ESP-IDF Getting Started](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/get-started/index.html) guide. 
- Have an Espressif evaluation board or another compatible board for flashing the code. In this tutorial we will use the [ESP32-C3-DevkitM-1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32c3/esp32-c3-devkitm-1/user_guide.html) but any Espressif evaluation board will work just as well. If you built your own board, you might need an [ESP-PROG](https://docs.espressif.com/projects/esp-iot-solution/en/latest/hw-reference/ESP-Prog_guide.html) programmer. 
- Understand the difference between a Wi-Fi access point and a Wi-Fi station.
- (Optional) Have a basic knowledge of the [logging system](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/log.html#use-logging-library) in Espressif. 

If you're not quite comfortable with any of the above steps yet, consider checking out the [ESP-IDF with ESP32-C6 Workshop](../../../../workshops/esp-idf-with-esp32-c6/). These resources can help you get hands-on experience with setup, flashing, and basic debugging before diving into this tutorial.


## Starting a new project from `hello_world`

To start a new project and prepare for the following steps, we will perform these actions: 
1. Create a new project using the [`hello_world`](https://github.com/espressif/esp-idf/tree/master/examples/get-started/hello_world) example as a starting point.
2. Set the target core (in our case, `ESP32-C3`)
3. Select right port (here `/dev/tty.usbserial-11320`)
4. Build, flash, and start a monitor with `hello_world`.

To start, create a new project from `hello_world`. 
Below you can find a refresher for VS Code and using the CLI. 

{{< tabs groupId="devtool" >}}

{{% tab name="VS Code extension" %}}

Most commands in VSCode are executed through the Command Palette, which you can open by pressing `CTRL+SHIFT+P` (or `CMD+SHIFT+P` if you’re on mac-os). In the following, commands to enter in the Command Palette are marked with the symbol `>`.

* `> ESP-IDF: New Project`   
   _Follow the instructions to create a new project using the `hello_world` as a template_
* `> ESP-IDF: Set Espressif Device Target`    
  _Choose your SoC. In this tutorial we use `esp32c3`_
   *  _If you are using an evaluation board or a USB-UART bridge, select `The ESP32-C3 Chip via builtin USB-JTAG`_
   *  _If you're using one of the `ESP-PROG` programmers, choose the most appropriate option._
* `> ESP-IDF: Select Port to Use (COM, tty, usbserial)`    
   _Choose the port assigned to the board. Check with your os device manager if unsure_
* `> ESP-IDF: Build, Flash and start a Monitor on your device`


{{% /tab %}}

{{% tab name="CLI" %}}

If you're using a simple text editor and the CLI commands, you can follow the instruction on the get-started guide ([linux/mac-os](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/linux-macos-setup.html#get-started-linux-macos-first-steps) | [windows](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/windows-setup.html#get-started-windows-first-steps) ).

{{% /tab %}}
{{< /tabs >}}

If everything runs smoothly, we should see the compilation finish successfully, followed by the firmware flashing and the `hello_world` example running, displaying `Hello world!` and restarting after 10 seconds. 

We have just compiled the code and flashed it onto the internal flash memory of the Espressif module. On boot, the module now runs the `hello_world` example, sending a 'Hello, World' message to the serial port (connected to the programmer), along with a countdown until the module restarts. This step ensures that the entire process is working correctly. Now, we can begin modifying the code to implement the soft-AP.

## Renaming the Project and Cleaning Up

Now, we will rename the project and remove all the necessary commands and library. 
Update the content of `hello_world_main.c` to the following code:

```c
#include <stdio.h>
#include "sdkconfig.h"

void app_main(void)
{
    printf("Hello tutorial!\n");

}
```

Then build, flash, and monitor again to confirm that everything is working correctly. 
Before moving on, rename the file `hello_world_main.c` &rarr; `basic_soft_ap.c` for clarity. 
Update CMake to ensure it compiles the new file instead of the old one. Open `main/CMakeLists.txt` and change the content to
```
idf_component_register(SRCS "basic_http_server.c"
                    PRIV_REQUIRES 
                    INCLUDE_DIRS "")
```

After making these changes:

- Perform a full clean: Run in the command palette `ESP-IDF: Full Clean Project`
- Build, flash and open a monitor again. 

<!-- > [!WARNING]
> Every time you change the CMakeLists.txt, you need to perform a full clean to see the changes take effect. To know more about the build system, consult the [documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html#minimal-component-cmakelists). -->

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
Every time you change the CMakeLists.txt, you need to perform a full clean to see the changes take effect. To learn more about the build system, consult the document [Build System](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html#minimal-component-cmakelists).
{{< /alert >}}

### Disable NVS

To keep things as simple as possible, in this tutorial we will not use Non-Volatile Storage (NVS), which is commonly used with Wi-Fi to store credentials and access calibration data under the hood. 

By default, some configuration variables have NVS enabled, which may cause warnings or errors. To avoid this, we need to disable them in `menuconfig`. 


{{< tabs groupId="devtool" >}}
{{% tab name="VS Code extension" %}}
To access `menuconfig`, type `ESP-IDF: SDK Configuration Editor` in the command palette and hit <kbd>Enter</kbd>. 

In the `menuconfig` search bar type `NVS` then uncheck the following options
{{< figure
default=true
src="img/disable_nvs.webp"
height=500
caption="NVS options to be disabled"
    >}}
{{% /tab %}}

{{% tab name="CLI" %}}
To access `menuconfig`, call `idf.py menuconfig`
{{% /tab %}}
{{< /tabs >}}

Now your project should resemble the [bare-minimum example](https://github.com/FBEZ-docs-and-templates/devrel-tutorials-code/tree/main/tutorial-basic-project) in the repository below. 

{{< github repo="FBEZ-docs-and-templates/devrel-tutorials-code" >}}

<!-- After a quick look at how logs are managed in Espressif, we can start with the soft-AP.  -->
 
<!-- ## A short detour: Logs

While not strictly necessary for this tutorial, logs are extremely useful when developing applications. 

Espressif logging system is provided by the `esp_log.h` header, which you need to include to use logging features.

### How to use logging in your code  
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

For a detailed explanation of logging functions, refer to the [official documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/log.html).  -->


## Starting the soft-AP

To set up a soft-AP, we will need to: 

1. **Define soft-AP parameters:**  
   To keep things easy, we will use some `#define`s for SSID, password and the other soft-AP parameters.  
1. **Initialize the IP Stack:**  
   We'll call `esp_netif_init()` to initialize the network interface.
2. **Initialize the event loop:**  
   We'll call `esp_event_loop_create_default()` to initialize the standard event loop.  
3. **Register handlers for soft-AP:**  
   We'll register the event handlers needed for a soft-AP application.  


Espressif IP stack is managed through the unified interface called [`esp_netif`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_netif.html#esp-netif). This interface was designed to provide an agnostic abstraction for different IP stacks. Currently, the only TCP/IP stack available through this interface is lwIP. 

For most applications, creating a default network with the default event loop is sufficient -- this is the approach used in this tutorial.  


<!-- > [!INFO] For a complete implementation with error handling you can refer [here](https://github.com/espressif/esp-idf/blob/master/examples/wifi/getting_started/softAP/main/softap_example_main.c#L47). -->

{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}
For a complete implementation with error handling you can refer [here](https://github.com/espressif/esp-idf/blob/master/examples/wifi/getting_started/softAP/main/softap_example_main.c#L47).
{{< /alert >}}

### Define soft-AP parameters

Best practices dictate that we should avoid hard-coding credentials directly in our code. Instead, credentials should be stored in the Non-Volatile Storage (NVS) partition. This approach is commonly used in the ESP-IDF examples and is the recommended way to manage credentials.

For the sake of simplicity in this tutorial, however, we will define the AP credentials directly in the code as simple defines.

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
<!-- > [!CAUTION] This is not the recommended way to store credentials. Please store them in NVS when writing a real application.  -->
<!-- 
reached this point -->

{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
 This is __not__ the recommended way to store credentials. Please store them securely in NVS or manage them through configuration settings using menuconfig.
{{< /alert >}}

### Initialize the IP stack

To initialize the IP stack, we just need to call the two functions
```c
esp_netif_init();
esp_netif_create_default_wifi_ap();
```

### Initialize the event loop

Espressif's Wi-Fi component relies on an [event loop](https://en.wikipedia.org/wiki/Event_loop) to handle asynchronous events. Therefore, we need to:  

1. Start the [default event loop](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/esp_event.html#default-event-loop). 
2. Create and register an event handler function to process Wi-Fi events.  

For now, this function will simply print the `event_id`. 

To keep things clean, we will create a function called `wifi_init_softap` where we will encapsulate all the steps listed above required to start the soft-AP.

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

`ESP_LOGI` is a logging command which prints an information message on the terminal. If you're unsure about it, check the [logging library documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/log.html#use-logging-library).

### Handle Wi-Fi Events

At this point, the function handling Wi-Fi events is as follows:

```c
static void wifi_event_handler(void* arg, esp_event_base_t event_base,
                                  int32_t event_id, void* event_data){
    printf("Event nr: %ld!\n", event_id);
}
```

Now compile, flash, start a monitor and run the project. We should start seeing several event numbers appearing on the terminal.


## Testing the Connection with a Smartphone

At this point, take your smartphone, open the Wi-Fi list, and select the SSID `esp_tutorial`. When we do so, we should see on the terminal `Event nr: 14!`. 
 
{{< figure
    default=true
    src="img/ap_list.webp"
    height=500
    caption="Listing of APs"
    >}}

If we check on the `esp-idf` source code related to the event codes ([here](https://github.com/espressif/esp-idf/blob/c5865270b50529cd32353f588d8a917d89f3dba4/components/esp_wifi/include/esp_wifi_types_generic.h#L964)), we will find that 14 corresponds to `WIFI_EVENT_AP_STACONNECTED`. 

This indicates that a station (STA) has connected to the soft-AP. 

<!--  [!NOTE] 
> You can use the `event_id`to discriminate between different events and then use the additional data you are provided with `event_data`.  
 -->


We can use the `event_id` to distinguish between different events and then process the additional data you available in `event_data`.  

This allows us to handle specific Wi-Fi events appropriately, such as when a station connects or disconnects from the soft-AP. 


{{< alert icon="lightbulb" iconColor="#179299"  cardColor="#9cccce">}}

`event_data` is a void pointer, you need to cast it to the proper structure if you want to extract data. [Here](https://github.com/espressif/esp-idf/blob/c5865270b50529cd32353f588d8a917d89f3dba4/examples/wifi/getting_started/softAP/main/softap_example_main.c#L36) you can find two examples. 

{{< /alert >}}

You can find the complete code at the link [soft-ap tutorial code](https://github.com/FBEZ-docs-and-templates/devrel-tutorials-code/blob/main/tutorial-soft-ap/main/basic_soft_ap.c). 


<!-- Note that `event_data` is a void pointer, you need to cast it to the proper structure if you want to extract data. [Here](https://github.com/espressif/esp-idf/blob/c5865270b50529cd32353f588d8a917d89f3dba4/examples/wifi/getting_started/softAP/main/softap_example_main.c#L36) you can find two examples. -->

## Conclusion  

In this tutorial, you learned how to:  

1. Create a new project based on the `hello_world` example.  
2. Initialize the `esp_netif` library.  
3. Start the standard event loop to handle Wi-Fi events.  
4. Configure and launch a soft-AP, allowing devices to connect via Wi-Fi.  
5. Verify event handling by monitoring the terminal for connection events.  

This serves as a foundation for building more advanced Wi-Fi applications, such as MQTT clients, HTTP servers, or other networked solutions.

### Next step

> _Next Step_: Check the [basic http tutorial](/blog/2025/06/basic_http_server/)
