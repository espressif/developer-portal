---
title: "Alexa"
date: 2018-10-24
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - developer-portal
tags:
  - Alexa
  - IoT
  - Esp32
  - Technology

---
{{< figure
    default=true
    src="img/alexa-1.webp"
    >}}

{{< alert >}}
**Note (as of Sep 2025)**:<br>
This project is no longer actively maintained. The information in this article is provided for archival and reference purposes only, and developers are encouraged to explore Espressif’s latest solutions for voice-enabled applications.
{{< /alert >}}

Espressif’s Alexa SDK makes building Alexa-powered devices a breeze. These devices have microphones and speaker embedded within the device to provide the full Alexa experience. Alexa features like Conversation, Music Services, Alerts and Reminders are all supported within the SDK. The SDK also provides references phone apps that let you configure the device for the first time.

We support two types of Alexa built-in device SDKs:

- Using Espressif’s __Alexa Voice Services SDK__ : Ideal for building __Alexa-enabled speakers__  with support for Bluetooth A2DP Sink, A2DP Source, DLNA among other features. Amazon-certified speakers using this SDK are already launched in the market.
- Using Espressif’s SDK for __AVS for AWS IoT__ : Ideal for smart-devices with Alexa built-in capability. This SDK implements Amazon’s AVS integration for AWS-IoT. The same AWS-IoT connection is shared for voice exchange, as well as the smart device’s data exchange. This is fully Amazon-qualified and listed on their dev-kits page here: `https://developer.amazon.com/en-US/alexa/alexa-voice-service/dev-kits#smart-home-dev-kits`.

We have certified solutions with DSP-G’s DBMD5P SoC and Synaptics CNX20921 SoC. These DSPs run the Wake-word engine that captures the local “Alexa” utterance.

The SDK is available at: [https://github.com/espressif/esp-va-sdk](https://github.com/espressif/esp-va-sdk)

Some relevant articles:

- [Anatomy of a Voice-Integrated Device](/blog/anatomy-of-a-voice-integrated-device)
- [Espressif’s AVS SDK Release Announcement](/blog/espressifs-alexa-sdk-v1-0b1)
- [Espressif’s SDK for AVS integration for AWS IoT](https://www.espressif.com/en/news/ESP32-Vaquita-DSPG_and_SDK?position=0&list=AguoTi8cJOJycmcaOUTvPhV0fqCv3Z6oxZhbrasmZA4)
