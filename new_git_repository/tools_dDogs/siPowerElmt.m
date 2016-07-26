%% Solar Resource Assessment
%  Power plant analysis
%
%  Title: Power Forecasting Element
%
%  Description:
%    This function will extract a set time series of data from the power plant
%    as indicated by the time input, and it will then perform conversions of the
%    data into horizontal clear sky index using the Muneer and Boland models.
%    This data will then be returned in a uniform structure.
%
%  Input:
%	 target		siDeployment struct
%	 time		times for which to get power:
%				* Specify a single time to get power every 1 sec for the 30 seconds leading up to it
%				* Specify two or more times to get power every 1 sec over the
%				  spanned time range
%				* Note that by default, times will be rounded to the nearest second
%	 scaleFactor (optional) to convert readings in kW to W or vice-versa if desired
%				TODO: scaleFactor should probably be a property of the deployment setup?
%
function pwr_elmt = siPowerElmt( target, time, scaleFactor )
%% Process Input Arguments

% Time resolutions
% Desired data resolution
dres = 1; %[s]
% lookback time - this is the age of the oldest data we need to get
lookback = 30; %[s]

% Default is to convert kW readings to W.
if( nargin < 3 || isempty(scaleFactor) )
	scaleFactor = 1000; %[W/kW]
end
% if more than one time is specified, extract lookback and ires properties from the time series
t_end = time(end);
if( length(time) >= 2)
	t_end = max(time(:));
	lookback = round((t_end - min(time(:)))*24*3600); % in seconds
end

%% Store the time
pwr_elmt.time = (t_end + ((-lookback+dres):0)/24/3600)';

%% Retrieve Data
if false && ~isempty(regexpi(target.name,'^ucsd')) && isfield(target,'data_type') && strcmpi(target.data_type(1),'g')
	if strcmpi(target.data_type, 'ghi'), fprintf(' Ground data type: GHI sensor\n'), end
	if strcmpi(target.data_type, 'ghipv'), fprintf(' Ground data type: GHI sensor & PV\n'), end

	%% Do DEMROES sensors
	% Fetch DEMROES data, compute clear sky model GHI, divide measured GHI by modeled clear sky GHI to obtain clear sky index kt, to be used as
	% input into siForecastGHI's kt PDF procedure.
	[pwr_elmt.sensor.GHI, pwr_elmt.time] = getDEMROES( pwr_elmt.time(1), pwr_elmt.time(end), target);
	csk = clearSkyIrradiance( target.ground.position , pwr_elmt.time, target.tilt, target.azimuth );
	pwr_elmt.sensor.kt = pwr_elmt.sensor.GHI  ./ repmat( csk.gi(:) , [1 size(pwr_elmt.sensor.GHI,2)] );
	
	%% Do PV arrays if present
	% Currently assumes PV arrays located on UCSD on one PI server. Fetch PV data from UCSD PI server, compute plane of array clear sky
	% model GI. Model clear sky PV power using modeled clear sky GI and empirical efficiency curve (currently 4th order polynomial fit).
	% Divide measured PV power by modeled PV power to obtain kt.
	if strcmpi(target.data_type,'ghipv')
		pwr_elmt.inverter.power = target.ucsdpi.getPower(pwr_elmt.time(1), pwr_elmt.time(end),1);
		csk.pv.gi = ghi2gi( target.footprint.pv.azimuth , target.footprint.pv.tilt , target.footprint.pv.pos , csk.time , csk.ghi );
		clrPwrModel = csk.pv.gi'*target.footprint.pv.scaleFactor;
		clrPwrModel = polyval(target.footprint.pv.eff_coeff, clrPwrModel).*clrPwrModel;
		pwr_elmt.inverter.kt = pwr_elmt.inverter.power./clrPwrModel;
	end
elseif strcmpi(target.name,'redlands')
	%% we have 1 GHI data from a GHI sensor at PV022 and 4 power data sets. We will convert 4 power data sets to GHI and use them as GHI sensors
	%% load GHI data from the irradiance sensor
	
	%% convert GHI to kt
	
	%% load power data from the 4 power data sets
	% check if data exist
	% convert to kt
	
	%% concat kt for all 5 stations
	pwr_elmt.time2h = ( pwr_elmt.time(end) - lookback/24/3600 + 1/24/3600 ) :1/24/3600: pwr_elmt.time(end);
	pwr_elmt.sensor.kt;
	
