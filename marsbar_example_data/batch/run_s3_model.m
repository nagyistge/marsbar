% Run SPM 2 session model for MarsBaR ER sample data
% 
% $Id$ 

switch spm('ver')
 case 'SPM99'
  sdirname = 'SPM99_ana';
 case 'SPM2'
  % load SPM defaults
  spm_defaults;
  sdirname = 'SPM2_ana';
end

% quit MarsBaR, otherwise SPM will get confused
% (in fact this is only true for old versions of MarsBaR)
if ~isempty(which('marsbar'))
  marsbar('quit'); 
end

% Make sure SPM modality-specific defaults are set
spm('defaults', 'fmri');

% Run statistics, contrasts
subjroot = spm_get('CPath', '..'); % from batch directory
sesses = {'sess1','sess2','sess3'};
model_file = configure_er_model(subjroot, sesses, sdirname);
estimate_er_model(model_file, [1 0]);