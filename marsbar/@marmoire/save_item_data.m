function [saved_f, o] = save_item_data(o, item, flags, filename)
% save data for item to file
% FORMAT [saved_f o] = save_item_data(o, item, flags, filename)
% o        - object
% item     - name of item
% flags    - flags for save; fields in flag structure can be
%                  'force' - force save even if not flagged as needed
%                  'warn_empty' - GUI warn if no data to save
%                  'ync' - start save with save y/n/cancel dialog
%                  'prompt' - prompt for save; 
%                  'prompt_suffix - suffix for prompt
%                  'prompt_prefix - prefix for prompt
%                  'ui' - use UI prompts for save - forced if save_ui
%                  'no_no_save' - if 'no' is chosen in the save dialog,
%                     contents are flagged as not needing a save in
%                     the future (has_changed flag set to 0)  
% filename - filename for save
% 
% Returns
% saved_f  - flag set to 1 if save done
% o        - possibly modified object (changed filename, maybe data is
%            left as a file, and data field made empty) 
% 
% $Id$

if nargin < 2
  error('Need item');
end
if nargin < 3
  flags = NaN;
end
if nargin < 4
  filename = NaN;
end

if ~isstruct(flags), flags = []; end

if strcmp(item, 'all')
  item_list = fieldnames(o.items);
else 
  item_list = {item};
end

n_items = length(item_list);
saved_f = zeros(n_items, 1);
for i_no = 1:n_items
  item = item_list{i_no};
  I = get_item_struct(o, item);
  tmp_flgs = flags;
  if pr_is_nix(filename) & ...
	isempty(I.file_name)
    tmp_flags.ui = 1;
  end
  [saved_f I] = pr_save(I, tmp_flags, filename);
  o.items = setfield(o.items, item, I);
end