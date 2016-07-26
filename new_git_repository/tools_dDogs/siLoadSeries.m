function [fSeries pwrSeries trSeries] = siLoadSeries(outputDir)
% load the summary outputs from the most recent forecast run
% output file is indexed from 1 to 999 based on the order of the run
% output:
%           fSeries:        forecast series
%           pwrSeries:      power series
%           cmSeries:       cloud motion series
%
% Note that siLoadSeries tries to load the most recent of each of the series individually, which may not be exactly what you were after

% Check for previous runs to generate new index
flist = dir( [outputDir '/forecast*.mat'] );
fid = max(cellfun(@(s)str2double(s(10:12)),{flist.name}));
flist = dir( [outputDir '/power*.mat'] );
pid = max(cellfun(@(s)str2double(s(7:9)),{flist.name}));
flist = dir( [outputDir '/trajectory*.mat'] );
eid = max(cellfun(@(s)str2double(s(12:14)),{flist.name}));

fSeries = loadSeries('forecast',fid);
pwrSeries = loadSeries('power',pid);
trSeries = loadSeries('trajectory',eid);

	function value = loadSeries(name, id)
		name = [outputDir '/' name '_' sprintf('%03d',id) '.mat'];
		if(exist(name,'file'))
			value = load(name);
		else
			value = [];
		end
	end

end

