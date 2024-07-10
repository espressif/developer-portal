---
title: "Newest Espressif-IDE"
date: 2024-07-10T10:18:17+08:00
showAuthor: false
authors:
  - "zikalino"
tags: ["ESP32", "ESP-IDF", "Espressif-IDE"]
---

## 0. General Notes

It seems that Espressif-IDE version 3.0 user interface is simplified in comparison to previous versions, which is good. However, after playing for a while I feel a strong need to read documentation and try to find out if I am missing something or doing something wrong.

I was able to find everything what I was looking for, however sometimes options seem to be hidden, for instance I could access **Component Manager** and other tools related to my current project by right clicking selected project in the workspace and displaying context menu. I am still not sure whether these options are somehow available in any simpler way (perhaps inexperienced user may not figure out they should right click on the project name to display more options?).

I couldn't find any options under **Project** menu or there's no icon in the toolbar to launch additional project options.


## 1. Installation

I have been playing with the newest version of Espressif IDE. It's probably the best way to get started with ESP-IDF, especially for beginners.

The installer encapsulates entire installation process including:

- IDE itself - of course!
- Latest version of ESP-IDF
- All the necessary tools
- All necessary drivers

Theoretically nothing could go wrong, and probably won't go wrong for somebody who never installed ESP-IDF on their system before.

Unfortunately for me the new setup interfered with some remaining bits of previous installation of Espressif-IDE / ESP-IDF. I had to figure it out and manually add ESP-IDF that was previously installed by the installer.

## 2. Managing ESP-IDF Installations

This is something I had to use immediately to fix the issues I had with previous installations.
Fortunately **ESP-IDF Manager** works well, and I was able to add existing ESP-IDF (the same that was installed by the setup) here, what fixed all my problems.

There are some minor issues that could be mentioned and fixed in upcoming versions, for instance:

- **Add ESP-IDF** button suggest that it can be used to add (existing?) ESP-IDF, it would be nice to have separate button **Add** and **Install**.
- **Reload** button is a bit mysterious, it's hard to understand what it actually means

![ESP-IDF Manager](./img/esp-idf-manager.png "ESP-IDF Manager")



## 3. Creating a New Project

## 4. Playing with Components

Newest version of Espressif-IDE comes with new component manager implementation.
It's much better than before.
The first thing I noticed is that it emulates the functionality available via browser - every component is displayed as a tile.

Component Manager can be started by right-clicking on your project, then selecting **ESP-IDF** and **Install New Component**. I couldn't find any other way of launching component manager view.

![Component Manager](./img/component-manager.png "ESP-IDF Manager")

Component Manager works pretty well however there are a few glitches that will hopefully be fixed in future versions:

- After installing the component the tile is not refreshed and **Install** button is still visible. Of course trying to install the component again ends with failure.
- There's no way to uninstall components, instead there's grayed button **Already Installed**
- Compoent descriptions seem to be editable. Of course editing these has no effect on anything and the changes are not preserved.
- There's no search button
- Components are not displayed in any order, so in order to find any component I had to scroll through a few screens until I was able to locate one that I wanted
- I am not really sure what I am browsing, is it local cache of components, or are they coming from online location? Local copy of the registry seems to be placed in **Espressif** folder.
- There's no way to see whether currently installed version is the same as newest version. Perhaps there should be some kind of update functionality, or version selector?
- Scrolling doesn't work very well. It works when using scrollbar, but when using double-touch scroll and touchpad it only works in specific areas of the entire view.

Overall from user perspective it would be nice to see what components are currently installed. I believe for a fraction of the second I saw **managed_components** folder in the tree view on the left side, but it disappeared later after I installed one more component. 

## 5. GitHub source code

Source code for this project can be found in the following address:

https://github.com/raffarost/espresso


## 7. Contact info

| | |
| --- | --- |
| Author | Zim Kalinowski |
| Date   | June 2024 |
| email  | zim.kalinowski@zoho.com |


## 8. References

- [x] [XXX](https://xxx.xxx)
