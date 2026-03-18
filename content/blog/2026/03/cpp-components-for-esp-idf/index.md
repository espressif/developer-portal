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
summary: "This article presents two C++ ESP32 components: Wifi Manager for seamless network connection and Deep Sleep for power-saving operation both easily integrated using provided code examples. It also lists additional ESP-IDF components to streamline development."
---

## Introduction
For beginners it is not easy to establish a minimal working environment for the ESP32 SoCs with e.g. Wi-Fi, buttons, LEDs and waking up from Deep Sleep. Unfortunately such a minimal environment is necessary to get things done. In this article, we will use these C++ components:
* one for Wi-Fi management to connect the ESP SoC with the local Wi-Fi network
* one for Deep Sleep operation.

First we describe how C++ components are structured using the examples of the Wi-Fi manager component `wifi_manager` and the Deep Sleep component `deep_sleep`.

Then we guide you how to use these C++ components in your ESP program - step by step. 

## Structure of C++ Components

C++ components use C++ classes to encapsulate the complexity of the component. The component user only has to know how to create an instance of the class and how to use the available methods.   

## 1. Wi-Fi Manager as a C++ Component
This C++ component is available on the ESP Component Registry at 
[elrebo-de/wifi_manager](https://components.espressif.com/components/elrebo-de/wifi_manager).
### Purpose
The easiest method to connect an ESP32 chip with the local network (LAN) is to establish a Wi-Fi connection. With this component there is no need to give the Wi-Fi credentials (SSID and password) in configuration parameters, because it starts a Wi-Fi access point with a login page. This allows to choose the SSID from a list of Wi-Fi networks and enter the password. Then a connection to the given Wi-Fi network is established. The SSID and the password only have to be entered once, because they are stored in non-volatile flash storage, from where they are retrieved on subsequent startups.

### Interface
Because the complexity of the implementation is hidden inside the C++ class, the public interface is small and easy to use.
```C++
class Wifi {
public:
    // Constructor
	Wifi( std::string tag,          // tag for ESP_LOGx
          std::string ssid_prefix,  // AP mode SSID prefix
          std::string language      // Web UI language
	    );
	virtual ~Wifi();

    void RestartStation();

    std::string GetSsid() const;
    std::string GetIpAddress() const;
    int GetRssi() const;
    int GetChannel() const;
    std::string GetMacAddress() const;

    bool IsConnected() const;
```
### Functionality
#### Create an Instance of Class Wifi
To use this component you only have to create an instance of class Wifi in the beginning of your program, everything else is done inside the class.
```C++
    /* Initialize WifiManager class */
    ESP_LOGI(tag, "WifiManager");
    Wifi wifi(
		std::string("WifiManager"), // tag
		std::string("ESP32"), // ssid_prefix
		std::string("de-DE") // language
    );
```
#### Call Method `IsConnected()`
A call to the public method `isConnected()` will only return, when the Wi-Fi network is connected.
```C++
    ESP_LOGI(tag, "Wifi is %s", wifi.IsConnected() ? "connected" : "not connected");
```
So, what happens "under the hood"?

When the method `IsConnected()` is called for the first time, there are no credentials for the Wi-Fi network available on the ESP chip and the ESP starts a Wi-Fi access point.

![Wi-Fi access point](./img/wifi-aps.webp)

That's in german, which depends on your computer's language settings. Here you can see the Wi-Fi access point of the ESP system named "ESP32-6A51". The prefix "ESP32" depends on the parameter `ssid_prefix` in the constructor of class `Wifi` (see above).

When you connect to this Wi-Fi access point you see a web page where you can enter the Wi-Fi credentials (SSID and password).

![Wi-Fi credentials](./img/enter-credentials.webp)

That's in german too, which depends on the parameter `language` in the constructor of class Wifi (see above).

After entering the credentials they are stored in the non volatile flash storage, the Wi-Fi network is connected and the method `IsConnected()`returns `true`.

And when the method `IsConnected()` is called for the second time, then the credentials are already present in the non volatile flash storage, they are used for connecting to the Wi-Fi network and method `IsConnected()`returns `true` without any user interaction and the Wi-Fi network is connected. 

#### Request Connection Information
When the network is connected, you can request the technical information with the methods `GetSsid()`, `GetIpAddress()`, `GetRssi()`, `GetChannel()` and `GetMacAddress()`.
```C++
    ESP_LOGI(tag, "Ssid: %s", wifi.GetSsid().c_str());
    ESP_LOGI(tag, "IpAddress: %s", wifi.GetIpAddress().c_str());
    ESP_LOGI(tag, "Rssi: %i", wifi.GetRssi());
    ESP_LOGI(tag, "Channel: %i", wifi.GetChannel());
    ESP_LOGI(tag, "MacAddress: %s", wifi.GetMacAddress().c_str());
```

## 2. Deep Sleep as a C++ Component
This C++ component is available on the ESP Component Registry at
[elrebo-de/deep_sleep      ](https://components.espressif.com/components/elrebo-de/deep_sleep).
### Purpose
Sometimes you want to enter Deep Sleep mode after your SoC has done its work. Wake up could be triggered by different events. This component allows to go to Deep Sleep and to wake up after a certain time or when a button is pressed. The boot count is incremented with every boot process.
### Interface
Because the complexity of the implementation is hidden inside the C++ class, the public interface is small and easy to use.
```C++
class DeepSleep {
public:
    // Constructor
	DeepSleep( std::string tag,
	           int *bootCount
	         );
	virtual ~DeepSleep();

	esp_sleep_wakeup_cause_t GetWakeupReason();

    esp_err_t EnableTimerWakeup( unsigned long sleepTime,
                            std::string sleepTimeUnit // {"min", "sec", "milliSec", "microSec"}
                          );
    esp_err_t EnableGpioWakeup( gpio_num_t gpio,
                           int level  // level: 1 = High, 0 = Low
                          );
	esp_err_t GoToDeepSleep();

```
### Functionality
#### Create an Instance of Class DeepSleep
To use this component you have to create an instance of class DeepSleep and to define variable `bootCount` as an RTC_DATA_ATTR in the beginning of your program.
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
```
Because the variable `bootCount` is declared as an RTC_DATA_ATTR its value is remembered after Deep Sleep. 
#### Find out the Wakeup Reason
You can also find out, what the wakeup reason was by calling `GetWakeupReason()`.
```C++
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
```
#### Configure the Wakeup Sources
Once your application has completed its tasks, configure the desired wake up source, either a timer or a GPIO button or both. This is done with methods `EnableTimerWakeup` and `EnableGpioWakeup`.
```C++
    ESP_LOGI(tag, "EnableTimerWakeup");
    ESP_ERROR_CHECK(deepSleep.EnableTimerWakeup(30, "sec"));  // enable wake up after 30 seconds sleep time

    ESP_LOGI(tag, "EnableGpioWakeup");
        ESP_ERROR_CHECK(deepSleep.EnableGpioWakeup((gpio_num_t) 39, 0));  // enable wake up when GPIO 39 is pulled down
```
Here the program will wake up from Deep Sleep after 30 seconds or when the button on GPIO 39 is pulled down.
#### Go to Deep Sleep
Finally you send the ESP chip to Deep Sleep with method `GoToDeepSleep()`.
```C++
    bool rc = false;
    ESP_LOGI(tag, "GoToDeepSleep");
    rc = deepSleep.GoToDeepSleep(); // go to deep sleep
    
    // this statement will not be reached, if GoToDeepSleep is working
    ESP_LOGI(tag, "GoToDeepSleep rc=%u", rc);
```
## Step by Step Guide
Let us start with an empty ESP program, then we add the WiFi functionality and finally the Deep Sleep functionality.

### Step 1: Create an empty ESP Program
### Step 2: Add component Wi-Fi Manager
### Step 3: Include `wifi_manager.hpp`
### Step 4: Define class `Wifi`
### Step 5: Wait until Wi-Fi is connected
### Step 6: Retrieve connection information
### Step 7: Add component Dleep Sleep
### Step 8: Include `deep_sleep.hpp`
### Step 9: Define variable `bootCount` and class `DeepSleep`
### Step 10: Find out the Wakeup Reason
### Step 11: Configure the Wakeup Sources
### Step 12: Go to Deep Sleep
### Summary: What did we achieve


## Available Components for a Minimal Working Environment
Currently there are the following components ready to use with ESP IDF V5.5+ published on ESP Component Registry.
### wifi_manager
[elrebo-de/wifi_manager      ](https://components.espressif.com/components/elrebo-de/wifi_manager) – to set up a Wifi connection
### deep_sleep
[elrebo-de/deep_sleep        ](https://components.espressif.com/components/elrebo-de/deep_sleep) – to go to deep sleep
### generic_button
[elrebo-de/generic_button    ](https://components.espressif.com/components/elrebo-de/generic_button) – to use push buttons
### onboard_led
[elrebo-de/onboard_led       ](https://components.espressif.com/components/elrebo-de/onboard_led) – to use the onboard LED
### time_sync
[elrebo-de/time_sync         ](https://components.espressif.com/components/elrebo-de/time_sync) – to synchronize time with an SNTP source
### i2c_master
[elrebo-de/i2c_master        ](https://components.espressif.com/components/elrebo-de/i2c_master) – to use an I2C bus
### generic_nvsflash
[elrebo-de/generic_nvsflash  ](https://components.espressif.com/components/elrebo-de/generic_nvsflash) – to store/retrieve values in non volatile flash storage
### hcsr04_sensor
[elrebo-de/hcsr04_sensor     ](https://components.espressif.com/components/elrebo-de/hcsr04_sensor) – to measure distances with an HCSR04 sensor
### shelly_plug
[elrebo-de/shelly_plug       ](https://components.espressif.com/components/elrebo-de/shelly_plug) – to use a shelly plug as a power switch
### http_config_server
[elrebo-de/http_config_server](https://components.espressif.com/components/elrebo-de/shelly_plug) – to use a web page to enter configuration parameters
