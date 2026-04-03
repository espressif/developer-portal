---
title: "Hybrid Secure Boot with Post-Quantum Verification on ESP32-Class Targets"
date: 2026-04-04
summary: "A measured research prototype of hybrid secure boot for ESP32-class devices combining ML-DSA verification with ECDSA V2 under realistic bootloader constraints."
tags:
  - ESP32
  - Security
  - Secure Boot
  - Post-Quantum Cryptography
  - ML-DSA
showAuthor: false
---

## 1. Introduction: Why Post-Quantum Security Matters for ESP32

Post-quantum cryptography is required because large-scale quantum computers would break the public-key foundations used across today’s secure systems. **Shor’s algorithm** can solve integer factorization and discrete logarithm problems efficiently on a quantum computer, which directly threatens **RSA** (factorization) and **ECDSA/ECC** (discrete logarithm). In practical terms, signatures and key exchange mechanisms based on these assumptions lose long-term security once capable quantum hardware exists.

This is why PQC has moved from theory to standards. In 2024, NIST finalized the first PQC standards: **FIPS 203 (ML-KEM)**, **FIPS 204 (ML-DSA)**, and **FIPS 205 (SLH-DSA)**. For cloud systems, migration is mostly a software and operational challenge; for embedded systems, especially long-lived IoT devices, it is a lifecycle challenge.

ESP32-class deployments often remain in the field for 10-15 years, which intersects with “**Harvest Now, Decrypt Later**” risk models where adversaries can collect signed firmware artifacts and revisit them later with stronger capability. In this context, authenticity and trust-chain durability matter as much as confidentiality. This post presents a **measured research prototype** of hybrid secure boot using post-quantum verification on ESP32-class targets, centered on `pqc_boot_verify`, with secure boot and flash encryption enabled under realistic bootloader constraints.

---

## 2. From Classical Secure Boot to Hybrid PQC Verification

Traditional secure boot relies on classical public-key signatures (commonly RSA or ECDSA): ROM code verifies the bootloader, the bootloader is loaded, then the bootloader verifies the app image before execution.

In this model, signature trust is anchored in classical algorithms. The bootloader’s check is where the device commits to **app-image authenticity** before execution, and that decision rests on the same hardness assumptions **Shor’s algorithm** would break on a large enough quantum computer—so long-lived deployments face a **harvest now, break later** risk for signed firmware that is distinct from, but related to, the confidentiality story.

For that reason, this prototype uses a **hybrid implementation** rather than replacing the classical path outright:

- Keep the existing classical secure boot trust chain in place.
- Add PQC verification in the app verification path.
- Require both checks to pass before boot continues.

To do this without breaking the existing flow, the design appends a dedicated PQC signature sector after the standard secure boot signature block. Current boot stages keep working while post-quantum verification material is carried in flash.

The approach keeps **Secure Boot V2** semantics and a practical layout: bounded extra flash and RAM, deterministic boot, an **8 KB** PQC sector after the **4 KB** classical sector, and a single digest **SHA-256(image + ECDSA sector)** that PQC binds to. At runtime the bootloader verifies **PQC first**, then **ECDSA V2**, and continues only if **both** succeed. The **ROM** root of trust stays classical; the new layer targets app-image authenticity over a longer horizon.

---

## 3. Prototype Scope and Targeting

This implementation is intentionally positioned as a **research/prototype with measured results**, not a production readiness claim.

Relative to typical production secure boot, this work combines **ML-DSA-65** with **ECDSA V2** on the same app image under **Secure Boot and Flash Encryption**; uses a fixed **8 KB** PQC sector aligned to **4 KB** for **bootloader mmap**; ties classical and post-quantum signatures through one digest over the image and classical sector; runs PQC verification in the bootloader with explicit temporary memory (for example **TLSF**); and reports timings on **ESP32-C5**-class hardware.

### Current targeting

- Primary test target: **ESP32-C5**
- Design intent: reusable across other ESP32 SoCs with sufficient memory budget
- Classic ESP32 is excluded from this path
- Resource-constrained targets remain the strictest validation point for portability assumptions

### Key constraints (prototype context)

- Secure Boot + Flash Encryption increase bootloader code size.
- Bootloader code size (excluding signature): ~64 KB (ESP32-C3 reference).
- No OS/runtime environment during bootloader execution.
- CPU frequency in measured context: 80 MHz.

The working model is: if the constrained targets are stable, broader adoption on larger-memory SoCs is practical.

---

## 4. Hybrid Secure Boot Architecture

**Host pipeline:** Pad the app binary, sign with **ECDSA V2 Secure Boot** (add the **4 KB** signature sector), hash **image plus that sector**, sign the digest with **ML-DSA-65**, and append the **8 KB** PQC block.

