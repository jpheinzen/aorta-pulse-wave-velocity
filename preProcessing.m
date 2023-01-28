
%% Info: 
% preProcessing - Takes a video and turns it into .tif files contained in a
%   folder
%
% See also vid2im, writeImage, postProcessing, gatherData.

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Nov. 12th, 2022

% TODO:
%   Finish Header

%% Main
ccc

vidName = 'example.mov';
folderName = 'exampleImages';

% load in video - should be quick(ish)
[mov, vidFolder] = vid2im(vidName,6000);  % Only loads in 6000 frames
% [mov, vidFolder] = vid2im(vidName);       % Loads in all the frames

% create a folder with folderName; place .tif files - will take longer
% Probably better to do this using external software.     
writeImage(mov,folderName);

% NOTE: all of this is done because some high speed videos can be > 16GB,
% and in order to make this run better on machines with lower RAM, each
% frame is only read in when it is needed, and then it is overwritten by
% the next frame. You could rewrite the code to only hold the videoReader
% object, and read in a frame at a time, but since our new camera outputs
% .tif files, this is how it was written. This way is also more conducive
% to future parallelization.

% % change directory to folder with images
% cd(folderName);