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

if __name__ == '__main__':
	# args = parser.parse_args()

	chp = chirp(1.0, 10, 20000)

	np.savetxt("./chirp_extended.signal", chp, fmt="%.9f")

	plt.plot(chp)
	plt.show()