---
title: "C++ Components for ESP-IDF"
date: 2026-03-30
tags:
  - ESP-IDF
  - beginner
  - C++
  - components
showAuthor: false
featureAsset: "featured-cpp-components.webp"
authors:
    - "christoph-oberle"
summary: "This article presents two C++ ESP32 components: Wifi Manager for seamless network connection and Deep Sleep for power-saving operation, both easily integrated using provided code examples. It also lists additional ESP-IDF components to streamline development."
---
For beginners it is not easy to establish a minimal working environment for the ESP32 SoCs with e.g. Wifi, buttons, LEDs and waking up from Deep Sleep. Unfortunately such a minimal environment is necessary to get things done. In this article, we will [...] in order to [...] etc
## Components for the Minimal Working Environment: Two Examples

### 1. Wifi Manager Component

The easiest method to connect an ESP32 chip with the local network (LAN) is to establish a Wi-Fi connection. With this component there is no need to give the Wi-Fi credentials (SSID and password) in configuration parameters, because it starts a Wi-Fi access point with a login page. This allows to choose the SSID from a list of Wi-Fi networks and enter the password. Then a connection to the given Wi-Fi network is established. The SSID and the password only have to be entered once, because they are stored in non-volatile flash storage, from where they are retrieved on subsequent startups.

To use this component you only have to create an instance of class Wifi in the beginning of your program, everything else is done inside the class.

This code snippet shows how you can connect to a Wifi network: 

```C++
    /* Initialize WifiManager class */
    ESP_LOGI(tag, "WifiManager");
    Wifi wifi(
		std::string("WifiManager"), // tag
		std::string("ESP32"), // ssid_prefix
		std::string("de-DE") // language
    );

    ESP_LOGI(tag, "Wifi is %s", wifi.IsConnected() ? "connected" : "not connected");

    ESP_LOGI(tag, "Ssid: %s", wifi.GetSsid().c_str());
    ESP_LOGI(tag, "IpAddress: %s", wifi.GetIpAddress().c_str());
    ESP_LOGI(tag, "Rssi: %i", wifi.GetRssi());
    ESP_LOGI(tag, "Channel: %i", wifi.GetChannel());
    ESP_LOGI(tag, "MacAddress: %s", wifi.GetMacAddress().c_str());
```

### 2. Deep Sleep Component

Sometimes you want to enter Deep Sleep mode after your SoC has done its work. Wake up could be triggered by different events. This component allows to go to Deep Sleep and to wake up after a certain time or when a button is pressed. The boot count is incremented with every boot process.

To use this component you have to create an instance of class DeepSleep and to define variable bootCount as an RTC_DATA_ATTR in the beginning of your program.

After your program has done its duty, you have to enable timer wake up and/or a GPIO button wake up and go to Deep Sleep. 

```C++
#include "deep_sleep.hpp"
RTC_DATA_ATTR int bootCount = 0;

extern "C" void app_main(void)
{
    /* Initialize DeepSleep class */
    ESP_LOGI(tag, "DeepSleep");
    DeepSleep deepSleep(
		std::string("DeepSleep"), // tag
		&bootCount // Address of int bootCount in RTC_DATA
    );

    ESP_LOGI(tag, "GetWakeupReason");
    esp_sleep_wakeup_cause_t wakeupReason = deepSleep.GetWakeupReason();

    switch(wakeupReason) {
        case ESP_SLEEP_WAKEUP_EXT0 : ESP_LOGI(tag, "Wakeup caused by external signal using RTC_IO"); break;
        case ESP_SLEEP_WAKEUP_EXT1 : ESP_LOGI(tag, "Wakeup caused by external signal using RTC_CNTL"); break;
        case ESP_SLEEP_WAKEUP_TIMER : ESP_LOGI(tag, "Wakeup caused by timer"); break;
        case ESP_SLEEP_WAKEUP_TOUCHPAD : ESP_LOGI(tag, "Wakeup caused by touchpad"); break;
        case ESP_SLEEP_WAKEUP_ULP : ESP_LOGI(tag, "Wakeup caused by ULP program"); break;
        case ESP_SLEEP_WAKEUP_GPIO : ESP_LOGI(tag, "Wakeup caused by gpio"); break;
        default : ESP_LOGI(tag, "Wakeup was not caused by deep sleep: %d",wakeupReason); break;
    }

    //***************************
    // Put your program code here 
    //***************************

    ESP_LOGI(tag, "EnableTimerWakeup");
    ESP_ERROR_CHECK(deepSleep.EnableTimerWakeup(30, "sec"));  // enable wake up after 30 seconds sleep time

    ESP_LOGI(tag, "EnableGpioWakeup");
        ESP_ERROR_CHECK(deepSleep.EnableGpioWakeup((gpio_num_t) 39, 0));  // enable wake up when GPIO 39 is pulled down

    bool rc = false;
    ESP_LOGI(tag, "GoToDeepSleep");
    rc = deepSleep.GoToDeepSleep(); // go to deep sleep
    
    // this statement will not be reached, if GoToDeepSleep is working
    ESP_LOGI(tag, "GoToDeepSleep rc=%u", rc);
}
```

