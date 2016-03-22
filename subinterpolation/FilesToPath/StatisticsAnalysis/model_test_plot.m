%close all

xx=1:100;

alpha=0.001; beta=alpha;
yy=exp(((xx.^beta-1)./xx.^beta)/alpha)./xx;
hold on
plot(xx,yy)