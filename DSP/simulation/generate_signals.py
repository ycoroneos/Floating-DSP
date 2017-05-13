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


def highpass(cutoff, fs, bins=101):
    return scipy.signal.firwin(bins, cutoff = 0.3, window = "hamming", pass_zero=False)

def lowpass(cutoff, fs, bins=101):
    return scipy.signal.firwin(bins, cutoff = 0.3, window = "hamming", pass_zero=True)



if __name__ == '__main__':
	# args = parser.parse_args()

	# chp = chirp(1.0, 10, 20000)

	# sqr = square(0.25, 100)

	# print "TEST", sqr.shape

	# np.savetxt("./square_smaller.signal", sqr, fmt="%.9f")
	
	hpf = highpass(4800, 24800, bins=207)
	lpf = lowpass(4800, 24800, bins=207)

	numbins = 1024*10

	f = np.fft.fft(lpf, numbins)

	fabs = np.abs(f)
	xdb = 20*np.log10(fabs / fabs.max())
	x = np.linspace(0, 1.0, numbins)

	plt.semilogx(x, xdb)

	print np.sum(lpf)
	print np.sum(hpf)


	# plt.plot(hpf)
	# plt.plot(lpf)

	# # np.savetxt("./chirp_extended.signal", chp, fmt="%.9f")
	# # plt.plot(chp)
	plt.show()