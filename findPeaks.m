function r_times = findPeaks(corrected, thresh)
samplingrate = 2000;
%   Filter - first pass
WinSize = floor(samplingrate * 571 / 1000);
if rem(WinSize,2) == 0
    WinSize = WinSize+1;
end
filtered1 = ecgdemowinmax(corrected, WinSize);

%   Scale EKG
peaks1 = filtered1/(max(filtered1)/7);

[peaks,~]=findpeaks(peaks1);
mincutoff = mean(peaks)/thresh;
%   Filter by threshold filter
for data = 1:1:length(peaks1)
    if peaks1(data) < mincutoff
        peaks1(data) = 0;
    else
        peaks1(data) = 1;
    end
end
%% Finds the time of each R wave.
r_times = find(peaks1);
r_times = r_times'/2000;
r_times = r_times';