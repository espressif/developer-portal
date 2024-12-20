---
title: "Data transmission reliability over ESP-NOW protocol in indoor environment"
date: 2024-12-19
showAuthor: false         # Hide default Espressif author
authors:
  - "kubascik-michal"        # List your name(s)
tags:
    - IoT
    - Wireless
    - ESP-NOW
    - ESP32-S3
    - ESP32-C6
---

## Introduction

Department of Technical Cybernetics at the Faculty of Management Science and Informatics mainly focuses embedded systems and IoT networks, implementing innovative approaches in such systems. Most applications are powered by batteries, and require low power consumption and reliable data transmission. Therefore, the new wireless protocol ESP-NOW has become interesting for implementation in IoT systems. Our testing mainly focuses on reliability of data transmission in indoor smart applications.

## Smart applications

Generally, smart application involves the interconnection of multiple sensors via wired or wireless connection. In basic concept, system consist of:
- __measurement unit__ - microcontroler, microprocessor with sensors, etc., 
- __processing unit__ - high performance microcontroler, single-board computer, cloud system, etc., 
- __actuator unit__ - for example heating, cooling, watering, etc. 

By the most common smart appliances include smart lightning, smart plugs, siol moisture monitoring, machine status monitoring or search and rescue systems.

### Communication protocols 

Communication protocols could be divided to two classes:
- __Wired Protocols:__ Mostly used between microcontrolers, microprocessors and sensors. Most common are UART, IIC, SPI, and in industrial appliances CAN. 
- __Wireless Protocols:__ Commonly used between sensor nodes, or nodes and processing unit, cloud. Mostly used are Wi-Fi, Zigbee, Bluetooth or Bluetooth Low Energy, Matter, Thread or ESP-NOW. For data transmission over longer distances are implemented LoRa or GSM technologies. 

## ESP-NOW vs. Wi-Fi

Both ESP-NOW and Wi-Fi are radio-frequency communication protocols. There are several points to mention, in case of wireless protocol chose.

With Wi-Fi connection, ESP32-based device is able to communicate with various types of devices and systems in network. In case of speed, Wi-Fi can work up to 70Mbps, and Wi-Fi range is up to 30 meters. On the other hand, power consumption of Wi-Fi based device is relatively high.

Using ESP-NOW, we can achieve much lower power consumption (aprox. 100mA while device is transmiting). ESP-NOW range is much higher - up to 200 meters with low packet loss. Data transmit speed is lower - up to 250kbps. Also, by implementing ESP-NOW, communication is limited to modules by Espressif Systems.

ESP-NOW is therefore designed mainly for low power devices, IoT, and not for huge data transfer.

## Concept of data transmission and evaluation

By the motivation of research has been evaluation of range and packet loss of data transmission over time and according to placement and environment. 

Our network concept consist of 8 sensor nodes based on ESP32 simulating sensor data, and central node - based on ESP32-S3 and ESP32-C6 combination. Block scheme is on following figure.
{{< figure
    default=true
    src="img/conceptNodes.webp"
  >}}

Architecture of network is shown on following figure.
{{< figure
    default=true
    src="img/sensorNodes.webp"
    >}}
Sensor nodes 1-8 are sending packets to central node over ESP-NOW. This device is recieving packets, and through UART sending to transmitter, connected to network over Wi-Fi. Data are consequently sent to Thingspeak.


### Methods

Evaluation of packets received for period of time, with stable frequency of sending. Relative reliability is calculated as ratio of received packets to expected number packets. Relative packet loss is calculated as ratio of non-received packets to expected number packets.

Data were sent to CU with period 250ms = 4 packets per second. Number of received packets is calculated for 30 seconds = 120 packets are expected with 0% packet loss.

### Placement

8 sensor nodes has been developed and placed over department. Each node has been sending packets to central unit. Description of placement is described on following picture.
{{< figure
    default=true
    src="img/department.webp"
    >}}

### Results
As an result, we can see following comparison of multiple nodes. On following picture is success rate shown of nodes 1-4 and 5-8.

{{< figure
    default=true
    src="img/nodes14.webp"
    >}}

{{< figure
    default=true
    src="img/nodes58.webp"
    >}}

Best success rate is defined as the lowest packet loss. It has been achieved between central unit and nodes 1,2,4,6. 

{{< figure
    default=true
    src="img/best.webp"
    >}}

## Conclusion and recommendations

By our measurements we assume that 50% of nodes are reliable, and packet loss highly depends on structure of the building – number and structure of the walls between devices, percentage of open space. Future research will include analysis of signal over multiple floors. Furthermore, we need find place with lowest packet loss and changing power of signal on nodes to reduce power consumption of nodes.

As a recommendation for new large smart indoor application based on ESP-NOW protocol, we suggest to divide building to segments with highest percentage of open space, and usage of multiple central units. Also, developers should implement sophisticated software control of packet delivery and solve the issue of non-delivery status.

## More informations

Article has been released on DevCon 2024 - [*see more.*](https://www.youtube.com/watch?v=DatH-QUB0ho&list=PLOzvoM7_KnrdtDvNgN6b-GQ-kLppmNxab&index=27&ab_channel=EspressifSystems)
