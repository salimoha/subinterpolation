% Representation of Alpha_Dogs
clear all
close all
clc
%cd Filestopath
%addTopath
cd ..
%%
sigma0=0.1;
%fun=@(x) (x-.3)^2+sigma0*randn;
%fun=@(x) (x-.3)^2;
fun=@(x) 1/(10*x)+10*x;
xi=[0.01 1 0.5];
for ii=1:length(xi)
    yi(ii)=fun(xi(:,ii));
end
T=ones(1,3);
K=5; L=1;
[xi,ind]=sort(xi); yi=yi(ind);
xx=0:0.01:1;
xc=(xi(1:end-1)+xi(2:end))/2;
d=(xi(2:end)-xi(1:end-1))/2;
%[inter_par,yp]=interpolateparametarization(xi,yi,sigma0./sqrt(T),1);
[inter_par]=interpolateparametarization(xi,yi,1);

for ii=1:length(xx)
    x=xx(ii);
    %fr(ii)= funr(x);
    f(ii)=fun(x);
    p(ii) = interpolate_val(x,inter_par);
    e(ii) = max(d.^2-(x-xc).^2);
    sc(ii) = p(ii)-K*e(ii);
end
[tc,indc]=min(sc);
figure(1)
plot(xx,f,'k-',xx,p,'k--', xx, sc, 'k-.') 
hold on
% errorbar(xi,yi,sigma0./sqrt(T),'k.','linewidth',2)
%    sd = min(yp,2*yi-yp)-L*sigma0./sqrt(T);
%[td,indd]=min(sd);
%hold on
plot(xi,yi,'ks', 'Markersize',10, 'MarkerFacecolor', 'k')
%text(xx(indc),tc-.05,'x_k','fontsize',20)
plot(xx(indc),tc,'k*','Markersize',10)
%text(xi(indd),td-.05,'z_k','fontsize',20)
set(gca,'YTickLabel',[])
set(gca,'XTickLabel',[])
%ylim([-.3 0.9])
grid on
    