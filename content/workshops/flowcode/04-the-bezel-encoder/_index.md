---
title: "Flowcode - M5 Stack Dial Workshop - The bezel encoder"
date: 2024-12-10
authors:
    - john-dobson
---

The bezel encoder feeds into two inputs - GPIO 40 and 41.
When you rotate the bezel the inputs go high - first one then
the other. The direction of rotation dictates which of the two
inputs goes high first. The Quadrature encoder component in
Flowcode takes care of the details for you and increments or
decrements a counter in the component itself. You need to
detect when a change has been made using an interrupt and
then read the counter value.
                                                                             4 0 candy.png



Start with the previous program where you learned how to use
the bezel switch and the Input Output pins.
Add an Encoder and connect it to B.9 (GPIO41) and B.8
(GPIO40). Alter the properties as you can see in the image
here.




Your panel should look like this:


Alter your program so that it looks like the flow chart here.
                                                                    4 1 encoder properties.png

Note that you will need to set up an Interrupt Macro with just
one command in it.

Over to you:
Combine the functionality of the Bezel encoder, the switch and
the display by altering the encoder counter to reset when the
Bezel switch is pressed. You can use the Encoder hardware
macro ‘Resetcounter’ for this.
               4 2 encoder panel.png





                                  4 3 bezel program a.png




                                                           4 5 bezel program c.png

Your panel should look like this:This program sets up
                                interrupts for the GPIO pins
                                40 and 41 - the internal
Alter your program so that it looks likeconnections.
                                Bezel    the flow chart here.
                                                      The
                                interrupts call the Encoderint
Note that you will need to set up an Interrupt
                                macro           Macro
                                         which just     withfor
                                                    checks   just
one command in it.              changes on the Encoder.
Over to you:
Combine the functionality of the Bezel encoder, the switch and
the display by altering the encoder counter4 4 to
                                               bezelreset       when the
                                                     program b.png

Bezel switch is pressed. You can use the Encoder hardware
macro ‘Resetcounter’ for this.



Start with the previous program where you learned how to use
the bezel switch and the Input Output pins.
Add an Encoder and connect it to B.9 (GPIO41) and B.8
(GPIO40). Alter the properties as you can see in the image
here.




Your panel should look like this:


Alter your program so that it looks like the flow chart here.

Note that you will need to set up an Interrupt Macro with just
one command in it.

Over to you:
Combine the functionality of the Bezel encoder, the switch and
the display by altering the encoder counter to reset when the
Bezel switch is pressed. You can use the Encoder hardware
macro ‘Resetcounter’ for this.



                          Youtube logo.png




A YouTube video accompanies this tutorial.




A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
4 - Encoder.fcfx


                          4 - bezel encoder.jpg
