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
ExecStep $xv_path/bin/xsim fir_floatingtb_behav -key {Behavioral:sim_1:Functional:fir_floatingtb} -tclbatch fir_floatingtb.tcl -view /home/corey/mit/6.337/yanni_code/finalproj/DSP/test_bench_tb_multiplier_behav.wcfg -log simulate.log
