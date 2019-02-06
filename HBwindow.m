function assignedTaps = HBwindow(btime, tap_times)

% Create a three column matrix called windows.
windows = zeros(length(btime),3);

% Make the first column of windows equal to the time of each heartbeat.
for i = 1:length(btime)
    windows(i,1) = btime(i);
end

% Make the second column of windows equal to the midpoint between the
% heartbeat and the one before it (plus 0.2 seconds). Make the third column of windows equal 
% to the midpoint between the heartbeat and the one after it (plus 0.2 seconds).
for i = 2:length(btime)-1
    windows(i,2) = ((btime(i-1) + btime(i))/2) + 0.2;
    windows(i,3) = ((btime(i+1) + btime(i))/2) + 0.2;
end

% Remove the first and last heartbeats from windows.
windows = windows(2:length(windows)-1, :);

% Create a matrix called assignedTaps.
assignedTaps = [];
k=1;

% In the matrix called assignedTaps, place every tap time in the first
% column and the heartbeat it's assigned to in the second.
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

