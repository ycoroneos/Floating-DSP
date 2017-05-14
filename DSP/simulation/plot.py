#!/usr/bin/env python

import numpy as np
import struct, os
import argparse
import re, string
import matplotlib.pyplot as plt
from argparse import RawTextHelpFormatter
import scipy
import scipy.signal
# from simulate import SIGNAL_IN_FLOAT, COEFF_IN_FLOAT, SIGNAL_IN_FIXED, COEFF_IN_FIXED, SIGNAL_OUT_FLOAT, SIGNAL_OUT_FIXED

parser = argparse.ArgumentParser(
	formatter_class=RawTextHelpFormatter,
	description='')

# SIGNAL_IN_FLOAT = "./float_simulation/xsim/chirp_float_binary.mem"
# COEFF_IN_FLOAT = "./float_simulation/xsim/float_coeffs.list"
# SIGNAL_IN_FIXED = "./fixed_simulation/xsim/chirp_fixed_binary.mem"
# COEFF_IN_FIXED = "./fixed_simulation/xsim/coeff.list"
# SIGNAL_OUT_FLOAT = "./float_simulation/xsim/float_output.mem"
# SIGNAL_OUT_FIXED = "./fixed_simulation/xsim/fixed_output.mem"



SIGNAL = "/signal.list"
COEFFS = "/coeff.list"
FLOAT = "/output_float_dec.list"
FIXED = "/output_fixed_normalized.list"
IDEAL = "/output_ideal.list"
IDEAL = "/output_ideal32.list"

parser.add_argument('test', metavar='TEST', type=str, help='Directory containing the test bench output')
parser.add_argument('--signal', dest='signal', action='store_true', help="Show the signal")
parser.add_argument('--fixed', dest='fixed', action='store_true', help="Show the fixed output")
parser.add_argument('--float', dest='float', action='store_true', help="Show the float output")
parser.add_argument('--diff1', dest='diff1', action='store_true', help="Show the difference between fixed and float output")
parser.add_argument('--diff2', dest='diff2', action='store_true', help="Show the difference between ideal and float output")
parser.add_argument('--diff3', dest='diff3', action='store_true', help="Show the difference between ideal and fixed output")
parser.add_argument('--ideal', dest='ideal', action='store_true', help="Show the ideal output signal")
parser.add_argument('--ideal32', dest='ideal', action='store_true', help="Show the ideal output signal with 32 bits")
parser.add_argument('--fft', dest='fft', action='store_true', help="Show the fft of the signals")
parser.set_defaults(signal=False)
parser.set_defaults(fixed=False)
parser.set_defaults(float=False)
parser.set_defaults(diff1=False)
parser.set_defaults(diff2=False)
parser.set_defaults(diff3=False)
parser.set_defaults(ideal=False)
parser.set_defaults(ideal32=False)
parser.set_defaults(fft=False)


def showFFT(b, fs=48000, bins=1024*10, logy=True, justplot=True, label=""):
	N=bins
	X = np.fft.fft(b, N)
	if logy:
		Xm=np.abs(X)
		Xm = 20*np.log10(Xm/Xm.max())
	else:
		Xm = np.abs(X) * (2.0/len(X))
	t=np.fft.fftfreq(len(Xm), d=1.0/fs)
	if justplot:
		if label == "":
			plt.semilogx(t, Xm, alpha=0.6)
		else:
			plt.semilogx(t, Xm, label=label, alpha=0.6)
		# plt.show()
	else:
		return t, Xm

# def do(cmd):
# 	os.system(cmd)

# def chirp(length, low, high):
# 	times = np.linspace(0, length, num=length*48000)
# 	return scipy.signal.chirp(times, low, length, high, method="logarithmic")

if __name__ == '__main__':
	args = parser.parse_args()

	float_out = None
	fixed_out = None
	ideal_out = None
	ideal_out32 = None
	signal = None



	# coeffs1 = np.loadtxt("./better_lpf.coeffs")
	# coeffs2 = np.loadtxt("./tests/better_lpf_chirp_extended/coeff_fixed_int.list")
	# coeffs3 = np.loadtxt("./tests/better_lpf_chirp_extended/coeff.list")

	# print coeffs1.dtype

	# showFFT(coeffs1, label="1")
	# showFFT(coeffs2, label="2")
	# showFFT(coeffs3, label="3")
	# plt.plot(np.fft.fft(coeffs))
	
	if args.signal:
		signal = np.loadtxt(args.test + SIGNAL)

		if args.fft:
			showFFT(signal, justplot=True)
		else:
			plt.plot(signal, label="signal")

	if args.float:
		# print args.test + FLOAT
		float_out = np.loadtxt(args.test + FLOAT)

		if args.fft:
			showFFT(float_out, label="float fft")
			# plt.plot(np.fft.fft(float_out), label="float out fft", alpha=0.6)
		else:
			plt.plot(float_out, label="float out", alpha=0.6)

		

	if args.fixed:
		fixed_out = np.loadtxt(args.test + FIXED)
		
		if args.fft:
			showFFT(fixed_out, label="fixed fft")
			# plt.plot(np.fft.fft(fixed_out), label="fixed out fft", alpha=0.6)
		else:
			plt.plot(fixed_out, label="fixed out", alpha=0.6)



	if args.ideal:
		ideal_out = np.loadtxt(args.test + IDEAL)

		if args.fft:
			showFFT(ideal_out, label="ideal fft")
			# plt.plot(np.fft.fft(ideal_out), label="ideal out fft", alpha=0.6)
		else:
			plt.plot(ideal_out, label="ideal out", alpha=0.6)
		

	if args.ideal32:
		ideal_out32 = np.loadtxt(args.test + IDEAL32)
		plt.plot(ideal_out32, label="ideal out 32 bit", alpha=0.6)

	if args.diff1:
		if float_out == None:
			float_out = np.loadtxt(args.test + FLOAT)
		if fixed_out == None:
			fixed_out = np.loadtxt(args.test + FIXED)
		plt.plot(float_out - fixed_out, label="float - fixed", alpha=0.6)

	if args.diff2:
		if float_out == None:
			float_out = np.loadtxt(args.test + FLOAT)
		if ideal_out == None:
			ideal_out = np.loadtxt(args.test + IDEAL)
		err = float_out - ideal_out
		print "Floating RMSE:", np.sqrt(np.mean(np.power(err[300:-300], 2.0)))
		plt.plot(err[300:-300], label="float - ideal", alpha=0.6)

	if args.diff3:
		if ideal_out == None:
			ideal_out = np.loadtxt(args.test + IDEAL)
		if fixed_out == None:
			fixed_out = np.loadtxt(args.test + FIXED)

		err = fixed_out - ideal_out
		print "Fixed RMSE:", np.sqrt(np.mean(np.power(err[300:-300], 2.0)))
		plt.plot(err[300:-300], label="fixed - ideal", alpha=0.6)


	# print (fixed_out - ideal_out)
	# exit()

	plt.legend()
	plt.show()