---
title: "Creating an Arduino Demo With No Coding Experience Using AI"
date: 2026-05-19
authors:
  - parsa-abbasi
tags:
  - Arduino
  - ESP32-C5
  - AI
  - Hardware
showTableOfContents: true
featureAsset: "featured.webp"
summary: "A first-person account of building an ESP32-C5 Arduino temperature indicator with AI assistance, from generated code and confusing errors to serial debugging, wiring issues, and the moment the LED finally changed color."
---

It started with a simple idea.

I wanted a tiny device that could *feel* the temperature and show it using colors. Nothing fancy. Just something physical, something real. Blue if it's cold, red if it's hot, green if everything is fine.

I had never built anything like this before.

No Arduino experience.  
No embedded systems background.  
Not even a clear idea of what "flashing a board" really meant.

What I did have was an ESP32-C5 development board, a small environmental sensor, and access to AI. Which was suggested to me with the AI itself once I shared my final demo outcome idea.

That turned out to be enough, but not in the way I expected.

## The First Hour: False Confidence

At the beginning, everything felt deceptively easy.

Install Arduino IDE.  
Plug in the board.  
Select a port.  
Click "Upload."

I asked AI to generate code:

> Read temperature and change LED color based on thresholds.

It gave me a full sketch. It looked complete. Structured. Professional.

I copied it, hit upload, and waited for magic.

Nothing happened.

The LED stayed stubbornly red.

## The Second Hour: Reality Sets In

The first error message appeared:

```c
undefined reference to loop()
```

Then another:

```c
redefinition of 'setup()'
```

Then another.

At this point, I realized something important:

I didn't understand the code I was running.

AI had given me something that *looked* correct, but I had no mental model for it. Fixing errors felt like guessing.

Still, I kept going.

## The Silent Failure

Eventually, the code uploaded successfully. No errors. Clean build.

But the behavior made no sense:

- The LED stayed red no matter what
- The temperature never seemed to change
- The system felt... dead

I tried heating the sensor with steam.  
Nothing.  
I tried cooling it.  
Nothing.

At this point, I wasn't debugging code anymore. I was debugging reality.

## The Invisible Output

Then came one of the most confusing moments.

I expected to see temperature values printed somewhere. The code clearly had `Serial.print()` statements.

But where were they?

I stared at the Arduino IDE. There was text scrolling in the bottom panel: logs, uploads, messages. I assumed that was it.

It wasn't.

I had been looking at the **Output tab**, not the **Serial Monitor**.

When I finally opened the correct panel, set the baud rate to 115200, and pressed reset, the device suddenly spoke:

```text
Temperature: 24.7
Temperature: 24.6
```

It was the first real sign of life.

## The Hardware Strikes Back

But just as things started working, a new kind of problem appeared, one that had nothing to do with syntax or logic.

The board began crashing.

```text
CPU_LOCKUP
Failed to allocate dummy cacheline
```

It looked serious, and it was.

The ESP32-C5, it turns out, is relatively new. Its support in the Arduino ecosystem isn't perfectly stable yet. Something related to PSRAM initialization was failing before my code even ran.

This was frustrating in a different way.

You can fix code.  
You can debug logic.  
But when the hardware itself behaves unpredictably, it feels like the ground is moving under your feet.

Fixing it required:

- Updating board definitions
- Changing obscure settings like "USB CDC On Boot"
- Toggling PSRAM on and off
- Testing minimal sketches just to confirm the board could *boot*

This wasn't something AI could fully solve. It required trial, patience, and a bit of stubbornness.

## Breaking It Apart

At some point, I stopped trying to fix everything at once.

Instead, I broke the system into pieces.

First: the LED.

I wrote a tiny program that just cycled colors:

```text
Red -> Green -> Blue -> repeat.
```

It worked perfectly.

Then: the serial connection.

A simple "Hello from ESP32" message confirmed communication was stable.

Then: the sensor.

I ran an I2C scanner.

It returned:

```text
No I2C devices found
```

That meant the sensor wasn't even being detected.

So I went back to the wires.

## The Wiring Problem No One Talks About

This part took longer than I expected.

The ESP32-C5 board doesn't label pins in a beginner-friendly way. There were numbers, but they didn't clearly map to the GPIO values used in code. Here was a challange and a very usefull lesson to learn more about the C5 devkits, as they are very popular and suitable for my future experiments. The information regarding all devkits is easily availabe on Espressif Systems website. https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32/

I connected SDA and SCL to the wrong pins.  
Then I swapped them.  
Then I questioned whether the sensor was even powered.

Eventually, after carefully tracing connections and trying different combinations, the scanner finally returned:

```text
I2C device found at 0x44
```

That single line felt like a breakthrough.

## The Moment It All Came Together

Once the sensor was detected and the LED was confirmed working, combining them was almost anticlimactic.

The logic was simple:

- If temperature < 23: blue
- If temperature > 27: red
- Else: green

I uploaded the code.

Opened Serial Monitor.

Pressed reset.

Then I did something simple: I breathed on the sensor.

The temperature value ticked upward.

And the LED turned red.

It worked.

## What This Experience Actually Taught Me

Before this, I assumed the hard part would be writing code.

It wasn't.

The real challenges were:

- Understanding how tools behave
- Knowing where to look for output
- Debugging hardware connections
- Dealing with unstable environments
- Breaking problems into smaller pieces

AI helped a lot, especially with generating code and explaining errors, but it didn't eliminate the need to think.

If anything, it shifted the skill from *writing code* to *understanding systems*.

## Why This Matters

A few years ago, building something like this would require:

- Reading datasheets
- Writing low-level code
- Understanding communication protocols

Now, you can start with an idea, describe it in plain language, and get something working in a day.

Not perfectly.  
Not smoothly.  
But *real*.

## The Takeaway

This wasn't just about building a temperature indicator.

It was about discovering a new way of learning.

You don't need to know everything upfront.  
You don't need to write perfect code.

You just need to:

- Start with a simple idea
- Accept that things will break
- Fix one problem at a time
- Use AI as a guide, not a crutch

And eventually, the LED changes color, and you understand why.

---

If you're thinking about trying something similar, do it.

Not because it's easy.

But because it's now *possible*.
