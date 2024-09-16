---
title: "Building Applications on NuttX: Understanding the Build System"
date: 2024-09-16T08:00:00-03:00
tags: ["NuttX", "Apache", "ESP32", "POSIX", "Linux", "Tutorial"]
series: ["nuttx-apps"]
series_order: 1
showAuthor: false
authors:
    - "tiago-medicci"
---

## Developing a Project with Existing Applications

The process of building an application in NuttX - whether it is a custom application or one that already exists and targets other operating systems - follows the principles of the NuttX build system. Although the NuttX documentation covers aspects of the application compilation process in various articles and documents, we will delve deeper into some of these options in this article.

For those who are not familiar with NuttX, I recommend reading the article [Getting Started with NuttX and ESP32]({{< ref "blog/nuttx-getting-started/index.md" >}}) or referring to the [*Getting Started*](https://nuttx.apache.org/docs/latest/quickstart/index.html) section in the official NuttX documentation. I would like to highlight NuttX's great advantage: being a POSIX-compliant system allows for easy integration of many applications into the system. About that, there's an old saying:

> Don't reinvent the wheel. Someone may have already developed an application to solve your problem!

In this sense, developing a product with NuttX is greatly facilitated by using commonly used applications and libraries that can be easily adapted to NuttX (if it hasn't already been done). Thus, the developer can focus on developing the end application of the product based on extensively tested, validated, and well-documented applications and libraries.

This series of articles explains how applications and libraries can be integrated into NuttX using the build system, and based on that explanation, we will integrate the [`RTP Tools`](https://www.cs.columbia.edu/~hgs/software/rtptools/) application into NuttX. This application is a set of utilities that, among other things, allows receiving Real-Time Protocol (RTP) packets over the network. The final application that will use RTP Tools will be further detailed in another article.

Giving a glimpse about it: have you ever thought about how cool it would be to turn an ESP32 into a low-cost, high-fidelity sound server? Well, we might need `RTP Tools` for that :wink:.

## Compiling an Application in NuttX

Applications in NuttX are separated from the kernel source code of the operating system. Similarly to other operating systems, they interact with the NuttX kernel through public APIs compatible with the POSIX standard. It's worth noting, however, that applications need to use the NuttX build system to be integrated into the final firmware. Thus, the Apache NuttX project also provides the [`nuttx-apps`](https://github.com/apache/nuttx-apps) repository, which is a collection of applications available for NuttX.

The applications in this repository are public and can be used by any user. NuttX also provides means to compile applications outside this repository, allowing proprietary applications (not public) to be integrated into the system.

{{< alert icon="comment">}}
Not every application needs to be made publicly available in `nuttx-apps`. It's possible to keep non-public applications, but that is a topic for another article (or if you're very curious, refer to the official documentation).
{{< /alert >}}

### Hello Word!

The most commonly used application as an example by operating systems and programming languages is perhaps the `Hello World!`: an application that prints those words to the user interface. It isn’t different with NuttX, and this application can be found in `apps/examples/hello` in the `nuttx-apps` repository [[1]].

The section entitled `Application Configuration File` (from the `nuttx-apps` repository description [[2]]) and the `Extend the apps directory to include a new custom directory` section in the `Custom Apps How-to` guide [[3]] explain some of the NuttX's build system and how to add an application to NuttX. Based on these documents, we will explain here the compilation of the `Hello World!` application.

The `apps/examples/hello` directory of the `nuttx-apps` repository contains the following files:

{{< highlight shell >}}
./examples/hello
├──CMakeLists.txt
├── hello_main.c
├── Kconfig
├── Make.defs
└── Makefile
{{< /highlight >}}

The `hello_main.c` file refers to the source code. The others are related to the NuttX build system, which configures and selects this application to be compiled and integrated into NuttX.

#### The Build System

NuttX uses `kconfig-frontends` (or, more recently, `kconfiglib`) to generate the NuttX configuration file (`.config`), which resides in the NuttX OS's main directory. For example, when compiling the Hello World! example, this file will have:

{{< highlight shell >}}
CONFIG_EXAMPLES_HELLO=y
{{< /highlight >}}

But how do we "register" this application to be compiled in NuttX?

#### Kconfig

The configuration `CONFIG_EXAMPLES_HELLO=y` is made available for selection by the build system through the `apps/examples/hello/Kconfig` file in the application repository. It’s this file - through the config `EXAMPLES_HELLO` line (as we’ll see soon) - that allows the NuttX build system to be aware of the existence of this application. The `Kconfig` file of the Hello World! application has the following content:

{{< highlight shell >}}
#
# For a description of the syntax of this configuration file,
# see the file kconfig-language.txt in the NuttX tools repository.
#

config EXAMPLES_HELLO
	tristate "\"Hello, World!\" example"
	default n
	---help---
		Enable the \"Hello, World!\" example

if EXAMPLES_HELLO

config EXAMPLES_HELLO_PROGNAME
	string "Program name"
	default "hello"
	---help---
		This is the name of the program that will be used when the NSH ELF
		program is installed.

config EXAMPLES_HELLO_PRIORITY
	int "Hello task priority"
	default 100

config EXAMPLES_HELLO_STACKSIZE
	int "Hello stack size"
	default DEFAULT_TASK_STACKSIZE

endif
{{< /highlight >}}

#### Make.defs

Based on this configuration, the NuttX build system includes the `apps/examples/Make.defs` file, which, in turn, adds the `apps/examples/hello` directory to the `CONFIGURED_APPS` variable as follows:

{{< highlight shell >}}
  ifneq ($(CONFIG_EXAMPLES_HELLO),)
  CONFIGURED_APPS += $(APPDIR)/examples/hello
  endif
{{< /highlight >}}

Once the application directory is added to the `CONFIGURED_APPS` variable, the apps/examples/hello/Makefile is included in the build system.

#### Makefile

Finally, the `apps/examples/hello/Makefile` provides the guidelines to compile the application for NuttX. Considering this example, the content of the file is:


{{< highlight shell >}}
include $(APPDIR)/Make.defs

# Hello, World! built-in application info

PROGNAME  = $(CONFIG_EXAMPLES_HELLO_PROGNAME)
PRIORITY  = $(CONFIG_EXAMPLES_HELLO_PRIORITY)
STACKSIZE = $(CONFIG_EXAMPLES_HELLO_STACKSIZE)
MODULE    = $(CONFIG_EXAMPLES_HELLO)

# Hello, World! Example

MAINSRC = hello_main.c

include $(APPDIR)/Application.mk
{{< /highlight >}}

Note that the Make recipe defines some variables such as `PROGNAME`, `PRIORITY`, `STACKSIZE`, and `MODULE`. These variables are set to values configured by Kconfig in the example.

However, the most important one is the `MAINSRC` variable, which defines the source files to be compiled (in this case, `hello_main.c`). Note that although not present in this example, other variables can be defined, such as `CSRCS`, which includes other auxiliary C code, and `ASRCS`, which includes assembly files (*.asm), for example.

### The Example Application

The last file in the `apps/examples/hello` directory is finally the source code of the application. The content of `hello_word.c` is:

{{< highlight c >}}
/****************************************************************************
 * Included Files
 ****************************************************************************/

#include <nuttx/config.h>
#include <stdio.h>

/****************************************************************************
 * Public Functions
 ****************************************************************************/

/****************************************************************************
 * hello_main
 ****************************************************************************/

int main(int argc, FAR char *argv[])
{
  printf("Hello, World!!\n");
  return 0;
}
{{< /highlight >}}

Note that the source code of this application is as simple as it would be for the same application to be compiled on any other operating system supporting the C language and POSIX-compliant. The entry point of the application is defined similarly, represented by the `main()` function.

## Integrating External Applications

The `Hello World!` example is a great introduction to how the NuttX build system allows to simply and quickly compile applications. However, note that the source code of the application (`hello_main.c` in this case) is integrated into the apps repository, and thus we could infer that the example application was written for NuttX (although it is very similar to a generic application). In this section, let's explore the integration of an external application (or library) whose source code was originally designed for other UNIX-based systems. So, how can we compile *Mbed TLS* for NuttX?

### Mbed TLS

The Mbed TLS repository defines it as:

> Mbed TLS is a C library that implements cryptographic primitives, X.509 certificate manipulation and the SSL/TLS and DTLS protocols. Its small code footprint makes it suitable for embedded systems."

In other words, Mbed TLS is a library that provides cryptographic functions that can be used by other applications. Let's see how it can be integrated into NuttX!

The `apps/crypto/mbedtls/Makefile` directory in the apps repository contains the files that allow compiling this library in NuttX:

{{< highlight shell >}}
./crypto/mbedtls
├── Kconfig
├── Make.defs
└── Makefile
{{< /highlight >}}

Note that there are no source files (.c) or header files (.h) present in this repository! This is possible because the Mbed TLS source code is downloaded to be compiled only when the application is selected in the NuttX build system. But how does it work?

#### Makefile

The provided Makefile in each application directory not only defines "default" variables used in the compilation but also allows writing (and overwriting) commonly used recipes in the make language. Take a look at the content of the `apps/crypto/mbedtls/Makefile`:

{{< highlight make >}}
include $(APPDIR)/Make.defs

# Mbed TLS crypto library

# Set up build configuration and environment

MBEDTLS_URL ?= "https://github.com/ARMmbed/mbedtls/archive"

MBEDTLS_VERSION = $(patsubst "%",%,$(strip $(CONFIG_MBEDTLS_VERSION)))
MBEDTLS_ZIP = v$(MBEDTLS_VERSION).zip

MBEDTLS_UNPACKNAME = mbedtls
UNPACK ?= unzip -q -o

MBEDTLS_UNPACKLIBDIR = $(MBEDTLS_UNPACKNAME)$(DELIM)library
MBEDTLS_UNPACKPROGDIR = $(MBEDTLS_UNPACKNAME)$(DELIM)programs

# This lets Mbed TLS better use some of the POSIX features we have
CFLAGS += ${DEFINE_PREFIX}__unix__

mbedtls/library/bignum.c_CFLAGS += -fno-lto

# Build break on Assemble compiler if -fno-omit-frame-pointer and -O3 enabled at same time
# {standard input}: Assembler messages:
# {standard input}:2560: Error: branch out of range
# make[2]: *** [apps/Application.mk:170: mbedtls/library/sha256.o] Error 1

ifeq ($(CONFIG_FRAME_POINTER),y)
  ifeq ($(CONFIG_DEBUG_OPTLEVEL),"-O3")
    mbedtls/library/sha256.c_CFLAGS += -O2
  endif
endif

ifeq ($(CONFIG_ARCH_SIM),y)
  CFLAGS += -O0
endif

CSRCS = $(wildcard $(MBEDTLS_UNPACKLIBDIR)$(DELIM)*.c)

$(MBEDTLS_ZIP):
	@echo "Downloading: $(MBEDTLS_URL)/$(MBEDTLS_ZIP)"
	$(Q) curl -O -L $(MBEDTLS_URL)/$(MBEDTLS_ZIP)

$(MBEDTLS_UNPACKNAME): $(MBEDTLS_ZIP)
	@echo "Unpacking: $(MBEDTLS_ZIP) -> $(MBEDTLS_UNPACKNAME)"
	$(Q) $(UNPACK) $(MBEDTLS_ZIP)
	$(Q) mv	mbedtls-$(MBEDTLS_VERSION) $(MBEDTLS_UNPACKNAME)
	$(Q) patch -p1 -d $(MBEDTLS_UNPACKNAME) < 0001-mbedtls-entropy_poll-use-getrandom-to-get-the-system.patch
	$(Q) patch -p1 -d $(MBEDTLS_UNPACKNAME) < 0002-mbedtls-add-mbedtls-x509-crt-pool.patch
	$(Q) touch $(MBEDTLS_UNPACKNAME)

# Download and unpack tarball if no git repo found
ifeq ($(wildcard $(MBEDTLS_UNPACKNAME)/.git),)
context:: $(MBEDTLS_UNPACKNAME)

distclean::
	$(call DELDIR, $(MBEDTLS_UNPACKNAME))
	$(call DELFILE, $(MBEDTLS_ZIP))
endif

# Configuration Applications

ifneq ($(CONFIG_MBEDTLS_APPS),)

MODULE = $(CONFIG_MBEDTLS_APPS)

ifeq ($(CONFIG_MBEDTLS_APP_BENCHMARK),y)

PROGNAME  += $(CONFIG_MBEDTLS_APP_BENCHMARK_PROGNAME)
PRIORITY  += $(CONFIG_MBEDTLS_APP_BENCHMARK_PRIORITY)
STACKSIZE += $(CONFIG_MBEDTLS_APP_BENCHMARK_STACKSIZE)

MAINSRC += $(MBEDTLS_UNPACKPROGDIR)/test/benchmark.c
endif

ifeq ($(CONFIG_MBEDTLS_APP_SELFTEST),y)

PROGNAME  += $(CONFIG_MBEDTLS_APP_SELFTEST_PROGNAME)
PRIORITY  += $(CONFIG_MBEDTLS_APP_SELFTEST_PRIORITY)
STACKSIZE += $(CONFIG_MBEDTLS_APP_SELFTEST_STACKSIZE)

MAINSRC += $(MBEDTLS_UNPACKPROGDIR)/test/selftest.c
endif

endif

# Configuration alternative implementation

ifeq ($(CONFIG_MBEDTLS_ENTROPY_HARDWARE_ALT),y)
CSRCS += $(APPDIR)/crypto/mbedtls/source/entropy_alt.c
endif

ifeq ($(CONFIG_MBEDTLS_ALT),y)

CSRCS += $(APPDIR)/crypto/mbedtls/source/dev_alt.c

ifeq ($(CONFIG_MBEDTLS_AES_ALT),y)
CSRCS += $(APPDIR)/crypto/mbedtls/source/aes_alt.c
endif

ifeq ($(CONFIG_MBEDTLS_MD5_ALT),y)
CSRCS += $(APPDIR)/crypto/mbedtls/source/md5_alt.c
endif

ifeq ($(CONFIG_MBEDTLS_SHA1_ALT),y)
CSRCS += $(APPDIR)/crypto/mbedtls/source/sha1_alt.c
endif

ifeq ($(CONFIG_MBEDTLS_SHA256_ALT),y)
CSRCS += $(APPDIR)/crypto/mbedtls/source/sha256_alt.c
endif

ifeq ($(CONFIG_MBEDTLS_SHA512_ALT),y)
CSRCS += $(APPDIR)/crypto/mbedtls/source/sha512_alt.c
endif

endif

include $(APPDIR)/Application.mk
{{< /highlight >}}

##### **Downloading the Source Code**

According to the *Built-In Applications* section of the `nuttx-apps` repository:

>The build occurs in several phases as different build targets are executed: (1) context, (2) depend, and (3) default (all). Application information is collected during the make context build phase. [[4]]

Note that the `context` recipe is always executed by the NuttX build system, and it usually prepares the compilation of an application. For the Mbed TLS, it depends on the `$(MBEDTLS_UNPACKNAME)` file, which depends on the `$(MBEDTLS_ZIP)` file that is downloaded by the recipe:

{{< highlight make >}}
$(MBEDTLS_ZIP):
	@echo "Downloading: $(MBEDTLS_URL)/$(MBEDTLS_ZIP)"
	$(Q) curl -O -L $(MBEDTLS_URL)/$(MBEDTLS_ZIP)
{{< /highlight >}}

The build system can download a compressed file containing the Mbed TLS source code directly from the library's repository. Once downloaded, this code will be unpacked into a folder and will be available to be compiled by NuttX.

##### **Applications and Library**

Unlike the previous example, we can see that this Makefile also adds source files to the CSRS variable:

{{< highlight make >}}
CSRCS = $(wildcard $(MBEDTLS_UNPACKLIBDIR)$(DELIM)*.c)
{{< /highlight >}}

Source files from the library folder of the Mbed TLS are added to the `CSRCS` variable. In other words, files from the Mbed TLS library will be compiled even though they are not executable applications *per se*. The Mbed TLS library provides cryptographic APIs to other applications in the system. However, to test the library's functionalities, the Mbed TLS repository also provides test applications, which can be activated through the configurations in `apps/crypto/mbedtls/Kconfig`:

{{< highlight make >}}
# Configuration Applications

ifneq ($(CONFIG_MBEDTLS_APPS),)

MODULE = $(CONFIG_MBEDTLS_APPS)

ifeq ($(CONFIG_MBEDTLS_APP_BENCHMARK),y)

PROGNAME  += $(CONFIG_MBEDTLS_APP_BENCHMARK_PROGNAME)
PRIORITY  += $(CONFIG_MBEDTLS_APP_BENCHMARK_PRIORITY)
STACKSIZE += $(CONFIG_MBEDTLS_APP_BENCHMARK_STACKSIZE)

MAINSRC += $(MBEDTLS_UNPACKPROGDIR)/test/benchmark.c
endif
{{< /highlight >}}

This portion of the Makefile compiles the Mbed TLS benchmark application if selected. Note that if `CONFIG_MBEDTLS_APP_BENCHMARK=y`, the source code in `programs/test/benchmark.c` of the library's repository will be added to `MAINSRC` Similarly, the self-test application in programs/test/selftest.c can be compiled if `CONFIG_MBEDTLS_APP_SELFTEST=y`.

#### Kconfig

The Kconfig file for the Mbed TLS selects, in addition to the library version to be downloaded, the test applications that will also be compiled and configs that may be enabled in the library's config. The full content of the Kconfig file can be found at [`crypto/mbedtls/Kconfig`](https://github.com/apache/nuttx-apps/blob/nuttx-12.5.1/crypto/mbedtls/Kconfig). Part of it is as follows:

{{< highlight shell >}}
menuconfig CRYPTO_MBEDTLS
	bool "Mbed TLS Cryptography Library"
	default n
	---help---
		Enable support for Mbed TLS.

if CRYPTO_MBEDTLS

config MBEDTLS_VERSION
	string "Mbed TLS Version"
	default "3.4.0"

config MBEDTLS_DEBUG_C
	bool "This module provides debugging functions."
	default DEBUG_FEATURES
	---help---
		This module provides debugging functions.

config MBEDTLS_SSL_IN_CONTENT_LEN
	int "Maximum length (in bytes) of incoming plaintext fragments."
	default 16384
	---help---
		Maximum length (in bytes) of incoming plaintext fragments.

config MBEDTLS_SSL_OUT_CONTENT_LEN
	int "Maximum length (in bytes) of outgoing plaintext fragments."
	default 16384
	---help---
		Maximum length (in bytes) of outgoing plaintext fragments.

config MBEDTLS_SSL_SRV_C
	bool "This module is required for SSL/TLS server support."
	default y
	---help---
		This module is required for SSL/TLS server support.

config MBEDTLS_PLATFORM_MEMORY
	bool "Enable the memory allocation layer."
	depends on MBEDTLS_PLATFORM_C
	default n

config MBEDTLS_ENTROPY_HARDWARE_ALT
	bool "Uncomment this macro to let mbed TLS use your own implementation of a hardware entropy collector."
	default n
	depends on DEV_RANDOM
	select MBEDTLS_NO_PLATFORM_ENTROPY

config MBEDTLS_AES_ROM_TABLES
	bool "Store the AES tables in ROM."
	default n

config MBEDTLS_NO_PLATFORM_ENTROPY
	bool "Do not use built-in platform entropy functions."
	default n

config MBEDTLS_ECP_RESTARTABLE
	bool "Enable the restartable ECC."
	depends on MBEDTLS_ECP_C
	default n

config MBEDTLS_SELF_TEST
	bool "Enable the checkup functions (*_self_test)."
	default n
{{< /highlight >}}

#### Make.defs

Finally, the last file in the folder is `Make.defs`. By comparing it with the one of the `Hello World!` example, the Make.defs file of the Mbed TLS additionally defines the header files (.h) of the library to be used by other NuttX applications by adding the content of the mbedtls/include folder to the `CFLAGS` and `CXXFLAGS` variables of the NuttX build system:

{{< highlight make >}}
ifneq ($(CONFIG_CRYPTO_MBEDTLS),)
CONFIGURED_APPS += $(APPDIR)/crypto/mbedtls

# Allows `<mbedtls/<>.h>` import.

CFLAGS += ${INCDIR_PREFIX}$(APPDIR)/crypto/mbedtls/include
CFLAGS += ${INCDIR_PREFIX}$(APPDIR)/crypto/mbedtls/mbedtls/include
CFLAGS += ${DEFINE_PREFIX}MBEDTLS_CONFIG_FILE="<mbedtls/mbedtls_config.h>"

CXXFLAGS += ${INCDIR_PREFIX}$(APPDIR)/crypto/mbedtls/include
CXXFLAGS += ${INCDIR_PREFIX}$(APPDIR)/crypto/mbedtls/mbedtls/include
CXXFLAGS += ${DEFINE_PREFIX}MBEDTLS_CONFIG_FILE="<mbedtls/mbedtls_config.h>"

endif
{{< /highlight >}}

## To Be Continued...

The purpose of this article is to take a look into the NuttX build system. We started by showing how an application can be defined and built using the `nuttx-apps` (the `Hello World!` examples). Also, it was shown how an external library (with its testing applications) - the Mbed TLS - can be compiled for NuttX.

### A Quick Demonstration of Mbed TLS

Please check the Mbed TLS library (and its testing applications) being selected to be built for NuttX on ESP32-S3-DevKit-1 board:

{{< asciinema key=build_mbedtls idleTimeLimit="2" speed="2" poster="npt:0:09" >}}

In the following series of this article, we will port a not-yet available application to NuttX. Stay tuned for the upcoming articles in this series. Any questions, criticisms, or suggestions? Leave your comment on the page :wink:

## Useful Links

- [NuttX Documentation](https://nuttx.apache.org/docs/)
- [NuttX GitHub](https://github.com/apache/nuttx)
- [NuttX channel on Youtube](https://www.youtube.com/nuttxchannel)
- [Developer Mailing List](https://nuttx.apache.org/community/#mailing-list)

[1]: https://github.com/apache/nuttx-apps/tree/nuttx-12.5.1/examples/hello
[2]: https://github.com/apache/nuttx-apps/tree/nuttx-12.5.1?tab=readme-ov-file#application-configuration-file
[3]: https://nuttx.apache.org/docs/12.5.1/guides/customapps.html
[4]: https://github.com/apache/nuttx-apps/tree/nuttx-12.5.1#built-in-applications
