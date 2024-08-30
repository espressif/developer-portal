---
title: ESP RainMaker and Serverless
date: 2020-05-26
showAuthor: false
authors: 
  - amey-inamdar
---
[Amey Inamdar](https://medium.com/@iamey?source=post_page-----d144d8a71987--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F96a9b11b7090&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp-rainmaker-and-serverless-d144d8a71987&user=Amey+Inamdar&userId=96a9b11b7090&source=post_page-96a9b11b7090----d144d8a71987---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*YAS-IDAfh-sdpNc0ibRUjw.png)

Recently, we launched ESP RainMaker, that provides a way for developers to build devices with readymade cloud, phone apps and voice assistant support. In this context, designing and implementing an IoT cloud service was a significant part of the efforts and we wanted to ensure that it met some of the key criteria that we had laid out.

__Security__  — We gave utmost importance to security to ensure that device and the user data is secure, and unintentional access to the data is prevented. The authentication, authorization and access control were to be supported using standard security protocols.

__Time-to-market__  — It was important for us to spend time wisely on innovating on the features that we like to be part of our solution. So we were ready to use a suitable platform instead of reinventing the wheel.

__Scalability__ — Scalability was an important consideration for us to ensure that the platform was well suited for large number of devices and varied workloads from different device classes that developers will build.

__Cost__  — Given that the number of devices and their workload is varied, the choice of our architecture and our implementation will provide the service at an optimised cost structure.

In addition to these measurable key criteria, we wanted to follow an important design principle for ESP RainMaker — to be independent of the application protocol between the devices and other services by supporting __Runtime Reconfiguration Pattern__ . We wanted to ensure that the cloud architecture that we select can provide good framework for this type of design.

__Runtime Reconfiguration Pattern__ — A static device configuration in the cloud has up till now been the norm for most applications. With ESP RainMaker, devices could be dynamically updated with the latest firmware and their cloud bindings could be reconfigured. This opens the possibility to continue to evolve (a) the devices, to provide new services after they are deployed and, (b) other services, to consume the device data and interact with the devices.

Defining these criteria helped us to evaluate available architectures or paradigms and select the one that is a closest-fit for our criteria.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*3azmz99lgixtFQWfH6K1VA.png)

The first three architectures required not only building the application, but also to maintain the infrastructure at various level. While elastic containers provide some level of scalability, it too required building and maintaining a distributed system with its own nuances. That’s where the Serverless deployment stood out and it was certainly worth a consideration.

## What is Serverless?

Serverless does not mean that there is no server. It hides the management of the hardware and software infrastructure and provides usable services for the application. The application is also designed to not run on a specific server instance, but is event driven and can make use of the available services.

## __FaaS — Function As A Service__ 

In addition to managed services, the Serverless architecture offers “FaaS (Function-as-a-Service)” runtime that allows developers to write code snippets that can work on the data and interact with available services. Developers can use their familiar programming languages (such as Python, node.js and Go) with SDKs to interact with services. FaaS is also charged based on number of executions and time and memory consumption of the runtime.

The cloud infrastructure provides a “*Rule Engine*” that facilitates the orchestration of the data flow through services. The FaaS runtime can be set to trigger based on various conditions in the system. Together Rule Engine and FaaS runtime can be used to build the business logic of the application.

The typical available Serverless services that are meaningful in the context of device connectivity include an MQTT broker, SQL and no-SQL database services, a binary blob/object storage, user management service, web API gateway service, message queuing service and stream analytics service amongst the few other Serverless services.

While ESP RainMaker is based on AWS Serverless platform, most of the other leading cloud service providers including Google Cloud Platform, Microsoft Azure Cloud, Tencent Cloud and Alibaba Cloud provide Serverless platform offering that is more or less similar. ESP-RainMaker could also be deployed on these platforms.

## ESP RainMaker and Serverless — Our Experience

Let’s first evaluate how Serverless fares for the parameters that we have considered to be important.

__Security__  — The Serverless architecture provides unified user management and RBAC (role-based access control) through security policies across the services. These roles and policies can be associated with multiple services at a very fine granularity. This is very useful as when the device data enters the system, when a user operation is performed, the context flows along with data across the services ensuring appropriate permission control at each stage. Devices get to choose a strong authentication with the IoT cloud service (e.g. TLS based mutual authentication). There are also some security specific services available for common requirements such as a web API gateway firewall that would protect from typical DoS attacks. With this infrastructure, security becomes an integral part of the design of the application and not an afterthought.

__Time-to-Market__ — This is where Serverless provides a very strong advantage. The services’ availability, scalability and reliability is guaranteed and constraints are documented clearly. This provides a distributed platform to the application where the complexity of the distributed system is abstracted from the application. The Serverless application design pattern is however non-orthodox where the application is broken into individual segments responding to various system events and inter-service orchestration is a part of the application. However this, in-fact, leads to an easier to develop and maintain architecture compared to the monolithic architecture. There is no traditional dev-ops involved. This all greatly reduces time-to-market and makes the maintenance of the system easier.

__Scalability__  — With the distributed nature of the services abstracted out and the availability of configuration to improve service response, the application achieves inherent scalability upto a large extent. However it’s also worthwhile to emphasise here that use of the Serverless architecture does not by default guarantee scalability. The data and workflows have to be defined considering the known limitations of individual services.

__Cost__  — While the cost of services vary from cloud vendor to cloud vendor, the basic device connectivity, messaging service pricing is quite low in general. However here too, choice of the architecture and the services used, can impact the actual cost of cloud usage under the same workload. It requires a continuous analysis and optimisation as a part of development process. With ESP RainMaker running on AWS Serverless infrastructure, we can maintain the cost of an always-connected device with a few messages per day to be within a few cents per device per year. While there are greater savings for indirect cost (such as engineering and maintenance), even direct cost is quite attractive and linear scaling as expected beating our initial apprehension.

__Runtime Reconfiguration Pattern__  — The Serverless framework with its availability of messaging, compute and storage services provided a good platform to design ESP RainMaker to meet its Runtime Reconfiguration requirement. In the Runtime Reconfiguration requirement, the devices and other services can use the cloud as a conduit: the devices can dynamically self describe their characteristics and the services can render themselves with the available data in an efficient way.

Serverless has proven to be a great platform for us for ESP RainMaker to deliver a feature-rich yet cost-effective (just like our hardware :-) ) device cloud platform. This gives us an ample opportunity to innovate further in terms of features that will make developers’ life easy for building and maintaining connected devices.

However this is also an important learning that Serverless is not a silver bullet. The application needs to be designed carefully, security configuration needs to be well thought through and service features need to be chosen to ensure low cost of operation. Also, application development and debugging is quite different than traditional model. But still the advantages greatly outweigh the efforts.

ESP-Rainmaker is designed for Makers to reduce the complexity of connecting their devices to the web and to provide a ready-to-use phone apps, so that Makers can focus on building their devices instead of reinventing the wheel. We would love to see your devices connecting to ESP RainMaker.

Let’s Make the world better!
