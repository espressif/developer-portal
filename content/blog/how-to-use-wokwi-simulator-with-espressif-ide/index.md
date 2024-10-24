---
title: "How to use Wokwi Simulator with Espressif-IDE"
date: 2023-04-16
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kondal-kolipaka
tags:
  - 2.9.0
  - Espressif Ide
  - Esp Idf
  - Wokwi
  - Espressif

---
The [Espressif IDE](https://github.com/espressif/idf-eclipse-plugin/blob/master/docs/README.md) version [2.9.0](https://github.com/espressif/idf-eclipse-plugin/releases/tag/v2.9.0) has recently been released, introducing a new feature for the Espressif community who want to use the Wokwi simulator directly from within the IDE.

__What is Wokwi?__

Wokwi is an online electronics simulator that allows users to simulate various boards, parts, and sensors, including the ESP32. With a browser-based interface, Wokwi offers a simple and intuitive way to start coding your next IoT project within seconds.

__How does the integration work between Wokwi and Espressif-IDE?__

Espressif-IDE provides a development environment for building IoT applications using [ESP-IDF](https://github.com/espressif/esp-idf) with various Espressif boards. While you can build, flash, monitor, and debug your applications within the IDE, visualizing the serial output requires an esp32-based development board. This is where the Wokwi simulator comes in.

Espressif-IDE provides a Wokwi integration plugin that allows the IDE to communicate with the [Wokwi Server](https://github.com/MabezDev/wokwi-server/) over a websocket, enabling the flashing of the .bin file of the project built in the IDE. Based on the chip target and project ID provided by the IDE, the Wokwi server launches the simulator in the system browser for the specified target. As a result, users can view the serial monitor output in the IDE console while communicating with the simulator.

{{< figure
    default=true
    src="img/how-1.webp"
    >}}

__To use the Wokwi simulator from the Espressif-IDE, you need to follow these simple steps:__

{{< figure
    default=true
    src="img/how-2.webp"
    >}}

__Conclusion__

In summary, the integration of the Wokwi simulator into Espressif-IDE provides a seamless experience for users to build and test their IoT projects without the need for a physical development board. This integration opens up new possibilities for developers looking to streamline their workflow and experiment with new ideas in a cost-effective manner.
