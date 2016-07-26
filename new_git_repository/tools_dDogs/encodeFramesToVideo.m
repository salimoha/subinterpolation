function encodeFramesToVideo(inputDir, imagetype, mp4filename, overwrite, framerate, quality)
% encodeFramesToVideo turns a folder full of png (or other) images into an mpeg4 video
%	videos are encoded using x264 or avconv on linux.  On windows, we use matlab's VideoWriter class
%
% Usage:
%	encodeFramesToVideo(videoDir, imagetype, mp4filename, overwrite, framerate, quality)
%
%

%% Check output filename, create output directory if needed
if(~exist('overwrite','var') || isempty(overwrite))
	overwrite = false;
end
parentdir = fileparts(mp4filename);
if(~exist(parentdir,'dir'))
	mkdir(parentdir);
elseif(exist(mp4filename,'file') && ~overwrite)
	error('encodeFramesToVideo:outputExists','The selected output file already exists.  Cancelling!\nTo Encode anyway: encodeFramesToVideo(''%s'',''%s'',''%s'', true)', inputDir, imagetype, mp4filename);
end
% default image type is png
if(~exist('imagetype','var') || isempty(imagetype))
	imagetype = 'png';
end

%% video quality and frame rate options
if(~exist('framerate','var'))
	framerate = 15;
end
if(~exist('quality','var') && ~ispc())
	quality = 18;
end

%% On windows...
if(ispc())
	warning('encodeFramesToVideo:untested', 'Windows implementation is untested.  If it works for you, please remove this warning');
	
	writerObj = VideoWriter(mp4filename,'MPEG-4');
	writerObj.FrameRate = framerate;
	% linux programs take CRF quality, 0-51 with 0 lossless and 51 really shitty; try to rescale to matlab's 0-100
	if(exist('quality','var'))
		quality = (10-quality)/20*100;
		writerObj.Quality = min(max(quality,0),100); % bound it to 0 and 100
	end
	filelist = dir([inputDir '/*.' imagetype]);
	if(isempty(filelist)), error('encodeFramesToVideo:noImages','No image files were found'); end
	filelist = {filelist.name};
	%filelist(cellfun(@isempty,regexp({x.name},'\d{4}','once'))) = []; % this would only do digit filenames, like the linux encoder
	filelist = strcat(inputDir, '/', filelist);
	open(writerObj);
	for i = 1:numel(filelist);
		img = imread(filelist{i});
		writeVideo(writerObj,img);
	end
	close(writerObj);
	return;
end

%% Check version of linux
[status, linux_vers] = unix('lsb_release -sd');
if(status~=0)
	linux_vers = 'Unix';
end
[~, haveEnc] = unix('which x264 avconv');
haveEnc = cellfun(@(x)~isempty(regexp(haveEnc,x,'once')),{'x264','avconv'});
if(~any(haveEnc))
	error('encodeFramesToVideo:noEncoder', 'please install x264 or avconv to encode video');
end

if(~isempty(regexp(linux_vers,'Ubuntu 12.04','once')) && haveEnc(1))
	% ubuntu 12.04's avconv isn't linked against libx264; prefer x264 since it will give better encodes
	encoder = 'x264';
elseif(~isempty(regexp(linux_vers,'Ubuntu 14.04','once')) && haveEnc(2))
	% ubuntu 14.04's x264 isn't properly linked against libavconv (as of Aug 2014), so can't take image frames as input
	encoder = 'avconv';
elseif(haveEnc(2))
	% on other systems, prefer avconv if it's present, since it will at least encode
	% something, hopefully in the best codec, whereas x264 may fail entirely if not
	% linked against libavconv
	encoder = 'avconv';
else
	encoder = 'x264';
end

%% Run the encoder
framerate = num2str(framerate);
quality = num2str(quality);
if(strcmp(encoder,'x264'))
	% There's an old note in dailymovie.m about needing to use a newer version of libstdc++ than some older copies of matlab use?  I haven't seen that error in a long time, so I think it's okay now.
	% note: position of framerate flag seems to matter less here, but this one should work
	unix(['x264 --fps ' framerate ' "' inputDir '"/%04d.' imagetype ' --crf ' quality ' -o "' mp4filename '"']);
else
	% note: framerate comes before input; otherwise frames are simply dropped from the stream prior to output
	unix(['avconv -r ' framerate ' -i "' inputDir '"/%04d.' imagetype ' -c:v libx264 -crf ' quality ' "' mp4filename '"']);
end

end
