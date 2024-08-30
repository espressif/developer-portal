---
title: Core Dump: A Powerful Tool for Debugging Programs in Zephyr with ESP32 Boards
date: 2023-07-27
showAuthor: false
authors: 
  - lucas-tamborrino
---
[Lucas Tamborrino](https://medium.com/@lucastamborrino?source=post_page-----969830fd6cdb--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2F9f67b4e2c37e&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fcore-dump-a-powerful-tool-for-debugging-programs-in-zephyr-with-esp32-boards-969830fd6cdb&user=Lucas+Tamborrino&userId=9f67b4e2c37e&source=post_page-9f67b4e2c37e----969830fd6cdb---------------------post_header-----------)

--

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*jYTUyas5elSy9YEC7g4MMg.gif)

[Zephyr OS](https://www.zephyrproject.org/) is an open-source, scalable, and adaptable real-time operating system (RTOS) for multiple hardware platforms, including [Espressif’s](https://www.espressif.com/) SoCs ESP32, ESP32S2, ESP32C3, and ESP32S3. Zephyr OS provides a wide range of features for embedded systems development, including support for generating and analyzing core dumps on unrecoverable software errors.

A core dump is a snapshot of the state of a program’s memory when it crashes. It can be used to debug the program and find the cause of the crash. So, it is possible to find out what task, at what instruction (line of code), and what call stack of that program led to the crash. It is also possible to dump variables content on demand if previously attributed accordingly.

Zephyr OS provides support for multiple core dump backends, including the logging backend. The logging backend dumps core dumps to the UART, which can then be saved to a file and analyzed using a custom GDB server and the GDB provided by the SDK.

## How To Use

To use the logging backend for core dumps, you need to enable the following Kconfig options:

```
CONFIG_DEBUG_COREDUMP=y 
CONFIG_DEBUG_COREDUMP_BACKEND_LOGGING=y 
```

Once you have enabled the logging backend, the application will generate the core dump during a fatal error. CPU registers and memory content will be printed to the console.

Copy and paste the content into a file called __coredump.log__ .

We need to convert this text file to a binary that can be parsed by the custom GDB server. To do that just run the coredump_serial_log_parser.py script

```
./scripts/coredump/coredump_serial_log_parser.py coredump.log coredump.bin 
```

The script will output the binary file to __coredump.bin__ .

Start the custom GDB server with the __.elf__  file from the zephyr application and the binary core dump file as parameters:

```
./scripts/coredump/coredump_gdbserver.py build/zephyr/zephyr.elf coredump.bin 
```

In another terminal just run Xtensa’s GDB from the Zephyr SDK with the __.elf__ file as parameter:

```
~/zephyr-sdk-0.16.0/xtensa-espressif_esp32_zephyr-elf/bin/xtensa-espressif_esp32_zephyr-elf-gdb build/zephyr/zephyr.elf 
```

Inside GDB, attach to the custom server with:

```
(gdb) target remote localhost:1234 
```

Now you can examine the state of the program at the time of the crash, read variables values, backtraces and register values.

## Example

Here is an example of how to use the logging backend for core dumps to debug a program.

We will build and flash the coredump test located in __*tests/subsys/debug/coredump*__ 

The program defines three functions: *func_1*, *func_2*, and *func_3*. *func_1* calls *func_2*, which calls *func_3*. *func_3* attempts to dereference a null pointer. This will cause the program to crash.

The crash will generate a core dump file, which we will use to debug the program.

```
west build -p -b esp32 tests/subsys/debug/coredump 
```

2. Flash and monitor the ESP32 board:

```
west flash && west espressif monitor 
```

Here is the expected output:

```
*** Booting Zephyr OS build zephyr-v3.3.0-3986-gebf86941118f *** 
Coredump: esp32 
E:  ** FATAL EXCEPTION 
E:  ** CPU 0 EXCCAUSE 29 (store prohibited) 
E:  **  PC 0x400d0435 VADDR (nil) 
E:  **  PS 0x60620 
E:  **    (INTLEVEL:0 EXCM: 0 UM:1 RING:0 WOE:1 OWB:6 CALLINC:2) 
E:  **  A0 0x80081716  SP 0x3ffe65e0  A2 0x3f401cb8  A3 (nil) 
E:  **  A4 0x3f401cb8  A5 0xff  A6 0x3ffb1ad8  A7 0x3ffe5dfc 
E:  **  A8 (nil)  A9 0x3ffe6590 A10 0x3f400968 A11 0x3f4012d0 
E:  ** A12 0x3ffb1ad8 A13 0x60420 A14 0x3ffe5dd8 A15 0x3ffe5e30 
E:  ** LBEG (nil) LEND (nil) LCOUNT (nil) 
E:  ** SAR 0x1b 
E: #CD:BEGIN# 
E: #CD:5a4501000500050000000000 
E: #CD:4101006800 
E: #CD:0202000135040d401d000000000000001b000000200606000000000016170880 
E: #CD:e065fe3fb81c403f00000000b81c403fff000000d81afb3ffc5dfe3f00000000 
E: #CD:9065fe3f6809403fd012403f000000009065fe3f6809403fd012403f00000000 
E: #CD:0000000000000000 
E: #CD:4d0100d81afb3f581bfb3f 
E: #CD:d81cfb3fd81cfb3f000000000180000000000000000000000000000000000000 
E: #CD:000000000000000000000000000000000000000000000000101bfb3f101bfb3f 
E: #CD:6d61696e00000000000000000000000000000000000000000000000000000000 
E: #CD:00000000305efe3f0008000000000000f5ffffff0864fe3f080afb3fffffffff 
E: #CD:4d0100305efe3f3066fe3f 
E: #CD:f4b6dbfcd7903c37a5f85ffb73a1c5ad7da3432d420e03142b7673dc1f70a451 
E: #CD:e4165f6f2491c43b0aae041aa6bad45d0d019d7bd7061165478aa8e8e9dfb05d 
E: #CD:5e9ca79574bd8eee1a446b5919d39bbdc7a78c067dd9348e7dd99f3bc0ae0e59 
E: #CD:05a5d5e1459c6325d537dd4db75d0210f30e67e7e292f5af90ea8bab11d9090c 
E: #CD:14bacecb11dc47c19ae8d3922a290fcbe82ff95e23d63ad210459e8fc79dc78a 
E: #CD:e443c9dbf22b94b0ed95e23bba0f6006022225d48e85ba76d148caff2b2fd519 
E: #CD:324d6de3d17410eeae3d5a6513bfc8eed68141495be8c069e69dcea9748fd38e 
E: #CD:59fc1f6e57f36d52ba51d383d2df4ab9746d893b9bf276879d2182cfd03fe1fe 
E: #CD:fce68691b4df96c5ac234d34a8eb21f199191138061a17245042ab8ac94e14ac 
E: #CD:0e017619e4b42895aec67da7fdfb525168850547d0f2530247b1995dfaf9ddc5 
E: #CD:168588d974a379bcc3ddbead2edba5571dcbdd29c06ab11b41793d3ba2e15ab4 
E: #CD:da808c516438cd28215077c160bb5e0221b6c2d827db238850687d5cad9736f4 
E: #CD:60f9f777da01758a56b11a2fa9fc4bd9eaddb172f844223ea356ac0d5f77324f 
E: #CD:14417a13726f99d28c42bdedf33cc9a198dbe361b4974d152256806c0db076f8 
E: #CD:12b3e2c95e5dc84dd6d028065abf26054ff992b205ca641e249417dd7368bd92 
E: #CD:d8faf9e19687346bf31e315db64a05c049b23cf3a10eb60d6472211fdd43e8cc 
E: #CD:7b334dbb3b549c5b91bea3352ac68b3f6b199e2967344cc07da7d79c4bdc884c 
E: #CD:6ebcd3093df87d7633ccb583b036864cc48166283095024d592b16600f4ed38f 
E: #CD:bd1e1bdaf1538c6134c078d1f7b69f9467774e910b318854a0fcdd8841b12e0d 
E: #CD:74ca51cad7c6b020789c6affacc31d39a034d13c0ebaa3a07b53f81091d7b704 
E: #CD:8641f161cbaacd75c8aa1bd1b557470083e87921b4ae92960764aa2ad6eff203 
E: #CD:c32fa391df51c8c38aa88c5a54bf130009f26b64a8b2a15418b4286ab0edc3ec 
E: #CD:08d9c9c133fad8213c38e9ccb7505e2940c9612ceeb772440786012cddf5bbaf 
E: #CD:435c265247afa7e2cdb315fa23e47a45b9050d8cb61b4a72646f58febc81773f 
E: #CD:cbf027958c8a67478a2f9441bc94767ec90f446ba54ff82b893dddaddd42a004 
E: #CD:2a26cb016dfb2c1e0c691e319505c4167e83031ee83cd0843165c00b63fa4e96 
E: #CD:01f75bce679271064f56595a83ca5ae00ea79ba5c396f560a709dfa617e1dd14 
E: #CD:714ee1c87b95a422386d41a70f88df76019315875cc82b030dd005ba35af53bc 
E: #CD:029df20768fe4612c91133a5f38602715c05ef9b330ea662402b4779b8de6e8b 
E: #CD:6d8cad92e2fe7600ea3c4c83744186abc127d75f6f9334365e0c6b8c2ea6c82b 
E: #CD:7ea6b0095adbdbc82ba150a670db718a67d5fe5d8b9f04a48eafff8d2200e075 
E: #CD:d18277cc7bcbd8419bb21b15cfddc8340bd7721707bd54ff04fb72c71ec12ce7 
E: #CD:8ce9635cf260717cbe2cf8392f7796c24a2384dd9db2142dc00e7dc83c9b8119 
E: #CD:3e8a971d612a603e88062e7679ada4082e8fddc80cdd34bfd9df64f4a887d9b0 
E: #CD:920fff4ae8ee63e1e48e611e887334929a89ccce5ecb250c03ca59178b3eb5dc 
E: #CD:d88de936c368020f892357c7700d2b9ac237affbe9aad454736025fc37e7a4f0 
E: #CD:b60103116de8e418f17b1ffea7c3840ce9b5de74f2714451e7c774b0fc94d2d1 
E: #CD:8c3e9f17ac30161adf79c9cee52cfa79e62cc228781234124557f6463fe95228 
E: #CD:80d4d0b905bc05fb54e134ced7f84ac128ba82cda103f29f9a62e4c5f4105021 
E: #CD:80f085cb993e77c86f82ecf01dac257e25942f840eccd2e11385a946fd7b508c 
E: #CD:71e13192d9b4ceba06ae199b77127b529791be9b878657590a3c5a263d9c8319 
E: #CD:b9f9487e4086539f1e4758b87ca24b70887d185c7e617ff288bde4944e2c6cf3 
E: #CD:fb23feb7aadf90c80c6d00f66d287f80f52c7d593a108e9ff178fc30defc40d4 
E: #CD:3b59f4efbd708b0f0192d457450ad657d3b45fc4d254406d7ac94f4eafdc5be4 
E: #CD:ba1719090cbed14af915ca7991db7b87027ced573a0e6aff7078a83139df611f 
E: #CD:3fa23f95b5c39b7e15c92108a5322206fb74ee59e39327b66180c48dd9cbc1cb 
E: #CD:00c04eeb3550aa7e24de68fa4aa720be1ee74e8dc10a57a93c64fe3f00000000 
E: #CD:00c050eb0000000000000000703d088000c04eeb010000006d00000000000000 
E: #CD:3266fe3f0000000000000000db32008c00c050eb010000000000000000000000 
E: #CD:0a0000000000000020020600703d0840093d0880001008406d000000a01c403f 
E: #CD:7c330880a064fe3f6d00000000000000fedf99ececff33aec26b3658ed9c5be5 
E: #CD:283d0880c064fe3f6d00000006000000c01cfb3fd81afb3fd81afb3fd865fe3f 
E: #CD:4c3d08804065fe3f6809403fc065fe3fd012403f000000008000037300000000 
E: #CD:00000000000000001a2488bc891e7d358fc4ecfa81e597aa9df65bb7a6a74806 
E: #CD:c065fe3fa065fe3f04000000c065fe3fa065fe3ffc3c0840000000007509403f 
E: #CD:000000007209403fdb8a502716f5e7f50400000025000000a065fe3f04000000 
E: #CD:30040d809065fe3f6809403fd012403f000000003b4bed4f08035fadadc14494 
E: #CD:0a1751af3f39a63cf90f74b2820658d1cbb50403fb4800949c65fe3fd81afb3f 
E: #CD:20040600d85dfe3f305efe3f000000009065fe3f6809403fd012403fb81c403f 
E: #CD:ff000000d81afb3ffc5dfe3fdf2daf23000000001d0000000000000000000000 
E: #CD:000000001b0000002006060035040d401617088000100840b81c403f00000000 
E: #CD:56040d800066fe3f0000000000000000b81c403fff000000d81afb3ffc5dfe3f 
E: #CD:000000002066fe3ff81608400000000000000000000000007f00000000000000 
E: #CD:000000004066fe3f000000000000000000000000000000000000000000000000 
E: #CD:END# 
E: >>> ZEPHYR FATAL ERROR 0: CPU exception on CPU 0 
E: Current thread: 0x3ffb1ad8 (main) 
E: Halting system 
```

The core dump content begins with #CD:BEGIN# and ends with #CD:END#. We need to copy the content in between to a new file called __coredump.log__ 

3. Copy core dump to coredump.log

```
E: #CD:BEGIN# 
E: #CD:5a4501000500050000000000 
E: #CD:4101006800 
E: #CD:0202000135040d401d000000000000001b000000200606000000000016170880 
E: #CD:e065fe3fb81c403f00000000b81c403fff000000d81afb3ffc5dfe3f00000000 
E: #CD:9065fe3f6809403fd012403f000000009065fe3f6809403fd012403f00000000 
E: #CD:0000000000000000 
E: #CD:4d0100d81afb3f581bfb3f 
E: #CD:d81cfb3fd81cfb3f000000000180000000000000000000000000000000000000 
E: #CD:000000000000000000000000000000000000000000000000101bfb3f101bfb3f 
E: #CD:6d61696e00000000000000000000000000000000000000000000000000000000 
E: #CD:00000000305efe3f0008000000000000f5ffffff0864fe3f080afb3fffffffff 
E: #CD:4d0100305efe3f3066fe3f 
E: #CD:f4b6dbfcd7903c37a5f85ffb73a1c5ad7da3432d420e03142b7673dc1f70a451 
E: #CD:e4165f6f2491c43b0aae041aa6bad45d0d019d7bd7061165478aa8e8e9dfb05d 
E: #CD:5e9ca79574bd8eee1a446b5919d39bbdc7a78c067dd9348e7dd99f3bc0ae0e59 
E: #CD:05a5d5e1459c6325d537dd4db75d0210f30e67e7e292f5af90ea8bab11d9090c 
E: #CD:14bacecb11dc47c19ae8d3922a290fcbe82ff95e23d63ad210459e8fc79dc78a 
E: #CD:e443c9dbf22b94b0ed95e23bba0f6006022225d48e85ba76d148caff2b2fd519 
E: #CD:324d6de3d17410eeae3d5a6513bfc8eed68141495be8c069e69dcea9748fd38e 
E: #CD:59fc1f6e57f36d52ba51d383d2df4ab9746d893b9bf276879d2182cfd03fe1fe 
E: #CD:fce68691b4df96c5ac234d34a8eb21f199191138061a17245042ab8ac94e14ac 
E: #CD:0e017619e4b42895aec67da7fdfb525168850547d0f2530247b1995dfaf9ddc5 
E: #CD:168588d974a379bcc3ddbead2edba5571dcbdd29c06ab11b41793d3ba2e15ab4 
E: #CD:da808c516438cd28215077c160bb5e0221b6c2d827db238850687d5cad9736f4 
E: #CD:60f9f777da01758a56b11a2fa9fc4bd9eaddb172f844223ea356ac0d5f77324f 
E: #CD:14417a13726f99d28c42bdedf33cc9a198dbe361b4974d152256806c0db076f8 
E: #CD:12b3e2c95e5dc84dd6d028065abf26054ff992b205ca641e249417dd7368bd92 
E: #CD:d8faf9e19687346bf31e315db64a05c049b23cf3a10eb60d6472211fdd43e8cc 
E: #CD:7b334dbb3b549c5b91bea3352ac68b3f6b199e2967344cc07da7d79c4bdc884c 
E: #CD:6ebcd3093df87d7633ccb583b036864cc48166283095024d592b16600f4ed38f 
E: #CD:bd1e1bdaf1538c6134c078d1f7b69f9467774e910b318854a0fcdd8841b12e0d 
E: #CD:74ca51cad7c6b020789c6affacc31d39a034d13c0ebaa3a07b53f81091d7b704 
E: #CD:8641f161cbaacd75c8aa1bd1b557470083e87921b4ae92960764aa2ad6eff203 
E: #CD:c32fa391df51c8c38aa88c5a54bf130009f26b64a8b2a15418b4286ab0edc3ec 
E: #CD:08d9c9c133fad8213c38e9ccb7505e2940c9612ceeb772440786012cddf5bbaf 
E: #CD:435c265247afa7e2cdb315fa23e47a45b9050d8cb61b4a72646f58febc81773f 
E: #CD:cbf027958c8a67478a2f9441bc94767ec90f446ba54ff82b893dddaddd42a004 
E: #CD:2a26cb016dfb2c1e0c691e319505c4167e83031ee83cd0843165c00b63fa4e96 
E: #CD:01f75bce679271064f56595a83ca5ae00ea79ba5c396f560a709dfa617e1dd14 
E: #CD:714ee1c87b95a422386d41a70f88df76019315875cc82b030dd005ba35af53bc 
E: #CD:029df20768fe4612c91133a5f38602715c05ef9b330ea662402b4779b8de6e8b 
E: #CD:6d8cad92e2fe7600ea3c4c83744186abc127d75f6f9334365e0c6b8c2ea6c82b 
E: #CD:7ea6b0095adbdbc82ba150a670db718a67d5fe5d8b9f04a48eafff8d2200e075 
E: #CD:d18277cc7bcbd8419bb21b15cfddc8340bd7721707bd54ff04fb72c71ec12ce7 
E: #CD:8ce9635cf260717cbe2cf8392f7796c24a2384dd9db2142dc00e7dc83c9b8119 
E: #CD:3e8a971d612a603e88062e7679ada4082e8fddc80cdd34bfd9df64f4a887d9b0 
E: #CD:920fff4ae8ee63e1e48e611e887334929a89ccce5ecb250c03ca59178b3eb5dc 
E: #CD:d88de936c368020f892357c7700d2b9ac237affbe9aad454736025fc37e7a4f0 
E: #CD:b60103116de8e418f17b1ffea7c3840ce9b5de74f2714451e7c774b0fc94d2d1 
E: #CD:8c3e9f17ac30161adf79c9cee52cfa79e62cc228781234124557f6463fe95228 
E: #CD:80d4d0b905bc05fb54e134ced7f84ac128ba82cda103f29f9a62e4c5f4105021 
E: #CD:80f085cb993e77c86f82ecf01dac257e25942f840eccd2e11385a946fd7b508c 
E: #CD:71e13192d9b4ceba06ae199b77127b529791be9b878657590a3c5a263d9c8319 
E: #CD:b9f9487e4086539f1e4758b87ca24b70887d185c7e617ff288bde4944e2c6cf3 
E: #CD:fb23feb7aadf90c80c6d00f66d287f80f52c7d593a108e9ff178fc30defc40d4 
E: #CD:3b59f4efbd708b0f0192d457450ad657d3b45fc4d254406d7ac94f4eafdc5be4 
E: #CD:ba1719090cbed14af915ca7991db7b87027ced573a0e6aff7078a83139df611f 
E: #CD:3fa23f95b5c39b7e15c92108a5322206fb74ee59e39327b66180c48dd9cbc1cb 
E: #CD:00c04eeb3550aa7e24de68fa4aa720be1ee74e8dc10a57a93c64fe3f00000000 
E: #CD:00c050eb0000000000000000703d088000c04eeb010000006d00000000000000 
E: #CD:3266fe3f0000000000000000db32008c00c050eb010000000000000000000000 
E: #CD:0a0000000000000020020600703d0840093d0880001008406d000000a01c403f 
E: #CD:7c330880a064fe3f6d00000000000000fedf99ececff33aec26b3658ed9c5be5 
E: #CD:283d0880c064fe3f6d00000006000000c01cfb3fd81afb3fd81afb3fd865fe3f 
E: #CD:4c3d08804065fe3f6809403fc065fe3fd012403f000000008000037300000000 
E: #CD:00000000000000001a2488bc891e7d358fc4ecfa81e597aa9df65bb7a6a74806 
E: #CD:c065fe3fa065fe3f04000000c065fe3fa065fe3ffc3c0840000000007509403f 
E: #CD:000000007209403fdb8a502716f5e7f50400000025000000a065fe3f04000000 
E: #CD:30040d809065fe3f6809403fd012403f000000003b4bed4f08035fadadc14494 
E: #CD:0a1751af3f39a63cf90f74b2820658d1cbb50403fb4800949c65fe3fd81afb3f 
E: #CD:20040600d85dfe3f305efe3f000000009065fe3f6809403fd012403fb81c403f 
E: #CD:ff000000d81afb3ffc5dfe3fdf2daf23000000001d0000000000000000000000 
E: #CD:000000001b0000002006060035040d401617088000100840b81c403f00000000 
E: #CD:56040d800066fe3f0000000000000000b81c403fff000000d81afb3ffc5dfe3f 
E: #CD:000000002066fe3ff81608400000000000000000000000007f00000000000000 
E: #CD:000000004066fe3f000000000000000000000000000000000000000000000000 
E: #CD:END#
```

4. Convert to binary format:

```
./scripts/coredump/coredump_serial_log_parser.py coredump.log coredump.bin 
```

5. Start the custom GDB server:

```
./scripts/coredump/coredump_gdbserver.py build/zephyr/zephyr.elf coredump.bin -v 
```

Expected output:

```
[INFO][gdbstub] Log file: coredump.bin 
[INFO][gdbstub] ELF file: build/zephyr/zephyr.elf 
[INFO][parser] Reason: K_ERR_CPU_EXCEPTION 
[INFO][parser] Pointer size 32 
[INFO][parser] Memory: 0x3ffb1ad8 to 0x3ffb1b58 of size 128 
[INFO][parser] Memory: 0x3ffe5e30 to 0x3ffe6630 of size 2048 
[INFO][parser] ELF Section: 0x0 to 0x1f of size 32 (read-only data) 
[INFO][parser] ELF Section: 0x20 to 0x3b of size 28 (read-only data) 
[INFO][parser] ELF Section: 0x40080000 to 0x400803ff of size 1024 (text) 
[INFO][parser] ELF Section: 0x40080400 to 0x40083e7b of size 14972 (text) 
[INFO][parser] ELF Section: 0x3f400040 to 0x3f401bff of size 7104 (read-only data) 
[INFO][parser] ELF Section: 0x3f401c00 to 0x3f401c3f of size 64 (read-only data) 
[INFO][parser] ELF Section: 0x3f401c40 to 0x3f401cb7 of size 120 (read-only data) 
[INFO][parser] ELF Section: 0x3f401cb8 to 0x3f401cd9 of size 34 (read-only data) 
[INFO][parser] ELF Section: 0x3ffb0a20 to 0x3ffb0a57 of size 56 (read-only data) 
[INFO][parser] ELF Section: 0x400d0020 to 0x400d3d53 of size 15668 (text) 
[INFO][gdbstub] Waiting GDB connection on port 1234... 
```

6. In a new terminal, start the Xtensa ESP32 GDB that is located in Zephyr’s SDK:

```
~/zephyr-sdk-0.16.0/xtensa-espressif_esp32_zephyr-elf/bin/xtensa-espressif_esp32_zephyr-elf-gdb build/zephyr/zephyr.elf 
```

7. Inside GDB, attach to the remote server:

```
(gdb) target remote localhost:1234 
Remote debugging using localhost:1234 
0x400d0435 in func_3 (addr=0x0) at zephyr/tests/subsys/debug/coredump/src/main.c:27 
27              *addr = 0; 
```

8. Run __bt__ command to see the backtrace in the moment of the crash:

```
(gdb) bt 
#0  0x400d0435 in func_3 (addr=0x0) 
    at zephyr/tests/subsys/debug/coredump/src/main.c:27 
#1  func_2 (addr=0x0) at zephyr/tests/subsys/debug/coredump/src/main.c:40 
#2  func_1 (addr=0x0) at zephyr/tests/subsys/debug/coredump/src/main.c:45 
#3  main () at zephyr/tests/subsys/debug/coredump/src/main.c:52 
```

## Conclusion

Core dump is a powerful tool for debugging programs in Zephyr with ESP32 boards. By using the logging backend for core dumps, you can easily generate core dump files that can be analyzed using a debugger. This can help you to identify the cause of a program crash and fix the bug in your program quickly and easily.
