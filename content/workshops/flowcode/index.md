                                                                                Page #


                                                                M5 stack dial
                                                                 workshop




                    Flowcode logo full.jpg




                          title image.jpg




                                                    Espressif logo.png

M5 stack logo.png



                                                       Page #


                                       M5 stack dial
Contents                                workshop





                                                         Page #


                                         M5 stack dial
Programs & media                          workshop





                                                                        Page #


                                                        M5 stack dial
 Requirements                                            workshop


This set of workshops will take around 20 hours to complete.
You will need:
M5Stack Dial with power lead
Relay board - can be 12 or 24V
Grove style 4 pin push leads
Solenoid


If you are implementing the door lock for real you will also need:
Maglock
12 or 24V power supply
5V regulator board (for powering the M5Stack Dial)


You will also need a copy of Flowcode with the ESP32 chip
pack. Flowcode is free of charge for makers, professionals will
need to buy a Pro license.


The ESP chip pack costs £60 or around $80 and is available
from the Flowcode web site: www.flowcode.co.uk.





                                                                        Page #


                                                        M5 stack dial
 Learning outcomes                                       workshop


This workshop is designed for engineers who have some
experience of programming embedded systems and want to
learn more about graphical display based systems and web
based control and data gathering systems.
For Matrix customers it assumes that you have completed the
Introduction to Microcontrollers course.
If you complete the exercises in this workbook then it will take
you around 20 hours. This is designed for self study.


If you complete this workshop then will learn:
ESP32 programming
Simple Input / Output pin control
How encoders work
How I2C sensors work
SHT32 temperature humidity sensor operation
How solenoid/maglocks work
Graphical display programming
Menu system design for graphical displays
Embedded web based communication techniques
Mobile phone app development
Mobile phone / Embedded system design


Whilst this project uses the M5Stack Dial the silks learned will
be useful for any graphical display based project.

                                                                                         Page #


                                                         M5 stack dial
1 - Planning                                              workshop


Ok - let’s be honest. Planning is a bit of a pain. Its boring. Its
not the fun part of the job. At the start of a project we are
itching to get on with the coding, the graphics and get
something working.

But if you don’t plan then there can be all sorts of pain later:
you end up redoing work, falling out with colleagues and
customers, and it’s a lot less fun later on in the project.
                                                            M5stack test screen-01.jpg


In part 1 we show you how we plan the project.
Specification:
We are going to show you how to make an electronic door lock
based on the M5stack dial with the following features:
Based on M5 stack dial
Code entry access using bezel and switch
Maglock door opener – 24VDC @10A
Graphical display
Remote unlock with mobile phone
Weather information on mobile phone and locally





                                                                                     Page #


                                                      M5 stack dial
1 - Planning                                           workshop


Specification:
We are going to show you how to make an electronic door lock
based on the M5stack dial with the following features:
Based on M5 stack dial
Code entry access using bezel and switch
Maglock door opener – 24VDC @10A
Graphical display
                                                        M5stack test screen-01.jpg
Remote unlock with mobile phone
Weather information on mobile phone and locally




                                                           Home.png





                                                                               Page #


                                                      M5 stack dial
1 - Planning                                           workshop


Specification:
We are going to show you how to make an electronic door lock
based on the M5stack dial with the following features:
Based on M5 stack dial
Code entry access using bezel and switch
Maglock door opener – 24VDC @10A
Graphical display                                                 combo.png


Remote unlock with mobile phone
Weather information on mobile phone and locally




                                                                No entry.png




                                                             unlocked.png





                                                                      Page #


                                                      M5 stack dial
1 - Planning                                           workshop


Specification:
We are going to show you how to make an electronic door lock
based on the M5stack dial with the following features:
Based on M5 stack dial
Code entry access using bezel and switch
Maglock door opener – 24VDC @10A
Graphical display
Remote unlock with mobile phone
Weather information on mobile phone and locally





                                                                      Page #


                                                      M5 stack dial
1 - Planning                                           workshop


Specification:
We are going to show you how to make an electronic door lock
based on the M5stack dial with the following features:
Based on M5 stack dial
Code entry access using bezel and switch
Maglock door opener – 24VDC @10A
Graphical display
Remote unlock with mobile phone
Weather information on mobile phone and locally





                                                                      Page #


                                                      M5 stack dial
