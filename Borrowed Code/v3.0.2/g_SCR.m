function [gx,dgdx] = g_aSCR(Xt,Phi,ut,inG)
% Description
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: g_SCR.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;

gx = Xt(1) + Xt(4) + Xt(7);

dgdx = zeros(size(Xt,1),1);
dgdx([1;4;7]) = 1;