**Device pipeline:** **ROM** authenticates the bootloader. The bootloader recomputes the same digest, **verifies the PQC block first** (stop on failure), then **verifies ECDSA V2**, then runs the application.

The **PQC signature block wraps the application image plus the ECDSA Secure Boot V2 sector**: ML-DSA verifies a digest over that combined region, so one post-quantum signature binds both the firmware image and the classical signature block. The ROM-to-bootloader classical trust path is unchanged.

### Boot flow and signature layout (combined)

The figure has two parts:

1. **Flash layout** — sectors **F1 → F2 → F3** in address order.
2. **Boot chain** — top-to-bottom steps **S1 … S9**.

Links: **F1** and **F2** feed the SHA-256 step; **F3** feeds PQC verification; **F2** feeds ECDSA verification. **PQC runs before ECDSA**; both must pass.

```mermaid
%%{init: {"flowchart": {"curve": "linear", "nodeSpacing": 28, "rankSpacing": 32}}}%%
flowchart TB
    subgraph flash["Flash layout (low to high address)"]
        direction LR
        F1["App + pad"] --> F2["4 KB ECDSA V2"] --> F3["8 KB PQC"]
    end
    subgraph boot["Boot chain"]
        direction TB
        S1["ROM boot"] --> S2["ROM verifies bootloader"]
        S2 --> S3["Bootloader loads app"]
        S3 --> S4["SHA-256: app + ECDSA sector"]
        S4 --> S5["Verify PQC (ML-DSA-65)"]
        S5 --> S6{"PQC OK?"}
        S6 -->|No| HALT["Halt"]
        S6 -->|Yes| S7["Verify ECDSA (V2)"]
        S7 --> S8{"ECDSA OK?"}
        S8 -->|No| HALT
        S8 -->|Yes| S9["Execute app"]
    end
    F1 --> S4
    F2 --> S4
    F3 --> S5
    F2 --> S7
```

### Signing order (host)

The image is built in **two steps**: classical signing first, then PQC over the already signed layout.

```mermaid
%%{init: {"flowchart": {"curve": "linear"}}}%%
flowchart LR
    S0["App + pad"] --> S1["ECDSA sign (+4 KB)"]
    S1 --> S2["SHA-256 (image + ECDSA)"]
    S2 --> S3["PQC sign (+8 KB)"]
```

### Verification model (device)

- ROM flow is unchanged (classical verification of the bootloader).
- Bootloader checks the app image in **strict order**:
  1. **ML-DSA-65 (PQC block)** — on failure, boot **stops** (ECDSA is not run).
  2. **ECDSA V2 Secure Boot** — only **after** PQC succeeds.
- Boot continues only if **both** checks pass.

This keeps classical trust assumptions while adding post-quantum resilience. The combined diagram matches this order against the **flash sectors**.

---

## 5. Flash Signature Layout: Extending Without Breaking Existing Flow

The prototype appends a dedicated PQC sector after the standard secure boot sector:

| Region | Size |
| --- | --- |
| Secure Boot V2 signature sector | **4 KB** |
| PQC signature sector | **8 KB** |
| **Total signature footprint** | **12 KB** |

The **App + pad → 4 KB ECDSA → 8 KB PQC** order matches the **Flash layout** subgraph in the combined Mermaid diagram in Section 4.

### PQC signature block (8 KB) details

Based on `pqc_sig_block.h`, the PQC sector contains one packed `pqc_sig_block_t` of exactly **8192 bytes**, appended after the 4 KB ECDSA sector.

**Note:** The PQC signature block is kept at **8 KB** (a multiple of 4 KB) because bootloader `mmap` parsing operates in **4 KB** units.

| Section | Size | Details |
| --- | --- | --- |
| Header | 4 bytes | `magic_byte` (`0xE8`), `version` (`0x01`), `algorithm_id`, `flags` |
| Image digest | 32 bytes | SHA-256 of **image content + ECDSA sector** (wrapped region) |
| Length fields | 8 bytes | `public_key_len`, `signature_len` for the active PQC algorithm |
| Public key area | 2592 bytes max | Fixed-size array; zero-padded if the algorithm uses fewer bytes |
| Signature area | 4627 bytes max | Fixed-size array; zero-padded if the algorithm uses fewer bytes |
| CRC | 4 bytes | CRC-32-LE over bytes from offset `0` up to (not including) `block_crc` |
| Padding | Remainder | Zero fill so the packed block is exactly **8192** bytes |

---

## 6. Memory Strategy Under Bootloader Constraints

Bootloader environments cannot rely on normal application allocation behavior. This prototype uses an explicit temporary-memory strategy.

### Current approach

- **TLSF allocator** for PQC/liboqs allocation paths.
- Fixed temporary region near top of app SRAM.
- Current configured temporary pool budget in this setup: **72 KB**.
- No additional assertion-based safety guards are enabled yet (known prototype limitation).

