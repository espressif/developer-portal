---
title: "Flowcode - M5 Stack Dial Workshop - 3. Switch and I/O Pins"
date: 2024-12-09
authors:
    - john-dobson
---

There were quite a few new concepts in the previous section.
This section is relatively easy: we are going to look at how you
can use the Bezel switch and the general purpose I/O.
The Bezel switch is connected to B10 (GXX) and the I/O is
connected to A1, A2 (GXX, GYY).



                                                                     3 1 M5stack Dial.png


Start a new M5stack Dial program in Flowcode.
Add a switch and a LED to the 2D panel and create the
program you can see here.
This is a simple program that reads the value of the switch on
the bezel (B10 or GPIO42) and sends it to the pins on A1 and
A4 (GPIO10 and GPIO2). You can simulate this and you can
check it works by sending it to your hardware.
So what?
You will notice that the switch logic is reversed: when the bezel
is pressed the input at Port B10 (GPIO42) goes low.


Over to you:
Modify the program so that the output stays on for 5 seconds
when the bezel is pressed.
Try the same program but use GPIO pins 13 and 15 rather than
10 and 42. Does the program work?




                                                        3 1 IO.png




                                                                             Page #


                                                             M5 stack dial
3- Switch & I/O pins                                          workshop




                          Youtube logo.png




A YouTube video accompanies this tutorial.




A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
3 - Switch n IO pins.fcfx


                          3 - switch n io pins.jpg
