%% Analyze heartbeat tapping data.
% ---------------------------------------------------------------------------------------------
%
%  Requres input of trial number (trial), subject ID (sub), session number
%  (ses), input file directory (inDirect), and output file directory
%  (outDirect). Will export to given file directory:
%    (1) a graph for each trial, depicting blue lines where patient tapped,
%    red lines at each 200ms after each heartbeat, and green lines at each
%    tone played. 
%    (2) Will also export a data file which lists number of
%    taps, number of tones, number of heartbeats, the average latency, the
%    standard deviation of the latencies, the variance of latencies, the
%    result of a chi squared goodness of fit test and the p value, the
%    accuracy score as described in a paper by Ibanez et al, as well as the
%    participant ratings of difficulty, their confidence that they did
%    well, and the intensity at which they felt their heartbeat. This data
%    is given for each individual trial.
%    (3) Exports a qq plot of the latency data.
%    (4) Exports a histogram of the latency data.
%
% Created by Katie Clary
%
% ---------------------------------------------------------------------------------------------

function All = analyze(trial, sub, ses, BEHdata, PHYSdata, outDirect, r_times, corrected, PTT)

%%%RTK Edit, deal with cases where no data available (e.g. only one trial done)
if isempty(BEHdata)
	All = {};
    warning(['No data available for trial ' num2str(trial) '.'])
	return
end

%% Set beginning and end time for each trial.
startT = BEHdata{BEHdata.event_code == 4 & BEHdata.trial_type == trial, {'absolute_time'}};
endT  = BEHdata{BEHdata.event_code == 8 & BEHdata.trial_type == trial, {'absolute_time'}};
%%%RTK Edit, deal with cases where subject didn't complete this trial
if length(endT) == 0
	All = {};
    warning(['Subject did not complete trial ' num2str(trial) '.'])
	return
end

%% Read difficulty, confidence, and intensity.
% Stores values patients have given for the difficulty of the task, their
% confidence in their accuracy, and how intensely they felt their
% heartbeat.
difficulty = BEHdata(BEHdata.result == 'How difficult was the previous task?' ...
    & BEHdata.trial_type == trial, {'trial_type','response'});
confidence = BEHdata(BEHdata.result == 'How accurate was your performance?' ...
    & BEHdata.trial_type == trial, {'trial_type','response'});
confidence = [confidence; BEHdata(BEHdata.result == ...
    'How accurate do you believe your performance was?' & BEHdata.trial_type == trial, ...
    {'trial_type','response'})];
if trial ~= 1
    intensity = BEHdata(BEHdata.result == 'How intensely did you feel your heartbeat?' ...
        & BEHdata.trial_type == trial, {'trial_type','response'});
else
    intensity = BEHdata(BEHdata.result == 'How intensely did you hear the tone?' ...
        & BEHdata.trial_type == trial, {'trial_type','response'});
end

% If no response was given, the value is set as 'NA'.
if isempty(difficulty)
    difficulty = {'trial_type','response'; trial, 'NA'};
    difficulty = cell2dataset(difficulty);
end
if isempty(confidence)
    confidence = {'trial_type','response'; trial, 'NA'};
    confidence = cell2dataset(confidence);
end
if isempty(intensity)
    intensity = {'trial_type','response'; trial, 'NA'};
    intensity = cell2dataset(intensity);
end

%% Define the axis for the main graph
fig = figure; 
%set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]); %Displays figure
%in full sized window.
hold all;

% Name axis.
ylabel('Volts (mV)', 'FontSize', 60)
xlabel('Time (s)', 'FontSize', 60)

% Define span of axis
axis([startT endT -0.4 1.7])

% Define ticks.
ax = gca;
tick = 0:10:max(PHYSdata.time);
ax.XTick = tick;
ax.TickLength = [0.005 0.001];
ax.XMinorTick = 'on';
tick = -10:0.5:10;
ax.YTick = tick;
ax.FontSize = 20;

%% Define and create legend.
if trial == 1
    verticle(-1, 'b', 'LineWidth', 1);
    verticle(-1, 'g', 'LineWidth', 1);
    legend({'Tap', 'Tone'}, 'Orientation', 'vertical', 'FontSize', 4, 'Location', ...
        'eastoutside');
else
    verticle(-1, 'b', 'LineWidth', 1);
    verticle(-1, 'r', 'LineWidth', 1);
    verticle(-1, 'k', 'LineWidth', 1);
    legend({'Tap', '200ms after R-wave', 'EKG'}, 'Orientation', 'vertical', ...
        'FontSize', 4, 'Location', 'eastoutside');
end

%% Plots lines at time of each tap.
% Also counts number of taps in each trial and assigns the value to
% nTapsTx.

tap_times = BEHdata(BEHdata.event_code == 6 & BEHdata.trial_type == trial, {'absolute_time'});

% If you would like to test how random taps compare to the participant's:
% tap_times.absolute_time = startT.absolute_time + (endT.absolute_time - startT.absolute_time)...
%     * rand(length(tap_times), 1);


