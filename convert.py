#!/usr/bin/env python

import struct
import argparse
import re, string
from argparse import RawTextHelpFormatter

parser = argparse.ArgumentParser(
	formatter_class=RawTextHelpFormatter,
	description='Utility for converting numerical representations. \n \n \
    Int (3) to binary float (01000....0): convert.py in.txt out.txt --in_format=d, --out_format=b \n \
    Float (1.234) to binary float (01000....0): convert.py in.txt out.txt --in_format=f, --out_format=b \n \
    Binary float (01000....0) to decimal float (1.234): convert in.txt out.txt --in_format=b, --out_format=d --ftoi \n \
    Binary float (01000....0) to decimal int (1): convert in.txt out.txt --in_format=b, --out_format=i --ftoi \n \n \n \
This can take either input files or just a single raw input value, for example:\n\n \
    ./convert.py 1.234 --out_format=b --in_format=f\n \
    > 00111111100111011111001110110110\n \n \
    ./convert.py 00111111100111011111001110110110 --out_format=f --in_format=b --ftoi \n \
    > 1.23399996758\n \n \
Use --noconv to convert directly from one number type to another, without turning it into a binary float value.\n \n \
    ./convert.py f --in_format=h --out_format=b --noconv \n \
  	> 00000000000000000000000000001111 \n\n\
Warning: Converting float value outputs (without ftoi) to something other ')

parser.add_argument('input', metavar='IN/VAL', type=str, help='Input file path or a single value to convert.')
parser.add_argument('output', metavar='OUT', nargs="?", type=str, help='Output file path')
parser.add_argument('--in_format',metavar='b,d,h,f', type=str, default="d", help='Format of input values: hex(h), decimal(d), binary(b), or float(f)')
parser.add_argument('--out_format',metavar='b,d,h,f,i', type=str, default="b", help='Format of output values: hex(h), decimal(d), binary(b), ints(i) or float(f)')
parser.add_argument('--ftoi', dest='ftoi', action='store_true', help="Convert from a binary representation of a float value to a number")
parser.add_argument('--noconv', dest='noconvert', action='store_true', help="Do not convert from a number to a float binary representation, just number to number.")
parser.add_argument('--bitness', type=int, default=32, help="Number of bits on the output, default 32")
parser.add_argument('--2c', dest='twoscomplement', action='store_true', help="Indicate that the input is in twos complement format")
parser.set_defaults(ftoi=False)
parser.set_defaults(noconvert=False)
parser.set_defaults(twoscomplement=False)


bitness = 32

def load_data(infile, informat):
	# pattern = re.compile('[\W_|.]+') # remove nonalphanumeric
	pattern = re.compile('[^\dA-Fa-f.-]+') # remove nonalphanumeric except period
	data = []
	with open(infile, 'r') as data_file:
		for row in data_file:
			val = pattern.sub('', row)
			if not val == "":
				data.append(val)
	return data

def save_output(outfile, outformat, data):
	with open(outfile, 'w') as data_file:
		if bin_format(outformat):
			for row in data:
				row = int_to_twos_comp(row, bitness)
				data_file.write(format(row, '#0'+str(bitness+2)+'b')[2:] + "\n")
		elif hex_format(outformat):
			for row in data:
				row = int_to_twos_comp(row, bitness)
				data_file.write(format(row, "#0"+str(bitness/4+2)+"X")[2:] + "\n")
		elif dec_format(outformat):
			for row in data:
				data_file.write(str(row) + "\n")
		elif float_format(outformat):
			for row in data:
				data_file.write(str(row) + "\n")
		elif int_format(outformat):
			for row in data:
				data_file.write(str(int(row)) + "\n")

def twos_comp_to_int(val, bits):
	""" compute the 2's complement of int value val """
	if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
		val = val - (1 << bits)        # compute negative value
	return val                         # return positive value as is

def int_to_twos_comp(val, bits):
	""" compute the 2's complement of int value val """
	if val < 0:
		val = val % (1<<bits)
	return val

