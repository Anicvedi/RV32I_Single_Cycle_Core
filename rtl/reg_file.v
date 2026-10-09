`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Module 3: 32 x 32-bit Register File (reg_file.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
//
// Microarchitecture Specification:
// - 32 general-purpose 32-bit registers (x0 to x31).
// - Register x0 hardwired to constant 0 (reads always return 0, writes ignored).
// - Dual independent asynchronous read ports (raddr1, raddr2).
// - Single synchronous write port (waddr, wdata, we) on posedge clk.
// - Hardware debug taps for x10 (a0) and x11 (a1) for 7-segment / benchmark monitoring.
// ==============================================================================

module reg_file (
    input  wire        clk,
    input  wire        rst,
    input  wire [4:0]  raddr1,
    input  wire [4:0]  raddr2,
    input  wire [4:0]  waddr,
    input  wire [31:0] wdata,
    input  wire        we,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2,
    // Hardware debug probes (a0 = x10: return quotient, a1 = x11: return remainder)
    output wire [31:0] x10,
    output wire [31:0] x11
);

    (* keep = "true" *) reg [31:0] regs [0:31];
    integer i;

    // Asynchronous dual read ports: x0 is hardwired to 0
    assign rdata1 = (raddr1 == 5'd0) ? 32'h00000000 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'd0) ? 32'h00000000 : regs[raddr2];

    // Hardware debug tap for benchmark and 7-segment display
    assign x10 = regs[10];
    assign x11 = regs[11];

    // Synchronous write port on posedge clk with active-high reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'h00000000;
            end
        end else if (we && (waddr != 5'd0)) begin
            regs[waddr] <= wdata;
        end
    end

endmodule
