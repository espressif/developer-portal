---
title: "Rust + Embedded: A Development Power Duo"
date: 2023-04-19
showAuthor: false
featureAsset: "img/featured/featured-espressif.webp"
authors:
  - juraj-sadel
tags:
  - Rust
  - Embedded Systems
  - Esp32
  - Rust Programming Language

---
{{< figure
    default=true
    src="img/rust-1.webp"
    >}}

__Beginning of Rust__

> The initial idea of a Rust programming language was born because of an accident. In 2006, in Vancouver, Mr. Graydon Hoare was returning to his apartment but the elevator was again out of order, because of a software bug. Mr. Hoare lived on the 21st floor and as he climbed the stairs, he started thinking “We computer people couldn’t even make an elevator that works without crashing!”. This accident led Mr. Hoare to work on the design of a new programming language he hoped, would be possible to write small, fast code without memory bugs [[1](https://www.technologyreview.com/2023/02/14/1067869/rust-worlds-fastest-growing-programming-language/)].If you are interested in the more detailed and technical history of Rust, please visit [[2](https://blog.rust-lang.org/2015/05/15/Rust-1.0.html)] and [[3](https://blog.rust-lang.org/2019/05/15/4-Years-Of-Rust.html)].

Almost eighteen years later, Rust has become the hottest new language in the world with more and more people interested every year. In __Q1 2020__  there were around __600,000__  Rust developers and in __Q1 2022__  the number increased to __2.2 million__  [[4](https://yalantis.com/blog/rust-market-overview/)]. Huge tech companies like Mozilla, Dropbox, Cloudflare, Discord, Facebook(Meta), Microsoft, and others are using Rust in their codebase.

{{< figure
    default=true
    src="img/rust-2.webp"
    >}}

In the past six years, the Rust language remained the most “loved” programming language based on [[5](https://survey.stackoverflow.co/2021#most-loved-dreaded-and-wanted-language-love-dread)].

__Programming languages in Embedded development__

Embedded development is not as popular as web development or desktop development and these are a few examples of why this might be the case:

- __Hardware constraints__ : The embedded systems will most likely have limited hardware resources, such as performance and memory. This can make it more challenging to develop software for these systems.
- __Limited and niche market__ : The embedded market is more limited than web and desktop applications and it can make it less financially rewarding for developers specializing in embedded programming.
- __Specialized low-level knowledge__ : Specialized knowledge of concrete hardware and low-level programming languages is a must-to-have in embedded development
- __Longer development cycles__ : Developing software for embedded systems can take longer than developing software for web or desktop applications, due to the need for testing and optimization of the code for the specific hardware requirements.
- __Low-level programming languages__ : These languages, such as assembly or C do not provide much of an abstraction to the developer and provide direct access to hardware resources and memory which will lead to memory bugs.

These are only a few examples of why and how is embedded development unique and is not as famous and lucrative for young programmers as web development. If you are used to the most common and modern programming languages like Python, JavaScript, or C# where you do not have to count every processor cycle and every kilobyte used in memory, it is a very brutal change to start with embedded, that can be very discouraging for coming into the embedded world not even for beginners but also experienced web/desktop/mobile developers. That is why it would be very interesting and needed to have a modern programming language in embedded development.

__Why Rust?__

Rust is a modern and relatively young language with a focus on memory and thread safety that with an intention to produce reliable and secure software. Also, Rust's support for concurrency and parallelism is particularly relevant for embedded development, where efficient use of resources is critical. Rust's growing popularity and ecosystem make it an attractive option for developers, especially those who are looking for a modern language that is both efficient and safe. These are the main reasons why Rust is becoming an increasingly popular choice not only in embedded development but especially for projects that prioritize __safety__ , __security__ , and __reliability__ .

__Advantages of Rust (compared with C and C++)__

- __Memory safety__ : Rust offers strong memory safety guarantees through its __ownership__  and __borrowing__  system which is very helpful in preventing common memory-related bugs like __null pointer dereferences__  or __buffer overflow__ , for example. In other words, Rust guarantees __memory safety__  at compile time through ownership and borrowing system. This is especially important in embedded development where memory/resource limitations can make such bugs more challenging to detect and resolve.
- __Concurrency__ : Rust provides excellent support for zero-cost abstractions and safe concurrency and multi-threading, with a built-in __async/await__  syntax and a powerful types system that prevents common concurrency bugs like data races. This can make it easier to write safe and efficient concurrent code not only in embedded systems.
- __Performance__ : Rust is designed for high performance and can go toe-to-toe with C and C++ in performance measures while still providing strong memory safety guarantees and concurrency support.
- __Readability__ : Rust’s syntax is designed to be more readable and less error-prone than C and C++, with features like pattern matching, type inference, and functional programming constructs. This can make it easier to write and maintain code, especially for larger and more complex projects.
- __Growing ecosystem__ : Rust has a growing ecosystem of libraries (crates), tools, and resources for (not only) embedded development, which can make it easier to get started with Rust and find necessary support and resources for a particular project.
- __Package manager and build system__ : Rust distribution includes an official tool called __Cargo,__ which is used____ to automate the build, test, and publish process together with creating a new project and managing its dependencies.

__Disadvantages of Rust (compared with C and C++)__

On the other hand, Rust is not a perfect language and has also some disadvantages over other programming languages (not only C and C++).

- __Learning curve__ : Rust has a steeper learning curve than many programming languages, including C. Its unique features, such as already mentioned ownership and borrowing, may take some time to understand and get used to and therefore are more challenging to get started with Rust.
- __Compilation time__ : Rust’s advanced type system and borrow checker can result in longer compilation times compared to other languages, especially for large projects.
- __Tooling__ : While Rust’s ecosystem is growing rapidly, it may not yet have the same level of tooling support as more established programming languages. For example, C and C++ have been around for decades and have a vast codebase. This can make it more challenging to find and use the right tools for a particular project.
- __Lack of low-level control__ : Rust’s safety features can sometimes limit low-level control to C and C++. This can make it more challenging to perform certain low-level optimizations or interact with hardware directly, but it is possible.
- __Community size__ : Rust is still a relatively new programming language compared to more established languages like C and C++, which means that it may have a smaller community of developers and contributors, and fewer resources, libraries, and tools.

Overall, Rust offers many advantages over traditional embedded development languages like C and C++, including memory safety, concurrency support, performance, code readability, and a growing ecosystem. As a result, Rust is becoming an increasingly popular choice for embedded development, especially for projects that prioritize safety, security, and reliability. The disadvantages of Rust compared to C and C++ tend to be related to Rust’s relative newness as a language and its unique features. However, many developers find that Rust’s advantages make it a compelling choice for certain projects.

---

__How can Rust run?__

There are several ways to run the Rust based firmware, depending on the environment and requirements of the application. The Rust based firmware can typically be used in one of two modes: hosted-environment or bare-metal, let’s look at what these are.

__What is hosted-environment?__

In Rust, the hosted-environment is close to a normal PC environment [[6](https://docs.rust-embedded.org/book/intro/no-std.html#hosted-environments)] which means, you are provided with an Operating System. With the operating system, it is possible to build the [*Rust standard library (std)*](https://doc.rust-lang.org/std/). The std refers to the standard library, which can be seen as a collection of modules and types that are included with every Rust installation. The std provides a set of multiple functionalities for building Rust programs, including __data structures__ , __networking__ , __mutexes and other synchronization primitives__ , __input/output__ , and more.

With the hosted-environmentapproach you can use the functionality from the C-based development framework called the [*ESP-IDF*](https://github.com/espressif/esp-idf) because it provides a [*newlib*](https://sourceware.org/newlib/)[* *](https://sourceware.org/newlib/)environment that is “powerful” enough to build the Rust standard library on top of it. In other words, with the hosted-environment (sometimes called just std) approach, we use the ESP-IDF as an operating system and build the Rust application on top of it. In this way, we can use all the standard library features listed above and also already implement C functionality from the ESP-IDF API.

An example, how a [blinky example](https://github.com/esp-rs/esp-idf-hal/blob/master/examples/blinky.rs) running on top of ESP-IDF (FreeRTOS) may look like (more examples can be found in [esp-idf-hal](https://github.com/esp-rs/esp-idf-hal/tree/master/examples)):

```rust
// Import peripherals we will use in the example
use esp_idf_hal::delay::FreeRtos;
use esp_idf_hal::gpio::*;
use esp_idf_hal::peripherals::Peripherals;

// Start of our main function i.e entry point of our example
fn main() -> anyhow::Result<()> {
    // Apply some required ESP-IDF patches
    esp_idf_sys::link_patches();

    // Initialize all required peripherals
    let peripherals = Peripherals::take().unwrap();

    // Create led object as GPIO4 output pin
    let mut led = PinDriver::output(peripherals.pins.gpio4)?;

    // Infinite loop where we are constantly turning ON and OFF the LED every 500ms
    loop {
        led.set_high()?;
        // we are sleeping here to make sure the watchdog isn't triggered
        FreeRtos::delay_ms(1000);

        led.set_low()?;
        FreeRtos::delay_ms(1000);
    }
}
```

__When you might want to use hosted-environment__

- __Rich functionality__ : If your embedded system requires lots of functionality like support for networking protocols, file I/O, or complex data structures, you will likely want to use hosted-environment approach because std libraries provide a wide range of functionality that can be used to build complex applications relatively quickly and efficiently
- __Portability__ : The std crate provides a standardized set of APIs that can be used across different platforms and architectures, making it easier to write code that is portable and reusable.
- __Rapid development__ : The std crate provides a rich set of functionality that can be used to build applications quickly and efficiently, without worrying about low-level details.

__What is bare-metal?__

Bare-metal means we do not have any operating system to work with. When a Rust program is compiled with the no_std attribute, it means that the program will not have access to certain features (some are listed in the std chapter). This does not necessarily mean that you cannot use networking or complex data structures with no_std, you can do anything without std that you can do with std but it is more complex and challenging. no_std programs rely on a set of [core](https://doc.rust-lang.org/beta/core/index.html) language features that are available in all Rust environments, for example, data types, control structures or low-level memory management. This approach is useful for embedded programming where memory usage is often constrained and low-level control over hardware is required.

An example, how a [blinky example](https://github.com/esp-rs/esp-hal/tree/main) running on bare-metal (no operating system) may look like (more examples can be found in [esp-hal](https://github.com/esp-rs/esp-hal/tree/main)):

```rust
#![no_std]
#![no_main]

// Import peripherals we will use in the example
use esp32c3_hal::{
    clock::ClockControl,
    gpio::IO,
    peripherals::Peripherals,
    prelude::*,
    timer::TimerGroup,
    Delay,
    Rtc,
};
use esp_backtrace as _;

// Set a starting point for program execution
// Because this is `no_std` program, we do not have a main function
#[entry]
fn main() -> ! {
    // Initialize all required peripherals
    let peripherals = Peripherals::take();
    let mut system = peripherals.SYSTEM.split();
    let clocks = ClockControl::boot_defaults(system.clock_control).freeze();

    // Disable the watchdog timers. For the ESP32-C3, this includes the Super WDT,
    // the RTC WDT, and the TIMG WDTs.
    let mut rtc = Rtc::new(peripherals.RTC_CNTL);
    let timer_group0 = TimerGroup::new(
        peripherals.TIMG0,
        &clocks,
        &mut system.peripheral_clock_control,
    );
    let mut wdt0 = timer_group0.wdt;
    let timer_group1 = TimerGroup::new(
        peripherals.TIMG1,
        &clocks,
        &mut system.peripheral_clock_control,
    );
    let mut wdt1 = timer_group1.wdt;

    rtc.swd.disable();
    rtc.rwdt.disable();
    wdt0.disable();
    wdt1.disable();

    // Set GPIO4 as an output, and set its state high initially.
    let io = IO::new(peripherals.GPIO, peripherals.IO_MUX);
    // Create led object as GPIO4 output pin
    let mut led = io.pins.gpio5.into_push_pull_output();

    // Turn on LED
    led.set_high().unwrap();

    // Initialize the Delay peripheral, and use it to toggle the LED state in a
    // loop.
    let mut delay = Delay::new(&clocks);

    // Infinite loop where we are constantly turning ON and OFF the LED every 500ms
    loop {
        led.toggle().unwrap();
        delay.delay_ms(500u32);
    }
}
```

__When you might want to use bare-metal__

- __Small memory footprint__ : If your embedded system has limited resources and needs to have a small memory footprint, you will likely want to use bare-metal because std features add a significant amount of final binary size and compilation time.
- __Direct hardware control__ : If your embedded system requires more direct control over the hardware, such as low-level device drivers or access to specialized hardware features you will likely want to use bare-metal because std adds abstractions that can make it harder to interact directly with the hardware.
- __Real-time constraints or time-critical applications__ : If your embedded system requires real-time performance or low-latency response times because std can introduce unpredictable delays and overhead that can affect real-time performance.
- __Custom requirements__ : bare-metal allows more customization and fine-grained control over the behavior of an application, which can be useful in specialized or non-standard environments.

{{< figure
    default=true
    src="img/rust-3.webp"
    >}}

__TL;DR Should I switch from C to Rust?__

If you are starting a new project or a task where memory safety or concurrency is required, it may be worth considering moving from C to Rust. However, if your project is already well-established and functional in C, the benefits of switching to Rust may not outweigh the costs of rewriting and retesting your whole codebase. In this case, you can consider keeping the current C codebase and start writing and adding new features, modules, and functionality in Rust — it is relatively simple to call C functions from Rust code. [It is also possible to write ESP-IDF components in Rust](https://github.com/espressif/rust-esp32-example). In the end, the final decision to move from C to Rust should be based on a careful evaluation of your specific needs and the trade-offs involved.

References1. [How Rust went from a side project to the world’s most-loved programming language | MIT Technology Review](https://www.technologyreview.com/2023/02/14/1067869/rust-worlds-fastest-growing-programming-language/)2. [Announcing Rust 1.0 | Rust Blog (rust-lang.org)](https://blog.rust-lang.org/2015/05/15/Rust-1.0.html)3. [4 years of Rust | Rust Blog (rust-lang.org)](https://blog.rust-lang.org/2019/05/15/4-Years-Of-Rust.html)

4. [The state of the Rust market in 2023 (yalantis.com)](https://yalantis.com/blog/rust-market-overview/)

5. [Stack Overflow Developer Survey 2021](https://survey.stackoverflow.co/2021#most-loved-dreaded-and-wanted-language-love-dread)

6. [https://docs.rust-embedded.org/book/intro/no-std.html#hosted-environments](https://docs.rust-embedded.org/book/intro/no-std.html#hosted-environments)
