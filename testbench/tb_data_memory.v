`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Testbench: 4-Banked Data Memory Subsystem Verification (tb_data_memory.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
// ==============================================================================

`include "rv32i_defines.v"

module tb_data_memory;

    reg         clk;
    reg         rst;
    reg         we;
    reg  [2:0]  funct3;
    reg  [31:0] addr;
    reg  [31:0] wdata;
    wire [31:0] rdata;

    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate UUT
    data_memory #(
        .MEM_DEPTH(512)
    ) uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .funct3(funct3),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    // 100 MHz clock (10 ns period)
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
        we = 0;
        funct3 = `FUNCT3_LW;
        addr = 0;
        wdata = 0;

        $display("==================================================================");
        $display("   STARTING RV32I DATA MEMORY (data_memory) VERIFICATION          ");
        $display("==================================================================");

        #15;
        rst = 0;

        // ---------------------------------------------------------------------
        // Test 1: Full Word Store and Load (SW & LW)
        // Store 0xDEADBEEF at addr 0x00000000
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 1;
        funct3 = `FUNCT3_SW;
        addr = 32'h0000_0000;
        wdata = 32'hDEAD_BEEF;
        @(negedge clk);
        we = 0;
        funct3 = `FUNCT3_LW;
        #1;
        check_val(rdata, 32'hDEAD_BEEF, "Test 1: SW and LW (0xDEADBEEF)");

        // ---------------------------------------------------------------------
        // Test 2: Byte Store and Signed/Unsigned Load (SB, LB, LBU)
        // Store 0xFE (negative signed byte) at addr 0x00000004
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 1;
        funct3 = `FUNCT3_SB;
        addr = 32'h0000_0004;
        wdata = 32'h0000_00FE;
        @(negedge clk);
        we = 0;
        
        // Read signed byte LB
        funct3 = `FUNCT3_LB;
        #1;
        check_val(rdata, 32'hFFFF_FFFE, "Test 2A: LB Sign Extension (0xFE -> 0xFFFFFFFE)");

        // Read unsigned byte LBU
        funct3 = `FUNCT3_LBU;
        #1;
        check_val(rdata, 32'h0000_00FE, "Test 2B: LBU Zero Extension (0xFE -> 0x000000FE)");

        // ---------------------------------------------------------------------
        // Test 3: Byte Store to higher byte lanes (addr offset 1, 2, 3)
        // Store 0x12 at addr 0x05 (byte 1), 0x34 at addr 0x06 (byte 2)
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 1;
        funct3 = `FUNCT3_SB;
        addr = 32'h0000_0005;
        wdata = 32'h0000_0012;
        @(negedge clk);
        addr = 32'h0000_0006;
        wdata = 32'h0000_0034;
        @(negedge clk);
        we = 0;

        // Read back byte 1 with LB
        addr = 32'h0000_0005;
        funct3 = `FUNCT3_LB;
        #1;
        check_val(rdata, 32'h0000_0012, "Test 3A: LB at Byte Lane 1 (0x12)");

        // Read full word at 0x04: should be 0x003412FE
        addr = 32'h0000_0004;
        funct3 = `FUNCT3_LW;
        #1;
        check_val(rdata, 32'h0034_12FE, "Test 3B: Word Composition (0x003412FE)");

        // ---------------------------------------------------------------------
        // Test 4: Halfword Store and Load (SH, LH, LHU)
        // Store 0x8ABC (negative signed halfword) at addr 0x00000008 (lower half)
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 1;
        funct3 = `FUNCT3_SH;
        addr = 32'h0000_0008;
        wdata = 32'h0000_8ABC;
        @(negedge clk);
        we = 0;

        // Read LH signed halfword
        funct3 = `FUNCT3_LH;
        #1;
        check_val(rdata, 32'hFFFF_8ABC, "Test 4A: LH Sign Extension (0x8ABC -> 0xFFFF8ABC)");

        // Read LHU unsigned halfword
        funct3 = `FUNCT3_LHU;
        #1;
        check_val(rdata, 32'h0000_8ABC, "Test 4B: LHU Zero Extension (0x8ABC -> 0x00008ABC)");

        // Store 0x1234 at upper halfword (addr 0x0000000A)
        @(negedge clk);
        we = 1;
        funct3 = `FUNCT3_SH;
        addr = 32'h0000_000A;
        wdata = 32'h0000_1234;
        @(negedge clk);
        we = 0;

        // Read back full word at 0x00000008: should be 0x12348ABC
        funct3 = `FUNCT3_LW;
        addr = 32'h0000_0008;
        #1;
        check_val(rdata, 32'h1234_8ABC, "Test 4C: Full Word Composition of Two Halfwords");

        // ---------------------------------------------------------------------
        // Test 5: Write Enable Inhibit (we = 0)
        // Attempt to overwrite 0xDEADBEEF at 0x00 with 0xCAFEBABE while we=0
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 0;
        funct3 = `FUNCT3_SW;
        addr = 32'h0000_0000;
        wdata = 32'hCAFE_BABE;
        @(negedge clk);
        funct3 = `FUNCT3_LW;
        #1;
        check_val(rdata, 32'hDEAD_BEEF, "Test 5: Write Inhibit When we=0");

        // Final Summary
        $display("==================================================================");
        $display("   TEST SUMMARY: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("==================================================================");

        if (fail_count == 0) begin
            $display(">>> ALL DATA MEMORY TESTS PASSED SUCCESSFULLY! <<<");
        end else begin
            $display(">>> SOME DATA MEMORY TESTS FAILED! PLEASE REVIEW RTL! <<<");
        end

        $finish;
    end

endmodule
