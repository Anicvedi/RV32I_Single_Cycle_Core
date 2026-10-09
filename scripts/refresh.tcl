# ==============================================================================
# AMD Xilinx Vivado Live Sync Script: Refresh Project from Disk
# Target: Single-Cycle RV32I Processor
# ==============================================================================

set base_dir "C:/temp/RV32I_Single_Cycle_Core"
set rtl_dir "$base_dir/rtl"
set tb_dir  "$base_dir/testbench"
set cstr_dir "$base_dir/constraints"

puts "=================================================================="
puts " [Vivado Live Sync] Scanning workspace for new and updated files..."
puts "=================================================================="

# Add any new or updated RTL files
add_files -norecurse [glob -nocomplain "$rtl_dir/*.v"]
set_property include_dirs $rtl_dir [current_fileset]

# Add any new or updated simulation testbenches & hex programs
add_files -fileset sim_1 -norecurse [glob -nocomplain "$tb_dir/*.v"]
if {[file exists "$tb_dir/program_fib.hex"]} {
    add_files -fileset sim_1 -norecurse "$tb_dir/program_fib.hex"
}
set_property include_dirs $rtl_dir [get_filesets sim_1]

# Add any constraints
add_files -fileset constrs_1 -norecurse [glob -nocomplain "$cstr_dir/*.xdc"]

# Set top modules
set_property top rv32i_core [current_fileset]
set_property top tb_rv32i_core [get_filesets sim_1]

# Re-evaluate hierarchy and compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "=================================================================="
puts " [Vivado Live Sync] Complete! Hierarchy refreshed cleanly."
puts "=================================================================="
