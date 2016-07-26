%% Solar Resource Assessment
%  Sky Imager Library
%
%  Title: Individual Instrument Configuration
%
%  Author: Bryan Urquhart
%  
%  Description:
%    This script will read the TSI config file and set various parameters
%    used by processing software. This will help keep settings consistent
%    among different processing codes by maintaining a single location with
%    basic system parameters.
%
function [cfg] = tsi_conf( cfgFile__ )
%% File Check
%
% Verify that the configuration file exists
%
% Convert to java file object if necessary
if( ~isa(cfgFile__,'java.io.File') )
  cfgFile__ = java.io.File( cfg_file__ );
end
% Check for file
if( ~cfgFile__.isFile() )
  error( [ 'Sky imager configuration file not present!' , 10 , ...
           '    Cannot perform continue with cfg file reading.' ] );
end

%% Config Setup
%
% Create bu configuration file reading object
cfgObj__ = bu.util.config.Configuration( cfgFile__ );
%
% Status checking
statusEnum__ = 'bu.util.config.Configuration$Status';
%
% Set configuration fields to be searched
%
% -- NAME --
NAME__ = 'NAME';

% -- POSITION --
LONGITUDE__ = 'LONGITUDE';
LATITUDE__  = 'LATITUDE';
ALTITUDE__  = 'ALTITUDE';
HEADING__   = 'HEADING';

% -- IMAGE PIXEL GEOMETRY --
CENTER_X__ = 'CENTER_X';
CENTER_Y__ = 'CENTER_Y';
RADIUS__   = 'RADIUS';

% -- OBJECT OCCLUSION --
% Shadowband
SHADOWBAND_LENGTH__         = 'SHADOWBAND_LENGTH';
SHADOWBAND_WIDTH__          = 'SHADOWBAND_WIDTH';
SHADOWBAND_END_WIDTH__      = 'SHADOWBAND_END_WIDTH';

% Geometric Calibration
SKY_IMAGE_CALIBRATION__ = 'SKY_IMAGE_CALIBRATION';

% Daily Log
SKY_IMAGER_DAILY_LOG__ = 'SKY_IMAGER_DAILY_LOG';

% Polygon file
POLYGON_FILE__             = 'POLYGON_FILE';

% % Clear Sky Libarary
% CLEAR_SKY_LIBRARY_FILE__   = 'CLEAR_SKY_LIBRARY';

% % Cloud Decision Configuration
CLOUD_DECISION_CONF__       = 'CLOUD_DECISION_CONF';

