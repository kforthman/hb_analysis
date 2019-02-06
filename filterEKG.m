function corrected = filterEKG(PHYSdata)
%% Filter. 
%  Source:
%  http://www.librow.com/cases/case-2

% Number of samples per second
samplingrate = 2000;

% Remove lower frequencies
fresult = fft(PHYSdata.mV);
fresult(1 : round(length(fresult)*5/samplingrate)) = 0;
fresult(end - round(length(fresult)*5/samplingrate) : end) = 0;
corrected=real(ifft(fresult));