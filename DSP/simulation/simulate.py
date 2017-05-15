#!/usr/bin/env python

import numpy as np
import struct, os
import argparse
import re, string
from argparse import RawTextHelpFormatter

parser = argparse.ArgumentParser(
	formatter_class=RawTextHelpFormatter,
	description='')

parser.add_argument('coeffs', metavar='COEFFS', type=str, help='File to find coefficients in float format from [1.0,-1.0]')
parser.add_argument('signal', metavar='SIGNAL', type=str, help='File to find signal in float format from [1.0,-1.0]')
parser.add_argument('output', metavar='OUTPUT', type=str, help='Name of the output folder')
parser.add_argument('--notes', metavar='NOTES', type=str, default="", help='Optional notes')
parser.add_argument('--which', metavar='WHICH', type=str, default="", help='Which number simulation to use, optional, use if multiple instances at same time')
parser.add_argument('--dry', dest='dry', action='store_true', help="Dry run, no simulation")
parser.set_defaults(dry=False)


def pad_signal(signal, num_coeffs):
	return np.concatenate(([0], signal, np.zeros(num_coeffs*2)))

CONV = "../../convert.py "

SIGNAL_IN_FLOAT = "./float_simulation{0}/xsim/chirp_float_binary.mem"
COEFF_IN_FLOAT = "./float_simulation{0}/xsim/float_coeffs.list"
SIGNAL_IN_FIXED = "./fixed_simulation{0}/xsim/chirp_fixed_binary.mem"
COEFF_IN_FIXED = "./fixed_simulation{0}/xsim/coeff.list"

SIGNAL_OUT_FLOAT = "./float_simulation{0}/xsim/float_output.mem"
SIGNAL_OUT_FIXED = "./fixed_simulation{0}/xsim/fixed_output.mem"

FLOAT_SIMULATE = "cd ./float_simulation{0}/xsim/ && ./fir_floating_file_tb.sh && cd ../../"
FIXED_SIMULATE = "cd ./fixed_simulation{0}/xsim/ && ./fir_fixed_file_tb.sh && cd ../../"

def do(cmd):
	os.system(cmd)

CLIP_METHOD = 1
SMALLER_SCALE_METHOD = 2

SCALE_METHOD = CLIP_METHOD
# SCALE_METHOD = SMALLER_SCALE_METHOD

def line_prepender(filename, line):
	with open(filename, 'r+') as f:
		content = f.read()
		f.seek(0, 0)
		f.write(line.rstrip('\r\n') + '\n' + content)

def strip_last_line(filename):
	with open(filename, 'r+') as f:
		content = f.read()
		f.seek(0, 0)
		f.write(line.rstrip('\r\n') + '\n' + content)

def float_to_scaled_int(arr, copy=True):
	if copy:
		unscaled = np.copy(arr)
	else:
		unscaled = arr

	if SCALE_METHOD == CLIP_METHOD:
		unscaled *= 2**23
		unscaled = np.round(unscaled)
		unscaled = np.clip(unscaled, -2**23, 2**23-1)
	elif SCALE_METHOD == SMALLER_SCALE_METHOD:
		unscaled *= 2**22
		unscaled = np.round(unscaled)

	return unscaled.astype(np.int64)

def unscale(arr):
	unscaled = None
	if SCALE_METHOD == CLIP_METHOD:
		unscaled = arr >> 23
	elif SCALE_METHOD == SMALLER_SCALE_METHOD:
		unscaled = arr >> 22
	return unscaled

def normalize(arr):
	arr = arr.astype(np.float64)
	if SCALE_METHOD == CLIP_METHOD:
		arr /= 2**23
	elif SCALE_METHOD == SMALLER_SCALE_METHOD:
		arr /= 2**22
	return arr

def convolve(coeffs, signal):
	return np.convolve(coeffs, signal, mode="full")

def convolve(coeffs, signal, dtype=np.float64):
	return np.convolve(coeffs.astype(dtype), signal.astype(dtype), mode="full").astype(dtype)

TAPS = 107
TAPS = 277

