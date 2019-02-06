function cfg = scr_cfg_first_level_scr

% $Id: scr_cfg_first_level_scr.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


%% First Level
cfg        = cfg_repeat;
cfg.name   = 'SCR';
cfg.tag    = 'scr';
cfg.values = {scr_cfg_glm_scr, scr_cfg_dcm, scr_cfg_sf}; % Values in a cfg_repeat can be any cfg_item objects
cfg.forcestruct = true;
cfg.help   = {''};