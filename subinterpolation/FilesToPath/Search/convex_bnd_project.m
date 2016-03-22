function [xp,xc,R2,ii] = convex_bnd_project(x,xi,tri)
% Find the convex boundary projection of the point x
global n m cons
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
    al=Inf;
    for i=1:m
    c=cons(i).val(xc);
    if (c<0)
        p=xc-x;
        a=intersect_feas_conv(x,p,i);
        al=min([al,a]);
    end
    end
     xp=x+al*p;  
end
end

function a=intersect_feas_conv(x,p,i)
global cons
a=0; y=1;
while 1  
   % keyboard
    if cons(i).val(x+a*p)^2<1e-5
        break
    end
a1=cons(i).val(x+a*p)/(cons(i).val(x+a*p)-cons(i).val(x+y*p));
if cons(i).val(x+(a+a1*(y-a))*p)>0
    a=a+a1*(y-a);
else
    y=a+a1*(y-a);
end
if abs(cons(i).val(x+a1*p))<1e-4
break
end
end
end
