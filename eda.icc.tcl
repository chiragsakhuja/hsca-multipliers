set lib_path "/usr/local/packages/synopsys_90nm_lib/SAED_EDK90nm"
if {![info exists dut]} {
    set dut "kraken"
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

# set the design name
set design_name $dut

# set the filename for the sdc file
set sdc ".sdc"
set sdc_fn "./output/$dut$sdc"

# set the filename for the post synthesis netlist
set post_synth ".post_synth.v"
set post_synth_fn "./output/$dut$post_synth"

# create the lib
create_mw_lib -tech "${lib_path}/Technology_Kit/techfile/saed90nm_icc_1p9m.tf" -mw_reference_library {"/usr/local/packages/synopsys_90nm_lib/SAED_EDK90nm/Digital_Standard_Cell_Library/process/astro/fram/saed90nm_fr" "/usr/local/packages/synopsys_90nm_lib/SAED_EDK90nm/Memories/process/astro/saed_sram_fr"} ${dut}_LIB

# open the lib you just made
open_mw_lib ${dut}_LIB

# set ?
set_tlu_plus_files \
    -max_tluplus "${lib_path}/Technology_Kit/rules/starrcxt/tluplus/saed90nm_1p9m_1t_Cmax.tluplus" \
    -min_tluplus "${lib_path}/Technology_Kit/rules/starrcxt/tluplus/saed90nm_1p9m_1t_Cmin.tluplus" \
    -tech2itf_map "${lib_path}/Technology_Kit/rules/starrcxt/tech2itf.map" 

# read in your netlist
import_design "${post_synth_fn}" -format "verilog" -top ${dut} -cell ${dut}

# read in the sdc
read_sdc ${sdc_fn}

# floorplan to A0 size
derive_pg_connection -power_net {vdd!} -ground_net {gnd!}

# place all hard macros and leaf cells
create_fp_placement -timing_driven -no_hierarchy_gravity

# hard paste all macro cells
set_dont_touch_placement [all_macro_cells]

# make a floorplan
create_floorplan -control_type "aspect_ratio" -core_aspect_ratio 0.707318 -core_utilization "0.4"

# place
place_opt -effort high
preroute_standard_cells -nets {vdd! gnd!} -connect horizontal -extend_to_boundaries_and_generate_pins

# optimise clocks
clock_opt -fix_hold_all_clocks -no_clock_route
route_zrt_group -all_clock_nets -reuse_existing_global_route true

# route
route_opt -effort high

# route again
route_opt -incremental

# reports
report_timing -path full -max_paths 10 -significant_digits 8 -sort_by group > timing.icc.rpt
report_area -hierarchy > area.icc.rpt
report_power > power.icc.rpt
report_qor -significant_digits 8 > qor.icc.rpt

# design check
check_design > check_design.post_pnr.rpt

# dump important files
set post_pnr ".post_pnr.v"
set post_pnr_fn "./output/$dut$post_pnr"
write_verilog $post_pnr_fn
write_sdc $post_pnr_fn
write_parasitics -format SBPF -o $post_pnr_fn
write_stream $post_pnr_fn

# start the gui
gui_start

# close out everything
# close_mw_cel
# exit
