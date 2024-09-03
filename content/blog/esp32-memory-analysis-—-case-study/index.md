---
title: ESP32 Memory Analysis — Case Study
date: 2020-06-01
showAuthor: false
authors: 
  - mahavir-jain
---
[Mahavir Jain](https://medium.com/@mahavirj?source=post_page-----eacc75fe5431--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fe94f74442319&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fesp32-memory-analysis-case-study-eacc75fe5431&user=Mahavir+Jain&userId=e94f74442319&source=post_page-e94f74442319----eacc75fe5431---------------------post_header-----------)

--

Memory has significant impact on silicon cost as well as die size, hence from hardware perspective having optimal size is important and from software perspective being able to utilise it to fullest is crucial.

In this post we will discuss some upcoming features and commonly available configuration options (knobs) in ESP-IDF to allow __end__  __application__  to utilise various internal memory regions in most optimal way.

## Important Notes

- We will focus on single core mode of ESP32 here, as that is where more number of memory optimisation features are applicable.
- We will be considering typical IoT use-cases here where gaining memory at the cost of performance is acceptable criteria.
- We will take typical cloud application as case study which requires TLS connection with mutual authentication support.
- ESP-IDF feature branch used here can be found at, [https://github.com/mahavirj/esp-idf/tree/feature/memory_optimizations](https://github.com/mahavirj/esp-idf/tree/feature/memory_optimizations)

## ESP32: Internal Memory Breakup

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*GX1WDpWbR4mdhsF5N1VZdg.png)

- As can be seen from above memory layout, there are various memory regions internal to silicon and of different clock speed.
- For single core use-cases, we get additional 32K of instruction memory, which otherwise would have acted as cache for APP CPU core.
- Instruction RAM access should always be 32-bit address and size aligned.
- For end application business logic, it is always desirable to have more DRAM, which is fastest memory without any access restrictions.

## Case Study — AWS IoT Sample Application

- We will be taking subscribe_publish example from ESP-AWS-IoT [__here__ ](https://github.com/espressif/esp-aws-iot/tree/master/examples/subscribe_publish) as case study to analyse memory utilisation.
- ESP-IDF provides an API to get minimum free heap or dynamic memory available in system using heap_caps_get_minimum_free_size(). __Our aim would be to maximise this number (for relative analysis) and thus increase the amount of memory available for end application specific business logic (DRAM region to be specific).__ 

## Default Memory Utilisation

We will be using following patch on top of subscribe_publish example to log dynamic memory statistics.

- First we will be logging system level minimum free heap numbers for DRAM and IRAM regions respectively as mentioned earlier.
- Second we will be using heap task tracking feature which provides information on dynamic memory usage on per task basis. This feature is modified to also log peak usage numbers for DRAM and IRAM regions on per task basis.
- __We will be logging this information for__ __aws_iot_task__ __,__ __tiT (tcpip)__ __and__ __wifi__ __tasks respectively__ (as these tasks define data transfer path from application layer to physical layer and vice-versa). It is also to be noted that there will some variation in peak memory usage of networking tasks based on environmental (like WiFi connection, network latency) factors.

*Note: Change in core-id during task creation (from below patch) is for single core configuration that we are using for this particular example.*

> With default configuration (and heap task tracking feature enabled) we get following heap utilisation statistics (all values in bytes):

```
Task Heap Utilisation Stats:
||  Task         |  Peak DRAM  |   Peak IRAM ||
||  aws_iot_task |   63124     |     0       || 
||  tiT          |   3840      |     0       || 
||  wifi         |   31064     |     0       ||System Heap Utilisation Stats:
||   Minimum Free DRAM |   Minimum Free IRAM || 
||       152976        |        40276        ||
```

## Single Core Config

As mentioned earlier we will be using single core configuration for all our experiments. Please note that even in single core mode there is enough processing power available in ESP32 (close to 300 DMIPS), more than sufficient for typical IoT use-cases.

> Corresponding configuration to be enabled in application:

```
CONFIG_FREERTOS_UNICORE=y
```

> Updated heap utilisation statistics from application re-run as following:

```
Task Heap Utilisation Stats:
||  Task         |  Peak DRAM  |   Peak IRAM ||
||  aws_iot_task |   63124     |     0       || 
||  tiT          |   3892      |     0       || 
||  wifi         |   31192     |     0       ||System Heap Utilisation Stats:
||   Minimum Free DRAM |   Minimum Free IRAM || 
||       162980        |        76136        ||
```

> As can be seen from above, we have gained ~10KB memory in DRAM, since some of services (e.g. idle, esp_timer tasks etc.) for second CPU core are not required anymore. In addition IPC service for inter processor communication is also no more required, so we gain from stacks and dynamic memory of that service. Increase in IRAM is due to the freeing up of 32KB cache memory of second CPU core and some of code savings due to disablement of above mentioned services.

## TLS Specific

## Asymmetric TLS Content Length

This feature has been part of ESP-IDF from v4.0 onwards. This feature allows to enable asymmetric content length for TLS IN/OUT buffers. Thus application has an ability to reduce TLS OUT buffer from its default value of 16KB __(maximum TLS fragment length per specification)__  to as small as say 2KB, and thus allowing __14KB of dynamic memory saving__ .

Please note that, it is not possible to reduce TLS IN buffer length from its default 16KB, unless you have direct control over server configuration or sure about server behaviour that it will never send inbound data (during handshake or actual data-transfer phase) over certain threshold.

> Corresponding configuration to be enabled in application:

```
# Enable TLS asymmetric in/out content length
CONFIG_MBEDTLS_ASYMMETRIC_CONTENT_LEN=y
CONFIG_MBEDTLS_SSL_OUT_CONTENT_LEN=2048
```

> Updated heap utilisation statistics from application re-run as following:

```
Task Heap Utilisation Stats:
||  Task         |  Peak DRAM  |   Peak IRAM ||
||  aws_iot_task |   48784     |     0       || 
||  tiT          |   3892      |     0       || 
||  wifi         |   30724     |     0       ||System Heap Utilisation Stats:
||   Minimum Free DRAM |   Minimum Free IRAM || 
||       177972        |        76136        ||
```

> As can be seen from above, we have gained ~14KB memory from aws_iot_task and thus minimum free DRAM number has increased accordingly.

## Dynamic Buffer Allocation Feature

During TLS connection, mbedTLS stack keeps dynamic allocations active during entire session starting from initial handshake phase. These allocations includes, TLS IN/OUT buffers, peer certificate, client certificate, private keys etc. In this feature (soon to be part of ESP-IDF), mbedTLS internal APIs have been glued (using SHIM layer) and thus it is ensured that whenever resource usage (including data buffers) is complete relevant dynamic memory is immediately freed up.

This greatly helps to reduce peak heap utilisation for TLS connection. This will have small performance impact due to frequent dynamic memory operations (on-demand resource usage strategy). Moreover since memory related to authentication credentials (certificate, keys etc.) has been freed up, during TLS reconnect attempt (if required), application needs to ensure that mbedTLS SSL context is populated again.

> Corresponding configuration to be enabled in application:

```
# Allow to use dynamic buffer strategy for mbedTLS
CONFIG_MBEDTLS_DYNAMIC_BUFFER=y
CONFIG_MBEDTLS_DYNAMIC_FREE_PEER_CERT=y
CONFIG_MBEDTLS_DYNAMIC_FREE_CONFIG_DATA=y
```

> Updated heap utilisation statistics from application re-run as following:

```
Task Heap Utilization Stats:
||  Task         |  Peak DRAM  |   Peak IRAM ||
||  aws_iot_task |   26268     |     0       || 
||  tiT          |   3648      |     0       || 
||  wifi         |   30724     |     0       ||System Heap Utilization Stats:
||   Minumum Free DRAM |   Minimum Free IRAM || 
||       203648        |        76136        ||
```

> As can be seen from above, we have gained ~22KB memory from *aws_iot_task* and thus minimum free DRAM number has increased accordingly.

## Networking Specific

## WiFi/LwIP Configuration

We can further optimise the WiFi and LwIP configuration to reduce memory usage, at the cost of giving away some performance. Primarily we will reduce WiFi TX and RX buffers and try to balance it out by moving some critical code path from networking subsystem to instruction memory (IRAM).

To give some ballpark on performance aspect, with default networking configuration average TCP throughput is close to ~20Mbps, but with below configuration it will be close to ~4.5Mbps, which is still sufficient to cover typical IoT use-cases.

> Corresponding configuration to be enabled in application:

```
# Minimal WiFi/lwIP configuration
CONFIG_ESP32_WIFI_STATIC_RX_BUFFER_NUM=4
CONFIG_ESP32_WIFI_DYNAMIC_TX_BUFFER_NUM=16
CONFIG_ESP32_WIFI_DYNAMIC_RX_BUFFER_NUM=8
CONFIG_ESP32_WIFI_AMPDU_RX_ENABLED=
CONFIG_LWIP_TCPIP_RECVMBOX_SIZE=16
CONFIG_LWIP_TCP_SND_BUF_DEFAULT=6144
CONFIG_LWIP_TCP_WND_DEFAULT=6144
CONFIG_LWIP_TCP_RECVMBOX_SIZE=8
CONFIG_LWIP_UDP_RECVMBOX_SIZE=8
CONFIG_ESP32_WIFI_IRAM_OPT=y
CONFIG_ESP32_WIFI_RX_IRAM_OPT=y
CONFIG_LWIP_IRAM_OPTIMIZATION=y
```

> Updated heap utilisation statistics from application re-run as following:

```
Task Heap Utilization Stats:
||  Task         |  Peak DRAM  |   Peak IRAM ||
||  aws_iot_task |   26272     |     0       || 
||  tiT          |   4108      |     0       || 
||  wifi         |   19816     |     0       ||System Heap Utilization Stats:
||   Minumum Free DRAM |   Minimum Free IRAM || 
||       213712        |        62920        ||
```

> As can be seen from above log, we have gained roughly ~9KB of additional DRAM for application usage. Impact (reduction) in total IRAM comes because we moved critical code path from networking subsystem to this region.

## System Specific

## Utilising RTC (Fast) Memory (single-core only)

As can be seen from earlier memory breakup there is one useful 8KB RTC Fast memory (and reasonably fast) which has been sitting idle and not fully utilised. ESP-IDF will soon have feature to enable RTC Fast memory for dynamic allocation purpose. This option exists in single core configuration, as the RTC Fast memory is accessible to PRO CPU only.

It has been ensured that RTC Fast memory region will be utilised as first dynamic memory range, and most of startup, pre-scheduler code/services will occupy this range. This will allow to not have any performance impact in application code due to clock speed (slightly on slower side) of this memory.

Since there are no access restrictions to this region, capability wise we will call it as DRAM henceforth.

Let’s re-run our application with this feature and gather memory numbers.

> Corresponding configuration to be enabled in application:

```
# Add RTC memory to system heap
CONFIG_ESP32_ALLOW_RTC_FAST_MEM_AS_HEAP=y
```

> Updated heap utilisation statistics from application re-run as following:

```
Task Heap Utilization Stats:
||  Task         |  Peak DRAM  |   Peak IRAM ||
||  aws_iot_task |   26272     |     0       || 
||  tiT          |   4096      |     0       || 
||  wifi         |   19536     |     0       ||System Heap Utilization Stats:
||   Minumum Free DRAM |   Minimum Free IRAM || 
||       221792        |        62892        ||
```

> As can be seen from above log, we have gained 8KB of additional DRAM for application usage.

## Utilising Instruction Memory (IRAM, single-core only)

So far we have seen different configuration options to allow end application to have more memory from DRAM (data memory) region. To continue along similar lines, it should be noted that there is still sufficient IRAM (instruction memory) left but it can not be used as generic purpose due to 32-bit address and size alignment restrictions.

- If access (load or store) is from IRAM region and size is not word-aligned, then processor will generate LoadStoreError(3) exception
- If access (load or store) is from IRAM region and address is not word-aligned then processor will generate LoadStoreAlignmentError(9) exception

In this particular feature from ESP-IDF, above mentioned unaligned accesses have been fixed through corresponding exception handlers and thus resulting in correct program execution. However, these exception handlers can take up-to 167 CPU cycles for each (restricted) load or store operation. So there could be significant performance penalty (as compared with DRAM access) while using this feature.

This memory region can be used in following ways:

- First through heap allocator APIs using special capability field known as __MALLOC_CAP_IRAM_8BIT__ 
- Second by redirecting DATA/BSS to this region using provided linker attributes, __IRAM_DATA_ATTR__  and __IRAM_BSS_ATTR__ 

Limitations wise:

- This memory region can be not be used for DMA purpose
- This memory region can not be used for allocating task stacks

While discussing usage of this memory region with understood performance penalty, TLS IN/OUT (per our configuration value of buffer 16KB/2KB) buffers were found to be one of the potential candidate to allocate from this region. In one of the experiments, for transfer of 1MB file over TLS connection, time increased from ~3 seconds to ~5.2 seconds with TLS IN/OUT buffers moved to IRAM.

It is also possible to redirect all TLS allocations to IRAM region but that may have larger performance impact and hence this feature redirects only buffers whose size is greater or equal than minimum of TLS IN or OUT buffer (in our case threshold would be 2KB).

Let’s re-run our application with this feature and gather memory numbers.

> Corresponding configuration to be enabled in application:

```
# Allow usage of IRAM as 8bit accessible region
CONFIG_ESP32_IRAM_AS_8BIT_ACCESSIBLE_MEMORY=y
CONFIG_MBEDTLS_IRAM_8BIT_MEM_ALLOC=y
```

> Updated heap utilisation statistics from application re-run as following:

```
Task Heap Utilization Stats:
||  Task         |  Peak DRAM  |   Peak IRAM ||
||  aws_iot_task |   17960     |     21216   || 
||  tiT          |   3640      |     0       || 
||  wifi         |   19536     |     0       ||System Heap Utilization Stats:
||   Minumum Free DRAM |   Minimum Free IRAM || 
||       228252        |        40432        ||
```

> As can be seen from above log, we have gained another ~7KB of additional DRAM for application usage. Please note that, even though we have redirected all allocations above 2KB threshold to IRAM, there are still many smaller (and simultaneous) allocations happening from DRAM region (another local maxima) and hence effective gain is lower than what actually should have been. If additional performance impact is acceptable then it is possible to redirect all TLS allocation to IRAM and gain further at-least ~10–12KB memory from DRAM region.

## Summary

- Having complete application control over selection of various features through configuration options is one of the important features in ESP-IDF.
- Through above exercise we have systematically evaluated various features and configuration options within ESP-IDF to __increase DRAM (fastest memory) budget for end application by 63KB__  (minimum free DRAM size increased from ~160KB to ~223KB).
- Some of these configuration options are available for single-core configuration only (have been marked as such in title itself) but even in dual-core configuration memory savings are possible with rest of the options.
- It is further possible to utilise instruction memory (IRAM) as 8-bit accessible region for non-performance critical modules like logging and diagnostics by end application.
- It is recommended to disable some of the debugging features that we used in above exercise like heap task tracking to reduce metadata overhead (and further increase memory budget) once required system characterisation is achieved.

## References

- Modified subscribe_publish example along with final sdkconfig.defaults file can be found [__here__ ](https://github.com/mahavirj/esp-aws-iot/tree/feature/memory_optimizations/examples/subscribe_publish)__.__ 
- This application should be built against ESP-IDF fork and feature branch from [__here__ ](https://github.com/mahavirj/esp-idf/tree/feature/memory_optimizations)__.__
