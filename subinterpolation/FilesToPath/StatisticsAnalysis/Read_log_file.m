function [t,zf]=Read_log_file(filename)

fid = fopen(filename);

% Skip the first 18 lines
for k=1:18
    tline = fgets(fid);
end

k=1;
% Read from line 19 to end
while 1
C = strsplit(tline);
zf(k)=str2num(C{7});
t(k)=str2num(C{4});
k=k+1;
tline = fgets(fid);
if tline==-1
    break
end
end

fclose(fid);
end