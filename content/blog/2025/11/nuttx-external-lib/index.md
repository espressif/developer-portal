---
title: "Integrating External Libraries into NuttX Applications"
date: 2025-11-19
lastmod: 2025-11-27
tags:
  - NuttX
  - practitioner
  - how-to
  - RISC-V
  - cross-compilation
  - library
showAuthor: false
authors:
    - "filipe-cavalcanti"
summary: "This guide demonstrates how to integrate external libraries into NuttX applications using static libraries and cross-compilation. Learn how to build a library on x86, integrate it into the NuttX simulation environment, and cross-compile for RISC-V targets like the ESP32-C6, all without moving your entire codebase into the NuttX directory structure."
---

## Introduction

When moving your application to NuttX, you may need to add your existing codebase to the NuttX build environment. That is a common scenario where the user application contains mostly hardware-independent logic (such as data processing and analysis) that was originally developed on a POSIX compliant system. Those applications are usually tested on an x86 machine and adapted to run on an RTOS, or, in the case of NuttX, it should not need changes if the codebase is already POSIX compliant.

This article shows how to build NuttX with your custom application without moving your entire stack to the NuttX directory. You use a static library and cross-compilation to achieve this.

This article is divided into four parts. The first part introduces an example library and builds it on x86. Then, the second part describes how to add the library to the NuttX simulation environment. The third part cross-compiles to RISC-V and runs the example on the ESP32-C6. Finally, the fourth part concludes the article.

## Using an example library

For demonstration purposes, we will use an example application library that converts a hexadecimal color string to RGB with the following structure:

```
hex-converter/
├── src/
│   ├── hex_to_rgb.h
│   └── hex_to_rgb.c
├── main.c
├── test.c
├── Makefile
└── README.md
```

