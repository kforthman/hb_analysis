% Compare ear pulse accross subjects


% get rid of all participants who did not complete the task.
Participants_good = {};
for i = 1:length(Participants)
    i
    sub = Participants{i};
    inDirect = ['/Volumes/labs-1/NPC/Analysis/T1000/data-organized/' sub '/' ses '/behavioral_session/'];
    if exist([inDirect sub '-' ses '-__HC-' rnd '-PHYS.csv'], 'file') == 2
        Participants_good(end+1) = {sub};
    end
end



% run the analysis on all participants
for i = 1:10
    i
    sub = Participants_unrecorded{i};
    inDirect = ['/Volumes/labs-1/NPC/Analysis/T1000/data-organized/' sub '/' ses '/behavioral_session/'];
    if exist([outDirect sub], 'file')==0
        mkdir([outDirect sub])
    end
    main(sub, ses, inDirect, [outDirect sub '/'])
end

% compare time window values across participants
as_timeWindow = [];
for i = 1:length(Participants_good)
    i
    sub = Participants_good{i};
    inDirect = ['/Volumes/labs-1/NPC/Analysis/T1000/data-organized/' sub '/' ses '/behavioral_session/'];
    BEHfilename = [inDirect sub '-' ses '-__BH-' rnd '-_BEH.csv'];
    BEHdata = impBEH_BH(BEHfilename);
    % Find when subject is answering questions
    inst_on = BEHdata.absolute_time(BEHdata.event_code == 4);
    inst_of = BEHdata.absolute_time(BEHdata.event_code == 5);
    time_window = inst_of(1)-inst_on(1);
    as_timeWindow(end+1) = time_window;
end
as_timeWindow = as_timeWindow/60;

% compare PTT values across participants
PTT = {};
for i = 1: 14 %length(Participants_good)
    i
    sub = Participants_unrecorded{i};
    inDirect = ['/Volumes/labs-1/NPC/Analysis/T1000/data-organized/' sub '/' ses '/behavioral_session/'];
    PTT(end+1) = {compareRate(inDirect, outDirect, sub, ses, rnd)};
end
PTT(:,2) = Participants_good(1:length(PTT));
PTT = mat2cell(PTT',150);


for i = 1:14 %length(Participants_good)
    i
    sub = Participants_unrecorded{i};
    inDirect = ['/Volumes/labs-1/NPC/Analysis/T1000/data-organized/' sub '/' ses '/behavioral_session/'];
    compareRate(inDirect, outDirect, sub, ses, rnd);
end


% Plot time window distribution across subjects
figure
hold all
ax = gca;
tick = 0:1:max(as_timeWindow);
ax.XTick = tick;
ax.XMinorTick = 'on';
title('Time Window Distribution')
histogram(as_timeWindow)
scatter(as_timeWindow, 10 + 20 * rand([length(as_timeWindow) 1]),'filled', 'o', 'SizeData',75);
alpha(.3)
avg_as_timeWindow = trimmean(as_timeWindow,10);
verticle(avg_as_timeWindow, 'Color', [0.5 0 0]);
xlabel('time window (minutes)')

% Plot PTT distribution across subjects
figure
hold all
title('PTT Distribution')
histogram(PTT)
scatter(PTT, 10 + 20 * rand([length(PTT) 1]),'filled', 'o', 'SizeData',75);
alpha(.3)
avg_PTT = trimmean(PTT,10);
verticle(avg_PTT, 'Color', [0.5 0 0]);
xlabel('PTT (seconds)')
% Bad: 59

