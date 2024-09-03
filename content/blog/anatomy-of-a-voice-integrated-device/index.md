---
title: Anatomy of a Voice-Integrated Device
date: 2018-08-12
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----e48703e0ec20--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fanatomy-of-a-voice-controlled-device-e48703e0ec20&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----e48703e0ec20---------------------post_header-----------)

--

Recently I have seen significant interest from OEMs in embedding voice assistants, like Alexa, directly into their products. Not just linking with a voice-assistant using a cloud to cloud integration, but by having the product itself be voice-enabled (with microphones and speakers).

For example, a washing machine with a voice interface for starting it, or a smart switch with “Echo” embedded into it.

Let us have a quick look at the internal components of a typical Voice-Integrated device. We will take Alexa as an example for this post.

## The Record Path

When we typically say “__Alexa__ , what is the time”, the word “Alexa” is detected locally, while the rest of the sentence “what is the time” is detected in the cloud (in this case by the Alexa Voice Service). The keyword Alexa in this case is called a __Wake-Word__ .

The typical journey of the record path is as shown below:

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*WUJ5BoIynnBDwz5x-ZvWDQ.png)

The sounds that the device hears using the microphone are typically processed to perform noise and echo cancellation first.

Then a wake-word engine processes the sound to detect if a wake-word was spoken. The wake-word engine is typically trained with a sample-set of data with the particular accents that the end-users will utter. When the wake-word engine detects the wake-word it notifies the Alexa client to start processing.

The Alexa client now knows that the user has uttered the wake-word, and may be now asking a query. The client then starts capturing the audio stream and sends it up to the cloud.

The cloud interprets the user’s command and then instructs the device to stop recording and take the action that the user requested.

## Mapping to Hardware

So how do the above components map to typical hardware components? Let’s quickly check below:

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*kRMuLorQuwE45hH8AlUYPQ.png)

A combination of connectivity processors and digital signal processors can be used to achieve this.

As in the diagram above the simplest case is all the components are running on the same host that offers connectivity too. For example, ESP32 can be used to run the algorithms for noise cancellation, the wake-word engine and also the Alexa client to transmit data over Wi-Fi. Since it is a single chip solution this will be the lowest cost solution for the job at hand.

Then there are options of offloading the echo cancellation/beam-forming or wake-word engine to a dedicated DSP. This combination can be used to optimise for use cases where far-field interactions need to be supported, or where a wake-word needs to be detected while also playing music (barge-in). A DSP could also offer the capacity to load a wake-word engine with a much larger wake-word sample set.

Depending upon the use-case at hand, the appropriate selection can be made for supporting it in the most effective manner.

## The Playback Path

In most cases, the playback path is fairly simple.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*lhBzdsuTtvXWhwwAH_ySqA.png)

In its simplest form, the playback path consists of the ESP32, acting as a client, fetching the encoded audio data (MP3, AAC etc), decoding it and forwarding the samples to a DAC which then drives a speaker.

In case hardware options with DSP are used, the playback stream may also have to be provided to the DSP for performing acoustic echo cancellation. Depending upon the DSP, it can drive the DAC by itself, or the data needs to be duplicated (in hardware or software) for the DSP.

We are looking at voice-controlled devices in 2 major ways: a) those with voice assistants (like Alexa) that are running on the ESP32, and b) those with conversational interfaces (like Amazon-Lex or Google DialogFlow). Stay tuned for an upcoming post on these approaches.

If you are intereted in building Voice-Controlled Devices with ESP32, we would love to hear about it. Please reach out to sales@espressif.com with the subject line “Voice-Controlled Devices”.
