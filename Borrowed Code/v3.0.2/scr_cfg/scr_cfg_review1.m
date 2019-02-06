function review = scr_cfg_review1
% Review model (first level)

% $Id: scr_cfg_review1.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

%% Data File Selector
modelfile         = cfg_files;
modelfile.name    = 'Model File';
modelfile.tag     = 'modelfile';
modelfile.num     = [1 1];
modelfile.filter  = '.*\.(mat|MAT)$';
modelfile.help    = {'Choose model file to review.'};

%% GLM    
glm         = cfg_menu;
glm.name    = 'GLM';
glm.tag     = 'glm';
glm.labels  = {'Design matrix', 'Orthogonality', 'Predicted & Observed', 'Regressor names', 'Reconstructed'};
glm.values  = {1, 2, 3, 4, 5};
glm.help    = {'Specify the plot that you wish to display'};

%% DCM

% INV
session_nr         = cfg_entry;
session_nr.name    = 'Session Number';
session_nr.tag     = 'session_nr';
session_nr.strtype = 'i';
session_nr.num     = [1 1];
session_nr.val     = {1};
session_nr.help    = {'Data session. Must be 1 if there is only one session in the file.'};

trial_nr         = cfg_entry;
trial_nr.name    = 'Trial Number';
trial_nr.tag     = 'trial_nr';
trial_nr.strtype = 'i';
trial_nr.num     = [1 1];
trial_nr.help    = {'Trial to review.'};

inv         = cfg_branch;
inv.name    = 'Inversion results for one trial';
inv.tag     = 'inv';
inv.val     = {session_nr, trial_nr};
inv.help    = {'Non-linear SCR model (DCM): Review individual trials or sequences of trials inverted at the same time.'};

%SUM
sum         = cfg_branch;
sum.name    = 'Predicted & Observed for all trials';
sum.tag     = 'sum';
sum.val     = {session_nr};
sum.help    = {'DCM for event-related responses: review summary plot of all trials. Adding a figure name saves the figure.'};

% SCRF
scrf       = cfg_const;
scrf.name  = 'SCRF';
scrf.tag   = 'scrf';
scrf.val   = {'scrf'};
scrf.help  = {'DCM for event-related responses: review SCRF (useful if SCRF was estimated from the data).'};

% Names
names       = cfg_const;
names.name  = 'Trial and condition names';
names.tag   = 'names';
names.val   = {'names'};
names.help  = {'Show trial and condition names in command window.'};


dcm         = cfg_choice;
dcm.name    = 'DCM';
dcm.tag     = 'dcm';
dcm.values  = {inv, sum, scrf, names};

%% SF
% SF
episode_nr         = cfg_entry;
episode_nr.name    = 'Episode Number';
episode_nr.tag     = 'episode_nr';
episode_nr.strtype = 'i';
episode_nr.num     = [1 1];
episode_nr.help    = {'Episode to review.'};

sf         = cfg_branch;
sf.name    = 'SF';
sf.tag     = 'sf';
sf.val     = {episode_nr};
sf.help    = {'DCM for spontaneous fluctuations: Show inversion results for one episode.'};

%% Contrasts

con         = cfg_const;
con.name    = 'Contrasts';
con.tag     = 'con';
con.val     = {'all'};
con.help    = {'Display contrast names for any first level model.'};


% Modeltype
modeltype         = cfg_choice;
modeltype.name    = 'Model Type';
modeltype.tag     = 'modeltype';
modeltype.values  = {glm, dcm, sf, con};
modeltype.help    = {'Specify the type of model.'};

% Executable Branch
review      = cfg_exbranch;
review.name = 'Review First-Level Model';
review.tag  = 'review';
review.val  = {modelfile, modeltype};
review.prog = @scr_cfg_run_review1;
review.help = {['This module allows you to look at the first-level (within-subject) model to investigate ' ...
    'model fit and potential estimation problems. This is not necessary for standard analyses. Further ' ...
    'processing can be performed directly on the second level after first-level model estimation.']};