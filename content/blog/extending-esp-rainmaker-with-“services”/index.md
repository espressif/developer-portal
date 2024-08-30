---
title: Extending ESP RainMaker with “Services”
date: 2022-01-12
showAuthor: false
authors: 
  - piyush-shah
---
[Piyush Shah](https://medium.com/@shahpiyushv?source=post_page-----9ccb82dfb9b7--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F57464183000e&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fextending-esp-rainmaker-with-services-9ccb82dfb9b7&user=Piyush+Shah&userId=57464183000e&source=post_page-57464183000e----9ccb82dfb9b7---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*nEkL1xmWZBaPe8WqlESV6Q.png)

[*If you have been following the Espressif blogs and announcements, you must already be aware of ESP RainMaker and its various features. If not, please check out the info *[*here*](https://rainmaker.espressif.com/)* so that you get an idea about what ESP RainMaker is before you proceed further*.]

One important aspect of RainMaker is that the cloud is very thin and acts as a tunnel between the ESP nodes and clients like mobile phones, Alexa, GVA, etc. This makes it very flexible and extensible allowing users to create any type of device with any kind of functionality and access it from the phone apps. There are some defaults that we have defined, but they are not mandatory to use and you can create your own device/param types.

The functionality that a RainMaker node supports is communicated by the node using something called as the [node configuration](https://rainmaker.espressif.com/docs/node-cloud-comm.html#node-configuration). This, broadly has 2 parts.

Most RainMaker users are now well versed with the concept of devices since they are very much visible in the examples. However, the concept of “services” may not be clear because it is hidden under the APIs like __esp_rmaker_system_service_enable(), esp_rmaker_schedule_enable()__ or __esp_rmaker_timezone_service_enable()__ and used internally by the phone apps.

Structurally, a service is very similar to a device. It has a “name” and “type” and a set of parameters. That’s one reason why all device specific APIs are applicable even to services. This applies not just to the firmware APIs, but even to the cloud APIs. The same [GET /user/nodes?node_details=true](https://swaggerapis.rainmaker.espressif.com/#/User%20Node%20Association/getUserNodes), [GET /user/nodes/config](https://swaggerapis.rainmaker.espressif.com/#/User%20Node%20Association/getUserNodeConfiguration) and [GET/PUT /user/nodes/params](https://swaggerapis.rainmaker.espressif.com/#/Node%20Parameter%20Operations) APIs that are used for devices are applicable for services.

You can find some standard services [here](https://github.com/espressif/esp-rainmaker/blob/master/components/esp_rainmaker/src/standard_types/esp_rmaker_standard_services.c), but the purpose of this post is to help understand how to add your own custom service.

## Defining the Use Case

Naturally, before you even write a service, you need to define your use case, which will then help you define the parameters of the service. Let’s consider a use case of “Diagnostics” wherein you want the users to trigger some diagnostics on the node and get the diagnostic data in the phone app.

## Creating the service

The code snippet below is the minimal code required to create a service. It basically has 4 components

If the overall number of values in diagnostic data is small, it would be ok to define separate integer/bool/float/string parameters for each (“Timestamp” in above example). But if the data is going to be large, it is recommended to use an “object” type (“Data” in above example) and then pass whatever JSON object you want.

> Note that none of these parameters are mandatory and are shown just for reference.

The above service will show up in the node configuration as this object under the services array:

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*1ynig-iVzwHALoRlWK7OEg.png)

Similarly, the following will show up in the node parameters object

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*coTlABKakZVciNBhLCGGQg.png)

## Handling Service callbacks

As you can see in the code snippet above, we have registered diag_write_cb as the service write callback. Let us see a sample implementation of this.

The above code snippet should be self explanatory because of the comments.

As you can see, 4 different values of 4 different types could be reported via a single parameter, which is better than having 4 different parameters, which would bloat up the node configuration. Note that the JSON Generator library usage is shown just for reference as it is used at most places in ESP RainMaker. You can choose any other libraries or functions to create the object.

## Testing the Service

Before you add some logic in your phone apps to use the service, it would be better to test it first from the [RainMaker CLI](https://rainmaker.espressif.com/docs/cli-setup.html). Once you have the CLI set-up, you can use a command like this to start the diagnostics:

```
$ ./rainmaker.py setparams --data '{"Diagnostics":{"Trigger":true}}' <node_id>
```

Once the device gets this command, the device serial console will show up such prints

```
I (74726) esp_rmaker_param: Received params: {"Diagnostics": {"Trigger": true}}I (74726) app_main: Received write request via : CloudI (74726) app_main: Starting DiagnosticsI (74736) esp_rmaker_param: Reporting params: {"Diagnostics":{"Data":{"diag1":true,"diag2":30,"diag3":54.16430,"diag4":"diag"}}}I (74746) esp_rmaker_param: Reporting params: {"Diagnostics":{"Timestamp":1639738352}}
```

You can then query the node parameters to see the results using:

```
$ ./rainmaker.py getparams <node_id>
```

It will show up this object:

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*DxxnjM1bCTFYf872fhHz7A.png)

As you can see here, we could add a new custom functionality in RainMaker without changing/configuring anything in the cloud backend. That’s how the “tunnelling” concept of RainMaker works, making it very extensible.

A few samples for RainMaker services can be found here:

- [OTA Using Params](https://github.com/espressif/esp-rainmaker/blob/master/components/esp_rainmaker/src/ota/esp_rmaker_ota_using_params.c)
- [System Service](https://github.com/espressif/esp-rainmaker/blob/master/components/esp_rainmaker/src/core/esp_rmaker_system_service.c)
- [Time Service](https://github.com/espressif/esp-rainmaker/blob/master/components/esp_rainmaker/src/core/esp_rmaker_time_service.c)
- [Schedules](https://github.com/espressif/esp-rainmaker/blob/master/components/esp_rainmaker/src/core/esp_rmaker_schedule.c)
