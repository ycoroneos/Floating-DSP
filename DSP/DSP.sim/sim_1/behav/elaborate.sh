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
ExecStep $xv_path/bin/xelab -wto 9b562c261b20467093d14aa91dfb8cb9 -m64 --debug typical --relax --mt 8 -L float_lib -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot fir_floatingtb_behav xil_defaultlib.fir_floatingtb xil_defaultlib.glbl -log elaborate.log