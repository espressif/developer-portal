---
title: "Flowcode - M5 Stack Dial Workshop - 2. Using the Display"
date: 2024-12-09
series: ["FL001"]
series_order: 2
showAuthor: false
---

In this section we show you how to use the Display
component in Flowcode. Once you know the colours, fonts and
other parameters of your design, display graphics are just a
series of commands to draw the lines, graphics and text in the
right places.

One of the great features of Flowcode is that you can simulate
the graphical display on screen - this saves hours of coding
time.                                             2 0 candy.png

{{< figure
    default=true
    src="../assets/2-0-candy.webp"
    >}}

First set up the panel in Flowcode as above:
PWM channel connected to PortA.9 (GPIO XX)
This allows us to control the brightness of the display.

{{< figure
    default=true
    src="../assets/2-1-panel-set-up.webp"
    >}}

Then add the GC9A01A_SPI display. Use the images here to
get the correct settings.

{{< figure
    default=true
    src="../assets/2-2-backlight-properties.webp"
    >}}


{{< figure
    default=true
    src="../assets/2-3-display-properties-1.webp"
    >}}

If you need more information then you can left click on the
display and click on HELP to get more information from the
Flowcode Wiki.

Notice that we have not got the exact fonts that we wanted -
Flowcode does not include all fonts - although more can be
made - but the fonts that we have should be fine.

{{< figure
    default=true
    src="../assets/2-4-display-properties-2.webp"
    >}}

{{< figure
    default=true
    src="../assets/2-5-display-properties-3.webp"
    >}}

{{< figure
    default=true
    src="../assets/2-6-display-properties-4.webp"
    >}}


{{< figure
    default=true
    src="../assets/2-7-bitmap-drawer-properties.webp"
    >}}


{{< figure
    default=true
    src="../assets/2-8-first-flowchart.webp"
    >}}

{{< figure
    default=true
    src="../assets/2-9-first-sim.webp"
    >}}


{{< figure
    default=true
    src="../assets/2-10-constants.webp"
    >}}

{{< figure
    default=true
    src="../assets/2-11-pseudocode.webp"
    >}}

## Resources


A YouTube video accompanies this tutorial.


A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?title=Examples_and_Tutorials

2 - Using the display.fcfx

## Next step

[Assignment 3: Switch and I/O Pins](../03-switch-io-pins)
