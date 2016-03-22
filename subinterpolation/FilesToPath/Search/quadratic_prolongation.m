function [alpha] = quadratic_prolongation(x0,v,H,f,d)
% Find the prolongation of x0+alpha*v with x'Hx+fx+d=0
% if method=0: it is a prolongation, method=1: part of the maximizer
%alpha>0
aa=v'*H*v;
bb=2*x0'*H*v+f'*v;
cc=x0'*H*x0+f'*x0+d;

lam=roots([aa bb cc]);
alpha=lam(lam>1e-4);

if length(alpha)==0
    alpha=inf;
end
end

