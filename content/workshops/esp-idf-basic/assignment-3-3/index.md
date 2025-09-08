---
title: "ESP-IDF Basics - Assign. 3.3"
date: "2025-08-05"
series: ["WS00A"]
series_order: 11
showAuthor: false
---

## Putting it all together


In this assignment, you will put combine all you have done together by adding the two routes below to your HTTP server.

For this assignment, you have to

1. Add the route `GET /enviroment/` which returns the `json` object

```json
{
   'temperature': float,
   'humidity': float
}
```

### Optional task

2. (Optional) add route `POST /startblink/` which flashes the led according to the temperature reading
   * Flashes the number of tens digit (e.g. 29 degrees &rarr; 2) with 400ms on and 200ms off
   * Pauses 1 sec
   * Flashes the number of units digit (e.g. 29 degrees &rarr; 2) with 400ms on and 200ms off


## Conclusion

You have create a basic IoT application, putting together sensor reading and HTTP connectivity, letting external services to interact with your application.

### Next step

> Next step &rarr; [Conclusion](../#conclusion)
