---
title: "OpenAI Component | Accelerating the integration of OpenAI APIs in projects"
date: 2023-07-24
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - ali-hassan-shah
tags:
  - IoT
  - Esp
  - Esp Box
  - OpenAI
  - Espressif

---
Integrating OpenAI capabilities into projects has become increasingly trends in today’s fast-paced technological landscape. [OpenAI](https://platform.openai.com/docs/api-reference) offers a wide range of powerful APIs for natural language processing. However, the process of integrating these APIs can be complex and time-consuming, often requiring substantial effort and expertise. To simplify this integration process, we introduce the [OpenAI Component](https://github.com/espressif/esp-iot-solution/tree/master/components), a powerful library that streamlines the incorporation of OpenAI APIs into projects.

{{< figure
    default=true
    src="img/openai-1.webp"
    >}}

__*In this article, we will demonstrating how it enables developers to easily add OpenAI capabilities to their projects without having to handle all the implementation tasks.*__

*This article consists of three main sections. The initial section “*__*ESP Component Registry*__ *”provides information on step involve in adding appropriate components into your ESP-IDF project. The second section focuses on providing details about the “*__*OpenAI Component”*__ *and the last section gives and update on “*__*ESP-Box*__ * *__*ChatGPT*__ * ” demo example.*

---

## ESP Component Registry

The [__ESP Component Registry__ ](https://components.espressif.com/)____ acts as a central hub for an extensive array of open-source components that can turbocharge your IoT projects. By simply performing a quick search and a few clicks, you can effortlessly obtain the desired components and seamlessly incorporate them into your IDF projects. This efficient workflow expedites your development cycle, enabling you to concentrate on creating groundbreaking IoT solutions without the burden of complex setup procedures.

{{< figure
    default=true
    src="img/openai-2.webp"
    >}}

## Steps to Follow

```shell
idf.py add-dependency "espressif/Component name^verison"
```

---

## OpenAI Component

To provide developers with comprehensive coverage of [OpenAI API](https://platform.openai.com/docs/api-reference) features, a simple yet powerful ESP-IDF [component](https://components.espressif.com/components/espressif/openai) is introduced. This component offers extensive support, focusing on a wide range of functionalities while excluding file operations and fine-tuning capabilities. There is comprehensive [documentation](https://docs.espressif.com/projects/esp-iot-solution/en/latest/ai/openai.html) accessible to assist developers in comprehending the APIs effortlessly.

## Usage Example

The first step is to instantiate an object and provide a secure “API key” as a parameter. The OpenAPI key is accessible through the [OPENAI](https://openai.com/) website. To gain access to OpenAI services, you must first create an account, purchase tokens, and obtain your unique API key.

```c
openai = OpenAICreate(key);
```

After creating the OpenAI object, the code calls the chatCompletion API. It sets the required parameters, sends a message (indicating it’s not the last message), and retrieves the generated response for further use or processing.

```c
chatCompletion = openai->chatCreate(openai);
chatCompletion->setModel(chatCompletion, "gpt-3.5-turbo");
chatCompletion->setSystem(chatCompletion, "Code geek");
chatCompletion->setMaxTokens(chatCompletion, CONFIG_MAX_TOKEN);
chatCompletion->setTemperature(chatCompletion, 0.2);
chatCompletion->setStop(chatCompletion, "\r");
chatCompletion->setPresencePenalty(chatCompletion, 0);
chatCompletion->setFrequencyPenalty(chatCompletion, 0);
chatCompletion->setUser(chatCompletion, "OpenAI-ESP32");
OpenAI_StringResponse_t *result = chatCompletion->message(chatCompletion, "Hello!, World", false); //Calling Chat completion api
char *response = result->getData(result, 0);
```

Similarly, after instantiating the OpenAI object, the code calls the audioTranscriptionCreate API. It sets the necessary parameters, such as the audio file and language, followed by initiating the audio transcription process. Finally, it retrieves the transcription result for further use or processing.

```c
audioTranscription = openai->audioTranscriptionCreate(openai);
audioTranscription->setResponseFormat(audioTranscription, OPENAI_AUDIO_RESPONSE_FORMAT_JSON);
audioTranscription->setLanguage(audioTranscription,"en");
audioTranscription->setTemperature(audioTranscription, 0.2);
char *text = audioTranscription->file(audioTranscription, (uint8_t *)audio, audio_len, OPENAI_AUDIO_INPUT_FORMAT_WAV); // Calling transcript api
```

To explore more APIs and their functionalities, please refer to the [documentation](https://docs.espressif.com/projects/espressif-esp-iot-solution/en/latest/ai/openai.html).

---

## ESP-BOX ChatGPT Demo Example

The [updated version](https://github.com/espressif/esp-box) of the ESP-BOX ChatGPT example incorporates the OpenAI component, replacing the [older version](https://github.com/espressif/esp-box/tree/0924e7bc2cad50d3d7ca4b0f91eef7da6934d5e6/examples/chatgpt_demo). Further details on the development process can be found in the [Blog](/blog/unleashing-the-power-of-openai-and-esp-box-a-guide-to-fusing-chatgpt-with-espressif-socs). Notably, in the newer version, we have implemented a secure method to store the Wi-Fi and OpenAI keys in non-volatile storage (NVS) using a [esp_tinyuf2](https://components.espressif.com/components/espressif/esp_tinyuf2?from_wecom=1) component.

During the initial boot, the first binary is executed, allowing the user to enter secure credentials such as Wi-Fi and OpenAI keys. Once the credentials are entered, the system restarts, and the ChatGPT binary takes control. This binary is responsible for running the ChatGPT functionality, utilizing the secure credentials provided during the initial boot. The workflow for this process is illustrated in the figure below, providing an overview of the overall process.

{{< figure
    default=true
    src="img/openai-3.webp"
    >}}

Additionally, users have the option to try out the newer version of the ESP-BOX ChatGPT example using the [ESP-Launchpad](https://espressif.github.io/esp-launchpad/?flashConfigURL=https%3A%2F%2Fraw.githubusercontent.com%2Fespressif%2Fesp-box%2Fmaster%2Flaunch.toml) without the need to compile the project locally on the machines. This option offers a convenient means for individuals to experience the improvements and advancements made in the implementation.
