# ==============================================================================
# AMD Xilinx Artix-7 Timing Constraints: Single-Cycle RV32I Core
# Target Part: XC7A35T-1CPG236C (Digilent Basys 3)
# ==============================================================================

# Target 50 MHz system clock (Period = 20.0 ns)
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]
