---
title: "New Features in ESP RainMaker"
date: 2021-06-25
showAuthor: false
featureAsset: "img/featured/featured-rainmaker.webp"
authors:
  - piyush-shah
tags:
  - Rainmaker
  - Espressif
  - ESP32
---
[ESP RainMaker](https://rainmaker.espressif.com/) has been around for more than a year now and we have been adding quite some features to it every few months. Here we are now, with some more new features.

## Node Sharing

ESP RainMaker allows a user to control a node remotely over the Internet. However, there is often a need to allow others to use the same node. It could be something like giving control of lightbulbs to members of your family, or temporarily giving access to a door lock to your tenant or a maid, or something like a shared hardware resource being accessed remotely by multiple employees. To serve such use cases, ESP RainMaker offers an ability of sharing a node with others.

To share a node, go to the parameters control page by tapping the device tile on the home page, click on the (i) on top right and then scroll own to the bottom where you can find an option to Add a new member. Note that you can add only those users who have already signed up for RainMaker. The user who shares the node is called the primary user for the node, whereas all the other users added are called secondary users.

{{< figure
    default=true
    src="img/new-1.webp"
    >}}

The secondary user with whom the node was shared can open the phone app, and under the User profile page, go to “Sharing Requests”. It will show all the sharing requests received, which can then be accepted or declined. Soon, we will provide push notifications to alert users that someone has shared RainMaker nodes with them.

{{< figure
    default=true
    src="img/new-2.webp"
    >}}

Once the sharing is accepted, the secondary user can control and monitor the node, in the same way as the primary user. However, he/she cannot share it further. For more information, check out the [ESP RainMaker docs](https://rainmaker.espressif.com/docs/node-sharing/).

## Timezone Setting

ESP RainMaker already had support for Timezones on the device side. The various ways in which this could be used can be found [ESP RainMaker docs](http://docs.rainmaker.espressif.com/docs/product_overview/features/time-service). However, the support on phone app side was missing, making it a bit hard to set timezone on the devices at run time. The latest phone apps now have an option to set this on the Node details page. Moreover, to prevent cases wherein people may forget to set the timezone explicitly from the Node details page, we have also added this in the “Adding device” workflow. So, after provisioning and user-node association is done, the phone app automatically sets the device timezone to match the phone’s timezone.

## Arduino Support

Even though we have taken quite some efforts to make developer on-boarding easy, by ways of the [ESP IDF Windows Installer](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/windows-setup.html#esp-idf-tools-installer) and the Eclipse and VSCode plug-ins, we do understand that a lot of makers/hobbyists would still prefer Arduino due to its simplicity and cross platform support. That’s why we have now added the ESP RainMaker support in Arduino. Check out [ESP RainMaker now in Arduino post](/blog/esp-rainmaker-now-in-arduino) for more information.

## Node Grouping

As people start using more and more Smart devices, it often gets hard to view and manage them from the phone apps. To make that simpler, we have added a concept of Node grouping. You can create logical or abstract groups of your nodes using the RainMaker app. For some users, the groups can be based on rooms; for others, they could be based on device types. The choice is yours. Group management is available directly on the homepage as you can see in this screenshot.

{{< figure
    default=true
    src="img/new-3.webp"
    >}}

Even though the phone apps have only single level groups, the RainMaker backend supports even sub groups. You can check out the Grouping APIs at [Swagger](https://swaggerapis.rainmaker.espressif.com/#/Device%20grouping) if you are interested.

Apart from these features, we have made quite some visual and convenience related improvements. Download our latest apps from [RainMake docs](https://docs.rainmaker.espressif.com/docs/product_overview/technical_overview/components#reference-phone-app) and check these out for yourself. You can give your feedback either on [GitHub](https://github.com/espressif/esp-rainmaker/issues) or the [forums](https://www.esp32.com/viewforum.php?f=41&sid=98f7b3da06f71d135fc2161792ffa5d0).
