function [x]=feasible_point_finder(x,H,f,e)
% Calculate an initial feasible point for the feasible domain
% minimize -\sum log(-x'H_ix- f'x_i- e_i)

global m n
for i=1:m
    e{i}=e{i}-0.1;
end
while 1
[M]=cost_fun(x,H,f,e);
if (M==0)
    break
end
[dM]=grad_fun(x,H,f,e);
[d2M]=hess_fun(x,H,f,e);
d2M=d2M+0.01*eye(n);
p=-d2M\dM;
%line search method
alpha1=1;
while 1
x1=x+alpha1*p(1:n);
M1=cost_fun(x1,H,f,e);
if (M-M1>-0.01*p'*dM)
    x=x1; break
else
    alpha1=0.9*alpha1;
end
end
if norm(alpha1*p)<1e-3
    break
end

end
end
function [y]=cost_fun(x,H,f,e)
global m n
y=0;
for i=1:m
    y=y+min(x'*H{i}*x+f{i}'*x+e{i},0)^2;
end
end
function [dy]=grad_fun(x,H,f,e)
global m n
dy=zeros(n,1);
for i=1:m
    c=min([x'*H{i}*x+f{i}'*x+e{i},0]);
    dc=2*H{i}*x+f{i};
    dy=dy+c*dc;
end
end
function [d2y]=hess_fun(x,H,f,e)
global m n
d2y=zeros(n,n);
for i=1:m
    c=min([x'*H{i}*x+f{i}'*x+e{i},0]);
    dc=2*H{i}*x+f{i};
    d2c=2*H{i};
    if c<0
    d2y=d2y+c*d2c+dc*dc';
    end
end
end