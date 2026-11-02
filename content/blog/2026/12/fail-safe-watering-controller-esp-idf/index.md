---
title: "Designing a fail-safe watering controller with ESP-IDF"
date: 2026-12-02
summary: "An ESP-IDF watering controller for the ESP32-C3 and ESP32-C6 that waters in short pulses, backs every pulse with a one-shot timer and the task watchdog, and latches a fault when the sensor fails, the soil stops responding or the pump uses up its daily on-time budget. The article covers the wiring, the sensor checks, the state machine and host tests that check the safety rules without hardware."
tags:
  - ESP-IDF
  - practitioner
  - tutorial
  - community contribution
  - ADC
  - MQTT
authors:
  - "artur-puig"
---

A controller that switches the pump on whenever the soil sensor reads dry keeps pumping in three common failures. A sensor that slips out of the soil reads dry in air. An empty reservoir never makes the soil wetter. A control task that stalls with the pump on never switches it off. The controller in this article stops the pump in all three cases: within one watering cycle for the first two, and within seconds for the third.

In 2018 I prototyped iGrow, a controller for growing conditions, and filed it in Spain as a [utility model application (ES 1211990 U)](https://consultas2.oepm.es/InvenesWeb/detalle?referencia=U201830548). Soil moisture was one of its inputs; this article builds a smaller controller around that one input.

The controller reads one capacitive soil moisture sensor and drives one low-voltage pump or solenoid valve. It targets ESP-IDF v6.1 on the ESP32-C3 and the ESP32-C6. The firmware compiles for both chips, and the control logic is plain C that is tested on a PC against a simulated pot; the bring-up checklist at the end covers what only the hardware can confirm. The complete project is on GitHub:

{{< github repo="arturpuig/esp32-failsafe-watering" >}}

## What the controller does

- Reads soil moisture once per second and converts it to a percentage between two calibration points.
- Waters in pulses of a few seconds with a soak period after each one, until the soil reaches a target.
- Ends every pulse on time, with a one-shot timer and the task watchdog as backups for the control task.
- Latches a fault when the readings stay invalid for 10 s, when a full cycle of pulses barely raises the moisture or when the pump uses up its 24-hour on-time budget. A latched fault keeps the pump off until someone clears it, and it survives a reboot, as does the on-time already used.
- Optionally reports its state over MQTT. Watering never waits for the network.

{{< alert icon="triangle-exclamation" >}}
This is a hobby or small-scale controller built from low-voltage parts. It is not a certified irrigation product. Keep mains wiring out of the build, and test every change with the pump outlet in a bucket before it goes near a plant.
{{< /alert >}}

## Hardware

| Part | Notes |
| --- | --- |
| ESP32-C3 or ESP32-C6 development board | For example ESP32-C3-DevKitM-1 or ESP32-C6-DevKitC-1. Choose the ESP32-C6 if your sensor reads above about 2.3 V in dry soil (see [Reading the sensor](#reading-the-sensor)) |
| Capacitive soil moisture sensor | Analog output, powered from 3.3 V; prefer boards with a TLC555 timer (see below) |
| N-channel MOSFET | R<sub>DS(on)</sub> specified at a gate voltage of 2.5 V, such as the AO3400A or IRLML6344 (both SOT-23, so a breadboard needs an adapter) |
| Schottky diode, 1N5819 | Flyback diode across the pump or valve |
| 100 Ω and 100 kΩ resistors | Gate series resistor and gate pull-down |
| 5 V or 12 V pump or solenoid valve | With its own power supply |
| Fuse or polyfuse | Sized for the pump, in the pump supply line |

{{< figure
    default=true
    src="img/wiring.webp"
    alt="Wiring diagram: soil sensor output to GPIO3; GPIO10 to the MOSFET gate through 100 ohms, with a 100 kilohm resistor from gate to ground; pump on the low side with a 1N5819 flyback diode; separate pump supply with a fuse, its ground joined to the board ground"
    caption="Wiring for the ESP32-C3 and ESP32-C6. The pump is switched on the low side and has its own supply."
    >}}

Notes on the circuit:

- **The sensor goes to an ADC1 pin.** GPIO3 is ADC1 channel 3 on both chips and is not a strapping pin on either. ADC1 is also the portable choice: on the ESP32-C3, ADC2 is not usable for oneshot readings by default, and the ESP32-C6 has no ADC2.
- **The MOSFET must switch fully at 3.3 V.** The ESP32-C3 and ESP32-C6 drive their GPIOs at 3.3 V. Parts such as the IRLZ44N are often sold as "logic level", but their datasheets specify R<sub>DS(on)</sub> at 4 V or more; at 3.3 V they may only partly switch on and run hot. Choose a part with an R<sub>DS(on)</sub> figure at 2.5 V, like those in the table. Step 3 of the bring-up checks the result.
- **A 100 kΩ pull-down holds the gate low until the firmware runs.** After power-on or a reset from the EN pin, the GPIO stays an input until the firmware configures it. The pull-down from gate to ground keeps the pump off during that time. The 100 Ω series resistor limits the current into the gate capacitance when the pin switches.
- **The gate pin must have no pull-up at reset.** The internal pull resistors are roughly 45 kΩ. Against the 100 kΩ pull-down, an internal pull-up would lift the gate to about 2.3 V, enough to switch on a low-threshold MOSFET such as the AO3400A. GPIO10 has no pull at reset on either chip; GPIO6, for example, has a weak pull-up at reset on both. The ESP32-C6FH4 and ESP32-C6FH8, the variants with flash in the package, do not bring out GPIO10. On those, use GPIO0 or GPIO1 if no 32 kHz crystal is fitted.
- **The flyback diode sits across the pump**, with its cathode on the positive supply. When the MOSFET turns off, the inductance of the motor or coil keeps the current flowing for a moment. The diode carries that current back through the coil, instead of letting it become a voltage spike across the MOSFET.
- **The pump has its own supply.** The pump's start-up current then does not load the board's supply. Join the two grounds at one point, which keeps the motor current out of the board's ground path and the ADC readings steady. If the pump has to share the board's supply, fit a large electrolytic capacitor across that supply near the pump.

**Check the sensor before you trust it.** The common "v1.2" and "v2.0" capacitive sensor boards are copies of the DFRobot SEN0193 design, and the copies vary. The original uses a TLC555 timer, a CMOS part that runs from 2 V. Some clones use an NE555, which is specified from 4.5 V and is a poor fit for a 3.3 V supply. Ed Mallon's [teardown on the Cave Pearl Project](https://thecavepearlproject.org/2020/10/27/hacking-a-capacitive-soil-moisture-sensor-for-frequency-output/) describes two more defects: boards whose 1 MΩ output resistor is not connected to ground, which makes the output respond very slowly, and cut board edges that absorb water. Powered at 3.3 V, the boards in the teardown output "~3.0v dry to 1.5v fully submerged in water". Power yours from 3.3 V and read its output in air and in a glass of water. The two readings should be roughly that far apart and settle within a second or two. Seal the cut edges, and protect the electronics above the soil line with conformal coating or heat-shrink.

## Building and flashing

Clone the project, select the chip and open the configuration menu:

```sh
git clone https://github.com/arturpuig/esp32-failsafe-watering.git
cd esp32-failsafe-watering
idf.py set-target esp32c6    # or esp32c3
idf.py menuconfig            # "Watering controller" menu
idf.py build flash monitor
```

Since ESP-IDF v6.0, ESP-MQTT is a separate component in the ESP Component Registry. The project declares it in `main/idf_component.yml`, and the first build downloads it. All settings are under *Watering controller* in menuconfig:

| Setting | Default |
| --- | --- |
| Sensor, pump gate and fault-clear button | GPIO3, GPIO10 and GPIO9 (the BOOT button) |
| Start watering below / stop at | 35 % / 45 % |
| Pulse length / soak time | 5 s / 10 min |
| Pulses per cycle / expected rise after a full cycle | 4 / 3 % |
| Pump on-time budget per 24 h | 120 s |
| Invalid readings tolerated for | 10 s |
| Dry / wet calibration points | 2300 mV / 1500 mV (placeholders) |
| Plausible window | 1000 to 3100 mV (upper limit 2450 mV on the ESP32-C3) |
| Largest spread within one burst of samples | 150 mV |

## Reading the sensor

ESP-IDF's oneshot ADC driver reads the raw value, and the calibration API converts it to millivolts using factory calibration data stored in eFuses. Both chips use the curve-fitting calibration scheme, and `adc_oneshot_io_to_channel()` maps the GPIO to its channel, which lets the same code run on both.

The attenuation is `ADC_ATTEN_DB_12`; ESP-IDF v6 removed the old name, `ADC_ATTEN_DB_11`. At this attenuation the calibrated range differs between the two chips: up to 2500 mV on the ESP32-C3 and up to 3300 mV on the ESP32-C6. A sensor in air, at about 3.0 V, can read past the top of the ESP32-C3's range. The upper limit for a plausible reading therefore defaults to 2450 mV on the ESP32-C3, just under that range, and to 3100 mV on the ESP32-C6. On the ESP32-C3, that leaves room for a dry calibration point up to about 2.3 V. If your sensor reads higher in the driest soil you accept, use the ESP32-C6.

On the ESP32-C6, also check the chip revision in the boot log. Revisions v0.0 and v0.1 lose the four lowest bits of every ADC result (erratum ADC-1477). That gives steps of about 13 mV, under 2 % of the default calibration span, which this controller tolerates. Revision v0.2 fixed it.

Each reading is a burst of 16 samples taken one RTOS tick apart, 10 ms at the default tick rate of 100 Hz. A single noisy sample then cannot start or stop the pump. The firmware sorts the samples, takes the median as the reading and measures the spread between the third-lowest and the third-highest sample:

```c
qsort(mv, SAMPLES, sizeof(mv[0]), compare_int);
int median = (mv[SAMPLES / 2 - 1] + mv[SAMPLES / 2]) / 2;
int spread = mv[SAMPLES - 1 - TRIM] - mv[TRIM];

if (median < s_cal.min_mv || median > s_cal.max_mv ||
    spread > s_cal.max_spread_mv) {
    return INVALID;
}
/* The output voltage falls as the soil gets wetter. */
float span = (float)(s_cal.dry_mv - s_cal.wet_mv);
float pct = 100.0f * (float)(s_cal.dry_mv - median) / span;
pct = pct < 0.0f ? 0.0f : pct > 100.0f ? 100.0f : pct;
```

Readings beyond the calibration points are clamped to 0 % and 100 %. A sensor in air therefore reads 0 % as long as its voltage stays inside the plausible window.

`INVALID` is a reading with `valid` set to false and the moisture set to `NAN`. A `NAN` makes every `<`, `<=`, `>` and `>=` comparison false. Even if a validity check were missing, an invalid reading could never pass the `moisture_pct < dry_pct` test that starts a cycle. The logic also checks `valid` explicitly, in that test too; the `NAN` is a second line of defense.

A reading is invalid when the median falls outside a plausible window or when the samples disagree too much. A sensor that has lost power reads close to 0 V, below the window, as long as its 1 MΩ output resistor is connected to ground. A disconnected signal wire leaves the ADC input floating, which may or may not produce noisy or out-of-range values. Step 6 of the bring-up checks both faults on your hardware. Because these checks cannot catch every fault, the control logic also checks that watering raises the moisture.

**Calibration.** The two calibration points come from your own sensor and soil:

1. Switch off the pump supply, flash the project with the default values and open the serial monitor. The firmware logs a JSON line with the median (`mv`) and the spread (`spread_mv`) every minute and on every state change.
2. Let a pot of your mix dry out to the driest state you would accept, put the sensor in and note the median. This is the dry point, 0 %.
3. Water the same pot until water runs out of the bottom, wait ten minutes and note the median again. This is the wet point, 100 %.
4. Enter both values in menuconfig under *Watering controller → Sensor calibration*. Set the plausible window a few hundred millivolts beyond each point, and the maximum spread to about twice the largest spread you saw. On the ESP32-C3, keep the upper limit at or below 2450 mV, just under the 2500 mV top of the calibrated range. That leaves less margin: soil that dries out beyond the dry point may latch a `sensor` fault instead of being watered.
5. Run `idf.py erase-flash` before you flash the calibrated build. The calibration run may have latched a fault or used on-time, and both are stored in NVS, which a normal flash keeps.

## Pulse and soak

Water takes minutes to spread through the soil and reach the sensor. A pump that runs until the sensor reads wet keeps running through that delay. By the time the reading reaches the target, the pump has delivered far more water than the pot needed. The controller therefore waters in pulses: a few seconds of pumping, then a soak period with the pump off, then a new measurement.

{{< figure
    default=true
    src="img/pulse-soak.webp"
    alt="Chart of simulated soil moisture over 50 minutes. Pumping until the sensor reads 45 % runs the pump for 55 s and the moisture ends at 78 %. Three 5-second pulses, 10 minutes apart, end at 46 %."
    caption="Simulated with the pot model from the host tests: pumped water reaches the sensor over a few minutes, and the pump adds 0.8 % moisture per second."
    >}}

In the simulation, pumping until the sensor reads 45 % runs the pump for 55 s, and the moisture ends at 78 %. Pulse and soak stops after three pulses, 15 s of pumping in total, at 46 %.

A watering cycle starts when the moisture falls below the dry threshold (35 % by default) and ends when it reaches the wet threshold (45 %). The gap between the two thresholds is hysteresis: with a single threshold, readings that hover around it would start a new cycle after every small change. The defaults are starting points; adjust them after watching a few cycles with your plant.

{{< figure
    default=true
    src="img/state-machine.webp"
    alt="State machine. SOAKING waits one soak period after boot, after a cleared fault and after every pulse. It then moves to IDLE, or starts another pulse if the reading is valid, the soil is below the wet threshold and the cycle has pulses and budget left. IDLE starts a pulse when the moisture falls below the dry threshold. WATERING returns to SOAKING when the pulse time is reached or a reading is doubtful. Any state moves to FAULT on persistent invalid readings, no response or an exhausted budget, and holding the BOOT button for 3 s clears it."
    caption="The controller's four states. Every path back to the pump goes through a soak period."
    >}}

The state machine lives in `components/watering_logic`. On each tick it receives the current time and one reading, and returns whether the pump may run until the next tick. Because it has no hardware access, the same code runs in the firmware and in the host tests.

## The limits that keep the pump off

Most of the rules sit in the watering and soaking states:

```c
case WL_WATERING:
    /* Any doubtful reading ends the pulse at once. */
    if (!reading.valid ||
        now_ms - ctx->state_since_ms >= ctx->cfg.pulse_ms) {
        end_pulse(ctx, now_ms);
        return false;
    }
    return true;

case WL_SOAKING:
    if (now_ms - ctx->state_since_ms < ctx->cfg.soak_ms) {
        return false;
    }
    /* Hold-off after boot or a cleared fault. */
    if (ctx->pulses_in_cycle == 0) {
        return idle(ctx, now_ms, reading);
    }
    /* Wait for a valid reading; the grace period limits the wait. */
    if (!reading.valid) {
        return false;
    }
    /* Cycle complete. */
    if (reading.moisture_pct >= ctx->cfg.wet_pct) {
        return idle(ctx, now_ms, reading);
    }
    if (ctx->pulses_in_cycle >= ctx->cfg.max_pulses_per_cycle) {
        float rise = reading.moisture_pct - ctx->cycle_start_pct;
        if (rise < ctx->cfg.min_rise_pct) {
            /* Empty reservoir, kinked hose or sensor out of the soil. */
            return fail(ctx, WL_FAULT_NO_RESPONSE, now_ms);
        }
        /* The soil responds: a new cycle may start. */
        return idle(ctx, now_ms, reading);
    }
    return start_pulse(ctx, now_ms);
```

How the controller responds to each failure:

| Failure | What the controller sees | What it does |
| --- | --- | --- |
| Sensor wire loose, sensor unpowered | Median out of range or a large spread | Ends the current pulse at the next reading. Latches a `sensor` fault if it lasts longer than 10 s |
| Sensor pulled out of the soil | A steady, very dry reading | Runs one cycle, sees no rise and latches `no_response` |
| Empty reservoir, kinked hose, failed pump, hose outside the pot | Moisture does not rise | Same as above: one cycle, then `no_response` |
| Leaking pot | Moisture rises, falls again, cycles repeat | Latches `budget` before the pump exceeds its on-time for the window |
| Control task stuck | Nothing: the task has stopped | The hard-stop timer ends the pulse; the task watchdog switches the pump off and resets the chip |
| Brownout or power loss during a pulse | The chip restarts | The gate pull-down keeps the pump off; the first pulse waits one soak period |
| Repeated resets | The chip restarts again and again | The on-time is stored in NVS, so the budget still runs out |
| Wi-Fi or MQTT broker down | Nothing changes for watering | Status messages are dropped until the connection returns |

A sensor out of the soil reads dry in air, and that reading passes the range checks. The no-response check catches it after one cycle of pulses: 20 s of pumping in total with the default settings (four pulses of 5 s). On the ESP32-C3, a sensor in air may also read above the plausible window and latch a `sensor` fault sooner.

The on-time budget is 120 s of pump time per 24 hours by default, enough for six full cycles. Measure how much water one pulse delivers with your pump and tubing, then set the budget well above what the plant normally needs. Reaching it then means something is wrong, and the controller latches a `budget` fault until someone checks the setup.

The 24-hour window starts at boot and restarts after every 24 hours of uptime. The firmware has no wall-clock time and cannot tell how long a power cut lasted. Instead, the on-time used so far is stored in NVS and carried into the new window after a reboot. Without that, a controller that resets during every pulse would start each boot with a full budget. With the sensor out of the soil, it would also never complete the cycle that the no-response check needs. The cost is that a controller restarted more than once a day, by a timer socket for example, never gets a fresh window and eventually latches `budget`. Clearing a fault resets the on-time to zero and starts a new window.

## Safeguards around the state machine

The firmware around the state machine covers what the state machine cannot: the pin state before it runs, a stalled control task, and state across reboots.

**Pump output first.** `app_main()` sets the pump GPIO level to low and then configures the pin as an output, with no internal pull resistors, before it initializes NVS, the ADC or Wi-Fi. The firmware never calls `gpio_reset_pin()` on the gate pin, because that function enables the internal pull-up. Nor does it call `gpio_hold_en()`, which would keep the pin's state through a watchdog reset.

**A hard stop for every pulse.** When a pulse starts, the firmware arms a one-shot `esp_timer` that switches the pump off after the pulse length, independently of the control task:

```c
void pump_start(uint32_t max_ms)
{
    uint64_t timeout_us = (uint64_t)max_ms * 1000;
    esp_timer_stop(s_hard_stop); /* not running is fine */
    if (esp_timer_start_once(s_hard_stop, timeout_us) != ESP_OK) {
        return; /* no hard stop, no pulse */
    }
    gpio_set_level(s_gpio, 1);
}
```

The timer is armed before the GPIO goes high. If arming fails, the pulse never starts.

**The task watchdog.** The control task subscribes to the task watchdog and feeds it once per loop, and `sdkconfig.defaults` enables a panic on timeout: a stuck task resets the chip. A panic reboot resets the CPU but not the GPIO peripheral, and on its own would leave the gate pin high until `app_main()` runs again. The task watchdog calls `esp_task_wdt_isr_user_handler()` from its interrupt before the panic handler runs, and the project uses that hook to switch the pump off:

```c
void esp_task_wdt_isr_user_handler(void)
{
    if (s_gpio != GPIO_NUM_NC) {
        gpio_set_level(s_gpio, 0);
    }
}
```

Any other panic, such as a crash or a failed assert in any task (the control task included) or an interrupt watchdog timeout, reboots without the hook. The pump then stays on until the restarted firmware reaches `pump_init()`. Keep the default reboot on panic: halting, or waiting for a GDB connection, would leave the pump as it was.

**A hold-off after boot.** The state machine starts in the soaking state. The first pulse can only begin one soak period (10 minutes by default) after power-up. If the pump's inrush current causes a brownout, the chip resets and waits another soak period instead of switching the pump straight back on.

**State that survives a reboot.** A latched fault and the on-time used are written to NVS after each tick in which they change, before the pump switches on. A pulse counts in full as soon as it starts, so a pulse that ends in a reset still uses up its on-time. In normal use that is one NVS write per pulse. After a power cut, a controller with a latched fault comes back in the fault state. To clear it, hold the BOOT button (GPIO9 on both DevKits) for three seconds.

## Reporting over MQTT

If you set a Wi-Fi SSID and an MQTT broker URI in menuconfig, the controller publishes to three topics under a prefix (`garden/watering` by default):

- `status`: `online` while connected, retained. If the controller drops off the network, the broker publishes `offline` through the Last Will message once the keep-alive runs out, about three minutes with ESP-MQTT's default keep-alive of 120 s.
- `fault`: the current fault name, retained and refreshed with each state message. A dashboard shows it after a restart or a broker outage.
- `state`: a JSON line every minute and on each state change. An example, with illustrative values:

```json
{"state":"soaking","fault":"none","valid":true,"mv":1925,"spread_mv":12,"moisture":46.9,"pump_s_window":15,"reset":"power_on"}
```

When a reading is invalid, `valid` is `false` and `moisture` is `null`. The `reset` field gives the last reset reason; a controller that keeps restarting with `brownout` needs a stronger supply or better decoupling.

The control task never waits for the network. It copies each message into a FreeRTOS queue with a zero timeout and drops the message if the queue is full. A separate, lower-priority task passes the messages to `esp_mqtt_client_enqueue()`. That function only queues the message, but it first takes the client's lock. The MQTT task holds that lock while it connects or writes to the socket, for up to the 10 s network timeout, which is longer than the 5 s watchdog timeout. While the client is disconnected, messages are dropped.

## Testing the logic on a PC

The tests build with GCC or Clang, which provide the sanitizers they use, and need no board:

```console
$ make -C host_test
ok   waters a dry pot up to the wet threshold
ok   does not water inside the hysteresis band
ok   waits one soak period after boot
ok   unplugged sensor stops the pulse and latches a fault
ok   never starts a pulse on an invalid reading
ok   tolerates a short sensor glitch
ok   empty reservoir faults after one cycle
ok   sensor out of the soil faults
ok   leaking pot stops at the on-time budget
ok   on-time budget holds through a reboot loop
ok   restored fault survives a reboot until cleared
ok   randomized runs keep the safety invariants
all tests passed
```

The tests drive the state machine against a simple model of a pot: pumped water reaches the sensor gradually, the soil dries slowly and the readings carry noise. In the tests, an invalid reading carries a moisture of 0, the most dangerous value, so a missing validity check shows up as a pulse. Most scenarios inject one fault: an unplugged sensor in the middle of a pulse or just as a soak ends, an empty reservoir, a sensor lifted out of the soil, a pot that leaks. The reboot-loop scenario combines a sensor out of the soil with a reset late in every pulse.

The last test runs 300 randomized simulations of three days each, with random pot behavior. Loose wires, an empty reservoir and a sensor out of the soil appear at random times, and a latched fault is cleared after a random delay, usually with its cause fixed. After every run the test checks the rules that must always hold:

- no single pump run is longer than the pulse length;
- the logic ends every pulse on time by itself, without relying on the hard-stop timer;
- consecutive pulses are at least one soak period apart, and the first pulse waits one soak period after boot;
- no pulse starts on an invalid reading;
- the pump never runs in the fault state;
- the on-time within one budget window never exceeds the budget.

The second rule holds exactly in the simulation, where the ticks line up with the pulse length. On the device, the loop reads the time after a sensor burst, and the logic can notice the end of a pulse one tick late. The hard-stop timer switches the pump off on time in that case.

`host_test/mutation_check.py` removes or weakens each of 13 safety checks in the logic in turn, rebuilds the tests and confirms that at least one test fails for every change. The tests are compiled with AddressSanitizer and UndefinedBehaviorSanitizer.

Host tests only cover the decisions. They cannot tell you whether your MOSFET switches fully, how your sensor behaves in your soil or how much water a pulse delivers. The bring-up below checks those on the real hardware.

## Bringing it up on hardware

Work through these steps with the pump outlet in a bucket. For steps 3 to 8, set *Start watering below* to 99 % and *Stop watering at* to 100 %, and shorten the soak time to 1 minute. The controller then pulses whenever the reading is valid and below 99 %; keep the sensor in soil that is not saturated, not in the pot you have just watered for calibration. The soil cannot respond to water that goes into the bucket, so expect `no_response` and `budget` faults along the way. Clear them with the BOOT button whenever the next step needs a pulse.

1. **Power-up state.** With the pump supply on and the board's USB cable unplugged, confirm that the pump stays off. Then plug in the board and confirm that it stays off while flashing and booting.
2. **Calibration.** Follow the calibration steps above, with the pump supply off.
3. **MOSFET.** Set the pulse length to 30 s. During a pulse, measure the voltage between the MOSFET's drain and source. With the parts in the table and a pump that draws up to 1 A, it should stay below about 0.1 V, and the MOSFET should stay cool. A volt or more means that the MOSFET is only partly on.
4. **Hard stop and watchdog.** Keep the 30 s pulse, so that the hard stop cannot be what ends the pulse in the watchdog test. Enable the options under *Watering controller → Bring-up tests* one at a time. With *Never call pump_stop()*, every pulse must still end after 30 s. With *Stall the control task*, the pump must stop within 5 s of the pulse starting, and the boot log must show `task_wdt` as the reset reason. Turn both options off afterwards.
5. **Pulse volume.** Measure the water delivered by one 30 s pulse, and work out a pulse length that delivers a small fraction of what the pot needs. Keep 30 s until step 9.
6. **Sensor faults.** Disconnect the sensor's power wire during a pulse. The pump should stop within a second or two, and a `sensor` fault should appear after 10 s. Reconnect the power wire, clear the fault, wait for the next pulse and repeat with the signal wire. If the reading stays plausible with a wire disconnected, the range and spread checks cannot see that fault on your hardware, and only the no-response check limits it.
7. **No response.** Let a full cycle run. With the outlet in the bucket the soil cannot respond, and after four pulses the controller must latch `no_response`.
8. **Fault persistence.** Power-cycle the board while the fault is latched and check that it comes back in the fault state. Clear it with the BOOT button.
9. **Back to normal.** Restore the thresholds and the soak time, and set the pulse length you worked out in step 5. Run `idf.py erase-flash` before flashing, so that no on-time from the tests counts against the budget. Then move the outlet from the bucket to the plant.

## Where to take it next

- **A float switch or a flow sensor.** The no-response check detects a dry reservoir only after one cycle. A float switch in the reservoir detects it before the pump starts and protects pumps that must not run dry; a flow sensor on the outlet does the same for a kinked hose.
- **A second moisture sensor.** Two sensors that must roughly agree make a single failed sensor much easier to detect.
- **A hardware pump enable.** Gate the MOSFET drive through a retriggerable monostable that the control task keeps triggering from a second GPIO. After any crash or panic, the triggers stop and the monostable switches the pump off without help from the CPU.
- **Schedules.** SNTP time allows rules such as "no watering at night". Keep the safety timers on the monotonic `esp_timer` clock: a wrong time from the network can then delay watering but never extend a pulse.
- **Remote settings and updates.** Thresholds stored in NVS and changed over MQTT would avoid a rebuild for every adjustment. Over-the-air firmware updates need a partition table with two OTA app slots in place of the single-app table used here.
