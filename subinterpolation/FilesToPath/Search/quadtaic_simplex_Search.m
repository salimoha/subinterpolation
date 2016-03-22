function [xm,pm]=quadtaic_simplex_Search(xm,inter_par,X,Y)
% perform search in the simplex

global n y0

%keyboard
x=X*ones(n+1,1)/(n+1);
[xc,R2]=circhyp(X, n);
yss=Y*ones(n+1,1)/(n+1);
while 1
K=(interpolate_val(x,inter_par)+yss-y0)/(R2-norm(x-xc)^2);
if K<0
    K=0;
end
   H_1=2*X'*(inter_par{5}+K*eye(n))*X;
   f_1=X'*(-2*inter_par{5}*inter_par{3}+inter_par{4}-2*K*xc)+Y';
 %  e_1=inter_par{3}'*inter_par{5}*inter_par{3}-inter_par{4}'*inter_par{3}+inter_par{2}+K*[R2+norm(xc)^2];
options=optimoptions('quadprog','Display','none');
w=quadprog(H_1,f_1,-eye(n+1),zeros(n+1,1),ones(1,n+1),1,[],[],ones(n+1,1)/(n+1),options); 
x1=X*w;
if norm(x-x1)<1e-3
    break
else
    x=x1;
    pm=interpolate_val(x,inter_par)+Y*w;
    yss=Y*w;
end
end    
end