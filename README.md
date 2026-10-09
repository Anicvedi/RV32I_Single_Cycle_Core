# Single-Cycle 32-bit RISC-V (RV32I) Processor Core with Unaligned Memory Architecture

[![Target: AMD Artix-7](https://img.shields.io/badge/FPGA-AMD%20Artix--7%20(XC7A35T)-blue.svg)](https://www.xilinx.com)
[![Board: Digilent Basys 3](https://img.shields.io/badge/Board-Digilent%20Basys%203-red.svg)](https://digilent.com)
[![EDA: AMD Vivado 2025.2](https://img.shields.io/badge/EDA-Vivado%202025.2-purple.svg)](https://www.xilinx.com)
[![Status: Module 2 (ImmGen) In Progress](https://img.shields.io/badge/Status-Module%202%20(ImmGen)%20Active-blue.svg)](#)

Synthesizable, from-scratch hardware implementation of a **Single-Cycle 32-bit RISC-V (RV32I) Processor Core** targeted to AMD Xilinx Artix-7 FPGA (`XC7A35T-1CPG236C`, Digilent Basys 3).

## Architectural Datapath Schematic

The microarchitecture is designed strictly to Patterson & Hennessy academic specifications ($CPI = 1.0$):

![RV32I Academic Datapath](docs/RV32I_Single_Cycle_Datapath_Academic.png)

## Repository Architecture
```
RV32I_Single_Cycle_Core/
├── docs/
│   ├── RV32I_Single_Cycle_Datapath_Academic.png  <-- Publication-grade monochrome datapath schematic
│   └── generate_academic_diagram.py              <-- Vector diagram generator script
├── rtl/
│   ├── rv32i_defines.v                           <-- ISA opcodes, funct3/7, and ALU encodings
│   ├── alu.v                                     <-- Module 1: 32-bit RV32I ALU (10 Operations)
│   └── imm_gen.v                                 <-- Module 2: Immediate Generator (I, S, B, U, J)
├── testbench/
│   ├── tb_alu.v                                  <-- ALU unit testbench (6/6 phases PASS)
│   └── tb_imm_gen.v                              <-- Immediate Generator testbench (9/9 PASS)
├── vivado/
│   └── RV32I_Single_Cycle_Core.xpr               <-- AMD Vivado 2025.2 GUI Project
├── reports/
│   ├── alu_utilization.rpt                       <-- Module 1 Standalone Utilization (432 LUTs, 24 CARRY4)
│   ├── alu_timing.rpt                            <-- Module 1 Standalone Timing (WNS = -0.645 ns @ 100 MHz, ~94 MHz Fmax)
│   └── alu_power.rpt                             <-- Module 1 Standalone Power (87 mW total)
├── constraints/
│   └── alu_timing.xdc                            <-- Standalone ALU timing constraint
├── scripts/
│   ├── create_vivado_project.tcl                 <-- Vivado GUI project generator
│   ├── refresh.tcl                               <-- Live project synchronizer for open Vivado GUI
│   └── run_synth_alu.tcl                         <-- ALU standalone synthesis script
├── launch_vivado_gui.bat                         <-- One-click Vivado GUI desktop launcher
└── README.md
```

## Module Development Progress
- **Module 1: 32-bit RV32I ALU (`alu.v`)**
  - Operations: `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`.
  - Zero flag generation for conditional branches.
  - Verified with self-checking testbench (`tb_alu.v`): **100% Passed (6/6 phases)**.
  - Synthesized on Artix-7: **432 Slice LUTs**, **24 CARRY4** primitives, **0 latches/registers**, **~94 MHz standalone $F_{\text{max}}$**.
- **Module 2: Immediate Generator (`imm_gen.v`)**
  - Sign-extends and reconstructs immediates for **I-Type**, **S-Type**, **B-Type**, **U-Type**, and **J-Type** instructions.
  - Verified with self-checking testbench (`tb_imm_gen.v`): **9/9 Passed**.

## Quick Start (Vivado GUI & Simulation)
1. Double-click `launch_vivado_gui.bat` to launch the AMD Vivado 2025.2 GUI.
2. In the Vivado Tcl Console, run `source scripts/refresh.tcl` to synchronize sources.
3. Run simulation with Icarus Verilog or Vivado XSim:
   ```cmd
   iverilog -g2012 -I rtl -o sim.vvp testbench/tb_imm_gen.v rtl/imm_gen.v
   vvp sim.vvp
   ```

## Quick Start (Vivado GUI & Simulation)
1. Double-click `launch_vivado_gui.bat` to launch the AMD Vivado 2025.2 GUI.
2. Run full-core simulation with Icarus Verilog or Vivado XSim:
   ```cmd
   iverilog -g2012 -I rtl -o sim.vvp testbench/tb_rv32i_core.v rtl/*.v
   vvp sim.vvp
   ```
