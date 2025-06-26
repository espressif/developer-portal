---
title: "Introduction to Zephyr OS Tracing and Profiling"
date: 2024-11-15T06:54:17+08:00
showAuthor: false
featureAsset: "featured-gauge.webp"
authors:
  - "raffael-rostagno"
tags: ["ESP32", "Tracing",  "Profiling","Zephyr"]
---

Embedded systems can be quite complex, depending on the architecture, application size and nature. Even for an experienced embedded developer, understanding the interplay of threads, interrupts, and multiple processes that run in a large application can be challenging. We humans are (mostly) visual by nature, and having the means to *visualize* what is happening in a given system can really open up possibilities. Without the right tools we are often in the dark, quite literally.

One category of tools interesting to learn about is tracing and profiling. *Tracing* is collecting software execution data - the sequence and timing of execution of functions, threads, ISRs - and logging it for future analysis, without interrupting or interfering (at best) in the application execution. *Profiling* aims to measure performance metrics such as execution time, CPU usage, and dynamic memory usage. With such tools it is possible to evaluate how well an embedded system is performing, understand if the hardware used is adequate for the application being run and debug eventual problems.

In this article we are going to do a brief introduction and show some basic examples of these resources as implemented in Zephyr RTOS. Later we’ll take a look at some of the features offered by Percepio's Tracealyzer, which is a third party solution that extends some of Zephyr's *tracing and profiling* native functionalities and has a front-end tool to analyze the data.


## Zephyr's tracing tool

