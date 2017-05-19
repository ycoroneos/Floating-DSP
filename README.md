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
python utilities for signal processing and visualization. Specifically interesting files are Convert.py, analyze.py,
generate_signals.py, and simulate.py

## How to Run / Verify
Fortunately, our testing framework is entirely scripted and automatic.
Unfortunately, you must have Vivado 2017.1 or newer installed.

Step 1. Install Vivado 2017.1 or newer from Xilinx. Older versions might
work but no guarantees.

Step 2. Navigate to the DSP/simulation folder

Step 3. To run a simulation of the fixed point and floating point
filters, you must use simulate.py. Here is an example command for
running a low pass blackman filter on a Chirp signal:

./simulate.py 150Hz_lpf_277tap_blackman.coeffs chirp_extended.signal ./tests/test --notes="blackman 150hz 277 taps lpf, chirp 20-20000hz"

Step 4. To verify the RTL, open DSP.xpr with Vivado and poke around.
XSim is a great utility for observing the systolic FIR pipeline. An
alternative way to verify the RTL (when Vivado is not available) is to aggregate every single verilog
file in the subtree and perform a reachability analysis starting from
"toplevel.v"
