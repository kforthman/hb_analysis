%% Analyze baseline data
% Reference, used for heart rate variability calculations:
% http://circ.ahajournals.org/content/93/5/1043.full

function hrv_hb(inDirect, outDirect, sub, ses)
%% Import data.
BEHfilename = [inDirect sub '-' ses '-__HB-R1-_BEH.csv'];
BEHdata = impBEH(BEHfilename);
BEHdata = table2dataset(BEHdata);

PHYSfilename = [inDirect sub '-' ses '-__HB-R1-PHYS.csv'];
PHYSdata = importPHYS(PHYSfilename);
PHYSdata = table2dataset(PHYSdata);



%% Create time array to accompany PHYS data.
last = size(PHYSdata,1)/2000;
time = 0:0.0005:last-.0005;
PHYSdata.time = time';

%% Find start and end times of each trial.
% startT is a dataset. In column 1 is the number of the trial, and
% in column 2 is the absolute time of the start of the trial.
startT = BEHdata(BEHdata.event_code == 2, {'trial_number', 'absolute_time'});

%imgT = BEHdata(BEHdata.event_code == 3, {'trial_number', 'absolute_time'});


%%  Find the heartbeat data between the start time and 300 seconds after 
%   the start time.
hr = PHYSdata(PHYSdata.time >= startT{1,2} & PHYSdata.time <= startT{1,2} + 300, {'time', 'HR', 'EKG'});

%% Filter. 
%  Source:
%  http://www.librow.com/cases/case-2

samplingrate = 2000;

% Remove lower frequencies
fresult = fft(PHYSdata.EKG);
fresult(1 : round(length(fresult)*5/samplingrate)) = 0;
fresult(end - round(length(fresult)*5/samplingrate) : end) = 0;
corrected=real(ifft(fresult));

%   Filter - first pass
WinSize = floor(samplingrate * 571 / 1000);
if rem(WinSize,2) == 0
    WinSize = WinSize+1;
end
filtered1 = ecgdemowinmax(corrected, WinSize);

%   Scale EKG
peaks1 = filtered1/(max(filtered1)/7);

[peaks,~]=findpeaks(peaks1);
mincutoff = 3*mean(peaks)/4;
%   Filter by threshold filter
for data = 1:1:length(peaks1)
    if peaks1(data) < mincutoff
        peaks1(data) = 0;
    else
        peaks1(data) = 1;
    end
end
rtime = find(peaks1);
rtime = rtime'/2000;
rtime = rtime(rtime>startT.absolute_time & rtime<startT.absolute_time+300);
% if length(positions) > 1
%      distance = min(positions(2:end)-positions(1:end-1))
%     % Optimize filter window size
%     QRdistance = floor(0.04*samplingrate);
%     if rem(QRdistance,2) == 0
%         QRdistance = QRdistance+1;
%     end
%     WinSize = 2*distance - QRdistance;
%     
%     % Filter - second pass
%     filtered2 = ecgdemowinmax(corrected, WinSize);
% else
%     filtered2 = filtered1;
% end



%% Find the peak of the r wave of each heartbeat.
%   The r wave is determined by (1) the width of the wave. The wave must
%   not exceed 0.025 seconds from valley to valley. (2) Prominence. 

%[~,rtime] = findpeaks(filtered1,PHYSdata.time);

%  y = abs(hr.EKG).^2;
% [~,rtime] = findpeaks(y,hr.time, 'MaxPeakWidth', 0.025,...
%      'MinPeakProminence', 0.14,'MinPeakDistance', 0.4);

%% Find the number seconds between each heartbeat.
rint = zeros(size(rtime,1)-1, 1);
for i = 1:size(rtime,1)-1
   
    rint(i, 1) = rtime(i+1,1)-rtime(i,1);
   
end

cutoff2 = mean(rint)-2*std(rint);
rint = rint(rint>cutoff2);
%% Find the time difference between each subsequent r interval.
rintdiff = zeros(size(rint,1)-1, 1);
for i = 1:size(rint,1)-1
   
    rintdiff(i, 1) = rint(i+1,1)-rint(i,1);
   
end

%% Define variables for legend.
% LegHandles = []; 
% LegText = {};

%% Plot lines and create legend tags.
fig = figure;
set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
%
ratP = subplot(6, 1, [1 2]);

cla
hold all

title([sub ' - PB Data']) 

axis([0 max(PHYSdata.time) -10 150]) 

ylim([min(PHYSdata.RR)-10, max(PHYSdata.HR)+10]);

ratP.XGrid = 'on';      
ratP.XMinorGrid = 'on';
ratP.YGrid = 'on';
ratP.XMinorTick = 'on';

