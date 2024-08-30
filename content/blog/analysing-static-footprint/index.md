---
title: Analysing Static Footprint
date: 2018-05-13
showAuthor: false
authors: 
  - kedar-sovani
---
[Kedar Sovani](https://kedars.medium.com/?source=post_page-----eceb73fb9f2d--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F1d2175c72923&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fanalysing-static-footprint-eceb73fb9f2d&user=Kedar+Sovani&userId=1d2175c72923&source=post_page-1d2175c72923----eceb73fb9f2d---------------------post_header-----------)

--

The ESP32 is equipped with a 512KB of SRAM. While this may seem quite small, it can pack a lot of punch in this compact form if used well.

As we use the various components and its features in our application firmware, the linker pulls in different functions and variables from these components. The linker will typically optimise out entities that aren’t being used (or referenced) from the current application firmware. So, depending upon what you do in your application, the contribution from various components to your footprint changes.

The IDF provides a utility, idf_size.py, that lets you peek into the footprint utilisation so you could identify and optimise the relevant bits. The utility is also linked with the build scripts so you could directly run *make targets* to look at the footprint without having to remember a number of commands.

Let’s look at some quick ways how this can be used to look at the effective static footprint.

## Per-Component Size

One way to look at the static footprint is to look at what impact every component has on your final firmware image. This can be done using the __size-components__  target of the build system. Executing this target after building the *examples/wifi/power_save* application shows me the following output:

```
$ __make IDF_PATH=~/work/idf size-components__ 
Total sizes:
 DRAM .data size:   14200 bytes
 DRAM .bss  size:   23224 bytes
Used static DRAM:   37424 bytes ( 143312 available, 20.7% used)
Used static IRAM:   62344 bytes (  68728 available, 47.6% used)
      Flash code:  368546 bytes
    Flash rodata:   65916 bytes
Total image size:~ 511006 bytes (.bin may be padded larger)
Per-archive contributions to ELF file:
  __Archive File DRAM .data & .bss   IRAM Flash code & rodata   Total__ 
 libnet80211.a       1976   8891   3358      92337    10206  116768
     liblwip.a         19   3865      0      72280    14962   91126
       libpp.a        855   6339  13035      40707     7311   68247
        libc.a          0      0      0      55343     3889   59232
      libphy.a       1334    869   4584      29104        0   35891
    libesp32.a       2685    436   8067      10719     7388   29295
      libwpa.a          0    682      0      20314     2320   23316
 libfreertos.a       4148    776  12215          0     1595   18734
libnvs_flash.a          0     32      0       9497     2705   12234
      libgcc.a          4     20    104       9899      848   10875
...upplicant.a          0      0      0       9492        4    9496
...spi_flash.a         36    323   6465        912     1724    9460
     libheap.a        876      4   3390       1123      996    6389
   libdriver.a         24      4      0        883     4990    5901
      libsoc.a        669      8   3841          0     1239    5757
  libcoexist.a       1277     94   3344          0      137    4852
   libstdc++.a          8     20      0       2613     1253    3894
  libmbedtls.a          0      0      0       3109      320    3429
...p_adapter.a          0    124      0       2578      316    3018
      libvfs.a         40     63      0       2212      417    2732
   libnewlib.a        152    252    750        463       95    1712
  libpthread.a         16     12    178        770      655    1631
      liblog.a          8    268    438        396      166    1276
     libmain.a          0      0      0        574      643    1217
     libcore.a          0      5      0        709      402    1116
      librtc.a          0      4   1090          0        0    1094
...pp_update.a          0      0      0        123      725     848
      libhal.a          0      0    515          0       32     547
        libm.a          0      0     92          0        0      92
      libcxx.a          0      0      0         11        0      11
      libwps.a          0      1      0          0        0       1
     libwpa2.a          0      1      0          0        0       1
 libethernet.a          0      0      0          0        0       0
 ..._support.a          0      0      0          0        0       0
```

As you can see from the output above, it will display footprint information that is contributed by all the components towards the firmware. The information is additionally displayed in multiple columns:

- __DRAM .data__ : This is the size of the .*data* section of the component. This includes any pre-initialized data that can be read or written at runtime
- __DRAM .bss__ : This is the size of the .*bss* section of the component. This includes any global or statically defined variables and objects that are zero-initialised on boot-up.
- __IRAM__ : This is the size of the code (*.text*) section that needs to be loaded into IRAM. Note that most code can directly be executed from flash (XIP), without having to load it into IRAM. Typically code that is executed in interrupt context or accesses flash for read/write directly goes in here.
- __Flash Code__ : This is the size of the code (*.text*) section that is in the flash and is directly executed from there. Most of your code section will end up in this column.
- __Flash rodata__ : Any read-only data that is used by your firmware (strings, statically initialized and unmodifiable arrays) all go into this section. Since the flash can directly be accessed during execution, this need not be loaded into memory.
- __Total:__  The total contribution of this component.

As you might have guessed the size contributions to the IRAM and DRAM section here are critical. Since SRAM is limiting factor (512KB) relative to flash (about 2–8 MB).

## Per-Symbol Size

Now Let’s say you found out that one of the components that you have written consumes much more memory that it should have. You can dig deeper by trying to check which symbols within this component contribute the most to the footprint. This can be done using the __size-symbols__  target to the build system. For example,

```
$ __make IDF_PATH=~/work/idf size-symbols COMPONENT=soc__ Total sizes:
 DRAM .data size:   14200 bytes
 DRAM .bss  size:   23224 bytes
Used static DRAM:   37424 bytes ( 143312 available, 20.7% used)
Used static IRAM:   62344 bytes (  68728 available, 47.6% used)
      Flash code:  368546 bytes
    Flash rodata:   65916 bytes
Total image size:~ 511006 bytes (.bin may be padded larger)
Symbols within the archive: libsoc.a (Not all symbols may be reported)__Symbols from section: .dram0.data__ str1.4(605) __func__$3446(23) __func__$3425(21) rtc_clk_cpu_freq_value(20)
Section total: 669__Symbols from section: .dram0.bss__ 
s_cur_pll(4) s_cur_freq(4)
Section total: 8__Symbols from section: .iram0.text__ 
rtc_init(1020) rtc_clk_cpu_freq_set(472) rtc_clk_bbpll_set(380) rtc_clk_cal_internal(369) .iram1(282) rtc_clk_cpu_freq_get(172) rtc_clk_32k_bootstrap(170) rtc_clk_32k_enable_internal(149) rtc_clk_wait_for_slow_cycle(129) rtc_time_get(96) rtc_clk_cpu_freq_value(96) rtc_clk_cal(78) rtc_clk_xtal_freq_get(68) rtc_clk_slow_freq_get_hz(51) rtc_clk_apb_freq_get(50) rtc_clk_32k_enable(49) rtc_clk_fast_freq_set(46) rtc_clk_slow_freq_set(43) clk_val_is_valid(32) .iram1.literal(28) rtc_clk_apb_freq_update(23) rtc_clk_slow_freq_get(16) clk_val_to_reg_val(14) reg_val_to_clk_val(8)
Section total: 3841Symbols from section: .iram0.vectorsSection total: 0Symbols from section: .flash.textSection total: 0__Symbols from section: .flash.rodata__ 
soc_memory_regions(704) soc_memory_types(320) str1.4(159) soc_reserved_regions(48) soc_reserved_region_count(4) soc_memory_region_count(4)
Section total: 1239
```

Notice that we pass an additional parameter *COMPONENT=<component_name>* in the make command line to get per symbol information of this component. In the example above, we requested information for the component ‘soc’.

This caused the tool to display how much every symbol (function or variable/object) from this component contributed to the firmware’s footprint. Notice how information about how much size every function contributed to __.iram0.text__  is shown in the output above. Also, because the arrays __soc_memory_types__  and __soc_memory_regions__  (defined in soc_memory_layout.c) are defined as ‘const’ are put into the flash since it is read-only data.

This information can be effectively used to identify exactly what parts of your components are contributing to the firmware footprint and then help you focus on optimizing these parts effectively.
