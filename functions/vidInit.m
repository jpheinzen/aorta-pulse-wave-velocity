function [mov,vidName, numFrames, type, maxCVal, height, width] = vidInit(directory)
% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Dec. 31st, 2022

% TODO:
%   Finish Header

fileNames = '*.tif';

% if you don't input anything, you'd need to be in the directory with the
% .tif files but you can input a directory (or path) to specify where to
% pull the .tif files should be pulled from.
if nargin == 1
    fileName = fullfile(directory,fileNames);
end

% Read Video
vidName = dir(fileName);

try % would throw error if vidName doesn't have the fields
    % Lowers memory needed to hold in workspace -> file is big
    vidName = rmfield(vidName,["folder","date","bytes","isdir","datenum"]);
catch
end

% less strict on length, may not be in order though??
vidName = string({vidName(:).name}');
% strict that every name must have the same length
% vidName = string(cell2mat({vidName(:).name}'));

[~,~]= checkVidOrder(vidName,true,true);


% Video Initialization
numFrames = length(vidName);
% Preallocate memory
frame = imread(vidName(1)); % could also use importdata, but from my 
                            % testing, imread is slightly faster
type = class(frame);
% maximum color value allowed by type
% eg for uint8, max value is 2^8
maxCVal = 2^str2double(erase(type,'uint'))-1;

[height,width,depth] = size(frame);

mov = struct('cdata',zeros(height,width,depth,type),'colormap',[]);
% mov(frameReadNum).cdata = readFrame(vidObj);

if depth==3
    mov.cdata = frame;
else
    % Needed since .tif is b&w
    mov.cdata = repmat(frame,[1,1,3]);
end
end