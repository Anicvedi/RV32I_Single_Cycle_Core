`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Testbench: Program Counter & Instruction Memory (tb_fetch.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
// ==============================================================================

module tb_fetch;

    reg         clk;
    reg         rst;
    reg  [31:0] pc_next;
    wire [31:0] pc;
    wire [31:0] inst;

    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate Program Counter
    pc_reg #(
        .RESET_ADDR(32'h0000_0000)
    ) u_pc_reg (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    // Instantiate Instruction Memory (512 words)
    imem #(
        .MEM_DEPTH(512),
        .MEM_INIT_FILE("")
    ) u_imem (
        .addr(pc),
        .inst(inst)
    );

    // 100 MHz Clock generation (10 ns period)
    always #5 clk = ~clk;

    task check_val;
        input [31:0] got;
        input [31:0] expected;
        input [127:0] test_name;
        begin
            if (got === expected) begin
                $display("[PASS] %s | Expected: 0x%08h, Got: 0x%08h", test_name, expected, got);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s | Expected: 0x%08h, Got: 0x%08h", test_name, expected, got);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        pc_next = 32'h0000_0000;

        // Pre-fill a few locations in memory for test verification
        u_imem.mem[0] = 32'h00500113; // addi x2, x0, 5
        u_imem.mem[1] = 32'h00a00193; // addi x3, x0, 10
        u_imem.mem[2] = 32'h00310233; // add  x4, x2, x3
        u_imem.mem[3] = 32'hfe000ce3; // beq  x0, x0, target

        $display("==================================================================");
        $display("   STARTING RV32I INSTRUCTION FETCH & PC (Module 4) VERIFICATION  ");
        $display("==================================================================");

        // ---------------------------------------------------------------------
        // Test 1: Reset Behavior
        // ---------------------------------------------------------------------
        #15;
        check_val(pc, 32'h0000_0000, "Test 1: Reset PC Vector");
        check_val(inst, 32'h0050_0113, "Test 1: Fetch Inst at Reset PC");

        // Release reset
        rst = 0;

        // ---------------------------------------------------------------------
        // Test 2: Sequential Step (PC + 4)
        // ---------------------------------------------------------------------
        @(negedge clk);
        pc_next = pc + 32'd4;
        @(posedge clk);
        #1;
        check_val(pc, 32'h0000_0004, "Test 2A: PC Increment to 0x4");
        check_val(inst, 32'h00a0_0193, "Test 2B: Fetch Inst at PC=0x4");

        // ---------------------------------------------------------------------
        // Test 3: Another Sequential Step (PC + 4 -> 0x8)
        // ---------------------------------------------------------------------
        @(negedge clk);
        pc_next = pc + 32'd4;
        @(posedge clk);
        #1;
        check_val(pc, 32'h0000_0008, "Test 3A: PC Increment to 0x8");
        check_val(inst, 32'h0031_0233, "Test 3B: Fetch Inst at PC=0x8");

        // ---------------------------------------------------------------------
        // Test 4: Branch / Jump Target Vectoring (Arbitrary Jump to 0x40)
        // ---------------------------------------------------------------------
        @(negedge clk);
        pc_next = 32'h0000_0040;
        @(posedge clk);
        #1;
        check_val(pc, 32'h0000_0040, "Test 4A: Jump to Target PC=0x40");
        check_val(inst, 32'h0000_0013, "Test 4B: Default NOP at Uninitialized 0x40");

        // ---------------------------------------------------------------------
        // Test 5: Out of bounds Address Handling (> MEM_DEPTH words)
        // 512 words * 4 = 2048 (0x800). Test address 0x1000
        // ---------------------------------------------------------------------
        @(negedge clk);
        pc_next = 32'h0000_1000;
        @(posedge clk);
        #1;
        check_val(pc, 32'h0000_1000, "Test 5A: Out-of-bounds PC Address");
        check_val(inst, 32'h0000_0013, "Test 5B: Safe NOP on Out-of-bounds Read");

        // Final Summary
        $display("==================================================================");
        $display("   TEST SUMMARY: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("==================================================================");

        if (fail_count == 0) begin
            $display(">>> ALL FETCH & PC TESTS PASSED SUCCESSFULLY! <<<");
        end else begin
            $display(">>> SOME FETCH & PC TESTS FAILED! PLEASE REVIEW RTL! <<<");
        end

        $finish;
    end

endmodule
