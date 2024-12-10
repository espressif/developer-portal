---
title: "Flowcode - M5 Stack Dial Workshop - 4. The bezel encoder"
date: 2024-12-09
series: ["FL001"]
series_order: 4
showAuthor: false
---

The bezel encoder feeds into two inputs - GPIO 40 and 41.
When you rotate the bezel the inputs go high - first one then
the other. The direction of rotation dictates which of the two
inputs goes high first. The Quadrature encoder component in
Flowcode takes care of the details for you and increments or
decrements a counter in the component itself. You need to
detect when a change has been made using an interrupt and
then read the counter value.

{{< figure
    default=true
    src="../assets/4-0-candy.webp"
    >}}

Start with the previous program where you learned how to use
the bezel switch and the Input Output pins.
Add an Encoder and connect it to B.9 (GPIO41) and B.8
(GPIO40). Alter the properties as you can see in the image
here.

Your panel should look like this:


Alter your program so that it looks like the flow chart here.

{{< figure
    default=true
    src="../assets/4-1-encoder-properties.webp"
    >}}

Note that you will need to set up an Interrupt Macro with just
one command in it.

Over to you:
Combine the functionality of the Bezel encoder, the switch and
the display by altering the encoder counter to reset when the
Bezel switch is pressed. You can use the Encoder hardware
macro ‘Resetcounter’ for this.

{{< figure
    default=true
    src="../assets/4-2-encoder-panel.webp"
    >}}


{{< figure
    default=true
    src="../assets/4-3-bezel-program-a.webp"
    >}}

{{< figure
    default=true
    src="../assets/4-4-bezel-program-b.webp"
    >}}

{{< figure
    default=true
    src="../assets/4-4-bezel-program-c.webp"
    >}}


A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
4 - Encoder.fcfx

## Next step

[Assignment 5: I2C Expansion](../05-i2c-expansion)
