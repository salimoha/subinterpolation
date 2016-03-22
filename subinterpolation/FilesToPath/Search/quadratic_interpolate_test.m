% test for quadratic interpolation with linear correction.
clear all
close all

global n
n=1;

fun=@(x) 1/x+x;
xi=[3 2 2.5 0.1];

for ii=1:size(xi,2)
yi(ii)=fun(xi(:,ii));
end


% polyharmonic spline interpolation
inter_par= interpolateparametarization(xi,yi,1);
xv=0.1:0.05:3;
for ii=1:length(xv)
yy(ii)=fun(xv(ii));
yp(ii)=interpolate_val(xv(ii),inter_par);
end
plot(xv,yy,'-',xv,yp,'--');
hold on
plot(xi,yi,'ks')

