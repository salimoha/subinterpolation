function [x y cse]=Adoptive_K_conv(x,inter_par,xc,R2)
% Find the minimizer of the search function in a simplex
 rho=0.9; % parameters of backtracking
% Initialize the point in the simplex
%[xc,R2]=circhyp(xiT(:,tri(index,:)), n);
iter=1; mu=1; cse=2;
x_pre=x;
while iter<10
iterr=1; 
while iterr<10
y=cost(x,inter_par,xc, R2,mu);
% Calculate the Newton direction   
if (y==-inf)
    cse=1;
    break
end
g=kgrad(x,inter_par,xc,R2,mu);
H=khess(x,inter_par,xc,R2,mu);
H=modichol(H,0.1,20);
H=(H+H')/2;

%p=quadprog(double(H),double(g),Ain,bin-Ain*x,[],[],[],[],zeros(n,1),options);
p=-H\g;
%p=min(p,bnd2-x); p=max(bnd1-x);

% Perform the hessian modification
if norm(p)<1e-3
            break
end
a=1;
% Backtracking
while 1
    x1=x+a*p;
        y1=cost(x1,inter_par,xc,R2,mu);
        if (y-y1)>0
        x=x1; y=y1;
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
iter=iter+1;
if norm(x_pre-x)<1e-3
    break
else
    mu=mu*0.5;
end
x_pre=x;
end
if cse==1
    [x y]=inter_min_conv(x, inter_par);
end
end

function c=cost(x,inter_par,xc,R2,mu)
global y0 cons m
c=-(R2-norm(x-xc)^2)/(interpolate_val(x,inter_par)-y0);
for i=1:m
    cos=cons(i).val(x);
    if cos<0
        c=inf;
        break
    end
    c=c-mu*log(cos);
end
    
if (interpolate_val(x,inter_par)<y0 && c~=inf)
    c=-inf;
end
end
function  g  = kgrad(x,inter_par,xc,R2,mu)
global y0 cons m
p=interpolate_val(x,inter_par);
gp=interpolate_grad(x,inter_par);
ge=-2*(x-xc);
e=R2-(x-xc)'*(x-xc);
g=-ge/(p-y0)+e*gp/(p-y0)^2;
for i=1:m
   cos=cons(i).val(x);
   g1=cons(i).grad(x);
   g=g-mu*g/cos;
end
end

function  H  = khess(x,inter_par,xc,R2,mu)
global y0 n m cons
p=interpolate_val(x,inter_par);
Hp=interpolate_hessian(x,inter_par);
gp=interpolate_grad(x,inter_par);
ge=-2*(x-xc);
e=R2-norm(x-xc)^2;
%H=Hp/e-(gp*ge.'+ge*gp.')/e^2+(p-y0)*(2*ge*ge.'/e^3+2*eye(n)/e^2);
H=2*eye(n)/(p-y0)+(gp*ge.'+ge*gp.')/(p-y0)^2-e*(2*gp*gp.'/(p-y0)^3-2*Hp/(p-y0)^2); 

for i=1:m
   c1=cons(i).val(x);
   g1=cons(i).grad(x);
   h1=cons(i).Hess(x);
   %keyboard
   H=H-mu*h1/c1+mu*g1*g1'/c1^2;
end

end

    