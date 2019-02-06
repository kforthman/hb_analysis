function nTaps = plotTaps(tap)
    nTaps = 0;
    for i = 1:length(tap)
        verticle(tap{i,1}, 'Color', [0.0784 0.1686 0.5490])
        nTaps = nTaps+1;
    end
end