for i = 1:length(tap_times)
    verticle(tap_times{i,1}, 'Color', 'b', 'LineWidth', 1)
end
nTaps = length(tap_times);

%% Plots lines at time of each tone. Counts number of tones.
if trial == 1
    tone_times = BEHdata(BEHdata.event_code == 5 & BEHdata.trial_type == trial, {'absolute_time'});
    
    nTones = length(tone_times);
    for i = 1:nTones
        verticle(tone_times{i, 1}, 'Color',  'g', 'LineWidth', 1)
    end
    
    % convert tone_times to matrix for export.
    tone_times = dataset2cell(tone_times);
    tone_times = cell2mat(tone_times(2:end,1));
end

%% Plots lines at avg PTT after each heartbeat, given the heartbeat is during a trial.
r_times = r_times(startT <= r_times & r_times <= endT);

if trial ~= 1
    for i = 1:length(r_times)
        %verticle(r_times(i), 'Color',[0.85 0.7 0], 'LineWidth', 1); %plots yellow
        %lines at r waves.
        %verticle(r_times(i)+0.2, 'r', 'LineWidth', 1);
        verticle(r_times(i)+PTT, 'r', 'LineWidth', 1);
    end
    nTones = 'NA';
end

nR = length(r_times);

%% Finds the difference between each tap and the heartbeat who's window the tap resides in.
if trial ~= 1
    marker_times = r_times;
else
    marker_times = tone_times;
end
% Create a three column matrix called windows.
windows = zeros(length(marker_times),3);

% Make the first column of windows equal to the time of each heartbeat/tone.
for i = 1:length(marker_times)
    windows(i,1) = marker_times(i);
end

% Make the second column of windows equal to the midpoint between the
% marker and the one before it. Make the third column of windows equal
% to the midpoint between the marker and the one after it.
for i = 2:length(marker_times)-1
    windows(i,2) = ((marker_times(i-1) + marker_times(i))/2);
    windows(i,3) = ((marker_times(i+1) + marker_times(i))/2);
end

% If the trial is not a tone trial, shift the windows to the right by
% subject average PTT.
if trial ~= 1
    windows(:,1) =  windows(:,1)+ PTT;
    windows(:,2) =  windows(:,2)+ PTT;
    windows(:,3) =  windows(:,3)+ PTT;
end

% Remove the first and last markers from windows.
%%%RTK edit, take care of cases where very few windows are identified (i.e. bc of bad EKG)
if length(windows) > 4
   windows = windows(2:length(windows)-1, :);
else
   windows = [];
   warning('Few windows identified, potentially poor EKG')
end

% Create a matrix called assignedTaps.
assignedTaps = [];
k=1;

% In the matrix called assignedTaps, place every tap time in the first
% column and the marker it's assigned to in the second. There is currently
% a possibility that the first and last one or two taps may not be assigned
% to any marker, since there is no window defined at the start and end
% of each trial. Also, note that two or more taps can be assigned to the same
% marker.
for i = 1:length(windows)
    tw = tap_times(tap_times.absolute_time > windows(i,2) ...
        & tap_times.absolute_time <= windows(i,3), {'absolute_time'});
    
    if ~isempty(tw)
        for j = 1:length(tw)
            assignedTaps(k,1) = tw{j,1};
            assignedTaps(k,2) = windows(i,1);
            k = k+1;
        end
    end
    
end


% The matrix tap_latencies is the time of each tap minus the
% marker it's assigned to.
if ~isempty(assignedTaps)
    tap_latencies = assignedTaps(:,1) - assignedTaps(:,2);
else
    tap_latencies = [];
end

% Create shaded areas of the graph to show windows.
if trial ~= 1
    for i = 1:2:length(windows)
         fill([windows(i,2) windows(i,3) windows(i,3) windows(i,2)], ...
             [-0.4 -0.4 1.7 1.7], 'r', 'EdgeColor','none');
         alpha(0.1);
    end
else
    for i = 1:2:length(windows)
        fill([windows(i,2) windows(i,3) windows(i,3) windows(i,2)], ...
            [-0.4 -0.4 1.7 1.7], 'g', 'EdgeColor','none');
        alpha(0.1);
    end    
end
%% OLD METHOD: Finds the difference between each tap and the closest heartbeat/tone
%  that comes before it.

if (trial~=1)
    tap_latencies_2 = differenceHB2(trial, r_times, tap_times, startT, endT);
else
    tap_latencies_2 = differenceHB2(trial, tone_times, tap_times, startT, endT);
end

%% Find the standard statistics of the tap latencies

if ~isempty(tap_latencies)
    avg_latency = mean(tap_latencies);
    std_latency = std(tap_latencies);
    var_latency = var(tap_latencies);
    IbanezAscore = mean(abs(tap_latencies))/nTaps;
else
    std_latency = 'NA';
    var_latency = 'NA';
    avg_latency = 'NA';
    IbanezAscore = 'NA';
end

