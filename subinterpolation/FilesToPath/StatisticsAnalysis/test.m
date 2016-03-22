clear all
close all
clc

cd .. 
addTopath
cd StatisticsAnalysis

kt=0.1; N=500;
for n=1:N
   rho=exp(-kt*(1:n));
   sigma(n)=1+2*sum(rho)-2*sum(rho.*(1:n))/n;
end
%figure(1)
%plot(1:N,sqrt(sigma./(1:N)),'k-',1:N, sqrt(1./(1:N)),'b-', 1:N, sqrt(sigma(end)./(1:N)),'r-')


figure(1)
plot(1:N,sqrt(sigma./(1:N)),'b-')
hold on

for k=1:100
% Generate the Random process
[x]=artificial_dataset_exponential_corr(N,kt,10);
% perform the analysis
Initial_mod(1)=0; Initial_mod(2)=0;
[mu(k),sigmaT(k),Initial_Mod{k}] = alpha_statitical_analyze(x,Initial_mod);
end


