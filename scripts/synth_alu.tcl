# ==============================================================================
# AMD Xilinx Vivado Tcl Script: Synthesize Module 1 (32-bit ALU)
# Target Device: Artix-7 XC7A35T-1CPG236C (Digilent Basys 3)
# Author: Anirudh Chaturvedi
# ==============================================================================

set base_dir "C:/temp/RV32I_Single_Cycle_Core"
set proj_file "$base_dir/vivado_project/rv32i_single_cycle.xpr"
set reports_dir "$base_dir/reports"

file mkdir $reports_dir

puts "=================================================================="
puts " Opening Vivado Project: $proj_file"
puts "=================================================================="
open_project $proj_file

# Set synthesis top to ALU
set_property top alu [current_fileset]
update_compile_order -fileset sources_1

# Create timing constraints file for standalone ALU analysis
set xdc_file "$base_dir/constraints/alu_timing.xdc"
file mkdir "$base_dir/constraints"
set fp [open $xdc_file w]
puts $fp "# Virtual clock for purely combinational ALU timing analysis (100 MHz target, 10 ns period)"
puts $fp "create_clock -name vclk -period 10.000"
puts $fp "set_input_delay -clock vclk 0.000 [get_ports {a b alu_op}]"
puts $fp "set_output_delay -clock vclk 0.000 [get_ports {result zero}]"
close $fp

if {[get_filesets -quiet constrs_1] == ""} {
    create_fileset -constrset constrs_1
}
add_files -fileset constrs_1 -norecurse $xdc_file

puts "=================================================================="
puts " Launching Synthesis for Module 1 (ALU) ..."
puts "=================================================================="
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check synthesis status
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: Synthesis failed!"
    exit 1
}

puts "=================================================================="
puts " Synthesis Complete! Generating PPA Reports ..."
puts "=================================================================="
open_run synth_1

report_utilization -file "$reports_dir/alu_utilization.rpt"
report_timing_summary -file "$reports_dir/alu_timing.rpt"
report_power -file "$reports_dir/alu_power.rpt"

puts "=================================================================="
puts " Reports generated in $reports_dir:"
puts " - alu_utilization.rpt"
puts " - alu_timing.rpt"
puts " - alu_power.rpt"
puts "=================================================================="
