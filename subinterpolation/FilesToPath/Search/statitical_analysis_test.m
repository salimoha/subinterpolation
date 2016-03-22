clear all
close all

tic
[t,zf]=Read_log_file('Zforces.log');
toc
[mu sigma]=alpha_statitical_analyze(zf,[0 0]);