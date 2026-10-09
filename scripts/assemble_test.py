# Bare-metal test program assembler for RV32I verification

def r_type(funct7, rs2, rs1, funct3, rd, opcode):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def i_type(imm, rs1, funct3, rd, opcode):
    imm = imm & 0xFFF
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def s_type(imm, rs2, rs1, funct3, opcode):
    imm = imm & 0xFFF
    imm_11_5 = (imm >> 5) & 0x7F
    imm_4_0  = imm & 0x1F
    return (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode

def b_type(imm, rs2, rs1, funct3, opcode):
    imm = imm & 0x1FFF # 13-bit signed (-4096 to 4094, multiple of 2)
    b12   = (imm >> 12) & 0x1
    b10_5 = (imm >> 5)  & 0x3F
    b4_1  = (imm >> 1)  & 0xF
    b11   = (imm >> 11) & 0x1
    return (b12 << 31) | (b10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (b4_1 << 8) | (b11 << 7) | opcode

def u_type(imm20, rd, opcode):
    return ((imm20 & 0xFFFFF) << 12) | (rd << 7) | opcode

def j_type(imm, rd, opcode):
    imm = imm & 0x1FFFFF # 21-bit signed
    j20    = (imm >> 20) & 0x1
    j10_1  = (imm >> 1)  & 0x3FF
    j11    = (imm >> 11) & 0x1
    j19_12 = (imm >> 12) & 0xFF
    return (j20 << 31) | (j10_1 << 21) | (j11 << 20) | (j19_12 << 12) | (rd << 7) | opcode

# Instructions
# Test Program:
# 1. Initialize x1 = 0, x2 = 1, x3 = 10 (loop counter for Fibonacci)
# 2. Loop:
#    x4 = x1 + x2 (next fib)
#    x1 = x2
#    x2 = x4
#    x3 = x3 - 1 (addi x3, x3, -1)
#    bne x3, x0, Loop (-16 bytes)
# 3. Memory Test:
#    sw x2, 16(x0)      # Store Fib(10)=55 at dmem[16]
#    lw x10, 16(x0)     # Load back into x10 (a0)
# 4. Function Call Test via JAL / JALR:
#    jal x1, func       # Call func, return addr in x1
#    beq x0, x0, halt   # Finished
# func:
#    addi x10, x10, 5   # x10 = 55 + 5 = 60
#    jalr x0, 0(x1)     # return to caller
# halt:
#    beq x0, x0, halt   # infinite halt loop

prog = []
labels = {}

# We'll assemble manually:
# Addr 0x00: addi x1, x0, 0      (0x00000093)
# Addr 0x04: addi x2, x0, 1      (0x00100113)
# Addr 0x08: addi x3, x0, 9      (0x00900193)  -- 9 iterations to get F_10 = 55
# Loop (Addr 0x0C):
# Addr 0x0C: add  x4, x1, x2     (0x00208233)
# Addr 0x10: addi x1, x2, 0      (0x00010093)
# Addr 0x14: addi x2, x4, 0      (0x00020113)
# Addr 0x18: addi x3, x3, -1     (0xfff18193)
# Addr 0x1C: bne  x3, x0, -16    (offset -16 bytes from 0x1C to 0x0C)
# After Loop (Addr 0x20):
# Addr 0x20: sw   x2, 16(x0)     (0x00202823)  store 55 at dmem[16]
# Addr 0x24: lw   x10, 16(x0)    (0x01002503)  load 55 into x10
# Addr 0x28: jal  x1, 12         (offset +12 bytes from 0x28 to 0x34)
# Addr 0x2C: halt: beq  x0, x0, 0 (0x00000063) infinite loop
# Addr 0x30: nop                 (0x00000013)
# Subroutine (Addr 0x34):
# Addr 0x34: addi x10, x10, 5    (0x00550513)  x10 = 55 + 5 = 60 (0x3C)
# Addr 0x38: jalr x0, 0(x1)      (0x00008067)  return to 0x2C (halt)

instructions = [
    (0x00, i_type(0, 0, 0, 1, 0x13), "addi x1, x0, 0"),
    (0x04, i_type(1, 0, 0, 2, 0x13), "addi x2, x0, 1"),
    (0x08, i_type(9, 0, 0, 3, 0x13), "addi x3, x0, 9"),
    (0x0C, r_type(0, 2, 1, 0, 4, 0x33), "add x4, x1, x2"),
    (0x10, i_type(0, 2, 0, 1, 0x13), "addi x1, x2, 0"),
    (0x14, i_type(0, 4, 0, 2, 0x13), "addi x2, x4, 0"),
    (0x18, i_type(-1, 3, 0, 3, 0x13), "addi x3, x3, -1"),
    (0x1C, b_type(-16, 0, 3, 1, 0x63), "bne x3, x0, -16"), # bne: funct3=001
    (0x20, s_type(16, 2, 0, 2, 0x23), "sw x2, 16(x0)"),
    (0x24, i_type(16, 0, 2, 10, 0x03), "lw x10, 16(x0)"),
    (0x28, j_type(12, 1, 0x6F), "jal x1, +12"),
    (0x2C, b_type(0, 0, 0, 0, 0x63), "halt: beq x0, x0, 0"),
    (0x30, 0x00000013, "nop"),
    (0x34, i_type(5, 10, 0, 10, 0x13), "addi x10, x10, 5"),
    (0x38, i_type(0, 1, 0, 0, 0x67), "jalr x0, 0(x1)")
]

with open("C:/temp/RV32I_Single_Cycle_Core/testbench/program_fib.hex", "w") as f:
    for addr, hex_val, asm in instructions:
        f.write(f"{hex_val:08x}\n")
        print(f"0x{addr:02x}: {hex_val:08x} // {asm}")
