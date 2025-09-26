---
title: "ESP-IDF Basics - Assign. 2.3 (Optional)"
date: "2025-08-05"
series: ["WS00A"]
series_order: 7
showAuthor: false
---

This assignment is optional and it should be done if there's some time left before the break.

Add another route to the HTTP server from the previous assignments:

- `POST /led/flash` &rarr; accepts JSON `{"periods": [int], "duty_cycles": [int]}` and for each element, calculates the on-time and off-time and drives the LED accordingly.

You need to first check that both periods and duty_cycles have the same length and contain positive number only. `duty_cycles` should contain numbers between 0 and 100.

Then, you can traverse the two arrays and calculate for each element at index `i` the LED `on_time` and `off_time` as follows:
```c
on_time[i] = duty_cycle[i]/100 * periods[i]
off_time[i] = periods[i]-on_time[i]
````

Now you can drive the LED according to the sequence:
```c
ON: on_time[1]
OFF: off_time[1]
ON: on_time[2]
OFF: off_time[2]
...
```

## Conclusion

If you managed to reach this point, it means you have good understanding of a basic REST API implementation. You can now move to the third lecture, detailing the management of external libraries and the use of the components found on the component registry.

### Next step
> Next lecture &rarr; [Lecture 3](../lecture-3/)
