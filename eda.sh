#! /usr/bin/env bash

# validate arguments
if [ "$#" -ne 2 ]; then
    echo "usage: eda <dut name> <master file>"
    exit
fi

if [ ! -f $2 ]; then
    echo "master file \"$2\" does not exist!"
    exit
fi

# get hsca dir
hsca_dir=$(dirname $2)

# get filenames
files_to_read=""
for i in $(cat $2) ; do files_to_read="$files_to_read $hsca_dir/$i" ; done;

# make a dir
mkdir -p $1/output

# goto it 
pushd . > /dev/null
cd $1

# invoke dc_shell
dc_shell -f /home/ecelrc/students/csakhuja/eda/eda.dc.tcl -x "set dut $1; set files_to_read {$files_to_read};" 2>&1 | tee $1.dc.log

# copy over cool stuff
mv timing.dc.rpt output/
mv area.dc.rpt output/
mv power.dc.rpt output/
mv check_design.pre_synth.rpt output/
mv check_design.post_synth.rpt output/
mv $1.sdc output/
mv $1.post_synth.v output/
mv $1.dc.log output/

# run icc
icc_shell -f /home/ecelrc/students/csakhuja/eda/eda.icc.tcl -x "set dut $1;" 2>&1 | tee $1.icc.log

# copy over more cool stuff
mv $1.icc.log output/
mv timing.icc.rpt output/
mv area.icc.rpt output/
mv power.icc.rpt output/
mv qor.icc.rpt output/
mv check_design.post_pnr.rpt output/

# return
popd > /dev/null
