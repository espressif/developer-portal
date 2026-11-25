---
title: "Introducing ESP ZeroCode AI"
date: "2026-11-27"
summary: "ESP ZeroCode AI is a browser-based development studio for Espressif devices. Describe a device in plain words, and it writes the product specification, builds and reviews a complete ESP-IDF project, tests it in an emulator, and guides you through checks on real hardware, with nothing to set up on your computer."
authors:
  - "chirag-atal"
  - "kedar-sovani"
  - "amey-inamdar"
tags:
  - ESP-IDF
  - beginner
  - announcement
  - zero-code
  - AI
---

AI can turn a prompt into embedded code. Getting that code to work on a specific board is harder. Pins, peripherals, memory limits, connectivity stacks and physical behavior all matter. Even firmware that compiles cleanly may not do what its creator intended.

We are excited to introduce ESP ZeroCode AI, built to close that gap. It does not stop at code: it works out what the device should do, writes the firmware for your board, has it reviewed and tested, and then helps you check it on the real hardware. Everything happens in the browser.

Here is the whole journey in five steps. The tour below is interactive: click **Next** and **Back**, or the dots, to step through it.

<!-- The ESP ZeroCode AI tour: five click-through slides. Self-contained: its CSS is scoped to .zct, "not-prose" keeps the theme's typography out. -->
<style>
.zct{--grad:linear-gradient(90deg,#3283f2,#8d75d3,#ec3f33);background:#15131c;border-radius:16px;overflow:hidden;color:#f4f2f8;display:flex;flex-wrap:wrap;margin:2rem 0;font-family:inherit;line-height:normal}
.zct-ill{flex:1 1 280px;min-width:0;background:radial-gradient(70% 55% at 12% 8%,rgba(50,131,242,.42) 0%,rgba(50,131,242,0) 70%),radial-gradient(60% 55% at 92% 92%,rgba(236,63,51,.36) 0%,rgba(236,63,51,0) 70%),radial-gradient(80% 60% at 60% 45%,rgba(141,117,211,.34) 0%,rgba(141,117,211,0) 70%),#ebe6f7}
.zct-box{position:relative;width:100%;padding-top:88.9%}
.zct-box svg{position:absolute;inset:0;width:100%;height:100%;margin:0;opacity:0;transition:opacity .3s ease;font-family:inherit}
.zct-box svg.on{opacity:1}
.zct-g{opacity:0;transform:translateY(10px);transition:opacity .5s ease,transform .5s ease}
.zct-box svg.on .zct-g{opacity:1;transform:none;transition-delay:var(--d)}
.zct-copy{flex:1 1 280px;min-width:0;padding:28px 28px 20px;display:flex;flex-direction:column;min-height:300px}
.zct-txt{display:grid}
.zct-s{grid-area:1/1;opacity:0;visibility:hidden;transition:opacity .35s ease,visibility .35s}
.zct-s.on{opacity:1;visibility:visible}
.zct-eb{display:inline-block;font-size:12px;letter-spacing:.14em;text-transform:uppercase;font-weight:700;background:var(--grad);-webkit-background-clip:text;background-clip:text;color:transparent}
.zct-h{font-size:24px;line-height:1.2;font-weight:700;margin:10px 0 14px;color:#f4f2f8}
.zct-s p{font-size:15px;line-height:1.55;color:#b6b1c6;margin:0 0 10px}
.zct-bar{display:flex;flex-wrap:wrap;align-items:center;gap:10px;margin-top:auto;padding-top:14px;border-top:1px solid rgba(255,255,255,.1)}
.zct-dots{display:flex;gap:6px}
.zct-dots button{width:8px;height:8px;border-radius:4px;border:0;padding:0;cursor:pointer;background:#5b5670;transition:width .3s ease}
.zct-dots button.on{width:22px;background:var(--grad)}
.zct-back{margin-left:auto}
.zct-btn{border:1px solid rgba(255,255,255,.22);background:transparent;color:#f4f2f8;border-radius:999px;padding:7px 16px;font-size:13px;font-weight:600;cursor:pointer;font-family:inherit;white-space:nowrap;text-decoration:none;line-height:1.2}
.zct-btn:disabled{opacity:.4;cursor:default}
.zct-fw{display:grid}
.zct-fw>*{grid-area:1/1;text-align:center}
.zct-fw .off{visibility:hidden}
.zct-btn.p{border-color:transparent;background:var(--grad);color:#fff}
.zct-btn.p:hover{color:#fff;text-decoration:none}
.zct-btn:focus-visible,.zct-dots button:focus-visible{outline:2px solid #8d75d3;outline-offset:2px}
@media (max-width:420px){.zct-copy{padding:22px 20px 16px}.zct-btn{padding:7px 13px}.zct-bar{gap:8px}}
@media (prefers-reduced-motion:reduce){.zct *{transition:none!important}}
</style>
<div class="zct not-prose" id="zc-tour" role="region" aria-roledescription="carousel" aria-label="ESP ZeroCode AI tour">
<div class="zct-ill"><div class="zct-box">
<svg class="zct-sc on" viewBox="0 0 450 400" role="img" aria-label="Describe: a chat with the Product Expert"><defs><linearGradient id="zct-g1" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#3283f2"/><stop offset="0.6" stop-color="#6f79dd"/><stop offset="1" stop-color="#8d75d3"/></linearGradient></defs><g class="zct-g" style="--d:0.1s"><text x="420" y="62" text-anchor="end" font-size="11.5" fill="#6d6880">You</text><rect x="140" y="72" width="280" height="92" rx="18" fill="url(#zct-g1)"/><text x="160" y="104" font-size="14" fill="#fff">A porch light that turns on at</text><text x="160" y="126" font-size="14" fill="#fff">dusk, dims after midnight and</text><text x="160" y="148" font-size="14" fill="#fff">works with Apple Home.</text></g><g class="zct-g" style="--d:0.6s"><circle cx="46" cy="206" r="16" fill="url(#zct-g1)"/><text x="46" y="211" text-anchor="middle" font-size="14" font-weight="700" fill="#fff">Z</text><text x="72" y="211" font-size="11.5" fill="#6d6880">ESP ZeroCode AI</text><rect x="30" y="228" width="300" height="72" rx="18" fill="#fff" stroke="#ebe7f5"/><text x="50" y="258" font-size="14" fill="#1c1a26">Got it. One quick question first:</text><text x="50" y="280" font-size="14" fill="#1c1a26">how should it connect?</text></g><g class="zct-g" style="--d:1s"><rect x="30" y="318" width="84" height="34" rx="17" fill="#fff" stroke="#e6e1f3"/><text x="72" y="340" text-anchor="middle" font-size="13" fill="#1c1a26">Wi-Fi</text><rect x="124" y="318" width="96" height="34" rx="17" fill="#f3f0ff" stroke="#8d75d3" stroke-width="1.5"/><text x="172" y="340" text-anchor="middle" font-size="13" font-weight="600" fill="#1c1a26">Thread</text></g></svg>
<svg class="zct-sc" viewBox="0 0 450 400" role="img" aria-label="Spec: a spec card and a wiring diagram"><g class="zct-g" style="--d:0.1s"><rect x="24" y="36" width="210" height="150" rx="14" fill="#fff" stroke="#ebe7f5"/><text x="44" y="66" font-size="13" font-weight="600" fill="#1c1a26">Spec</text><g><circle cx="52" cy="94" r="9" fill="#22a06b"/><path d="M48 94l3 3l5 -6" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></g><text x="70" y="98" font-size="12.5" fill="#1c1a26">Turns on at dusk</text><g><circle cx="52" cy="124" r="9" fill="#22a06b"/><path d="M48 124l3 3l5 -6" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></g><text x="70" y="128" font-size="12.5" fill="#1c1a26">Dims after midnight</text><g><circle cx="52" cy="154" r="9" fill="#22a06b"/><path d="M48 154l3 3l5 -6" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></g><text x="70" y="158" font-size="12.5" fill="#1c1a26">Works with Apple Home</text></g><g class="zct-g" style="--d:0.35s"><rect x="270" y="36" width="150" height="200" rx="10" fill="#2a2838"/><circle cx="282" cy="60" r="3" fill="#c9b458"/><circle cx="408" cy="60" r="3" fill="#c9b458"/><circle cx="282" cy="82" r="3" fill="#c9b458"/><circle cx="408" cy="82" r="3" fill="#c9b458"/><circle cx="282" cy="104" r="3" fill="#c9b458"/><circle cx="408" cy="104" r="3" fill="#c9b458"/><circle cx="282" cy="126" r="3" fill="#c9b458"/><circle cx="408" cy="126" r="3" fill="#c9b458"/><circle cx="282" cy="148" r="3" fill="#c9b458"/><circle cx="408" cy="148" r="3" fill="#c9b458"/><circle cx="282" cy="170" r="3" fill="#c9b458"/><circle cx="408" cy="170" r="3" fill="#c9b458"/><circle cx="282" cy="192" r="3" fill="#c9b458"/><circle cx="408" cy="192" r="3" fill="#c9b458"/><circle cx="282" cy="214" r="3" fill="#c9b458"/><circle cx="408" cy="214" r="3" fill="#c9b458"/><rect x="310" y="96" width="70" height="70" rx="6" fill="#3a3750"/><text x="345" y="135" text-anchor="middle" font-size="10.5" fill="#f4f2f8">ESP32-C6</text><text x="345" y="229" text-anchor="middle" font-size="10.5" fill="#b6b1c6">ESP32-C6 DevKit</text></g><g class="zct-g" style="--d:0.65s" fill="none" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M408 104 H436 V330 H404" stroke="#3283f2"/><path d="M282 148 H252 V320 H150" stroke="#8d75d3"/><path d="M330 236 V326 H320" stroke="#ec3f33"/></g><g class="zct-g" style="--d:0.5s"><circle cx="390" cy="330" r="24" fill="#ec3f33" fill-opacity="0.18"/><circle cx="390" cy="330" r="13" fill="#ec3f33"/><text x="390" y="370" text-anchor="middle" font-size="11.5" fill="#6d6880">LED</text><circle cx="136" cy="320" r="14" fill="#3a3750"/><circle cx="136" cy="320" r="7" fill="#8d75d3"/><text x="136" y="358" text-anchor="middle" font-size="11.5" fill="#6d6880">Button</text><rect x="280" y="312" width="40" height="28" rx="4" fill="#3a3750"/><circle cx="292" cy="326" r="5" fill="#f2c94c"/><text x="300" y="358" text-anchor="middle" font-size="11.5" fill="#6d6880">Light sensor</text></g></svg>
<svg class="zct-sc" viewBox="0 0 450 400" role="img" aria-label="Build: writing, compiling, review and test"><defs><linearGradient id="zct-g3" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#3283f2"/><stop offset="0.55" stop-color="#8d75d3"/><stop offset="1" stop-color="#ec3f33"/></linearGradient><marker id="zct-arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0 0L10 5L0 10z" fill="#6d6880"/></marker></defs><g class="zct-g" style="--d:0.1s"><rect x="40" y="46" width="370" height="52" rx="12" fill="#fff" stroke="#ebe7f5"/><text x="60" y="69" font-size="13" font-weight="600" fill="#1c1a26">Writing</text><text x="60" y="87" font-size="11.5" fill="#6d6880">Firmware Expert, checked as it writes</text><g><circle cx="386" cy="72" r="9" fill="#22a06b"/><path d="M382 72l3 3l5 -6" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></g></g><g class="zct-g" style="--d:0.3s"><rect x="40" y="114" width="370" height="52" rx="12" fill="#fff" stroke="#ebe7f5"/><text x="60" y="137" font-size="13" font-weight="600" fill="#1c1a26">Compiling</text><text x="60" y="155" font-size="11.5" fill="#6d6880">a real ESP-IDF build</text><g><circle cx="386" cy="140" r="9" fill="#22a06b"/><path d="M382 140l3 3l5 -6" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></g></g><g class="zct-g" style="--d:0.5s"><rect x="40" y="182" width="370" height="52" rx="12" fill="#fff" stroke="#ebe7f5"/><text x="60" y="205" font-size="13" font-weight="600" fill="#1c1a26">Review</text><text x="60" y="223" font-size="11.5" fill="#6d6880">a separate reviewer reads the change</text><rect x="300" y="198" width="56" height="20" rx="10" fill="#fde7c8"/><text x="328" y="212" text-anchor="middle" font-size="11" font-weight="600" fill="#8a5a00">1 fix</text><g><circle cx="386" cy="208" r="9" fill="#22a06b"/><path d="M382 208l3 3l5 -6" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></g></g><g class="zct-g" style="--d:0.7s"><rect x="40" y="250" width="370" height="52" rx="12" fill="#fff" stroke="#ebe7f5"/><text x="60" y="273" font-size="13" font-weight="600" fill="#1c1a26">Test</text><text x="60" y="291" font-size="11.5" fill="#6d6880">boots and runs on the emulator</text><g><circle cx="386" cy="276" r="9" fill="#22a06b"/><path d="M382 276l3 3l5 -6" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></g></g><g class="zct-g" style="--d:0.9s"><path d="M40 208 H24 V72 H36" fill="none" stroke="#6d6880" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#zct-arr)"/></g><g class="zct-g" style="--d:1.1s"><rect x="125" y="322" width="200" height="40" rx="20" fill="url(#zct-g3)"/><text x="225" y="347" text-anchor="middle" font-size="13" font-weight="600" fill="#fff">Flash image ready</text></g></svg>
<svg class="zct-sc" viewBox="0 0 450 400" role="img" aria-label="Run: the virtual device in the browser, or your own board"><g class="zct-g" style="--d:0.1s"><rect x="24" y="30" width="402" height="230" rx="12" fill="#fff" stroke="#ebe7f5"/><path d="M24 56 V42 Q24 30 36 30 H414 Q426 30 426 42 V56 Z" fill="#f3f0ff"/><circle cx="42" cy="43" r="4" fill="#f28b82"/><circle cx="56" cy="43" r="4" fill="#fbd38d"/><circle cx="70" cy="43" r="4" fill="#9ae6b4"/><text x="225" y="47" text-anchor="middle" font-size="10.5" fill="#6d6880">esp-zerocode.ai</text><rect x="50" y="80" width="110" height="150" rx="8" fill="#2a2838"/><rect x="75" y="120" width="60" height="60" rx="5" fill="#3a3750"/><path d="M160 110 H186" stroke="#3283f2" stroke-width="2.5"/><path d="M160 196 H184" stroke="#8d75d3" stroke-width="2.5"/><circle cx="200" cy="196" r="14" fill="#3a3750"/><circle cx="200" cy="196" r="7" fill="#8d75d3"/><text x="200" y="228" text-anchor="middle" font-size="11.5" fill="#6d6880">Press</text></g><g class="zct-g" style="--d:0.5s"><circle cx="200" cy="110" r="26" fill="#ec3f33" fill-opacity="0.2"/><circle cx="200" cy="110" r="12" fill="#ec3f33"/><text x="200" y="152" text-anchor="middle" font-size="11.5" fill="#6d6880">LED on</text></g><g class="zct-g" style="--d:0.7s" font-family="ui-monospace, Menlo, monospace" font-size="10.5"><rect x="250" y="72" width="160" height="172" rx="8" fill="#1c1a26"/><text x="262" y="98" fill="#b6b1c6">I (312) app: boot</text><text x="262" y="120" fill="#b6b1c6">I (845) wifi: up</text><text x="262" y="142" fill="#7ee2a8">I (902) light: on</text><text x="262" y="164" fill="#b6b1c6">I (1210) btn: press</text><text x="262" y="186" fill="#7ee2a8">I (1214) light: dim</text></g><g class="zct-g" style="--d:0.95s"><text x="24" y="298" font-size="13" font-weight="600" fill="#1c1a26">Or flash your own board over USB</text><path d="M120 322 C 170 370, 250 330, 300 342" fill="none" stroke="#6d6880" stroke-width="3" stroke-linecap="round"/><rect x="96" y="314" width="24" height="16" rx="3" fill="#6d6880"/><rect x="300" y="318" width="110" height="48" rx="6" fill="#2a2838"/><text x="355" y="346" text-anchor="middle" font-size="11.5" fill="#f4f2f8">Your board</text></g></svg>
<svg class="zct-sc" viewBox="0 0 450 400" role="img" aria-label="Share: publish a product and see its forks"><defs><linearGradient id="zct-g5" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#3283f2"/><stop offset="0.55" stop-color="#8d75d3"/><stop offset="1" stop-color="#ec3f33"/></linearGradient></defs><g class="zct-g" style="--d:0.1s"><rect x="110" y="30" width="230" height="150" rx="14" fill="#fff" stroke="#ebe7f5"/><rect x="126" y="46" width="56" height="56" rx="10" fill="url(#zct-g5)"/><text x="194" y="68" font-size="14" font-weight="700" fill="#1c1a26">Porch Light</text><text x="194" y="88" font-size="11.5" fill="#6d6880">@you, ESP32-C6</text><rect x="126" y="116" width="60" height="22" rx="11" fill="#f3f0ff"/><text x="156" y="131" text-anchor="middle" font-size="11" fill="#1c1a26">Matter</text><rect x="194" y="116" width="60" height="22" rx="11" fill="#f3f0ff"/><text x="224" y="131" text-anchor="middle" font-size="11" fill="#1c1a26">Source</text><text x="126" y="164" font-size="11.5" fill="#6d6880">Try it, flash it, fork it</text></g><g class="zct-g" style="--d:0.5s" fill="none" stroke="#8d75d3" stroke-width="2" stroke-dasharray="5 4"><path d="M225 180 V214 H130 V236"/><path d="M225 214 H320 V236"/></g><g class="zct-g" style="--d:0.7s"><rect x="40" y="236" width="180" height="64" rx="12" fill="#fff" stroke="#ebe7f5"/><text x="56" y="262" font-size="12.5" font-weight="600" fill="#1c1a26">Porch Light + motion</text><text x="56" y="282" font-size="11" fill="#6d6880">forked by @maker</text><rect x="230" y="236" width="180" height="64" rx="12" fill="#fff" stroke="#ebe7f5"/><text x="246" y="262" font-size="12.5" font-weight="600" fill="#1c1a26">Garden Light</text><text x="246" y="282" font-size="11" fill="#6d6880">forked by @another</text></g><g class="zct-g" style="--d:0.95s"><rect x="125" y="326" width="200" height="40" rx="20" fill="url(#zct-g5)"/><text x="225" y="351" text-anchor="middle" font-size="13" font-weight="600" fill="#fff">Try it in your browser</text></g></svg>
</div></div>
<div class="zct-copy">
<div class="zct-txt" aria-live="polite">
<div class="zct-s on"><div class="zct-eb">Describe</div><div class="zct-h">Start with a sentence, not a datasheet.</div><p>Describe your device in plain words: what it senses, what it does, what it works with.</p><p>The Product Expert asks a few quick questions, then gets to work.</p></div>
<div class="zct-s" aria-hidden="true"><div class="zct-eb">Spec</div><div class="zct-h">A spec and wiring you agree to.</div><p>The Product Expert writes down the features, controls and power-up behavior in plain words.</p><p>It draws the wiring diagram on the real pins of your board.</p></div>
<div class="zct-s" aria-hidden="true"><div class="zct-eb">Build</div><div class="zct-h">Written, built, reviewed and tested.</div><p>The Firmware Expert writes the code and builds it with ESP-IDF in the cloud.</p><p>A reviewer and the emulator check it. Anything that fails goes back with the evidence.</p></div>
<div class="zct-s" aria-hidden="true"><div class="zct-eb">Run</div><div class="zct-h">Try it in your browser, then on your desk.</div><p>Run boots the real image on a virtual device, wired like your diagram.</p><p>Or flash your own board over USB, and the Testing Expert checks it with you.</p></div>
<div class="zct-s" aria-hidden="true"><div class="zct-eb">Share</div><div class="zct-h">Publish it. Fork it.</div><p>Share the firmware, or the full source, with the Community.</p><p>Anyone can try it in their browser, flash it, or fork it into their own.</p></div>
</div>
<div class="zct-bar"><div class="zct-dots"><button type="button" aria-label="Slide 1 of 5: Describe" class="on"></button><button type="button" aria-label="Slide 2 of 5: Spec"></button><button type="button" aria-label="Slide 3 of 5: Build"></button><button type="button" aria-label="Slide 4 of 5: Run"></button><button type="button" aria-label="Slide 5 of 5: Share"></button></div><button type="button" class="zct-btn zct-back" data-go="-1" disabled>Back</button><span class="zct-fw"><button type="button" class="zct-btn p" data-go="1">Next</button><a class="zct-btn p off" href="https://esp-zerocode.ai" target="_blank" rel="noopener">Try it now</a></span></div>
</div>
</div>
<script>
(() => {
  const root = document.getElementById('zc-tour'); if (!root) return
  const sc = root.querySelectorAll('.zct-box svg'), tx = root.querySelectorAll('.zct-s'), dots = root.querySelectorAll('.zct-dots button')
  const back = root.querySelector('[data-go="-1"]'), next = root.querySelector('[data-go="1"]'), cta = root.querySelector('a.zct-btn')
  const n = sc.length; let i = 0
  const go = k => {
    i = Math.max(0, Math.min(n - 1, k))
    sc.forEach((e, j) => e.classList.toggle('on', j === i))
    tx.forEach((e, j) => { e.classList.toggle('on', j === i); e.toggleAttribute('aria-hidden', j !== i) })
    dots.forEach((e, j) => e.classList.toggle('on', j === i))
    back.disabled = i === 0; next.classList.toggle('off', i === n - 1); cta.classList.toggle('off', i !== n - 1)
  }
  dots.forEach((e, j) => e.addEventListener('click', () => go(j)))
  back.addEventListener('click', () => go(i - 1)); next.addEventListener('click', () => go(i + 1))
  root.addEventListener('keydown', e => { if (e.key === 'ArrowRight') go(i + 1); else if (e.key === 'ArrowLeft') go(i - 1) })
})()
</script>

## Experts working together

ESP ZeroCode AI is not only about writing code. Its aim is a better product at the end.

The **Product Expert** asks clarifying questions and captures the intended behavior, hardware and wiring. Early users have told us this conversation is one of the most enlightening parts of the experience: it brings up decisions about their product that they had not thought of yet.

The **Firmware Expert** writes the ESP-IDF source, compiles it for the target and has the code reviewed.

The **Testing Expert** checks the behavior on an emulator and guides testing on real hardware. When a test uncovers a problem, the findings go back to the Firmware Expert to fix.

{{< figure
    src="img/three-experts.webp"
    alt="The Product Expert specifies, the Firmware Expert implements, the Testing Expert verifies; defects and evidence return to the Firmware Expert for fixes"
    >}}

## Grounded in the ESP32 ecosystem

ESP ZeroCode AI works with real chip and board definitions, rather than generic pin assumptions. At launch, its catalog spans eight Espressif SoCs, over 130 development boards and more than 400 parts, with boards from Espressif, M5Stack, Seeed Studio, Adafruit and more. The Product Expert uses the selected board's pin map when it writes the spec and wiring for the device.

Firmware can combine capabilities across connectivity, interaction and AI, depending on the chip and hardware:

- **Connectivity:** Wi-Fi, Bluetooth LE, Matter over Wi-Fi or Thread, Zigbee, BLE Mesh, ESP-NOW, ESP RainMaker, MQTT and AWS IoT.
- **Interaction:** touchscreen displays, speakers and sound, a control page served by the device itself, and Bluetooth media remotes.
- **AI:** voice commands, trained models that classify sensor data on the device, plain-language commands understood offline, camera motion detection, and cloud AI agents.

An open library of reusable drivers, device types, behaviors and framework integrations supports firmware creation and lets contributors extend the catalog.

<figure class="not-prose" style="margin:2rem 0">
<svg viewBox="0 0 760 318" role="img" aria-label="Eight Espressif SoCs, one studio: ESP32, ESP32-C3, ESP32-C5, ESP32-C6, ESP32-H2, ESP32-P4, ESP32-S3 and the new ESP32-S31; 131 boards, 400+ parts, 16 frameworks" style="display:block;width:100%;height:auto;color:inherit;fill:currentColor;font-family:inherit" font-size="11.5">
<text x="24" y="32" font-size="15" font-weight="600">Eight Espressif SoCs, one studio</text>
<g><rect x="24" y="60" width="166" height="76" rx="8" fill="none" fill-opacity="1" stroke="currentColor" stroke-opacity="0.35" stroke-width="1.25"/><text x="36" y="86" font-size="13" font-weight="600">ESP32</text><text x="36" y="106" fill-opacity="0.7">Wi-Fi + Bluetooth</text><text x="36" y="122" fill-opacity="0.7">Classic and BLE</text></g>
<g><rect x="206" y="60" width="166" height="76" rx="8" fill="none" fill-opacity="1" stroke="currentColor" stroke-opacity="0.35" stroke-width="1.25"/><text x="218" y="86" font-size="13" font-weight="600">ESP32-C3</text><text x="218" y="106" fill-opacity="0.7">Wi-Fi 4 + BLE 5</text><text x="218" y="122" fill-opacity="0.7">RISC-V, low cost</text></g>
<g><rect x="388" y="60" width="166" height="76" rx="8" fill="none" fill-opacity="1" stroke="currentColor" stroke-opacity="0.35" stroke-width="1.25"/><text x="400" y="86" font-size="13" font-weight="600">ESP32-C5</text><text x="400" y="106" fill-opacity="0.7">Dual-band Wi-Fi 6</text><text x="400" y="122" fill-opacity="0.7">BLE 5 + Thread</text></g>
<g><rect x="570" y="60" width="166" height="76" rx="8" fill="none" fill-opacity="1" stroke="currentColor" stroke-opacity="0.35" stroke-width="1.25"/><text x="582" y="86" font-size="13" font-weight="600">ESP32-C6</text><text x="582" y="106" fill-opacity="0.7">Wi-Fi 6 + BLE 5</text><text x="582" y="122" fill-opacity="0.7">Thread and Zigbee</text></g>
<g><rect x="24" y="152" width="166" height="76" rx="8" fill="none" fill-opacity="1" stroke="currentColor" stroke-opacity="0.35" stroke-width="1.25"/><text x="36" y="178" font-size="13" font-weight="600">ESP32-H2</text><text x="36" y="198" fill-opacity="0.7">Thread and Zigbee</text><text x="36" y="214" fill-opacity="0.7">BLE 5, no Wi-Fi</text></g>
<g><rect x="206" y="152" width="166" height="76" rx="8" fill="none" fill-opacity="1" stroke="currentColor" stroke-opacity="0.35" stroke-width="1.25"/><text x="218" y="178" font-size="13" font-weight="600">ESP32-P4</text><text x="218" y="198" fill-opacity="0.7">High performance</text><text x="218" y="214" fill-opacity="0.7">MIPI display, camera</text></g>
<g><rect x="388" y="152" width="166" height="76" rx="8" fill="none" fill-opacity="1" stroke="currentColor" stroke-opacity="0.35" stroke-width="1.25"/><text x="400" y="178" font-size="13" font-weight="600">ESP32-S3</text><text x="400" y="198" fill-opacity="0.7">Wi-Fi + BLE 5</text><text x="400" y="214" fill-opacity="0.7">Vector instructions</text></g>
<g><rect x="570" y="152" width="166" height="76" rx="8" fill="#3283f2" fill-opacity="0.12" stroke="#3283f2" stroke-opacity="1" stroke-width="2"/><text x="582" y="178" font-size="13" font-weight="600">ESP32-S31</text><text x="724" y="178" text-anchor="end" font-size="11.5" font-weight="600" fill="#3283f2">NEW</text><text x="582" y="198" fill-opacity="1">Wi-Fi + BLE + Thread</text><text x="582" y="214" fill-opacity="1">Displays, audio, AI</text></g>
<line x1="24" x2="736" y1="252" y2="252" stroke="currentColor" stroke-opacity="0.2"/>
<text x="143" y="284" text-anchor="middle" font-size="22" font-weight="600">131</text><text x="143" y="304" text-anchor="middle" fill-opacity="0.7">boards in the catalog</text><text x="380" y="284" text-anchor="middle" font-size="22" font-weight="600">400+</text><text x="380" y="304" text-anchor="middle" fill-opacity="0.7">parts to wire to them</text><text x="617" y="284" text-anchor="middle" font-size="22" font-weight="600">16</text><text x="617" y="304" text-anchor="middle" fill-opacity="0.7">frameworks to combine</text>
</svg>
</figure>

## Build and try, right in your browser

Writing and building the firmware happen in the browser, and so does trying it. Before you have any hardware, you can run the firmware on a virtual device that is wired like your diagram. It boots the same image you would flash, and you can press its buttons and touch its screen.

{{< figure
    src="img/product-page.webp"
    alt="The Core-S3 Walkie-Talkie product page: a photo of two M5Stack CoreS3 units talking to each other, the prompt it was built from, and Try in browser, Flash, Download and Fork buttons"
    caption="A Community project, the [Core-S3 Walkie-Talkie](https://esp-zerocode.ai/community/products/core-s3-walkie-talkie): the prompt it was built from, with **Try in browser**, **Flash**, **Download** and **Fork**"
    >}}

{{< figure
    src="img/try-in-browser.webp"
    alt="The T-Rex game running on a virtual ESP32-S31 board in the browser, with a list of what to look for beside it"
    caption="[T-Rex](https://esp-zerocode.ai/community/products/t-rex-opt/try) running on a virtual ESP32-S31 board in the browser, with what to look for beside it"
    >}}

## Human in the loop: the agent tests on your hardware

An emulator cannot tell you that a relay clicks, or that a 180 ms double-press is too quick for a thumb. Your board can, so the last test loop runs on it, and you do the checks that only a person can.

Plug your board in over USB and flash it from the browser, with nothing to install. The Testing Expert then gives you a checklist, watches the device log for the events that matter and flags crashes. You confirm what you see and hear, and anything that fails goes back to the Firmware Expert with the evidence.

{{< figure
    src="img/flash-from-browser.webp"
    alt="Flash from your browser: connect your board, flash the firmware in one click, and watch the device log as it starts"
    caption="Flashing from the browser: connect the board, flash in one click, watch it start"
    >}}

## Your project, yours to share

The output is a complete, editable ESP-IDF project with source, configuration and a flashable binary. Makers can continue in the browser; experienced developers can download the project into their usual ESP-IDF tools, add custom components and perform the additional validation needed for a commercial product.

Your projects are yours. They stay private unless you choose to publish them, and you can download the full source at any time. When you publish to the Community, you share either the firmware alone or the full source as well, and others can try it in their browser, flash it to their own board or fork it into a project of their own. Published code and binaries are shared under the Apache-2.0 license, and photos and descriptions under CC BY 4.0.

{{< figure
    src="img/community.webp"
    alt="The ESP ZeroCode AI Community page: a carousel of projects built by makers, including a Minecraft-style game, a music player, a robot arm and a reminder display"
    caption="What the [Community](https://esp-zerocode.ai/community) is building"
    >}}

The Community has already built a [Minecraft-style game](https://esp-zerocode.ai/community/products/minecraft) on the ESP32-S31, a [T-Rex runner](https://esp-zerocode.ai/community/products/t-rex-opt), a [music synthesizer](https://esp-zerocode.ai/community/products/music-synth), a [USB security key](https://esp-zerocode.ai/community/products/usb-security-key) and a [robot that plays Atari](https://esp-zerocode.ai/community/products/robo-atari) with a real joystick.

## Try it

ESP ZeroCode AI is live at [esp-zerocode.ai](https://esp-zerocode.ai). Describe a device, watch it get built and tested, run it in your browser, and when you are ready, plug in a board.

We would love to see what you make, and to hear where we can improve the experience. Please reach out to [zerocode@espressif.com](mailto:zerocode@espressif.com) for any issues and feedback.
