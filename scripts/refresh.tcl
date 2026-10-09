# ==============================================================================
# AMD Xilinx Vivado Live Sync Script: Refresh Project from Disk
# Target: Reset to ALU and Step Right After ALU (Immediate Generator)
# ==============================================================================

set base_dir "C:/temp/RV32I_Single_Cycle_Core"
set rtl_dir  "$base_dir/rtl"
set tb_dir   "$base_dir/testbench"
set cstr_dir "$base_dir/constraints"

puts "=================================================================="
puts " [Vivado Sync] Removing deleted modules and syncing sources..."
puts "=================================================================="

# Remove any files in project that no longer exist on disk
foreach f [get_files] {
    if {![file exists $f]} {
        puts " Removing deleted file from project: [file tail $f]"
        remove_files $f
    }
}

# Add active RTL files
add_files -norecurse [glob -nocomplain "$rtl_dir/*.v"]
set_property include_dirs $rtl_dir [current_fileset]

# Add active Testbench files
add_files -fileset sim_1 -norecurse [glob -nocomplain "$tb_dir/*.v"]
set_property include_dirs $rtl_dir [get_filesets sim_1]

# Add constraints if present
add_files -fileset constrs_1 -norecurse [glob -nocomplain "$cstr_dir/*.xdc"]

# Set Top to ALU (or imm_gen)
set_property top alu [current_fileset]
set_property top tb_alu [get_filesets sim_1]

# Update hierarchy and compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "=================================================================="
puts " [Vivado Sync] Project cleanly reset! Top module is now 'alu'."
puts "=================================================================="
