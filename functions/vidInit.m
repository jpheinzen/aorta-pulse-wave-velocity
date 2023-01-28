function [mov,vidName, numFrames, type, maxCVal, height, width] = vidInit
% Read Video
vidName = dir('*.tif');

try % would throw error if cLines doesn't have the fields
    % Lowers memory needed to hold in workspace -> file is big
    vidName = rmfield(vidName,["folder","date","bytes","isdir","datenum"]);
catch
end

% less strict on length, may not be in order though??
vidName = string({vidName(:).name}');
% strict that every name must have the same length
% vidName = string(cell2mat({vidName(:).name}'));

[~,~]= checkVidOrder(vidName,true);


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