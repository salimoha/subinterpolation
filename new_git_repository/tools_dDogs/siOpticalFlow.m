function optic = siOpticalFlow(cloudmap_prev,cloudmap,para)

% Author: Chi Wai Chow
% Input: cloudmap
% Output: optical flow field per second
%
% 
% cloud motion convention: +ve down & right
%
% Last modified: 5/21/2014
%%

%% Post-Processing of data

%Modifcations by Keenan Murray (k8murray@ucsd.edu;kmurray@mtu.edu) on July
%17th 2014
% Store the time, height, and imager name, and sky for loading data in 
%"cloudmotion_elmt" step
optic.time = cloudmap.time;
optic.height = cloudmap.height;
optic.imager = cloudmap.imager;
optic.sky=cloudmap.sky;
time.diff = (cloudmap.time - cloudmap_prev.time)*24*3600; % time difference in sec
velocity.unit = cloudmap.sky.dx / time.diff;

    % use rbr - rbrcsb image
    im1 = cloudmap_prev.rbrmap-cloudmap_prev.cslmap;
    im1(isnan(im1)) = 0;
    im2 = cloudmap.rbrmap-cloudmap.cslmap;
    im2(isnan(im2)) = 0;
    % assgin zero optical flow when small cloud fraction
    if cloudmap.fraction<0.05
        optic.forward.vx = zeros(size(cloudmap.map)); optic.forward.vy = zeros(size(cloudmap.map));
        optic.backward.vx = zeros(size(cloudmap.map)); optic.backward.vy = zeros(size(cloudmap.map));
        fprintf('clear sky: no optical flow estimation is performed');
    else
    % motion estimation with optical flow with a choice of
    % different methods (only Liu's is available now)
        switch(para.op_choice)
            case 'Liu'
            % to make sure we capture the duration in between images
            time.sep = (cloudmap.time - cloudmap_prev.time)*86400; 
            if para.tr
                % forward OF
                [vx,vy,warpI2] = Coarse2FineTwoFrames(im1,im2,para.flow); % notice the order of input 1&2
                [vx,vy]=op_LiuCorrect(vx,vy,cloudmap,cloudmap_prev);
                optic.forward.vx = vx; optic.forward.vy = vy;
            end
            clear vx vy
            % backward OF
            % backward OF is used because of the output
            % positions of the optical flow field
            [vx,vy,warpI2] = Coarse2FineTwoFrames(im2,im1,para.flow); % notice the order of input 1&2
            [vx,vy]=op_LiuCorrect(vx,vy,cloudmap,cloudmap_prev);
            optic.backward.vx = -vx; optic.backward.vy = -vy; % pixel per frame
            optic.para = para;
        end
        
        % to visualize the flow
        % figure, imagesc(flowToColor(cat(3,vx,vy)));
        
	end
	
	
	%Calculate mean speed and direction of clouds
	%% Mean Flow Properties - Backward

% Compute first two moments of the magnitude flow pattern 
u_ = optic.backward.vx(~isnan(optic.backward.vx));  
v_ = optic.backward.vy(~isnan(optic.backward.vy));  

speed = sqrt( u_.^2 + v_.^2 );
optic.speed.mean = mean(speed);
optic.speed.std  = std (speed);

% Compute the azimuth, mean azimuth, and standard deviation of the azimuth
azimuth = siCM_azimuth( u_ , -v_ ); %The negative sign is added as in the CCM method the v component is flipped.

% Store the mean and azimuth
optic.azimuth.mean = azimuth.mean * 180/pi;
optic.azimuth.std  = azimuth.std  * 180/pi;

%% Average flow speed

% Compute the vector average flow speed
% convention: north positive, east positive
optic.u.pixel = nanmean(optic.backward.vx);
optic.v.pixel = nanmean(optic.backward.vy);

% Compute the sky velocity
optic.u.raw = optic.u.pixel * velocity.unit;
optic.v.raw = optic.v.pixel * velocity.unit;
optic.u.sky = optic.u.pixel * velocity.unit;
optic.v.sky = optic.v.pixel * velocity.unit;
	