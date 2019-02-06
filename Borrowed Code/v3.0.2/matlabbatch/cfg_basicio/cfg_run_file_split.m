function out = cfg_run_file_split(job)

% Split a set of files according to subset indices.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: cfg_run_file_split.m 701 2015-01-22 14:36:13Z tmoser $

rev = '$Rev: 701 $'; %#ok

nosel = true(1,numel(job.files));
for k = 1:numel(job.index)
    idx = job.index{k}(job.index{k}<=numel(job.files));
    nosel(idx) = false;
    out{k} = job.files(idx);
end;
out{k+1} = job.files(nosel);