1 - Planning                                           workshop


Specification:
We are going to show you how to make an electronic door lock
based on the M5stack dial with the following features:
Based on M5 stack dial
Code entry access using bezel and switch
Maglock door opener – 24VDC @10A
Graphical display
Remote unlock with mobile phone
Weather information on mobile phone and locally





                                                                      Page #


                                                      M5 stack dial
1 - Planning                                           workshop


Specification:
We are going to show you how to make an electronic door lock
based on the M5stack dial with the following features:
Based on M5 stack dial
Code entry access using bezel and switch
Maglock door opener – 24VDC @10A
Graphical display
Remote unlock with mobile phone
Weather information on mobile phone and locally




                         hardware.png





                                                                        Page #


                                                        M5 stack dial
1 - Planning                                             workshop
Resources



                           Youtube logo.png




A YouTube video accompanies this tutorial.
www.youtube.com/playlist?list=XYZ




                        1 - planning the project.jpg





                                                                                                  Page #


                                                            M5 stack dial
2 - Using the display                                        workshop


In this section we show you how to use the Display
component in Flowcode. Once you know the colours, fonts and
other parameters of your design, display graphics are just a
series of commands to draw the lines, graphics and text in the
right places.

One of the great features of Flowcode is that you can simulate
the graphical display on screen - this saves hours of coding
time.                                             2 0 candy.png


First set up the panel in Flowcode as above:
PWM channel connected to PortA.9 (GPIO XX)
This allows us to control the brightness of the display.

                                                                                 2 1 panel set up.png




Then add the GC9A01A_SPI display. Use the images here to
get the correct settings.

If you need more information then you can left click on the
display and click on HELP to get more information from the
Flowcode Wiki.

Notice that we have not got the exact fonts that we wanted -
Flowcode does not include all fonts - although more can be
made - but the fonts that we have should be fine.


                                                        2 2 backlight properties.png




                                                                                                      Page #


                                                                        M5 stack dial
2 - Using the display                                                    workshop


First set up the panel in Flowcode as above:
PWM channel connected to PortA.9 (GPIO XX)
This allows us to control the brightness of the display.




Then add the GC9A01A_SPI display. Use the images here to
get the correct settings.

If you need more information then you can2 left
                                           3 displayclick
                                                     propertieson
                                                               1.png the

display and click on HELP to get more information from the
Flowcode Wiki.

Notice that we have not got the exact fonts that we wanted -
Flowcode does not include all fonts - although more can be
made - but the fonts that we have should be fine.



                                                                       2 4 display properties 2.png




           2 5 display properties 3.png




            2 6 display properties 4.png





                                                                                       Page #


                                                          M5 stack dial
2 - Using the display                                      workshop


First set up the panel in Flowcode as above:
PWM channel connected to PortA.9 (GPIO XX)
This allows us to control the brightness of the display.




Then add the GC9A01A_SPI display. Use    the images here to
                                    2 7 bitmap drawer properties.png
get the correct settings.

If you need more information then you can left click on the
display and click on HELP to get more information from the
Flowcode Wiki.

Notice that we have not got the exact fonts that we wanted -
Flowcode does        not include all fonts - although more can be
             2 9 first sim.png


made - but the fonts that we have should be fine.




                                                             2 8 first flowchart.png




       2 10 constants.png

                                                                                      Page #


                                                                      M5 stack dial
2 - Using the display                                                  workshop


First set up the panel in Flowcode as above:
PWM channel connected to PortA.9 (GPIO XX)
This allows us to control the brightness of the display.




Then add the GC9A01A_SPI display. Use the images here to
get the correct settings.                   Home.png




If you need more information then you can left click on the
display and click on HELP to get more information from the
Flowcode Wiki.

Notice that we have not got the exact fonts that we wanted -
Flowcode does not include all fonts - although more can be
made - but the fonts that we have should be fine.
                         2 11 pseudocode.png




                                                           2 12 c code.png




                                                                             Page #


                                                             M5 stack dial
2 - Using the display                                         workshop
Resources



                           Youtube logo.png




A YouTube video accompanies this tutorial.




