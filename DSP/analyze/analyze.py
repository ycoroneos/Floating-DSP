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


def getFFT(fs, x, freqlo, freqhi):
    xf=scipy.fftpack.fft(x)
    freq=np.fft.fftfreq(len(x), d=1.0/fs)
    return (2.0/len(x))* np.abs(xf)[freqlo:freqhi]

def showFFT(fs, x, freqlo, freqhi):
    xf=scipy.fftpack.fft(x, fs*1000)
    freq=np.fft.fftfreq(len(x), d=1.0/fs)
    #plt.plot(freq[freqlo:freqhi],(2.0/len(x))* np.abs(xf)[freqlo:freqhi])
    plt.semilogx(freq[freqlo:freqhi],(2.0/len(x))* np.abs(xf)[freqlo:freqhi])
    plt.show()

def showFFTdB(fs, x, freqlo, freqhi):
    xf=scipy.fftpack.fft(x, 1024)
    freq=np.fft.fftfreq(len(x), d=1.0/fs)
    #plt.plot(freq[freqlo:freqhi],(2.0/len(x))* np.abs(xf)[freqlo:freqhi])
    #plt.semilogx(freq[freqlo:freqhi],(2.0/len(x))* np.abs(xf)[freqlo:freqhi])
    dat=20*np.log10(xf/max(xf))
    plt.semilogx(freq[freqlo:freqhi], dat)
    plt.show()

def fir_freqz(b, fs):
    N=1024*10
    # Get the frequency response
    X = np.fft.fft(b, N)
    # Take the magnitude
    Xm = np.abs(X)
    # Convert the magnitude to decibel scale
    Xdb = 20*np.log10(Xm/Xm.max())
    # Frequency vector
    f = np.arange(N)*fs/N
    plt.semilogx(f, Xdb, 'b', label='Orig. coeff.')
    plt.show()

def readfloatfile(filename):
    return map(float, [line.strip() for line in open(filename, 'r')])

def calcTHDN(fftsig, fundamental):
    denom = fftsig[fundamental]/np.sqrt(2)
    numerator = sum(map(lambda x: np.power((x/np.sqrt(2)),2.0), fftsig))
    numerator -= np.power(denom, 2.0)
    numerator = np.sqrt(numerator)
    return numerator / denom


if (__name__=="__main__"):
    #generate a sample signal
    sig=readfloatfile("coeff_fixed_int.list")
    #sig=readfloatfile("chirp.signal")
    #w,h = scipy.signal.freqz(sig)
    #h_dB = 20 * np.log10(abs(h))
    #plt.plot(w/max(w), h_dB)
    #plt.show()
    fir_freqz(sig, 48000)
    #showFFTdB(48000*100, sig, 0, 48000)
    #t, sq=square(48000, 2, 4)
   # t, sq=sine(48000, 2)
    #fft=getFFT(48000, sq, 0, 100)
    #print calcTHDN(fft, 2)
#    plt.plot(t, sq)
#    plt.show()
#    t2, sn2 = sine(48000, 50)
#    t3, sn3 = sine(48000, 20)
#    showFFT(48000, sq, 0, 100)
