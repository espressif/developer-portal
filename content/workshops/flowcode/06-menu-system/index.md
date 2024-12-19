---
title: "Flowcode - M5 Stack Dial Workshop - 6. Menu System"
date: 2024-12-09
series: ["FL001"]
series_order: 6
showAuthor: false
---

{{< figure
    default=true
    src="../assets/6-1-allscreens.webp"
    >}}

In this section we look at how you can create a menu system
using Flowcode. To make coding easier we have a separate
macro subroutine for each menu. One key issue here is that
you need to make sure that you close each subroutine when
navigating between screens. using a variable flag to control
navigation. It’s a slightly odd structure but easy enough to
create.

In Flowcode each screen is a separate mini subroutine
program or ‘macro’ with an endless While loop. The navigation
is controlled by two variables OldScreen and NewScreen. A
screen navigation change is carried out by altering the
NewScreen variable which is examined in the While loop every
cycle. This structure might be a little unfamiliar to some
engineers, but it is actually really flexible and it allows us to
prevent while loops from not being closed - and hence the
microcontroller subroutine stack clean - good coding practice.

At the core of this is a Switch or Case statement in the Main
macro. This is driven by numbers so we declare some global
constants representing the screens as follows:


| Screen| number| Constants|
|-------|-------|----------|
|Home screen| 0| HOMESCREEN|
|Code entry screen| 1| CODESCREEN|
|Enter screen| 2| ENTERSCREEN|
|Denial Screen| 3| DENIALSCREEN|

Let’s see how this works:
{{< figure
    default=true
    src="../assets/6-2-main.webp"
    >}}

The code in the main screen is shown here.

{{< figure
    default=true
    src="../assets/6-3-home-screen.webp"
    >}}

We initialise the screen and set the brightness then jump
straight into the main   look with the Switch statement which
controls navigation between screens.

In the Homescreen macro we print a message on the screen and then wait for the Bezel stiwch to be pressed. Remember that the swith is active low - it gives logic 0 when pressed so the test in the If statement is ‘Bezelswitch=0’.The Newscreen variable is altered to be the CODESCREEN.

You can see the other three macros for the other menus here. The code is similar to the Home screen.

So this program just cycles between the screens on the press of the Bezel switch.

{{< figure
    default=true
    src="../assets/6-4-code-screen.webp"
    >}}

{{< figure
    default=true
    src="../assets/6-5-enter-screen.webp"
    >}}

{{< figure
    default=true
    src="../assets/6-6-denial-screen.webp"
    >}}

## Over to You

We will not ask you to construct this program from scratch as there are now quite a few elements to it. Instead open the “6 - driving a menu.fcfx” Flowcode file and download it to your M5 stack Dial. Make sure that you can get it working and that you understand the program.

In this example we simply navigated between the screens, one after the other, using the bezel switch. In practice you might want a slightly different menu system driven from the front panel using the bezel encoder to select the screen that will be navigated to and the Bezel switch to make the selection. To implement this:

Alter the Home screen so that it prints ENTER, CODE, DENIAL above each other on the M5 Stack Dial.
- Print these in white text to start with.
- Modify the program to select the value of a new variable, Nextcreen, between 1 and 3
- Overprint the ENTER, CODE, DENIAL text with red text as the encoder cycles the value of Nextscreen. Overprint in white the screen text as it is deselected.
- When the bezel switch is pressed change the program so that it navigates to the selected screen.

Now you understand how to do menu selection with the bezel encoder and switch. You can use this simple technique to implement your own menu selection system.

## Video and example file

{{< youtube 8z-WcH0wGcY >}}

A Flowcode example file accompanies this tutorial:
- [6 - Driving a menu.fcfx](https://www.flowcode.co.uk/wiki/images/0/05/6_-_Driving_a_menu.fcfx)


Further reading: [Flowcode Wiki](https://www.flowcode.co.uk/wiki/index.php?title=Examples_and_Tutorials
).

## Next step

[Assignment 7: Connecting to the web](../07-connecting-to-the-web)
