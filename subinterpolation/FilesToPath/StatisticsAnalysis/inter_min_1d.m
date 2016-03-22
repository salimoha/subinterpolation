function x=inter_min_1d(x, inter_par)
%Minimize the interpolation to estimate the transient Time


rho=0.9; % parameters of backtracking

% start the search with method
iter=1;

while iter<10

% Calculate the Newton direction
y=interpolate_val(x,inter_par);
g=interpolate_grad(x,inter_par);
H=interpolate_hessian(x,inter_par);
% Perform the Hessian modification
H=max(H,0.01);
p=-g/H;
p=min([p,1-x]); p=max([p, -x]);
 
a=1;
% Backtracking
while 1
    x1=x+a*p;
        y1=interpolate_val(x,inter_par);
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
iter=iter+1;
end
     

