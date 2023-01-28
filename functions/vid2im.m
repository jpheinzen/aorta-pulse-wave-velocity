function [mov, vidFolder] = vid2im(vidName,nMaxFrames)
%% Info
% vid2im - Video to Images. Converts a video file into a structure
%               containing all the data from each frame.
%
% Usage:
%   vid2im(vidName)     Default to run vid2im method
%
% Inputs:
%   vidName (1,1)   Name of the video to be processed. Must include file
%                       extension.
%   nMaxFrames (1,1)    Maximum number of frames that will be read
%
% Outputs:
%   mov     (1,NumFrames)    Structure containing the following:
%       cdata   (Height,Width,3)    Data from each file containg RGB
%                                       values where (:,:,1) is R
%                                                    (:,:,2) is G
%                                                    (:,:,3) is B
%       colormap (1,1)      Empty colormap data
%
% See also writeImage, preProcessing.

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Oct. 15th, 2022

% TODO:
%   Finish Header
%   add functionality to choose a starting frame

%% Main 
if(nargin == 1)
    nMaxFrames = inf;
elseif (nargin ~= 2)
    error(sprintf(['Incorrect number of inputs to vid2im\n'...
        'Need to input a name for the video to be processed']))
end

folder = fileparts(which(vidName));             % Find folder of video
fullFilePath = fullfile(folder, vidName);       % Full file path
% Check to see that it exists.
if ~exist(fullFilePath, 'file')
    error(strcat("file '%s' is not located in the MATLAB ",... 
        "path. Current diectory is:\n%s"),vidName,pwd);
end

% Create a VideoReader Object to read data from vidName file
vidObj = VideoReader(vidName);  

% height and width of the video.
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;


% This formula above gives only an "estimate" of the number of frames. For
% fixed frame-rate files, the value will be within 1 of the actual number
% of frames due to rounding issues. Many video files are variable
% frame-rate and so for those files the actual number of frames can be more
% or less than the estimated value. To get the exact value, you have no
% choice but to scan through the entire file
numFrames = min(ceil(vidObj.FrameRate*vidObj.Duration),nMaxFrames);

% Preallocate memory
mov = struct('cdata',zeros(vidHeight,vidWidth,3),'colormap',[]);
mov = repmat(mov,1,numFrames);

% % Read one frame at a time until the end of the video is reached.
k = 0;
while hasFrame(vidObj) && k < nMaxFrames
    k = k+1;
    mov(k).cdata = readFrame(vidObj);
    printProgress(k,min(numFrames,nMaxFrames),'Importing Video')
end

mov = mov(1:k);         % in case the estimate was an overestimate
vidFolder = folder;     % for possible future reference
end













