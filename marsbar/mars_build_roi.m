function o = mars_build_roi
% builds ROIs via the SPM GUI
%
% $Id$

o = [];  
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Build ROI', 0);

% get ROI type
optfields = {'image','sphere','box_cw', 'box_lims'};
optlabs =  {'Image','Sphere',...
	    'Box (centre,widths)','Box (ranges XYZ)'};

roitype = char(...
    spm_input('Type of ROI', '+1', 'm',{optlabs{:} 'Quit'},...
	      {optfields{:} 'quit'},length(optfields)+1));

d = [];
switch roitype
 case 'image'
  imgname = spm_get(1, 'img', 'Image defining ROI');
  [p f e] = fileparts(imgname);
  binf = spm_input('Maintain as binary image', '+1','b',...
				      ['Yes|No'], [1 0],1);
  func = '';
  if spm_input('Apply function to image', '+1','b',...
				      ['Yes|No'], [1 0],1);
    spm_input('img < 30',1,'d','Example function:');
    func = spm_input('Function to apply to image', '+1', 's', 'img');
  end
  d = f; l = f;
  if ~isempty(func)
    d = [d ' func: ' func];
    l = [l '_f_' func];
  end
  if binf
    d = [d ' - binarized'];
    l = [l '_bin'];
  end
  o = maroi_image(struct('vol', spm_vol(imgname), 'binarize',binf,...
			 'func', func));
 case 'sphere'
  c = spm_input('Centre of sphere (mm)', '+1', 'e', [], 3); 
  r = spm_input('Sphere radius (mm)', '+1', 'r', 10, 1);
  d = sprintf('%0.1fmm radius sphere at [%0.1f %0.1f %0.1f]',r,c);
  l = sprintf('sphere_%0.0f-%0.0f_%0.0f_%0.0f',r,c);
  o = maroi_sphere(struct('centre',c,'radius',r));
 case 'box_cw'
  c = spm_input('Centre of box (mm)', '+1', 'e', [], 3); 
  w = spm_input('Widths in XYZ (mm)', '+1', 'e', [], 3);
  d = sprintf('[%0.1f %0.1f %0.1f] box at [%0.1f %0.1f %0.1f]',w,c);
  l = sprintf('box_w-%0.0f_%0.0f_%0.0f-%0.0f_%0.0f_%0.0f',w,c);
  o = maroi_box(struct('centre',c,'widths',w));
 case 'box_lims'
  X = sort(spm_input('Range in X (mm)', '+1', 'e', [], 2)); 
  Y = sort(spm_input('Range in Y (mm)', '+1', 'e', [], 2)); 
  Z = sort(spm_input('Range in Z (mm)', '+1', 'e', [], 2));
  A = [X Y Z];
  c = mean(A);
  w = diff(A);
  d = sprintf('box at %0.1f>X<%0.1f %0.1f>Y<%0.1f %0.1f>Z<%0.1f',A);
  l = sprintf('box_x_%0.0f:%0.0f_y_%0.0f:%0.0f_z_%0.0f:%0.0f',A);
  o = maroi_box(struct('centre',c,'widths',w));
 case 'quit'
  o = [];
  return
 otherwise
  error(['Strange ROI type: ' roitype]);
end
o = descrip(o,d);
o = label(o,l);