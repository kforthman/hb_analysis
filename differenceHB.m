function dif = differenceHB(btime, tap_times, startT, endT)
dif = [];
difs = 1;

for i = 1:size(tap_times,1)
    
    if tap_times{i,1} >= startT{1,2} && tap_times{i,1} <= endT{1,2}
        
        [~,idx] = min(abs(btime(:, 1) - tap_times{i,1})); % finds closest r wave
        % to tap amd returns it's position in the array.
        dif(difs, 1) = tap_times{i,1}-btime(idx); % Finds the difference between
        % the tap time and the time of the closest r wave.
        dif(difs, 2) = tap_times{i,1}; % stores the time of tap next to the
        % previous value.
%         if tap_times{i,1}-btime(idx) < 0
%             if idx > 1
%                 dif(difs,3) = btime(idx-1);
%                 
%             else
%                 dif(difs,:) = [];
%             end
%         else
             dif(difs,3) = btime(idx);
%         end
 difs = difs + 1;
    end
end