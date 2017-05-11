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
ExecStep $xv_path/bin/xsim OGTestBench_behav -key {Behavioral:sim_1:Functional:OGTestBench} -tclbatch OGTestBench.tcl -view /home/corey/mit/6.337/yanni_code/finalproj/DSP/test_bench_tb_multiplier_behav.wcfg -log simulate.log
