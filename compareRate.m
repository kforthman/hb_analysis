function ear_r_diff = compareRate(inDirect, outDirect, sub, ses, rnd)
% Only computes PTT if BH file exists.
if exist([inDirect sub '-' ses '-__BH-' rnd '-PHYS.csv'], 'file') == 2
    
    PHYSfilename = [inDirect sub '-' ses '-__BH-' rnd '-PHYS.csv'];
    PHYSdata = importEarPulse(PHYSfilename);
    BEHfilename = [inDirect sub '-' ses '-__BH-' rnd '-_BEH.csv'];
    BEHdata = impBEH_BH(BEHfilename);
    
    % Create a time array
    last = size(PHYSdata,1)/2000;
    time = 0:0.0005:last-.0005;
    time = time';
    
    PHYSdata.time = time;
    
    % Find when subject is given instructions
    inst_on = BEHdata.absolute_time(BEHdata.event_code == 4);
    inst_of = BEHdata.absolute_time(BEHdata.event_code == 5);
    
    if ~isempty(inst_of) && ~isempty(inst_on)
        
        % Narrow PHYS dataset to time during which subject is answering questions.
        PHYSdata = PHYSdata(PHYSdata.time >= inst_on(1) & PHYSdata.time <= inst_of(1), :);
        
        %%
        %         figure
        %         hold all
        %         d_SpO2 = PHYSdata.SpO2(2:end)-PHYSdata.SpO2(1:end-1);
        %         plot(PHYSdata.time(2:end), d_SpO2)
        %         plot(PHYSdata.time, PHYSdata.EarPulse)
        %         plot(PHYSdata.time, PHYSdata.SpO2*.10)
        
        %  % I meant for this to mark the data as 'bad' when there was a large
        %  % change in SpO2, but apparently large changes in SpO2 do not necessarily
        %  % correspond to a noisy pulse signal.
        %         good = zeros(length(d_SpO2)+1,1);
        %         for i = 1:length(d_SpO2)
        %             if (PHYSdata.SpO2(i+1) <= 100) && (d_SpO2(i) >= -0.1) && (d_SpO2(i) <= 0.1)
        %                 good(i+1) = 1;
        %             else
        %                 good(i+1) = 0;
        %             end
        %         end
        
        % Grab data from the longest period of time during instruction where SpO2
        % is less than 100.
        PHYSdata.good = zeros(length(PHYSdata.time),1);
        PHYSdata.good(PHYSdata.SpO2 <= 100) = 1;
        
        if sum(PHYSdata.good)>6000
            windows = zeros(1,3);
            j = 1;
            prev = 0;
            for i = 1:length(PHYSdata.time)
                if isequal(prev, 0) && isequal(PHYSdata.good(i), 1)
                    windows(j, 1) = PHYSdata.time(i);
                    prev = 1;
                elseif isequal(prev, 1) && isequal(PHYSdata.good(i), 1)
                    windows(j, 3) = windows(j, 3)+1;
                    prev = 1;
                elseif isequal(prev, 1) && isequal(PHYSdata.good(i), 0)
                    windows(j, 2) = PHYSdata.time(i-1);
                    prev = 0;
                    j = j+1;
                end
            end
            
            if isequal(windows(end,2),0)
                windows(end,2) = PHYSdata.time(end);
            end
            
            r = find(windows(:,3) == max(windows(:,3)));
            samp_window = windows(r,:);
            
            %         fill([samp_window(1) samp_window(2) samp_window(2) samp_window(1)], ...
            %             [-0.4 -0.4 1.7 1.7], 'g', 'EdgeColor','none');
            %         alpha(0.1);
            %
            %
            %         fileName = [outDirect sub '-' ses '-SpO2'];
            %         set(gcf,'PaperUnits','inches','PaperPosition',[0 0 204 10])
            %         print(fileName, '-dpng', '-r0')
            
            inst_on = samp_window(1);
            inst_of = samp_window(2);
            PHYSdata = PHYSdata(PHYSdata.time >= inst_on(1) & PHYSdata.time <= inst_of(1), :);
            %%
            
            % Filter ear pulse using linear quadratic method
            opol = 50;
            [p,~,mu] = polyfit(PHYSdata.time,PHYSdata.EarPulse,opol);
            f_y = polyval(p,PHYSdata.time,[],mu);
            PHYSdata.correctedEP = PHYSdata.EarPulse - f_y;
            PHYSdata.correctedEP = detrend(PHYSdata.correctedEP);
            
            % Remove lower frequencies of EKG
            Fs = 2000;
            fresult = fft(PHYSdata.EKG);
            fresult(1 : round(length(fresult)*5/Fs)) = 0;
            fresult(end - round(length(fresult)*5/Fs) : end) = 0;
            PHYSdata.correctedEKG = real(ifft(fresult));
            
            % Define peak of r waves and onset of ear pulse.
            r_times = findPeaks(PHYSdata.correctedEKG,2) + PHYSdata.time(1);
            ear_times = findPeaks(-1*PHYSdata.correctedEP,4) + PHYSdata.time(1);
            
            % For each r wave, looks for closest ear pulse that preceeds the following
            % r wave and calculates the difference in time between the two. If there is
            % no ear pulse between the r wave and the next r wave, the difference value
            % is set to 10. All values in the dataset above 9 are then filtered out.
            figure
            title([sub ' - Ear Pulse'], 'FontSize', 80)
            axis([inst_on(1) inst_of(1) -0.5 1])
            hold all
            
            %             ear_r_diff = zeros(length(r_times)-1,3);
            %             for i = 1:length(r_times)-1
            %                 etg = ear_times(ear_times>r_times(i) & r_times(i+1)>ear_times);
            %                 if ~isempty(etg)
            %                     ear_r_diff(i,1) = etg(1) - r_times(i);
            %                     ear_r_diff(i,2) = etg(1);
            %                     ear_r_diff(i,3) = r_times(i);
            %                     plot([r_times(i),etg(1)],[0.5,0.5], 'r', 'LineWidth', 2);
            %                 else
            %                     ear_r_diff(i) = 10;
            %                 end
            %             end
            %             ear_r_diff = ear_r_diff(ear_r_diff(:,1)<9,:);
            
            diff = zeros(length(r_times)-1,1);
            ear_time = zeros(length(r_times)-1,1);
            r_time = zeros(length(r_times)-1,1);
            for i = 1:length(r_times)-1
                etg = ear_times(ear_times>r_times(i) & r_times(i+1)>ear_times);
                if ~isempty(etg)
                    diff(i) = etg(1) - r_times(i);
                    ear_time(i) = etg(1);
                    r_time(i) = r_times(i);
                    plot([r_times(i),etg(1)],[0.5,0.5], 'r', 'LineWidth', 2);
                else
                    diff(i) = -1;
                end
            end
            ear_r_diff = table(r_time, ear_time, diff);
            ear_r_diff(ear_r_diff.diff<0,:) = [];
            
            
            % Average ear pulse is calculated and returned.
            %         avg_ear_r_diff = trimmean(ear_r_diff,10);
            %             ear_r_diff_sorted = sort(ear_r_diff.diff);
            %             med_ear_r_diff = ear_r_diff_sorted(floor(length(ear_r_diff_sorted)/2));
            %             med_ear_r_diff_time = ear_r_diff(abs(ear_r_diff.diff-med_ear_r_diff) < 0.0001,:);
            mean_ear_r_diff = trimmean(ear_r_diff.diff,10);
            sd_ear_r_diff = std(ear_r_diff.diff);
            
            
            ear_r_diff = sortrows(ear_r_diff, 3);
            med_ear_r_diff_time = ear_r_diff(floor(length(ear_r_diff.diff)/2),:);
            med_ear_r_diff = med_ear_r_diff_time.diff(1);
            
            mode_ear_r_diff = mode(round(ear_r_diff.diff,2))
            
            %% The following is for creating a plot of the ear pulse and
            %  marked ear_times.
            
            
            plot(PHYSdata.time, PHYSdata.correctedEKG);
            plot(PHYSdata.time, PHYSdata.correctedEP);
            
            for i = 1:length(r_times)
                verticle(r_times(i), 'Color', 'm');
            end
            for i = 1:length(ear_times)
                verticle(ear_times(i), 'Color', 'r');
            end
            
            verticle(med_ear_r_diff_time.ear_time(1), 'Color', 'r', 'LineWidth', 4)
            verticle(med_ear_r_diff_time.r_time(1), 'Color', 'm', 'LineWidth', 4)
            
            %plot(PHYSdata.time, f_y, 'Color', 'o');
            %plot(PHYSdata.time, PHYSdata.EarPulse, 'Color', 'r');
            %plot(PHYSdata.time, PHYSdata.EKG, 'Color', 'b');
            
            %% Save Plot
            
            fileName = [outDirect sub '-' ses '-EarPulse'];
            set(gcf,'PaperUnits','inches','PaperPosition',[0 0 204 10])
            print(fileName, '-dpng', '-r0')
            
            figure; %fig = figure; set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
            if ~isempty(ear_r_diff)
                Bins = createFit3(ear_r_diff.diff, 'PTT', outDirect, sub, ses);
                Bins = dataset2cell(Bins);
                Bins = Bins(2:end,1:2);
            else
                Bins = [];
            end
            
        else
            med_ear_r_diff = 'NA'; %%%RTK, need to be able to tell which subjects don't have boog PPTs measured
            %avg_ear_r_diff = .2;
            mean_ear_r_diff = 'NA'; 
            mode_ear_r_diff = 'NA'; 
            sd_ear_r_diff = 'NA';
        end
    else
        med_ear_r_diff = 'NA';%%%RTK, need to be able to tell which subjects don't have boog PPTs measured
        %avg_ear_r_diff = .2;
        mean_ear_r_diff = 'NA'; 
        mode_ear_r_diff = 'NA'; 
        sd_ear_r_diff = 'NA';
    end
else
    med_ear_r_diff = 'NA';%%%RTK, need to be able to tell which subjects don't have boog PPTs measured
    %avg_ear_r_diff = .2;
    mean_ear_r_diff = 'NA'; 
    mode_ear_r_diff = 'NA'; 
    sd_ear_r_diff = 'NA';
end
ear_r_diff = [{med_ear_r_diff; mean_ear_r_diff; mode_ear_r_diff; sd_ear_r_diff}];


%% The following commented code creates a histogram of the distribution of
% PTT times for the current subject.
% figure
% hold all
% title(sub)
% histogram(ear_r_diff)
% scatter(ear_r_diff, 3 + 5 * rand([length(ear_r_diff) 1]),'filled', 'o', 'SizeData',75);
% alpha(.3)
% verticle(avg_ear_r_diff, 'Color', [0.5 0 0]);