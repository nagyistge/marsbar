function str = mars_cvs_version(mfile, class_name)
% returns cvs version number from m file as string
% FORMAT str = mars_cvs_version(mfile [,class_name])
%
% mfile      - name of function 
% class_name - optional class name to help matlab find function
%              (needed for class private functions)
%
% $Id$

if nargin < 1
  error('Need matlab function or filename');
end
if nargin < 2
  mfname = which(mfile);
else
  mfname = which(mfile, 'in', [class_name filesep class_name]);
end
if isempty(mfname)
  error(['Cannot find .m file: ' mfile]);
end
fid=fopen(mfname,'rt');
if fid == -1, error(['Cannot open file ' mfname]);end 
aLine = '';
while(isempty(aLine))
  aLine = fgetl(fid);
end
if  ~strcmp(aLine(1:8),'function'), return, end
aLine = fgetl(fid);
while ~isempty(findstr(aLine,'%')) & feof(fid)==0; 
  [cvsno count] = sscanf(aLine, '%%%*[ ]$Id:%*s%*[ ] %f');
  if count
    str = num2str(cvsno);
    break
  end
  aLine = fgetl(fid);
end % while
fclose(fid);
return
