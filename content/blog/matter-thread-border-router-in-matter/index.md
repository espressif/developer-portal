---
title: Matter: Thread Border Router in Matter
date: 2022-01-04
showAuthor: false
authors: 
  - shu-chen
---
[Shu Chen](https://medium.com/@chenshu?source=post_page-----240838dc4779--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Ffeb379dca2c7&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fmatter-thread-border-router-in-matter-240838dc4779&user=Shu+Chen&userId=feb379dca2c7&source=post_page-feb379dca2c7----240838dc4779---------------------post_header-----------)

--

[*Espressif Matter Series*](/matter-38ccf1d60bcd)* #5*

In the [Previous Articles](/matter-38ccf1d60bcd), we talked about Matter from several aspects. Today, let’s start with a foundational concept of Matter: __IP-based__ .

Matter defines a common application layer, using __Internet Protocol (IP)__ , that delivers interoperability among devices regardless of the underlying network protocol. At launch, Matter will run on Ethernet, Wi-Fi and Thread.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*06NbJDPSgGk-3-TKDxpmnQ.png)

Ethernet and Wi-Fi are all well known networking protocols, while Thread may be new to some people.

In a nutshell, [Thread](https://www.threadgroup.org/) is an __IPv6-based__ , __low-power, mesh__  networking protocol for Internet of things (IoT) products. It is built on IEEE-802.15.4 technology, so the Thread devices cannot communicate with the Wi-Fi or Ethernet devices directly. In the Matter topology, a special device is required to connect the sub-networks, the device is called the __Thread Border Router__  (Thread BR will be used for short).

Below is a typical Matter topology:

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*OeycxMdKmICdUOOvViswwQ.png)

The [Device-to-Device Automations](/matter-device-to-device-automations-bdbb32365350) within local network is a key feature of Matter, it works across Ethernet, Wi-Fi and Thread devices. For instance, a *Thread* Matter switch can directly control a *Wi-Fi* Matter bulb, or the other way around, without any phone-apps/cloud in the middle.

Now, let’s take a look at the Thread BR that connects Wi-Fi and Thread as an example, and investigate how it supports the (a) bi-directional connectivity and (b) service discovery used in Matter.

__Bidirectional Connectivity__ 

Thread BR is responsible for forwarding IP frames between Wi-Fi and Thread networks. Different from the Gateway/Bridge devices which need to handle the *application-level* interaction, Thread BR only focuses on the *IP layer* routing, regardless of the application payload.

There are three scopes in a Thread network for unicast addressing:

- Link-Local: used only for one-hop communication
- Mesh-Local: used for communication within the local Thread Network
- Global: used for communication with the hosts outside the local Thread Network

Thread BR configures its Thread partition with an Off-Mesh Routable (OMR) prefix, each Thread device adds an OMR address as the Global unicast address. Thread BR announces reachability of this OMR Prefix to Wi-Fi network by sending Router Advertisement (RA) which contains an IPv6 Route Information Option (RIO).

Vice versa, Thread BR should also inform Thread devices about the routing to Wi-Fi network. Rather than using the IPv6 Neighbor Discovery protocol, prefixes are advertised via Thread Network Data as external route entries.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*kFrhJ60RCk_0xUlChd36Tg.png)

Then both devices in Thread and Wi-Fi networks know about the particular IPv6 prefixes reachable via the Thread BR.

__Service Discovery__ 

In Matter, the Standard DNS-Based Service Discovery (DNS-SD) is used for Service Advertising and Discovery. On Wi-Fi and Ethernet networks, the DNS-SD uses Multicast DNS for zero-configuration operation.

But multicast and broadcast are inefficient on wireless mesh networks like Thread. Service Registry Protocol (SRP) is introduced in Thread for service discovery over unicast packets.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*XIUc0-S9yFyTZ_ccGjuSrw.png)

Normally, Thread BR acts as the SRP server and the Advertising Proxy: Thread devices register their services to Thread BR, and the BR will advertise all the services via Multicast DNS to Wi-Fi network.

The Thread Border Router also implements DNS-SD Discovery Proxy, to enable clients on the Thread network to discover services from Wi-Fi network.

__Espressif Thread Border Router Solution__ 

Espressif, as an active member that supports Matter from the beginning, we can offer the full spectrum of Matter protocol solutions for end-products with Wi-Fi or Thread connectivity, as well as for Thread Border Router and Bridge solutions using a combination of SoCs.

The Thread Border Router SDK is now available from the link: [Thread Border Router Example and SDK](https://github.com/espressif/esp-idf/tree/master/examples/openthread/ot_br). It uses two SoCs (Wi-Fi + 802.15.4) connected via a serial interface like UART or SPI.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*C0UO2eqXR77h0yvbXTKSjQ.png)

If you are interested in our Thread Border Router solution, please contact our [customer support team](https://www.espressif.com/en/contact-us/sales-questions).
