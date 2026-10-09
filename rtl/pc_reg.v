`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Module 4A: Program Counter Register (pc_reg.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
//
// Description:
// Synchronous 32-bit register holding the current instruction fetch address.
// Updates to pc_next on each rising clock edge. Resets to RESET_ADDR.
// ==============================================================================

module pc_reg #(
    parameter [31:0] RESET_ADDR = 32'h0000_0000
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= RESET_ADDR;
        end else begin
            pc <= pc_next;
        end
    end

endmodule
