from pylab import *
import scipy.signal as signal

#Plot frequency and phase response
def mfreqz(b,a=1):
    w,h = signal.freqz(b,a)
    h_dB = 20 * log10 (abs(h))
    subplot(211)
    plot(w/max(w),h_dB)
    ylim(-150, 5)
    ylabel('Magnitude (db)')
    xlabel(r'Normalized Frequency (x$\pi$rad/sample)')
    title(r'Frequency response')
    subplot(212)
    h_Phase = unwrap(arctan2(imag(h),real(h)))
    plot(w/max(w),h_Phase)
    ylabel('Phase (radians)')
    xlabel(r'Normalized Frequency (x$\pi$rad/sample)')
    title(r'Phase response')
    subplots_adjust(hspace=0.5)

#Plot step and impulse response
def impz(b,a=1):
    l = len(b)
    impulse = repeat(0.,l); impulse[0] =1.
    x = arange(0,l)
    response = signal.lfilter(b,a,impulse)
    subplot(211)
    stem(x, response)
    ylabel('Amplitude')
    xlabel(r'n (samples)')
    title(r'Impulse response')
    subplot(212)
    step = cumsum(response)
    stem(x, step)
    ylabel('Amplitude')
    xlabel(r'n (samples)')
    title(r'Step response')
    subplots_adjust(hspace=0.5)

n = 90
a = signal.firwin(n, cutoff = 0.3, window = "hamming")

float_coeffs = a.astype(np.float32)
print a.dtype


def convert_to_fixed(coeff):
	coeff *= 2**23
	coeff = np.round(coeff).astype(np.int64)
	return coeff

def convert_from_fixed(coeff):
	coeff = coeff.astype(np.float64)
	return coeff / 2**23


fixed_coeffs = convert_to_fixed(a.copy())
fixed_coeffs = convert_from_fixed(fixed_coeffs)
# print np.sum(a)
# print fixed_coeffs
# print np.sum(convert_from_fixed(fixed_coeffs))

# exit()
#Frequency and phase response
mfreqz(fixed_coeffs)
# figure(2)
mfreqz(a)
show()
#Impulse and step response
# figure(2)
# impz(a)
# show()