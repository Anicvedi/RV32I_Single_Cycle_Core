# ==============================================================================
# AMD Xilinx Vivado Tcl Script: Synthesize Module 1 (32-bit ALU)
# Target Device: Artix-7 XC7A35T-1CPG236C (Digilent Basys 3)
# Non-Project High-Performance In-Memory Synthesis Flow
# ==============================================================================

set base_dir "C:/temp/RV32I_Single_Cycle_Core"
set reports_dir "$base_dir/reports"
file mkdir $reports_dir

puts "=================================================================="
puts " Loading RTL Sources into Vivado ..."
puts "=================================================================="
read_verilog "$base_dir/rtl/rv32i_defines.v"
read_verilog "$base_dir/rtl/alu.v"

puts "=================================================================="
puts " Synthesizing ALU targeting Artix-7 (xc7a35tcpg236-1) ..."
puts "=================================================================="
synth_design -top alu -part xc7a35tcpg236-1 -flatten_hierarchy rebuilt

puts "=================================================================="
puts " Applying Timing Constraints & Running Static Timing Analysis ..."
puts "=================================================================="
create_clock -name vclk -period 10.000
set_input_delay -clock vclk 0.000 [get_ports {a b alu_op}]
set_output_delay -clock vclk 0.000 [get_ports {result zero}]

puts "=================================================================="
puts " Generating PPA Reports ..."
puts "=================================================================="
report_utilization -file "$reports_dir/alu_utilization.rpt"
report_timing_summary -file "$reports_dir/alu_timing.rpt" -max_paths 10
report_power -file "$reports_dir/alu_power.rpt"

# Save synthesis checkpoint for GUI viewing
write_checkpoint -force "$base_dir/vivado_project/alu_synth.dcp"

puts "=================================================================="
puts " Synthesis Complete! Checkpoint saved: vivado_project/alu_synth.dcp"
puts " Reports saved to: $reports_dir"
puts "=================================================================="
