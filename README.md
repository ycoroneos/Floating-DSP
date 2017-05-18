# Floating-DSP
Floating Point Systolic FIR

This is the repo for the 6.337 final project of Yanni Coroneos and Corey Walsh.
We created two kinds of FIR filters, fixed point and floating point, and compared their error metrics.
Spoiler Alert : Floating Point is much better.

The final report is also in the top-level folder so go ahead and read it.

The DSP directory contains the Vivado project for the xc7a200t FPGA. We used a Nexys Video training board
and we also include RTL for interfacing the codec's i2s protocol 
from Stefan Kristiansson (https://github.com/skristiansson/i2s/tree/master/rtl/verilog).

Also inside the DSP folder is our simulation library and simulation test set. We have created a hodge-podge of useful
python utilities for signal processing and visualization. Speicifically interesting files are Convert.py, analyze.py,
generate_signals.py, and simulate.py
