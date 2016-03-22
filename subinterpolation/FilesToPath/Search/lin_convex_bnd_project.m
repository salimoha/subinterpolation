function [xp,xc,R2,ii] = lin_convex_bnd_project(x,xi,tri)
% Find the convex boundary projection of the point x
global n m Ain bin

lincon=1;
out=0;
for ii=1:size(tri,1)
            if (min(tri(ii,:))<n+2)
                [xc,R2]=circhyp(xi(:,tri(ii,:)), n);
                if norm(x-xc)< sqrt(R2)
                    out=1;
                    break
                end
            end            
end
if out==0
    xp=x;
else
   xp=prolongation (x,xc-x);
end
end

function xp=prolongation (x,p)
global Ain bin
c=bin-Ain*x; d=Ain*p;
if min(c)<1e-5
    a=0;
else
a=c./d; a=a(d>0);
end
a1=min(a);
xp=x+a1*p;
end