elseif strcmpi(target.name, 'henderson')  %% works for Henderson
	% Get all the data between the last time step and this time step. Here the
	% presumed data resolution is 1sec.
	inverter = target.pi.obj.getPower(pwr_elmt.time(1), pwr_elmt.time(end),1);

	% Convert to matrix, time by inverter. Scale to SI units.
	pwr_elmt.inverter.power = cat(2,inverter(:).power)' * scaleFactor;

	%% Compute gi
	pwr_elmt.inverter.gi  = pwrPowerToGI( pwr_elmt.inverter.power' , target.design.power )';

	%% Compute the plane of array kt
	% need the clear sky irradiance first
	csk = clearSkyIrradiance( target.ground.position , pwr_elmt.time, target.tilt, target.azimuth );
	% dividing by clear sky gives kt
	pwr_elmt.inverter.kt = pwr_elmt.inverter.gi  ./ repmat( csk.gi , [1 size(pwr_elmt.inverter.gi,2)] );
else % new, standardized deployment format
	for di = 1:numel(target.data_type);
		dt = target.data_type{di};
		
		% fetch raw power data
		if(~isfield(target,'data_fcn')), error('siPowerElmt:noDataFunction', 'Please specify the functions to be called to fetch data in the deployment.conf file for ''%s'' deployment', target.name); end
		if(iscell(target.data_fcn))
			f = target.data_fcn{di};
		else
			f = target.data_fcn;
		end
		if(ischar(f)), f = str2func(f); end
		[raw, rawtime] = f( pwr_elmt.time(1), pwr_elmt.time(end), target);
		if(~iscell(rawtime))
			rawtime = {rawtime}; raw = {raw};
		end
		
		% put it at the desired timestamps
		pwr_elmt.(dt).power = nan(numel(pwr_elmt.time),size(target.design.([dt 'nominal']),1));
		% match timestamps to the nearest second
		% (alt algorithm would be to average/interpolate, but that's only really appropriate for sub-second resolutions)
		ci = 1;
		for si = 1:numel(rawtime)
			nc = size(raw{si},2);
			[ind, locb] = ismember(round((pwr_elmt.time-pwr_elmt.time(1))*3600*24),round((rawtime{si}-pwr_elmt.time(1))*3600*24));
			pwr_elmt.(dt).power(ind,ci:(ci+nc-1)) = raw{si}(locb(ind),:);
			ci = ci + nc;
		end
		
		% Compute to GI
		pwr_elmt.(dt).gi = nan(size(pwr_elmt.(dt).power));
		if(isfield(target.design,[dt 'nominal_is_poly']))
			m = target.design.([dt 'nominal_is_poly']);
			if(any(m)); fcns = target.design.([dt 'nominal_inv']); end
			for fi=1:numel(m)
				if(m(fi))
					pwr_elmt.(dt).gi(:,fi) = 1000*fcns{fi}(pwr_elmt.(dt).power(:,fi));
				else
					pwr_elmt.(dt).gi(:,fi) = pwr_elmt.(dt).power(:,fi)/target.design.([dt 'nominal'])(fi)*1000;
				end
			end
		else
			pwr_elmt.(dt).gi = pwr_elmt.(dt).power./repmat(target.design.([dt 'nominal'])(:)',numel(pwr_elmt.time),1)*1000;
		end
		
		% Compute Plane-of-Array kt
		tilt = target.design.([dt 'tilt']); azimuth = target.design.([dt 'azimuth']);
		csk = clearSkyIrradiance( target.ground.position, pwr_elmt.time(:), tilt', azimuth' );
		pwr_elmt.(dt).kt = pwr_elmt.(dt).gi ./ csk.gi;
		pwr_elmt.(dt).kt(csk.gi==0) = nan; % avoid infinite values
	end
end

end
