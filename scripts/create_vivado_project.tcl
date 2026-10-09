# ==============================================================================
# AMD Xilinx Vivado Tcl Script: Create Single-Cycle RV32I Processor Project
# Target Device: Artix-7 XC7A35T-1CPG236C (Digilent Basys 3)
# Author: Anirudh Chaturvedi
# ==============================================================================

set base_dir "C:/temp/RV32I_Single_Cycle_Core"
set proj_name "rv32i_single_cycle"
set proj_dir  "$base_dir/vivado_project"
set rtl_dir   "$base_dir/rtl"
set tb_dir    "$base_dir/testbench"

# Target part: Digilent Basys 3 FPGA
set target_part "xc7a35tcpg236-1"

puts "=================================================================="
puts " Creating Vivado Project: $proj_name at $proj_dir"
puts " Target FPGA: $target_part"
puts "=================================================================="

# Create project directory
file mkdir $proj_dir
create_project -force $proj_name $proj_dir -part $target_part

# Configure project properties
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property default_lib work [current_project]

# Add RTL source files
add_files -norecurse [glob -nocomplain "$rtl_dir/*.v"]
set_property include_dirs $rtl_dir [current_fileset]

# Add Simulation Testbench files
add_files -fileset sim_1 -norecurse [glob -nocomplain "$tb_dir/*.v"]
set_property include_dirs $rtl_dir [get_filesets sim_1]

# Set top module
set_property top alu [current_fileset]
set_property top tb_alu [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "=================================================================="
puts " Project successfully generated! Ready for Synthesis & Simulation"
puts "=================================================================="
