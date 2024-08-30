---
title: Securely booting user application in ESP Privilege Separation
date: 2023-02-18
showAuthor: false
authors: 
  - sachin-parekh
---
[Sachin Parekh](https://medium.com/@sachin.parekh?source=post_page-----2522ace5a268--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Ffbf6b7e86d64&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fsecurely-booting-user-application-in-esp-privilege-separation-2522ace5a268&user=Sachin+Parekh&userId=fbf6b7e86d64&source=post_page-fbf6b7e86d64----2522ace5a268---------------------post_header-----------)

--

In the [previous post](https://medium.com/the-esp-journal/ota-firmware-updates-with-esp-privilege-separation-3b676b49459), we demonstrated the ability to independently update the user application in the ESP Privilege Separation framework. With the separation and isolation of the protected app and user app, it becomes convenient to decouple the ownership of each of these apps and their updates. This also potentially allows the possibility of having multiple user applications for a single protected application, somewhat like an “application store” for user app. As the functionality of these applications increases, the security of these apps becomes mandatory.

In this post, we will describe the secure boot mechanism implemented for the user application. This mechanism ensures that only the trusted and authorized user application can execute on the device.

## Secure boot

> Secure boot is a process that guarantees that only authorized and trusted code executes on the device. This is ensured by building a chain of trust starting from an entity that is trusted and cannot be changed, e.g. one-time programmable memory in hardware

A project using the ESP Privilege Separation framework has two separate application binaries — protected_app and user_app, which can have independent update cycles.

The framework supports secure boot for both of these apps. Protected app and user app binaries are verified by establishing a chain of trust with the root of trust.

## Secure boot for protected app

Secure boot for protected application follows the secure boot scheme of the traditional application in ESP-IDF.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*ChYG-9gypX_qa3z_dI4oow.png)

The overview of secure boot process is as follows:

For more details, please refer to the [Secure boot](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/security/secure-boot-v2.html) section in the ESP-IDF documentation

## Secure boot for user app

As previously mentioned, both of these apps can be developed independently so the ownership of these apps can be with different entities. This could mean that both of these apps require separate signing keys. For verifying the protected app, we burn the hash of the protected app public key in eFuse. While we can do the same for the user app public key, it is not scaleable as eFuse memory is scarce.

We have designed a certificate-based verification mechanism for user app secure boot.

## __Certificate-based verification scheme__ 

In this scheme, the protected application is considered trusted and thus the protected app will have some information embedded in its firmware that will be used to verify the authenticity of the user app.

## Requisites

Let’s look at the requisites for protected app and user app for this scheme

__Protected app:__ 

__User app:__ 

## Verification process

The verification flow of this scheme is as follows:

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*7fi-E-i0tX1XPvWiLkdikw.png)

For more details about the implementation, please refer to the [Secure boot](https://docs.espressif.com/projects/esp-privilege-separation/en/latest/esp32c3/technical-details/secure_boot.html#) section in the ESP Privilege Separation documentation.