%% Retrieve the config variables
%
%                
% Read config file for longitude
status__ = cfgObj__.get(NAME__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  error( ['Could not retrieve cfg var: ' NAME__ ]);
else
  cfg.name = char( cfgObj__.getVal() );
end

% == POSITION ===
% Variable init
cfg.position = struct('longitude',-1, ...
                      'latitude' ,-1, ...
                      'altitude' ,-1, ...
                      'heading'  ,-1 );
%                
% Read config file for longitude
status__ = cfgObj__.get(LONGITUDE__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear cfg.position;
  error( ['Could not retrieve cfg var: ' LONGITUDE__ ]);
else
  cfg.position.longitude = double(java.lang.Double.valueOf( cfgObj__.getVal() ));
end
% Read config file for latitude
status__ = cfgObj__.get(LATITUDE__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear cfg.position;
  error( ['Could not retrieve cfg var: ' LATITUDE__ ]);
else
  cfg.position.latitude = double(java.lang.Double.valueOf( cfgObj__.getVal() ));
end
% Read config file for altitude
status__ = cfgObj__.get(ALTITUDE__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear cfg.position;
  error( ['Could not retrieve cfg var: ' ALTITUDE__ ]);
else
  cfg.position.altitude = double(java.lang.Double.valueOf( cfgObj__.getVal() ));
end
% Read config file for heading
status__ = cfgObj__.get(HEADING__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear cfg.position;
  error( ['Could not retrieve cfg var: ' HEADING__ ]);
else
  cfg.position.heading = double(java.lang.Double.valueOf( cfgObj__.getVal() ));
end
% =============
%
%
%
% == CENTER ===
% Variable init
cfg.center = struct('x',-1,'y',-1);
% Read config file for X
status__ = cfgObj__.get(CENTER_X__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear cfg.center;
  error( ['Could not retrieve cfg var: ' CENTER_X__ ]);
else
  cfg.center.x = double(java.lang.Integer.valueOf( cfgObj__.getVal() ));
end
% Read config file for Y
status__ = cfgObj__.get(CENTER_Y__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear cfg.center;
  error( ['Could not retrieve cfg var: ' CENTER_Y__ ]);
else
  cfg.center.y = double(java.lang.Integer.valueOf( cfgObj__.getVal() ));
end
% =============
%
%
% == RADIUS ==
% Read config file for radius
status__ = cfgObj__.get(RADIUS__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  error( ['Could not retrieve cfg var: ' RADIUS__ ]);
else
  cfg.radius = double(java.lang.Integer.valueOf( cfgObj__.getVal() ));
end
% =============
%
%
%
% == SHADOWBAND ===
% Variable init
cfg.shadowband = struct('length',-1,'width',-1,'endWidth',-1);
% Read config file for length
status__ = cfgObj__.get(SHADOWBAND_LENGTH__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear cfg.shadowband;
  error( ['Could not retrieve cfg var: ' SHADOWBAND_LENGTH__ ]);
else
  cfg.shadowband.length = double(java.lang.Integer.valueOf( cfgObj__.getVal() ));
end
% Read config file for width
status__ = cfgObj__.get(SHADOWBAND_WIDTH__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear cfg.shadowband;
  error( ['Could not retrieve cfg var: ' SHADOWBAND_WIDTH__ ]);
else
  cfg.shadowband.width = double(java.lang.Integer.valueOf( cfgObj__.getVal() ));
end
% Read config file for end width
status__ = cfgObj__.get(SHADOWBAND_END_WIDTH__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  clear cfg.shadowband;
  error( ['Could not retrieve cfg var: ' SHADOWBAND_END_WIDTH__ ]);
else
  cfg.shadowband.endWidth = double(java.lang.Integer.valueOf( cfgObj__.getVal() ));
end
% % Read config file for the solar azimuth fit of sky imager
% status__ = cfgObj__.get(SHADOWBAND_AZIMUTH_LOOKUP__);
% % Error handling
% if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
%   clear cfg.shadowband;
%   error( ['Could not retrieve cfg var: ' SHADOWBAND_END_WIDTH__ ]);
% else
%   cfg.shadowband.azimuthLookup = char( cfgObj__.getVal() );
% end
% =============
%
%
%
% == SKY IMAGER DAILY LOG ===
% Variable init
% Read config file for X
status__ = cfgObj__.get(SKY_IMAGER_DAILY_LOG__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  error( ['Could not retrieve cfg var: ' SKY_IMAGER_DAILY_LOG__ ]);
else
  cfg.files.daily_log_filename = char(cfgObj__.getVal());
end
% =============
%
%
%
% == POLYGON OCCLUSION FILE ===
% Variable init
% Read config file for X
status__ = cfgObj__.get(POLYGON_FILE__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  error( ['Could not retrieve cfg var: ' POLYGON_FILE__ ]);
else
  cfg.files.polygon_filename = char(cfgObj__.getVal());
end
% =============
%
%
%
% == CALIBRATION FILE ===
% Variable init
% Read config file for X
status__ = cfgObj__.get(SKY_IMAGE_CALIBRATION__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  error( ['Could not retrieve cfg var: ' SKY_IMAGE_CALIBRATION__ ]);
else
  cfg.files.calibration_filename = char(cfgObj__.getVal());
end
% =============
%
%
%
% % == CLEAR SKY LIBRARY FILE ===
% % Variable init
% % Read config file for X
% status__ = cfgObj__.get(CLEAR_SKY_LIBRARY_FILE__);
% % Error handling
% if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
%   error( ['Could not retrieve cfg var: ' CLEAR_SKY_LIBRARY_FILE__ ]);
% else
%   cfg.files.clear_sky_library_filename = char(cfgObj__.getVal());
% end
% % =============
%
%
%
% == CLOUD DECISION CONF FILE ===
% Variable init
% Read config file for X
status__ = cfgObj__.get(CLOUD_DECISION_CONF__);
% Error handling
if( status__ == javaMethod('valueOf',statusEnum__,'FAILURE') )
  error( ['Could not retrieve cfg var: ' CLOUD_DECISION_CONF__ ]);
else
  cfg.clouddecision.conf = char(cfgObj__.getVal());
end
% =============

%% Workspace clean up
%
% Remove any variables placed on the workspace by this script
% That are not intended to be persistent

clear cfgFile__;
clear cfgObj__;
clear index__;

clear LONGITUDE__;
clear LATITUDE__;
clear ALTITUDE__;
clear HEADING__;

clear CENTER_X__;
clear CENTER_Y__;
clear RADIUS__;

clear SHADOWBAND_LENGTH__;
clear SHADOWBAND_WIDTH__;
clear SHADOWBAND_END_WIDTH__;

clear SKY_IMAGE_CALIBRATION__;
clear SKY_IMAGER_DAILY_LOG__;
clear CLEAR_SKY_LIBRARY_FILE__;
clear POLYGON_FILE__;
clear GEOMETRY_FILE__;
clear CLOUD_DECISION_CFG__;

clear statusEnum__;
clear status__;