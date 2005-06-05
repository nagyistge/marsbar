function pre_release(username, rname, outdir, proj, proj_descrip)
% Runs pre-release export, cleanup
% FORMAT pre_release(username, rname, outdir, proj, proj_descrip)
%
% Inputs [defaults]
% username     - marsbar CVS username 
% rname        - string to define release version ['-%s']
% outdir       - directory to output release to [pwd]
% proj         - project name (and name of main project file) ['marsbar']
% proj_descrip - short description of project ['MarsBaR ROI toolbox']
%
% e.g.  pre_release('matthewbrett', '-devel-%s', '/tmp')
% would output a release called marsbar-devel-0.34.tar.gz (if the marsbar
% version string is '0.34') to the /tmp directory
%
% $Id$
  
if nargin < 1
  error('Need username');
end
if nargin < 2
  rname = '-%s';
end
if nargin < 3
  outdir = pwd;
end
if nargin < 4
  proj = 'marsbar';
end
if nargin < 5
  proj_descrip = 'MarsBaR ROI toolbox';
end

% project version
V = eval([proj '(''ver'')']);
rname = sprintf(rname, V);

% export from CVS
cmd = sprintf(['cvs -d:ext:%s@cvs.sourceforge.net:/cvsroot/%s ' ...
	       'export -D tomorrow %s'], username, proj, proj);
unix(cmd);

% make contents file
contents_str = sprintf('Contents of %s version %s', ...
		       proj_descrip, V);
make_contents(contents_str, 'fncrd', fullfile(pwd, proj));

% make m2html documentation if the program is available
if ~isempty(which('m2html'))
  m2html('mfiles', proj, ...
	 'htmldir', fullfile(proj, 'doc'), ...
	 'graph', 'on', ...
	 'recursive', 'on', ...
	 'global', 'on')
end

% move, tar directory
full_name = sprintf('%s%s',proj, rname);
unix(sprintf('mv %s %s', proj, full_name));
unix(sprintf('tar zcvf %s.tar.gz %s', full_name, full_name));
unix(sprintf('rm -rf %s', full_name));

fprintf('Created %s release %s\n', proj, full_name);

