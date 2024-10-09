---
title: "Introducing ESP Privilege Separation"
date: 2022-06-19
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - sachin-parekh
tags:
  - Esp32
  - IoT
  - Security
  - Embedded Systems

---
Typically, applications on microcontrollers (MCU) are developed as monolithic firmware. We have been discussing on achieving “user-kernel” separation with appropriate execution privileges, like general purpose OS, on MCUs.

The crux of this was to make the end application development easier without worrying about the underlying changes in the system, like how applications on desktop/mobile phones are developed: the underlying operating system handles the critical functionalities, and the end application can use the interface exposed by the operating system.

We started off with a PoC on ESP32 and realized that there were limitations in it, and we would require some robust hardware support that can enforce permissions at the hardware level to achieve isolation between the user and kernel application. This led us to design our own custom peripherals (described in more details in subsequent section) in ESP32-C3. With all the brainstorming and development done till now, we are excited to release a new framework called __ESP Privilege Separation__ !

## Introduction

Traditionally, any ESP-IDF application on an Espressif SoCs is built as a single monolithic firmware without any separation between the “core” components (Operating System, Networking, etc.) and the “application” or “business” logic. In the ESP Privilege Separation framework, we split the firmware image into two separate and independent binaries: protected and user application.

{{< figure
    default=true
    src="img/introducing-1.webp"
    >}}

## Highlights of ESP Privilege Separation

- Supports two isolated execution environments: Secure world and Non-secure world.
- Separation of monolithic firmware into two independent firmware: protected (secure) application and user (non-secure) application.
- Protected app is isolated from exceptions in the user app.
- Standard system call interface through which user application can request access to core services.
- Maintains consistency with ESP-IDF APIs.
- Configurable memory and peripheral access.
- Flexible memory split between protected and user application.

## Technical Details

## 1. Application bootup

{{< figure
    default=true
    src="img/introducing-2.webp"
    >}}

In ESP Privilege Separation, the bootup flow is like ESP-IDF application bootup flow, the Boot ROM (1st stage bootloader) verifies and loads the 2nd stage ESP-IDF bootloader from the flash. The 2nd stage bootloader then verifies and loads the protected application. Protected application checks for valid user application header in flash and if found, it sets appropriate permissions and tries to verify and load the user application.

## 2. World controller and Permission control

The most important piece of this framework is achieving the separation of privileges and enforcing permissions. This is achieved using World controller and Permission Controller peripherals in ESP32-C3. Permission controller manages the permissions and World controller manages execution environment, where each World has its own permission configuration. Currently, we have 2 Worlds; World0 and World1.World0 is the secure (protected) environment and World1 is the non-secure (user) environment.

{{< figure
    default=true
    src="img/introducing-3.webp"
    >}}

The above diagram shows that:

- Secure World (World0) has complete access to address range A.
- Non-secure World (World1) has read only access to address range A.

If non-secure World tries to write to any address in range A, then a violation interrupt shall be raised. Secure World handles this violation interrupt and takes appropriate actions.

## 3. Switching between Secure and Non-secure Worlds

- Switching from Secure to Non-Secure World:CPU can be switched to non-secure world by configuring the address in World controller register. When CPU tries to execute the configured address, it will transparently switch and execute in the non-secure world.
- Switching from Non-secure to Secure World:CPU can only switch from non-secure to secure world via interrupts or exceptions. Any interrupt in the system will cause the CPU to switch to secure world.

## 4. Memory Layout

With the permissions enforced, the next step is to split the memory.

Internal SRAM:

The following figure represents how the SRAM is split between protected and user application. SRAM is divided into IRAM and DRAM and this split is entirely configurable and dependent upon the usage of the application.

{{< figure
    default=true
    src="img/introducing-4.webp"
    >}}

The DRAM region contains the .data and .bss section of the respective application and the remaining DRAM region is used as heap. In this framework, there is a dedicated heap allocator for each, protected and user application.

This SRAM memory layout helps maintain memory compatibility when upgrading protected application. If in case IRAM consumption of the protected app increases or decreases, we can move the main IRAM-DRAM split line such that the user boundary is not affected.

External flash:

The following figure represents how the Flash virtual memory is split between protected and user application. Like internal memory split, flash MMU range is divided into .rodata and .text sections and is entirely configurable.

{{< figure
    default=true
    src="img/introducing-5.webp"
    >}}

## 5. System call interface

Protected application provides a standard “system call” interface through which user application can request access to core services. This uses a special CPU instruction that generates a synchronous exception that hands over the control to a protected application. The system call handler carefully checks the request and performs action accordingly. The following diagram gives an overview of how the system call interface is implemented:

{{< figure
    default=true
    src="img/introducing-6.webp"
    >}}

## 6. API consistency

We have maintained ESP-IDF API consistency, for most of the components, across protected and user app. Components which are exposed to user application through system call interface must use the system call implementation instead of the actual function implementation. We leverage the linker’s attributes to override the API’s definition with the system call definition.

- API consistency also ensures that ESP-IDF sample applications can easily (with minimal changes) be ported to this framework.
- Consistency with ESP-IDF API ensures the same program can be built either as a protected app or as a user app.

## 7. User space exception handling

With the permissions and the memory split in place, there can be scenarios where the user app, either intentionally or unintentionally, tries to access the forbidden region of protected environment. In this case, the permission controller raises a violation interrupt which can be handled in the protected application. The benefits of having the permissions enforced is that the protected space memory and hence the protected application is not hampered by any (mis)behavior of the user application. In the framework, we have provision for the protected application to register a handler for cases where any exception occurs in the user application. In this handler, we can gather some vital information and handle the exception accordingly.

## 8. Device drivers

The user application might need access to peripherals (SPI, I2C, etc.) to communicate with external devices and sensors. In this framework, we have implemented device drivers in protected application and exposed it to user application through standard I/O system calls (open, read, write, etc.). This allows us to implement multiple device drivers through a common set of system calls.

It is also possible to provide a peripheral’s register access to the user application and let the user application write its own driver.

## Advantages

With the ESP Privilege Separation framework, we envision various use cases and scenarios that usually cannot be achieved in the traditional monolithic approach; a few of which we have listed below:

## Getting Started

> This project is still in __beta__  phase and active development is being done. There are certain limitations and bottlenecks which are constantly being addressed. Please report any issues and bugs you may encounter.

The framework is entirely open-sourced and can be found in our [__ESP Privilege Separation repository__ ](https://github.com/espressif/esp-privilege-separation). For detailed technical documentation and walkthroughs please refer [__here__ ](https://docs.espressif.com//projects/esp-privilege-separation/en/latest/esp32c3/index.html).

Please feel free to report any issues or feedback by raising an issue tracker on the GitHub repository. We also welcome contributions to this framework through PRs.

We hope this novel approach in application development will open various avenues for you. We are eager to hear your thoughts about this.
