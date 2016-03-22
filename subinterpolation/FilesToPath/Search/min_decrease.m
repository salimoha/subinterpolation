function [x1]=min_decrease(x0, x, inter_par) 
% find the intersection of x, x1 with the boundary of p(x)<0
global y0
%keyboard
while 1
 a=(interpolate_val(x0,inter_par)-y0)/(interpolate_val(x0,inter_par)-interpolate_val(x,inter_par));
 if a<1e-4
     break
 end
 if 1-a<1e-4
     break
 end
 x1=x0+a*(x-x0);
 if interpolate_val(x1,inter_par)<y0
     x=x1;
 else
     x0=x1;
 end
end
end