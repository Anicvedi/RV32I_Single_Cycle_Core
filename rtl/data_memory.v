`timescale 1ns / 1ps
// ==============================================================================
// 32-bit Single-Cycle RISC-V Processor (RV32I)
// Target Device: AMD Xilinx Artix-7 (XC7A35T-1CPG236C, Digilent Basys 3)
// Module 5: 4-Banked Distributed Data Memory Subsystem (data_memory.v)
// Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
//
// Microarchitecture Specification:
// - Byte-addressable 4-banked distributed RAM architecture.
// - Pure Distributed RAM (LUT RAM) with asynchronous combinational reads
//   to satisfy single-cycle execution constraint (CPI = 1.0).
// - Synchronous writes on posedge clk with individual byte lane enables.
// - Full RV32I load/store support:
//     * Stores: SB (byte), SH (halfword), SW (word)
//     * Loads:  LB (signed byte), LH (signed halfword), LW (word),
//               LBU (unsigned byte), LHU (unsigned halfword)
// ==============================================================================

`include "rv32i_defines.v"

module data_memory #(
    parameter MEM_DEPTH = 512                     // 512 words = 2048 bytes
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        we,                         // Memory Write Enable
    input  wire [2:0]  funct3,                     // Load / Store width specifier
    input  wire [31:0] addr,                       // Byte address from ALU
    input  wire [31:0] wdata,                      // Write data from RegFile rdata2
    output reg  [31:0] rdata                       // Read data to Writeback Mux
);

    // 4 physical byte banks to support individual byte lane enables
    (* keep = "true" *) reg [7:0] bank0 [0:MEM_DEPTH-1];
    (* keep = "true" *) reg [7:0] bank1 [0:MEM_DEPTH-1];
    (* keep = "true" *) reg [7:0] bank2 [0:MEM_DEPTH-1];
    (* keep = "true" *) reg [7:0] bank3 [0:MEM_DEPTH-1];

    wire [31:0] word_idx    = addr[31:2];
    wire [1:0]  byte_offset = addr[1:0];

    // Initialize memory to zero
    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            bank0[i] = 8'h00;
            bank1[i] = 8'h00;
            bank2[i] = 8'h00;
            bank3[i] = 8'h00;
        end
    end

    // -------------------------------------------------------------------------
    // Synchronous Write Logic (Byte, Halfword, Word)
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (we && (word_idx < MEM_DEPTH)) begin
            case (funct3)
                `FUNCT3_SB: begin
                    case (byte_offset)
                        2'b00: bank0[word_idx] <= wdata[7:0];
                        2'b01: bank1[word_idx] <= wdata[7:0];
                        2'b10: bank2[word_idx] <= wdata[7:0];
                        2'b11: bank3[word_idx] <= wdata[7:0];
                    endcase
                end

                `FUNCT3_SH: begin
                    case (byte_offset[1])
                        1'b0: begin
                            bank0[word_idx] <= wdata[7:0];
                            bank1[word_idx] <= wdata[15:8];
                        end
                        1'b1: begin
                            bank2[word_idx] <= wdata[7:0];
                            bank3[word_idx] <= wdata[15:8];
                        end
                    endcase
                end

                `FUNCT3_SW: begin
                    bank0[word_idx] <= wdata[7:0];
                    bank1[word_idx] <= wdata[15:8];
                    bank2[word_idx] <= wdata[23:16];
                    bank3[word_idx] <= wdata[31:24];
                end

                default: begin
                    // No write operation
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Asynchronous Read Logic with Sign/Zero Extension (LB, LH, LW, LBU, LHU)
    // -------------------------------------------------------------------------
    wire [31:0] raw_word;
    assign raw_word = (word_idx < MEM_DEPTH) ? 
                      {bank3[word_idx], bank2[word_idx], bank1[word_idx], bank0[word_idx]} : 
                      32'h0000_0000;

    always @(*) begin
        case (funct3)
            `FUNCT3_LB: begin // Signed byte load
                case (byte_offset)
                    2'b00: rdata = {{24{raw_word[7]}},  raw_word[7:0]};
                    2'b01: rdata = {{24{raw_word[15]}}, raw_word[15:8]};
                    2'b10: rdata = {{24{raw_word[23]}}, raw_word[23:16]};
                    2'b11: rdata = {{24{raw_word[31]}}, raw_word[31:24]};
                endcase
            end

            `FUNCT3_LH: begin // Signed halfword load
                case (byte_offset[1])
                    1'b0: rdata = {{16{raw_word[15]}}, raw_word[15:0]};
                    1'b1: rdata = {{16{raw_word[31]}}, raw_word[31:16]};
                endcase
            end

            `FUNCT3_LW: begin // Word load
                rdata = raw_word;
            end

            `FUNCT3_LBU: begin // Unsigned byte load
                case (byte_offset)
                    2'b00: rdata = {24'h0000_00, raw_word[7:0]};
                    2'b01: rdata = {24'h0000_00, raw_word[15:8]};
                    2'b10: rdata = {24'h0000_00, raw_word[23:16]};
                    2'b11: rdata = {24'h0000_00, raw_word[31:24]};
                endcase
            end

            `FUNCT3_LHU: begin // Unsigned halfword load
                case (byte_offset[1])
                    1'b0: rdata = {16'h0000, raw_word[15:0]};
                    1'b1: rdata = {16'h0000, raw_word[31:16]};
                endcase
            end

            default: begin
                rdata = raw_word;
            end
        endcase
    end

endmodule
