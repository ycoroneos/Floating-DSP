#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2017.1"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim fir_floating_file_tb_behav -key {Behavioral:sim_1:Functional:fir_floating_file_tb} -tclbatch fir_floating_file_tb.tcl -view /home/yanni/18.335/finalproj/DSP/test_bench_tb_multiplier_behav.wcfg -log simulate.log
