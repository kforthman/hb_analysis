function outfile = scr_merge(infile1, infile2, reference, options)
% SCR_MERGE merges two SCRalyze datafiles with different channels and
% writes it to a file with the same name as the first file, prepended 'm'. 
% The data is aligned to file start or first marker. Data after the reference
% are extended to the duration of the longer data file
% 
% FORMAT:
% outfile = scr_merge(infile1, infile2, reference, options)
% 
% infile1, infile2: data file name(s) (char, or cell array for multiple
%                   files)
% reference:        'marker' aligns with respect to first marker
%                   'file'   aligns with respect to file start
% options:          
% options.overwrite: overwrite existing files by default
% options.marker_chan_num: 2 marker channel numbers - if undefined 
%                          or 0, first marker channel is used
%                   
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (UZH, WTCN)

% $Id: scr_merge.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise & user output
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
outfile = [];

% check input
% -------------------------------------------------------------------------
% check missing input --
if nargin < 3
    warning('Not enough input'); return; 
end;

% check faulty input --
if ischar(infile1)
    infile1 = {infile1};
elseif ~iscell(infile1)
    warning('Data file names must be strings or cell arrays'); return; 
end;
if ischar(infile2)
    infile2 = {infile2};
elseif ~iscell(infile2)
    warning('Data file names must be strings or cell arrays'); return; 
end;
if numel(infile1) ~= numel(infile2)
    warning('Number of data files does not match'); return; 
end;
infile = {infile1, infile2};
if ~ischar(reference) || ~ismember(reference, {'marker', 'file'})
    warning('Reference must be ''marker'' or ''file''.'); return;
end;

% check options --
try options.overwrite, catch, options(1).overwrite = 0; end;
try options.marker_chan_num, catch, options.marker_chan_num = [0 0]; end;

% loop through data files
% -------------------------------------------------------------------------
for iFile = 1:numel(infile{1})
    % read input files --
    for iNum = 1:2
        [sts, infos{iNum}, data{iNum}] = scr_load_data(infile{iNum}{iFile});
        if sts ~= 1, return; end;
    end;
    % for marker alignment, trim data before first marker --
    if strcmpi(reference, 'marker')
        for iNum = 1:2
            trimdata.data = data{iNum}; trimdata.infos = infos{iNum};
            trimoptions.marker_chan_num = options.marker_chan_num(iNum);
            trimdata = scr_trim(trimdata, 0, 'none', 'marker', trimoptions);
            data{iNum} = trimdata.data; infos{iNum} = trimdata.infos;
        end;
    end;
    % put together and cut away data from the end --
    [sts, data, duration] = scr_align_channels([data{1}; data{2}]);
    if sts ~= 1, return; end;
    % collect infos --
    oldinfos = infos; infos = struct([]);
    infos(1).duration = duration;
    try infos.sourcefile = {oldinfos{1}.importfile; oldinfos{2}.importfile}; end;
    try infos.importfile = {oldinfos{1}.importfile; oldinfos{2}.importfile}; end;
    try infos.importdate = {oldinfos{1}.importdate; oldinfos{2}.importdate}; end;
    try infos.recdate = {oldinfos{1}.recdate; oldinfos{2}.recdate}; end;
    try infos.rectime = {oldinfos{1}.rectime; oldinfos{2}.rectime}; end;
    infos.mergedate = date;
    infos.mergedref = reference;
    % create output file name and save data --
    [pth, fn, ext] = fileparts(infile{1}{iFile});
    outfile{iFile} = fullfile(pth, ['m', fn, ext]);
    infos.mergedfile = outfile{iFile} ;
    outdata.data = data; outdata.infos = infos; outdata.options = options;
    sts = scr_load_data(outfile{iFile}, outdata);
    if sts ~= 1, return; end;
end;

% convert to char if only one file was given
if numel(infile{1}) == 1, outfile = outfile{1}; end;
return;

    