A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
2 - Using the display.fcfx


                          2 - using the display.jpg




                                         Flowcode logo.png





                                                                                            Page #


                                                              M5 stack dial
3- Switch & I/O pins                                           workshop


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




                                         Flowcode logo.png





                                                                                                 Page #


                                                                   M5 stack dial
4 - The bezel encoder                                               workshop


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



                                                                                     Page #


                                                               M5 stack dial
4 - The bezel encoder                                           workshop


Start with the previous program where you learned how to use
the bezel switch and the Input Output     pins.
                                  4 3 bezel program a.png


Add an Encoder and connect it to B.9 (GPIO41) and B.8
(GPIO40). Alter the properties as you can see in the image
here.




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





                                                                        Page #


                                                        M5 stack dial
4 - The bezel encoder                                    workshop


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





                                                                            Page #


                                                            M5 stack dial
4 - The bezel encoder                                        workshop




                          Youtube logo.png




A YouTube video accompanies this tutorial.




A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
4 - Encoder.fcfx


                          4 - bezel encoder.jpg




                                        Flowcode logo.png





                                                                          Page #


                                                          M5 stack dial
5 - I2C expansion                                          workshop


In this section we are going to read a sensor value using the
I2C connection on the M5 Stack Dial.
In this case we will use a small Grove sensor that contains a
SH31 temperature and humidity chip.
Of course it’s a bit odd having a temperature and humidity
sensor on a door lock! But it allows us to teach you how you
can take advantage of the huge range of I2C sensors and
expansion devices to extend the functionality of your M5stack
Dial.                                                  SHT31.png



Start with the program you made in the previous section.


Add a SHT31 Temp / Humidity sensor from the Sensors
component section.
Adjust its properties as you can see here:



You should have a panel that looks like this:
Add two variables of type INT: Temperature and       Humidity.
                                              5 1 sht31 properties.png
Then develop the program you can see below.
The program is easy to read but there are a few things of note:
The program initialises the display and the SHT31 sensor.
Initialisation is used on many components to set up registers
inside the microcontroller.
When reading and display a value like this one issue you have
is that you are writing new numbers on top of old ones. When
the number changes the display becomes hard to read. So we
need to clear the area of the screen before we rewrite the
number. Clearing the screen takes time - its quicker to draw a
rectangle of the background colour (black here).

Over to you:                5 2 panel.png


In practice the temperature and humidity are quantities that


change very slowly. So there is no need to constantly rewrite
                                                                                  Page #


                                                                  M5 stack dial
5 - I2C expansion                                                  workshop


Start with the program you made in the previous section.


Add a SHT31 Temp / Humidity sensor from the Sensors
component section.
Adjust its properties as you can see here:



You should have a panel that looks like this:
Add two variables of type INT: Temperature and Humidity.
Then develop the program you can see below. 5 3 variables.png
The program is easy to read but there are a few things of note:
The program initialises the display and the SHT31 sensor.
Initialisation is used on many components to set up registers
inside the microcontroller.
When reading and display a value like this one issue you have
is that you are writing new numbers on top of old ones. When
the number changes the display becomes hard to read. So we
need to clear the area of the screen before we rewrite the
number. Clearing the screen takes time - its quicker to draw a
rectangle of the background colour (black here).

Over to you:
In practice the temperature and humidity are quantities that
change very slowly. So there is no need to constantly rewrite
the values on the screen.
Develop a program that only redraws the values when they
change.



           5 4 temp hum program.png





                                                                       Page #


                                                       M5 stack dial
5 - I2C expansion                                       workshop


Start with the program you made in the previous section.


Add a SHT31 Temp / Humidity sensor from the Sensors
component section.
Adjust its properties as you can see here:



You should have a panel that looks like this:
Add two variables of type INT: Temperature and Humidity.
Then develop the program you can see below.
The program is easy to read but there are a few things of note:
The program initialises the display and the SHT31 sensor.
Initialisation is used on many components to set up registers
inside the microcontroller.
When reading and display a value like this one issue you have
is that you are writing new numbers on top of old ones. When
the number changes the display becomes hard to read. So we
need to clear the area of the screen before we rewrite the
number. Clearing the screen takes time - its quicker to draw a
rectangle of the background colour (black here).

