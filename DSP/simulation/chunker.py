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

parser.add_argument('input', metavar='INPUT', type=str, help='Input file')
parser.add_argument('output', metavar='OUTPUT', type=str, help='Output file prefix')
parser.add_argument('--chunks', dest='chunks', default=5, type=int, help="Number of chunks")
parser.add_argument('--padding', dest='padding', default=600, type=int, help="Number of samples to overlap")

if __name__ == '__main__':
	args = parser.parse_args()
	full = np.loadtxt(args.input)

	breaks = np.linspace(0,full.shape[0], num=args.chunks+1).astype(int)
	for i in xrange(1,breaks.shape[0]):
		left = breaks[i-1]
		right = np.min((breaks[i] + args.padding, full.shape[0]))

		chunk = full[left:right]
		np.savetxt(args.output + str(i) + ".list", chunk, fmt="%.10f")


	print breaks

	# args.input
	# args.chunks
