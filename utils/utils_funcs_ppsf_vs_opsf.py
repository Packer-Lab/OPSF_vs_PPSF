import numpy as np
import matplotlib.pyplot as plt

def meanError(arr, axis=0, n=False):
    
    if not n:
        n = arr.shape[0]
    
    mean = np.nanmean(arr, axis)
    std = np.nanstd(arr, axis)
    ci = 1.960 * (std/np.sqrt(n)) # 1.960 is z for 95% confidence interval, standard deviation divided by the sqrt of N samples (# cells)
    sem = std/np.sqrt(n)
    
    return mean, std, ci, sem

def paq_data(paq, chan_name, threshold_ttl=False, plot=False):
    '''
    returns the data in paq (from paq_read) from channel: chan_names
    if threshold_tll: returns sample that trigger occured on
    '''

    chan_idx = paq['chan_names'].index(chan_name)
    data = paq['data'][chan_idx, :]
    if threshold_ttl:
        data = threshold_detect(data, 1)

    if plot:
        if threshold_ttl:
            plt.plot(data, np.ones(len(data)), '.')
        else:
            plt.plot(data)

    return data

def threshold_detect(signal, threshold):
    '''lloyd russell'''
    thresh_signal = signal > threshold
    thresh_signal[1:][thresh_signal[:-1] & thresh_signal[1:]] = False
    times = np.where(thresh_signal)
    return times[0]

def stim_start_frame(paq=None, stim_chan_name=None, frame_clock=None,
                     stim_times=None, plane=0, n_planes=1):
    '''Returns the frames from a frame_clock that a stim occured on.
       Either give paq and stim_chan_name as arugments if using 
       unprocessed paq. 
       Or predigitised frame_clock and stim_times in reference frame
       of that clock
    '''

    if frame_clock is None:
        frame_clock = paq_data(paq, 'frame_clock', threshold_ttl=True)
        stim_times = paq_data(paq, stim_chan_name, threshold_ttl=True)

    stim_times = [stim for stim in stim_times if stim < np.nanmax(frame_clock)]

    frames = []

    for stim in stim_times:
        # the sample time of the frame immediately preceeding stim
#         frame = next(frame_clock[i-1] for i, sample in enumerate(frame_clock[plane::n_planes])
#                      if sample - stim > 0)
        frame = next(i-1 for i, sample in enumerate(frame_clock[plane::n_planes])
                     if sample - stim > 0)
        frames.append(frame)

    return np.array(frames)


def savePlot(save_path):
    '''Save both .png and .svg from a matplotlib plot
    
    Inputs:
        save_path -- path to save plots to
    '''
    plt.savefig(save_path + '.png', bbox_inches='tight')
    plt.savefig(save_path + '.svg', bbox_inches='tight')
    
    
def thresh_signal(signal, threshold, direction='less'):
    
    if direction == 'less':
        thresh_signal = signal < threshold
    elif direction == 'more':
        thresh_signal = signal > threshold
    else:
        raise Exception('ERROR: direction must be less or more')
        
    thresh_signal[1:][thresh_signal[:-1] & thresh_signal[1:]] = False
    times = np.where(thresh_signal)[0]
        
    return times