%% Finishes and exports a plot for each trial. Draws line between each assigned tap and the 
%  marker it is assigned to. Also plots the EKG on top of event markers for non-tone trials.
if ~isempty(tap_latencies)
    for i = 1:length(tap_latencies)
        plot(assignedTaps(i,1:2),[1,1], 'r', 'LineWidth', 3);
    end
end

%%%RTK edit, plot EKG for all trials (since we get HR for tone trial as well)
%if trial ~= 1
    plot(PHYSdata.time, corrected, 'black', 'LineWidth', 1); %Plot EKG to time.
%end

savePlot(trial, sub, ses, outDirect)

%%
if ~isempty(tap_latencies)
figure;
plot(assignedTaps(:,2), tap_latencies, 'r-o');
axis([startT endT -1.5 1.5])
title([sub ' - t' num2str(trial) ' - Reaction Time']);
xlabel('Time of stimulus (s)');
ylabel('Reaction time (s)');
fileName = [outDirect sub '-' ses '-t' num2str(trial) '-ReactTimeplot'];
%set(gcf,'PaperUnits','inches','PaperPosition',[0 0 204 10]);
print(fileName, '-dpng', '-r0')
end

%% Calculates BPM.
%bpm = (nR*60) / (endT - startT)

%% Creates a histogram of tap latencies.
figure; %fig = figure; set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
if ~isempty(tap_latencies)
    Bins = createFit3(tap_latencies, trial, outDirect, sub, ses);
    Bins = dataset2cell(Bins);
    Bins = Bins(2:end,1:2);
else
    Bins = [];
end

%% Creates a QQ plot
figure;
if ~isempty(tap_latencies)
    qqplot(tap_latencies);
    
    % Export plot.
    fileName = [outDirect sub '-' ses '-t' num2str(trial) '-QQplot'];
    set(gcf,'PaperUnits','inches','PaperPosition',[0 0 20 20])
    print(fileName, '-dpng', '-r0')
end

%% Create three text files.
% > "LatencyDataWindow.txt" holds the tap latiencies calculated using the
% R wave window method.
% > "Windows" lists the windows used to assign taps to
% a certain R wave.
% > "LatencyDataClosestAfter" lists the latencies
% calculated using the method that finds the closest tap following each
% R wave.

fileName = [outDirect sub '-' ses '-t' num2str(trial) '-LatencyDataWindow.txt'];
if ~isempty(tap_latencies)
    data = dataset(tap_latencies(:,1));
    export(data, 'file', fileName,'WriteVarNames',false, 'Delimiter',' ');
else
    %%%RTK, create an empty file if there were no taps
    fclose(fopen(fileName, 'w'));
end

fileName = [outDirect sub '-' ses '-t' num2str(trial) '-Windows.txt'];
if ~isempty(windows)
    data = dataset(windows(:,3)-windows(:,2));
    export(data, 'file', fileName,'WriteVarNames',false, 'Delimiter',' ');
else
    %%%RTK, create an empty file if there were no taps
    fclose(fopen(fileName, 'w'));
end

fileName = [outDirect sub '-' ses '-t' num2str(trial) '-LatencyDataClosestAfter.txt'];
if ~isempty(tap_latencies_2)
    data = dataset(tap_latencies_2);
    export(data, 'file', fileName,'WriteVarNames',false, 'Delimiter',' ');
else
    %%%RTK, create an empty file if there were no taps
    fclose(fopen(fileName, 'w'));
end

%% Calculates the chi squared goodness of fit statistic.
% Null hypothesis is that the distribution is flat. chi_gof will be 1 if
% the null hypothesis is rejected. chi_gof will be 0 if the null hypothesis
% is not rejected.

if ~isempty(tap_latencies)
    nbins = 10; % number of bins
    edges = linspace(-1,1,nbins+1); % edges of the bins
    E = length(tap_latencies(:,1))/nbins*ones(nbins,1); % expected value (equal for uniform dist)
    [h,p,~] = chi2gof(tap_latencies(:,1),'Expected',E,'Edges',edges, 'Alpha', 0.05);
else
    h = 'NA';
    p = 'NA';
end

%% Exports data.
All = {
    ['t' num2str(trial) '_n_taps'], nTaps;
    ['t' num2str(trial) '_n_tones'], nTones;
    ['t' num2str(trial) '_n_heartbeats'], nR;
    ['t' num2str(trial) '_avgdelay'],avg_latency;
    ['t' num2str(trial) '_stddelay'], std_latency;
    ['t' num2str(trial) '_vardelay'], var_latency;
    ['t' num2str(trial) '_chi_gof' ], h;
    ['t' num2str(trial) '_chi_pval' ], p;
    ['t' num2str(trial) '_IbanezAscore'], IbanezAscore;
    ['t' num2str(trial) '_difficulty'], difficulty{1, 2};
    ['t' num2str(trial) '_confidence'], confidence{1,2};
    ['t' num2str(trial) '_intensity' ], intensity{1,2} };
%All = [All; Bins];
%%%RTK Edit, ignore Bins
All = [All];
