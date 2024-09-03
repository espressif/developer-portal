---
title: Alexa
date: 2018-10-24
showAuthor: false
authors: 
  - esp-bot
---
[ESP BOT](https://medium.com/@espbot?source=post_page-----74d432975be6--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F71611a95e5c4&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Falexa-74d432975be6&user=ESP+BOT&userId=71611a95e5c4&source=post_page-71611a95e5c4----74d432975be6---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*UNdnK-SaGsW1UCFi68zNAQ.png)

Espressif’s Alexa SDK makes building Alexa-powered devices a breeze. These devices have microphones and speaker embedded within the device to provide the full Alexa experience. Alexa features like Conversation, Music Services, Alerts and Reminders are all supported within the SDK. The SDK also provides references phone apps that let you configure the device for the first time.

We support two types of Alexa built-in device SDKs:

- Using Espressif’s __Alexa Voice Services SDK__ : Ideal for building __Alexa-enabled speakers__  with support for Bluetooth A2DP Sink, A2DP Source, DLNA among other features. Amazon-certified speakers using this SDK are already launched in the market.
- Using Espressif’s SDK for __AVS for AWS IoT__ : Ideal for smart-devices with Alexa built-in capability. This SDK implements Amazon’s AVS integration for AWS-IoT. The same AWS-IoT connection is shared for voice exchange, as well as the smart device’s data exchange. This is fully Amazon-qualified and listed on their dev-kits page here: [https://developer.amazon.com/en-US/alexa/alexa-voice-service/dev-kits#smart-home-dev-kits](https://developer.amazon.com/en-US/alexa/alexa-voice-service/dev-kits#smart-home-dev-kits).

We have certified solutions with DSP-G’s DBMD5P SoC and Synaptics CNX20921 SoC. These DSPs run the Wake-word engine that captures the local “Alexa” utterance.

The SDK is available at: [https://github.com/espressif/esp-va-sdk](https://github.com/espressif/esp-va-sdk)

Some relevant articles:

- [Anatomy of a Voice-Integrated Device](https://medium.com/the-esp-journal/anatomy-of-a-voice-controlled-device-e48703e0ec20)
- [Espressif’s AVS SDK Release Announcement](https://medium.com/the-esp-journal/espressifs-alexa-sdk-v1-0b1-326f13c862f6)
- [Espressif’s SDK for AVS integration for AWS IoT](https://www.espressif.com/en/news/ESP32-Vaquita-DSPG_and_SDK?position=0&list=AguoTi8cJOJycmcaOUTvPhV0fqCv3Z6oxZhbrasmZA4)
