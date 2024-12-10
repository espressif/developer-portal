---
title: "Flowcode - M5 Stack Dial Workshop - 7. Mobile Phone App"
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

{{< figure
    default=true
    src="../assets/7-1-embedded-initialise.webp"
    >}}

{{< figure
    default=true
    src="../assets/7-2-htmlcallback.webp"
    >}}

{{< figure
    default=true
    src="../assets/7-4-embedded-panel.webp"
    >}}

{{< figure
    default=true
    src="../assets/7-5-home-screen.webp"
    >}}

{{< figure
    default=true
    src="../assets/7-6-html-callback.webp"
    >}}

{{< figure
    default=true
    src="../assets/7-7-fetch-for-enter.webp"
    >}}

{{< figure
    default=true
    src="../assets/7-8-enterconfirmation.webp"
    >}}


  content can only be fetched by browsers fromthe server.

{{< figure
    default=true
    src="../assets/7-9-gettemp.webp"
    >}}

{{< figure
    default=true
    src="../assets/7-10-setgaugevalue.webp"
    >}}


A YouTube video accompanies this tutorial.


A Flowcode example file accompanies this tutorial. This is
available from the Flowcode Wiki:
https://www.flowcode.co.uk/wiki/index.php?
title=Examples_and_Tutorials
7 - mobile phone app.fcfx

## Next step

[Assignment 8: Full Project](../08-full-project)
