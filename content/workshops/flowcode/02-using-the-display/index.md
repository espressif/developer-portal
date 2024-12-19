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
time.

{{< figure
    default=true
    src="../assets/2-0-candy.webp"
    >}}

First set up the panel in Flowcode as above:
PWM channel connected to PortA.9 (GPIO9)
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

If you need more information then you can left
click on the display and click on HELP to get
more information from the Flowcode Wiki.

{{< figure
    default=true
    src="../assets/2-3-display-properties-1.webp"
    >}}


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

You can also set up the Bitmap drawer. This
will need the central graphic copying to the
same directory as the Flowcode file so that it
simulates properly.

{{< figure
    default=true
    src="../assets/2-7-bitmap-drawer-properties.webp"
    >}}


{{< figure
    default=true
    src="../assets/2-8-first-flowchart.webp"
    >}}

The flowchart you can see above will produce the screen you can see below.

{{< figure
    default=true
    src="../assets/2-9-first-sim.webp"
    >}}


{{< figure
    default=true
    src="../assets/2-10-constants.webp"
    >}}

## Over to you

Now that you understand the basics of how to control
the graphics and text you can complete the design of the first
screen using the specification:

Download the program to the M5 stack dial and check is all works ok!
Note that if you want to you can also create your program in C code or in Pseudocode:

{{< figure
    default=true
    src="../assets/2-11-pseudocode.webp"
    >}}

Open the program ‘Using the display.fcfx’ and
download it to your M5 stack Dial.

- Use Flowcode to create the Home screen you can
see here.

- Make sure you include the light purple cross hatch - you may want to make a separate macro to print
those.

{{< figure
    default=true
    src="../assets/2-12-c-code.webp"
    >}}

- You will need to have the bitmap ‘M5Stack Lock
Test Purple.bmp’ in the same directory as the
Flowcode program.

## Video and example file

{{< youtube A0fKmmufJRk >}}

A Flowcode example file accompanies this tutorial:
- [2 - Using the display.fcfx](https://www.flowcode.co.uk/wiki/images/b/b7/2_-_Using_the_display.fcfx)


Further reading: [Flowcode Wiki](https://www.flowcode.co.uk/wiki/index.php?title=Examples_and_Tutorials
).

## Next step

[Assignment 3: Switch and I/O Pins](../03-switch-io-pins)
