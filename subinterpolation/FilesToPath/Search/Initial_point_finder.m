function [x]=Initial_point_finder(x,H,f,e)
% calculate an initial interior point for the feasible domain
% minimize -\sum log(-x'H_ix- f'x_i- e_i)

global m n
while 1
[M]=cost_fun(x,H,f,e);
[dM]=grad_fun(x,H,f,e);
[d2M]=hess_fun(x,H,f,e);
p=-d2M\dM;
%line search method
for j=1:m
    alpha(j) = quadratic_prolongation(x,p,H{j},f{j},e{j});
end
alpha1=0.95*min(alpha);  
alpha1=min([1,alpha1]);
if norm(alpha1*p)<1e-3
    break
end
while 1
x1=x+alpha1*p(1:n);
M1=cost_fun(x1,H,f,e);
if (M-M1>-0.01*p'*dM)
    x=x1; break
else
    alpha1=0.9*alpha1;
end
end

end
end
function [y]=cost_fun(x,H,f,e)
global m n
y=0;
% minimize -\sum log(-x'H_ix- f'x_i- e_i)
for i=1:m
    y=y-log(x'*H{i}*x+f{i}'*x+e{i});
end
end
function [dy]=grad_fun(x,H,f,e)
global m n
dy=zeros(n,1);
% minimize -\sum log(-x'H_ix- f'x_i- e_i)
for i=1:m
    dy=dy-(2*H{i}*x+f{i})/(x'*H{i}*x+f{i}'*x+e{i});
end
end
function [d2y]=hess_fun(x,H,f,e)
global m n
d2y=zeros(n,n);
% minimize -\sum log(-x'H_ix- f'x_i- e_i)
for i=1:m
    d2y=d2y-2*H{i}/(x'*H{i}*x+f{i}'*x+e{i})+(2*H{i}*x+f{i})*(2*H{i}*x+f{i})'/(x'*H{i}*x+f{i}'*x+e{i})^2;
end
end