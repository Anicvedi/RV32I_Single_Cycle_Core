`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Module 6: Main Control Unit & Instruction Decoder (control_unit.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
//
// Microarchitecture Specification:
// - Hardwired combinational control decoder (Single-Cycle CPI = 1.0).
// - Generates datapath routing and enable signals from instruction opcode, funct3, funct7.
// - Supports full RV32I base integer instruction set:
//     * R-Type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
//     * I-Type: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
//     * Load:   LB, LH, LW, LBU, LHU
//     * Store:  SB, SH, SW
//     * Branch: BEQ, BNE, BLT, BGE, BLTU, BGEU
//     * Jump:   JAL, JALR
//     * Upper:  LUI
// ==============================================================================

`include "rv32i_defines.v"

module control_unit (
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire        funct7_5,    // Bit 5 of funct7 (distinguishes SUB/ADD, SRA/SRL)
    input  wire        br_eq,       // Branch condition: rs1 == rs2
    input  wire        br_lt,       // Branch condition: signed(rs1) < signed(rs2)
    input  wire        br_ltu,      // Branch condition: unsigned(rs1) < unsigned(rs2)
    output reg         reg_write,   // Register file write enable
    output reg         mem_write,   // Data memory write enable
    output reg         alu_src,     // ALU operand B selector (0: rdata2, 1: immediate)
    output reg  [2:0]  imm_src,     // Immediate generator format selection
    output reg  [1:0]  result_src,  // Writeback Mux selector (ALU, MEM, PC+4, LUI)
    output reg  [1:0]  pc_src,      // Next PC selector (00: PC+4, 01: PC+Imm, 10: rs1+Imm)
    output reg  [3:0]  alu_op       // 4-bit ALU operation control code
);

    reg branch_taken;

    // -------------------------------------------------------------------------
    // 1. Branch Condition Evaluation
    // -------------------------------------------------------------------------
    always @(*) begin
        case (funct3)
            `FUNCT3_BEQ:  branch_taken = br_eq;
            `FUNCT3_BNE:  branch_taken = ~br_eq;
            `FUNCT3_BLT:  branch_taken = br_lt;
            `FUNCT3_BGE:  branch_taken = ~br_lt;
            `FUNCT3_BLTU: branch_taken = br_ltu;
            `FUNCT3_BGEU: branch_taken = ~br_ltu;
            default:      branch_taken = 1'b0;
        endcase
    end

    // -------------------------------------------------------------------------
    // 2. Main Decoder: Datapath Multiplexers and Write Enables
    // -------------------------------------------------------------------------
    always @(*) begin
        // Default safe values
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        alu_src    = 1'b0;
        imm_src    = `IMM_SRC_I;
        result_src = `WB_ALU;
        pc_src     = 2'b00;

        case (opcode)
            `OPCODE_R_TYPE: begin
                reg_write  = 1'b1;
                mem_write  = 1'b0;
                alu_src    = 1'b0; // rdata2
                imm_src    = `IMM_SRC_I;
                result_src = `WB_ALU;
                pc_src     = 2'b00;
            end

            `OPCODE_I_TYPE: begin
                reg_write  = 1'b1;
                mem_write  = 1'b0;
                alu_src    = 1'b1; // imm_ext
                imm_src    = `IMM_SRC_I;
                result_src = `WB_ALU;
                pc_src     = 2'b00;
            end

            `OPCODE_LOAD: begin
                reg_write  = 1'b1;
                mem_write  = 1'b0;
                alu_src    = 1'b1; // imm_ext
                imm_src    = `IMM_SRC_I;
                result_src = `WB_MEM; // Data memory read data
                pc_src     = 2'b00;
            end

            `OPCODE_STORE: begin
                reg_write  = 1'b0;
                mem_write  = 1'b1; // Memory write enabled
                alu_src    = 1'b1; // imm_ext
                imm_src    = `IMM_SRC_S;
                result_src = `WB_ALU;
                pc_src     = 2'b00;
            end

            `OPCODE_BRANCH: begin
                reg_write  = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                imm_src    = `IMM_SRC_B;
                result_src = `WB_ALU;
                pc_src     = branch_taken ? 2'b01 : 2'b00; // Branch target (PC+Imm) if taken
            end

            `OPCODE_JAL: begin
                reg_write  = 1'b1; // Link return address to rd
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                imm_src    = `IMM_SRC_J;
                result_src = `WB_PC4; // PC + 4
                pc_src     = 2'b01;   // Unconditional Jump (PC+Imm)
            end

            `OPCODE_JALR: begin
                reg_write  = 1'b1; // Link return address to rd
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                imm_src    = `IMM_SRC_I;
                result_src = `WB_PC4; // PC + 4
                pc_src     = 2'b10;   // Indirect Jump ((rs1+Imm) & ~1)
            end

            `OPCODE_LUI: begin
                reg_write  = 1'b1;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                imm_src    = `IMM_SRC_U;
                result_src = `WB_LUI; // Direct immediate writeback
                pc_src     = 2'b00;
            end

            default: begin
                reg_write  = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                imm_src    = `IMM_SRC_I;
                result_src = `WB_ALU;
                pc_src     = 2'b00;
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // 3. ALU Decoder: Generates 4-bit alu_op
    // -------------------------------------------------------------------------
    always @(*) begin
        case (opcode)
            `OPCODE_R_TYPE: begin
                case (funct3)
                    `FUNCT3_ADD_SUB: alu_op = funct7_5 ? `ALU_SUB : `ALU_ADD;
                    `FUNCT3_SLL:     alu_op = `ALU_SLL;
                    `FUNCT3_SLT:     alu_op = `ALU_SLT;
                    `FUNCT3_SLTU:    alu_op = `ALU_SLTU;
                    `FUNCT3_XOR:     alu_op = `ALU_XOR;
                    `FUNCT3_SRL_SRA: alu_op = funct7_5 ? `ALU_SRA : `ALU_SRL;
                    `FUNCT3_OR:      alu_op = `ALU_OR;
                    `FUNCT3_AND:     alu_op = `ALU_AND;
                    default:         alu_op = `ALU_ADD;
                endcase
            end

            `OPCODE_I_TYPE: begin
                case (funct3)
                    `FUNCT3_ADD_SUB: alu_op = `ALU_ADD;
                    `FUNCT3_SLL:     alu_op = `ALU_SLL;
                    `FUNCT3_SLT:     alu_op = `ALU_SLT;
                    `FUNCT3_SLTU:    alu_op = `ALU_SLTU;
                    `FUNCT3_XOR:     alu_op = `ALU_XOR;
                    `FUNCT3_SRL_SRA: alu_op = funct7_5 ? `ALU_SRA : `ALU_SRL; // SRAI vs SRLI
                    `FUNCT3_OR:      alu_op = `ALU_OR;
                    `FUNCT3_AND:     alu_op = `ALU_AND;
                    default:         alu_op = `ALU_ADD;
                endcase
            end

            `OPCODE_LOAD,
            `OPCODE_STORE,
            `OPCODE_JALR: begin
                alu_op = `ALU_ADD; // Address arithmetic (base + offset)
            end

            `OPCODE_BRANCH: begin
                alu_op = `ALU_SUB; // Subtraction for zero flag
            end

            default: begin
                alu_op = `ALU_ADD;
            end
        endcase
    end

endmodule
