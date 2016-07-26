function [data]=siCheckDataCons(data,step_,FC_conf,varargin)
%This function was created by Keenan Murray on 7/30/14 to check data for
%consistancy of cloud motion algorithms during a data run and with
%loaded saved data. The data check is dependent upon which step in the data
%is being executed at calling time.


error_flag=0;
switch step_
	
	case 'cloudmotion_elmt'

		%Check to see if a "motion_method" field exists and check data
		%agreement
		if isfield(data,'motion_method')
			if strcmp(FC_conf.cm_method,'BOTH')
				if ~isfield(data,'ccm_method') || ~strcmp(data.motion_method,'OF') || ~strcmp(data.ccm_method.motion_method,'CCM')
					error_flag=1;
				end
			elseif ~strcmp(data.motion_method,FC_conf.cm_method)
				error_flag=1;
			end
			
		else
			
		%If the "motion_method" field does not exist, determine the motion
		%type based upon wiether the OF "backward" or "forward" field is present.
			if isfield(data,'backward') || isfield(data,'forward')
				data.motion_method='OF';
			else
				data.motion_method='CCM';
			end
			
		end
		
		%Throw an error if there is inconsistancies in cloud motion algorithms
		%in the data and forcast.conf
		if error_flag
			error(['Loaded saved data uses ' data.motion_method ' cloud motion,  data code uses ' FC_conf.cm_method ' cloud motion'])
		end
		
	case 'forecast'
		%Check loaded data for consistancy of data with current set data cloud
		%motion algorithm. Pass in a variable with a structure field of "motion_method"
		% (Such as cm_elmt) as a varargin to  set loaded data as OF or CCM
		% if the "motion_method" field does not exist in the forcast
		% structure
		error_flag=0;
		
		%If the data data has the new field "motion_method", confirm it
		%matches with the algorithm set in forecast.conf
		if isfield(data,'motion_method')
			if strcmp(FC_conf.cm_method,'BOTH')
				if ~isfield(data,'ccm_method') || ~strcmp(data.motion_method,'OF') || ~strcmp(data.ccm_method.motion_method,'CCM')
					error_flag=1;
				end
			elseif ~strcmp(data.motion_method,FC_conf.cm_method)
				error_flag=1;
			end
		else
			
			%pass in cm_elmt variable as a varargin to determine weither loaded data is
			%OF or CCM
			if nargin>0 && isfield(varargin{1},'motion_method')
				data1=varargin{1};
				%The "cloudmotion_elmt" section adds a field "motion_method" to
				%"cm_elmt" based up subfield names if "motion_method" does not
				%exist due to the data being produceds from older data code.
				if strcmp(data1.motion_method,'OF')
					data.motion_method='OF';
				else
					data.motion_method='CCM';
				end
			end
			
		end
		
		%Throw an error if there is inconsistancy in the cloud motion choice
		%and data
		if error_flag
			error(['Loaded saved data uses ' data.motion_method ' cloud motion,  forecast code uses ' FC_conf.cm_method ' cloud motion'])
		end
		
		
	otherwise

	disp(['No data checks established for step: ' step_])
end

end