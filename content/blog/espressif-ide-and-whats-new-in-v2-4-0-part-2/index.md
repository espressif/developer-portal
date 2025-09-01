---
title: "Espressif IDE and What’s new in v2.4.0 — Part 2"
date: 2022-03-01
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - kondal-kolipaka
tags:
  - Espressif Ide
  - Idf Eclipse Plugin
  - Esp Idf
  - Espressif
  - Eclipse

---
This section will talk about Espressif IDE installation options that are available and platforms supported.

Espressif IDE supports Windows, macOS, and Linux platforms. Please find the download links below to get started.

[Espressif-IDE-2.4.1-win32.win32.x86_64.zip](https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-2.4.1-win32.win32.x86_64.zip)

[Espressif-IDE-2.4.1-macosx.cocoa.x86_64.tar.gz](https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-2.4.1-macosx.cocoa.x86_64.tar.gz)

[Espressif-IDE-2.4.1-linux.gtk.x86_64.tar.gz](https://dl.espressif.com/dl/idf-eclipse-plugin/ide/Espressif-IDE-2.4.1-linux.gtk.x86_64.tar.gz)

## macOS security notice

On macOS, if you download the Espressif-IDE archive with the browser, the strict security checks on recent macOS will prevent it to run, and complain that the program is damaged. That’s obviously not true, and the fix is simple, you need to remove the com.apple.quarantine extended attribute.

```
*$ xattr -d com.apple.quarantine ~/Downloads/Espressif-IDE-2.4.1-macosx.cocoa.x86_64.tar.gz*
```

After un-archiving, if the application still complains, check/remove the attribute from the Espressif-IDE.app folder too:

```
*$ xattr -dr com.apple.quarantine ~/Downloads/Espressif-IDE.app*
```

## Espressif-IDE v2.4.0 Installer (All-in-one package) for Windows OS

Espressif-IDE Installer is an offline installer and it comes with all the required components to work with the ESP-IDF Application development.

The installer deploys the following components:

- ESP-IDF v4.4
- Espressif-IDE (based on Eclipse 2021–12)
- Amazon Corretto OpenJDK 11.0.14
- Drivers — FTDI chip, WinUSB support for JTAG
- Embedded Python
- Cross-compilers
- OpenOCD
- CMake and Ninja build tools

As Installer bundles, all the required components and tools including stable esp-idf so people behind corporate firewalls can use the whole solution out-of-box. This also configures all the required build environment variables and tool paths as you launch the IDE. All you could do is to get started with your project directly without manually configuring anything. This will give you a big boost to your productivity!

The All-in-one installer option is a recommended approach if someone trying for the first time in Windows OS or has challenges in installing tools.

Espressif-IDE Installer for Windows OS is available [here](https://dl.espressif.com/dl/esp-idf/) for download. The latest version of Espressif-IDE is v2.4.1 but you get as part of the installer is v2.4.0 so one has to update to the latest using the [update site](https://docs.espressif.com/projects/espressif-ide/en/latest/marketplaceupdate.html#installing-idf-plugin-using-update-site-url)

Installation instructions are similar to what is described [here](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/windows-setup.html#esp-idf-tools-installer) for the ESP-IDF Tools installer. Always prefer *Full Installation *during the setup.

{{< figure
    default=true
    src="img/espressif-1.webp"
    >}}

Once the installation completes you could launch the Espressif-IDE from the desktop shortcut and this will pre-configure everything required to build the ESP-IDF project.

When you launch the IDE for the first time it will pop up with the Welcome page!

{{< figure
    default=true
    src="img/espressif-2.webp"
    >}}

To verify Installed tools version and product information in general, you could navigate to the *Espressif *menu and click on the *Product Information *option.

{{< figure
    default=true
    src="img/espressif-3.webp"
    >}}

Once you’re able to see all the tools, IDF_PATH, IDF_PYTHON_PATH, PATH, and other environment information correctly in the console, you are set to get started with the HelloWorld project!

Check our IDE [documentation](https://docs.espressif.com/projects/espressif-ide/en/latest/marketplaceupdate.html) page for more information!

Happy coding!