## Using a Component in a Program

### Define the Component as a Dependency for Your Project in idf_component.yml

All the components for the minimal working environment are published in the ESP Component Registry.

To use a component you have to define the component as a dependency for your project. This can be done with the IDF command add-dependency. 

For the component wifi_manager, the command is:
```bash
idf.py add-dependency "elrebo-de/wifi_manager^1.4.1"
```
For the component deep_sleep, the command is:
```bash
idf.py add-dependency "elrebo-de/deep_sleep^1.2.1"
```
Executing this command adds the dependency to the dependencies section of idf-component.yml.

### Create a C++ Main Program and Include the Header File of the Component
Because the components are C++ classes the calling program must also be a C++ program. There you can include the header files of the needed components. In C++ main programs (`main.cpp`) the function app_main must be specified with `extern "C"`, so that it has C linkage.

This is the beginning of a main.cpp file which is used in the example of the deep_sleep component. 
For the deep_sleep component the header file deep_sleep.hpp is included, the int variable bootCount is defined in RTC_DATA storage and an instance of class DeepSleep is defined:
```C++
/*
 * Example program to use deep_sleep functionality with elrebo-de/deep_sleep
 */

#include <string>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "deep_sleep.hpp"
RTC_DATA_ATTR int bootCount = 0;

#include "esp_log.h"
#include "sdkconfig.h"

static const char *tag = "deep sleep test";

extern "C" void app_main(void)
{
    // short delay to reconnect logging
    vTaskDelay(pdMS_TO_TICKS(5000)); // delay 0.5 seconds

    ESP_LOGI(tag, "Example Program");

    /* Initialize DeepSleep class */
    ESP_LOGI(tag, "DeepSleep");
    DeepSleep deepSleep(
		std::string("DeepSleep"), // tag
		&bootCount // Address of int bootCount in RTC_DATA
    );

```

## Available Components for a Minimal Working Environment
Currently there are the following components ready to use with ESP IDF V5.5+ published on ESP Component Registry.
### wifi_manager
[elrebo-de/wifi_manager    ](https://components.espressif.com/components/elrebo-de/wifi_manager) – to set up a Wifi connection
### deep_sleep
[elrebo-de/deep_sleep      ](https://components.espressif.com/components/elrebo-de/deep_sleep) – to go to deep sleep
### deep_sleep
[elrebo-de/generic_button  ](https://components.espressif.com/components/elrebo-de/generic_button) – to use push buttons
### onboard_led
[elrebo-de/onboard_led     ](https://components.espressif.com/components/elrebo-de/onboard_led) – to use the onboard LED
### time_sync
[elrebo-de/time_sync       ](https://components.espressif.com/components/elrebo-de/time_sync) – to synchronize time with an SNTP source
### i2c_master
[elrebo-de/i2c_master      ](https://components.espressif.com/components/elrebo-de/i2c_master) – to use an I2C bus
### generic_nvsflash
[elrebo-de/generic_nvsflash](https://components.espressif.com/components/elrebo-de/generic_nvsflash) – to store/retrieve values in non volatile flash storage
### hcsr04_sensor
[elrebo-de/hcsr04_sensor   ](https://components.espressif.com/components/elrebo-de/hcsr04_sensor) – to measure distances with an HCSR04 sensor
### shelly_plug
[elrebo-de/shelly_plug     ](https://components.espressif.com/components/elrebo-de/shelly_plug) – to use a shelly plug as a power switch
