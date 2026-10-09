`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Testbench: Immediate Generator Verification (tb_imm_gen.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
// ==============================================================================

`include "rv32i_defines.v"

module tb_imm_gen;

    reg  [31:7] instr;
    reg  [2:0]  imm_src;
    wire [31:0] imm_ext;

    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate Unit Under Test (UUT)
    imm_gen uut (
        .instr(instr),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    task check_result;
        input [31:0] expected;
        input [127:0] test_name;
        begin
            #1; // Wait for combinational settling
            if (imm_ext === expected) begin
                $display("[PASS] %s | Expected: 0x%08h, Got: 0x%08h", test_name, expected, imm_ext);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s | Expected: 0x%08h, Got: 0x%08h", test_name, expected, imm_ext);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("==================================================================");
        $display("   STARTING RV32I IMMEDIATE GENERATOR (imm_gen) VERIFICATION     ");
        $display("==================================================================");

        // ---------------------------------------------------------------------
        // Test 1: I-Type Positive Immediate
        // Example: ADDI x1, x2, 12'h02A (+42)
        // instr[31:20] = 12'h02A
        // ---------------------------------------------------------------------
        instr = 25'b0;
        instr[31:20] = 12'h02A;
        imm_src = `IMM_SRC_I;
        check_result(32'h0000002A, "Test 1: I-Type Positive (+42)");

        // ---------------------------------------------------------------------
        // Test 2: I-Type Negative Immediate (Sign extension verification)
        // Example: ADDI x1, x2, -1 (12'hFFF)
        // instr[31:20] = 12'hFFF
        // ---------------------------------------------------------------------
        instr = 25'b0;
        instr[31:20] = 12'hFFF;
        imm_src = `IMM_SRC_I;
        check_result(32'hFFFFFFFF, "Test 2: I-Type Negative (-1)");

        // ---------------------------------------------------------------------
        // Test 3: S-Type Positive Immediate
        // Example: SW x1, 44(x2) -> imm = 44 = 12'h02C = 12'b0000_0010_1100
        // instr[31:25] = 7'b0000001, instr[11:7] = 5'b01100
        // ---------------------------------------------------------------------
        instr = 25'b0;
        instr[31:25] = 7'b0000001;
        instr[11:7]  = 5'b01100;
        imm_src = `IMM_SRC_S;
        check_result(32'h0000002C, "Test 3: S-Type Positive (+44)");

        // ---------------------------------------------------------------------
        // Test 4: S-Type Negative Immediate
        // Example: SW x1, -16(x2) -> imm = -16 = 12'hFF0 = 12'b1111_1111_0000
        // instr[31:25] = 7'b1111111, instr[11:7] = 5'b10000
        // ---------------------------------------------------------------------
        instr = 25'b0;
        instr[31:25] = 7'b1111111;
        instr[11:7]  = 5'b10000;
        imm_src = `IMM_SRC_S;
        check_result(32'hFFFFFFF0, "Test 4: S-Type Negative (-16)");

        // ---------------------------------------------------------------------
        // Test 5: B-Type Positive Offset
        // Example: BEQ x1, x2, +32 (13'b0_0000_0010_0000, 13'h020)
        // imm[12] = instr[31] = 0
        // imm[11] = instr[7]  = 0
        // imm[10:5] = instr[30:25] = 6'b000001
        // imm[4:1] = instr[11:8] = 4'b0000
        // ---------------------------------------------------------------------
        instr = 25'b0;
        instr[31]    = 1'b0;
        instr[7]     = 1'b0;
        instr[30:25] = 6'b000001;
        instr[11:8]  = 4'b0000;
        imm_src = `IMM_SRC_B;
        check_result(32'h00000020, "Test 5: B-Type Positive (+32)");

        // ---------------------------------------------------------------------
        // Test 6: B-Type Negative Offset
        // Example: BNE x1, x2, -8 (13'b1_1111_1111_1000, 13'h1FF8)
        // imm[12] = instr[31] = 1
        // imm[11] = instr[7]  = 1
        // imm[10:5] = instr[30:25] = 6'b111111
        // imm[4:1] = instr[11:8] = 4'b1100
        // ---------------------------------------------------------------------
        instr = 25'b0;
        instr[31]    = 1'b1;
        instr[7]     = 1'b1;
        instr[30:25] = 6'b111111;
        instr[11:8]  = 4'b1100;
        imm_src = `IMM_SRC_B;
        check_result(32'hFFFFFFF8, "Test 6: B-Type Negative (-8)");

        // ---------------------------------------------------------------------
        // Test 7: U-Type Upper Immediate
        // Example: LUI x1, 0x12345
        // instr[31:12] = 20'h12345
        // Expected: 32'h12345000
        // ---------------------------------------------------------------------
        instr = 25'b0;
        instr[31:12] = 20'h12345;
        imm_src = `IMM_SRC_U;
        check_result(32'h12345000, "Test 7: U-Type (LUI 0x12345)");

        // ---------------------------------------------------------------------
        // Test 8: J-Type Positive Jump Target
        // Example: JAL x1, +512 (21'b0_0000_0000_0010_0000_0000 = 21'h00200)
        // imm[20] = instr[31] = 0
        // imm[19:12] = instr[19:12] = 8'b00000000
        // imm[11] = instr[20] = 0
        // imm[10:1] = instr[30:21] = 10'b0001000000 (val 64)
        // imm[10:1]*2 = 128? Wait: imm[9] is bit 9. 512 is bit 9 = 1!
        // imm = 512 = 21'b0_0000_0000_0010_0000_0000
        // imm[10:1] = 512 >> 1 = 256 = 10'b0100000000
        // ---------------------------------------------------------------------
        instr = 25'b0;
        instr[31]    = 1'b0;
        instr[19:12] = 8'b00000000;
        instr[20]    = 1'b0;
        instr[30:21] = 10'b0100000000;
        imm_src = `IMM_SRC_J;
        check_result(32'h00000200, "Test 8: J-Type Positive (+512)");

        // ---------------------------------------------------------------------
        // Test 9: J-Type Negative Jump Target
        // Example: JAL x1, -4 (21'h1FFFFC)
        // imm = -4 = 21'b1_1111_1111_1111_1111_1100
        // imm[20] = instr[31] = 1
        // imm[19:12] = instr[19:12] = 8'hFF
        // imm[11] = instr[20] = 1
        // imm[10:1] = instr[30:21] = 10'b1111111110 (10'h3FE)
        // ---------------------------------------------------------------------
        instr = 25'b0;
        instr[31]    = 1'b1;
        instr[19:12] = 8'hFF;
        instr[20]    = 1'b1;
        instr[30:21] = 10'b1111111110;
        imm_src = `IMM_SRC_J;
        check_result(32'hFFFFFFFC, "Test 9: J-Type Negative (-4)");

        // Final Summary
        $display("==================================================================");
        $display("   TEST SUMMARY: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("==================================================================");

        if (fail_count == 0) begin
            $display(">>> ALL IMM_GEN TESTS PASSED SUCCESSFULLY! <<<");
        end else begin
            $display(">>> SOME IMM_GEN TESTS FAILED! PLEASE REVIEW RTL! <<<");
        end

        $finish;
    end

endmodule
