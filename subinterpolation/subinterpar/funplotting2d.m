function [h,U]= funplotting2d(fun,xx,yy,n,sigma)

% plotting the function in 1D and 2D with noise.
% fun: f(x), xx,yy: variables, n:dimension, sigma:std of noise


close all
if n==1
 for ii=1:length(xx)
    U(ii)=fun([xx(ii)])+sigma*randn;
    Ur(ii)=fun([xx(ii)]);
 end
 figure(1)
 h=plot(xx,U,'k-','linewidth',2)
 minU=min(U);

else
for jj=1:length(xx)
for ii=1:length(xx)
    U(ii,jj)=fun([xx(ii) ;yy(jj)])+sigma*randn;
end
end
figure(1)
h=surf(xx,xx,U.');
figure(2)
h=contourf(xx,xx,U.');
[t]=min(min(U));
end
end
