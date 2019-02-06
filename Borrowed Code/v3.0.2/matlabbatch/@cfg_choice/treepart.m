function tname = treepart(item, dflag)

% function tname = treepart(item, dflag)
% tree part to search - for cfg_repeat/cfg_choice this is val for filled
% cfg_items and values for default cfg_items.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: treepart.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok

if dflag
    tname = 'values';
else
    tname = 'val';
end;
