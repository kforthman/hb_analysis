function out = scr_cfg_run_resp_pp(job)
% Executes scr_resp_pp

% $Id: scr_cfg_run_resp_pp.m 87 2015-06-04 13:36:30Z tmoser $
% $Rev: 87 $

% sample rate
sr = job.sr;

% channel
if isfield(job.chan,'chan_nr')
    chan = job.chan.chan_nr;
else
    chan = '';
end

options.plot = job.options.plot;

if isfield(job.options.systemtype, 'bellows')
    options.systemtype = 'bellows';
else
    options.systemtype = 'cushion';
end

f = fields(job.options.datatype);

options.datatype = {};
for i = 1:numel(f)
    if job.options.datatype.(f{i}) == 1
        options.datatype = [options.datatype, f{i}];
    end;
end;


sts = scr_resp_pp(job.datafile{1}, sr, chan, options);

out = job.datafile;