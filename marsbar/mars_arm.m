function varargout = mars_arm(action, varargin)
% wrapper function for MarsBaR marmoire object
% FORMAT varargout = mars_arm(action, varargin)
% 
% This only to make the marsbar.m code prettier
% See the help for the marmoire object for details
% 
% $Id$

global MARS
if ~isfield(MARS, 'ARMOIRE')
  error('Global structure does not contain marmoire object');
end

if nargin < 1
  error('Need action');
end

o = MARS.ARMOIRE;

switch lower(action)
 case 'get'
  [varargout{1} o varargout{2}] = get_item_data(o, varargin{:});
 case 'set'
  [o varargout{1}] = set_item_data(o, varargin{:});
 case 'set_ui'
  [o varargout{1}] = set_item_data_ui(o, varargin{:});  
 case 'update'
  [o varargout{1}] = update_item_data(o, varargin{:});
 case 'set_param'
  o = set_item_param(o, varargin{:});
 case 'save'
  [varargout{1} o] = save_item_data(o, varargin{:});
 case 'save_ui'
  [varargout{1} o] = save_item_data(o, varargin{:});
 case 'isempty'
  varargout{1} = isempty_item_data(o, varargin{:});
 otherwise
  error('Weird');
end

MARS.ARMOIRE = o;