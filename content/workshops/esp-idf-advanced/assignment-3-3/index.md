---
title: "ESP-IDF Adv. - Assign.  3.3"
date: "2025-08-05"
series: ["WS00B"]
series_order: 12
showAuthor: false
summary: "Explore core dump - DIY"
---

If you still have time, try to find the other bug in the code by using the info provided by the core dump again.

## Solution steps outline

Create the core dump file as you did in the previous assignment.
* Wait for the crash to happen
* Stop monitor (`CTRL + ]`)
* Run `idf.py coredump-info > coredump.txt`
* Open the file `coredump.txt`


<details>
<summary>Expand the second core dump</summary>

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
ra             0x4200dc68	0x4200dc68 <temperature_sensor_read_celsius+10>
sp             0x3fc9fe40	0x3fc9fe40
gp             0x3fc94600	0x3fc94600 <country_info_24ghz+200>
tp             0x3fc9ff10	0x3fc9ff10
t0             0x4005890e	1074104590
t1             0x0	0
t2             0xffffffff	-1
fp             0x0	0x0
s1             0x3fc9f13c	1070199100
a0             0x3fcacc14	1070255124
a1             0x3fc9fe5c	1070202460
a2             0x0	0
a3             0x0	0
a4             0x3fcacb34	1070254900
a5             0x0	0
a6             0x4200d4c2	1107350722
a7             0x9800000	159383552
s2             0x0	0
s3             0x0	0
s4             0xffffffff	-1
s5             0x0	0
s6             0xffffffff	-1
s7             0x3fcacb44	1070254916
s8             0x0	0
s9             0x0	0
s10            0x0	0
s11            0x0	0
t3             0x0	0
t4             0x604f	24655
t5             0x0	0
t6             0x0	0
pc             0x0	0x0

==================== CURRENT THREAD STACK =====================
#0  0x00000000 in ?? ()
#1  0x4200dc68 in temperature_sensor_read_celsius (sensor=<optimized out>, temperature=temperature@entry=0x3fc9fe5c) at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/components/temperature_sensor/temperature_sensor.c:150
#2  0x4200d4d4 in temp_event_handler (handler_arg=<optimized out>, base=<optimized out>, id=<optimized out>, event_data=<optimized out>) at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/main/app_main.c:50
#3  0x420b1942 in handler_execute (loop=loop@entry=0x3fc9f13c, handler=<optimized out>, post=<error reading variable: Cannot access memory at address 0x0>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:136
#4  0x420b228e in esp_event_loop_run (event_loop=event_loop@entry=0x3fc9f13c, ticks_to_run=ticks_to_run@entry=4294967295) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:696
#5  0x420b2386 in esp_event_loop_run_task (args=0x3fc9f13c, args@entry=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:106
#6  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

======================== THREADS INFO =========================
  Id   Target Id          Frame
* 1    process 1070202648 0x00000000 in ?? ()
  2    process 1070198548 0x403851d4 in esp_cpu_wait_for_intr () at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_hw_support/cpu.c:64
  3    process 1070254080 0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
  4    process 1070196668 0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
  5    process 1070209148 0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
  6    process 1070222780 0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
  7    process 1070191796 0x40387998 in vPortClearInterruptMaskFromISR (prev_int_level=1) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:515


       TCB             NAME PRIO C/B  STACK USED/FREE
---------- ---------------- -------- ----------------
0x3fc9ff18          sys_evt    20/20         352/2460
0x3fc9ef14             IDLE      0/0         208/1312
0x3fcac800        mqtt_task      5/5         624/5516
0x3fc9e7bc             main      1/1         336/3752
0x3fca187c              tiT    18/18         336/3240
0x3fca4dbc             wifi    23/23         336/6312
0x3fc9d4b4        esp_timer    22/22         224/3856

