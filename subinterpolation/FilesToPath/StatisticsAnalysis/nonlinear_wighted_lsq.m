function [cost,g]= nonlinear_wighted_lsq(par,T,y,weight)
mu2=par(1); sigma2=par(2); b0=par(3); beta=par(4);
c=mu2+sigma2*((b0+(1-b0).*exp(-beta*(T-1))))./T;
cost=(y-c)*diag(weight)*(y-c)';

if nargout>1
    g(1)=2*sum(diag(weight)*(c-y)');
    g2=((b0+(1-b0).*exp(-beta*(T-1))))./T;
    g(2)=2*g2*diag(weight)*(c-y)';
    g3=sigma2*(1-exp(-beta*(T-1)))./T;
    g(3)=2*g3*diag(weight)*(c-y)';
    g4=sigma2*((b0-(1-b0)*beta.*exp(-beta*(T-1))))./T;
    g(4)=2*g4*diag(weight)*(c-y)';
end