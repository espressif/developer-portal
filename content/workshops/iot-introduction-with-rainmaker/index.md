---
title: "IoT Introduction with RainMaker"
date: 2024-07-08
showAuthor: false
authors:
  - "pedro-minatel"
showTableOfContents: false
showAuthor: false
---

Welcome to the IoT workshop with [ESP RainMaker](https://rainmaker.espressif.com/). The ESP RainMaker was designed to empower you to build, develop, and deploy customized AIoT solutions effortlessly, ESP RainMaker ensures you can achieve your goals with minimal coding and maximum security.

Join us as we explore how ESP RainMaker can transform your AIoT projects, offering a seamless blend of innovation, security, and scalability. Whether you are looking to streamline maintenance, enhance security, or scale your operations, this workshop will equip you with the knowledge and tools to harness the full potential of ESP RainMaker.

## About this workshop

On this workshop, you will have an introduction to the ESP RainMaker with 6 assignments:

- [Assignment 1: Installing the Espressif IDE](#assignment-1-installing-the-espressif-ide)
- [Assignment 2: Installing the ESP RainMaker](#assignment-2-installing-the-esp-rainmaker)
- [Assignment 3: Building the IoT device](#assignment-3-building-the-iot-device)
- [Assignment 4: Google Home integration](#assignment-4-google-home-integration)
- [Assignment 5: Over-the-air update](#assignment-5-over-the-air-update)
- [Assignment 6: Introduction to Matter](#assignment-6-introduction-to-matter)

The practical assignments covers a range of essential skills:

- **Assignment 1**: Installing the Espressif IDE, ensuring we have the necessary tools to start development.
- **Assignment 2**: Installing the ESP RainMaker SDK and the mobile phone application to deploy and control devices.
- **Assignment 3**: Build the IoT device to be controlled locally or via the cloud integration with the mobile application.
- **Assignment 4**: Setup the Google Voice Assistant integration to control the devices via the Google Home application.
- **Assignment 5**: Use the OTA to update the device firmware remotely.
- **Assignment 6**: Brief introduction to the Matter protocol for connected home devices.

By participating in this workshop, you will gain a comprehensive understanding of the ESP RainMaker, and how to build powerful AIoT applications. We hope this knowledge will serve as a solid foundation for your future projects.

Thank you for your time and engagement in this workshop. We look forward to seeing the innovative solutions you’ll create with the ESP RainMaker.

## Prerequisites

To follow this workshop, make sure you will meet the prerequisites, as described below.

### Hardware Prerequisites

- ESP32-C6-DevKit-C or ESP32-C6-DevKit-M
- USB cable compatible with your development board

### Software Prerequisites

- Windows, Linux, or macOS computer
- [ESP-IDF v5.2](https://github.com/espressif/esp-idf/tree/release/v5.2)
- [Espressif IDE 3.0.0](https://github.com/espressif/idf-eclipse-plugin/releases/tag/v3.0.0)
- [esp-rainmaker](https://github.com/espressif/esp-rainmaker/)

### Effort

{{< alert icon="mug-hot">}}
**Estimated time: 180 min**
{{< /alert >}}

---

## RainMaker introduction

The [ESP RainMaker](https://rainmaker.espressif.com/) is a end-to-end solution, cloud based, to provide an easy to use platform for IoT devices. The backend is based on the Amazon Web Services (AWS) server-less architecture, providing flexibility and scalability.

From the device side, the open-source SDK provides easy to use APIs to build your device, like switches, lights, fans, and more. Check the project repository for more examples on how to use and develop your RainMaker based product.

### Related documents

- [esp-rainmaker](https://github.com/espressif/esp-rainmaker) GitHub repository
- [RainMaker programming guide](https://rainmaker.espressif.com/docs)
- [RainMaker documentation](https://docs.espressif.com/projects/esp-rainmaker/en/latest/esp32/index.html)



- [ESP RainMaker](https://rainmaker.espressif.com/)
- [RainMaker dashboard](https://dashboard.rainmaker.espressif.com)

You can also use the phone apps, supported on Android and iOS.

- [RainMaker Android App](https://play.google.com/store/apps/details?id=com.espressif.rainmaker)
- [RainMaker iOS App](https://apps.apple.com/us/app/esp-rainmaker/id1497491540?platform=iphone)

For the cloud, you can get access to the devices via the [RainMaker dashboard](https://dashboard.rainmaker.espressif.com), where you can:

- See all the nodes.
- Create nodes groups.
- Manage the firmware updates (OTA)
- Manage keys

With the RainMaker dashboard you can't control the devices parameters. This is only possible by the RainMaker mobile application, CLI or via the REST [APIs](https://swaggerapis.rainmaker.espressif.com/).

[Client Cloud Communication](https://rainmaker.espressif.com/docs/spec-client-cloud)


## Assignment 1: Installing the Espressif IDE

---

To get started and perform all the workshop assignments, you will need to install the [Espressif IDE](https://github.com/espressif/idf-eclipse-plugin/releases/tag/v3.0.0). This IDE will be used to create the project, flash and debug the code.

> As alternative, you can use the VSCode extension for ESP-IDF or you can do directly by the Command-Line-Interface (CLI), however, this workshop is based on the Espressif IDE and all the assignments will follow the steps using this IDE.

### Installing the ESP-IDE

This assignment will be done by the following tutorial: [Getting Started with IDEs Workshop](../../espressif-ide/).

You will need to:

- Install all the necessary drivers for Windows
- Install the Espressif IDE
- Install the ESP-IDF
- Create the first project
- Build
- Flash
- Debug

Now that you know how to use the Espressif IDE, let's get started with the ESP-IDF and create a new RainMaker project.

## Assignment 2: Installing the ESP RainMaker

After installing the Espressif IDE and the ESP-IDF, we need to clone the RainMaker repository. Right now there are no way to install it directly from the Espressif IDE.

To manually install, you will need to clone the [esp-rainmaker](https://github.com/espressif/esp-rainmaker) repository on GitHub.

**Clone the repository**

```bash
$ git clone --recursive https://github.com/espressif/esp-rainmaker.git
```

Clone this repository at the same level as the ESP-IDF. Usually `c:/esp` or at your home directory. **Avoid long paths!**

**Installing the mobile phone application**

- [Android App](https://play.google.com/store/apps/details?id=com.espressif.rainmaker)
- [iOS App](https://apps.apple.com/us/app/esp-rainmaker/id1497491540?platform=iphone)

---

## Assignment 3: Building the IoT device

---

To get started with RainMaker, we will build the application in 3 steps:

1. LED light bulb
1. Switch
1. Outlet

### LED light bulb

This device represents the LED light bulb where you can set:

- Name
- Power
- Brightness
- Color Temperature
- Hue
- Saturation
- Intensity
- Light Mode

### Switch

- Name
- Power

### Outlet

- Name
- Power

### Node

```c
esp_rmaker_config_t rainmaker_cfg = {
    .enable_time_sync = false,
};

esp_rmaker_node_t *node = esp_rmaker_node_init(&rainmaker_cfg, "ESP RainMaker Device", "Switch");
if (!node) {
    ESP_LOGE(TAG, "Could not initialise node. Aborting!!!");
    vTaskDelay(5000/portTICK_PERIOD_MS);
    abort();
}
```

### Device

### Parameters

### WiFi provisioning

### Code

```c
    /* Initialize Wi-Fi. Note that, this should be called before esp_rmaker_init()
     */
    app_wifi_init();

    /* Initialize the ESP RainMaker Agent.
     * Note that this should be called after app_wifi_init() but before app_wifi_start()
     * */
    esp_rmaker_config_t rainmaker_cfg = {
        .enable_time_sync = false,
    };
    esp_rmaker_node_t *node = esp_rmaker_node_init(&rainmaker_cfg, "ESP RainMaker Device", "Switch");
    if (!node) {
        ESP_LOGE(TAG, "Could not initialise node. Aborting!!!");
        vTaskDelay(5000/portTICK_PERIOD_MS);
        abort();
    }

    /* Create a Switch device.
     * You can optionally use the helper API esp_rmaker_switch_device_create() to
     * avoid writing code for adding the name and power parameters.
     */
    switch_device = esp_rmaker_device_create("Switch", ESP_RMAKER_DEVICE_SWITCH, NULL);

    /* Add the write callback for the device. We aren't registering any read callback yet as
     * it is for future use.
     */
    esp_rmaker_device_add_cb(switch_device, write_cb, NULL);

    /* Add the standard name parameter (type: esp.param.name), which allows setting a persistent,
     * user friendly custom name from the phone apps. All devices are recommended to have this
     * parameter.
     */
    esp_rmaker_device_add_param(switch_device, esp_rmaker_name_param_create("name", "Switch"));

    /* Add the standard power parameter (type: esp.param.power), which adds a boolean param
     * with a toggle switch ui-type.
     */
    esp_rmaker_param_t *power_param = esp_rmaker_power_param_create("power", DEFAULT_POWER);
    esp_rmaker_device_add_param(switch_device, power_param);

    /* Assign the power parameter as the primary, so that it can be controlled from the
     * home screen of the phone apps.
     */
    esp_rmaker_device_assign_primary_param(switch_device, power_param);

    /* Add this switch device to the node */
    esp_rmaker_node_add_device(node, switch_device);

    /* Start the ESP RainMaker Agent */
    esp_rmaker_start();

    /* Start Wi-Fi.
     * If the node is provisioned, it will start connection attempts,
     * else, it will start Wi-Fi provisioning. The function will return
     * after a connection has been successfully established
     */
    app_wifi_start(POP_TYPE_RANDOM);
```

### ESP Insights

The RainMaker is integrated with the [ESP Insights](https://insights.espressif.com/).

> ESP Insights allows developers to view stack back-traces and register dumps for firmware running on devices.

With Insights you can:

- **Track Metrics**: Pre-defined system metrics or record your own custom metrics.
- **Crash Backtraces**: Inspect device crashes with detailed backtraces.
- **Device Logs**: Check all kinds of logs like Errors, Warnings, Reboots, etc.

To enable the ESP Insights you need to:

1. Call `app_insights_enable`:

```c
app_insights_enable();
```

2. Set the ESP Insights enable in the `sdkconfig`

Set `Enable ESP Insights ` in `Component config` -> `ESP Insights`.

Now you will be enabled to see the device metrics in the [ESP Insights Dashboard](https://dashboard.insights.espressif.com).

## Assignment 4: Google Home integration

---

One important features for an IoT device user experience is the ecosystem integration. This is important to keep all the controls in just on place.

If you are using Google Voice Assistant or Alexa to control your devices, RainMaker offers the integration that will allows you to control and do the automations via the voice assistant application.

To configure the integration with Google Home application, follow the steps.

1. Open the **Google Home** app on your mobile phone.
1. Tap on "+" -> Set up Device.
1. Select the "Works with Google" option meant for devices already set up.
1. Search for ESP RainMaker and sign in using your RainMaker credentials.
1. Once the Account linking is successful, your RainMaker devices will show up and you can start using them.

For Alexa, please use this documentation: [Enabling Alexa](https://rainmaker.espressif.com/docs/3rd-party#enabling-alexa).

After linking your RainMaker account with the Google Home app, you will be able to see and control all devices in your RainMaker account.

## Assignment 5: Over-the-air update

---

If your device is connected, you must be able to update it remotely.

In a connected world, devices can fail and security breaches can be discovered. If you have issues with your firmware on the field, you must be able to fix and update the devices without physical intervention.

To do that, the Over-the-air (OTA) update solves this issue.

RainMaker supports OTA

## Assignment 6: Introduction to Matter

---

[ESP ZeroCode](https://zerocode.espressif.com/)

1. Create account
1. Create product
1. Flash using ESP Launchpad
1. Provision using Google Home mobile application

> In order to use the Espressif vendor for development purpose, you need to enable your Google account as developer and create the Matter device types into your account using the console.

[Google Matter](https://developers.home.google.com/matter?hl=en)
[Developer Console](https://console.home.google.com/projects)

## Feedback

If you have any feedback for this workshop, please star a new [discussion on GitHub](https://github.com/espressif/developer-portal/discussions).