==================== THREAD 1 (TCB: 0x3fc9ff18, name: 'sys_evt') =====================
#0  0x00000000 in ?? ()
#1  0x4200dc68 in temperature_sensor_read_celsius (sensor=<optimized out>, temperature=temperature@entry=0x3fc9fe5c) at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/components/temperature_sensor/temperature_sensor.c:150
#2  0x4200d4d4 in temp_event_handler (handler_arg=<optimized out>, base=<optimized out>, id=<optimized out>, event_data=<optimized out>) at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/main/app_main.c:50
#3  0x420b1942 in handler_execute (loop=loop@entry=0x3fc9f13c, handler=<optimized out>, post=<error reading variable: Cannot access memory at address 0x0>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:136
#4  0x420b228e in esp_event_loop_run (event_loop=event_loop@entry=0x3fc9f13c, ticks_to_run=ticks_to_run@entry=4294967295) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:696
#5  0x420b2386 in esp_event_loop_run_task (args=0x3fc9f13c, args@entry=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_event/esp_event.c:106
#6  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 2 (TCB: 0x3fc9ef14, name: 'IDLE') =====================
#0  0x403851d4 in esp_cpu_wait_for_intr () at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_hw_support/cpu.c:64
#1  0x42015ce6 in esp_vApplicationIdleHook () at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/freertos_hooks.c:58
#2  0x4038859c in prvIdleTask (pvParameters=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/tasks.c:4341
#3  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 3 (TCB: 0x3fcac800, name: 'mqtt_task') =====================
#0  0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
#1  0x40387a5c in vPortYield () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:638
#2  0x403875bc in xQueueSemaphoreTake (xQueue=0x3fcaca20, xTicksToWait=<optimized out>, xTicksToWait@entry=101) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/queue.c:1901
#3  0x4208695e in sys_arch_sem_wait (sem=<optimized out>, timeout=1000) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/port/freertos/sys_arch.c:175
#4  0x42070b2a in lwip_select (maxfdp1=55, readset=0x3fcae488, writeset=0x0, exceptset=0x3fcae480, timeout=0x3fcae490) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/lwip/src/api/sockets.c:2142
#5  0x4200abe8 in esp_vfs_select (nfds=nfds@entry=55, readfds=readfds@entry=0x3fcae488, writefds=writefds@entry=0x0, errorfds=errorfds@entry=0x3fcae480, timeout=0x3fcae490) at /Users/francesco/esp/v5.4.2/esp-idf/components/vfs/vfs.c:1570
#6  0x42023706 in base_poll_read (t=0x3fcac734, timeout_ms=1000) at /Users/francesco/esp/v5.4.2/esp-idf/components/tcp_transport/transport_ssl.c:176
#7  0x4202325c in esp_transport_poll_read (t=<optimized out>, timeout_ms=timeout_ms@entry=1000) at /Users/francesco/esp/v5.4.2/esp-idf/components/tcp_transport/transport.c:156
#8  0x4200f9f8 in esp_mqtt_task (pv=0x3fca1a28, pv@entry=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/mqtt/esp-mqtt/mqtt_client.c:1736
#9  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 4 (TCB: 0x3fc9e7bc, name: 'main') =====================
#0  0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
#1  0x40387a5c in vPortYield () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:638
#2  0x40388d04 in vTaskDelay (xTicksToDelay=xTicksToDelay@entry=100) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/tasks.c:1588
#3  0x4200d7e8 in app_main () at /Users/francesco/Documents/articles/devrel-advanced-workshop-code/assignment_3_2/main/app_main.c:136
#4  0x420b420c in main_task (args=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/app_startup.c:208
#5  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 5 (TCB: 0x3fca187c, name: 'tiT') =====================
#0  0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
#1  0x40387a5c in vPortYield () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:638
#2  0x40387450 in xQueueReceive (xQueue=0x3fca099c, pvBuffer=pvBuffer@entry=0x3fca182c, xTicksToWait=<optimized out>, xTicksToWait@entry=1) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/queue.c:1659
#3  0x42086ae6 in sys_arch_mbox_fetch (mbox=mbox@entry=0x3fc9b7c0 <tcpip_mbox>, msg=msg@entry=0x3fca182c, timeout=10) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/port/freertos/sys_arch.c:313
#4  0x420710e8 in tcpip_timeouts_mbox_fetch (mbox=mbox@entry=0x3fc9b7c0 <tcpip_mbox>, msg=msg@entry=0x3fca182c) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/lwip/src/api/tcpip.c:104
#5  0x420711da in tcpip_thread (arg=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/lwip/lwip/src/api/tcpip.c:142
#6  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 6 (TCB: 0x3fca4dbc, name: 'wifi') =====================
#0  0x4038345e in esp_crosscore_int_send_yield (core_id=core_id@entry=0) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_system/crosscore_int.c:121
#1  0x40387a5c in vPortYield () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:638
#2  0x40387450 in xQueueReceive (xQueue=0x3fca2c9c, pvBuffer=0x3fca4d48, xTicksToWait=<optimized out>, xTicksToWait@entry=4294967295) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/queue.c:1659
#3  0x420b3d62 in queue_recv_wrapper (queue=<optimized out>, item=<optimized out>, block_time_tick=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_wifi/esp32c3/esp_adapter.c:238
#4  0x400407be in ppTask ()
#5  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255

