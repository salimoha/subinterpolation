function xr=linreflection(x,Nm,delta)
% reflecting x on the cartition grid for a polygon
global Ain bin n m
inda=1:m;
inda=inda(Ain*x-bin>-delta);
Aa=Ain(inda,:); ba=bin(inda);
if length(Aa)==0
    x0=zeros(n,1);
    V=eye(n);
else
x0=Aa\ba;
V=null(Aa);
end
if size(V,2)==0
xr=x0;
else
w=V\(x-x0);
w=round(w*Nm)/Nm;
xr=x0+V*w;
end
end