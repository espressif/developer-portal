---
title: "Flowcode - M5 Stack Dial Workshop - 6. Menu System"
date: 2024-12-09
series: ["FL001"]
series_order: 6
showAuthor: false
---

In this section we look at how you can create a menu system

{{< figure
    default=true
    src="../assets/6-1-allscreens.webp"
    >}}

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
Home screen              0        HOMESCREEN
Code entry screen        1        CODESCREEN
Enter screen        2        ENTERSCREEN
Denial Screen            3        DENIALSCREEN
Let’s see how this works:







The code in the main screen is shown on the left.

{{< figure
    default=true
    src="../assets/6-2-main.webp"
    >}}

We initialise the screen and set the brightness then jump
straight into the main   look with the Switch statement which

{{< figure
    default=true
    src="../assets/6-3-home-screen.webp"
    >}}

controls navigation between screens.


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

A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
6 - menu system.fcfx

## Next step

[Assignment 7: Mobile Phone App](../07-mobile-phone-app)