==================== THREAD 7 (TCB: 0x3fc9d4b4, name: 'esp_timer') =====================
#0  0x40387998 in vPortClearInterruptMaskFromISR (prev_int_level=1) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:515
#1  0x40387a28 in vPortExitCritical () at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:624
#2  0x40389774 in ulTaskGenericNotifyTake (uxIndexToWait=uxIndexToWait@entry=0, xClearCountOnExit=xClearCountOnExit@entry=1, xTicksToWait=xTicksToWait@entry=4294967295) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/tasks.c:5759
#3  0x42017e98 in timer_task (arg=<error reading variable: value has been optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/esp_timer/src/esp_timer.c:459
#4  0x403877cc in vPortTaskWrapper (pxCode=<optimized out>, pvParameters=<optimized out>) at /Users/francesco/esp/v5.4.2/esp-idf/components/freertos/FreeRTOS-Kernel/portable/riscv/port.c:255


======================= ALL MEMORY REGIONS ========================
Name   Address   Size   Attrs
.rtc.text 0x50000000 0x0 RW
.rtc.force_fast 0x50000000 0x1c RW A
.rtc_noinit 0x5000001c 0x0 RW
.rtc.force_slow 0x5000001c 0x0 RW
.iram0.text 0x40380000 0x13d0a R XA
.dram0.data 0x3fc93e00 0x2ed8 RW A
.flash.text 0x42000020 0xb4fd6 R XA
.flash.appdesc 0x3c0c0020 0x100 R  A
.flash.rodata 0x3c0c0120 0x1ff3c RW A
.eh_frame_hdr 0x3c0e005c 0x0 RW
.eh_frame 0x3c0e005c 0x0 RW
.flash.tdata 0x3c0e005c 0x0 RW
.iram0.data 0x40393e00 0x0 RW
.iram0.bss 0x40393e00 0x0 RW
.dram0.heap_start 0x3fc9b8e0 0x0 RW
.coredump.tasks.data 0x3fc9ff18 0x150 RW
.coredump.tasks.data 0x3fc9fda0 0x170 RW
.coredump.tasks.data 0x3fc9ef14 0x150 RW
.coredump.tasks.data 0x3fc9ee30 0xd0 RW
.coredump.tasks.data 0x3fcac800 0x150 RW
.coredump.tasks.data 0x3fcae2c0 0x270 RW
.coredump.tasks.data 0x3fc9e7bc 0x150 RW
.coredump.tasks.data 0x3fc9e660 0x150 RW
.coredump.tasks.data 0x3fca187c 0x150 RW
.coredump.tasks.data 0x3fca1720 0x150 RW
.coredump.tasks.data 0x3fca4dbc 0x150 RW
.coredump.tasks.data 0x3fca4c60 0x150 RW
.coredump.tasks.data 0x3fc9d4b4 0x150 RW
.coredump.tasks.data 0x3fc9d3c0 0xe0 RW

===================== ESP32 CORE DUMP END =====================
===============================================================
Done!
```
</details>


Good bug hunting!

<details>
<summary>Show solution</summary>

The error is caused by line 128 in `app_main.c`
```c
free(sensor);
```

It deletes the sensor object and the temperature reading is using an invalid pointer.
</details>

> Next step: [Lecture 4](../lecture-4/)

> Or [go back to navigation menu](../#agenda)