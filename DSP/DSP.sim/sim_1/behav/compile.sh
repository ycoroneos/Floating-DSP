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
echo "xvlog -m64 --relax -prj fir_floatingtb_vlog.prj"
ExecStep $xv_path/bin/xvlog -m64 --relax -prj fir_floatingtb_vlog.prj 2>&1 | tee compile.log
