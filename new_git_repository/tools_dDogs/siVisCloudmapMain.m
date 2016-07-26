%% Solar Resource Assessment
%  Sky Imager Library
%
%  Title: Sky Imager Forecasting Cloudmap Visualization Coordination Script
%  
%  Author: Bryan Urquhart
%
%  Description:
%    Generates plots of cloudmap for post processing visualization of forecast
%    output. This is just a coordination script which iterates through and loads
%    all the data. The actual plot output is confined to a single subroutine
%    that can potentially be integrated into a visualization screen.
%
%% Clean up the workspace
clear all; close all; clear java; clear avi; clc;

%% Initialization Scripts

% Start up the image server
def_imgsrv;

% Initialize the database
def_database_2;

% Initialize the sky imager
[cfg.instrument cal] = tsi_main_conf( java.io.File( sys.dir.tsi , 'config/tsi_main.conf' ) , ...
                                      sys , dat );

%% Forecast Parameters (historical forecast only)

% User message
disp( 'Getting images from imageserver' ); timer_ = tic;

time.begin = bu.util.Time.datevecToTime([ 2011 10 25 00 00 00 ]);
time.end   = bu.util.Time.datevecToTime([ 2011 10 26 00 00 00 ]);
% time.begin = bu.util.Time.datevecToTime([ 2007 06 05 22 00 00 ]); %2007-06-05 22:56:00.000
% time.end   = bu.util.Time.datevecToTime([ 2007 06 06 23 00 00 ]); %2007-06-06 22:56:00.000
time.zone  = 'PST';
time.begin = time.begin.toUTC(time.zone);
time.end   = time.end  .toUTC(time.zone);
instrument = 'tsi_pcs33';

[images time.val imgtree ] = siGetRaw( instrument , time.begin , time.end , sys );

% % Change times to UTC (only for old data - DON'T USE OPERATIONALLY!!!)
% for idx = 1:time.val.length
%   time.val(idx) = time.val(idx).toUTC(time.zone);
% end

% User message
disp([ '  retrieving images took ' num2str(toc(timer_)) ' seconds.']);

if( images.size() == 0 ) , return; end
                                    
%% Forecast Configuration

% This configuration applies to historical forecasts only. Notice the time
% argument that is provided to siForecastConf().

% Configure Cloud Decision
cfg.clddec = siClouddecMainConf( 'cloud_decision.conf' , sys , cfg );
% Configure Forecast
[ cfg.forecast sys.dir.output sys.file sys.filename ] = ...
  siForecastConf( java.io.File( sys.dir.tsi , 'config/forecast.conf' ) , 'time' , time.begin );

%% Preprocessing

% Generate the forecast output folder if it does not currently exist (historical
% only)
if( ~sys.dir.output.main.isDirectory() )
  error( [ 'Non existent directory: ' char(sys.dir.output.main) char(10) ...
           '   selected for post processing visualization' ]);
end

% Use instrument parameters to crop azimuth/zenith calibrations
cal = siPreprocessCal( cfg , cal );


switch( instrument )
  case {'tsi_pcs33','tsi_pcs41'}
    sys.file.groundmap = java.io.File( sys.drive.nas2 , ...
      'projects/henderson/groundmap.mat' );
end
ground = sky_image_ghi_forecast_groundmap( sys.file.groundmap , ...
                                           cfg.forecast.groundmap , cfg , dat );

%% Get Power Data
% --> HISTORICAL ONLY <--
% --> CHANGE SECTION FOR OPERATIONAL <---

% THIS SECTION NEEDS TO BE IN A CONF FILE!!!!!!!!!!!!
% !!!!!!!!

% Set power lookback
cfg.power.timehistory = 10*60;
cfg.power.plant.panels.tilt    = 25;
cfg.power.plant.panels.azimuth = 180;
cfg.forecast.kt.binsize = 0.05;

% Load the groundmap
tic;
file = java.io.File( sys.drive.nas2 , 'projects/henderson/groundmap.mat' );
load( char(file) );

% Load the copper mountain layout
file = java.io.File( sys.drive.nas2 , 'projects/henderson/coppermountainlayout.mat' );
load( char(file) );

% Load the copper mountain layout
file = java.io.File( sys.drive.nas2 , 'projects/henderson/coppermountain_footprint.mat' );
load( char(file) );

% Load the nominal power
file = java.io.File( sys.drive.nas2 , 'projects/henderson/nominalpower.mat' );
load( char(file) );

toc

sys.dir.output.power = java.io.File( sys.dir.output.main , 'power' );
sys.filename.powerelement = 'power_elmt';
sys.filename.power        = 'power';

cfg.power.plant.layout    = coppermountain; clear coppermountain;
cfg.power.plant.footprint = footprint;      clear footprint;
cfg.power.nominal         = nominal;        clear nominal;
                                         
%% Generate & Store Cloudmap Analysis Plots

imgdir = java.io.File( sys.dir.output.cloudmap , 'img' );
if( ~imgdir.isDirectory() ), imgdir.mkdirs(); end
fileroot = 'cloudmapimg_';

for idx = 1:images.size()
  
  % User Messages
  disp(' ');
  disp( ['Processing image:  ' num2str(idx) ' of ' num2str(images.length) ' - ' char(time.val(idx))]);
  
  % Generate filenames
  filename{1} = java.io.File( imgdir , [fileroot  char(time.val(idx).toStringI()) '.fig' ] ); %#ok<SAGROW>
  filename{2} = java.io.File( imgdir , [fileroot  char(time.val(idx).toStringI()) '.emf' ] ); %#ok<SAGROW>
  
  % Check for file existence
  if( filename{1}.isFile() && filename{2}.isFile() ), continue; end;
  
  % Get the solar zenith and azimuth angles
  sun = siSunPosition( time.val(idx) , cfg.instrument.(instrument).position );
  
  % Check zenith angle
  if( sun.zenith > cfg.forecast.geometry.solar_zenith_max ), continue; end
  
  % Load an image
  img = imread(char(images(idx)));
  
  % Get the save filenames
  file = siSaveForecast( sys , time.val(idx) , [] , [] , [] , [] , [] , [] , true );
  
  % Check for presence of cloudmap files
  if( ~file.cloudmap.isFile() )
    java.lang.System.err.println( ['Warning: Missing cloudmap ' char(file.cloudmap) ] );
    continue;
  end
  
  % Load the cloudmap
  load( char(file.cloudmap) );
  
  % Check for empty cloudmap structure
  if( isempty( cloudmap ) )
    java.lang.System.err.println( [ 'Warning: Cloudmap ' char(file.cloudmap.getName()) ' not present.'] );
    continue;
  end
  
  % Generate Cloudmap Plot
  [h txt] = siVisCloudmap( instrument , time.val(idx) , time.zone , img , cloudmap , cfg , cal );
  
  % Save
  pause( 0.001 ); % Pause briefly to allow rendering (sometimes helps)
  try
    saveas(h,char(filename{1}),'fig');
  catch e
    java.lang.System.err.println( 'Warning: could not save figure as fig. Check for open files!' );
  end
  try
    % Shift labels over because save as emf screws their position
    for index = 1:length(txt)
      ipos = get( txt{index} , 'Position' );
      if( ipos(1) < 0 )
        ipos(1) = ipos(1) - 150;
      end
      ipos(1) = ipos(1) - 25;
      set( txt{index} , 'Position' , ipos );
    end
    saveas(h,char(filename{2}),'emf');
  catch e
    java.lang.System.err.println( 'Warning: could not save figure as emf. Check for open files!' );
  end
end
