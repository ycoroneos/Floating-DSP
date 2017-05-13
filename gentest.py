#!/usr/bin/env python

import struct
import argparse
import re, string
from argparse import RawTextHelpFormatter
import numpy as np

with open("test.txt", 'w') as data_file:
	for i in xrange(10000):
		# data_file.write(str(i) + "\n")
		data_file.write(str(np.sin(i / 10.0)) + "\n")

# verify it works
# with open("out2.txt", 'r') as data_file:
# 	i = 0
# 	for row in data_file:
# 		err = abs(float(row) - np.sin(i / 10.0)) 
# 		if err > 0.000001:
# 			print
# 			print
# 			print
# 			print row, np.sin(i / 10.0), err, i
# 		i += 1