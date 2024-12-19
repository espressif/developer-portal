---
title: "Flowcode - M5 Stack Dial Workshop - 1. Planning"
date: 2024-12-09
series: ["FL001"]
series_order: 1
showAuthor: false
---
Ok - let’s be honest. Planning is a bit of a pain. Its boring. Its
not the fun part of the job. At the start of a project we are
itching to get on with the coding, the graphics and get
something working.

But if you don’t plan then there can be all sorts of pain later:
you end up redoing work, falling out with colleagues and
customers, and it’s a lot less fun later on in the project.

In part 1 we show you how we plan the project.

### Specification

We are going to show you how to make an electronic door lock
based on the M5stack dial with the following features:
- Based on M5 stack dial
- Code entry access using bezel and switch
- Maglock door opener – 24VDC @10A
- Graphical display
- Remote unlock with mobile phone
- Weather information on mobile phone and locally

{{< figure
    default=true
    src="../assets/hardware.webp"
    >}}

Actually what we really want to do is teach you how to create a project based on the M5 stack dial. We have come up with the specification above so that we can teach you about the following:

- [Assignment 1: Planning](../01-planning)
- [Assignment 2: Using the Display](../02-using-the-display)
- [Assignment 3: Switch and I/O Pins](../03-switch-io-pins)
- [Assignment 4: The Bezel Encoder](../04-the-bezel-encoder)
- [Assignment 5: I2C Expansion](../05-i2c-expansion)
- [Assignment 6: Menu System](../06-menu-system)
- [Assignment 7: Connecting to the web](../07-connecting-to-the-web)
- [Assignment 8: Full Project](../08-full-project)

### Graphic designer’s brief

Usually we need a graphic designer in a project like this. They just have a knack of making stuff look right. In this case we gave the designer a brief of creating an image that allowed us to teach how to display text, vector graphics, and bitmap graphics in an Electronic safe/door lockproject. This is what he came up with:
Fantastic.

{{< figure
    default=true
    src="../assets/m5stack-test-screen-01.webp"
    >}}

From this we get a create colour scheme and a theme for our project.
What we need to do next is analyse this and turn it into information that we can use. The easiest way to do that is to redraw it. We are going to have to do that anyway to plan our menus.

After doing that we get this:

{{< figure
    default=true
    src="../assets/home.webp"
    >}}

As you can see we have taken the opportunity to draw a pixel grid on the diagram and we now understand the colours text sizes and position of all the graphical and text elements.

We also need to plan our menu and functionality. Once we have the main screen done this easily falls out of the design and we get the following screens:

When the user presses the bezel from the home screen they
can enter a combination. This graphic defines the elements
on that screen.

{{< figure
    default=true
    src="../assets/combo.webp"
    >}}

If the code is incorrect then this screen tells them they have the
wrong combination. They can ring a mobile number and the
door can be unlocked by someone with the mobile phone app.

{{< figure
    default=true
    src="../assets/noentry.webp"
    >}}


If they are successful then this screen is displayed. The door
unlocks and they get a summary of the weather!

{{< figure
    default=true
    src="../assets/unlocked.webp"
    >}}


So that has defined our functionality. We can then show this to colleagues and customers and be really clear about what we are doing before we start. A real time saver!

Now that we know what we are doing some other elements of the design easily come from this:

### Colours

We need to know the colours of all the items on the display. We will declare some constants in the program to save us time as well. So we have a list:

| Name | R | G | B | Constants |
|------|---|---|---|-----------|
|Purple| 64| 33| 87 |PURPLER, PURPLEG, PURPLEB|
|Light purple| 85| 47| 108| LIGHTPURPLER, LIGHTPURPLEG, LIGHTPURPLEB|
|Orange| 255| 102| 0| ORANGER, ORANGEG, ORANGEB|
|White| 255| 255| 255| WHITER, WHITEG, WHITEB|
|Red| 255| 0| 0|
|Yellow| 255| 255| 0|
|Green| 0| 255| 255|

### Graphics

We also have a rough plan for the home screen graphics:
Purple circle background
- Grid at 20 Pixel intervals
- Text Heading and subheading
- Red circles 30, 120 210, 120 22 diameter
- Orange circles 40, 170 200, 170 18 diameter
- Yellow circles 75,205 165, 205 15 diameter
- Green triangle 120, 225 – can’t do triangles so we can use some diminishing rectangles
- Bitmap is 80 x 80 pixels. Top left is 80, 80.

### Fonts
|Type|Size|Font face|Colour|Font Index|Const|
|-------|----------------|----------|-------|-------|---------|
|Heading| 15 pixels high |Arial bold| Orange| Font 0| HEADINGF|
|Subheading| 24 pixels high| Arial bold| Orange| Font 1| SUBHEADINGF|
|Instructions| 10| pixels high| Arial White| Font 2| INSTRUCTIONSF|
|Combo| 60 pixels high| Arial bold| Orange| Font 3| COMBOF|
|Digit| 35| pixels high| Arial bold| Orange| Font 4| DIGITF|

We now know roughly what fonts we are gong to use. In Flowcode every font is assigned a number so again we declare constants for the fonts as you can see in the table. That saves us from having to remember what font is what.

### Bitmaps

There is only one bitmap. Like fonts in Flowcode bitmaps are represented by numbers, but as there is only 1 - bitmap 0 - its easy enough to remember.

### Screens

| Screen| number| Constants|
|-------|-------|----------|
|Home screen| 0| HOMES|
|Code entry screen| 1| CODES|
|Enter screen| 2| ENTERS|
|Denial Screen| 3| DENIALS|

Each screen is represented by a number in the Flowcode program. We set up Global constants for these numbers so that we don’t have to remember what the numbers are.

### Connections

We can also define the connections both inside the M5 stack dial and outside. Flowcode needs the actual processor connections in order to drive the various chips and I/O inside the Dial. This is what we get when we dig into it:
Display is GC9A01A round, 240 x 240 pixel

SPI bus with the following connections:

- MOSI A5 (GPIO5)
- MISO A1 (GPIO1)
- CLK A6 (GPIO6)
- CS A7 (GPIO7)
- DC RS A4 (GPIO4)
- Reset A8 (GPIO8)
- Backlight A9 (GPIO9)
- Bezel switch B10 (GPIO5)
- Buzzer A3 (GPIO3)
- Bezel encoder
- A B9 (GPIO41)
- B B8 (GPIO40)
- I2C
- SCL A15 (GPIO15)
- SDA A13 (GPIO13)
- Relay on I/O pin A1 (GPIO1), A2 (GPIO2)

## Video

{{< youtube gjOI7aVCoqA >}}

## Over to you

Now we need to set up the hardware for the project. You can see this on the photograph. We have an M5stack Dial connected to the PC via USB.

There is a board with two relays on that are connected to the general purpose IO pins G10 and G2. That allows us to switch 24A AT 28V - should be enough for a Maglock. For prototyping purposes I have put a small solenoid on the board to simulate the Maglock function. This is powered by a 24V plug top power supply.

There is a Grove board with a SHT21 temperature and humidity sensor. This is connected to the Dial I2C pins GPIO13 and GPIO15.

Get your M5stack Dial, relay board and SHT31 board and a suitable power supply and set up your project.

You can see ours here:

{{< figure
    default=true
    src="../assets/hardware.webp"
    >}}

## Next step

[Assignment 2: Using the Display](../02-using-the-display)