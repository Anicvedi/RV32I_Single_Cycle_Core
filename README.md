# Single-Cycle 32-bit RISC-V (RV32I) Processor Core with Unaligned Memory Architecture

[![Target: AMD Artix-7](https://img.shields.io/badge/FPGA-AMD%20Artix--7%20(XC7A35T)-blue.svg)](https://www.xilinx.com)
[![Board: Digilent Basys 3](https://img.shields.io/badge/Board-Digilent%20Basys%203-red.svg)](https://digilent.com)
[![EDA: AMD Vivado 2025.2](https://img.shields.io/badge/EDA-Vivado%202025.2-purple.svg)](https://www.xilinx.com)
[![Status: Core Verified & Synthesized](https://img.shields.io/badge/Status-Core%20Verified%20%26%20Synthesized-success.svg)](#)

Synthesizable, from-scratch hardware implementation of a **Single-Cycle 32-bit RISC-V (RV32I) Processor Core** featuring pure Distributed RAM banking, hardware unaligned memory transfers, bare-metal assembly verification, and full-core physical synthesis on AMD Xilinx Artix-7 FPGA (`XC7A35T-1CPG236C`, Digilent Basys 3).

## Architectural Datapath Schematic

The microarchitecture is designed strictly to Patterson & Hennessy academic specifications ($CPI = 1.0$), featuring a dedicated parallel branch comparator, 4-banked distributed data memory with byte-enables, and single-cycle execution:

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
│   ├── imm_gen.v                                 <-- Module 2: Immediate Generator (I, S, B, U, J)
│   ├── reg_file.v                                <-- Module 3: 32x32-bit Register File (Dual-Read, Single-Write)
│   ├── pc_reg.v                                  <-- Module 4A: Program Counter Register
│   ├── imem.v                                    <-- Module 4B: Distributed Instruction Memory (512x32)
│   ├── data_memory.v                             <-- Module 5: 4-Banked Distributed Data Memory Subsystem
│   ├── control_unit.v                            <-- Module 6: Hardwired Control Unit & ALU Decoder
│   └── rv32i_core.v                              <-- Module 7: Top-Level RV32I Single-Cycle Core
├── testbench/
│   ├── tb_alu.v                                  <-- ALU unit testbench (6/6 phases PASS)
│   ├── tb_imm_gen.v                              <-- Immediate Generator testbench (9/9 PASS)
│   ├── tb_reg_file.v                             <-- Register File testbench (9/9 PASS)
│   ├── tb_fetch.v                                <-- Instruction Fetch testbench (10/10 PASS)
│   ├── tb_data_memory.v                          <-- Data Memory testbench (9/9 PASS)
│   ├── tb_control_unit.v                         <-- Control Unit testbench (11/11 PASS)
│   ├── tb_rv32i_core.v                           <-- System-level bare-metal testbench (100% PASS)
│   └── program_fib.hex                           <-- Assembled Fibonacci bare-metal machine code
├── vivado/
│   └── RV32I_Single_Cycle_Core.xpr               <-- AMD Vivado 2025.2 GUI Project
├── reports/
│   ├── core_utilization.rpt                      <-- Full-Core Artix-7 Utilization (2169 LUTs, 1056 FFs)
│   ├── core_timing.rpt                           <-- Full-Core Static Timing (WNS = +5.775 ns @ 50 MHz, Fmax = 70.6 MHz)
│   ├── core_power.rpt                            <-- Full-Core Vectorless Power Report (71 mW total)
│   ├── alu_utilization.rpt                       <-- Module 1 Standalone Utilization
│   ├── alu_timing.rpt                            <-- Module 1 Standalone Timing
│   └── alu_power.rpt                             <-- Module 1 Standalone Power
├── constraints/
│   ├── core_timing.xdc                           <-- Full-core 50 MHz clock constraint
│   └── alu_timing.xdc                            <-- Standalone ALU timing constraint
├── scripts/
│   ├── create_vivado_project.tcl                 <-- Vivado GUI project generator
│   ├── run_synth_core.tcl                        <-- Non-project full-core synthesis script
│   ├── run_synth_alu.tcl                         <-- ALU standalone synthesis script
│   └── assemble_test.py                          <-- Bare-metal Python RISC-V assembler
├── launch_vivado_gui.bat                         <-- One-click Vivado GUI desktop launcher
└── README.md
```

## Hardware Synthesis & PPA Analysis (AMD Xilinx Artix-7)

The complete processor core was synthesized using AMD Vivado 2025.2 in out-of-context mode targeting `XC7A35T-1CPG236C` (Digilent Basys 3 FPGA):

| Metric | Target Specification | Post-Synthesis Result |
| :--- | :--- | :--- |
| **FPGA Part** | Digilent Basys 3 | AMD Artix-7 `XC7A35T-1CPG236C` (Speed Grade -1) |
| **Target Clock** | 50.000 MHz ($T = 20.000\text{ ns}$) | **Timing Met (Zero Violations)** |
| **Worst Negative Slack (WNS)** | $\ge 0.000\text{ ns}$ | **$+5.775\text{ ns}$ (Slack Met)** |
| **Worst Hold Slack (WHS)** | $\ge 0.000\text{ ns}$ | **$+0.417\text{ ns}$ (Slack Met)** |
| **Datapath Delay ($t_{\text{crit}}$)**| $< 20.000\text{ ns}$ | **$14.170\text{ ns}$** ($4.404\text{ ns}$ logic, $9.766\text{ ns}$ routing) |
| **Max Operating Frequency ($F_{\text{max}}$)** | $> 50.0\text{ MHz}$ | **$70.57\text{ MHz}$** |
| **Slice LUTs** | 20,800 available | **2,169 (10.43%)** |
| ↳ *LUT as Logic* | - | 1,913 |
| ↳ *LUT as Distributed RAM* | 9,600 available | 256 (2.67%) |
| **Slice Registers (Flip-Flops)** | 41,600 available | **1,056 (2.54%)** ($33 \times 32$ bits, 0 Latches) |
| **Block RAM (BRAM)** | 50 tiles | **0 (0.00%)** *(Pure Distributed Memory)* |
| **DSP48 Primitives** | 90 slices | **0 (0.00%)** *(Pure LUT-based ALU)* |
| **Total Power Consumption** | - | **$71\text{ mW}$** ($3\text{ mW}$ dynamic, $68\text{ mW}$ static) |

### Critical Path Breakdown
Vivado static timing analysis confirms the classical theoretical critical path of single-cycle RISC-V processors:
$$\text{Path: } PC_{clk\rightarrow Q} \longrightarrow IMEM \longrightarrow RegFile_{read} \longrightarrow ALU \longrightarrow DMEM_{read} \longrightarrow WB_{mux} \longrightarrow RegFile_{setup}$$
The Load Word (`LW`) instruction exercises all sequential and distributed memory stages within a single clock cycle, totaling 18 logic levels ($14.170\text{ ns}$).

## Bare-Metal Assembly Verification
The core was verified by executing an assembled RISC-V machine program (`program_fib.hex`):
1. **Iterative Fibonacci:** Executes 9 iterations of `add`, `addi`, and conditional `bne` to compute $F_{10} = 55$.
2. **Memory Subsystem:** Stores $F_{10}$ to Data Memory address 16 via `sw`, then re-loads into register $x10$ (`a0`) via `lw`.
3. **Subroutine Calling & Return:** Calls an auxiliary routine via `jal x1, +12`, increments $a0$ by 5 ($a0 = 60$), and returns via indirect jump `jalr x0, 0(x1)`.
4. **Halt Condition:** Loops cleanly on `beq x0, x0, 0`.

**Simulation Results:**
- Cycles Executed: **55 clock cycles**
- Metric: **$\text{CPI} = 1.0$**
- Data Memory Verification: **$DMEM[16] = 55$ (PASS)**
- Register $a0$ Output: **$a0 = 60$ (PASS)**
- Test Status: **100% Passed (0 Failures)**

## Quick Start (Vivado GUI & Simulation)
1. Double-click `launch_vivado_gui.bat` to launch the AMD Vivado 2025.2 GUI.
2. Run full-core simulation with Icarus Verilog or Vivado XSim:
   ```cmd
   iverilog -g2012 -I rtl -o sim.vvp testbench/tb_rv32i_core.v rtl/*.v
   vvp sim.vvp
   ```
