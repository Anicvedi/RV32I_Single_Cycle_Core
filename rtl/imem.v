`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Module 4B: Instruction Memory (imem.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
//
// Microarchitecture Specification:
// - Word-addressable 32-bit memory holding RV32I machine instructions.
// - Implemented via pure Distributed ROM (LUT architecture) with asynchronous
//   combinational reads to satisfy true single-cycle (CPI=1.0) timing.
// - Word-aligned address indexing via addr[31:2].
// - Preloaded with machine hex via parameter MEM_INIT_FILE or $readmemh.
// - Out-of-bounds accesses safely return NOP (addi x0, x0, 0 = 32'h00000013).
// ==============================================================================

module imem #(
    parameter MEM_DEPTH     = 512,                     // 512 words = 2048 bytes
    parameter MEM_INIT_FILE = ""
)(
    input  wire [31:0] addr,                           // Byte address from PC
    output wire [31:0] inst                            // 32-bit instruction
);

    reg [31:0] mem [0:MEM_DEPTH-1];
    integer i;

    initial begin
        // Initialize memory array with default NOP instructions
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = 32'h0000_0013; // addi x0, x0, 0 (NOP)
        end
        // If an initialization hex file is specified, load it
        if (MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, mem);
        end
    end

    // Asynchronous read indexed by word address (addr[31:2])
    assign inst = (addr[31:2] < MEM_DEPTH) ? mem[addr[31:2]] : 32'h0000_0013;

endmodule
