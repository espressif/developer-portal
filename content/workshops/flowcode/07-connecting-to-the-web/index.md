---
title: "Flowcode - M5 Stack Dial Workshop - 7. Connecting to the web"
date: 2024-12-09
series: ["FL001"]
series_order: 7
showAuthor: false
---

In this section we look at how you can create a mobile phone
app to control the M5stack Dial. This works on Wifi and on the
local router. Controlling the Dial from outside the range of the
local router involves the use of a web Broker which we will not
look at here.

The mobile phone app will allow you to control the Dial from
anywhere in the range of the router.

{{< figure
    default=true
    src="../assets/7-3-web-panel.webp"
    >}}

Flowcode Web Developer allows you to create Apps that work
in a browser. It does this using the same PC interface as
Flowcode Embedded - but it creates Javascript programs.
If you have not used Javascript before there are three
fundamental changes that you will need to get to grips with:

- Firstly Javascript is not like other programming languages - it
is an object orientated programming language where one
event or object calls another.
- Secondly Browsers can not be ‘talked to’ cold. Pages and their
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
- You will need to develop 2 programs: a Flowcode Embedded program that goes into the M5Stack Dial and a Flowcode Web Developer program that runs on your mobile phone.

The Flowcode Embedded and Flowcode Web Developer programs are quite unfamiliar so its best to download the examples and work through them rather than create them from scratch.

Firstly lets look at the Flowcode Embedded program “[7 - Connecting to web FE.fcfx](https://www.flowcode.co.uk/wiki/images/3/36/7_-_Connecting_to_web_FE.fcfx)”. Here is the panel:

{{< figure
    default=true
    src="../assets/7-4-embedded-panel.webp"
    >}}

This builds on the panels in the previous programs. To the panel we have added a Web server, a Network comms layer component and a Wireless LAN component for the ESP32 chip. They all link together.

We need to pass information to and from the M5stack Dial Embedded system and the mobile phone. So how do we do this? Here is the strategy:

## Embedded system initialisation

1. Connect to the wifi.
2. Router assigns an IP address – in this case automatically assigned to 192.168.1.141 (you will have a slightly different number).
3. Create a socket for communications to take place

## Controlling the state of an output on an embedded system

1. Mobile phone browser requests page “192.168.1.141/Enter.html”.
2. Embedded system detects “192.168.1.141/Enter.html” request.
3. Embedded system navigates to the Enter screen macro and the door is opened for 4 seconds
4. Embedded system responds with “Door opened”

## Getting a temperature variable from the embedded system

1. Client browser requests page “192.168.1.141/gettemp.html”.
2. Embedded system detects “192.168.1.141/gettemp.html” request in the HTML Callback macro
3. Embedded system takes temperature sample from SHT31 sensor.
4. Embedded system responds with the relevant data served HTML
5. Client browser picks up the HTML data and displays it on the mobile phone

{{< figure
    default=true
    src="../assets/7-1-embedded-initialise.webp"
    >}}

We initialise the Wifi component and connect to the Router. This is a standard domestic Router and you will need to enter your Wifi network and password details.

If the connection is unsuccessful then we print an error on the Dial screen.

If the connection is successful we print the IP address and open a socket. Then we include the menu system from the previous program.

The next thing we need to do is periodically check the Web connection to see if a page has been requested. We do this by putting a `CheckSocketActivity()` command in the loop on each screen macro as you can see here:

{{< figure
    default=true
    src="../assets/7-5-home-screen.webp"
    >}}

When there is activity then the HTMLcallback macro is automatically triggered:

{{< figure
    default=true
    src="../assets/7-6-html-callback.webp"
    >}}

The IP address is generated automatically by the server: in this case “192.168.1.141”.

To open the door lock remotely the phone/browser accesses the web page: “192.168.1. 141/Enter.html”. The HTML callback macro is automatically activated. If “enter.html“ is fetched then the Newscreen variable is changed to Enterscreen and the program continues from there at the end of the HTMLcallback macro. The message “unlocked” is returned as the fetched HTML.

If “gettemp.htm” is fetched then the temperature sensors is read, converted to a string and this string is served up as the fetched HTML.

Lets now look at the Web Developer program that creates the Javascript file:

The Web Developer program panel looks like this:

{{< figure
    default=true
    src="../assets/7-3-web-panel.webp"
    >}}

It contains an Enter button, A text field, A HTTP Fetch command component - FetchForEnter - a read Temp button, a

Dial indicator and a second HTTP Fetch component FetchForReadTemp.

The Enter button calls the Macro Enter:

{{< figure
    default=true
    src="../assets/7-7-fetch-for-enter.webp"
    >}}

The Enter macro calls the HTTP
Fetch component FetchForEnter.
This sends a page request to the
server for page “192.168.1.141/enter.htm” which is
set as a property of the FetchForEnter component.

FetchForEnter component.has as a property the EnterConfirmation macro which is called after the Fetch is executed. Any returning HTML - in this case the confirmation text - is passed to the EnterConfirmation macro as a parameter.

{{< figure
    default=true
    src="../assets/7-8-enterconfirmation.webp"
    >}}

The EnterConfirmation macro sets the text field to the HTML returned by the FetchForEnter call, then it waits 4seconds and sets the text field to “Locked”.

Similarly the ReadTemp macro calls the macro GetTemp. This
simply calls the HTTP Fetch component FetchForReadTemp
which accesses the page “192.168.1.141/gettemp.htm”
which is set as a property of the FetchForReadTemp component.
The FetchForReadTemp component.has as a property the
SetGaugeValue macro which is called after the Fetch is executed.
Any returning HTML - in this case the temperature value - is passed to the SetGaugeValue macro as a parameter.


{{< figure
    default=true
    src="../assets/7-9-gettemp.webp"
    >}}

The SetGauge macro sets the value of the Gauge to the temperature.

{{< figure
    default=true
    src="../assets/7-10-setgaugevalue.webp"
    >}}


## Over to you

The web program and the embedded program only examined the Temperature.

Expand both programs so that the Humidity is also read from the SHT31 and displayed on the mobile phone on a separate dial.

Alter the text in the message box on the mobile phone so that it displays a different message

## Video and example files

{{< youtube hX9Ko3KUDQc >}}

### Mobile Phone App

{{< youtube YRs97dLiSgU >}}

A Flowcode example file accompanies this tutorial:
- [7 - Connecting to web - Embedded.fcfx](https://www.flowcode.co.uk/wiki/images/3/36/7_-_Connecting_to_web_FE.fcfx)
- [7 - Connecting to web - Web Developer.fcfx](https://www.flowcode.co.uk/wiki/images/9/93/7_-_Connecting_to_web_FWD.fcsx)


Further reading: [Flowcode Wiki](https://www.flowcode.co.uk/wiki/index.php?title=Examples_and_Tutorials
).

## Next step

[Assignment 8: Full Project](../08-full-project)
