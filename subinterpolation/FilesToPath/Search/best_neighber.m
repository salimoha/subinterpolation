function [xn,yn]=best_neighber(x0,inter_par,xE,delta, ub, lb)
global y0 n 
%keyboard
for ii=1:n
    x1=x0; x1(ii)=x1(ii)+delta;
    ym(ii)=(interpolate_val(x1,inter_par)-y0)/mindis(x1,xE);
    if x1(ii)>ub(ii)
        ym(ii)=inf;
    end
end
for ii=1:n
    x1=x0; x1(ii)=x1(ii)-delta;
    ym(ii+n)=(interpolate_val(x1,inter_par)-y0)/mindis(x1,xE);
    if x1(ii)<lb(ii)
        ym(ii+n)=inf;
    end
end
[yn,ind]=min(ym);
if ind<n+1
    xn=x0; xn(ind)=xn(ind)+delta;
else
    xn=x0; xn(ind-n)=xn(ind-n)-delta;
end

end
