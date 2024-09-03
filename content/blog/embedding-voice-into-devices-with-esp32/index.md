---
title: Embedding Voice into Devices with ESP32
date: 2019-03-10
showAuthor: false
authors: 
  - hrishikesh-dhayagude
---
[Hrishikesh Dhayagude](https://medium.com/@dhrishi?source=post_page-----107d9211633c--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fd9449153a291&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fembedding-voice-into-devices-with-esp32-107d9211633c&user=Hrishikesh+Dhayagude&userId=d9449153a291&source=post_page-d9449153a291----107d9211633c---------------------post_header-----------)

--

ESP32 already supported being a fully functional [Alexa client](https://github.com/espressif/esp-va-sdk/blob/master/README-Alexa.md), a voice assistant.

ESP32 now also supports [Dialogflow](https://dialogflow.com/), a voice-enabled conversational interface from Google. It enables IoT users to include a natural language user interface in their devices.

The differences of Dialogflow w.r.t. voice assistants are

- a reduced complexity,
- pay as you go pricing,
- custom wake words, instead of having to use ‘Okay Google’ or ‘Alexa’
- and no certification hassles, because hey, you aren’t integrating with Alexa or Google Assistant; you are building one of your own

Unlike voice-assistants, Dialogflow let’s you configure every step of the conversation, and it won’t answer other trivia/questions like voice-assistants typically do. For example, a Dialogflow agent for a Laundry project will provide information only about the configurable parameters of the laundry (like state, temperature, wash cycle etc.)

This is now a part of Espressif’s Voice Assistant SDK and is available on github here: [https://github.com/espressif/esp-va-sdk](https://github.com/espressif/esp-va-sdk/blob/master/README-Dialogflow.md). To get started, see [this](https://github.com/espressif/esp-va-sdk/blob/master/README-Dialogflow.md).

The underlying technologies used by the Dialogflow implementation for VA SDK includes:

- gRPC
- Google Protobufs
- HTTP 2.0

You can see a demo video of Dialogflow on ESP32 LyraT below:

Note that the current Dialogflow SDK does not yet include support for creating custom wake words. Conversations initiated with a tap-to-talk button are supported.
