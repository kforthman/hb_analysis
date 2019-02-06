## First-level analysis of the heartbeat tapping test:

The main function of the program is called ‘main.m’. This function requires an input of the subject ID, session number, the input directory of the physio and behavioral data, and the desired output directory (in that order).

The main function first imports the behavioral data and the EKG data from the physio file for R1 and R2. Main then calls ‘filterEKG.m’ and ‘findPeaks’ to filter the EKG data. FilterEKG.m removes the lower frequencies using a fast Fourier transform. After the EKG is converted to the frequency domain, the first and last n values in the transformed array are set to zero, where 
	
	n = [number of values in array]*5 / 2000

and n is rounded to the nearest whole number. The array is then converted back to the time domain, and returned to the main function.

The returned array is named ‘corrected’. The main function then calls ‘findPeaks.m’ to find the peaks of the filtered array. FindPeaks uses a windowed filter with a default window size equal to floor[samplingrate * 571 / 1000] to find local maxima. A threshold filter using a minimum cutoff of mean[peaks]/2 is then used to preserve significant maxima.

Main then calls the function ‘analyze.m’ four times, once for each trial. Analyze will return a dataset for each trial. Main combines the datasets returned by analyze, and then exports the combined dataset as a single text file to the output directory.

The analyze function first extracts tap times from the BEH data and organizes them into a dataset. If the trial was a tone trial, tone times are also extracted from the BEH data. If the trial is not a tone trial, R-wave times are pulled from the output of the findPeaks function that was called in main. Pulse times are set to be equal to each R-wave + 200 ms. Analyze then assigns each tap to the pulse/tone it was most likely in response to. Analyze does this by creating windows in the neighborhood of each pulse/tone, and assigning taps to the pulse/tone whose window it resides in. The edges of each window are equal to the midpoint between subsequent pulses/tones. After assigning each tap to a tone or pulse, latency values are calculated as 

	[tap time] - [pulse/tone time].

The analyze function outputs three graphs for each trial. 
* One will depict the timeline of the trial, showing each instance where a tap, tone, or heartbeat was recorded. This graph will also depict the windows surrounding each tone/heartbeat and a red line which connects each tap to the heartbeat it is assigned to representing the latency.
* Tap latencies are then arranged into a histogram with bins for every 100 ms. Transparent dots representing each individual latency time are plotted in order to better represent the distribution of tap latency times.
* A quantile-quantile(QQ) plot is created in order to show how well latencies follow a normal distribution. The better the blue points fit the red line, the better latency times follow a normal distribution.

There are three text files created for each file in addition to one text file created by the main file. The three text files created for each trial list (1) the width of each window, (2) the latency value, and (3)the distance between each heartbeat and the closest tap that comes after it (an old latency measure). The final text file includes the following values for each trial: number of taps, number of tones, number of r waves, average latency, standard deviation of latency, variance of latency, the chi goodness of fit (gof) value, the chi gof p value, the Ibanez accuracy score, and participants’ ratings of difficulty, confidence, and intensity.