def hex_format(formatstr):
	formatstr = formatstr.lower()
	return formatstr == "hex" or formatstr == "h"

def bin_format(formatstr):
	formatstr = formatstr.lower()
	return formatstr == "bin" or formatstr == "b"

def dec_format(formatstr):
	formatstr = formatstr.lower()
	return formatstr == "decimal" or formatstr == "dec" or formatstr == "d"

def float_format(formatstr):
	formatstr = formatstr.lower()
	return formatstr == "float" or formatstr == "f"

def int_format(formatstr):
	formatstr = formatstr.lower()
	return formatstr == "int" or formatstr == "i"

def hex_to_int(hex_str):
	return int(hex_str, 16)

def bin_to_int(bin_str):
	return int(bin_str, 2)

def decimal_to_int(dec_str):
	return int(float(dec_str))

def float_to_float(float_str):
	return float(float_str)

def float_to_binary(f):
	if f < 0:
		f = f * -1
		val = int(struct.unpack('!i',struct.pack('!f',f))[0])
		val |= 0b10000000000000000000000000000000
		return val
	return int(struct.unpack('!i',struct.pack('!f',f))[0])

def binary_to_float(f):
	return struct.unpack('f', struct.pack('I', f))[0]

def format_to_format(formatstr):
	if dec_format(formatstr):
		return "decimal"
	if hex_format(formatstr):
		return "hexidecimal"
	if bin_format(formatstr):
		return "binary"
	if int_format(formatstr):
		return "integer"
	if float_format(formatstr):
		return "float"


def should_convert_to_binary_float_representation(args):
	return not args.ftoi and not float_format(args.out_format) and not args.noconvert

def main():
	global bitness
	args = parser.parse_args()
	bitness = args.bitness

	if args.input and args.output:
		print args.input, "-->", args.output
		print "...Input format: ", format_to_format(args.in_format)
		print "...Output format: ", format_to_format(args.out_format)
		print "...Convert from binary float representation:", args.ftoi

		data = load_data(args.input, args.in_format)

		if hex_format(args.in_format):
			data = map(hex_to_int, data)
		elif bin_format(args.in_format):
			data = map(bin_to_int, data)
		elif dec_format(args.in_format):
			data = map(decimal_to_int, data)
		elif float_format(args.in_format):
			data = map(float_to_float, data)

		if args.twoscomplement:
			data = map(lambda x: twos_comp_to_int(x, bitness), data)

		if args.ftoi:
			data = map(binary_to_float, data)

		# if necessary, convert from a number to a binary float representation
		if should_convert_to_binary_float_representation(args):
			data = map(float_to_binary, data)

		save_output(args.output, args.out_format, data)
	
	elif args.input:
		in_val = args.input

		if hex_format(args.in_format):
			in_val = hex_to_int(in_val)
		elif bin_format(args.in_format):
			in_val = bin_to_int(in_val)
		elif dec_format(args.in_format):
			in_val = decimal_to_int(in_val)
		elif float_format(args.in_format):
			in_val = float_to_float(in_val)

		if args.twoscomplement:
			in_val = twos_comp_to_int(in_val, bitness)

		if args.ftoi:
			in_val = binary_to_float(in_val)

		# if necessary, convert from a number to a binary float representation
		if should_convert_to_binary_float_representation(args):
			in_val = float_to_binary(in_val)

		if bin_format(args.out_format):
			in_val = int_to_twos_comp(in_val, bitness)
			in_val = format(in_val, '#0'+str(bitness+2)+'b')[2:]
		elif hex_format(args.out_format):
			in_val = int_to_twos_comp(in_val, bitness)
			in_val = format(in_val, "#0"+str(bitness/4+2)+"X")[2:]
		elif dec_format(args.out_format):
			in_val = str(in_val)
		elif float_format(args.out_format):
			in_val = str(in_val)
		elif int_format(args.out_format):
			in_val = str(int(in_val))

		print in_val

if __name__ == '__main__':
	main()