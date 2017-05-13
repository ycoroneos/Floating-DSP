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
    # t = np.linspace(0,length,length*fs+1)
    # sq = np.zeros(len(t)) #preallocate the output array
    # for h in np.arange(1,25,length):
    #     sq += (4/(np.pi*h))*np.sin(2*np.pi*f*h*t)
    # return t, np.sign(sq)


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

# good window function: flattop, blackmanharris, nuttall, parzen
if __name__ == '__main__':
	# args = parser.parse_args()

	# chp = chirp(1.0, 10, 20000)

	# sqr = square(0.25, 100)

	# print "TEST", sqr.shape

	# np.savetxt("./square_smaller.signal", sqr, fmt="%.9f")

	# boxcar, triang, blackman, hamming, hann, bartlett, flattop, parzen, bohman, blackmanharris, nuttall, barthann, kaiser (needs beta), gaussian (needs std), general_gaussian (needs power, width), slepian (needs width), chebwin (needs attenuation)

	windows = ["boxcar", "triang", "blackman", "hamming", "hann", "bartlett", "flattop", "parzen", "bohman", "blackmanharris", "nuttall", "barthann"]
	goodwindows = ["flattop", "blackmanharris", "nuttall", "parzen"]
	goodwindows = ["nuttall"]

	TAPS = 107
	FS = 48000
	CUT = 1000

	lpf = lowpass(CUT, FS, bins=TAPS, window="nuttall")
	hpf = highpass(CUT, FS, bins=TAPS, window="nuttall")

	np.savetxt("./better_lpf.coeffs", lpf, fmt="%.9f")
	np.savetxt("./better_hpf.coeffs", hpf, fmt="%.9f")



	for i in goodwindows:
		print "Window function:", i
		hpf = highpass(CUT, FS, bins=TAPS)
		lpf = lowpass(CUT, FS, bins=TAPS, window=i)

		other = np.loadtxt("./lpf.coeffs")

		fir_freqz(lpf, FS)
		fir_freqz(hpf, FS)

		plt.ylim([-160,10])
		plt.xlim([10,FS/2])

		plt.xscale("log")

		plt.show()

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
	