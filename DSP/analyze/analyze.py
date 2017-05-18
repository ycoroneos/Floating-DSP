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
    t=np.arange(0,0.008,1.0/fs)
    return t, np.sin(2.0*np.pi*f*t)



def showFFT(b, fs=48000, bins=1024*50, logy=False, justplot=False, plotlabel=''):
    N=bins
    X = np.fft.fft(b, N)
    if logy:
        Xm=np.abs(X)
        Xm = 20*np.log10(Xm/Xm.max())
    else:
        Xm = np.abs(X) * (2.0/len(X))
    t=np.fft.fftfreq(len(Xm), d=1.0/fs)
    if justplot:
        plt.semilogx(t, Xm, label=plotlabel)
        #plt.show()
    else:
        return t, Xm


def readfloatfile(filename):
    return map(float, [line.strip() for line in open(filename, 'r')])


def calcTHDN(fftscale, fftsig, fundamental, bounds=20.0):
    #helper
    rmsfunc = lambda v:np.sqrt(np.sum(map(lambda x: x*x, v)))
    #first zero in on the fundamental frequency
    scalefact=fftscale[1]
    fund_lo = fundamental-bounds
    fund_hi = fundamental+bounds
    index_lo = np.floor(fund_lo/scalefact)
    index_hi = np.floor(fund_hi/scalefact)
    index_end = np.floor(24000.0/scalefact)
    denominator = rmsfunc(fftsig[index_lo:index_hi])
    numerator = rmsfunc(fftsig[index_hi+1:index_end])
    return numerator / denominator

#calculates THD+N for a some given signal samples
def signalTHDN(signal, fundamental, fs=48000, fuzz=20.0, auto=False):
    freqscale, value = showFFT(signal, fs, justplot=False, logy=False)
    if auto:
        fundamental=freqscale[np.argmax(value)]
        print fundamental
    return calcTHDN(freqscale, value, fundamental, bounds=fuzz)

#takes badly sliced period signal and returns two perfect periods
def symmetric(signal):
    deriv = signal[1:] - signal[:-1]
    firstcut=1
    while not ((np.sign(signal[firstcut])==1 or np.sign(signal[firstcut])==0) and np.sign(signal[firstcut-1])==-1 and deriv[firstcut]>0):
        firstcut+=1
    secondcut=firstcut+1
    while not ((np.sign(signal[secondcut])==1 or np.sign(signal[firstcut])== 0) and np.sign(signal[secondcut-1])==-1 and deriv[secondcut]>0):
        secondcut+=1
    print (firstcut, secondcut)
    return np.tile(signal[firstcut:secondcut], 10000)

def addzeroes(signal):
    return np.append(np.zeros(1000), np.append(signal, np.zeros(1000)))

def multiple_files(files):
    for f in files:
        #sig=symmetric(np.array(readfloatfile(f)[250:450]))
        #sig=addzeroes(np.array(readfloatfile(f)[250:450]))
        sig=np.array(readfloatfile(f))
        #plt.plot(sig, label=f)
        showFFT(sig, justplot=True, plotlabel=f, logy=True)
        #print str(f)+" "+str(signalTHDN(sig, 100, auto=True, fuzz=400.0))

if (__name__=="__main__"):
    #multiple_files(['output_fixed_normalized.list', 'output_float_dec.list'])
    multiple_files(['better_hpf.coeffs'])
    plt.legend()
    plt.show()
    #sig=readfloatfile("coeff_fixed_int.list")
    #sig=readfloatfile("output_ideal.list")[250:450]
    #sig=symmetric(np.array(readfloatfile("output_fixed_normalized.list")[250:450]))
    #sig=symmetric(np.array(readfloatfile("output_float_dec.list")[250:450]))
    #plt.plot(sig)
    #plt.show()
    #t, sq=sine(48000, 1280)
    #plt.plot(sig)
    #plt.show()
    #showFFT(sig, justplot=True)
    #print signalTHDN(sig, 100, auto=True, fuzz=400.0)
#    t, sq=square(48000, 100, 4)
#    freqscale, value = showFFT(sq, 48000, justplot=False, logy=False)
#    print calcTHDN(freqscale, value, 100, bounds=20.0)
