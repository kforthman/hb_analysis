%% Main Function
%  Requres the input of the subject, session, input directory, 
%  and output directory. 

%  Will generate two graphs for each trial. One graph shows the times of each 
%  tap and heartbeat (or tone). The second shows the normal distributions of 
%       (1) the time (in sec) between each heartbeat (or tone) 
%       (2) the time (in sec) between each tap. 
%       (3) the time (in sec) between each tap and its closest heartbeat 
%           (or tone).
%
%  This function also outputs a table of data for each trial, which 
%  includes accuracy scores.
%       (1) 'stddelay' is the standard deviation of the absolute value of 
%           the time between each tap and its closest heartbeat. 
%       (2)'IbanezAscore' is the mean of the absolute value of the time
%           between each tap and its closest heartbeat.
%       (3)'n_taps' is the number of taps in the trial.
%       (4)'n_tones'is the number of tones in the trial.
%       (5)'n_heartbeats'is the number of heartbeats in the trial.
%       (6)'diffuculty' is the patient's rating of the difficulty of the
%           task
%       (7)'confidence' is the patient's rating of their confidence that
%           they did well performing the task.
%       (8)'intensity' is the patient's rating of how well they felt their
%           heartbeat.
%       
%  Output files:
%   Trial 0 taps and heartbeats:    [outDirect sub '-' ses '-Trial' 0]
%   Trial 1 taps and heartbeats:    [outDirect sub '-' ses '-Trial' 1]
%   Trial 2 taps and heartbeats:    [outDirect sub '-' ses '-Trial' 2]
%   Trial 3 taps and heartbeats:    [outDirect sub '-' ses '-Trial' 3]
%   Trial 0 normal distributions:   [outDirect sub '-' ses '-Trial' 0 '-dist']
%   Trial 1 normal distributions:   [outDirect sub '-' ses '-Trial' 1 '-dist']
%   Trial 2 normal distributions:   [outDirect sub '-' ses '-Trial' 2 '-dist']
%   Trial 3 normal distributions:   [outDirect sub '-' ses '-Trial' 3 '-dist']
%   Data table:                     [outDirect sub '-' ses '-Data.txt']
%
% Katie Clary 11:21AM 6/13/2016

function main(sub, ses, inDirect, outDirect)
%% This reads the data into the program.
%%%RTK edit, try/catch and assign false where values are missing
try
	BEHdataR1 = impBEH(sub, ses, 'R1', inDirect);
catch
	BEHdataR1 = dataset();
    warning('BEH file for R1 not found.')
end

try
	BEHdataR2 = impBEH(sub, ses, 'R2', inDirect);
catch
	BEHdataR2 = dataset();
    warning('BEH file for R2 not found.')
end

try
	EKGR1 = myImportEKG(sub, ses, 'R1', inDirect);
catch
	EKGR1 = false;
    warning('PHYS file for R1 not found.')
end
try
	EKGR2 = myImportEKG(sub, ses, 'R2', inDirect);
catch
	EKGR2 = false;
    warning('PHYS file for R2 not found.')
end

%% Create time array.
lastR1 = size(EKGR1,1)/2000;
timeR1 = 0:0.0005:lastR1-.0005;

lastR2 = size(EKGR2,1)/2000;
timeR2 = 0:0.0005:lastR2-.0005;

%% Create dataset of time v mV
PHYSdataR1 = dataset;
PHYSdataR1.time = timeR1';
PHYSdataR1.mV = EKGR1;

PHYSdataR2 = dataset;
PHYSdataR2.time = timeR2';
PHYSdataR2.mV = EKGR2;

%%% RTK edit, deal with cases where no physio data are available
if EKGR1 == false
	correctedR1 = false;
	r_timesR1 = false;
else
	correctedR1 = filterEKG(PHYSdataR1);
	r_timesR1 = findPeaks(correctedR1,2);
end
if EKGR2 == false
	correctedR2 = false;
	r_timesR2 = false;
else
	correctedR2 = filterEKG(PHYSdataR2);
	r_timesR2 = findPeaks(correctedR2,2);
end

%% Find average PTT
PTT = compareRate(inDirect, outDirect, sub, ses, 'R1');
med_PTT = PTT{1};
mean_PTT = PTT{2};
mode_PTT = PTT{3};
std_PTT = PTT{4};

%%%RTK, need to be able to tell when ptt is not actually measured
if med_PTT == 'NA'
	ptt_to_use = 0.2;
else
	ptt_to_use = med_PTT;
end

%%
a = analyze(0, sub, ses, BEHdataR1, PHYSdataR1, outDirect, r_timesR1, correctedR1, ptt_to_use);
b = analyze(1, sub, ses, BEHdataR1, PHYSdataR1, outDirect, r_timesR1, correctedR1, ptt_to_use);
c = analyze(2, sub, ses, BEHdataR1, PHYSdataR1, outDirect, r_timesR1, correctedR1, ptt_to_use);
d = analyze(3, sub, ses, BEHdataR2, PHYSdataR2, outDirect, r_timesR2, correctedR2, ptt_to_use);

All = [{'median_ptt',med_PTT; 'trim10_mean_ptt', mean_PTT;'mode_ptt',mode_PTT; 'std_ptt', std_PTT};a;b;c;d];
data = dataset(All);%, Number_Taps, Number_Tones, Number_Heartbeats, Accuracy);
%fileName = [outDirect sub '-' ses '-Data.txt'];
fileName = [outDirect sub '-' ses '-Data.longformat']; %%%RTK Edit, rename file so compile script will work (instead of importing to REDCap)
export(data, 'file', fileName,'WriteVarNames',false, 'Delimiter',' ');
end

