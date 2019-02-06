function out = scr_cfg_run_emg_pp(job)
% Executes scr_emg_pp

% $Id: scr_cfg_run_emg_pp.m 41 2015-04-02 15:25:50Z tmoser $
% $Rev: 41 $

scr_emg_pp(job.datafile);

out = job.datafile;