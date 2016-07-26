%% Solar Resource Assessment
%  Bryan Urquhart

%  Unit testing of sky imager code.
%  This script tests functionality on a single sky image
%

%% Clean up the workspace
clear all; close all; clear java; clear avi; clc;

%% Movie Params

doWriteMovie = true;
filename = 'c:/users/bryan/desktop/20111108.avi';

%% Initialization Scripts

% Start up the image server
def_imgsrv;

% Initialize the database
def_database_2;

% Initialize the sky imager
[cfg.instrument cal] = tsi_main_conf( java.io.File( sys.dir.tsi , 'config/tsi_main.conf' ) , ...
                                      sys , dat );

%% Sky Imager Analysis Configuration

cfg.clddec = siClouddecMainConf( 'cloud_decision.conf' , sys , cfg );
[ cfg.forecast sys.dir.output sys.file ] = ...
  siForecastConf( java.io.File( sys.dir.tsi , 'config/forecast.conf' ) );


%% Find all images within time range

% Set the instrument to use
instrument = 'tsi_pcs33';

% Set up time window in which to look for images
time.begin = bu.util.Time.datevecToTime([ 2011 11 08 00 00 00 ]);
time.end   = bu.util.Time.datevecToTime([ 2011 11 09 00 00 00 ]);
% Set the local timezone for movie timestamp
time.zone  = 'PST';
% Convert local times to UTC
time.begin = time.begin.toUTC(time.zone);
time.end   = time.end  .toUTC(time.zone);

[images time.val] = siGetRaw( instrument , time.begin , time.end , sys  );

if( images.size() == 0 ), return; end

%% Show Movie

% Set the Image Processing Toolbox preferences
% functions: iptgetpref, iptsetpref
% This affects how the image is displayed. These changes are persistent,
% meaning they are stored across matlab sessions
sky_imager_ipt_preferences;

% Count the number of images within zenith range
count = 0;

% Movie frames
movie_frames = cell( images.size() , 1 );

for idx = 1:images.length
  
  disp(' ');
  disp( ['           Image:  ' num2str(idx) ' of ' num2str(images.length)]);
  disp(  '       ------------------------');
  disp( ['Displaying image:  ' char(images(idx))]);
  
%   tic;
%     % ====================== PRELIMINARY ===================================
%   % Get the image file to open
%   file = images.get(index).img.getPath();
%   
%   % Get the time
%   time = sky_image_time( file );
%   %time_ = time.toUTC( dat.sky_img_log.get(time).timezone );
%   time_ = time.toUTC( timezone );
%   timeC = time_.toLocal( timezone );
%   % ======================================================================
%   disp( ['Preliminary step:     ' num2str(toc) ' seconds.'] );
  
  
  tic
  % ================== SOLAR GEOMETRY ====================================
  % Compute the solar angles
  sun = siSunPosition( time.val(idx) , cfg.instrument.(instrument).position );
  
  % If the zenith angle is greater than our limit, skip the image
  if( sun.zenith > cfg.forecast.geometry.solar_zenith_max ), continue; end
  % ======================================================================
  disp( ['Solar Geometry step:  ' num2str(toc) ' seconds.'] );
  
  
  tic;
  % ==================== IMAGE READING ===================================
  % Read the image
  img = imread( char(images(idx)) );
  % ======================================================================
  disp( ['Image reading:        ' num2str(toc) ' seconds.'] );
  
  
  % ==================== IMAGE PREPROCESSING =============================
  tic;
  
  % Image Mask
  mask = siMask( img , time.val(idx) , sun , ...
                 cfg.instrument.(instrument).center     , ...
                 cfg.instrument.(instrument).shadowband , ...
                 cal.(instrument).occlusions, ...
                 cal.(instrument).zenith , ...
                 cal.(instrument).azimuth );
                  

  % Interpolate masked region
  img = sky_image_interp( img , mask.optic , 'prefilter' , 3 , 'postfilter' , 3, 'edge' , 2 , 'type' , 'natural' );

  
  % Apply the mask
  %img = immultiply(img,mask.other);
  
  % Crop the image
  img = sky_image_crop( img , cfg.instrument.(instrument).center , cfg.instrument.(instrument).radius-10);
  
  % User Message
  disp( ['Image pre-processing: ' num2str(toc) ' seconds.'] );
  % ======================================================================

  
  tic;
  % ======================== IMAGE DISPLAY & FRAME CAPTURE ===============
  % Show the image
  sky_image_display( time.val(idx).toLocal(time.zone) , img );
  
  % Store frame in RAM
  movie_frames{idx} = getframe;
  
  % Pause for image display
  pause(0.001);
  % ======================================================================
  disp( ['Image display:        ' num2str(toc) ' seconds.'] );disp(' ');
  
  
  % Increment counter
  count = count + 1;
end

%% Create the movie

if( ~doWriteMovie ), return; end

% --- Movie Recording ---
aviobj = avifile( char(filename) , 'quality', 100 , 'compression' , 'none' , 'fps' , 8);

for index = 1:length(movie_frames)
  % Add to movie fram
  if( isempty( movie_frames{index} ) ), continue; end
  aviobj = addframe(aviobj,movie_frames{index}) ;
end

aviobj = close( aviobj );
