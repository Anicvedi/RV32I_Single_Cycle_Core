// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Architecture Header Definitions
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
// ==============================================================================

`ifndef RV32I_DEFINES_V
`define RV32I_DEFINES_V

// -----------------------------------------------------------------------------
// 1. ALU Operation Encodings (4-bit alu_op)
// -----------------------------------------------------------------------------
`define ALU_ADD   4'b0000 // Addition (a + b)
`define ALU_SUB   4'b0001 // Subtraction (a - b)
`define ALU_SLL   4'b0010 // Shift Left Logical (a << b[4:0])
`define ALU_SLT   4'b0011 // Set Less Than Signed (($signed(a) < $signed(b)) ? 1 : 0)
`define ALU_SLTU  4'b0100 // Set Less Than Unsigned ((a < b) ? 1 : 0)
`define ALU_XOR   4'b0101 // Bitwise XOR (a ^ b)
`define ALU_SRL   4'b0110 // Shift Right Logical (a >> b[4:0])
`define ALU_SRA   4'b0111 // Shift Right Arithmetic ($signed(a) >>> b[4:0])
`define ALU_OR    4'b1000 // Bitwise OR (a | b)
`define ALU_AND   4'b1001 // Bitwise AND (a & b)

// -----------------------------------------------------------------------------
// 2. Base Instruction Opcodes [6:0]
// -----------------------------------------------------------------------------
`define OPCODE_R_TYPE   7'b0110011
`define OPCODE_I_TYPE   7'b0010011
`define OPCODE_LOAD     7'b0000011
`define OPCODE_STORE    7'b0100011
`define OPCODE_BRANCH   7'b1100011
`define OPCODE_JAL      7'b1101111
`define OPCODE_JALR     7'b1100111
`define OPCODE_LUI      7'b0110111

// -----------------------------------------------------------------------------
// 3. Funct3 Encodings
// -----------------------------------------------------------------------------
`define FUNCT3_ADD_SUB  3'b000
`define FUNCT3_SLL      3'b001
`define FUNCT3_SLT      3'b010
`define FUNCT3_SLTU     3'b011
`define FUNCT3_XOR      3'b100
`define FUNCT3_SRL_SRA  3'b101
`define FUNCT3_OR       3'b110
`define FUNCT3_AND      3'b111

// Branches
`define FUNCT3_BEQ      3'b000
`define FUNCT3_BNE      3'b001
`define FUNCT3_BLT      3'b100
`define FUNCT3_BGE      3'b101
`define FUNCT3_BLTU     3'b110
`define FUNCT3_BGEU     3'b111

// Loads & Stores
`define FUNCT3_LB       3'b000
`define FUNCT3_LH       3'b001
`define FUNCT3_LW       3'b010
`define FUNCT3_LBU      3'b100
`define FUNCT3_LHU      3'b101
`define FUNCT3_SB       3'b000
`define FUNCT3_SH       3'b001
`define FUNCT3_SW       3'b010

// -----------------------------------------------------------------------------
// 4. Writeback Multiplexer Selection Codes
// -----------------------------------------------------------------------------
`define WB_ALU          2'b00
`define WB_MEM          2'b01
`define WB_PC4          2'b10
`define WB_LUI          2'b11

`endif
