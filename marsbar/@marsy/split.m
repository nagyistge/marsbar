function o_arr = split(o)
% method splits each regions in object into own object
% 
% $Id$ 
  
r = region(o);
st = y_struct(o);
is_s = isfield(st, 'Y') & isfield(st, 'Yvar');
if is_s
  Y = st.Y;
  Yvar = st.Yvar;
else
  % remove any rogue Y or Yvar fields
  [tmp st] = mars_struct('split', st, {'Y','Yvar'});
end
for i = 1:length(r)
  r_st = st;
  r_st.regions = r(i);
  if is_s
    r_st.Y    = Y(:, i);
    r_st.Yvar = Yvar(:, i);
  end
  o_arr(i) = y_struct(o, r_st);
end
