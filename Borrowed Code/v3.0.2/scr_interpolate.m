function [newdatafile] = scr_interpolate(datafile, options)
% SCR_INTERPOLATE interpolates an SCR dataset and 
% writes it to a file with a prepended 'i'

%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id: scr_interpolate.m 24 2015-03-19 14:09:41Z tmoser $
% $Rev: 24 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
newdatafile = [];

% check input arguments
% -------------------------------------------------------------------------
if nargin<1
    warning('ID:invalid_input', 'No data.\n'); 
    return;
end;

% set options ---
try
    options.overwrite; 
catch
    options.overwrite = 0;
end;

% check data file argument --
if ischar(datafile) || isstruct(datafile)
    D = {datafile};
elseif iscell(datafile) 
    D = datafile;
else
    warning('Data file must be a char, cell, or struct.');
end;
clear datafile

% work on all data files
% -------------------------------------------------------------------------
for d=1:numel(D)
    % determine file names ---
    datafile=D{d};
        
    % user output ---
    if isstruct(datafile)
        fprintf('Interpolating ... ');
    else
        fprintf('Interpolating %s ... ', datafile);
    end;
    
    % check and get datafile ---
    [sts, infos, data] = scr_load_data(datafile, 0);
    if any(sts == -1)
        newdatafile = []; 
        break; 
    end;
    
    % trim file ---
    for k = 1:numel(data)
        
        % only interpolate waveform channels
        if ~strcmpi(data{k}.header.units, 'events') 
            
            dat = data{k}.data;
            x = 1:length(dat);
            v = dat;
            xq = find(v == 0);
            % throw away data not being informative
            % -> not being informative defined by user
            x(xq) = [];
            v(xq) = [];
            vq = interp1(x, v, xq, 'linear');
            dat(xq) = vq;
            
            data{k}.data = dat;
        end;
    end;
    
    clear savedata
    savedata.data = data; 
    savedata.infos = infos; 
    if isstruct(datafile)
        sts = scr_load_data(savedata, 'none');
        newdatafile = savedata;
    else
        [pth, fn, ext] = fileparts(datafile);
        newdatafile    = fullfile(pth, ['i', fn, ext]);
        savedata.infos.interpolatefile = newdatafile;
        savedata.options = options;
        sts = scr_load_data(newdatafile, savedata);
    end;
    if sts ~= 1
        warning('Interpolation unsuccessful for file %s.\n', newdatafile); 
    else
        Dout{d} = newdatafile;
        % user output
        fprintf('  done.\n');
    end;
end;

% if cell array of datafiles is being processed, return cell array of
% filenames
if d > 1
    clear newdatafile
    newdatafile = Dout;
end;

return;


    
