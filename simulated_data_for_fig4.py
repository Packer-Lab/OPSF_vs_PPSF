import numpy as np
import matplotlib.pyplot as plt

# generate mock data for axial PSF
a1 = 18.6  # FWHM
a2 = 8.3  # FWHM
plotwidth = 120  # specify x-axis width [μm]
sdtofwhm = 2.355  # sd to FWHM conversion factor
b1 = (a1 / sdtofwhm) * np.random.randn(1000000)  # generate random numbers with FWHM a1
b2 = (a2 / sdtofwhm) * np.random.randn(1000000)  # generate random numbers with FWHM a2

# create histograms
c1 = plt.hist(b1, bins=np.arange(-plotwidth / 2, plotwidth / 2 + 0.1, 0.1), color='r', alpha=0.0)
c2 = plt.hist(b2, bins=np.arange(-plotwidth / 2, plotwidth / 2 + 0.1, 0.1), color='b', alpha=0.0)
fig = plt.gcf()
fig.set_visible(False)

# normalize
d1 = c1[0] / np.max([c1[0], c2[0]])
d2 = c2[0] / np.max([c1[0], c2[0]])

# moving average filter
d1 = np.convolve(d1, np.ones(5) / 5, mode='same')
d2 = np.convolve(d2, np.ones(5) / 5, mode='same')

# plot simulated axial psf data
fig, axs = plt.subplots(3, 2, figsize=(10, 15))
axs[0, 0].plot(c1[1][:-1], d1, color='r')
axs[0, 0].plot(c2[1][:-1], d2, color='b')
axs[0, 0].set_xlim([-60, 60])
axs[0, 0].set_ylim([0, 1])
axs[0, 0].set_title('axial psf')
axs[0, 0].set_xlabel('μm')
axs[0, 0].set_ylabel('a.u.')
e1 = d1
e2 = d2

# add FWHM to plot
HMe1 = np.max(e1) / 2
HMe2 = np.max(e2) / 2
FWHMwidthe1 = c1[1][np.argmax(e1 > HMe1)] - c1[1][np.argmin(e1 < HMe1)]
FWHMwidthe2 = c2[1][np.argmax(e2 > HMe2)] - c2[1][np.argmin(e2 < HMe2)]
axs[0, 0].plot(c1[1][:-1], np.where(e1 > HMe1, HMe1, np.nan), 'b--')
axs[0, 0].plot(c2[1][:-1], np.where(e2 > HMe2, HMe2, np.nan), 'r--')

for i in range(6):
    cellsize = i*10
    spf = np.zeros(len(c1[1])-1)
    spf[(c1[1][:-1]<(cellsize/2)) & (c1[1][:-1]>-cellsize/2)] = 1
    spf /= spf.sum()

    e1 = np.convolve(d1, spf, mode='same')
    e2 = np.convolve(d2, spf, mode='same')

    #ax = axs[(i+1)//2, (i+1)%2]
    ax = axs[(i)//2, (i)%2]
    ax.plot(c1[1][:-1], e1)
    ax.plot(c2[1][:-1], e2, 'r')
    ax.set_xlim(-60, 60)
    ax.set_ylim(0, 1)

    HMe1 = np.max(e1) / 2
    HMe2 = np.max(e2) / 2
    FWHMwidthe1 = c1[1][np.argmax(e1 > HMe1)] - c1[1][np.argmin(e1 < HMe1)]
    FWHMwidthe2 = c2[1][np.argmax(e2 > HMe2)] - c2[1][np.argmin(e2 < HMe2)]
    
    
    FWHMe1[e1>HMe1] = HMe1
    FWHMe2[e2>HMe2] = HMe2
    ax.plot(c1[1][:-1], np.where(e1 > HMe1, HMe1, np.nan), 'b--')
    ax.plot(c2[1][:-1], np.where(e2 > HMe2, HMe2, np.nan), 'r--')