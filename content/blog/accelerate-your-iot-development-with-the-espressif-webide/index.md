---
title: "Accelerate Your IoT Development with the Espressif WebIDE"
date: 2023-04-17
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - brian-ignacio
tags:
  - Espressif
  - Eclipse Theia
  - Docker
  - Esp32
  - Ide

---
{{< figure
    default=true
    src="img/accelerate-1.webp"
    >}}

The [__Espressif Web IDE__ ](https://github.com/espressif/idf-web-ide) is an implementation of the [__Eclipse Theia__ ](https://theia-ide.org) framework with the [ESP-IDF extension for Visual Studio Code](https://github.com/espressif/vscode-esp-idf-extension) and few additional tools. You can see it in action in the Espressif DevCon22 presentation below.

{{< youtube cXgCjGslvoI >}}

If you haven’t used Eclipse Theia before, it is an open-source framework to develop Cloud & Desktop IDEs and tools in TypeScript with a Visual Studio Code UI and Visual Studio Code extensions support or extensions implemented in the [OpenVSX registry](https://open-vsx.org/).

Most of the features of [ESP-IDF extension for Visual Studio Code](https://github.com/espressif/vscode-esp-idf-extension) are also available for the Espressif Web IDE. Specific commands are the chip serial port connection. For that we have implemented two additional tools:

On the Web IDE side, there a couple commands implemented for each tool:

For __ESP-IWIDC__ , click the menu *Remote* and then *Remote Flash* or *Remote Monitor*. For esptool-js, click the the menu *Remote* and then *Flash with Webserial* or *Monitor with Webserial*. You will need to select the serial device before the flashing or monitor starts.

You can use the Espressif Web IDE in 2 ways, running directly from source code compilation or using the attached Dockerfile to build a docker container.

```shell
git clone https://github.com/espressif/idf-web-ide.git
cd idf-web-ide
yarn
cd browser-app
yarn run start — port=8080
```

Open __127.0.0.1:8080__  in your browser (Use Chrome for best experience).

2. To run using Docker do:

Pull the [latest docker image](https://hub.docker.com/r/espbignacio/idf-web-ide) using

```shell
docker pull espbignacio/idf-web-ide
```

or build the docker image from the IDF-Web-IDE repository with:

```shell
docker build . — tag espressif/idf-web-ide — platform linux/amd64
```

Run the container with:

```shell
docker run -d -e IWI_PORT=8080 -p 8080:8080 --platform linux/amd64 -v ${PWD}:/home/projects espressif/idf-web-ide
```

Open __127.0.0.1:8080__  in your browser (Use Chrome for best experience).

If you want to use the [ESP-IWIDC](https://github.com/espressif/iwidc/) you can get a built executable from Windows [here](https://github.com/espressif/iwidc/releases) or use the Python script from the repository.

Run the executable to start the ESP-IWIDC:

```shell
.\dist\main.exe — port PORT
```

and to see available ports.

```shell
.\dist\main.exe
```

If you are using the ESP-IWIDC python script directly, make sure to install required python packages with:

```shell
pip3 install -r ${ESP-IWIDC}/requirements.txt
python3 main.py
python3 main.py - port [SERIAL_PORT_OF_ESP_32]
```

For the esptool-js commands you don’t need to install anything.

The advantage of using the docker container is that you have a ESP-IDF ready docker container, the ESP32 QEMU fork and you don’t need to configure ESP-IDF for the IDE. Just open any ESP-IDF project and start coding!

The Espressif Web IDE uses the [Clang OpenVSX plugin](https://open-vsx.org/extension/llvm-vs-code-extensions/vscode-clangd) to provide C/C++ language support. This plugin uses the __build/compile_commands.json__  file to provide *Go to declaration* and other language features.

## Conclusion

Give the [Espressif Web IDE](https://github.com/espressif/idf-web-ide) a try and let us know what can we add or improve here! You can also look at our previous post about the [ESP-IDF extension for Visual Studio Code](/blog/whats-new-in-the-esp-idf-extension-for-vscode).

## Related links:

- [ESP-IDF Web IDE](https://github.com/espressif/idf-web-ide)
- [Eclipse Theia](https://theia-ide.org/)
- [ESP-IDF extension for Visual Studio Code](https://github.com/espressif/vscode-esp-idf-extension)
- [Espressif IDF Web Desktop Companion (ESP-IWIDC)](https://github.com/espressif/iwidc/)
- [esptool-js](https://github.com/espressif/esptool-js)
- [OpenVSX registry](https://open-vsx.org/)
- [Clang OpenVSX plugin](https://open-vsx.org/extension/llvm-vs-code-extensions/vscode-clangd)