Stack-heavy PQC verification is isolated to avoid collision with normal bootloader execution stack behavior.

---

## 7. Verification Flow (Pseudocode)

```c
verify_app_hybrid(image_start, ecdsa_block_start):
    pqc_block_start = ecdsa_block_start + 4KB

    init_tlsf_temp_pool()

    // Hash region covers app image + ECDSA sector
    digest = sha256_flash(image_start, pqc_block_start - image_start)

    pqc_block = mmap(pqc_block_start, 8KB)
    validate_pqc_header_crc_lengths(pqc_block)

    // Trust binding checks
    if pqc_block.public_key != compiled_trusted_pqc_pubkey:
        fail_boot()
    if pqc_block.image_digest != digest:
        fail_boot()

    // PQC check first
    if !mldsa65_verify(digest, pqc_block.signature, trusted_pubkey):
        fail_boot()

    // Classical check
    if !verify_ecdsa_v2_signature(ecdsa_block_start):
        fail_boot()

    destroy_tlsf_temp_pool()
    zero_temp_region()
    continue_boot()
```

---

## 8. Measured Results (ESP32-C5 Prototype)

### Hybrid secure boot path (`pqc_boot_verify`)

Under bootloader conditions (~80 MHz CPU context), current measurements show:

- **ML-DSA-65 verify:** ~68 ms (software path)
- **ECDSA verify:** ~7 ms (classical path with hardware acceleration)

### `signature_basic` example (ML-DSA-65 on ESP32-C5)

The **`signature_basic`** project under `post_quantum_cryptography` benchmarks ML-DSA-65 signing and verification in the application (not the hybrid bootloader). Figures below come from captured serial logs in that tree (e.g. `signature_basic/test.txt` and `signature_basic/hehe.txt`), **20 iterations** each, chip reported as **ESP32-C5**.

| Path | Sign (avg) | Verify (avg) |
| --- | --- | --- |
| **esp-liboqs** (ML-DSA-65) | ~26.9 ms (min ~24 ms, max ~42 ms) | ~18.0 ms |
| **WolfSSL** (ML-DSA-65) | ~40.5 ms | ~18.3 ms |
| **esp-mldsa-native** (ML-DSA-65) | ~198 ms | ~21.8 ms |

These numbers show how **implementation choice** (liboqs, WolfSSL, or native) shifts cost. The hybrid bootloader path is a different integration context but uses the same algorithm family.

**Takeaway:** Hybrid PQC verification is practical on-device, but timing and memory need explicit budgeting.

---

## 9. Why Hybrid Now Instead of Full Replacement

The prototype keeps **ECDSA** in the trust chain because classical secure boot is mature, widely deployed, and well understood on ESP32-class hardware. **PQC** is standardized, but bootloader use is still relatively new: implementations are **not yet as field-tested** as long-running RSA/ECDSA stacks, and software verification paths remain **vulnerable to side-channel analysis (SCA)**—timing, power, and fault injection—without strong countermeasures. Keeping hybrid verification treats PQC as a forward-looking layer rather than the only gate until embedded PQC paths gain more scrutiny and hardening.

For long-lived devices, **harvest now, decrypt later** also applies to **authenticity**: an adversary can store signed firmware and classical keys today and attack them when quantum-capable cryptanalysis is practical. A **PQC** signature over the image plus ECDSA block addresses that horizon; requiring **both** PQC and classical checks to pass hedges quantum-era breaks while retaining today’s proven secure boot path.

---

## 10. How to Build and Test `pqc_boot_verify`

1. **Clone and enter the project**

   ```bash
   cd pqc_boot_verify
   idf.py set-target esp32c5
   ```

2. **Configure security** — In menuconfig, enable **Secure Boot** and **Flash Encryption**. Generate classical secure boot keys (ECDSA/RSA) using the usual ESP-IDF flow.

3. **PQC keys and header** — Run the signing script. Keys are stored under **`keys/`** by default (use `python scripts/pqc_sign.py keygen --keys-dir <dir>` to override). Generate the C header that embeds the PQC public key for compile-time trust:

   ```bash
   python scripts/pqc_sign.py keygen
   python scripts/pqc_sign.py header --pk keys/pqc_ml_dsa_65_public.bin --output path/to/pqc_public_key.h
   ```

4. **Build, flash, monitor**

   ```bash
   idf.py build
   idf.py encrypted-flash monitor
   ```

For more detail, see the `post_quantum_cryptography` workspace (including `pqc_boot_verify/scripts/pqc_sign.py`).

---

## References

- [Espressif blog structure reference (GitHub source)](https://github.com/espressif/developer-portal/blob/main/content/blog/2026/03/red_da_assessment_tool_overview/index.md)
- [Published RED DA article format reference](https://raw.githubusercontent.com/espressif/developer-portal/main/content/blog/2026/03/red_da_assessment_tool_overview/index.md)