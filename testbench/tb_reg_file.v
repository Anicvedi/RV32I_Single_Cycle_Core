`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Testbench: 32x32 Register File Verification (tb_reg_file.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
// ==============================================================================

module tb_reg_file;

    reg         clk;
    reg         rst;
    reg  [4:0]  raddr1;
    reg  [4:0]  raddr2;
    reg  [4:0]  waddr;
    reg  [31:0] wdata;
    reg         we;

    wire [31:0] rdata1;
    wire [31:0] rdata2;
    wire [31:0] x10;
    wire [31:0] x11;

    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate UUT
    reg_file uut (
        .clk(clk),
        .rst(rst),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .wdata(wdata),
        .we(we),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .x10(x10),
        .x11(x11)
    );

    // Clock generation: 100 MHz (10ns period)
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
        raddr1 = 0;
        raddr2 = 0;
        waddr = 0;
        wdata = 0;

        $display("==================================================================");
        $display("      STARTING RV32I REGISTER FILE (reg_file) VERIFICATION        ");
        $display("==================================================================");

        // ---------------------------------------------------------------------
        // Test 1: Reset Test - Read all registers, verify they are zero
        // ---------------------------------------------------------------------
        #15;
        rst = 0;
        #5;
        raddr1 = 5'd1;
        raddr2 = 5'd31;
        #1;
        check_val(rdata1, 32'h00000000, "Test 1A: Post-Reset Read x1");
        check_val(rdata2, 32'h00000000, "Test 1B: Post-Reset Read x31");

        // ---------------------------------------------------------------------
        // Test 2: Invariant Check - Write to x0 must be ignored
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 1;
        waddr = 5'd0;
        wdata = 32'hDEADBEEF;
        @(negedge clk);
        we = 0;
        raddr1 = 5'd0;
        #1;
        check_val(rdata1, 32'h00000000, "Test 2: Hardwired x0 Zero Invariant");

        // ---------------------------------------------------------------------
        // Test 3: Write and Dual Asynchronous Read
        // Write x5 = 0x12345678, Write x6 = 0x87654321
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 1;
        waddr = 5'd5;
        wdata = 32'h12345678;
        @(negedge clk);
        waddr = 5'd6;
        wdata = 32'h87654321;
        @(negedge clk);
        we = 0;

        // Perform simultaneous asynchronous read
        raddr1 = 5'd5;
        raddr2 = 5'd6;
        #1;
        check_val(rdata1, 32'h12345678, "Test 3A: Read x5 Asynchronously");
        check_val(rdata2, 32'h87654321, "Test 3B: Read x6 Asynchronously");

        // ---------------------------------------------------------------------
        // Test 4: Write Enable Inactive (we == 0)
        // Attempt to write to x5 with we = 0, value must remain unchanged
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 0;
        waddr = 5'd5;
        wdata = 32'hBAADF00D;
        @(negedge clk);
        raddr1 = 5'd5;
        #1;
        check_val(rdata1, 32'h12345678, "Test 4: Write Inhibit When we=0");

        // ---------------------------------------------------------------------
        // Test 5: Overwrite existing register value
        // Update x5 with new value
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 1;
        waddr = 5'd5;
        wdata = 32'hCAFEFEED;
        @(negedge clk);
        we = 0;
        raddr1 = 5'd5;
        #1;
        check_val(rdata1, 32'hCAFEFEED, "Test 5: Overwrite Register x5");

        // ---------------------------------------------------------------------
        // Test 6: Debug Probes for a0 (x10) and a1 (x11)
        // Benchmark division results land here: Quotient in a0, Remainder in a1
        // ---------------------------------------------------------------------
        @(negedge clk);
        we = 1;
        waddr = 5'd10; // a0
        wdata = 32'd14; // Quotient 14 (100 / 7)
        @(negedge clk);
        waddr = 5'd11; // a1
        wdata = 32'd2;  // Remainder 2 (100 % 7)
        @(negedge clk);
        we = 0;
        #1;
        check_val(x10, 32'd14, "Test 6A: Debug Probe a0 (x10 Quotient)");
        check_val(x11, 32'd2,  "Test 6B: Debug Probe a1 (x11 Remainder)");

        // Final Summary
        $display("==================================================================");
        $display("   TEST SUMMARY: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("==================================================================");

        if (fail_count == 0) begin
            $display(">>> ALL REGISTER FILE TESTS PASSED SUCCESSFULLY! <<<");
        end else begin
            $display(">>> SOME REGISTER FILE TESTS FAILED! PLEASE REVIEW RTL! <<<");
        end

        $finish;
    end

endmodule