def simulate(coefficients, signal, output_name, notes="", dry=False):
	print "Simulating..."
	print "...signal length:", len(signal) 
	print "...coefficient length:", len(coefficients)
	print "...output folder name:", output_name
	print "---------------------------------------------------"
	print "---------------------------------------------------"

	global SIGNAL_IN_FLOAT, COEFF_IN_FLOAT, SIGNAL_IN_FIXED, COEFF_IN_FIXED, SIGNAL_OUT_FLOAT, SIGNAL_OUT_FIXED, FLOAT_SIMULATE, FIXED_SIMULATE

	SIGNAL_IN_FLOAT = SIGNAL_IN_FLOAT.format(args.which)
	COEFF_IN_FLOAT = COEFF_IN_FLOAT.format(args.which)
	SIGNAL_IN_FIXED = SIGNAL_IN_FIXED.format(args.which)
	COEFF_IN_FIXED = COEFF_IN_FIXED.format(args.which)
	SIGNAL_OUT_FLOAT = SIGNAL_OUT_FLOAT.format(args.which)
	SIGNAL_OUT_FIXED = SIGNAL_OUT_FIXED.format(args.which)
	FLOAT_SIMULATE = FLOAT_SIMULATE.format(args.which)
	FIXED_SIMULATE = FIXED_SIMULATE.format(args.which)

	print SIGNAL_IN_FLOAT
	print COEFF_IN_FLOAT
	print SIGNAL_IN_FIXED
	print COEFF_IN_FIXED
	print SIGNAL_OUT_FLOAT
	print SIGNAL_OUT_FIXED
	print FLOAT_SIMULATE
	print FIXED_SIMULATE

	# exit()
	
	# check if file exists, if not make it, fail if it is already a file
	if os.path.isfile(output_name):
		print "Output path is a file, failing..."
		return
	elif not os.path.isdir(output_name):
		os.mkdir(output_name)

	if not notes == "":
		with open("{0}/notes.txt".format(output_name), "w") as text_file:
			text_file.write(notes.decode('string_escape'))

	# do the ideal convolution with 64 bits
	ideal = convolve(coefficients, signal)
	ideal = np.concatenate((np.zeros(TAPS), ideal, np.zeros(1)))
	np.savetxt(output_name + "/output_ideal.list", ideal, fmt="%.20f")

	# do the same thing the FIR filter is expected to do
	ideal = convolve(coefficients, signal, dtype=np.float32)
	ideal = np.concatenate((np.zeros(TAPS), ideal, np.zeros(1)))
	np.savetxt(output_name + "/output_ideal32.list", ideal, fmt="%.20f")

	signal = pad_signal(signal, len(coefficients))

	# make copies of the source signal
	np.savetxt(output_name + "/signal.list", signal, fmt="%.14f")
	np.savetxt(output_name + "/coeff.list", coefficients, fmt="%.20f")

	# convert the float representation to binary
	do(CONV+"{0}/signal.list {0}/signal_float_bin.list --in_format=f --out_format=b".format(output_name))
	do(CONV+"{0}/coeff.list {0}/coeff_float_bin.list --in_format=f --out_format=b".format(output_name))

	# convert float values to integers for fixed point and save
	scaled_coeffs = float_to_scaled_int(coeffs)
	scaled_signal = float_to_scaled_int(signal)

	np.savetxt(output_name + "/signal_fixed_int.list", scaled_signal, fmt="%d")
	np.savetxt(output_name + "/coeff_fixed_int.list", scaled_coeffs, fmt="%d")

	# convert the ints to 50 bit twos complement binary
	do(CONV+"{0}/signal_fixed_int.list {0}/signal_fixed_bin.list --in_format=d --out_format=b --noconv --2c --bitness=50".format(output_name))
	do(CONV+"{0}/coeff_fixed_int.list {0}/coeff_fixed_bin.list --in_format=d --out_format=b --noconv --2c --bitness=50".format(output_name))

	# copy the files necessary for simulation
	do("cp {0}/signal_float_bin.list {1}".format(output_name, SIGNAL_IN_FLOAT))
	do("cp {0}/coeff_float_bin.list {1}".format(output_name, COEFF_IN_FLOAT))
	do("cp {0}/signal_fixed_bin.list {1}".format(output_name, SIGNAL_IN_FIXED))
	do("cp {0}/coeff_fixed_bin.list {1}".format(output_name, COEFF_IN_FIXED))

	if not dry:
		# do the simulations
		print "Doing fixed point simulation..."
		do(FIXED_SIMULATE)
		print "Doing floating point simulation..."
		do(FLOAT_SIMULATE)

	# copy out the results
	do("cp {0} {1}/output_float_bin.list".format(SIGNAL_OUT_FLOAT, output_name))
	do("cp {0} {1}/output_fixed_bin.list".format(SIGNAL_OUT_FIXED, output_name))

	# phase shift the float point result backwards one sample to phase align the signals
	line_prepender(output_name+"/output_float_bin.list", "0"*32)
	do("head -n-1 {0}/output_float_bin.list > {0}/tmp.list && mv {0}/tmp.list {0}/output_float_bin.list".format(output_name))

	# convert the results to more readable format
	do(CONV+"{0}/output_fixed_bin.list {0}/output_fixed_int.list --in_format=b --out_format=d --noconv --bitness=50 --2c".format(output_name))
	do(CONV+"{0}/output_float_bin.list {0}/output_float_dec.list --in_format=b --out_format=f --ftoi".format(output_name))
	do(CONV+"{0}/output_float_bin.list {0}/output_float_24bit.list --in_format=b --out_format=f --ftoi --with_rounding".format(output_name))
	do(CONV+"{0}/output_float_bin.list {0}/output_float_24bit_dither.list --in_format=b --out_format=f --ftoi --with_rounding --dither".format(output_name))

	# remove the scaling factor of the coefficients
	scaled_signal = np.loadtxt("{0}/output_fixed_int.list".format(output_name), dtype=np.int64)
	unscaled_signal = unscale(scaled_signal)
	np.savetxt(output_name + "/output_fixed_unscaled.list", unscaled_signal, fmt="%d")

	# convert the fixed point to the range [-1,1]
	normalized_signal = normalize(unscaled_signal)
	np.savetxt(output_name + "/output_fixed_normalized.list", normalized_signal, fmt="%.14f")

	print "DONE"

if __name__ == '__main__':
	args = parser.parse_args()

	coeffs = np.loadtxt(args.coeffs, dtype=np.float64)
	signal = np.loadtxt(args.signal, dtype=np.float64)

	if len(signal.shape) == 0:
		signal = np.array([signal], dtype=np.float64)

	simulate(coeffs, signal, args.output, notes=args.notes, dry=args.dry)