function varargout = mars_struct(action, varargin)
% multifunction function for manipulating structures
%
% To help the exposition a bit: 
% 'fill' in a name, means that values empty or missing 
% in one structure are fetched from another
% 
% 'merge' means simply that missing fields are added, with
% values, from a second structure (but not filled if empty)
%
% FORMAT c = mars_struct('fillafromb', a, b, fieldns, flags)
% fills structure fields empty or missing in a from those present in b
% a, b are structures
% fieldns (optional) is cell array of field names to fill from in b
% c is returned structure
% Is recursive, will fill struct fields from struct fields
% flags may contain 'f', which Force fills a from b (all non empty
% fields in b overwrite those in a)
% flags may also contain 'r', which Restricts fields to write from b, to
% those that are already present in a
% 
% FORMAT [c, d] = mars_struct('split', a, b)
% split structure a into two, according to fields in b
% so that c becomes a structure which contains the fields
% in a, that are also present in b, and d contains the fields
% in a that are not present in b.  b can be a structure
% or a cell array of fieldnames
%
% FORMAT c = mars_struct('merge', a, b)
% merges structure a and b (fields present in b added to a)
%
% FORMAT [c,d] = mars_struct('ffillsplit', a, b)
% force fill, followed by split
% All fields from a, that are also present in b, and not empty, 
% are replaced with the values in b; the result is returned as c  
% Any fields present in a, but not present in b, are returned in d
%
% FORMAT c = mars_struct('ffillmerge', a, b)
% force fill followed by merge
% performs 'ffillsplit' on a and b, then merges a and b
% All fields present in a or b are returned in c, but 
% any fields present in both, now have the value from b
%
% FORMAT [c d] = mars_struct('splitmerge', a, b)
% performs 'split' on a and b, creating c and d
% then merges c with b.
% d contains fields in a that were not present in b
% c contains fields present in both, or just in b
%
% $Id$

if nargin < 1
  error('Action needed');
end
if nargin < 3
  error('Must specify a and b')
end
[a b] = deal(varargin{1:2});

switch lower(action)  
 case 'fillafromb'
  % Return for empty passed args
  if isempty(a), varargout = {b}; return, end
  if isempty(b), varargout = {a}; return, end
  
  if nargin < 4, fieldns = []; else fieldns = varargin{3}; end
  if isempty(fieldns), fieldns = fieldnames(b); end
  
  if nargin < 5, flags = ''; else flags = varargin{4}; end
  if isempty(flags), flags = ' ';end
  
  if ischar(fieldns), fieldns=cellstr(fieldns);end
  
  af = fieldnames(a)';
  bf = fieldns';
  
  % classify fields 0 = a~b, 1 = a&b, 2=b~a
  cf = af;
  ftype = ismember(af, bf);
  if ~any(flags == 'r')
    b_not_a = find(~ismember(bf, af));
    cf =  {cf{:} bf{b_not_a}}; 
    ftype = [ftype ones(1, length(b_not_a))*2];
  end
  
  % cope with arrays of structures
  alen = prod(size(a));
  blen = prod(size(b));
  maxlen = max(alen, blen);
  
  for si=1:maxlen
    ctmp = [];
    for i=1:length(cf)
      fn = cf{i};
      switch ftype(i)
       case 0 % a~b
	fval = getfield(a(si), fn);
       case 1 % shared field
	bfc = getfield(b(si), fn);
	if isempty(getfield(a(si), fn)) | ... % a field is empty
	      (any(flags == 'f' & ~isempty(bfc)))% or force fill
	  fval = bfc;
	else % field not empty, could be struct -> recurse
	  fval = getfield(a(si),fn);
	  if isstruct(fval) & isstruct(bfc)
	    fval = mars_struct('fillafromb',fval,bfc);
	  end
	end
       case 2 % b~a
	fval = getfield(b(si), fn);
       case 3 % no field information, see below
	fval = [];
      end
      if isempty(ctmp)
	ctmp = struct(fn, fval);
      else
	ctmp = setfield(ctmp, fn, fval);
      end
    end
    c(si) = ctmp;
    
    if si == blen % reached end of bs, rest of b~a fields are empty
      ftype = (ftype == 2) * 3;
    elseif si == alen % end of a's rest of a~b fields are empty
      ftype = (ftype == 0) * 2 + 1;
    end
    
  end
  varargout = {c};
  
 case 'split'
  if isempty(a), varargout = {a,a}; return, end
  if isempty(b), varargout = {b,a}; return, end
  d = a;
  c = [];
  
  if ischar(b), b = {b};end
  if isstruct(b), b = fieldnames(b);end
  
  for bf = b(:)'
    if isfield(a, bf{1})
      c = setfield(c, bf{1}, getfield(a, bf{1}));
      d = rmfield(d, bf{1});
    end
  end  
  varargout = {c, d};
  
 case 'merge'
  if isempty(a), varargout = {b}; return, end
  if isempty(b), varargout = {a}; return, end
  c = a;
  
  for bf = fieldnames(b)';
    if ~isfield(a, bf{1})
      c = setfield(c, bf{1}, getfield(b, bf{1}));
    end
  end
  varargout = {c};
  
 case 'ffillsplit'
  if isempty(a), varargout = {b,a}; return,  end
  if isempty(b), varargout = {a,b}; return,  end
   c = a; d = b;
   
   cf = fieldnames(c);
   for i=1:length(cf)
     if isfield(d, cf{i})
       dfc = getfield(d,cf{i});
       if ~isempty(dfc) 
	 c = setfield(c, cf{i}, dfc);
       end
       d = rmfield(d, cf{i});
     end
   end
   varargout = {c,d};
   
 case 'ffillmerge'
  [a b] = mars_struct('ffillsplit', a, b);
  varargout = {mars_struct('merge', a, b)};
  
 case 'splitmerge'
  [a c] = mars_struct('split', a, b);
  varargout = {mars_struct('merge', a, b) c};
  
 case 'otherwise'
  error(['Suspicious action was ' action]);
end % switch