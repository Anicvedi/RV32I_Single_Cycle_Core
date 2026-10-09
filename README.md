# Single-Cycle 32-bit RISC-V (RV32I) Processor Core with Unaligned Memory Architecture

[![Target: AMD Artix-7](https://img.shields.io/badge/FPGA-AMD%20Artix--7%20(XC7A35T)-blue.svg)](https://www.xilinx.com)
[![Board: Digilent Basys 3](https://img.shields.io/badge/Board-Digilent%20Basys%203-red.svg)](https://digilent.com)
[![EDA: AMD Vivado 2025.2](https://img.shields.io/badge/EDA-Vivado%202025.2-purple.svg)](https://www.xilinx.com)
[![Status: Commit 1 (ALU Verified)](https://img.shields.io/badge/Status-Module%201%20Verified-success.svg)](#)

Synthesizable, from-scratch hardware implementation of a **Single-Cycle 32-bit RISC-V (RV32I) Processor Core** featuring pure Distributed RAM banking, hardware unaligned memory transfers, and physical verification on Digilent Basys 3 FPGA.

## Project Structure
```
RV32I_Single_Cycle_Core/
├── docs/
│   └── RV32I_Architecture_Block_Diagrams.pptx  <-- Architectural block diagrams presentation
├── rtl/
│   ├── rv32i_defines.v                        <-- Core definitions & opcodes
│   └── alu.v                                  <-- Module 1: 32-bit RV32I ALU
├── testbench/
│   └── tb_alu.v                               <-- Self-checking corner-case testbench
├── scripts/
│   └── create_vivado_project.tcl              <-- Vivado project generation script
├── launch_vivado_gui.bat                      <-- One-click batch script to open in Vivado GUI
└── README.md
```

## Quick Start (Vivado GUI)
Double-click `launch_vivado_gui.bat` to automatically build the project and launch the AMD Xilinx Vivado GUI.

## Commit Milestone Progression
- **Commit 1:** `feat(alu): 32-bit RV32I ALU, header definitions, and self-checking testbench`
