# 5-bit Carry Look-Ahead (CLA) Adder — VLSI Design

Full custom VLSI implementation of a 5-bit Carry Look-Ahead Adder, built end-to-end from RTL down to a fabricable layout — Verilog HDL design and simulation, gate-level schematic and layout in Magic (TSMC 180nm), layout extraction, and post-layout SPICE simulation in ngspice.

This project was completed for the **VLSI Design** course project (Monsoon 2025, IIIT Hyderabad).

---

## Table of Contents
- [Overview](#overview)
- [Design Specification](#design-specification)
- [Repository Structure](#repository-structure)
- [1. Verilog HDL (RTL) Design](#1-verilog-hdl-rtl-design)
- [2. Custom Layout in Magic (TSMC 180nm)](#2-custom-layout-in-magic-tsmc-180nm)
- [3. Layout Extraction & Post-Layout SPICE Simulation](#3-layout-extraction--post-layout-spice-simulation)
- [How to Reproduce](#how-to-reproduce)
- [Requirements / Tools Used](#requirements--tools-used)

---

## Overview

A 5-bit Carry Look-Ahead Adder computes `Sum[4:0]` and `Cout` for two 5-bit inputs `A` and `B` with carry-in `Cin`, using **propagate/generate logic** instead of a ripple-carry chain — every carry bit `C(i+1)` is derived directly from `P`, `G`, and `Cin` in a fixed logic-depth expression, trading extra gate fan-in for lower propagation delay. Each output sum bit also drives a sizing-constrained output inverter, and the adder is registered with input/output D flip-flops clocked so inputs are latched before the clock edge and outputs are valid at the next rising edge.

The project carries the design through four stages:
1. **RTL design & verification** — gate-level Verilog implementation of the CLA logic, functionally verified with a testbench.
2. **Transistor-level schematic design** — static CMOS gate-level netlists (SPICE subcircuits) for every logic primitive (AND2-AND6, OR2-OR6, XOR, D flip-flop, inverter).
3. **Physical layout** — full custom layout of every standard cell and the top-level circuit in **Magic VLSI**, targeting the **TSMC 180nm** process (`SCN6M_DEEP.09` technology file).
4. **Post-layout verification** — layout-vs-schematic extraction (`.ext`) of every cell, and post-layout SPICE simulation in **ngspice** to confirm the extracted circuit's electrical behavior matches the intended logic.

## Design Specification

- **Propagate/Generate logic** (per bit `i`): `p_i = a_i XOR b_i`, `g_i = a_i . b_i`
- **Carry look-ahead expansion**: `c(i+1) = (p_i . c_i) + g_i`, expanded recursively so every carry is computed directly from `P`, `G`, and `Cin` (no rippling), minimizing logic depth at the cost of wide AND/OR gates (up to 6-input).
- **Output stage**: each sum bit drives an inverter sized `Wp/Wn = 20λ/10λ` (`λ = 0.09 µm`).
- **Timing**: inputs are registered on one clock edge; the CLA combinational logic must settle and be captured at the next rising edge (input/output D flip-flops on both sides).
- **Process**: TSMC 180nm (`VDD = 1.8V`, `Ln = Lp`, `SCN6M_DEEP.09.tech27` Magic tech file).

## Repository Structure
```
5bit-CLA-Adder-VLSI-main/
├── README.md
├── course_project_vlsid2025 (3).pdf   # Original assignment specification
├── verilog/
│   ├── cla.v                          # Gate-level 5-bit CLA adder (primitive gates)
│   ├── cla_tb.v                       # Modular CLA design + testbench (custom gate modules, clocked test vectors)
│   ├── cla5.out                       # Compiled simulation output (icarus/vvp)
│   └── waveforms.vcd                  # Simulation waveform dump
├── magic/                             # Full-custom layouts (Magic VLSI, TSMC 180nm)
│   ├── and_gate/                      # AND2-AND6 cells: .mag layout, .ext extraction, .spice netlist
│   ├── or_gate/                       # OR2-OR6 cells: .mag layout, .ext extraction, .spice netlist
│   ├── xor gate/                      # XOR cell: .mag layout, .ext extraction, .spice netlist
│   ├── dff/                           # D flip-flop cell: .mag layout, .ext extraction, .spice netlist
│   ├── final_ckt/                     # Top-level 5-bit CLA adder layout (integrates all cells)
│   └── 3_c.mag, 6_b.mag               # Supporting/intermediate layout cells
├── magic_extracts/                    # SPICE netlists (.cir) extracted from Magic layouts for every cell + top-level circuit
└── ngspice_codes/
    ├── all_ckts.cir                   # Transistor-level SPICE subcircuits for every gate (inv, and2-and6, etc.), TSMC 180nm
    └── cla_final.cir                  # Full 5-bit CLA transistor-level netlist for simulation
```

## 1. Verilog HDL (RTL) Design

**Files:** `verilog/cla.v`, `verilog/cla_tb.v`

- `cla.v` implements `carry_lookahead_adder_5bit_gates`: the 5-bit CLA built directly from Verilog primitive gates (`and`, `xor`, `or`), mirroring the propagate/generate carry-lookahead equations exactly — generate (`G[i]`), propagate (`P[i]`), and carry terms `C1`-`C4`/`Cout` are each built as a sum-of-products of `P`/`G`/`Cin` with no ripple dependency between bits.
- `cla_tb.v` contains a second, modular implementation (`carry_lookahead_adder_5bit_modular`) built from custom reusable gate modules (`and2`-`and6`, `or2`-`or6`, `xor2` — matching the fan-ins actually needed by the CLA equations), plus a self-checking testbench:
  - Generates a clock and applies a sequence of `(A, B, Cin)` test vectors covering single-bit, multi-bit, and all-carry-propagate/generate cases.
  - Uses `$monitor` to print a live table of `A`, `B`, `Sum`, `Cout` on every clock edge.
  - Dumps waveforms to `waveforms.vcd` for viewing in a waveform viewer (e.g. GTKWave).

**Run it** (with Icarus Verilog):
```bash
cd verilog
iverilog -o cla5.out cla_tb.v
vvp cla5.out
gtkwave waveforms.vcd   # optional, to inspect waveforms
```

## 2. Custom Layout in Magic (TSMC 180nm)

**Files:** `magic/`

Every logic primitive used by the CLA design was hand-laid-out as a standard cell in Magic, targeting the TSMC 180nm process (`SCN6M_DEEP.09.tech27` technology file):

| Cell | Directory | Notes |
|---|---|---|
| AND2-AND6 | `magic/and_gate/` | Static CMOS AND gates with 2-6 inputs, needed for the wide carry-lookahead product terms |
| OR2-OR6 | `magic/or_gate/` | Static CMOS OR gates with 2-6 inputs, needed for the carry sum-of-products |
| XOR | `magic/xor gate/` | Used for propagate-signal (`P_i`) and sum-bit generation |
| D Flip-Flop | `magic/dff/` | Registers CLA inputs/outputs to the clock edge, per the timing spec |
| Top-level circuit | `magic/final_ckt/` | Integrates all standard cells into the complete 5-bit CLA adder layout |

Each cell directory contains its `.mag` layout file, an `.ext` extraction file, and a `.spice` netlist generated from the layout.

## 3. Layout Extraction & Post-Layout SPICE Simulation

**Files:** `magic_extracts/`, `ngspice_codes/`

- **`magic_extracts/`** — SPICE netlists (`.cir`) extracted directly from each Magic layout (transistor-level, with parasitics from the extraction), for every gate (`and2`-`and6`, `or2`-`or6`, `xor`, `dff`) and the integrated `final.cir` top-level circuit. `b3v32check.log` records the BSIM3v3 model-check output from extraction.
- **`ngspice_codes/`**
  - `all_ckts.cir` — hand-written transistor-level SPICE subcircuits for every gate (inverter, AND2-AND6, etc.) using the TSMC 180nm models, built from sized NMOS/PMOS devices (`CMOSN`/`CMOSP`) with `λ`-based width/length and AS/AD/PS/PD parasitic parameters — used as a reference/pre-layout netlist.
  - `cla_final.cir` — the complete pre/post-layout 5-bit CLA transistor-level netlist (`VDD = 1.8V`, static CMOS, `λ = 0.09 µm`), used to run the full-adder simulation in ngspice and verify correct logical and electrical behavior (voltage levels, timing) across all cells.

**Run a simulation** (example):
```bash
cd ngspice_codes
ngspice cla_final.cir
```

## How to Reproduce

1. **RTL:** simulate and verify `verilog/cla_tb.v` with Icarus Verilog (see above) to confirm functional correctness before moving to layout.
2. **Layout:** open each cell (and finally `final_ckt.mag`) in Magic VLSI with the TSMC 180nm tech file loaded, review/regenerate the layout, and re-extract (`extract all`, then `ext2spice`) to produce fresh `.ext`/`.spice` files if the layout is modified.
3. **Post-layout simulation:** feed the extracted netlist (`magic_extracts/final.cir`) or the reference netlist (`ngspice_codes/cla_final.cir`) into ngspice, apply the same test vectors used in the Verilog testbench, and compare the resulting waveforms against the RTL simulation to confirm the physical implementation matches the intended logic.

## Requirements / Tools Used
- **Icarus Verilog** (`iverilog`, `vvp`) + **GTKWave** — RTL simulation and waveform viewing
- **Magic VLSI** — full-custom schematic/layout editor
- **TSMC 180nm PDK** (`SCN6M_DEEP.09.tech27` for Magic, `TSMC_180nm.txt` SPICE models for simulation)
- **ngspice** — transistor-level/post-layout circuit simulation

