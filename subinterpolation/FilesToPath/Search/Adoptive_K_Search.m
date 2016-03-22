function [x y cse]=Adoptive_K_Search(x,inter_par,xc,R2)
% Find the minimizer of the search function in a simplex

global n Ain bin

cc=0.01; rho=0.9; % parameters of backtracking
% Initialize the point in the simplex
%[xc,R2]=circhyp(xiT(:,tri(index,:)), n);
iter=1; cse=2;
y=cost(x,inter_par,xc, R2);
while iter<3
% Calculate the Newton direction   
if (y==-inf)
    cse=1;
    break
end
g=kgrad(x,inter_par,xc,R2);
H=khess(x,inter_par,xc,R2);
H=modichol(H,0.1,20);
H=(H+H')/2;
options=optimoptions('quadprog','Display','none');
p=quadprog(double(H),double(g),Ain,bin-Ain*x,[],[],[],[],zeros(n,1),options);
%p=-H\g;
%p=min(p,bnd2-x); p=max(bnd1-x);

% Perform the hessian modification
if norm(p)<1e-3
            break
end
a=1;
% Backtracking
while 1
    x1=x+a*p;
        y1=cost(x1,inter_par,xc,R2);
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
iter=iter+1;
end
end

function [M]=cost(x,inter_par,xc,R2)
global y0
M=-(R2-norm(x-xc)^2)/(interpolate_val(x,inter_par)-y0);
if interpolate_val(x,inter_par)<y0
    M=-inf;
end
end
function [ y ] = kgrad(x,inter_par,xc,R2)
global y0
p=interpolate_val(x,inter_par);
gp=interpolate_grad(x,inter_par);
ge=-2*(x-xc);
e=R2-(x-xc)'*(x-xc);
%y=gp/e-(p-y0)*ge/e^2;
y=-ge/(p-y0)+e*gp/(p-y0)^2;
end

function [ H ] = khess(x,inter_par,xc,R2)
global y0 n
p=interpolate_val(x,inter_par);
Hp=interpolate_hessian(x,inter_par);
gp=interpolate_grad(x,inter_par);
ge=-2*(x-xc);
e=R2-norm(x-xc)^2;
%H=Hp/e-(gp*ge.'+ge*gp.')/e^2+(p-y0)*(2*ge*ge.'/e^3+2*eye(n)/e^2);
H=2*eye(n)/(p-y0)+(gp*ge.'+ge*gp.')/(p-y0)^2-e*(2*gp*gp.'/(p-y0)^3-2*Hp/(p-y0)^2); 

end

    