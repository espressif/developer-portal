---
title: OTA Firmware Updates with ESP Privilege Separation
date: 2023-01-29
showAuthor: false
authors: 
  - sachin-parekh
---
[Sachin Parekh](https://medium.com/@sachin.parekh?source=post_page-----3b676b49459--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Ffbf6b7e86d64&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fota-firmware-updates-with-esp-privilege-separation-3b676b49459&user=Sachin+Parekh&userId=fbf6b7e86d64&source=post_page-fbf6b7e86d64----3b676b49459---------------------post_header-----------)

--

Over-The-Air (OTA) firmware update is one of the most important feature of any connected device. It enables the developers to ship out new features and bug fixes by remotely updating the application. In ESP Privilege Separation, there are two applications — protected_app and user_app for which the framework provides the ability to independently update both the application binaries. In this post we will describe the independent OTA update feature under ESP Privilege Separation.

## OTA update workflow under ESP-IDF

Over the Air updates in ESP-IDF uses two partition system to achieve fail-safe firmware updates.

We have already covered it in detail in one of our previous blog posts: [OTA update frameworks](/ota-updates-framework-ab5438e30c12)

## OTA update workflow under ESP Privilege Separation

The ESP Privilege Separation framework extends the ESP-IDF OTA mechanism for protected_app and user_app. The partition table is augmented to enable independent updates of protected_app and user_app.

```
# ESP Privilege Separation Partition table
# Name,   Type, SubType, Offset,  Size , Flags
nvs,      data, nvs,           , 0x6000,
phy_init, data, phy,           , 0x1000,
otadata,  data, ota,           , 0x2000,
uotadata, data, user_ota,      , 0x2000,
ota_0,    app,  ota_0,         , 1500K,
ota_1,    app,  ota_1,         , 1500K,
user_0,   app,  user_0,        , 256K,
user_1,   app,  user_1,        , 256K,
```

- otadata partition is responsible for selection of active firmware for the protected app. otadata partition is of size 4KiB.
- uotadata partition is responsible for selection of active firmware for the user app. uotadata partition is of size 4KiB.
- Partitions ota_0 and ota_1 denote active and passive partitions for the protected app. These partitions are of size 1500KiB as the protected app binary has bulk of the code.
- Partitions user_0 and user_1 denote active and passive partitions for the user app. These partitions are of size 256KiB as the user app is a lightweight application containing business logic.

## User App OTA Update Workflow

As the OTA feature is critical to the functioning of the device, the entire OTA functionality is a part of the protected application which protects it from any unintended usage. This also makes the development of user app easier as it does not have to deal with the OTA updates.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*Rhf2tM4JSod20jHcDAOvpw.png)

- User app initiates an OTA update by sending a URL, which contains the latest user app firmware, to the protected app.
- Protected app does sanity tests on received URL and schedules a job to perform OTA update in background and returns to user app.
- The job downloads firmware image in passive user partition, updates uotadata entries for the user app and reboots the device.

The framework also supports secure OTA where the authenticity of the user application is also verified by verifying the signature of the user application.

## User App Boot-Up Flow

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*t6ta4TQwI3utvfUBsNKbCA.png)

- ESP Privilege Separation boot-up flow is slightly different from the traditional ESP-IDF boot-up flow. The second stage bootloader boots the protected app and the protected app is responsible for booting the user app.
- The protected app refers the uotadatapartition to select the active user partition.
- The protected app also has a option, which if enabled, verifies the signature of the user application before booting user_app
- Protected app also has provision to rollback user application in case of unexpected behaviour of newly updated user app.

## Highlights

- The OTA functionality is entirely handled by the protected application and user application need not worry about its implementation.
- Both, protected_app and user_app can be updated independently allowing different release timelines.
- Protected application has provision for secure OTA which ensures that only trusted user application can be executed on the device.
- It also has a fail-safe option of “Application rollback” in case the user application is incorrectly downloaded or shows unexpected behavior during bootup.

User OTA example is available in the [__ESP Privilege Separation Repository__ ](https://github.com/espressif/esp-privilege-separation/tree/master/examples/esp_user_ota). Please give it a try and feel free to report any issues or feedback by raising an issue tracker on the GitHub repository.

Here’s a video demonstrating a real world use case of user app OTA update using ESP Rainmaker and ESP Privilege Separation.
