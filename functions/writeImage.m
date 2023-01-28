function writeImage(images,imageName,fileType)
%% Info: 
% writeImage: Writes array of images to disk as multiple images and creates
%   new folder with name of imageName
%
% See also vid2im, preProcessing.

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Oct. 15th, 2022
%
% TODO:
%   Finish Header
%   input checking

%% Main
if nargin < 3
    fileType = '.tif';
end

if isstruct(images)
    [status,msg] = mkdir(imageName);
    if ~status
        error(msg)
    end
    
    folderName = strcat(imageName,'\');
    numFrames = length(images);
    % makes sure there are the correct number of 0's to pad number
    % This is necessary in the analysis to turn the list of 
    formatStr = sprintf('-%%0%i.f',length(num2str(numFrames)));

    for ii = 1:numFrames
        imwrite(images(ii).cdata,strcat(folderName,imageName,sprintf(formatStr,ii),fileType));
        
        printProgress(ii,numFrames,'Writing Images')
    end

else    % single image
    imwrite(images,strcat(imageName,fileType),'tif');
end
end