ratP.XMinorTick = 'on';

tick = round(min(PHYSdata.RR)-10, -1):10:round(max(PHYSdata.HR)+10, -1);
ratP.YTick = tick;

tick = 0:50:max(PHYSdata.time);
ratP.XTick = tick;

ratP.TickLength = [0.005 0.001];

ylabel('Rate (per minute)')

plot(PHYSdata.time, PHYSdata.HR, 'Color', [.7,0.2,0.4], 'LineWidth', 2); %Plot heart rate to time.
% LegHandles(end+1) = hLine;
% LegText{end+1} = 'HR';

plot(PHYSdata.time, PHYSdata.RR, 'Color', [0.3,0,0.7], 'LineWidth', 2); %Plot respiration to time.
% LegHandles(end+1) = hLine;
% LegText{end+1} = 'RR';

verticle(startT{1,2},'g');
% LegHandles(end+1) = hLine;
% LegText{end+1} = 'START';

legend({'Heart Rate', 'Respiration Rate'}, 'Orientation', 'vertical', 'FontSize', 4, 'Location', 'southoutside');

%
edaP = subplot(6,1,[3 4]);

cla
hold all

axis([0 max(PHYSdata.time) 0 15]) 

ylim([min(PHYSdata.EDA)-1, max(PHYSdata.EDA)+1]);

tick = round(min(PHYSdata.EDA)-1):0.5:round(max(PHYSdata.EDA)+1);
edaP.YTick = tick;

tick = 0:50:max(PHYSdata.time);
edaP.XTick = tick;

edaP.TickLength = [0.005 0.001];

edaP.XGrid = 'on'; 
edaP.XMinorGrid = 'on';
edaP.YGrid = 'on';
edaP.XMinorTick = 'on';

ylabel('Microsiemens')

plot(PHYSdata.time, PHYSdata.EDA,  'Color', [0,0.3,0.7], 'LineWidth', 1); %Plot EDA to time.
% LegHandles(end+1) = hLine;
% LegText{end+1} = 'EDA';

verticle(startT{1,2}, 'g');

legend({'EDA'}, 'Orientation', 'vertical', 'FontSize', 4, 'Location', 'southoutside');


%
ekgP = subplot(6,1,6);

cla
hold all

axis([0 max(PHYSdata.time) -1 3]) 

ylim([min(corrected)-1, max(corrected)+1]);

tick = round(min(corrected)-1):0.5:round(max(corrected)+1);
ekgP.YTick = tick;

tick = 0:50:max(PHYSdata.time);
ekgP.XTick = tick;

ekgP.TickLength = [0.005 0.001];

ekgP.XMinorTick = 'on';
ekgP.XGrid = 'on';     
ekgP.XMinorGrid = 'on';
ekgP.YGrid = 'on';

ylabel('mV')

plot(PHYSdata.time, corrected, 'Color', [.7,0.2,0.4], 'LineWidth', 0.1); %Plot EKG to time.
% LegHandles(end+1) = hLine;
% LegText{end+1} = 'EKG';

verticle(startT{1,2}, 'g');

legend({'EKG', 'Trial Start'}, 'Orientation', 'vertical', 'FontSize', 4, 'Location', 'southoutside');


%
rspP = subplot(6,1,5);

cla
hold all

axis([0 max(PHYSdata.time) 0 10]) 

tick = round(min(PHYSdata.RSP)-1):2:round(max(PHYSdata.RSP)+1);
rspP.YTick = tick;

tick = 0:50:max(PHYSdata.time);
rspP.XTick = tick;

rspP.TickLength = [0.005 0.001];

ylim([min(PHYSdata.RSP)-1, max(PHYSdata.RSP)+1]);

rspP.XMinorTick = 'on';
rspP.XGrid = 'on';    
rspP.XMinorGrid = 'on';
rspP.YGrid = 'on';

xlabel('Time (s)')
ylabel('Volts')

plot(PHYSdata.time, PHYSdata.RSP, 'Color', [0.3,0,0.7], 'LineWidth', 0.3); %Plot respiration to time.
% LegHandles(end+1) = hLine;
% LegText{end+1} = 'RSP';

verticle(startT{1,2}, 'g');

legend({'Respiration Belt'}, 'Orientation', 'vertical', 'FontSize', 4, 'Location', 'southoutside');


%% Plot time at which image was displayed.
% % Start.
% hLine = verticle(imgT{1,2}, 'b', 'LineWidth', 0.1);
% LegHandles(end+1) = hLine;
% LegText{end+1} = 'START';
% 
% for i = 2:size(imgT,1)
%     verticle(imgT{i,2}, 'b', 'LineWidth', 0.1);
% end


