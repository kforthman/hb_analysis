function vr(xPos,varargin)
% vr Plot a vertical line on a figure
% vr(xPos) plot a vertical line at xPos getting current axis values with
% default color gray, line width 1, and a solid line with no markers
% 
% vr(xPos,varargin) plot a vertical line at xPos getting current axis,
% while varargin takes any plot property as defined in built-in plot
% function.
% 
% Examples
% vr(1)
% vr(0,'r--','LineWidth',2)
% etc.
% 
% Copyright @ Md Shoaibur Rahman (shaoibur@bcm.edu)

if nargin < 2
    varargin{1} = 'Color';
    varargin{2} = [0.5 0.5 0.5];
end

y = get(gca,'YLim');
for k = 1:length(xPos)
    x = [xPos(k) xPos(k)];
    plot(x,y,varargin{1:length(varargin)});
end