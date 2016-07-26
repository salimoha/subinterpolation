%% Sky Imager Forecast 3
%
%  Title: Sky imager forecast configuration
%
%  Authors: Ben Kurtz, Andu Nguyen, Bryan Urquhart
%
%  Description:
%    Gathers configuration code in one location to remove clutter from the
%    main forecasting script
%
%
function [ conf steps ] = si3ForecastConf( cfName )

conf = readConf(siGetConfPath( char(cfName) ),0);

if( ~isfield(conf,'startTime') || ~isfield(conf,'endTime') || ~(isfield(conf,'imager') || isfield(conf,'multiImager')) || ~isfield(conf,'deployment') || ~isfield(conf,'outputDir') )
	% probably should break this out by field so we can be more specific
	error 'one of the required config parameters was not specified';
end
if( ~isfield(conf,'solarZenithMax') )
	conf.solarZenithMax = 80; % or some other suitable default value
	warning('si:missingConfig_solarZenithMax','A Solar Zenith Angle threshold was not specified, so we are using the default (%i).  You should probably override this in forecast.conf',conf.solarZenithMax);
else
	conf.solarZenithMax = str2num(conf.solarZenithMax); %#ok<ST2NM>
end
if( ~isfield(conf,'step') )
	conf.step = 'all';
	warning('si:missingConfig_step','No step type was specified, so we will be doing ''%s''.  If this was not your intent, please specify a step in forecast.conf',conf.step);
end
if( ~isfield( conf , 'heightType' ) )
  conf.heightType = 'metar';
end

%% Determine which steps we want to perform during this run
% The idea here is that we define one 'goal' step, and then each goal has a list of steps it depends on in order.  See more details about how the concept goes right before the beginning of the main loop
stepMatrix.clouddecision = {'clouddecision_prev'};
if any( lower(conf.heightType(1))=='sm' ) % stereo cloud height needs cld dec
    stepMatrix.cloudheight = [stepMatrix.clouddecision, {'clouddecision'}];
else
    stepMatrix.cloudheight = {};
end
stepMatrix.projection = {'clouddecision_prev', 'clouddecision', 'cloudheight'};
stepMatrix.cloudmotion_elmt = {'projection_prev', 'clouddecision_prev', 'clouddecision', 'cloudheight', 'projection'};
stepMatrix.cloudmotion = [stepMatrix.cloudmotion_elmt, {'cloudmotion_elmt'}];
stepMatrix.powervalidation = {};
stepMatrix.forecast = [stepMatrix.cloudmotion, {'cloudmotion','powervalidation'}];
conf.step = lower(conf.step);
% right now, 'all' really means 'forecast'
if( strcmp(conf.step,'all') ); conf.step = 'forecast'; end
% 'opticalflow' is currently an alias for 'cloudmotion_elmt'
if( strcmp(conf.step,'opticalflow') ); conf.step = 'cloudmotion_elmt'; end
% make sure the user has specified a valid step type
if( ~isfield(stepMatrix,conf.step) )
	error('si:unknownStep','Unknown step type ''%s''.',conf.step);
end
% get the list of steps, appending the 'goal' to the end of the list
steps = stepMatrix.( conf.step );
steps = [steps, {conf.step}];
% set a default value for the cm_method param if it's missing
if( ~isfield(conf, 'cm_method') )
	conf.cm_method = 'CCM';
end

end