%% Export plot.
fileName = [outDirect sub '-' ses '-PBplot'];         
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 max(PHYSdata.time)/2 100]);
print(fileName, '-dpng', '-r0');

%% HR per beat Plot
% Determine the RR intervals
RLocsInterval = diff(rtime);

% Derive the HRV signal
tHRV = rtime(2:end);
HRV = 1./RLocsInterval;

% Plot the signals
fig = figure;
set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
a1 = subplot(2,1,1);
hold all;
axis([min(rtime) max(rtime) -1 3]) 

for i = 1:size(rtime,1)
    
        verticle(rtime(i), 'red', 'LineWidth', 0.0625);
        
end

plot(PHYSdata.time,corrected,'b', 'LineWidth', 0.125);

grid

a2 = subplot(2,1,2);
plot(tHRV,HRV)
axis([min(rtime) max(rtime) -1 3]) 
grid
xlabel(a2,'Time(s)')
ylabel(a1,'EKG (mV)')
ylabel(a2,'HRV (Hz)')

%% Export plot.
title([sub ' - Heart Rate'])
fileName = [outDirect sub '-' ses '-PBhrplot'];         
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 100 15])
print(fileName, '-dpng', '-r0')

%% Histogram
fig = figure;
set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
hist(RLocsInterval)

grid
xlabel('Sampling interval (s)')
ylabel('RR distribution')

%% Lomb Scargle
fig = figure;
set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
hold all
verticle(40);
verticle(150);
plomb(HRV,tHRV, 'Pd', 0.95);



% xlim([0, 0.4]);
% xlabel('Frequency (Hz)')
% ylabel('PSD')
%% Export plot.
fileName = [outDirect sub '-' ses '-PBlombplot'];         
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 30 15]);
print(fileName, '-dpng', '-r0');


%% Power Spectral Density
fig = figure;
set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
hold all
Pfa = [10 5 1 0.01]/100;
Pd = 1-Pfa;
[P,F,PTH] = plomb(HRV,tHRV, 'Pd',Pd);
[pk,f0] = findpeaks(P, F, 'MinPeakHeight', PTH(1));
% psdPlot = plot(F, P);
axis([0 0.4 0 round(max(P)+0.05,1)])
plot(F, P, f0, pk, 'o')
xlim([0, 0.4]);
plot([0, 400], [PTH, PTH]);
text(0.3*[1 1 1 1], PTH,[repmat('P = ',[4 1]) num2str(Pfa')]);
verticle(0.04);
verticle(0.15);
xlabel('Frequency (Hz)');
ylabel('PSD');

% f0 = f0*1000;
% psd1 = mat2dataset([F,P]);
% psd2 = psd1(psd1.Var2 >= PTH, {'Var1','Var2'});

%% Export plot.
title([sub ' - PB PSD'])
fileName = [outDirect sub '-' ses '-PBpsdplot'];         
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 30 15]);
print(fileName, '-dpng', '-r0');

%%
p_freq = table;
p_freq.F = F;
p_freq.P = P;

%% Create a table of data.
outData = {'start_time', startT{1,2};
            'avg_hr', mean(hr.HR);
            'n_rint', size(rint,1);
            'duration',  PHYSdata.time(end) - startT{1,2};
            'max_rint', max(rint);
            'min_rint', min(rint);
            'diff_max_min', max(rint)-min(rint);
            'sdnn', std(rint);
            'rmssd_msec', sqrt(mean(rintdiff.^2))*1000;
            'nn50', sum(rintdiff > .05);
            'pnn50', sum(rintdiff > .05)/size(rintdiff, 1)
            'var_hrv', var(HRV);
            'integral_psd', trapz(p_freq{F>0 & F<0.4, {'F'}}, p_freq{F>0 & F<0.4, {'P'}});
            'power_vlf', trapz(p_freq{F>0 & F<.04, {'F'}}, p_freq{F>0 & F<.04, {'P'}});
            'power_lf', trapz(p_freq{F>0.04 & F<0.2, {'F'}}, p_freq{F>0.04 & F<0.2, {'P'}});
            'power_hf', trapz(p_freq{F>0.2 & F<0.4, {'F'}}, p_freq{F>0.2 & F<0.4, {'P'}});
            };
data = dataset(outData);

%% Export data.
fileName = [outDirect sub '-' ses '-PBdata.txt'];
export(data, 'file', fileName,'WriteVarNames',false, 'Delimiter',' ');
