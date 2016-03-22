function [mu,sigmaT,Initial_mod] = alpha_statitical_analyze(x,Initial_mod)

% Statistical analysis of a time_series vector: x.
% Initialmod(1)=0 the time series for a new parameterization, Initialmod(2)=0.
% Initialmod(1)=1 the time series for a existing parameterization, Initialmod(2)=t_transient.
% mu: estimate of the infinite_time average.
% sigma: uncertainty of the estimate mu.


% Delete the Initial transient part
if Initial_mod(1)==0
t= transientpart(x);
Initial_mod(2)=t;
else
t=Initial_mod(2);
end
x=x(t+1:end);


% Normalize x
mu=mean(x); S=std(x); 
x=(x-mu)./S;

% Estimate sigmaT of the Final point 
sigmaT=S*stationary_model(x);


end

function t= transientpart(x)
% The function that estimate the initial transient time

N=length(x); ns=20;
for i=1:1.8*ns
    s(i)=std(x(floor(N/(2*ns))*i:end));
    n(i)=length(x(floor(N/(2*ns))*i:end));
end

inter_par=interpolateparametarization((1:1.8*ns)/ns,(s./sqrt(n))/std(s./sqrt(n)),1);
aa=s./sqrt(n); [t,ind]=min(aa(1:length(aa)/2)); 
tx=inter_min_1d(ind/ns, inter_par);
t=floor(tx*N/2);
end

function sigmaT=stationary_model(x)
% The function that estimate sigma of the average process
N=length(x);

% Calculate the sigma(s) directly

ns=10; % number of points in fitting
ss=(1:ns)*floor(N/(2*ns));

% Direct calculation of sigma(s)
for jj=1:length(ss)
    j=ss(jj);
for i=0:N-j
   xxx(i+1)=mean(x(i+1:i+j)); 
end
xx(jj)=mean(xxx.^2);
clear xxx
end

% Fitting model
fun=@(x,T) exp((T.^x(1)-1)./(x(1)*T.^x(1)))./T;

options=optimoptions('lsqcurvefit','Display','none');
par = lsqcurvefit(fun,0.1,ss,xx,0,100,options);
b0=par(1); 
sigmaT=sqrt(exp((N.^b0-1)./(b0*N.^b0))./N);

%plot for testing the Statistical analaysis
%xxx=1:N;
%ypre=exp((xxx.^b0-1)./(b0*xxx.^b0))./xxx;
%plot(xxx,ypre,'k--',ss,xx,'*')




end