Over to you:
In practice the temperature and humidity are quantities that
change very slowly. So there is no need to constantly rewrite
the values on the screen.
Develop a program that only redraws the values when they
change.





                                                                            Page #


                                                            M5 stack dial
5 - I2C expansion                                            workshop




                          Youtube logo.png




A YouTube video accompanies this tutorial.
                          5 - I2C expansion.jpg




                                        Flowcode logo.png
A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
5 - I2C expansion.fcfx





                                                                            Page #


                                                            M5 stack dial
6 - menu system                                              workshop


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





                                                                        Page #


                                                        M5 stack dial
6 - menu system                                          workshop



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
Home screen             60
                         2 main.png  HOMESCREEN
Code entry screen        1           CODESCREEN
Enter screen        2             ENTERSCREEN
Denial Screen            3           DENIALSCREEN
Let’s see how this works:




The code in the main screen is shown on the left.
We initialise the screen and set the brightness then jump
straight into the main   look with the Switch statement which
                     6 3 home screen.png


controls navigation between screens.


                                                                              Page #


                                                              M5 stack dial
6 - menu system                                                workshop



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
Home screen                0 screen.png HOMESCREEN
                      6 4 code

Code entry screen          1            CODESCREEN
Enter screen        2             ENTERSCREEN
Denial Screen              3            DENIALSCREEN
Let’s see how this works:




The code in the main screen is shown on the left.
We initialise the screen and set the brightness then jump
straight into the    main look with the Switch statement which
                6 5 enter screen.png
controls navigation between screens.                6 6 Denisl screen.png





                                                                        Page #


                                                        M5 stack dial
6 - menu system                                          workshop



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
straight into the main look with the Switch statement which
controls navigation between screens.


                                                                               Page #


                                                               M5 stack dial
6 - menu system                                                 workshop




                             Youtube logo.png




A YouTube video accompanies      this tutorial.
                       6 - menu system.jpg




                                           Flowcode logo.png



A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
6 - menu system.fcfx





                                                                        Page #


                                                        M5 stack dial
7 - mobile phone app                                     workshop


In this section we look at how you can create a mobile phone
app to control the M5stack Dial. This works on Wifi and on the
local router. Controlling the Dial from outside the range of the
local router involves the use of a web Broker which we will not
look at here.
The mobile phone app will allow you to control the Dial from
anywhere in the range of the router. 7 3 web panel.png



Phone image to create
Flowcode Web Developer allows you to create Apps that work
in a browser. It does this using the same PC interface as
Flowcode Embedded - but it creates Javascript programs.
If you have not used Javascript before there are three
fundamental changes that you will need to get to grips with:
Firstly Javascript is not like other programming languages - it
   is an object orientated programming language where one
   event or object calls another.
Secondly Browsers can not be ‘talked to’ cold. Pages and their
  content can only be fetched by browsers from the server.
  That means that to send commands to an embedded system
  it needs to detect which pages have been accessed. So
  detecting a fetch of page “on.htm” might turn a light on and
  detecting a fetch of page “off.htm” might turn a light off.
  Correspondingly if we detect a page access of “getinfo.htm”
  then the returning HTML content can be the temperature
  value - or status of a switch etc. That allows us to have two
  way communication - but only instigated by the Javascript
  program in the browser on - in this case - the mobile phone.
You will need to develop 2 programs: a Flowcode Embedded
  program that goes into the M5Stack Dial and a Flowcode

                                                                             Page #


                                                             M5 stack dial
7 - mobile phone app                                          workshop


Flowcode Web Developer allows you to create Apps that work
in a browser. It does this using the same PC interface as
Flowcode Embedded - but it creates Javascript programs.
If you have not used Javascript before there are three
fundamental changes that you will need to get to grips with:
Firstly Javascript is not like other programming languages - it
   is an object orientated programming language where one
   event or object calls another.
Secondly Browsers can not be ‘talked to’ cold. Pages and their
  content can only be fetched by browsers from the server.
                                                           7 4 embedded panel.png
  That means that to send commands to an embedded system
  it needs to detect which pages have been accessed. So
  detecting a fetch of page “on.htm” might turn a light on and
  detecting a fetch of page “off.htm” might turn a light off.
  Correspondingly if we detect a page access of “getinfo.htm”
  then the returning HTML content can be the temperature
  value - or status of a switch etc. That allows us to have two
  way communication - but only instigated by the Javascript
  program in the browser on - in this case - the mobile phone.
