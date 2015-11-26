if {![info exists dut]} {
    echo "variable \"dut\" not set!"
    exit
}
if {![info exists files_to_read]} { 
    echo "variable \"files_to_read\" not set!"
    exit
}

# Search paths 
set search_path                                                                                                           \
{                                                                                                                         \
    "*"                                                                                                                     \
    /home/ecelrc/students/csakhuja/hsca-multipliers/                                                                          \
    /usr/local/packages/synopsys_90nm_lib/SAED_EDK90nm/Digital_Standard_Cell_Library/                                     \
    /usr/local/packages/synopsys_90nm_lib/SAED_EDK90nm/Digital_Standard_Cell_Library/synopsys/models/                     \
}
set target_library                                                                                                        \
{                                                                                                                         \
    /usr/local/packages/synopsys_90nm_lib/SAED_EDK90nm/Digital_Standard_Cell_Library/synopsys/models/saed90nm_typ.db      \
}
set link_library                                                                                                          \
{                                                                                                                         \
    /usr/local/packages/synopsys_90nm_lib/SAED_EDK90nm/Digital_Standard_Cell_Library/synopsys/models/saed90nm_typ.db      \
}
set symbol_library                                                                                                                    \
{                                                                                                                                     \
    /usr/local/packages/synopsys_90nm_lib/SAED_EDK90nm/Digital_Standard_Cell_Library/synopsys/icons/saed90nm.sdb      \
}
set synthetic_library { }

# read in your files
analyze -define { I_WANT_TO_FUCKING_SYNTHESISE } -format sverilog $files_to_read

# elaborate the read in module of choice
elaborate "$dut" -architecture verilog -library WORK

# set the current module
current_design "$dut"

# link/check
link
check_design > check_design.pre_synth.rpt

# create 1ns clock. dixit is a faggot so we must create both of these and expect one to fail
create_clock clk_in -period 1 -name ideal_clock
create_clock w_clk_in -period 1 -name ideal_clock

# uniquify makes less effort. compile ultra is the timing-optimised synthesis begin command
uniquify
compile_ultra

# report worst case timing paths
report_timing -path full -max_paths 10 -significant_digits 3 -sort_by group > timing.dc.rpt
report_area > area.dc.rpt
report_power > power.dc.rpt

# design check after
check_design > check_design.post_synth.rpt

# timing for IC Compiler
set sdc ".sdc"
write_sdc "$dut$sdc"

# write the netlist
set post_synth ".post_synth.v"
write -hierarchy -format verilog -output "$dut$post_synth"

# exit 
exit
