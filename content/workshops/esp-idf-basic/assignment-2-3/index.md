---
title: "ESP-IDF Basics - Assign. 2.3 (Optional)"
date: "2025-08-05"
lastmod: "2026-01-20"
series: ["WS00A"]
series_order: 7
showAuthor: false
summary: "Add a new route to the HTTP server for a programmable blink (Optional)"
---

This assignment is optional. You can do it if you still have time before the break.

Add another route to the HTTP server from the previous assignments:

- `POST /led/flash` &rarr; accepts JSON `{"periods": [int], "duty_cycles": [int]}` and for each element, calculates the on-time and off-time and drives the LED accordingly.


{{< alert iconColor="#df8e1d" cardColor="#edcea3">}}
To test a POST request, you need an app that allows you to send structured HTTP requests. One example is [Teste](https://play.google.com/store/apps/details?id=apitester.org&hl=en-US&pli=1).
If you connect your computer to the module’s access point, you can instead use the Python script below.
{{< /alert >}}


<details>
<summary>Python script for POST request</summary>

<!-- * First install requests:
    ```console
    pip install requests
    ``` -->
* Create the following script `post_test.py`

```python
#!/usr/bin/env python3
"""
Send LED flashing parameters to an ESP device via HTTP POST.

Endpoint:
  POST http://192.168.4.1/led/flash
  Body: {"periods": [int, ...], "duty_cycles": [int, ...]}

Each pair (period, duty_cycle) defines one blink pattern.
"""

import requests
import json

# --- Configuration ---
ESP_IP = "192.168.4.1"  # Replace with your module’s IP address
ENDPOINT = f"http://{ESP_IP}/led/flash"

# Example data:
# periods in milliseconds, duty_cycles in percentage
payload = {
    "periods": [1000, 500, 2000],
    "duty_cycles": [50, 75, 25]
}

def send_led_flash(payload):
    """Send POST request to the ESP endpoint with LED flash parameters."""
    try:
        print(f"Sending POST to {ENDPOINT} ...")
        response = requests.post(ENDPOINT, json=payload, timeout=5)
        response.raise_for_status()
        print("✅ Request successful!")
        print("Response:", response.text)
    except requests.exceptions.RequestException as e:
        print("❌ Error communicating with the ESP:", e)

if __name__ == "__main__":
    print("Payload:", json.dumps(payload, indent=2))
    send_led_flash(payload)

```
* Open an ESP-IDF Terminal `ESP-IDF: Open ESP-IDF Terminal`
* Run the script `python post_test.py`

</details>

## Solution outline

* You need to check that both periods and duty_cycles have the same length and contain positive number only. `duty_cycles` should contain numbers between 0 and 100.

* You can traverse the two arrays and calculate for each element at index `i` the LED `on_time` and `off_time` as follows:
    ```c
    on_time[i] = duty_cycle[i]/100 * periods[i]
    off_time[i] = periods[i]-on_time[i]
    ````

* You can drive the LED according to the sequence:
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

> Or [go back to navigation menu](../#agenda)
