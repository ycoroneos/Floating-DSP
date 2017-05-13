#!/usr/bin/env python

import struct
import argparse
import re, string
from argparse import RawTextHelpFormatter

parser = argparse.ArgumentParser(
	formatter_class=RawTextHelpFormatter,
	description='')

parser.add_argument('coefficients', metavar='COEFFS', type=str, help='File to find coefficients in float format from [1.0,-1.0')
