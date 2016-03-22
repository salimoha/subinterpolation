function [x y]=inter_min_conv(x, inter_par)
%find the minimizer of the interpolating function starting with x
global n
rho=0.9; % parameters of backtracking
% start the search with method
mu=1; iter=1;
while iter<4
x_pre=x; iterr=1;     
while iterr<10
% Calculate the Newton direction
y=cost(x,inter_par,mu); 
g=grad(x,inter_par,mu);
H=hess(x,inter_par,mu);
% Perform the Hessian modification
H=(H+H.')/2;
H=modichol(H,0.01,20);  
p=-H\g;
if norm(p)<1e-5
    break
end
a=1;
% Backtracking
while 1
    x1=x+a*p;
        y1=cost(x1,inter_par,mu);
        if (y-y1)>0
        x=x1;
        break
        else
        a=a*rho;
        if norm(a*p)<1e-4
            break
        end
        end
        
end
iterr=iterr+1;
end
if norm(x_pre-x)<1e-3
    break
else
    mu=0.5*mu;
end
iter=iter+1;
end
end

function c=cost(x,inter_par,mu)
global cons m
c=interpolate_val(x,inter_par);
for i=1:m
    cos=cons(i).val(x);
    if cos<0
        c=inf;
        break
    end
    c=c-mu*log(cos);
end
end

function g=grad(x,inter_par,mu)
global cons m
g=interpolate_grad(x,inter_par);
for i=1:m
   cos=cons(i).val(x);
   g1=cons(i).grad(x);
   g=g-mu*g/cos;
end

end



function H=hess(x,inter_par,mu)
global cons m
H=interpolate_hessian(x,inter_par);
for i=1:m
   c=cons(i).val(x);
   g1=cons(i).grad(x);
   h1=cons(i).Hess(x);
   H=H-mu*h1/c+mu*g1*g1'/c^2;
end
end