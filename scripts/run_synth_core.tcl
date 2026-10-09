# ==============================================================================
# AMD Xilinx Vivado Tcl Script: Non-Project Mode Synthesis for RV32I Full Core
# Target Device: Artix-7 XC7A35T-1CPG236C (Digilent Basys 3)
# Author: Anirudh Chaturvedi (DESE, IISc Bangalore)
# ==============================================================================

set target_part "xc7a35tcpg236-1"
set top_module  "rv32i_core"
set base_dir    "C:/temp/RV32I_Single_Cycle_Core"
set rtl_dir     "$base_dir/rtl"
set constr_file "$base_dir/constraints/core_timing.xdc"
set reports_dir "$base_dir/reports"

file mkdir $reports_dir

puts "=================================================================="
puts " Starting Vivado Synthesis for RV32I Full Core ($top_module)"
puts " Target FPGA: $target_part"
puts "=================================================================="

# 1. Read RTL source files
read_verilog [glob "$rtl_dir/*.v"]
set_property include_dirs $rtl_dir [current_fileset]

# 2. Read Timing Constraints
if {[file exists $constr_file]} {
    read_xdc $constr_file
}

# 3. Synthesize Design with actual hex workload to preserve complete datapath
synth_design -top $top_module -part $target_part -mode out_of_context -generic MEM_INIT_FILE="testbench/program_fib.hex"

# 4. Generate Reports
report_utilization -file "$reports_dir/core_utilization.rpt" -pb "$reports_dir/core_utilization.pb"
report_timing_summary -delay_type min_max -max_paths 10 -file "$reports_dir/core_timing.rpt"
report_power -file "$reports_dir/core_power.rpt"

puts "=================================================================="
puts " Core Synthesis Completed! Reports generated in $reports_dir"
puts "=================================================================="
