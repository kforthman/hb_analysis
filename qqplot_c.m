function qqplot_c(data,cdf)

    if ~exist('cdf','var'), cdf=@normcdf; end

    figure();
    hold on

    plot(cumsum(1/length(data)*ones(size(data))),cdf(sort(data)),'bx');
    plot([0,1],[0,1],'r-');

    ylim([0,1]);
    xlim([0,1]);
    xlabel('empirical percentiles');
    ylabel('fit percentiles');

    hold off

end