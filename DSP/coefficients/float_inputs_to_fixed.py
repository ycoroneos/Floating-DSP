import numpy as np
import matplotlib.pyplot as plt


# infile = open("./float_coeff_100LP.coe", "r")
# sigfile = open("./fixed_coeff_ints.coe", "w")

infile = open("./chirp_float.mem", "r")
sigfile = open("./chirp_fixed_ints.mem", "w")

output_bitness = 24
mult = 2**(output_bitness-1)-1

upper_bound = 2**(output_bitness-1) - 1
lower_bound = -1*(2**(output_bitness-1))

i = 0
for row in infile:
	inval = float(row)

	outval = round(inval * mult)

	if outval > upper_bound:
		print "Clipping input to maximum output"
		outval = upper_bound
	elif outval < lower_bound:
		print "Clipping input to minimum output"
		outval = lower_bound

	sigfile.write(str(int(outval))+'\n')

	i += 1

# i = 0
# for row in sigfile:
# 	outs[i] = float(row)
# 	i += 1

# 	if i > num_vals:
# 		break