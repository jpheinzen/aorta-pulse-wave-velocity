
%% Info:
% postProcessing - Uses the data gathered from a video and analyses it in
%   order to obtain a Pulse Wave Velocity (PWV).
% 
% Variables:
% skele         (NUMLINES+1,2) 
%   All points (y,x) in skeleton in order going down the column.
%   Standard matlab indexing into the video matrix (row,col). e.g.
%   skele(7,:) is the 7th point in the skeleton; skele(7,1) is the
%   'y-position' in the frame and skele(7,2) is the 'x-position' in the
%   frame.
%   skeleXY is the same thing except each point (i,j) is (x,y) instead of
%   (y,x).
% timeVal       (1,numFrames)
%   The time value of each frame in the video.
% numFrames     (1,1)
%   The number of frames in the video.
% NUMLINES      (1,1)
%   The number of lines going across the aorta at which data is recorded
%   for each frame. 
% fps           (1,1)
%   The number of frames per second of the video. For our camera this is
%   either 600 or 1200.
% posVal        (NUMLINES,1)
%   The position value of each line along the skeleton. The value in this
%   can be thought of as a 'pixel distance' from the start of the skeleton.
% cLines        (NUMLINES,1) - structure
%   A structure to track the amount of color in each line.
%   E.g. the weighted total of line 27 at frame 2000 is:
%   cLines(27).wtd(2000)
%   NOTE: This structure takes up a lot of space, so limiting the fields to
%   only those that are necessary improves computer performance, especially
%   with limited RAM.
%   Fields:
%       npts        (1,1)
%           The number of points in the line
%       pti         (npts,2)
%           The index of each point in the line into the video matrix using
%           standard matlab indexing (row,col)
%       r           (npts,nFrames)
%           The red value at each corresponding point in pti for each frame
%           in the video
%       g           (npts,nFrames)
%           The green value at each corresponding point in pti for each
%           frame in the video
%       b           (npts,nFrames)
%           The blue value at each corresponding point in pti for each
%           frame in the video
%       rtot        (1,nFrames)
%           The sum (total) of the red values at each point on the line for
%           each frame in the video
%       gtot        (1,nFrames)
%           The sum (total) of the green values of the line for each frame
%           in the video
%       btot        (1,nFrames)
%           The sum (total) of the blue values of the line for each frame
%           in the video
%       wtd         (1,nFrames)
%           A weighted sum of the red, green, and blue totals. I often used
%           a weighting of wtd = 2*r + 1.5*g + 1.25*b
%           The exact weighting used can be seen in the variable 'wt'
%
% Functions:
%
%
% See also preProcessing, gatherData.

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Dec. 31th, 2022

% TODO:
%   Finish Header

%% Main
%% --------------------------------------------------------------------- %%
%% Read File
% ccc

npinterpH = 200;

distanceinIn = 1;    % UPDATE THIS WITH DIAMETER OF TUBING
distanceinM = 0.0254*distanceinIn;

methodNum = 8;  % must be a number 1-11 - see findDelay.
                % I recommend 8,9,10, or 11
smoothFactor = 5;       % can change for methods 4 and 5. The larger the 
                        %   number, the more smooth the data. 4-10 is good

% supplying smoothing method for findDelay methods 8 or 9. Do 'help smooth'
%   for more information
%     'moving'   - Moving average (default)
%     'lowess'   - Lowess (linear fit)
%     'loess'    - Loess (quadratic fit)
%     'sgolay'   - Savitzky-Golay
%     'rlowess'  - Robust Lowess (linear fit)
%     'rloess'   - Robust Loess (quadratic fit)
smoothMethod = 'loess';

% load('example.mat')

% NOTE: Ignore the 3 function handle warnings -> The following don't work sometimes?
clear lineType lineColor ptType
im = mov.cdata;

%% Finding pixel distance from start

% These should be all the variables that you need?
clearvars -except cLines timeVal NUMLINES fps numFrames skele thta npinterpH distanceinM im methodNum

posVal = getPosition(skele, NUMLINES);

% posVal = fliplr(posVal);

%% Adding and simplifying vars
timeVal = (1:numFrames)/fps;
% No longer need skele
clearvars -except cLines timeVal posVal NUMLINES fps numFrames skele thta npinterpH distanceinM im methodNum

% in case you only want a few lines 
% cLines = cLines([5:7,NUMLINES-2:NUMLINES]);

try % would throw error if cLines doesn't have the fields
    % Lowers memory needed to hold in workspace -> cLines is huge
    cLines = rmfield(cLines,["rtot","gtot","btot","r","g","b"]);
catch
end

%% Scaling
pix2MScaling = findScaling(im,distanceinM);

%% Finding delay

delay = zeros(NUMLINES,1);
tic
for NUM = 1:NUMLINES
    
    delay(NUM) = findDelay(cLines(NUM).wtd,NUM,timeVal,fps,npinterpH,...
        methodNum,false,smoothFactor,smoothMethod);

    printTime(NUM,NUMLINES,toc)
%     printProgress(NUM,NUMLINES,'Finding delay')
end


%% Plot to find PWV

close all
starti = 1;

figure(100001)
if true  % all points
    p = polyfit(posVal(starti:end),delay(starti:end),1);
    plot(posVal(starti:end),delay(starti:end),'k.')
else    % Throw out 45 deg angles and things more than 1 std dev away from avg
    TEMP1 = find(mod(thta,90)==0);
    TEMP2 = find(delay < std(delay(mod(thta,90)==0)) + mean(delay(mod(thta,90)==0)));
    TEMP = intersect(TEMP1,TEMP2);
    p = polyfit(posVal(TEMP),delay(TEMP),1);
    plot(posVal(TEMP),delay(TEMP),'k.')
end


fprintf('PWV = %.3d pix/s\n',1/p(1))
fprintf('PWV = %.3f m/s\n',1/p(1)*pix2MScaling)

hold on
xx = linspace(min(posVal),max(posVal),1000);
plot(xx,polyval(p,xx))
xlabel('distance (pixels)')
ylabel('time(s)')
clearvars xx TEMP TEMP1 TEMP2

%% Debugging delay
close all
methodNum = 9;
X = 432.191;
[~,lineNum] = min(abs(posVal-X));
findDelay(cLines(lineNum).wtd,lineNum,timeVal,fps,npinterpH,methodNum,true,smoothFactor,smoothMethod);

clearvars X lineNum

