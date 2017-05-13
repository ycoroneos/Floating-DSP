#!/usr/bin/python
import numpy as np
import scipy
import scipy.fftpack
import matplotlib.pyplot as plt
import os
import sys

def square(fs, f):
    t = np.linspace(0,2,2*fs+1)
    sq = np.zeros(len(t)) #preallocate the output array
    for h in np.arange(1,25,2):
        sq += (4/(np.pi*h))*np.sin(2*np.pi*f*h*t)
    return t, np.sign(sq)

def DFT(x):
    n=len(x)
    return scipy.fftpack.fft(x)[0:n/2]

if (__name__=="__main__"):
    #generate a sample signal
    t, sq=square(48000, 1)
    dft=DFT(sq)
    #plt.plot(t, sq)
    plt.plot(map(abs, dft[0:20]))
    plt.show()
