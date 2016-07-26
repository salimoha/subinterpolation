function [pwr, time] = siPowerSeriesRemoveMissingData(pwr, tlimit)
% siPowerSeriesRemoveMissingData inspects a power series for missing data
%
% The goal of siPowerSeriesRemoveMissingData is to identifies data points near
% the end of the power series that are NaN but might have new updates.  It then
% removes those data points from the series, returning the updated series and
% the last time that should be considered to have valid data.  (Note: if the
% series is non-empty after truncation, the 'last time considered to have valid
% data' is also the last time in the series.)
%
% The algorithm checks for the oldest missing data for any station which
% has some valid data in the last M minutes (M is currently 5).  Stations
% which have no data in the last M minutes are considered to be offline
% longer term and are not considered candidates for updates, since they
% would likely result in large repeated fetches of power data without much
% hope of actually acquiring new data.  Only missing data at the end is
% considered.
%
% See Also: siSeries, siPowerElmt, siTruncateSeries

if(~exist('tlimit','var'))
	tlimit = 15; % minutes
end

% subfields besides 'time' are structs with kt data in them.
fn = fieldnames(pwr);
fn(strcmp(fn,'time')) = [];
if(size(pwr.time,2)>1)
	pwr.time = pwr.time'; pwr.time = pwr.time(:);
end

% concatenate struct fields.  Maybe this should be what siSeries does?  Oh well.
for fi = 1:numel(fn); f = fn{fi};
	if(isstruct(pwr.(f)) && numel(pwr.(f))>1) % should pretty much be all of them, since we've already removed time
		fn_inner = fieldnames(pwr.(f));
		newS = struct();
		for fj = 1:numel(fn_inner)
			ff = fn_inner{fj};
			newS.(ff) = vertcat(pwr.(f).(ff));
		end
		pwr.(f) = newS;
	end
end

% get a list of the most recent time index when each data field is not NaN
lastgoodall = [];
for fi = 1:numel(fn); f = fn{fi};
	datamask = ~isnan(pwr.(f).kt);
	lastgood = zeros(1,size(datamask,2));
	for ci = 1:numel(lastgood)
		x = find(datamask(:,ci), 1, 'last');
		if(~isempty(x))
			lastgood(ci) = x;
		end
	end
	lastgoodall = [lastgoodall lastgood];
end

% remove any stations that have no valid data in the last tlimit minutes
t = pwr.time;
t_ind = find(t(:)>t(end)-tlimit/60/24,1,'first');
lastgoodall(lastgoodall<t_ind) = [];

% calculate outputs
ind_remove = min(lastgoodall);
n = ceil((numel(t)-ind_remove));
time = t(1)-1/24/3600; % default time in case we empty the series
pwr = siTruncateSeries(pwr,n);
if(~isempty(pwr))
	time = pwr.time(end);
end

end
