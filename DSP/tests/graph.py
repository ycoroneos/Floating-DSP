import numpy as np
import matplotlib.pyplot as plt

num_vals = 48416


ins = np.zeros(num_vals+10, dtype=np.float64)
outs = np.zeros(num_vals+10, dtype=np.float64)
outs2 = np.zeros(num_vals+10, dtype=np.float64)
outs_float = np.zeros(num_vals+10, dtype=np.float64)


infile = open("./chirp_in.txt", "r")
sigfile_float = open("./floating_chirp_lpf_float.txt", "r")
sigfile = open("./fixed_chirp_lpf_intever.txt", "r")
# sigfile = open("./fixed_chirp_lpf.txt", "r")

i = 0
for row in infile:
	ins[i] = float(row)
	i += 1

i = 0
for row in sigfile:
	# print
	# print row, "  ", int(row) >> 23, int(row) / (2**23)
	chop = 23
	outs[i] = float(int(row) >> chop) / (2**(46-chop))
	outs2[i] = float(row) / (2**46)
	i += 1

	if i > num_vals:
		break
i = 0
for row in sigfile_float:
	outs_float[i] = float(row)
	i += 1

	if i > num_vals:
		break

outs = outs[500:-500]
outs2 = outs2[500:-500]
outs_float = outs_float[500:-500]

from scipy.optimize import minimize

# print np.mean(np.power(outs - outs_float , 2.0))

# print np.sum(outs) / np.sum(outs_float)
# print np.sum(outs_float)

def err(x):
	return np.mean(np.power(outs - x*outs_float, 2.0))

def err2(x):
	return np.mean(np.power(outs[500+x:-500+x] - x*outs_float[500:-500], 2.0))

# print err(1.0), err(1.00000159)

print "fd", np.mean(np.power(outs - outs_float, 2.0))
print "ch", np.mean(np.power(outs2 - outs_float, 2.0))


# for i in xrange(-5, 5):
# 	print err2(i), i

# res = minimize(err, 1.5)

# print res
# exit()
infile.close()
sigfile.close()
# exit()
plt.plot(outs2 - outs)
# plt.plot(outs - outs_float, label="err")
# # plt.plot(ins, label="chirp")
# plt.plot(outs, label="filtered fixed")
# plt.plot(outs_float, label="filtered float")
# plt.legend()
plt.show()

