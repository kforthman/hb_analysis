function [AIC, T, df] = scr_predval(X)
% scr_predval computes evidence for a predictive model - i. e. how well a
% binary target variable (the supposed central state) can be predicted from
% a set of data (e. g. the measured data, or the estimated central state). 
% 
% FORMAT: [AIC, T, df] = scr_predval(X)
%                   
%           with X: a 2-column vector for paired tests, a 2-element cell
%                   array for unpaired tests
%                AIC: computed from RSS of the predictive model
%                T: t-value of the associated t-test
%                df: df of the associated t-test
%__________________________________________________________________________
% PsPM 3.0
% (C) 2010-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_down.m 714 2015-02-05 15:10:44Z tmoser $  
% $Rev: 714 $

global settings;
if isempty(settings), scr_init; end;

% check input arguments
% -------------------------------------------------------------------------

if ~iscell(X)
    if (ndims(X) > 2 || size(X, 2) ~= 2 || numel(X) ~= 2*size(X, 1))
        warning('Input must be a 2-column vector (paired test) or a 2-element cell array (independent test).');
    else 
        paired = 1;
    end;
elseif iscell(X)
    if (numel(X) ~= 2) 
        warning('Input must be a 2-column vector (paired test) or a 2-element cell array (independent test).');
    else
        paired = 0;
    end;
end;

% prepare design matrix
% -------------------------------------------------------------------------

if paired
    nsub = size(X, 1);
    Y = [zeros(nsub, 1); ones(nsub, 1)];
    X = [X(:), [eye(nsub); eye(nsub)]];
    % glmfit adds an intercept
    X(:, end) = [];
    df = nsub - 1;
    n = 2 * nsub;
else
    for k = 1:2
        nsub(k) = numel(X{k});
        X{k} = X{k}(:);
    end;
    Y = [zeros(nsub(1), 1); ones(nsub(2), 1)];
    X = cell2mat(X(:));
    df = sum(nsub(:)) - 1;
    n = sum(nsub(:));
end;

% invert predictive model
% -------------------------------------------------------------------------
[b, dev, stat] = glmfit(X, Y);
T = stat.t(2); % first column is intercept
RSS = sum(stat.resid(:).^2);
AIC = n * log(RSS/n);




