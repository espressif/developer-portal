---
title: "Making the Fancy User Interface on ESP Has Never Been Easier!"
date: 2022-09-11
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - vilem-zavodny
tags:
  - LVGL
  - Squareline
  - ESP32
  - Embedded
  - User Interface
---
If you tried to make some fancy UI without any graphic library, you know, how hard it is. Fortunately, there are lot of graphical libraries for making fancy UI on our screens. One of the often used is [LVGL](http://lvgl.io), which is supported on ESP microcontrollers. Usually, when we wanted to use graphical library like [LVGL](http://lvgl.io), we had to know API functions and how to combine it to reach fancy UI. It isn’t true anymore!

There is a tool called [SquareLine Studio](https://squareline.io/), which can help making better and fancy UI without any other knowledge of the [LVGL API](https://docs.lvgl.io/master/index.html).

## SquareLine Studio

The [SquareLine Studio](https://squareline.io/) is a visual multiplatform (Mac OS, Windows and Linux) tool for creating beautiful graphical user interface with [LVGL](http://lvgl.io) graphical library. You can use drag-and-drop for adding and moving widgets on the screen. Working with images or fonts is very simple too.

After launching the SquareLine Studio and creating a new project (or open example project), there is main editor view (Figure 1). In the middle of the screen is one or more screens in the size of the output LCD display. On the left side is a list of widgets added on the screen in well-arranged __hierarchy__ . Under the hierarchy is list of __available widgets__  but there aren’t all of widgets from LVGL, only most of them. On the right side are three tabs. The important is __Inspector__ and very helpful can be __Font manager__  too. Inspector is changing for each selected widget on the screen and allows make appearance changing of the widget. There is __Events__ part too, where can be added an event for selected widget. There are lot of events for selection from click to gestures. Font manager can make LVGL font from any TTF font file and there can be selected only some characters for spare the memory. On the bottom of the application, there are two tabs, __Assets__ for all media files in the project and __Console__ , where is the whole history of info, warning and error messages.

{{< figure
    default=true
    src="img/making-1.webp"
    >}}

The play button on top right corner on the main screen enables simulator - all widgets actions and animations. You can try there, how yours UI will be react.

For create the code files, there is __Export__ in the top menu and __Export UI Files__ .

SquareLine studio version 1.1 introduce new feature — __board templates__ . There are pre-prepared boards from some companies, so you can generate complete project with the UI code for selected hardware. This complete project can be created by __Export->Create Template Project__  and then __Export->Export UI Files__  (UI files must be exported again after any change).

## ESP Boards in SquareLine Studio

Espressif has prepared two boards in SquareLine Studio for you: [__ESP-BOX__ ](https://github.com/espressif/esp-bsp/tree/master/bsp/esp-box) and [__ESP-WROVER-KIT__ ](https://github.com/espressif/esp-bsp/tree/master/bsp/esp_wrover_kit). You can select the board after launch the application in Create tab and then in Espressif tab (Figure 2). Each board has pre-filled size of screen, rotation and color depth, which is corresponding with [ESP-BSP](https://github.com/espressif/esp-bsp) which is used in generated code.

{{< figure
    default=true
    src="img/making-2.webp"
    >}}

When you select the board, you can see empty screen on the main view of the application. This empty screen has same size like the display on the selected board. Now, you can drag-and-drop some widgets, put the texts and set events. For example something like in the figure 3.

{{< figure
    default=true
    src="img/making-3.webp"
    >}}

After creating the template files (Export->Create Template Project) and exporting UI files (Export->Export UI Files), you can compile and flash the project by following the same steps, as you are used to with another Espressif’s examples (if you are using ESP-IDF). On the ESP-BOX it will look like in the figure 4.

{{< figure
    default=true
    src="img/making-4.webp"
    >}}

## Is SquareLine Studio for free?

This tool is __free for personal use with some limitations__ . The free use is limited by 5 screens only and 50 widgets for one project. Other pricing plans can be found on [SquareLine website](https://squareline.io/pricing/licenses).

## Conclusion

In my opinion, that’s really helpful tool for making fancy user interfaces on your displays and after the board templates added, it is really easy to use. Sometimes, it can be helpful only for edit some UI or it helps with position of the new widgets. It is very fast for use and easy.

Unfortunately, there is still missing some minor things, which can make this tool better. For example, I am missing some widgets like tabview or copy style to another widget. The compile and flash the Espressif’s microcontrollers would be nice too.

Indeed it is a new tool and we can hope, that some of these things will be added in next updates.
