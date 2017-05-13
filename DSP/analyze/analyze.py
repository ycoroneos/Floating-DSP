#!/usr/bin/python
import numpy as np
import scipy
import scipy.signal
import scipy.fftpack
import matplotlib.pyplot as plt
import os
import sys

def square(fs, f, time):
    t = np.linspace(0,time,time*fs+1)
    sq = np.zeros(len(t)) #preallocate the output array
    for h in np.arange(1,25,time):
        sq += (4/(np.pi*h))*np.sin(2*np.pi*f*h*t)
    return t, np.sign(sq)

def sine(fs, f):
    t=np.arange(0,1,1.0/fs)
    return t, np.sin(2.0*np.pi*f*t)



def showFFT(b, fs=48000, bins=1024*10, logy=False, justplot=False):
    N=bins
    X = np.fft.fft(b, N)
    if logy:
        Xm=np.abs(X)
        Xm = 20*np.log10(Xm/Xm.max())
    else:
        Xm = np.abs(X) * (2.0/len(X))
    t=np.fft.fftfreq(len(Xm), d=1.0/fs)
    if justplot:
        plt.semilogx(t, Xm)
        plt.show()
    else:
        return t, Xm


def readfloatfile(filename):
    return map(float, [line.strip() for line in open(filename, 'r')])

def calcTHDN(fftsig, fundamental):
    denom = fftsig[fundamental]/np.sqrt(2)
    numerator = sum(map(lambda x: np.power((x/np.sqrt(2)),2.0), fftsig))
    numerator -= np.power(denom, 2.0)
    numerator = np.sqrt(numerator)
    return numerator / denom


if (__name__=="__main__"):
    sig=readfloatfile("coeff_fixed_int.list")
    #sig=readfloatfile("chirp.signal")
    #t, sq=sine(48000, 2000)
    #t, sq=square(48000, 2000, 4)
    showFFT(sig, 48000, justplot=True, logy=True)
