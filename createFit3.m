function Bins = createFit3(dif2, trial, outDirect, sub, ses)
%CREATEFIT    Create plot of datasets and fits
%   CREATEFIT(DIF2)
%   Creates a plot, similar to the plot in the main distribution fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with dfittool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  0
%
%   See also FITDIST.

% This function was automatically generated on 02-Jun-2016 08:17:49

% Data from dataset "dif2 data":
%    Y = dif2

% Force all inputs to be column vectors
dif2 = dif2(:);

% Prepare figure
clf;
hold on;

t = length(dif2);
axis([-1 1 0 t]);

verticle(mean(dif2), 'r');
verticle(median(dif2), 'blue');
verticle(mode(round(dif2,2)), 'green');
legend('mean','median','mode')


% --- Plot data originally in dataset "dif2 data"
[CdfF,CdfX] = ecdf(dif2,'Function','cdf');  % compute empirical cdf
BinInfo.rule = 5;
BinInfo.width = 0.1;
BinInfo.placementRule = 1;
[~,BinEdge] = internal.stats.histbins(dif2,[],[],BinInfo,CdfF,CdfX);
[BinHeight,BinCenter] = ecdfhist(CdfF,CdfX,'edges',BinEdge);
BinHeight = round((BinHeight/10)*t);
if length(BinEdge)>15
    BinEdge = BinEdge(1:10);
    BinHeight = BinHeight(1:10);
    BinCenter = BinCenter(1:10);
end
hLine = bar(BinCenter,BinHeight,'hist');
set(hLine,'FaceColor','none','EdgeColor',[0.333333 0 0.666667],...
    'LineStyle','-', 'LineWidth',1);
xlabel('Latency(sec)');
ylabel('Count')
if trial == 0
    title('Guess')
    hist_name = ['-Trial' num2str(trial)];
    
elseif trial == 1
    title('Tone')
    hist_name = ['-Trial' num2str(trial)];
    
elseif trial == 2
    title('No Guess')
    hist_name = ['-Trial' num2str(trial)];
    
elseif trial == 3
    title('Breath Hold, No Guess')
    hist_name = ['-Trial' num2str(trial)];
else
    title(trial)
    hist_name = ['-' trial];
end

% Adjust figure
box on;
hold off;

%
Bins = dataset;
n = 1:1:length(BinHeight);
x = cell(length(n), 1);
for i = 1 : length(n)    
    myStr = {['t' num2str(trial) '_hist_bin' num2str(n(1,i))]};
    x(i, 1) = myStr;
end
Bins.n = x;
Bins.height = BinHeight';

dif2sorted = sort(dif2);
hold on
scatter(dif2sorted, 0.5 + 1 * rand([length(dif2) 1]),'filled', 'o', 'SizeData',75)
hold off
alpha(.3)
text(-0.8,t-t/10,['Kolmogorov-Smirnov Test Result: ' num2str(kstest(dif2))])
% Create legend from accumulated handles and labels
% hLegend = legend(LegHandles,LegText,'Orientation', 'vertical', 'FontSize', 9, 'Location', 'northeast');
% set(hLegend,'Interpreter','none');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 10])
fileName = [outDirect sub '-' ses hist_name '-dist'];
print(fileName, '-dpng', '-r0');