In order to show how Zephyr's native tracing system works, the sample below can be flashed and run on a physical device such as an ESP32-C6. If you're new to Zephyr please check [[1]](https://docs.zephyrproject.org/latest/develop/getting_started/index.html).

`samples/subsys/tracing`


For this example, which uses the ESP32-C6's USB JTAG port to output the logged data, the following settings should be configured:

```text
CONFIG_TRACING=y
CONFIG_TRACING_CTF=y
CONFIG_TRACING_BACKEND_UART=y
CONFIG_TRACING_BUFFER_SIZE=4096
```

These settings activate the tracing feature, define the data stored format as CTF (Common Trace Format) and configure the output medium (UART). As UART was selected as the medium to transfer data from the device to the host (PC), an *overlay* config can inform Zephyr where to output data:

```text
/ {
    chosen {
        zephyr,tracing-uart = &usb_serial;
    };
};

&usb_serial {
    status = "okay";
};
```

To build the sample, use the following command:

```shell
west build -p -b esp32c6_devkitc samples/subsys/tracing/ -DCONF_FILE=prj_uart_ctf.conf
```

Once the sample is flashed and the USB cable is connected to the ESP32-C6's USB port, run Zephyr's Python script to connect to the serial port and store the acquired data in a log file.

```shell
python3 scripts/tracing/trace_capture_uart.py -d /dev/ttyACM0 -b 115200 -o ../tracing/trace_0
```

The option `-o` indicates the path and file name for the tracing data, so any path and name can be used. In this example we can use an arbitrary folder called “tracing” just outside Zephyr's main folder.

After some seconds of acquisition we can hit CTRL+C to stop recording and get back to the shell in the host PC.

The CTF tracing format requires data typing to be decoded, so the metadata (tracing format description) file needs to be present in the same folder:

```shell
cp subsys/tracing/ctf/tsdl/metadata ../tracing/
```

Finally, to parse the CTF data and show the actual trace:

```shell
babeltrace2 ../tracing/
```

The output is something like:

<a href="img/img001.webp" target="_blank">
    {{< figure
        default=true
        src="img/img001.webp"
        alt=""
        caption="Sample trace output"
    >}}
</a>

This log shows the execution order and timing of the traced objects, allowing us to visualize how the software is executing in the acquired interval. This gives the possibility of running statistics on how the CPU resources are used and helps to easily spot functions that are taking too long to execute, or are being executed at wrong moments, or more times than expected.

### Objects monitored

It is possible to control which kinds of objects are monitored. The following are currently supported [[2]](https://docs.zephyrproject.org/latest/services/tracing/index.html):

```c
struct k_timer *_track_list_k_timer;
struct k_mem_slab *_track_list_k_mem_slab;
struct k_sem *_track_list_k_sem;
struct k_mutex *_track_list_k_mutex;
struct k_stack *_track_list_k_stack;
struct k_msgq *_track_list_k_msgq;
struct k_mbox *_track_list_k_mbox;
struct k_pipe *_track_list_k_pipe;
struct k_queue *_track_list_k_queue;
struct k_event *_track_list_k_event;
```

Kconfig's menu *Tracing Configuration* will allow selecting which objects will be traced, with options like shown below:

```text
TRACING_SYSCALL=y/n
TRACING_ISR=y/n
TRACING_SEMAPHORE=y/n
TRACING_HEAP=y/n
TRACING_STACK=y/n
TRACING_PM=y/n
(...)
```

If a large amount of data is to be generated, this might be useful to limit tracing only to the objects of interest, both to save buffer and provide a cleaner data acquisition.

Another interesting feature is the possibility of defining user functions to be called at tracing events, such as *headers* shown below. In a debugging situation or when external equipment (e.g., oscilloscope or data logger) is used, it can be useful to add custom code to the callbacks to drive a GPIO, for instance, in order to sync external acquisition data with the log provided by the *tracing* subsystem.

<a href="img/img002.webp" target="_blank">
    {{< figure
        default=true
        src="img/img002.webp"
        alt=""
        caption="Trace user functions"
    >}}
</a>

The following macros [[3]](https://docs.zephyrproject.org/apidoc/latest/group__subsys__tracing__macros.html) are placed on Zephyr's subsystems code to track important functions of the operating system:

```c
SYS_PORT_TRACING_FUNC(type, func, …)
SYS_PORT_TRACING_FUNC_ENTER(type, func, …)
SYS_PORT_TRACING_FUNC_EXIT(type, func, ...)
```

This means that depending on the functionality being probed, the *tracing* subsystem might already have hooks that will acquire data by default, as can be seen in the example below:

```c
/* Called when data needs to be sent to network */
int net_send_data(struct net_pkt *pkt)
{
    int status;
    int ret;

    SYS_PORT_TRACING_FUNC_ENTER(net, send_data, pkt);

    (...)
}
```

Instrumenting application, however, is currently not supported without manually implementing some code inside the *tracing* subsystem. For the time being, there are 3rd party tools that support such feature, and a new tool is expected to be integrated to Zephyr in the future that might as well support it [[4]](https://github.com/zephyrproject-rtos/zephyr/issues/57373).

## Zephyr's profiling tool

The current profiling implementation monitors the function stack in order to allow examining the software execution at given intervals. To enable it, the following configs must be defined:

```text
CONFIG_PROFILING=y
CONFIG_PROFILING_PERF=y
CONFIG_PROFILING_PERF_BUFFER_SIZE=2048
CONFIG_THREAD_STACK_INFO=y
CONFIG_SMP=n
CONFIG_SHELL=y
CONFIG_FRAME_POINTER=y
```

Using these directives it is possible to obtain a log that can be processed by tools and yield a composed view of what the system is executing:

<a href="img/img003.webp" target="_blank">
    {{< figure
        default=true
        src="img/img003.webp"
        alt=""
        caption="Profiling sample graph"
    >}}
</a>

The graph above shows a timeline of the functions pushed onto the stack, including all sub-function calls. While monitoring the function stack can be useful for analyzing certain kinds of problems, we won’t discuss this feature in detail, as it offers limited functionality for now. As mentioned earlier, a new subsystem is being developed that may provide better functionality [[4]](https://github.com/zephyrproject-rtos/zephyr/issues/57373).

## Percepio's Tracealyzer

Zephyr offers support to third party tools that use the tracing subsystem and extend some of its functionalities in order to provide more resources. One of them is Percepio's Tracealyzer. To enable it, the following configs must be set:

```text
CONFIG_TRACING=y
CONFIG_PERCEPIO_TRACERECORDER=y
```

The directions to configure a streaming port or use a RAM buffer to store the logged data can be found in reference [[5]](https://docs.zephyrproject.org/latest/services/tracing/index.html#percepio-tracerecorder-and-stream-ports).

Tracealyzer offers a front-end tool to analyze and process the collected data, helping visualize how the system is behaving dynamically:

<a href="img/img004.webp" target="_blank">
    {{< figure
        default=true
        src="img/img004.webp"
        alt=""
        caption="Tracealyzer GUI"
    >}}
</a>

The process of instrumenting the code and selecting the right data to be acquired is analogous to using an oscilloscope or other kind of probe to evaluate hardware. One might need to place additional *hooks* (instrumentation for the tracing system to acquire data at a specific point) in the application code and change the base configuration to narrow data acquisition down to the areas of interest.

The GUI has tools to inspect the software execution sequence (as seen before with Zephyr's native tracing), charts to evaluate CPU load, and plots to display acquired data. Embedded in the tool are reports that facilitate the evaluation of task/thread performance to check:

- CPU Usage
- Execution times
- Response times
- Periodicity
- Separation
- Fragmentation

These statistics can help an experienced developer spot problems with any of the subsystems, as well as check timing and CPU load under any execution regime. Any anomaly can lead to a detailed investigation on what's hindering performance, including glitches that will only be visible when enough data is collected.

Another interesting capability of Tracealyzer is helping monitor heap utilization. The following graph shows memory allocation/de-allocation over time, and it is paired with the synchronized *trace view* right below it. This renders possible to see if memory is allocated and freed accordingly or if memory leaks might be happening.

<a href="img/img005.webp" target="_blank">
    {{< figure
        default=true
        src="img/img005.webp"
        alt=""
        caption="Memory heap trace example"
    >}}
</a>

If memory leaks were present, allocation would only increase with time instead of reaching a mean usage level.

Another use case can be analysis of the interaction between threads and shared resources, such as message queues. Spotting problems like producers-consumers can be difficult, specially if it's a glitch. If a synchronized signal can be added to the acquisition in order to point to the timestamp where the problem is happening - say, when a symptom is visible to the outside world - the acquired data can be very useful in solving the problem.

<a href="img/img006.webp" target="_blank">
    {{< figure
        default=true
        src="img/img006.webp"
        alt=""
        caption="Producer-consumer example"
    >}}
</a>

The examples below show custom channels added to capture application data:

<a href="img/img007.webp" target="_blank">
    {{< figure
        default=true
        src="img/img007.webp"
        alt=""
        caption="Custom channel state transitions"
    >}}
</a>

<a href="img/img008.webp" target="_blank">
    {{< figure
        default=true
        src="img/img008.webp"
        alt=""
        caption="Custom channel signals"
    >}}
</a>

## Final remarks

While these examples are generic and the amount of possibilities that *tracing* and *profiling* tools can offer is vast, this article just scratches the surface in sharing some insights on how powerful these tools can be.
Even though these examples may be more applicable to analyzing complex systems, it is well worth knowing them, as they may happen to be just the right tool for a specific problem. Besides that, even for use cases that require high reliability, using them with the intent of *profiling* the system in order to check how it behaves over time and certify its performance can be probably the best approach, as you'll have real data to back up the perception that it is performing as intended.

## Resources

[1] [Zephyr's Getting Started](https://docs.zephyrproject.org/latest/develop/getting_started/index.html)  
[2] [Zephyr's tracing subsystem](https://docs.zephyrproject.org/latest/services/tracing/index.html)  
[3] [Tracing utility macros](https://docs.zephyrproject.org/apidoc/latest/group__subsys__tracing__macros.html)  
[4] [Zephyr instrumentation subsystem (RFC)](https://github.com/zephyrproject-rtos/zephyr/issues/57373)  
[5] [Percepio TraceRecorder and Stream Ports](https://docs.zephyrproject.org/latest/services/tracing/index.html#percepio-tracerecorder-and-stream-ports)  
[The Microscope for Embedded Code: How Tracealyzer Revealed Our Bug](https://percepio.com/the-microscope-for-embedded-code-how-tracealyzer-revealed-our-bug/)  
[Efficient Firmware Development with Visual Trace Diagnostics](https://percepio.com/percepio-tracealyzer-efficient-firmware-development-with-visual-trace-diagnostics/)  
[Tracealyzer on Zephyr – Examples from AC6](https://percepio.com/tracealyzer-zephyr-examples-ac6/)  
[Percepio Tracealyzer](https://percepio.com/tracealyzer/)


