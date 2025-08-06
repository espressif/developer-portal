---
title: "ESP-IDF Adv. - Assign.  3.2"
date: "2025-08-05"
series: ["WS00B"]
series_order: 11
showAuthor: false
summary: "Explore core dump -- guided"
---

## Core dump

For this assignment, you need to get the [assignment_3_2_base](https://github.com/FBEZ-docs-and-templates/devrel-advanced-workshop-code/tree/main/assignment_3_2_base) project.

## Assignment steps

We will:

1. Enable the core dump in the menuconfig
2. Build and run the application
3. Analyze the core dump
4. Fix the bugs in the project
5. Build and run the application again


### Enable the core dump

Enable the core dump

* Open menuconfig: `> ESP-IDF: SDK Configuration Editor (menuconfig)`
* Set `Core Dump` &rarr; `Data destination` &rarr; `Flash`
* `> ESP-IDF: Build, Flash and Start a Monitor on Your Device`

### Build an run the application

Now wait the core fault to happen.

* When it happens, halt the execution (`CTRL + ]`)
* Create a new terminal `> ESP-IDF: Open ESP-IDF Terminal`
* run `idf.py coredump-info > coredump.txt`
* Open the file `coredump.txt`

### Analyze the core dump

Now look closely to the core dump file.

<details>
<summary>Click here if you couldn't generate coredump.txt</summary>

```bash
Executing action: coredump-info
Serial port /dev/cu.usbmodem1131101
Connecting...
Detecting chip type... ESP32-C3
===============================================================
==================== ESP32 CORE DUMP START ====================

Crashed task handle: 0x3fc9ff18, name: 'sys_evt', GDB name: 'process 1070202648'
Crashed task is not in the interrupt context

================== CURRENT THREAD REGISTERS ===================
ra             0x4200d822	0x4200d822 <is_alarm_set+20>
sp             0x3fc9fe50	0x3fc9fe50
gp             0x3fc94600	0x3fc94600 <country_info_24ghz+200>
tp             0x3fc9ff10	0x3fc9ff10
t0             0x4005890e	1074104590
t1             0x90000000	-1879048192
t2             0xffffffff	-1
fp             0x0	0x0
s1             0x8b7f7a	9142138
a0             0x8b7f7a	9142138
a1             0x0	0
a2             0x8b7f7a0	146274208
a3             0x0	0
a4             0x4ddf	19935
a5             0x4c4b3f	4999999
a6             0x60023000	1610756096
a7             0xa	10
s2             0x0	0
s3             0x0	0
s4             0xffffffff	-1
s5             0x0	0
s6             0xffffffff	-1
s7             0x0	0
s8             0x0	0
s9             0x0	0
s10            0x0	0
s11            0x0	0
t3             0x0	0
t4             0xfe42	65090
t5             0x0	0
t6             0x0	0
pc             0x4200d840	0x4200d840 <is_alarm_set+50>

==================== CURRENT THREAD STACK =====================
#0  is_alarm_set (alarm=0x0) at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/components/alarm/alarm.c:40
#1  0x4200d48c in alarm_event_handler (handler_arg=<optimized out>, base=<optimized out>, id=<optimized out>, event_data=<optimized out>) at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/main/app_main.c:66
#2  0x420b1944 in handler_execute (loop=loop@entry=0x3fc9f13c, handler=<optimized out>, post=<error reading variable: Cannot access memory at address 0x4c4b3f>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:136
#3  0x420b2290 in esp_event_loop_run (event_loop=event_loop@entry=0x3fc9f13c, ticks_to_run=ticks_to_run@entry=4294967295) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:696
#4  0x420b2388 in esp_event_loop_run_task (args=0x3fc9f13c, args@entry=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:106
#5  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

======================== THREADS INFO =========================
  Id   Target Id          Frame
* 1    process 1070202648 is_alarm_set (alarm=0x0) at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/components/alarm/alarm.c:40
  2    process 1070198548 0x403851d4 in esp_cpu_wait_for_intr () at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_hw_support/cpu.c:64
  3    process 1070209148 0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
  4    process 1070196668 0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
  5    process 1070253776 0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
  6    process 1070222780 0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
  7    process 1070191796 0x40387998 in vPortClearInterruptMaskFromISR (prev_int_level=1) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:515


       TCB             NAME PRIO C/B  STACK USED/FREE
---------- ---------------- -------- ----------------
0x3fc9ff18          sys_evt    20/20         352/2460
0x3fc9ef14             IDLE      0/0         208/1312
0x3fca187c              tiT    18/18         336/3240
0x3fc9e7bc             main      1/1         336/3752
0x3fcac6d0        mqtt_task      5/5         768/5372
0x3fca4dbc             wifi    23/23         336/6312
0x3fc9d4b4        esp_timer    22/22         224/3856

==================== THREAD 1 (TCB: 0x3fc9ff18, name: 'sys_evt') =====================
#0  is_alarm_set (alarm=0x0) at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/components/alarm/alarm.c:40
#1  0x4200d48c in alarm_event_handler (handler_arg=<optimized out>, base=<optimized out>, id=<optimized out>, event_data=<optimized out>) at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/main/app_main.c:66
#2  0x420b1944 in handler_execute (loop=loop@entry=0x3fc9f13c, handler=<optimized out>, post=<error reading variable: Cannot access memory at address 0x4c4b3f>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:136
#3  0x420b2290 in esp_event_loop_run (event_loop=event_loop@entry=0x3fc9f13c, ticks_to_run=ticks_to_run@entry=4294967295) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:696
#4  0x420b2388 in esp_event_loop_run_task (args=0x3fc9f13c, args@entry=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:106
#5  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 2 (TCB: 0x3fc9ef14, name: 'IDLE') =====================
#0  0x403851d4 in esp_cpu_wait_for_intr () at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_hw_support/cpu.c:64
#1  0x42015ce8 in esp_vApplicationIdleHook () at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/freertos_hooks.c:58
#2  0x4038859c in prvIdleTask (pvParameters=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/tasks.c:4341
#3  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 3 (TCB: 0x3fca187c, name: 'tiT') =====================
#0  0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
#1  0x40387a5c in vPortYield () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:638
#2  0x40387450 in xQueueReceive (xQueue=0x3fca099c, pvBuffer=pvBuffer@entry=0x3fca182c, xTicksToWait=<optimized out>, xTicksToWait@entry=6) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/queue.c:1659
#3  0x42086ae8 in sys_arch_mbox_fetch (mbox=mbox@entry=0x3fc9b7c0 <tcpip_mbox>, msg=msg@entry=0x3fca182c, timeout=60) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/port/freertos/sys_arch.c:313
#4  0x420710ea in tcpip_timeouts_mbox_fetch (mbox=mbox@entry=0x3fc9b7c0 <tcpip_mbox>, msg=msg@entry=0x3fca182c) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/lwip/src/api/tcpip.c:104
#5  0x420711dc in tcpip_thread (arg=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/lwip/src/api/tcpip.c:142
#6  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 4 (TCB: 0x3fc9e7bc, name: 'main') =====================
#0  0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
#1  0x40387a5c in vPortYield () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:638
#2  0x40388d04 in vTaskDelay (xTicksToDelay=xTicksToDelay@entry=100) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/tasks.c:1588
#3  0x4200d7e8 in app_main () at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/main/app_main.c:136
#4  0x420b420e in main_task (args=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/app_startup.c:208
#5  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 5 (TCB: 0x3fcac6d0, name: 'mqtt_task') =====================
#0  0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
#1  0x40387a5c in vPortYield () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:638
#2  0x403875bc in xQueueSemaphoreTake (xQueue=0x3fcac8e0, xTicksToWait=<optimized out>, xTicksToWait@entry=4294967295) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/queue.c:1901
#3  0x42086910 in sys_arch_sem_wait (sem=sem@entry=0x3fcac8d0, timeout=timeout@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/port/freertos/sys_arch.c:165
#4  0x420713d4 in tcpip_send_msg_wait_sem (fn=<optimized out>, apimsg=apimsg@entry=0x3fcae33c, sem=0x3fcac8d0) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/lwip/src/api/tcpip.c:461
#5  0x42088840 in netconn_gethostbyname_addrtype (name=name@entry=0x3fcac8b8 <error: Cannot access memory at address 0x3fcac8b8>, addr=addr@entry=0x3fcae3a8, dns_addrtype=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/lwip/src/api/api_lib.c:1333
#6  0x4206de2a in lwip_getaddrinfo (nodename=nodename@entry=0x3fcac8b8 <error: Cannot access memory at address 0x3fcac8b8>, servname=servname@entry=0x0, hints=hints@entry=0x3fcae3fc, res=res@entry=0x3fcae41c) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/lwip/src/api/netdb.c:495
#7  0x42021468 in getaddrinfo (nodename=0x3fcac8b8 <error: Cannot access memory at address 0x3fcac8b8>, servname=0x0, hints=0x3fcae3fc, res=0x3fcae41c) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/include/lwip/netdb.h:23
#8  esp_tls_hostname_to_fd (host=<optimized out>, hostlen=<optimized out>, port=1883, addr_family=<optimized out>, address=address@entry=0x3fcae464, fd=fd@entry=0x3fcae460) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp-tls/esp_tls.c:210
#9  0x420218c4 in tcp_connect (host=host@entry=0x3fca24cc <error: Cannot access memory at address 0x3fca24cc>, hostlen=<optimized out>, port=port@entry=1883, cfg=cfg@entry=0x3fcac83c, error_handle=error_handle@entry=0x3fcac824, sockfd=sockfd@entry=0x3fcac8a0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp-tls/esp_tls.c:359
#10 0x42021ebc in esp_tls_plain_tcp_connect (host=host@entry=0x3fca24cc <error: Cannot access memory at address 0x3fca24cc>, hostlen=<optimized out>, port=port@entry=1883, cfg=cfg@entry=0x3fcac83c, error_handle=error_handle@entry=0x3fcac824, sockfd=sockfd@entry=0x3fcac8a0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp-tls/esp_tls.c:533
#11 0x42023e06 in tcp_connect (t=<optimized out>, host=0x3fca24cc <error: Cannot access memory at address 0x3fca24cc>, port=1883, timeout_ms=10000) at /Users/francesco/esp/v5.4.2/esp-idf/components/tcp_transport/transport_ssl.c:148
#12 0x42023210 in esp_transport_connect (t=<optimized out>, host=<optimized out>, port=<optimized out>, timeout_ms=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/tcp_transport/transport.c:123
#13 0x4200f628 in esp_mqtt_task (pv=0x3fca1a28, pv@entry=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/mqtt/esp-mqtt/mqtt_client.c:1620
#14 0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 6 (TCB: 0x3fca4dbc, name: 'wifi') =====================
#0  0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
#1  0x40387a5c in vPortYield () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:638
#2  0x40387450 in xQueueReceive (xQueue=0x3fca2c9c, pvBuffer=0x3fca4d48, xTicksToWait=<optimized out>, xTicksToWait@entry=4294967295) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/queue.c:1659
#3  0x420b3d64 in queue_recv_wrapper (queue=<optimized out>, item=<optimized out>, block_time_tick=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_wifi/esp32c3/esp_adapter.c:238
#4  0x400407be in ppTask ()
#5  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 7 (TCB: 0x3fc9d4b4, name: 'esp_timer') =====================
#0  0x40387998 in vPortClearInterruptMaskFromISR (prev_int_level=1) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:515
#1  0x40387a28 in vPortExitCritical () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:624
#2  0x40389774 in ulTaskGenericNotifyTake (uxIndexToWait=uxIndexToWait@entry=0, xClearCountOnExit=xClearCountOnExit@entry=1, xTicksToWait=xTicksToWait@entry=4294967295) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/tasks.c:5759
#3  0x42017e9a in timer_task (arg=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_timer/src/esp_timer.c:459
#4  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255


======================= ALL MEMORY REGIONS ========================
Name   Address   Size   Attrs
.rtc.text 0x50000000 0x0 RW
.rtc.force_fast 0x50000000 0x1c RW A
.rtc_noinit 0x5000001c 0x0 RW
.rtc.force_slow 0x5000001c 0x0 RW
.iram0.text 0x40380000 0x13d0a R XA
.dram0.data 0x3fc93e00 0x2ed8 RW A
.flash.text 0x42000020 0xb4fd8 R XA
.flash.appdesc 0x3c0c0020 0x100 R  A
.flash.rodata 0x3c0c0120 0x1ff3c RW A
.eh_frame_hdr 0x3c0e005c 0x0 RW
.eh_frame 0x3c0e005c 0x0 RW
.flash.tdata 0x3c0e005c 0x0 RW
.iram0.data 0x40393e00 0x0 RW
.iram0.bss 0x40393e00 0x0 RW
.dram0.heap_start 0x3fc9b8e0 0x0 RW
.coredump.tasks.data 0x3fc9ff18 0x150 RW
.coredump.tasks.data 0x3fc9fdb0 0x160 RW
.coredump.tasks.data 0x3fc9ef14 0x150 RW
.coredump.tasks.data 0x3fc9ee30 0xd0 RW
.coredump.tasks.data 0x3fca187c 0x150 RW
.coredump.tasks.data 0x3fca1720 0x150 RW
.coredump.tasks.data 0x3fc9e7bc 0x150 RW
.coredump.tasks.data 0x3fc9e660 0x150 RW
.coredump.tasks.data 0x3fcac6d0 0x150 RW
.coredump.tasks.data 0x3fcae240 0x300 RW
.coredump.tasks.data 0x3fca4dbc 0x150 RW
.coredump.tasks.data 0x3fca4c60 0x150 RW
.coredump.tasks.data 0x3fc9d4b4 0x150 RW
.coredump.tasks.data 0x3fc9d3c0 0xe0 RW

===================== ESP32 CORE DUMP END =====================
===============================================================
Done!

```
</details>

#### Identify the crashed task and context

The core dump starts with:

```
Crashed task handle: 0x3fc9ff18, name: 'sys_evt'
Crashed task is not in the interrupt context
```
From which, we can conclude the following:

1. The crash happened in the FreeRTOS task called **`sys_evt`**.
2. The crash did **not** happen during an interrupt, so it's a normal task context crash.

#### Look at the program counter (PC) and stack trace

The register dump shows:

```
pc             0x4200d840	0x4200d840 <is_alarm_set+50>
ra             0x4200d822	0x4200d822 <is_alarm_set+20>
sp             0x3fc9fe50
```

It means that:

1. The program counter (PC) is at address `0x4200d840`, inside the function `is_alarm_set`, specifically at offset +50 bytes.
2. The return address (`ra`) is also inside `is_alarm_set`, which means the crash happened __inside that function__.

#### Examine the stack trace

Stack trace (reversed call order):

```
#0  is_alarm_set (alarm=0x0) at alarm.c:40
#1  alarm_event_handler at app_main.c:66
#2  handler_execute (esp_event.c:136)
#3  esp_event_loop_run (esp_event.c:696)
#4  esp_event_loop_run_task (esp_event.c:106)
#5  vPortTaskWrapper (port.c:255)
```

1. The crash originated from `is_alarm_set` being called from `alarm_event_handler`.
2. This handler is called by the ESP-IDF event loop (`esp_event_loop_run`).

#### Focus on function arguments

Look at `is_alarm_set` arguments:

```
#0  is_alarm_set (alarm=0x0) at alarm.c:40
```

* The argument `alarm` is `0x0` (NULL pointer) (!)

#### Diagnose the crash reason

The crash happened inside `is_alarm_set` with a NULL pointer argument. Usually, this means:

* `is_alarm_set` dereferenced `alarm` without checking if it was NULL.
* Since `alarm` is NULL, accessing its fields caused an invalid memory access, crashing the program.

#### Check the source

The crash line is `alarm.c:40`. If you look at that line in your source:

```c
return alarm->last_state;
```

* Dereferencing `alarm` without NULL check causes a fault if `alarm == NULL`.

If we look a couple of lines above, we spot

```c
alarm = NULL;
```

which is likely our bug.


### Build and run the application again

Remove the line and the useless `else` block, to get the following `is_alarm_set` function.

```c
bool is_alarm_set(alarm_t *alarm)
{
    int64_t now_us = esp_timer_get_time();
    int64_t elapsed_us = now_us - alarm->last_check_time_us;

    if (elapsed_us >= CONFIG_ALARM_REFRESH_INTERVAL_MS * 1000) {
        uint32_t rand_val = esp_random() % 100;
        alarm->last_state = rand_val < CONFIG_ALARM_THRESHOLD_PERCENT;
        alarm->last_check_time_us = now_us;
    }
    return alarm->last_state;
}

```

Rebuild and run the application

* `> ESP-IDF: Build, Flash and Start a Monitor`


Another crash!

If you still have time, try to solve it by moving to [assignment 3.3](../assignment-3-3/).

If you don't, don't worry: all the following assignments will be based on the [assignment 2.1](../assignment-2-1/) code.


## Conclusion

In this assignment, we learnt how to create a core dump and how to analyze it to understand the reason of a core crash.
Core dump analysis is a very strong tool to debug your application.

If you still have time, try [assignment 3.3](../assignment-3-3/)

Otherwise
> Next step: [Lecture 4](../lecture-4/)
