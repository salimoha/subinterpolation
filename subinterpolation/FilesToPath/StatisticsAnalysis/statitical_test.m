% Test the statistical analysis process
% In this script the statistical analysis process in checked
clear all
close all

x=artificial_dataset(100,0.1,10);
figure(3)
plot(x)
[mu,sigmaT,Initial_mod] = alpha_statitical_analyze(x,[0 0])