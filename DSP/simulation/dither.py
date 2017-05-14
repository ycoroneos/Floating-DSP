import numpy as np
import matplotlib.pyplot as plt


num = 1000
vals = np.linspace(0, 1.0, num=num)

steps = 4


def threshold(vals):
	return np.round(vals*steps)

def dither(vals):
	out = np.zeros(vals.shape)
	err = 0.0
	for i in xrange(vals.shape[0]):
		val = steps * vals[i]
		out[i] = np.round(val - err)
		err += out[i] - val
	return out
		# print err

	# print err


image = np.zeros((num,num))
image2 = np.zeros((num,num))
image3 = np.zeros((num,num))

dither(vals)

for i in xrange(num):
	image[:,i] = vals
	image2[:,i] = threshold(vals)
	image3[:,i] = dither(vals)

# plt.imshow(image, cmap="gray")
# plt.show()

plt.imshow(image2, cmap="gray")
plt.show()

plt.imshow(image3, cmap="gray")
plt.show()
