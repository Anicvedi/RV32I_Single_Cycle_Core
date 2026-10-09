`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Testbench: Control Unit & Decoder Verification (tb_control_unit.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
// ==============================================================================

`include "rv32i_defines.v"

module tb_control_unit;

    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg        funct7_5;
    reg        br_eq;
    reg        br_lt;
    reg        br_ltu;

    wire       reg_write;
    wire       mem_write;
    wire       alu_src;
    wire [2:0] imm_src;
    wire [1:0] result_src;
    wire [1:0] pc_src;
    wire [3:0] alu_op;

    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate UUT
    control_unit uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7_5),
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

    task check_ctrl;
        input exp_reg_write;
        input exp_mem_write;
        input exp_alu_src;
        input [2:0] exp_imm_src;
        input [1:0] exp_result_src;
        input [1:0] exp_pc_src;
        input [3:0] exp_alu_op;
        input [127:0] test_name;
        begin
            #1;
            if (reg_write === exp_reg_write &&
                mem_write === exp_mem_write &&
                alu_src   === exp_alu_src &&
                imm_src   === exp_imm_src &&
                result_src === exp_result_src &&
                pc_src    === exp_pc_src &&
                alu_op    === exp_alu_op) begin
                $display("[PASS] %s", test_name);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s | Got: RegWr=%b MemWr=%b AluSrc=%b ImmSrc=%b ResSrc=%b PcSrc=%b AluOp=%b",
                         test_name, reg_write, mem_write, alu_src, imm_src, result_src, pc_src, alu_op);
                $display("       Expected: RegWr=%b MemWr=%b AluSrc=%b ImmSrc=%b ResSrc=%b PcSrc=%b AluOp=%b",
                         exp_reg_write, exp_mem_write, exp_alu_src, exp_imm_src, exp_result_src, exp_pc_src, exp_alu_op);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        opcode   = 7'd0;
        funct3   = 3'd0;
        funct7_5 = 1'b0;
        br_eq    = 1'b0;
        br_lt    = 1'b0;
        br_ltu   = 1'b0;

        $display("==================================================================");
        $display("   STARTING RV32I CONTROL UNIT (control_unit) VERIFICATION        ");
        $display("==================================================================");

        // ---------------------------------------------------------------------
        // Test 1: R-Type ADD (opcode 0110011, funct3 000, funct7_5 0)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_R_TYPE; funct3 = `FUNCT3_ADD_SUB; funct7_5 = 1'b0;
        check_ctrl(1'b1, 1'b0, 1'b0, `IMM_SRC_I, `WB_ALU, 2'b00, `ALU_ADD, "Test 1: R-Type ADD");

        // ---------------------------------------------------------------------
        // Test 2: R-Type SUB (opcode 0110011, funct3 000, funct7_5 1)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_R_TYPE; funct3 = `FUNCT3_ADD_SUB; funct7_5 = 1'b1;
        check_ctrl(1'b1, 1'b0, 1'b0, `IMM_SRC_I, `WB_ALU, 2'b00, `ALU_SUB, "Test 2: R-Type SUB");

        // ---------------------------------------------------------------------
        // Test 3: I-Type ADDI (opcode 0010011, funct3 000)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_I_TYPE; funct3 = `FUNCT3_ADD_SUB; funct7_5 = 1'b0;
        check_ctrl(1'b1, 1'b0, 1'b1, `IMM_SRC_I, `WB_ALU, 2'b00, `ALU_ADD, "Test 3: I-Type ADDI");

        // ---------------------------------------------------------------------
        // Test 4: I-Type SRAI (opcode 0010011, funct3 101, funct7_5 1)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_I_TYPE; funct3 = `FUNCT3_SRL_SRA; funct7_5 = 1'b1;
        check_ctrl(1'b1, 1'b0, 1'b1, `IMM_SRC_I, `WB_ALU, 2'b00, `ALU_SRA, "Test 4: I-Type SRAI");

        // ---------------------------------------------------------------------
        // Test 5: Load Word LW (opcode 0000011, funct3 010)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_LOAD; funct3 = `FUNCT3_LW; funct7_5 = 1'b0;
        check_ctrl(1'b1, 1'b0, 1'b1, `IMM_SRC_I, `WB_MEM, 2'b00, `ALU_ADD, "Test 5: Load Word LW");

        // ---------------------------------------------------------------------
        // Test 6: Store Word SW (opcode 0100011, funct3 010)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_STORE; funct3 = `FUNCT3_SW; funct7_5 = 1'b0;
        check_ctrl(1'b0, 1'b1, 1'b1, `IMM_SRC_S, `WB_ALU, 2'b00, `ALU_ADD, "Test 6: Store Word SW");

        // ---------------------------------------------------------------------
        // Test 7: Branch BEQ Taken (opcode 1100011, funct3 000, br_eq = 1)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_BRANCH; funct3 = `FUNCT3_BEQ; br_eq = 1'b1;
        check_ctrl(1'b0, 1'b0, 1'b0, `IMM_SRC_B, `WB_ALU, 2'b01, `ALU_SUB, "Test 7: Branch BEQ Taken");

        // ---------------------------------------------------------------------
        // Test 8: Branch BEQ Not Taken (opcode 1100011, funct3 000, br_eq = 0)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_BRANCH; funct3 = `FUNCT3_BEQ; br_eq = 1'b0;
        check_ctrl(1'b0, 1'b0, 1'b0, `IMM_SRC_B, `WB_ALU, 2'b00, `ALU_SUB, "Test 8: Branch BEQ Not Taken");

        // ---------------------------------------------------------------------
        // Test 9: Jump and Link JAL (opcode 1101111)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_JAL; funct3 = 3'b000;
        check_ctrl(1'b1, 1'b0, 1'b0, `IMM_SRC_J, `WB_PC4, 2'b01, `ALU_ADD, "Test 9: Jump JAL");

        // ---------------------------------------------------------------------
        // Test 10: Jump and Link Register JALR (opcode 1100111, funct3 000)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_JALR; funct3 = 3'b000;
        check_ctrl(1'b1, 1'b0, 1'b1, `IMM_SRC_I, `WB_PC4, 2'b10, `ALU_ADD, "Test 10: Jump JALR");

        // ---------------------------------------------------------------------
        // Test 11: Load Upper Immediate LUI (opcode 0110111)
        // ---------------------------------------------------------------------
        opcode = `OPCODE_LUI; funct3 = 3'b000;
        check_ctrl(1'b1, 1'b0, 1'b1, `IMM_SRC_U, `WB_LUI, 2'b00, `ALU_ADD, "Test 11: Load Upper LUI");

        // Final Summary
        $display("==================================================================");
        $display("   TEST SUMMARY: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("==================================================================");

        if (fail_count == 0) begin
            $display(">>> ALL CONTROL UNIT TESTS PASSED SUCCESSFULLY! <<<");
        end else begin
            $display(">>> SOME CONTROL UNIT TESTS FAILED! PLEASE REVIEW RTL! <<<");
        end

        $finish;
    end

endmodule
