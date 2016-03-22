function [xf,Ic,ind] = cosntraint_projection(x,xi)
% for box constraints
global Ain bin r con
m=size(Ain,1);
for ind=1:m
a=Ain(ind,:); 
b=bin(ind); 
lamda=(-a*x+b)/norm(a)^2;
R(ind)=inf;
T=con{ind};
for j=1:length(T)
    V=xi(:,T(j));
    RR=norm(V-x)/lamda;
    if RR<R(ind)
        R(ind)=RR;
    end
end
end
[r1,ind]=max(R);
if r1>r
 a=Ain(ind,:); 
 b=bin(ind); 
 lambda=(a*x-b)/norm(a)^2;   
 xf=x-lambda*Ain(ind,:)';
 Ic=1;
else
    xf=x;
    Ic=0;
    ind=0;
end
end
    








