%% Solar Resource Assessment
%  Sky Imager Library
%
%  Title: TSI Main Configuration
%
%  Author: Bryan Urquhart
%
%  Description:
%    This script runs standard configuration commands for the sky imager.
%    It collects all the configuration processes for each instrument into
%    one file.
%
function [instrument cal dat] = tsi_main_conf( filename , sys , dat )
%% Process input arguments

% Convert to string if the filename is actually a java file object. Casting to a
% char within matlab actually calls the java objects toString method prior to
% casting to a matlab character array
filename = char(filename);

%% Configuration Setup

cfg_dir__          = java.io.File( sys.dir.tsi , 'config' );

% == Main TSI configuration file ==
cfg_file__ = java.io.File( filename );

% Create bu configuration file reading object
cfgObj__ = bu.util.config.Configuration( cfg_file__ );

% Status checking
statusEnum__ = 'bu.util.config.Configuration$Status';

%% Configuration Parameters

INSTRUMENT__ = 'INSTRUMENT';
CONF_FILE__  = 'CONF_FILE';

%% Main Configuration

% Read out instrument names
status__ = cfgObj__.getMatrix( [] , [] , INSTRUMENT__ );
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear instrument.names;
  error( ['Could not retrieve cfg label/matrix: ' INSTRUMENT__ ]);
else
  instrument.names = cfgObj__.getCfgVarMatrix();
  for idx__ = 1:length( instrument.names )
    temp__(idx__) = instrument.names(idx__,1);  %#ok<AGROW>
  end
  instrument.names = temp__;
end

% Get the name of the conf file
status__ = cfgObj__.get( CONF_FILE__ );
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear instrument.conf_file;
  error( ['Could not retrieve cfg var: ' CONF_FILE__ ]);
else
  instrument.conf_file = cfgObj__.getVal();
end

%% Instrument specific configuration
% Process each instrument
for idx__ = 1:length( instrument.names )
  
  % User message
  t_config = tic;
  disp([ 'Reading ' char(instrument.names(idx__)) ' config file.' ]);
  
  % Construct the folder
  cfg_file__ = java.io.File( cfg_dir__ , instrument.names(idx__) );
  % Check for existence of instrument
  if( ~cfg_file__.isDirectory() )
    java.lang.System.err.println( ...
      [ 'The instrument: '  char(instrument.names(idx__)) char(10) ...
        '   does not have a configuration directory!' ] );
    continue;
  end
  
  % Construct the individual config file object
  cfg_file__ = java.io.File( cfg_file__ , instrument.conf_file );
  if( ~cfg_file__.isFile() )
    java.lang.System.err.println( ...
      [ 'The instrument: '  char(instrument.names(idx__)) char(10) ...
        '   does not have a configuration file!'  char(10) ...
        '   This instrument will NOT be configured.' ] );
    continue;
  end
  
  % Run instrument specific configuration
  instrument.(char(instrument.names(idx__))) = tsi_conf( cfg_file__ );
  
  % User Message
  disp([ '   read took ' num2str(toc(t_config)) ' seconds.' char(10) ]);
  
end

%% Secondary Configuration Scripts

% Run secondary configuration scripts
%sky_imager_cfg_cloud_decision;

% Set iptprefs - image processing toolbox
%sky_imager_ipt_preferences;

%% Perform Additional Configurations


% Process each instrument
for idx__ = 1:length( instrument.names )
  
  % User message
  t_config = tic;
  disp([ 'Initializing ' char(instrument.names(idx__)) '.' ]);
  
  % Construct the instrument config folder
  cfg_file__ = java.io.File( cfg_dir__ , instrument.names(idx__) );
  % Check for existence of instrument
  if( ~cfg_file__.isDirectory() )
    java.lang.System.err.println( ...
      [ 'The instrument: '  char(instrument.names(idx__)) char(10) ...
        '   does not have a configuration directory!' ] );
    continue;
  end
  
  % ====== Sky Imager Daily Log =========================================
  % Sky Imager Daily Log File
  instrument.(char(instrument.names(idx__))).files.daily_log_file = ...
        java.io.File( cfg_file__ , ...
        instrument.(char(instrument.names(idx__))).files.daily_log_filename );
  % Read the log if it exists
  if( instrument.(char(instrument.names(idx__))).files.daily_log_file.isFile() )
    % Read in the daily log
    dat.(char(instrument.names(idx__))).sky_img_log = ...
      bu.science.instrument.skytrack.SkyImagerDailyLog( cfg.files.daily_log_file );
  end
  % =====================================================================
  
  
  % ====== Sky Imager geometric mapping =================================
  instrument.(char(instrument.names(idx__))).files.calibration_file = ...
      java.io.File( cfg_file__ , ...
      instrument.(char(instrument.names(idx__))).files.calibration_filename );
  % Load calibrations
  if( instrument.(char(instrument.names(idx__))).files.calibration_file.isFile() )
    temp__ = load( char(instrument.(char(instrument.names(idx__))).files.calibration_file.getPath()) );
    cal.(char(instrument.names(idx__))) = temp__.cal;
  else
    java.lang.System.err.println( [ 'Warning: calibration for ' ...
      char(instrument.names(idx__)) ' could not be loaded.' ] );
  end
  % =====================================================================
  
  
  % ====== Sky Imager Occlusion file ====================================
  instrument.(char(instrument.names(idx__))).files.polygon_file = ...
    java.io.File( cfg_file__ , ...
      instrument.(char(instrument.names(idx__))).files.polygon_filename );
  % Load Occlusions from file
  if( instrument.(char(instrument.names(idx__))).files.polygon_file.isFile() )
    cal.(char(instrument.names(idx__))).occlusions = ...
      sky_imager_polygonal_occlusions( ...
        instrument.(char(instrument.names(idx__))).files.polygon_file );
  else
    java.lang.System.err.println( [ 'Warning: occlusions file for ' ...
      char(instrument.names(idx__)) ' could not be loaded.' ] );
  end
  % =====================================================================
  
  
%   % ====== Clear sky Library  ===========================================
%   cfg_CSL_i_dir__ = java.io.File( cfg_CSL_dir__ , instrument.names(idx__) );
%   instrument.(char(instrument.names(idx__))).files.clear_sky_library_file = ...
%     java.io.File( cfg_CSL_i_dir__ , ...
%     instrument.(char(instrument.names(idx__))).files.clear_sky_library_filename );
%   % Load clear sky library from file
%   if( instrument.(char(instrument.names(idx__))).files.clear_sky_library_file.isFile() )
%     
%     %
%     %
%     % === ADD LOADING OF CSL!! ===
%     %
%     %
%     
%   else
%     java.lang.System.err.println( [ 'Warning: clear sky library for ' ...
%       char(instrument.names(idx__)) ' could not be loaded.' ] );
%   end
%   % =====================================================================
  
  % User Message
  disp([ '   initialization took ' num2str(toc(t_config)) ' seconds.' char(10) ]);
  
end

%% Workspace clean up
%
% Remove any variables placed on the workspace by this script
% That are not intended to be persistent

clear cfg_dir__;
clear cfg_analysis_dir__;
clear cfg_CSL_dir__;
clear cfg_CSL_i_dir__;

clear cfg_file__;

clear cfgObj__;
clear statusEnum__;
clear status__;
clear idx__;
clear temp__

clear t_config;

% Clear parameters
clear INSTRUMENT__;
clear CONF_FILE__;