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
# FLOAT = "/output_float_24bit.list"
# FLOAT = "/output_float_24bit_dither.list"
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
	# my_data = np.genfromtxt('datdatdoe_lpf.csv', delimiter=',')
	my_data = np.genfromtxt('datdatdoe_hpf.csv', delimiter=',')
	# my_data = np.genfromtxt('datdatdoe_delay.csv', delimiter=',')
	titles = ("freq", "float rmse", "float err", "float rounded rmse", "float rounded err", "float dithered rmse", "float dithered err", "float fixed rmse", "float fixed err")
	my_data = my_data[1:,:]

	plt.semilogx(my_data[:,0], my_data[:,1], label=titles[1])
	plt.semilogx(my_data[:,0], my_data[:,3], label=titles[3])
	plt.semilogx(my_data[:,0], my_data[:,5], label=titles[5])
	plt.semilogx(my_data[:,0], my_data[:,7], label=titles[7])

	plt.legend()
	plt.show()

	# plt.semilogx(my_data[:,0], my_data[:,2], label=titles[2])
	# plt.semilogx(my_data[:,0], my_data[:,4], label=titles[4])
	# plt.semilogx(my_data[:,0], my_data[:,6], label=titles[6])
	# plt.semilogx(my_data[:,0], my_data[:,8], label=titles[8])

	# plt.legend()
	# plt.show()