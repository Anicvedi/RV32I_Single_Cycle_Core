`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Module 7: Top-Level RV32I Processor Core (rv32i_core.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
//
// Microarchitecture Specification:
// - Single-Cycle execution engine (CPI = 1.0) with pure Distributed RAM architecture.
// - Strictly implements the academic Patterson & Hennessy microarchitectural topology.
// - Features:
//     * 32 general-purpose 32-bit registers (x0 hardwired to ground)
//     * Full RV32I Base Integer Instruction Set (R, I, Load, Store, Branch, JAL, JALR, LUI)
//     * Asynchronous 4-banked data memory with byte-enables for unaligned support
//     * Hardware debug taps for program counter, instruction word, ALU result, and a0/a1
// ==============================================================================

`include "rv32i_defines.v"

module rv32i_core #(
    parameter IMEM_DEPTH     = 512,                     // Instruction memory words
    parameter DMEM_DEPTH     = 512,                     // Data memory words
    parameter MEM_INIT_FILE  = ""                       // Preload machine code hex
)(
    input  wire        clk,
    input  wire        rst,
    // Hardware Monitoring & Verification Probes
    output wire [31:0] debug_pc,
    output wire [31:0] debug_instr,
    output wire [31:0] debug_alu_result,
    output wire [31:0] debug_reg_x10,                   // a0 (Return Value / Quotient)
    output wire [31:0] debug_reg_x11                    // a1 (Auxiliary / Remainder)
);

    // -------------------------------------------------------------------------
    // Internal Datapath Interconnects
    // -------------------------------------------------------------------------
    // Fetch Stage
    wire [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_target;
    wire [31:0] jalr_target;
    wire [31:0] instr;

    // Decode Stage
    wire [6:0]  opcode   = instr[6:0];
    wire [4:0]  rd       = instr[11:7];
    wire [2:0]  funct3   = instr[14:12];
    wire [4:0]  rs1      = instr[19:15];
    wire [4:0]  rs2      = instr[24:20];
    wire [6:0]  funct7   = instr[31:25];

    wire [31:0] rdata1;
    wire [31:0] rdata2;
    wire [31:0] imm_ext;
    wire [31:0] result_data;

    // Control Signals
    wire        reg_write;
    wire        mem_write;
    wire        alu_src;
    wire [2:0]  imm_src;
    wire [1:0]  result_src;
    wire [1:0]  pc_src;
    wire [3:0]  alu_op;

    // Execute Stage
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire        alu_zero;

    // Memory Stage
    wire [31:0] dmem_rdata;

    // -------------------------------------------------------------------------
    // 1. Instruction Fetch (IF)
    // -------------------------------------------------------------------------
    assign pc_plus_4    = pc + 32'd4;
    assign pc_target    = pc + imm_ext;
    assign jalr_target  = (rdata1 + imm_ext) & ~32'd1;

    assign pc_next = (pc_src == 2'b01) ? pc_target :
                     (pc_src == 2'b10) ? jalr_target :
                                         pc_plus_4;

    pc_reg #(
        .RESET_ADDR(32'h0000_0000)
    ) u_pc_reg (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    imem #(
        .MEM_DEPTH(IMEM_DEPTH),
        .MEM_INIT_FILE(MEM_INIT_FILE)
    ) u_imem (
        .addr(pc),
        .inst(instr)
    );

    // -------------------------------------------------------------------------
    // 2. Instruction Decode & Register File (ID)
    // -------------------------------------------------------------------------
    // Parallel Branch Comparator (evaluated concurrently with ALU for timing optimization)
    wire br_eq  = (rdata1 == rdata2);
    wire br_lt  = ($signed(rdata1) < $signed(rdata2));
    wire br_ltu = (rdata1 < rdata2);

    control_unit u_control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7[5]),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .br_ltu(br_ltu),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .result_src(result_src),
        .pc_src(pc_src),
        .alu_op(alu_op)
    );

    imm_gen u_imm_gen (
        .instr(instr[31:7]),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    reg_file u_reg_file (
        .clk(clk),
        .rst(rst),
        .raddr1(rs1),
        .raddr2(rs2),
        .waddr(rd),
        .wdata(result_data),
        .we(reg_write),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .x10(debug_reg_x10),
        .x11(debug_reg_x11)
    );

    // -------------------------------------------------------------------------
    // 3. Execution & Arithmetic Logic Unit (EX)
    // -------------------------------------------------------------------------
    assign alu_operand_b = alu_src ? imm_ext : rdata2;

    alu u_alu (
        .a(rdata1),
        .b(alu_operand_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    // -------------------------------------------------------------------------
    // 4. Data Memory Subsystem (MEM)
    // -------------------------------------------------------------------------
    data_memory #(
        .MEM_DEPTH(DMEM_DEPTH)
    ) u_dmem (
        .clk(clk),
        .rst(rst),
        .we(mem_write),
        .funct3(funct3),
        .addr(alu_result),
        .wdata(rdata2),
        .rdata(dmem_rdata)
    );

    // -------------------------------------------------------------------------
    // 5. Writeback Multiplexer (WB)
    // -------------------------------------------------------------------------
    assign result_data = (result_src == `WB_ALU) ? alu_result :
                         (result_src == `WB_MEM) ? dmem_rdata :
                         (result_src == `WB_PC4) ? pc_plus_4 :
                         (result_src == `WB_LUI) ? imm_ext :
                                                   alu_result;

    // -------------------------------------------------------------------------
    // External Monitoring Probes
    // -------------------------------------------------------------------------
    assign debug_pc         = pc;
    assign debug_instr      = instr;
    assign debug_alu_result = alu_result;

endmodule
