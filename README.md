# Single-Cycle 32-bit RISC-V (RV32I) Processor Core with Unaligned Memory Architecture

[![Target: AMD Artix-7](https://img.shields.io/badge/FPGA-AMD%20Artix--7%20(XC7A35T)-blue.svg)](https://www.xilinx.com)
[![Board: Digilent Basys 3](https://img.shields.io/badge/Board-Digilent%20Basys%203-red.svg)](https://digilent.com)
[![EDA: AMD Vivado 2025.2](https://img.shields.io/badge/EDA-Vivado%202025.2-purple.svg)](https://www.xilinx.com)
[![Status: Module 3 Verified](https://img.shields.io/badge/Status-Module%203%20Verified-success.svg)](#)

Synthesizable, from-scratch hardware implementation of a **Single-Cycle 32-bit RISC-V (RV32I) Processor Core** featuring pure Distributed RAM banking, hardware unaligned memory transfers, and physical verification on Digilent Basys 3 FPGA.

## Architectural Datapath Schematic

The microarchitecture is designed strictly to Patterson & Hennessy academic specifications ($CPI = 1.0$), synthesized targeting AMD Xilinx Artix-7 (`XC7A35T-1CPG236C` on Digilent Basys 3) using pure Distributed RAM (LUT RAM) with asynchronous reads:

![RV32I Academic Datapath](docs/RV32I_Single_Cycle_Datapath_Academic.png)

## Project Structure
```
RV32I_Single_Cycle_Core/
├── docs/
│   ├── RV32I_Single_Cycle_Datapath_Academic.png  <-- Publication-grade monochrome datapath schematic
│   └── generate_academic_diagram.py              <-- Matplotlib vector generator script
├── rtl/
│   ├── rv32i_defines.v                           <-- Core ISA constants & ALU opcodes
│   ├── alu.v                                     <-- Module 1: 32-bit RV32I ALU (10 Operations)
│   ├── imm_gen.v                                 <-- Module 2: Immediate Generator (I, S, B, U, J)
│   └── reg_file.v                                <-- Module 3: 32x32-bit Register File (Dual-Read, Single-Write)
├── testbench/
│   ├── tb_alu.v                                  <-- Self-checking ALU testbench (6/6 phases PASS)
│   ├── tb_imm_gen.v                              <-- Self-checking ImmGen testbench (9/9 PASS)
│   └── tb_reg_file.v                             <-- Self-checking Register File testbench (9/9 PASS)
├── vivado/
│   └── RV32I_Single_Cycle_Core.xpr               <-- Vivado 2025.2 GUI Project
├── reports/
│   ├── alu_utilization.rpt                       <-- Module 1 Artix-7 Utilization (432 LUTs, 24 CARRY4)
│   ├── alu_timing.rpt                            <-- Module 1 Static Timing Report (WNS = -0.645 ns @ 100 MHz)
│   └── alu_power.rpt                             <-- Module 1 Power Analysis (87 mW total)
├── scripts/
│   ├── create_vivado_project.tcl                 <-- Project generation script
│   └── run_synth_alu.tcl                         <-- In-memory synthesis automation script
├── launch_vivado_gui.bat                         <-- One-click launcher for Vivado 2025.2 GUI
└── README.md
```

## Module Progress & Verification
- **Module 1: 32-bit RV32I ALU (`alu.v`)**
  - Operations: `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`.
  - Zero flag generation for conditional branches.
  - Verified with self-checking testbench (`tb_alu.v`): **100% Passed**.
  - Synthesized on Artix-7: **432 Slice LUTs**, **24 CARRY4** primitives, **0 latches/registers**, **~94 MHz standalone $F_{\text{max}}$**.
- **Module 2: Immediate Generator (`imm_gen.v`)**
  - Sign-extends and reconstructs immediates for **I-Type**, **S-Type**, **B-Type**, **U-Type**, and **J-Type** instructions.
  - Verified with self-checking testbench (`tb_imm_gen.v`): **9/9 Passed**.
- **Module 3: 32x32-bit Register File (`reg_file.v`)**
  - Dual independent asynchronous read ports (`raddr1`, `raddr2`).
  - Single synchronous write port (`waddr`, `wdata`, `we`) on positive clock edge.
  - Hardwired $x0 \equiv 0$ ground invariant (writes to $x0$ strictly inhibited).
  - Dedicated hardware debug taps for $x10$ (`a0`) and $x11$ (`a1`) to enable real-time 7-segment / benchmark monitoring.
  - Verified with self-checking testbench (`tb_reg_file.v`): **9/9 Passed**.

## Quick Start (Vivado GUI & Simulation)
1. Double-click `launch_vivado_gui.bat` to launch the project in the AMD Vivado 2025.2 GUI.
2. Run simulation with Icarus Verilog or Vivado XSim:
   ```cmd
   iverilog -I rtl -o sim.vvp rtl/imm_gen.v testbench/tb_imm_gen.v
   vvp sim.vvp
   ```
