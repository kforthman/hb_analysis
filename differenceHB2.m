function dif = differenceHB2(t, hbtime, tap, bgnT, endT)
dif = [];
difs = 1;
ploc = 0;

for i = 1:size(tap,1) % Look at every tap.
    
    w = tap{i,1}-hbtime(:); % make a table of the difference between the
    % tap and each recorded heartbeat.
    [~, loc] = min(w(w > 0)); % Note the position off the minimum
    % positive difference.
    if abs(loc-ploc) > 0.01 % If the closest heartbeat is not the same
        % as the last tap's,
        dif(difs,1) = min(w(w > 0)); % the distance is added to the
        % array 'difs'.
        difs = difs + 1;
        ploc = loc;
    end
    
end
end