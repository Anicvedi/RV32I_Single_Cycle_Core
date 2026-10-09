# ==============================================================================
# AMD Xilinx Vivado Tcl Script: Create Single-Cycle RV32I Processor Project
# Target Device: Artix-7 XC7A35T-1CPG236C (Digilent Basys 3)
# ==============================================================================

set base_dir "C:/temp/RV32I_Single_Cycle_Core"
set proj_name "RV32I_Single_Cycle_Core"
set proj_dir  "$base_dir/vivado"
set rtl_dir   "$base_dir/rtl"
set tb_dir    "$base_dir/testbench"
set constr_dir "$base_dir/constraints"

set target_part "xc7a35tcpg236-1"

puts "=================================================================="
puts " Creating Vivado Project: $proj_name at $proj_dir"
puts " Target FPGA: $target_part"
puts "=================================================================="

create_project -force $proj_name $proj_dir -part $target_part

set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property default_lib work [current_project]

# Add RTL source files
add_files -norecurse [glob -nocomplain "$rtl_dir/*.v"]
set_property include_dirs $rtl_dir [current_fileset]

# Add Simulation Testbench files & hex memory initialization
add_files -fileset sim_1 -norecurse [glob -nocomplain "$tb_dir/*.v"]
if {[file exists "$tb_dir/program_fib.hex"]} {
    add_files -fileset sim_1 -norecurse "$tb_dir/program_fib.hex"
}
set_property include_dirs $rtl_dir [get_filesets sim_1]

# Add Constraints
add_files -fileset constrs_1 -norecurse [glob -nocomplain "$constr_dir/*.xdc"]

# Set Top Modules
set_property top rv32i_core [current_fileset]
set_property top tb_rv32i_core [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "=================================================================="
puts " Project successfully generated: $proj_dir/$proj_name.xpr"
puts " Top RTL Module   : rv32i_core"
puts " Top Sim Testbench: tb_rv32i_core"
puts "=================================================================="
close_project
