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
ExecStep $xv_path/bin/xsim firtb_behav -key {Behavioral:sim_1:Functional:firtb} -tclbatch firtb.tcl -log simulate.log
