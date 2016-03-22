function [xi,xic] = Linear_constrained_initilazation(Ain, bin)
% Initialization of the linearly_cosntrained problem
% Ain x \leq bin

global n kappa 

kappa=1.5;
% Find an initial interior point for L
options=optimoptions('linprog','Display','off');

x1 = linprog([zeros(1,n) -1],[Ain ones(size(Ain,1),1); [zeros(2,n) [1 ;-1]]],[bin ;1; 0],[],[],[],[],[],options);
x0r=x1(1:n);


V = uniformsimplexrecursive(n);
% prolongate it to the boundary
for ii=1:n+1
   xi(:,ii)=prolongation(x0r,V(:,ii));
end

err=1;
while (err>1e-3)

err=0;
for k=1:n+1
xic=xi; 
xic(:,k)=[];
xn= Lin_last_point_find(xi(:,k),xic);
err=max([err,norm(xi(:,k)-xn)]);
xi(:,k)=xn;
end
end
% find the exterior simplex
for k=1:n+1
xic(:,k)=xi*ones(n+1,1)-n*xi(:,k); 
end
O=xi*ones(n+1,1)/(n+1);
for k=1:n+1
xic(:,k)=O+kappa*(xic(:,k)-O);
end

end

function xp=prolongation (x,p)
global Ain bin
c=bin-Ain*x; d=Ain*p;
if min(c)<1e-5
a1=0;
else
a=c./d; a=a(d>0);
a1=min(a);
end

xp=x+a1*p;
end