You will need to develop 2 programs: a Flowcode Embedded
  program that goes into the M5Stack Dial and a Flowcode
  Web Developer program that runs on your mobile phone.





                                                                          Page #


                                                          M5 stack dial
7 - mobile phone app                                       workshop


Flowcode Web Developer allows you to create Apps that work
in a browser. It does this using the same PC interface as
Flowcode Embedded - but it creates Javascript programs.
If you have not used Javascript before there are three
fundamental changes that you will need to get to grips with:
Firstly Javascript is not like other programming languages - it
   is an object orientated programming language where one
   event or object calls another.
Secondly Browsers can not be ‘talked to’ cold. Pages and their
  content can only be fetched by browsers from the server.
  That means that to send commands to an embedded system
  it needs to detect which pages have been accessed. So
  detecting a fetch of page “on.htm” might turn a light on and
                                            7 1 embedded initialise.png
  detecting a fetch of page “off.htm” might turn a light off.
  Correspondingly if we detect a page access of “getinfo.htm”
  then the returning HTML content can be the temperature
  value - or status of a switch etc. That allows us to have two
  way communication - but only instigated by the Javascript
  program in the browser on - in this case - the mobile phone.
You will need to develop 2 programs: a Flowcode Embedded
  program that goes into the M5Stack Dial and a Flowcode
  Web Developer program that runs on your mobile phone.





                                                                          Page #


                                                          M5 stack dial
7 - mobile phone app                                       workshop


Flowcode Web Developer allows you to create Apps that work
in a browser. It does this using the same PC interface as
Flowcode Embedded - but it creates Javascript programs.
If you have not used Javascript before there are three
fundamental changes that you will need to get to grips with:
Firstly Javascript is not like other programming languages - it
   is an object orientated programming language where one
   event or object calls another.
Secondly Browsers can not be ‘talked to’ cold. Pages and their
  content can only be fetched by browsers from the server.
  That means that to send commands to an embedded system
  it needs to detect which pages have been accessed.             So
                                                   7 5 home screen.png


  detecting a fetch of page “on.htm” might turn a light on and
  detecting a fetch of page “off.htm” might turn a light off.
  Correspondingly if we detect a page access of “getinfo.htm”
  then the returning HTML content can be the temperature
  value - or status of a switch etc. That allows us to have two
  way communication - but only instigated by the Javascript
  program in the browser on - in this case - the mobile phone.
You will need to develop 2 programs: a Flowcode Embedded
  program that goes into the M5Stack Dial and a Flowcode
  Web Developer program that runs on your mobile phone.





                                                                          Page #


                                                          M5 stack dial
7 - mobile phone app                                       workshop


Flowcode Web Developer allows you to create Apps that work
in a browser. It does this using the same PC interface as
Flowcode Embedded - but it creates Javascript programs.
If you have not used Javascript before there are three
fundamental changes that you will need to get to     grips with:
                                                7 6 HTML call back.png


Firstly Javascript is not like other programming languages - it
   is an object orientated programming language where one
   event or object calls another.
Secondly Browsers can not be ‘talked to’ cold. Pages and their
  content can only be fetched by browsers from the server.
  That means that to send commands to an embedded system
  it needs to detect which pages have been accessed. So
  detecting a fetch of page “on.htm” might turn a light on and
  detecting a fetch of page “off.htm” might turn a light off.
  Correspondingly if we detect a page access of “getinfo.htm”
  then the returning HTML content can be the temperature
  value - or status of a switch etc. That allows us to have two
  way communication - but only instigated by the Javascript
  program in the browser on - in this case - the mobile phone.
You will need to develop 2 programs: a Flowcode Embedded
  program that goes into the M5Stack Dial and a Flowcode
  Web Developer program that runs on your mobile phone.





                                                                            Page #


                                                            M5 stack dial
7 - mobile phone app                                         workshop


Flowcode Web Developer allows you to create Apps that work
in a browser. It does this using the same PC interface as
Flowcode Embedded - but it creates Javascript programs.
If you have not used Javascript before there are three
fundamental changes that you will need to get to grips with:
Firstly Javascript is not like other programming languages - it
   is an object orientated programming language where one
   event or object calls another.
