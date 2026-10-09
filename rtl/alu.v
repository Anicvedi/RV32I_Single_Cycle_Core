// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Module 1: 32-bit Arithmetic Logic Unit (ALU)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
// ==============================================================================

`include "rv32i_defines.v"

module alu (
    input  wire [31:0] a,        // Operand A (from Register File rdata1)
    input  wire [31:0] b,        // Operand B (from ALUSrc Mux: rdata2 or Imm)
    input  wire [3:0]  alu_op,   // 4-bit Operation Control Code
    output reg  [31:0] result,   // 32-bit ALU Result
    output wire        zero      // 1-bit Zero Flag (1 if result == 0)
);

    always @(*) begin
        case (alu_op)
            `ALU_ADD:  result = a + b;
            `ALU_SUB:  result = a - b;
            `ALU_SLL:  result = a << b[4:0];
            `ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            `ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;
            `ALU_XOR:  result = a ^ b;
            `ALU_SRL:  result = a >> b[4:0];
            `ALU_SRA:  result = $signed(a) >>> b[4:0];
            `ALU_OR:   result = a | b;
            `ALU_AND:  result = a & b;
            default:   result = 32'd0;
        endcase
    end

    // Zero flag output: asserted when result is all zeros (used by branches)
    assign zero = (result == 32'd0);

endmodule
