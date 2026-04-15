---
title: "Developing a Rust-based IoT device with AI"
date: 2026-04-20
tags:
  - how-to
  - Rust
  - IoT
  - AI
  - LLM
showAuthor: false
authors:
    - "ricardo-tafas"
summary: "AI assistants are most effective on ESP32 Rust firmware when you supply clear specs, pinned crates, reference implementations (often ESP-IDF C), and a tight verify loop. The article discusses good practices, pitfalls, discipline, and entropy. A brief explanation about the device is also included, along with the repository and all artifacts."
---

---

## 1. Introduction

### 1.1 Contextualization

Large language models (LLMs) and coding agents can speed up firmware development on Espressif SoCs. That applies to **Rust on bare metal**. The crates `esp-hal` and `esp-radio`, the [Embassy project](https://embassy.dev/), and many small protocol crates; they are all there. Yet, we see little adoption of Rust. That includes me. I've recently been learning it, and if pressured to deliver results, I would fall back on the _C_ that I already know; or, depending on the pressure and time available, the Arduino Core for ESP32 framework as well. The same tools I already use, if enhanced by AI, would make me even more productive. But... What about that junior feeling of starting something new? Well... I challenged myself.

This article describes the proto-workflow I used while building a **WiFi + BLE + provisioning** device on top of the ESP-DualKey ESP32-S3–based kit from M5Stack. I call it _proto_ because the workflow is still rough.

### 1.2 About Rust in this Challenge

Rust’s compiler catches many errors that would otherwise appear only on device. That pairs well with AI-generated code: you get **fast iteration in the editor** and **strong feedback from `cargo check`**, provided the model stays inside the right ecosystem (`esp-hal` 1.x, although focused on the newer RISC-V, still supports Espressif Xtensa). It is, then, safe to assume that Rust will benefit greatly from this new LLM-oriented coding world.

The ecosystem has reached milestones that make the story easier to explain to both humans and models. And managers. For example, the `esp-hal 1.0` [announcement](https://developer.espressif.com/blog/2025/10/esp-hal-1/) on the Developer Portal; official and community docs, like the [Rust on ESP Book](https://docs.espressif.com/projects/rust/book/) and the [no_std training](https://docs.espressif.com/projects/rust/no_std-training/), are enough of a foundation for anyone to conclude that yes, it could be used.

### 1.3 What, then?

We get hands-on. But wait, not directly. As with any project, we need to start right. And this is what we will do. Our challenge also includes:

- AI should do the coding. I recognize it types faster than I do.
- I trust AI coding. I'm at a beginner level with Rust, so it probably has more training in writing Rust code than I have.
- Both the AI and I can think about debugging when we face issues.
- Agent Mode is only enabled when we reach a conclusion.
- When we had too many things to do in sequence, we resorted to Planning.
- I'm the _Critical Thinking Capable_ and _Self-Aware_ entity of the duo. All issues are my fault.

I also used Cursor, but other tools and agents would yield a very similar experience. The rest of this note walks through workflow (how we worked with an AI agent), what can go wrong (including Git as undo and entropy as clutter), what we built, and the documents that kept humans and the model aligned.

I'm going to use the M5Stack ESP DualKey development kit. It provides enough ready-to-go peripherals. No breadboard this time.

<figure>
  <img src="./img/img1.webp" alt="Fig.1 - The ESP-DualKey kit." width="50%">
  <figcaption>Fig.1 - The ESP-DualKey kit.</figcaption>
</figure>

---

## 2. Coding with AI workflow

### 2.1 Good specifications

A written **product specification** is the main contract among all the interested parties: the human developer, the firmware, and the assistant. Behaviors, timeouts, SSID and BLE names, LED meanings, reboot rules, gesture timing—everything relevant—should be there. When the specification and the code disagree, you decide whether to fix the code or update the specification—never leave both drifting.

In this task, we collaborated to reach [this specification](https://github.com/rftafas/rust-dualkey-ble-provisioning/blob/main/references/spec/product_spec.md). The assistant can be pointed at it explicitly so refactors stay consistent with intended UX.

### 2.2 Prior working code, independent of language, is a great specification

Some teams treat **prose** as the specification; others treat **source code** (or formal specification) as the only specification that truly matters once the product ships. In practice, you want **both**: prose for intent and review, executable artifacts for precision. And guess: other environments can, or better, _must_ be used as input.

- **Repository source** — The Rust modules under `app/src/` implement the behavior the device actually runs. When prose lags, the source wins until you update the document.
- **ESP-IDF and examples as oracle** — For protocols shared with Espressif’s tooling, C examples are a very detailed specification. Example: WiFi/BLE provisioning for the **ESP BLE Provisioning** app expects **protocomm** behavior compatible with Espressif’s unified provisioning API, which is implemented and documented in ESP-IDF. Keeping a **known-good C reference** (e.g. the `wifi_prov_mgr` example) under the workspace makes it possible to ask: “Does our event order and message handling still match ESP-IDF?”
- **Thin hardware boundary** — GPIO, RMT/LED, radio init, and NVS work best in focused modules the model can reuse instead of rewriting each time. That boundary is part of the “code spec”: stable APIs reduce hallucinated glue.

### 2.3 Tools and scaffolding

Can we ditch everything useful to humans because we have AI? Definitely not. We actually should do the opposite: force the agent to use such tools. Start from **maintained generators and templates** (e.g. **esp-generate**, as in project setup notes). Give the agent the real **`Cargo.toml`**, chip **feature flags**, and **`rust-toolchain.toml`** so it does not invent unstable crate versions. The model makes fewer mistakes and spends less time on dead-end steps.

A **starter prompt**. I added mine, which resided in the empty folder, and instead of moving it later to a proper place, I left it there. Call it “to make it real.” It created the basic project organization, where files should go, tree structure, and it stubbed many guidelines or specifications, either at the repo root or in **editor rules** (e.g. under `.cursor/rules/`), to help impose structure: without that, both humans and AI tend to drift. Tight, enforced conventions reduce entropy and save reasoning for hard problems.


### 2.4 Bounded tasks and collaborative debugging

**It Works on My Machine**

I found uncanny human-like behavior in the AI. It often got stuck in a loop of reading and re-reading code and reasoning that things should work. But my tests indicated otherwise. We have to remember that LLMs are great at languages—programming or natural—and will try to use that strength to brute-force a solution. But... sometimes... it doesn't.

Yet, it told me it should work. I believe it would tell me “it works on my machine,” if it had one. So, I learned a few tricks.

**Good prompts are local**

- “Add a `Signal` from `embassy_sync` to stop the BLE task when provisioning starts; ensure the task exits so the radio can be reused.”
- “Implement sec1 session step Cmd0/Cmd1 matching the binary layout in the IDF example.”

**Poor prompts are unbounded:**

- “Add WiFi and Bluetooth” (too large; the model will glue incompatible layers).

Debugging is **collaborative**. AI is quick to write code but often weak at inventing the next experiment to isolate a bug; it can loop on “it should work.” Humans do that too. Supply **hypotheses and checks**:

- “BT is not connecting. First verify we send the confirmation packets the stack expects; then trace that we always send the packets the protocol specifies.”

In one concrete case, that line of reasoning showed the device was **resetting before a communication window finished** — something easy to miss by reading code alone.

**Tracing is back (and we used a lot of it).**

LLMs read **source** fluently; they are much weaker at knowing what the chip **actually did** last Tuesday. We leaned heavily on **runtime trace**: `log::info!` / `esp-println` on UART, following the provisioning and BLE paths message by message, and correlating resets, timeouts, and handshakes with the spec. That is not optional decoration; it was how we **grounded** the assistant: paste a log excerpt, state what you expected, ask what branch or ordering is wrong.

When static reasoning failed, **step-level debugging** still mattered: **OpenOCD**, **GDB**, single-stepping through the tight spots where “it should work” met reality. The surprise was how much **old-school tracing** improved the collaboration: the AI could diff “what the code says” against “what the trace proves,” instead of both of us staring at the same file. In that sense tracing did not come back as nostalgia—it came back as **shared evidence** between the coder and the evaluator.

### 2.5 Curated examples for the pieces you need

Hunting for **relevant** samples—not a random dump of repos—is what good embedded work has always looked like: a BLE HID snippet here, a SoftAP + HTTP pattern there, an ESP-IDF flow that matches the phone app you must interoperate with. You keep only what maps to **concrete gaps** in your firmware (a driver idiom, a handshake sequence, a task-shutdown pattern).

That habit is the same whether **you** read the example or the **assistant** does. We have long leaned on SDK demos, vendor examples, and half-related GitHub projects to de-risk a tricky corner; pointing the model at those same artifacts is not “cheating,” it is **sharing the same reference desk** you would use alone. A `scratch/` folder (or checked-out upstream trees) is a **living shelf**: prune what misleads, add what matches the next milestone, and ask for diffs against the specific file that models the behavior you want.

### 2.6 Simulation and CI where possible

When graphics or timing interact with hosts, **simulation** plus **automated checks** can shrink debug time. The [Developer Blog](https://developer.espressif.com/blog/) has discussed simulation and AI-assisted debugging in other contexts (e.g. Wokwi-oriented workflows); the same mindset extends to Rust if you invest in reproducible builds and log-based assertions.

---

## 3. Failure modes, Git discipline, and entropy

### 3.1 Git as safety net: same rules as “normal” development

Fast AI edits make it tempting to **skip commits** until “later.” That is how you discover, many times too late, that the assistant **changed or removed code that was already working**. The fix is boring and familiar: treat milestones like any other project. When something **works on the bench** (builds, flashes, passes the scenario you care about), **commit** with a message that says what was verified.

**Tags** help both **you** and the **model** point at a known-good snapshot: “revert to `v0.3-provisioning-ok` and try again from there” is easier than diffing through a long chat. **Stash** is just as useful: try an experimental patch, read the trace, then **pop** or **drop** and move forward without polluting the main line. In other words: Git is not ceremony—it is the **undo stack** for a workflow where the typing partner is fast and not always right.

### 3.2 The Entropy

Models behave a lot like tired humans under deadline: they **take shortcuts**, relax **rigid structure** when a quick test “works,” and then **leave that path in place** because nothing failed yet. A throwaway script lands in whatever folder is open; a reference PDF sits next to the binary because that was convenient; the “real” home for specs and sources in the repo map gets ignored as long as the immediate command succeeds.

That is **entropy**; not malice, just the path of least resistance. The assistant does not naturally optimize for **global** organization; it optimizes for **local** accessibility and the last green check. Left alone, the tree drifts the same way a shared desk drifts unless someone names folders and enforces them.

And much like humans, the AI **does not love cleaning the room**: deleting stale files, moving artifacts into the right `references/` or `scratch/` folder, or admitting that a debug dump should not live in the project root forever. It only does that if told. Yet it **benefits** from a clean room as much as we do—fewer wrong-file edits, fewer “which copy is authoritative?” moments, and easier handoff to the next session (human or model). Entropy is a failure mode you manage with **conventions and periodic tidy-ups**, not something the tool fixes by itself.

### 3.3 Common pitfalls (and how to avoid them)

| Pitfall | Symptom | Mitigation |
|--------|---------|------------|
| **Hallucinated APIs** | Methods that do not exist on the version being used. | Pin versions; paste **real** signatures from `docs.rs` or source into the prompt. |
| **Wrong concurrency model** | Deadlocks, radio busy | Document who owns WiFi/BLE; use explicit shutdown (e.g. signals) before switching modes. |
| **Protocol drift** | App connects but handshake fails | Compare bytes and ordering with ESP-IDF example and official app behavior. |
| **Over-refactoring** | Huge diffs, broken behavior | Instruct the agent: *minimal diff, match existing style*; review per feature. |
| **Timing of events** | Things happen unexpectedly, get stopped, or get cut short | Sometimes, more than reasoning is needed to figure out timing problems; imagination helps catch a tricky situation. |
| **Macaronic Code** | AI won't create structures in the source code. | Be the architect. Don't be afraid to ask it to change the way it implements a particular subsystem; force it to be consistent with good architecture. Rewrite if needed. |

---

## 4. The product I implemented

Now, briefly, this whole idea was to prove to myself that Rust is viable to be used along with AI to build consumer products. The main goal was to make it communicate with MQTT (targeting Home Assistant and IoT) and BLE HID (targeting BT gadget markets).

**Behavior (high level):**
- Pressing a button lights it.
- Colour indicates connection status for BT or Wi-Fi.
- Long presses enable factory reset (both buttons), provisioning, or pairing.

<div style="display: flex; justify-content: space-between;">

  <figure style="width:48%; text-align:center;">
    <img src="./img/img2.webp" alt="Led Red" style="width:100%;">
    <figcaption style="text-align:center;">Red: no connectivity.</figcaption>
  </figure>

  <figure style="width:48%; text-align:center;">
    <img src="./img/img3.webp" alt="Led Green" style="width:100%;">
    <figcaption style="text-align:center;">Green: BT and Wi-Fi up.</figcaption>
  </figure>

</div>


The goal of this section is orientation only; authoritative detail stays in the [root README](https://github.com/rftafas/rust-dualkey-ble-provisioning) and [references/spec/product_spec.md](https://github.com/rftafas/rust-dualkey-ble-provisioning/blob/main/references/spec/product_spec.md).

---

## 5. Documents and artifacts we created

Along the way we accumulated **documentation the assistant could read** and **references it could diff against**:

- **`references/spec/`** — Product behavior, provisioning notes, environment setup (`env_setup.md`), and related design markdown.
- **Root `README.md`** — Operator-facing gestures, LEDs, links, and build hints.
- **[`rust-espressif-ai-starter-prompt.md`](https://github.com/rftafas/rust-dualkey-ble-provisioning/blob/main/rust-espressif-ai-starter-prompt.md)** — High-level project expectations and layout for AI-assisted work.

**Session notes:** During long debug threads, the coding agent often produced structured troubleshooting notes—hypotheses tried, log snippets, “next steps”—much like a human engineer’s lab notebook. That was a surprise: even an AI benefits from a notebook instead of relying on context (i.e. memory) length alone.

**HOWEVER**... There is no debug journal in the repo anymore. It had lived in something like `scratch/debug-session.md` (or a similar name) and was **cleaned** when I asked the AI to “clean out the garbage files.” Neither of us treated that file as worth keeping - we threw away the lab notebook. Shame on us, although this was very developer-like behavior. It reminded me that I was supposed to be the Critical Thinking entity in the team, and I did not do my job on that. Well, to err is human, isn't it?

---

## 6. Conclusion

**AI as an accelerator:** LLMs and agents speed up drafting, refactors, and boilerplate—they are not a substitute for architecture, protocol literacy, or what you see on the wire and in the logs. Speed without tracing, commits, and occasional tidy-up is how you lose afternoons to regressions nobody can bisect.

In practice this felt like pair programming in the usual split: one person codes, the other evaluates. The model **coded**; I **evaluated**—against the spec, reference trees, `cargo check`, UART traces, and the bench. That “evaluator” seat is also where **critical thinking** belongs: questioning shortcuts, reinforcing discipline, taking a long-term view, code sustainability, and alignment with project goals.

**Maintenance.** Touchy subject. Many people criticize the maintainability of AI code. I agree. At the same time, I disagree. Like any other coder, AI is great at writing code according to a specification. We are not removing the brain from the equation; we are removing the typing. And AI is, indeed, a smart typist with excellent awareness of language and memory. Yet it needs a human who understands the project and evaluates whether what is being built achieves the intended results. Code maintenance, then, would speak more of the humans involved than the AI itself.

**Productivity:** The return comes from **small, verifiable steps**, **specs and code that agree**, **Git** (commits and tags as undo points), **examples and notes** the next session can read, and **curbing entropy** so neither you nor the model is always searching the wrong copy of the truth. Last but not least, focus on task completion. Letting it wander around, trusting the brute force of fast code generation, maybe behaving like an infinite monkey, is as good as nothing: the infinite monkey works as long as we have infinite time. We don't—at least, I don't. I found out that it's much better to orient the AI toward getting results faster. And so should you.