Secondly            Browsers can not be ‘talked to’ cold. Pages and their
  7 7 fetch for enter.png


  content can only be fetched by browsers from7the                 server.
                                                            3 web panel.png


  That means that to send commands to an embedded system
  it needs to detect which pages have been accessed. So
  detecting a fetch of page “on.htm” might turn a light on and
  detecting a fetch of page “off.htm” might turn a light off.
  Correspondingly if we detect a page access of “getinfo.htm”
  then the returning HTML content can be the temperature
  value - or status of a switch etc. That allows us to have two
  way        communication - but only instigated by the Javascript
   7 8 Enterconfirmation.png


  program in the browser on - in this case - the mobile phone.
You will need to develop 2 programs: a Flowcode Embedded
  program that goes into the M5Stack Dial and a Flowcode
  Web Developer program that runs on your mobile      phone.
                                                7 9 GetTemp.png




    7 10 SetGaugeValue.png



                                                                       Page #


                                                       M5 stack dial
7 - mobile phone app                                    workshop


Flowcode Web Developer allows you to create Apps that work
in a browser. It does this using the same PC interface as
Flowcode Embedded - but it creates Javascript programs.
If you have not used Javascript before there are three
fundamental changes that you will need to get to grips with:
Firstly Javascript is not like other programming languages - it
   is an object orientated programming language where one
   event or object calls another.
Secondly Browsers can not be ‘talked to’ cold. Pages and their
  content can only be fetched by browsers from the server.
  That means that to send commands to an embedded system
  it needs to detect which pages have been accessed. So
  detecting a fetch of page “on.htm” might turn a light on and
  detecting a fetch of page “off.htm” might turn a light off.
  Correspondingly if we detect a page access of “getinfo.htm”
  then the returning HTML content can be the temperature
  value - or status of a switch etc. That allows us to have two
  way communication - but only instigated by the Javascript
  program in the browser on - in this case - the mobile phone.
You will need to develop 2 programs: a Flowcode Embedded
  program that goes into the M5Stack Dial and a Flowcode
  Web Developer program that runs on your mobile phone.





                                                                              Page #


                                                              M5 stack dial
7 - mobile phone app                                           workshop




                           Youtube logo.png




A YouTube video accompanies this tutorial.




A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
7 - mobile phone app.fcfx


                          7 - mobile phone app.jpg




                                          Flowcode logo.png





                                                                         Page #


                                                         M5 stack dial
8 - Full project                                          workshop


If you have got this far then well done. You will have learned a
lot about embedded programming, about developing apps for
mobile devices and about electronics in general. You have
learned the basics of how to construct all the individual
elements of the system. Its up to you now to complete it.
What we have done is completed the project for you so that
you can refer to it when you get stuck. There are two final files:
“7 - Connecting to web FE.fcfx” and “7 - Connecting to web
FWD.fcfx”.
Over to you:
You have all the bones of the system in place. To get to the
final design you need to do the following:
Design all the individual screen graphics. Refer to the Planning
    section for details of the graphics, colours, fonts etc. We
    suggest that you embed the graphic of the menus needed
    onto your Embedded program panel so it looks like this:

Get the navigation between screens working properly.
Get the logic for a successful combination to be entered
   properly in place.
Get the communication between the Mobile phone and the
   M5Stack Dial working properly.                 8 0 panel.png



This is a great creative challenge. We suggest that you alter
the Embedded program panel to look like this:

Good luck and have fun!





                                                                       Page #


                                                       M5 stack dial
8 - Full project                                        workshop


Over to you:
You have all the bones of the system in place. To get to the
final design you need to do the following:
Design all the individual screen graphics. Refer to the Planning
    section for details of the graphics, colours, fonts etc. We
    suggest that you embed the graphic of the menus needed
    onto your Embedded program panel so it looks like this:

Get the navigation between screens working properly.
Get the logic for a successful combination to be entered
   properly in place.
Get the communication between the Mobile phone and the
   M5Stack Dial working properly.

This is a great creative challenge. We suggest that you alter
the Embedded program panel to look like this:

Good luck and have fun!






