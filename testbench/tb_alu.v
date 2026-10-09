// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Testbench for Module 1: 32-bit Arithmetic Logic Unit (ALU)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
// ==============================================================================

`timescale 1ns / 1ps
`include "rv32i_defines.v"

module tb_alu;

    reg  [31:0] a, b;
    reg  [3:0]  alu_op;
    wire [31:0] result;
    wire        zero;

    // Instantiate Unit Under Test (UUT)
    alu dut (
        .a      (a),
        .b      (b),
        .alu_op (alu_op),
        .result (result),
        .zero   (zero)
    );

    integer pass_count = 0;
    integer fail_count = 0;

    task check_result;
        input [31:0] expected_res;
        input        expected_zero;
        input [127:0] op_name;
        begin
            if (result === expected_res && zero === expected_zero) begin
                $display("[PASS] %0s | a=0x%08X, b=0x%08X -> Result=0x%08X, Zero=%b", 
                         op_name, a, b, result, zero);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s | a=0x%08X, b=0x%08X -> Got Result=0x%08X (Exp: 0x%08X), Got Zero=%b (Exp: %b)", 
                         op_name, a, b, result, expected_res, zero, expected_zero);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("================================================================");
        $display("  Starting RV32I ALU Corner-Case Self-Checking Testbench");
        $display("================================================================");

        // 1. ADD
        a = 32'd25; b = 32'd17; alu_op = `ALU_ADD; #10;
        check_result(32'd42, 1'b0, "ADD (25+17)");

        // 2. SUB and Zero Flag
        a = 32'd50; b = 32'd50; alu_op = `ALU_SUB; #10;
        check_result(32'd0, 1'b1, "SUB Zero (50-50)");

        // 3. SLL (Shift Left Logical by 3 bits)
        a = 32'h0000_000F; b = 32'd3; alu_op = `ALU_SLL; #10;
        check_result(32'h0000_0078, 1'b0, "SLL (0xF << 3)");

        // 4. SLT Corner Case (Signed: -1 < +1 should be TRUE = 1)
        a = 32'hFFFF_FFFF; // -1 signed
        b = 32'h0000_0001; // +1
        alu_op = `ALU_SLT; #10;
        check_result(32'd1, 1'b0, "SLT (-1 < +1)");

        // 5. SLTU Corner Case (Unsigned: 0xFFFFFFFF < 1 should be FALSE = 0)
        alu_op = `ALU_SLTU; #10;
        check_result(32'd0, 1'b1, "SLTU (MAX_UINT < 1)");

        // 6. XOR
        a = 32'hAAAA_5555; b = 32'hFFFF_0000; alu_op = `ALU_XOR; #10;
        check_result(32'h5555_5555, 1'b0, "XOR");

        // 7. SRL (Shift Right Logical: insert zeros)
        a = 32'h8000_0000; b = 32'd4; alu_op = `ALU_SRL; #10;
        check_result(32'h0800_0000, 1'b0, "SRL (0x80000000 >> 4)");

        // 8. SRA (Shift Right Arithmetic: replicate sign bit 1)
        alu_op = `ALU_SRA; #10;
        check_result(32'hF800_0000, 1'b0, "SRA (0x80000000 >>> 4)");

        // 9. OR
        a = 32'h00FF_0000; b = 32'h0000_FF00; alu_op = `ALU_OR; #10;
        check_result(32'h00FF_FF00, 1'b0, "OR");

        // 10. AND
        a = 32'hFFFF_00FF; b = 32'h00FF_FF00; alu_op = `ALU_AND; #10;
        check_result(32'h00FF_0000, 1'b0, "AND");

        $display("----------------------------------------------------------------");
        $display(" Testbench Summary: %0d Passed, %0d Failed", pass_count, fail_count);
        if (fail_count == 0) begin
            $display(" >>> ALL 10 ALU OPERATIONS & CORNER CASES PASSED! <<<");
        end else begin
            $display(" >>> ERRORS DETECTED IN ALU IMPLEMENTATION! <<<");
        end
        $display("================================================================\n");
        $finish;
    end

endmodule
