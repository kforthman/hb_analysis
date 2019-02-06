%Save plot will set the proper start and end times according to the trial
%given, and save the figure in the proper window.
function savePlot(trial, sub, ses, outDirect)

fileName = [outDirect sub '-' ses '-Trial' num2str(trial)];

if trial == 0
    title([sub ' - Guess'], 'FontSize', 80)
    
elseif trial == 1
    title([sub ' - Tone'], 'FontSize', 80)
    
elseif trial == 2
    title([sub ' - No Guess'], 'FontSize', 80)
    
elseif trial == 3
    title([sub ' - Breath Hold, No Guess'], 'FontSize', 80)
end
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 204 10])
%print(fileName, '-depsc', '-r0')
print(fileName, '-dpng', '-r0')

end
