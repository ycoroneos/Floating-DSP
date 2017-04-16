#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2016.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim i2c_tb_behav -key {Behavioral:sim_1:Functional:i2c_tb} -tclbatch i2c_tb.tcl -log simulate.log
