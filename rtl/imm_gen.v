`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Module 2: Immediate Generator (imm_gen.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
// ==============================================================================

`include "rv32i_defines.v"

module imm_gen (
    input  wire [31:7] instr,    // Instruction bits [31:7]
    input  wire [2:0]  imm_src,  // Immediate format select from Control Unit
    output reg  [31:0] imm_ext   // Sign-extended 32-bit immediate
);

    always @(*) begin
        case (imm_src)
            `IMM_SRC_I: begin
                // I-type: imm[11:0] = instr[31:20]
                imm_ext = {{20{instr[31]}}, instr[31:20]};
            end

            `IMM_SRC_S: begin
                // S-type: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
                imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            `IMM_SRC_B: begin
                // B-type: imm[12|10:5|4:1|11] -> imm[12] = instr[31], imm[11] = instr[7],
                // imm[10:5] = instr[30:25], imm[4:1] = instr[11:8], imm[0] = 1'b0
                imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            `IMM_SRC_U: begin
                // U-type: imm[31:12] = instr[31:12], imm[11:0] = 0
                imm_ext = {instr[31:12], 12'b0};
            end

            `IMM_SRC_J: begin
                // J-type: imm[20|10:1|11|19:12] -> imm[20] = instr[31], imm[19:12] = instr[19:12],
                // imm[11] = instr[20], imm[10:1] = instr[30:21], imm[0] = 1'b0
                imm_ext = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            default: begin
                imm_ext = 32'h00000000;
            end
        endcase
    end

endmodule
