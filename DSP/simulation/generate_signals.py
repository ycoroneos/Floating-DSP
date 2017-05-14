#!/usr/bin/env python

import numpy as np
import struct, os
import argparse
import re, string
import matplotlib.pyplot as plt
from argparse import RawTextHelpFormatter
import scipy
import scipy.signal


# parser = argparse.ArgumentParser(
# 	formatter_class=RawTextHelpFormatter,
# 	description='')

# parser.add_argument('coeffs', metavar='COEFFS', type=str, help='File to find coefficients in float format from [1.0,-1.0]')
# parser.add_argument('signal', metavar='SIGNAL', type=str, help='File to find signal in float format from [1.0,-1.0]')
# parser.add_argument('output', metavar='OUTPUT', type=str, help='Name of the output folder')
# parser.add_argument('--notes', metavar='NOTES', type=str, default="", help='Optional notes')


def do(cmd):
	os.system(cmd)

def chirp(length, low, high):
	times = np.linspace(0, length, num=length*48000)
	return scipy.signal.chirp(times, low, length, high, method="logarithmic")

def square(length, f, fs=48000):
	square = np.ones(int(length*fs), dtype=np.float64)
	for i in xrange(int(fs/f/2)):
		square[i::int(fs/f)] = -1.0
	return square*0.5

def sin(length, f, fs=48000):
	t = np.linspace(0,2.0*np.pi*f*length,length*fs+1)
	return np.sin(t)

def highpass(cutoff, fs, bins=101, window="hamming"):
    return scipy.signal.firwin(bins, cutoff = cutoff, window=window, pass_zero=False, nyq=fs / 2)

def lowpass(cutoff, fs, bins=101, window="hamming"):
    return scipy.signal.firwin(bins, cutoff = cutoff, window=window, pass_zero=True, nyq=fs / 2)

def fir_freqz(b, fs):
    N=1024*10
    # Get the frequency response
    X = np.fft.fft(b, N)
    # Take the magnitude
    Xm = np.abs(X)
    # Convert the magnitude to decibel scale
    Xdb = 20*np.log10(Xm/Xm.max())
    # Frequency vector
    f = np.arange(N)*fs/N
    plt.semilogx(f, Xdb, 'b', label='Orig. coeff.')
    # plt.show()

CONV = "../../convert.py "
SIMULATE = "./simulate.py "

# good window function: flattop, blackmanharris, nuttall, parzen
if __name__ == '__main__':



	num_cycles = 5.0
	padding = 300.0
	num_samples = 280
	# samples = np.logspace(20.0, 20000.0, num=num_samples)
	samples = np.logspace(1.0, 5.0, num=num_samples)
	min_freq = 20
	max_freq = 20000

	i = 0
	t = 0.0
	for freq in samples:
		if freq < min_freq or freq > max_freq:
			continue

		if freq < 1280:
			continue
		# if freq < 100:
		# 	time = 4 / freq
		# else:
		# 	time = num_cycles / freq + padding / 48000.0
		print "FREQ:", freq
		# i += 1
		# # time = num_cycles / freq + padding / 48000.0
		# t += time
		# wave = sin(time, freq)
		# np.savetxt("./tests/sweep/sin_"+str(int(freq)) + ".signal", wave, fmt="%.12f")

		name = str(int(freq))
		# run the shit through the simulator
		do(SIMULATE+"better_lpf.coeffs ./tests/sweep/sin_"+name+".signal ./tests/sweep/sin_"+name)

		# print SIMULATE+"better_lpf.coeffs ./tests/sweep/sin_"+str(freq)+".signal ./tests/sweep/sin_"+str(freq)

		# plt.plot(wave)
		# plt.show()

	print i, t

	# args = parser.parse_args()

	# chp = chirp(1.0, 10, 20000)

	# sqr = square(0.25, 100)

	# print "TEST", sqr.shape

	# np.savetxt("./square_smaller.signal", sqr, fmt="%.9f")

	# boxcar, triang, blackman, hamming, hann, bartlett, flattop, parzen, bohman, blackmanharris, nuttall, barthann, kaiser (needs beta), gaussian (needs std), general_gaussian (needs power, width), slepian (needs width), chebwin (needs attenuation)

	# windows = ["boxcar", "triang", "blackman", "hamming", "hann", "bartlett", "flattop", "parzen", "bohman", "blackmanharris", "nuttall", "barthann"]
	# goodwindows = ["flattop", "blackmanharris", "nuttall", "parzen"]
	# goodwindows = ["nuttall"]

	# TAPS = 107
	# FS = 48000
	# CUT = 1000

	# lpf = lowpass(CUT, FS, bins=TAPS, window="nuttall")
	# hpf = highpass(CUT, FS, bins=TAPS, window="nuttall")

	# np.savetxt("./better_lpf.coeffs", lpf, fmt="%.20f")
	# np.savetxt("./better_hpf.coeffs", hpf, fmt="%.20f")

	# for i in goodwindows:
	# 	print "Window function:", i
	# 	hpf = highpass(CUT, FS, bins=TAPS)
	# 	lpf = lowpass(CUT, FS, bins=TAPS, window=i)

	# 	other = np.loadtxt("./lpf.coeffs")

	# 	fir_freqz(lpf, FS)
	# 	fir_freqz(hpf, FS)

	# 	plt.ylim([-160,10])
	# 	plt.xlim([10,FS/2])

	# 	plt.xscale("log")

	# 	plt.show()

	# numbins = 1024*10

	# f = np.fft.fft(lpf, numbins)

	# fabs = np.abs(f)
	# xdb = 20*np.log10(fabs / fabs.max())
	# x = np.linspace(0, 1.0, numbins)

	# plt.semilogx(x, xdb)

	# print np.sum(lpf)
	# print np.sum(hpf)


	# plt.plot(hpf)
	# plt.plot(lpf)
	# plt.show()

	# # np.savetxt("./chirp_extended.signal", chp, fmt="%.9f")
	# # plt.plot(chp)
	