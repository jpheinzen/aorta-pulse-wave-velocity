
%% Info:
% gatherData - Takes a video (as a collection of .tif images) and obtains
%   the color values at normal lines along the length of a tube over time
% 
% Variables:
% n         (1,1)
%   The name + file type of the video to be processed. E.g. not 'videoName'
%   but 'videoName.mov'
% fps           (1,1)
%   The number of frames per second of the video. For our camera this is
%   either 600 or 1200.
% wt            (1,3)
%   The (r,g,b) weighting that specifies how the weighting of the video is
%   made. E.g. if wt = [3,2,1]; totalWeight = 3*r + 2*g + 1*b. This don't
%   really do anything if the image is black and white but still should be
%   set to something reasonable.
% lineLength    (1,1)
%   The one-sided length of the lines that are made across the aorta to track the
%   color.
% nMax          (1,1)
%   The maximum number of frames from the video that will be read in and
%   alazyzed. If nMax is greater than the maximum number of frames
%   contained in the video, all of the frames from the video will be read.
%   nMax can be set to infinity.
% vidName       (1,1)
%   See n.
% nMaxFrames    (1,1)
%   see nMax.
% deleteRegion  (1,1)
%   T/F. If true, a prompt will pop up to have the user manually delete
%   an unwanted region from the first frame of the video. To do this, a
%   polygon is drawn around the region that is to be kept. Every pixel
%   outside this polygon region is turned to black (0,0,0). This can help
%   remove any objects that may be messing up the aorta finiding algorithm.
%   Bright objects often cause this.
% folder        (1,1)
%   A filepath (string I think) to the folder that the video is contained
%   in. Will throw an error if the video (videoName) with the specified
%   extension is not found in the MATLAB file path.
% fullFilePath  (1,1)
%   A filepath (string I think) to the video file that will be analyzed.
%   This full file path is .../folder/fileName. Will throw an error if the
%   video (videoName) with the specified extension is not found in the
%   MATLAB file path.
% vidObj        -
%   A videoReader object that reads in the data from vidName file.
% vidHeight     (1,1)
%   The number of pixels that the video contains in the vertical (y)
%   direction
% vidWidth      (1,1)
%   The number of pixels that the video contains in the horizontal (x)
%   direction
% numFrames     (1,1)
%   The number of frames that will be read in from the video
% mov           (1,1)
%   A standard movie structure
%   Fields:
%       cdata       (vidHeight,vidWidth,3)
%           A unitX 3d array that has the rgb data from every pixel in a
%           frame. X is tested to be 8,10,16 but should work for any int.
%       colormap    ()
%           Not really bothered on what this does. Sometimes there's code
%           that may throw an error, but it shouldn't here. This comes
%           standard when MATLAB functions generate a movie structure.
% im            (vidHeight,vidWidth,3)
%   A unitX 3d array ('image') that contains the rgb data from every pixel
%   in a frame.  X is tested to be 8,10,16 but should work for any int.
%   Often used instead of mov.cdata becuase it's shorter and makes more
%   sense.
% 
% Functions:
%   makeNewIm - Makes a new image from means and assignments variables
%       given from kMeans
%   findThetaSkele - Finds the angle that a reference line should be given
%       two points in the skeleton.
%   getpts - gets all of the points in a reference line given the two end
%       points and the angle.
%   ptInBoundary - Returns true only if the point given by 'pt' is in the
%       boundary of the image
%   deleteArea - Allows the deletion of any regions in the first image that
%       may be affecting the initializing analysis. This should be used as
%       a last resort, and should be unnecessary with good experiment
%       design. Click anywhere on the image to select polygon nodes.
%       Connect the first point to the last point to stop selecting
%       points. Everything outside of the polygon is turned to black.
%   mainS - This is the main function of the data gathering process. This
%       function does this in a serial fashion (not in parallel). See the
%       function itself for more info.
%   vidInit - The initialization function of this file. Reads in the .tif
%       files from the current directory and outputs all nevessary
%       information about them.
%   checkVidOrder - Checks the order of the .tif files imported to make
%       sure the numbers associated with each frame is in ascending order.
%       E.g. that vidName001 comes before vidName002 which comes becore
%       vidName005 etc.
%   refLines - Finds all of the reference lines for analysis. Currently,
%       the reference lines are passed as an angle (thta), and the two end
%       points (p1e & p2e). This could be changed, but is good enough.
%   orderPts - Finds the order of the points in the skeleton. This is given
%       as ordered pairs in order from the start to the end (skele).
%   findAorta - Finds the color cluster associated with the object of
%       interest (in this case the aorta). Outputs a logical image (an
%       image consisting of just 1's and 0's where the aorta containing
%       pixles are set as 1 (true) and the rest are set as 0 (false).
%   getColor - Obtains the index of the color that associates with the
%       aorta in means. See kMeans function.
%   findSkeleton - Finds the skeleton of the aorta. Since I want this
%       function to work for various camera with varying resolutions, this
%       uses an iterative method that progressively increases the minimum
%       branch length of the skeleton until the skeleton is a single line.
%   doubleBWSkel - A helper function that runs the skeleton function twice
%       (to get rid of any adjacent pixels) and finds the end points of the
%       skeleton.
%   checkSkeleOrder - Checks that skeleton is in the order you want it to
%   be in. It will output an image of the aorta which can be checked.
%
% See also preProcessing, postProcessing, kMeans.

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Dec. 27th, 2022

% TODO:
%   Finish Header
%   Look into analyzing all of the frames at once? might speed up mainS
%   fctn even more...?
%   Use non-multiple of 45deg lines? 45 deg lines seem to be messing things
%       up? 
%   --> on this note, the fctns 'refLines' and 'getpts' probably should be
%           entirely re-written. Esp. refLines seems very bloated and could
%           be streamlined for speed of plotting? findThetaSkele should
%           also be rewritten for higher order interpolation using more
%           points.


%% UPDATES
% created meanColor group to try to get rid of reflections
% added more robust skeleton finding method - iterative method
% 
% Made main function use less memory by disposing vars:
%       clines:  "rtot","gtot","btot","r","g","b"
% 
% Vectorized to optimize code (see fctn mainS)
% 
% Created getColor function to clean up kMeans code a bit (and to include
%   random section that was just a single line to find the index.
%   this function can also contain code to automate finding wt variable
% Updated getColor to use maxk instead of manual iterations. >40% faster
% 
% Fixed bug in makeNewIm... Can't believe I didn't see this before... yikes
%   Now actually displays color correctly lol
% 
% Moved maxCVal into vidInit(). Makes WAY more sense to be there than in
%   kMeans section
% 
% Created findSkeleton and doubleBWSkel to clean up code some more
% 
% Created checkSkeleOrder so testing of the skeleton order could be more
%   easily customized or switched to the user's liking

%% Main
%% --------------------------------------------------------------------- %%
%% Set Parameters
ccc

fps = 1200; 
wt = [2,1.5,1.25]; 
lineLength = 80;        % Length of lines across region
folderName = 'Test7-34in-2000_single_pulse\ts3_000002';
folderName = 'D:\PWV\Test7 (12-14-22)\Test7-1in-2000-single_pulse';

nMaxFrames = inf;
deleteRegion = true;

% kMeans
k = 2;                  % Number of colors
aortaIndex = 1;         % Color cluster to pull from (1 being highest mean
                        % intensity, 2 being next highest, etc)

minBL = 16;             % Minimum branch length for skeletonization
                        % lower number will take longer, but may give
                        % better answer if you over-estimated. Probably
                        % best if you make this a power of 2.
scaleFactor = 1.1;      % changes how much minBL is multiplied by in 
                        % findSkeleton

%% Video Initialization
[mov,vidName, numFrames, type, maxCVal, height, width] = vidInit(folderName);

%% getting rid of bad pts; if applicable
% You only need to do this as a last resort if you are getting unwanted
%   reflections, etc. First, you should try using different k and
%   aortaIndex values (in that order). Good experiments should also
%   eliminate the need for this.
if (deleteRegion)
    im = deleteArea(mov.cdata);
else
    im = mov.cdata;
end


%% KMeans
inputMeanColors = maxCVal*ones(1,1,3);
[means,assignments,~] = kMeans(im,k,inputMeanColors);

im2 = makeNewIm(means,assignments);
imshowpair(im*(maxCVal/max(im,[],'all')),im2*(maxCVal/max(im,[],'all')),'montage')

% dont pass assignments to stop plotting
[index] = getColor(aortaIndex,means,assignments);

clearvars inputMeanColors
%% Finding Aorta
Lim = zeros(height,width,1,'logical');
Lim(assignments == index) = 1;

Lim2 = findAorta(Lim,height,width);

imshowpair(im2,Lim2,'montage')

%% Fill Holes
Lim3 = imfill(Lim2,'holes');
imshowpair(Lim2,Lim3,'montage')

%% skeletonization
[skeleim, endpts] = findSkeleton(Lim3, minBL,scaleFactor);

%% Ordering points
skele = orderPts(skeleim,endpts);

%% Checking that order is correct
checkSkeleOrder(skele, Lim3, type, maxCVal, height, width);

%% Finding reference lines
% dont pass mov to stop plotting 
% --> MUCH faster in current form but doesn't show what's going on
[thta,p1e,p2e,NUMLINES] = refLines(skele,lineLength,mov);

%% Using Color to find growth
close all
clearvars im im2 assignments endpts Lim Lim2 Lim3 means
clearvars skeleim skeleim1 imcheck num index row col ii
%% Main Data Extraction
[cLines] = mainS(NUMLINES, p1e, p2e, thta, vidName,nMaxFrames,wt);

%%
clearvars p1e p2e

%% --------------------------------------------------------------------- %%
% I do this so you can run the whole file without running the examples.
% you can still run the individual sections by clicking 'run section'
% (CTRL + Enter if you have Windows mapping of keybinds)
if false
%% Reference images
% These may need a toolbox (image processing?), so don't worry if they
% don't work. They aren't needed for analysis

% Examples 
% An image if you want to see what the video is of.
figure(1)
imshow(im)

% You can also look at other images such as:
%   assignments, bwim, im1, im2, im3, endpts, Lim, Lim2, Lim3, out,
%   skeleim, skeleim1, etc. 
% (you'll have to run this before they're cleared)

%% Example on cLines use
% Plots a curve for a single line over every frame
figure(1)
% Plot line 129
NUM = 70;
plot(timeVal,cLines(NUM).wtd)
title('Weighted value of line %i over the entire video',NUM)
xlabel('Time (s)')
ylabel('Weighted Value')
end





























