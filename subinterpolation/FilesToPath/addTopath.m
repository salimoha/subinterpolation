function addTopath()
% This function adds the current directory and all subdirectories to the MATLAB path
% this is equivalent to right-clicking in the folder browser and choosing "add
% selected folders and subfolders to path" except for we ignore .svn directories
% shahrouz.alm@gmail.com
% last update Aug 27 2015

%  Get the current working directory, and all its subdirectories
newpath = genpath(pwd);
%  Filter out .svn dirs
newpath = regexprep(newpath,':?[^:]*[/\\]\.svn[^:]*','');
newpath = regexprep(newpath,':?[^:]*[/\\]\.git[^:]*','');
%to the matlab path
addpath(newpath);
end
