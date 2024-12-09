---
title: "Flowcode - M5 Stack Dial Workshop - Menu System"
date: 2024-12-10
authors:
    - john-dobson
---

In this section we look at how you can create a menu system 6 1 allscreens.png

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
We initialise the screen and set the brightness then jump
straight into the main   look with the Switch statement which
                     6 3 home screen.png


controls navigation between screens.





                6 5 enter screen.png
              6 6 Denisl screen.png





                             Youtube logo.png




A YouTube video accompanies      this tutorial.
                       6 - menu system.jpg




                                           Flowcode logo.png



A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
6 - menu system.fcfx



