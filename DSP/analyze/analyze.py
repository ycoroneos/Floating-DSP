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

def sine(fs, f):
    t=np.arange(0,1,1.0/fs)
    return t, np.sin(2.0*np.pi*f*t)

def showFFT(fs, x, freqlo, freqhi):
    xf=scipy.fftpack.fft(x)
    freq=np.fft.fftfreq(len(x), d=1.0/fs)
    #plt.plot(freq[freqlo:freqhi],(2.0/len(x))* np.abs(xf)[freqlo:freqhi])
    plt.semilogx(freq[freqlo:freqhi],(2.0/len(x))* np.abs(xf)[freqlo:freqhi])
    plt.show()

def readfloatfile(filename):
    return map(float, [line.strip() for line in open(filename, 'r')])

if (__name__=="__main__"):
    #generate a sample signal
    sig=readfloatfile("chirp.signal")
    showFFT(48000, sig, 0, 4000)
#    t, sq=square(48000, 1)
#    t2, sn2 = sine(48000, 50)
#    t3, sn3 = sine(48000, 20)
#    showFFT(48000, sq, 0, 100)