The reference project is available in [this repository](https://github.com/fdcavalcanti/hex-converter).

The `hex-converter` library exposes one single function called `hex_to_rgb`. The user provides a pointer to a string representing the hex color and a pointer
to an array where the R, G, and B values are copied. It is a simple application but very useful as an example.

Now, let's use the library on our x86 machine and see how it operates.

1. Clone the repository
2. Build the library according to the steps in the README file
3. Execute the provided `main` example program:

```bash
$ ./main "#1A2B3C"
Input: #1A2B3C
RGB: (26, 43, 60)
```

At this point, the directory should contain a static library called `libhex_to_rgb.a`.

## Testing on NuttX Simulation 

As a user, you might want to use this library in an application. The first solution might be to copy the entire hex-converter repository to the NuttX application directory and 
add it entirely to the build system. That works but is complicated, not user-friendly, and causes a Makefile mess.

If you are new to NuttX, you can read the [Getting Started with NuttX and ESP32](https://developer.espressif.com/blog/nuttx-getting-started/), which shows how to setup the NuttX development environment.

The simplest way to test this library on NuttX is to modify the ready-to-use Hello World example in the NuttX Apps repository, which could in fact be any application.

With your NuttX environment ready, follow these steps:

1. Clone the example repository and build `libhex_to_rgb.a` as discussed in [Using an example library](#using-an-example-library)
2. Copy `libhex_to_rgb.a` to `apps/examples/hello` (the Hello World example directory)
3. In `apps/hello/Make.defs`, add the hex library, library path, and include path

The Make.defs file should look like this:
```
ifneq ($(CONFIG_EXAMPLES_HELLO),)
CONFIGURED_APPS += $(APPDIR)/examples/hello

EXTRA_LIBS      += -lhex_to_rgb
EXTRA_LIBPATHS  += -L$(APPDIR)/examples/hello
CFLAGS          += ${INCDIR_PREFIX}/home/user/hex-converter/src

endif
```

To use the library, we edit the `hello_main.c` file to look like this:

```c
/****************************************************************************
 * Included Files
 ****************************************************************************/

#include <nuttx/config.h>
#include <stdio.h>
#include <stdlib.h>

#include "hex_to_rgb.h"

/****************************************************************************
 * Public Functions
 ****************************************************************************/

/****************************************************************************
 * hello_main
 ****************************************************************************/

int main(int argc, FAR char *argv[])
{
    int rgb[3];
    int result;

    if (argc != 2) {
        return EXIT_FAILURE;
    }

    printf("Input: %s\n", argv[1]);

    result = hex_to_rgb(argv[1], rgb);

    if (result == HEX_TO_RGB_SUCCESS) {
        printf("RGB: (%d, %d, %d)\n", rgb[0], rgb[1], rgb[2]);
    }
    else {
        printf("Error: %d\n", result);
    }

    return result;
}
```

After all changes are done, build the NuttX simulation:

1. `./tools/configure.sh sim:nsh`
2. `make`
3. Execute: `./nuttx`

Call the `hello` program. This executes the HEX to RGB conversion: 
```
user@desktop:~/nxsupport/nuttx$ ./nuttx 
NuttShell (NSH) NuttX-12.8.0
nsh> hello "#1a2b3c"
Input: #1a2b3c
RGB: (26, 43, 60)
nsh>
```

Success! We can compile our library externally, link it to a NuttX application, and use it.

Now that simulation works, let's look into a real use case that requires the same code to work on hardware.

## Using the library on the ESP32-C6

This section shows how to prepare the library for an actual target device—in this case, the ESP32-C6. To do this, we first cross-compile the example library for the RISC-V architecture and then integrate the resulting static library into the Hello World Example that will be executed on our target.

### Cross-compilation

Clear the environment to delete the x86 build and rebuild for RISC-V:

1. `make clean`
2. `make TARGET=riscv32`

When you set the TARGET variable in the hex-converter Makefile, the CC instruction changes from `gcc` to `riscv-none-elf-gcc`.

The same `libhex_to_rgb.a` library is ready, but now it can be used on RISC-V devices. This can be verified easily:

```
$ file main
main: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI, version 1 (SYSV), statically linked, not stripped
```

### Test on target

Clean the NuttX environment with `make distclean` and configure it for the `nsh` example of ESP32-C6.

Copy the new `libhex_to_rgb.a` to the `hello` example directory. Then configure and build the project:

1. `make distclean`
2. `./tools/configure.sh esp32c6-devkitc:nsh`
3. On `menuconfig`, enable Hello World example (Application Configuration → Examples > "Hello World" Example)
4. `make`

Flash the board and try the `hello` example using the serial console:

```
[...]
SHA-256 comparison failed:
Calculated: d07603736784dd3c56754d4d27366ffd0c2a32aebaddea7e6c0a153ad774ba15
Expected: 00000000009d0000000000000000000000000000000000000000000000000000
Attempting to boot anyway...
entry 0x40805496
pmu_param(dbg): blk_version is less than 3, act dbias not burnt in efuse
*** Booting NuttX ***
[...]
NuttShell (NSH) NuttX-12.8.0
nsh> hello "#1a2b3c"
Input: #1a2b3c
RGB: (26, 43, 60)
nsh> 
```

With a simple change of compiler and no changes to the NuttX build system, we were able to have the same example
running on an ESP32-C6.

## Conclusion

This article demonstrates how to integrate external libraries into NuttX applications using static libraries and cross-compilation. The process involves three main steps: building the library on x86, integrating it into the NuttX simulation environment, and cross-compiling for the target hardware.

The static library approach offers several advantages. You can develop and test your code on an x86 machine without flashing the target device. The same library works across different architectures with minimal changes, requiring only a recompilation step. This workflow saves development time and simplifies the porting process.

By following these steps, you can add existing applications to NuttX without moving your entire codebase into the NuttX directory structure. This approach maintains separation between your application code and the RTOS, making maintenance and updates easier.

## Related Resources

- [NuttX ESP32 Documentation](https://nuttx.apache.org/docs/latest/platforms/risc-v/esp32c6/index.html)
- [Getting Started with NuttX and ESP32](https://developer.espressif.com/blog/nuttx-getting-started/)
