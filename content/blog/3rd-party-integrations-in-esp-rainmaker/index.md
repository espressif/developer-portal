---
title: "3rd Party Integrations in ESP RainMaker"
date: 2020-06-30
showAuthor: false
featureAsset: "img/featured/featured-rainmaker.webp"
authors:
  - piyush-shah
tags:
  - Espressif
  - Rainmaker
  - Alexa
  - Google Home
---
{{< figure
    default=true
    src="img/rd-1.webp"
    >}}

IoT, in general, has come a long away. During the very early stage, there was browser based control and monitoring, which, though more convenient than non-IoT devices, had a very narrow market. With the advent of Smartphones, IoT devices became much more easier to use and mass adoption became a possibility. However, the real push was given by the advent of various eco-systems and Voice assistants like Siri, Alexa and Google Assistant. Controlling by just asking verbally is much more natural than opening some app in a smartphone and tapping buttons.

With this in mind, we now have added 3rd party integrations, particularly Alexa and Google Voice Assistant (GVA) support in ESP RainMaker!

## How does this work?

If you are already familiar with ESP RainMaker, you may know that it has the concepts of [devices](https://docs.rainmaker.espressif.com/docs/product_overview/concepts/terminologies#devices) and [parameters](https://docs.rainmaker.espressif.com/docs/product_overview/concepts/terminologies#parameters). The devices and parameters have an optional “type” field. We have defined our own standard types for some common smart home devices like switches, lightbulbs, fans, etc. You can find information about the standard types [here](https://rainmaker.espressif.com/docs/standard-types.html). We have now created a layer which maps these parameters to formats that are understood by Alexa and GVA. So a device type in RainMaker (like light, switch, etc.) maps to a similar device type there, and their parameters like power, brightness, hue, saturation, intensity. etc. get mapped to the corresponding capabilities/traits. If you have just the power and brightness params, you get a simple brightness controllable light. If you include hue, saturation and intensity, you get a color light in Alexa and GVA.

## Usage

The code required to implement the standard devices is very simple. Let us look at a colour light example (led_light) which is already available on [GitHub](https://github.com/espressif/esp-rainmaker/tree/master/examples/led_light). The relevant code snippet below is self explanatory.

```c
/* Create a standard lightbulb (internally adds name and power as mandatory parameters */
esp_rmaker_create_lightbulb_device("Light", common_callback, NULL, DEFAULT_POWER);
/* Add the standard brightness parameter */
esp_rmaker_device_add_brightness_param("Light", "brightness", DEFAULT_BRIGHTNESS);
/* Add the standard hue parameter */
esp_rmaker_device_add_hue_param("Light", "hue", DEFAULT_HUE);
/* Add the standard saturation parameter */
esp_rmaker_device_add_saturation_param("Light", "saturation", DEFAULT_SATURATION);
```

The [switch example on GitHub](https://github.com/espressif/esp-rainmaker/tree/master/examples/switch) is also ready out of the box for Alexa/GVA.

Once you build and flash the Lightbulb/Switch example, provision your board and link to your account using the [ESP RainMaker Phone apps](https://docs.rainmaker.espressif.com/docs/product_overview/technical_overview/components#reference-phone-app). Give the device some friendly name so that it is easy to identify.

## Enabling Alexa

- Open the Alexa app on your phone, go to Skills and Games in the menu and search for ESP RainMaker.

{{< figure
    default=true
    src="img/rd-2.webp"
    >}}

- Select the skill, tap on “Enable to Use” and provide your RainMaker credentials.
- Once the account linking is successful, allow Alexa to discover your devices.
- Once the devices are successfully discovered, the setup is complete and you can start controlling them using Alexa.

## Enabling Google Voice Assistant (GVA)

- Open the Google Home app on your phone.
- Tap on “+” -> Set up Device.
- Select the “Works with Google” option meant for devices already set up.
- Search for ESP RainMaker and sign in using your RainMaker credentials.
- Once the Account linking is successful, your RainMaker devices will show up and you can start using them.

{{< figure
    default=true
    src="img/rd-3.webp"
    >}}

- Some users may not see the list like above, but the devices should show up in the device list in the Google Home app.

So, go ahead and start linking your RainMaker devices to your favourite voice assistants. Currently, only switch and light are supported. Let us know what you would like us to add next by dropping a message either on the [forum](https://esp32.com/viewforum.php?f=41) or [GitHub](https://github.com/espressif/esp-rainmaker/issues).
