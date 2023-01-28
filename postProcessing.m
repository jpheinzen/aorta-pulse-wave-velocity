
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
%   Oct. 19th, 2022

% TODO:
%   Finish Header

%% Main
%% --------------------------------------------------------------------- %%
%% Read File
ccc

load('example2.mat')

% NOTE: Ignore the 3 function handle warnings -> The following don't work sometimes?
clear lineType lineColor ptType

%% Finding pixel distance from start

% These should be all the variables that you need?
clearvars -except cLines timeVal NUMLINES fps numFrames skele thta

posVal = getPosition(skele, NUMLINES);

% posVal = fliplr(posVal);

%% Adding and simplifying vars
timeVal = (1:numFrames)/fps;
% No longer need skele
clearvars -except cLines timeVal posVal NUMLINES fps numFrames skele thta

% in case you only want a few lines 
% cLines = cLines([5:7,NUMLINES-2:NUMLINES]);

try % would throw error if cLines doesn't have the fields
    % Lowers memory needed to hold in workspace -> cLines is huge
    cLines = rmfield(cLines,["rtot","gtot","btot","r","g","b"]);
catch
end

%% Analyze data

%% Finding delay - Method 1 (simple method)

npinterpH = 200;

delay = zeros(NUMLINES,1);
tic
for NUM = 1:NUMLINES
    
    delay(NUM) = findDelay1(cLines,NUM,timeVal,npinterpH,fps);

    printTime(NUM,NUMLINES,toc)
%     printProgress(NUM,NUMLINES,'Finding delay')
end
%% Plot to find PWV
totalLengthInM = 0.1;

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
fprintf('PWV = %.3f m/s\n',1/p(1)/posVal(end)*totalLengthInM)

hold on
xx = linspace(min(posVal),max(posVal),1000);
plot(xx,polyval(p,xx))
xlabel('distance (pixels)')
ylabel('time(s)')
clearvars xx TEMP TEMP1 TEMP2

%% Debugging delay

% X = 102.243;
X = 207.657;
[~,lineNum] = min(abs(posVal-X));
findDelay3(cLines,lineNum,timeVal,npinterpH,fps,true);
clearvars X lineNum

%% --------------------------------------------------------------------- %%
function [x,y] = intersect2lines(m1,y1,m2,y2)
    x = (y2-y1)/(m1-m2);
    y = m1*x+y1;
end

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% Simplest way to find line delay:
%   Find intersection of preslope and pulse rise slope
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay1(cLines,lineNum,timeVal,npinterpH,fps,debug)
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
if nargin == 5
    debug = false;
end


deriv1 = zeros(length(timeVal),1);
for ii = npinterpH+1:length(timeVal)-npinterpH
    p = polyfit(timeVal(ii-npinterpH:ii+npinterpH),cLines(lineNum).wtd(ii-npinterpH:ii+npinterpH),1);
    deriv1(ii) = p(1);
end

[~,i1] = max(deriv1);
i2 = i1;

while deriv1(i2) >=0
    i2 = i2+1;
end
if deriv1(i2-1) < abs(deriv1(i2))
    i2 = i2-1;
end

prei1 = i2 - 1.5*fps;
prei2 = prei1+fps;
if prei1 < 1
    prei1 = 1;
end

p = polyfit(timeVal(prei1:prei2),cLines(lineNum).wtd(prei1:prei2),1);
preSlope = p(1);
preY = p(2);

ytarget = cLines(lineNum).wtd(i1)-(cLines(lineNum).wtd(i2)-cLines(lineNum).wtd(i1))/2;
ilow = round(i1-(i2-i1)/2);
[~,imid] = min(abs(cLines(lineNum).wtd(ilow:i1)-ytarget));    % finds y-pos just below i1
imid = imid + ilow;
%     imid = round((i1+i2)/2);
irange2H = 25;
p = polyfit(timeVal(imid-irange2H:imid+irange2H),cLines(lineNum).wtd(imid-irange2H:imid+irange2H),1);

[x,y] = intersect2lines(p(1),p(2),preSlope,preY);

[~,ifinal] = min(abs(timeVal-x));

delay = timeVal(ifinal);

if debug
    MS = 10;
    figure(lineNum)
    hold on;
    plot(timeVal,cLines(lineNum).wtd)
    plot(timeVal(i1),cLines(lineNum).wtd(i1),'r.','markersize',MS)
    plot(timeVal(i2),cLines(lineNum).wtd(i2),'g.','markersize',MS)


    xx = linspace(timeVal(prei1),timeVal(i2),1000);
    plot(xx,polyval([preSlope,preY],xx))

    plot(timeVal(imid),cLines(lineNum).wtd(imid),'b.','markersize',MS)


    xx = linspace(timeVal(round(i2-1.5*(i2-i1))),timeVal(i2),1000);
    plot(xx,polyval(p,xx),'m')

    plot(timeVal(ifinal),y,'k.','markersize',MS)

    Ltxt = ["Raw Data","Max Slope","0 slope - peak","pre-slope",...
        "Mid-pt","Front slope","Final Point"];
    legend(Ltxt,'location','best')

end
end

% ----------------------------------------------------------------------- %

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% More Complicated way to find the delay of lines.
%   Many different ways to try to find delay were tried, and left.
% -> Obviously this is very bloated and could be sped up?
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay2(cLines,lineNum,timeVal,npinterpH,fps,debug)
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
if nargin == 5
    debug = false;
end

deriv1 = zeros(length(timeVal),1);
for ii = npinterpH+1:length(timeVal)-npinterpH
    p = polyfit(timeVal(ii-npinterpH:ii+npinterpH),cLines(lineNum).wtd(ii-npinterpH:ii+npinterpH),1);
    deriv1(ii) = p(1);
end

[~,i1] = max(deriv1);

i2 = i1;
while deriv1(i2) >0            % 0 on right side
    i2 = i2+1;
end
if deriv1(i2-1) < abs(deriv1(i2))
    i2 = i2-1;
end

i7 = i1;
while deriv1(i7) > 0           % 0 on left side
    i7 = i7-1;
end
if deriv1(i7+1) < abs(deriv1(i7))
    i7 = i7+1;
end

%----------

i5 = 2*i1-i2;
i3 = i5+npinterpH/2;            % 1st guess using log assumption

ytarget = (deriv1(i1)+deriv1(i7))/2;
[~,imid] = min(abs(deriv1(i7:i1)-ytarget));    % finds y-pos between i1 and i7
imid = imid + i7;
%     imid = round((i1+i7)/2);

%----------
% finding info about pre-pulse
prei1 = i2 - 1.55*fps;
prei2 = prei1+fps;
if prei1 < 1
    prei1 = 1;
end

p = polyfit(timeVal(prei1:prei2),cLines(lineNum).wtd(prei1:prei2),1);
preSlope = p(1);
preY = p(2);

TEMP = preY - 2*std(cLines(lineNum).wtd(prei1:prei2));
TEMP1 = preY - 1.5*std(cLines(lineNum).wtd(prei1:prei2));
%----------
i0 = i1;
while deriv1(i0) >= preSlope && deriv1(i0) >= 1   % marching left
    i0 = i0-1;
end
if abs(deriv1(i0+1)-preSlope) < abs(abs(deriv1(i0))-preSlope)
    i0 = i0+1;
end
i4 = i0 + npinterpH;            % 2nd guess using left march to pre-slope

%----------
% line fit around midpt
irange2H = 25;
p = polyfit(timeVal(imid-irange2H:imid+irange2H),deriv1(imid-irange2H:imid+irange2H),1);

[x,~] = intersect2lines(p(1),p(2),0,preSlope);

[~,i6] = min(abs(timeVal-x));
i6 = i6 + npinterpH;            % 3rd guess using slope match to pre-slope



%----------
deriv2 = zeros(length(timeVal),1);
npinterpH2 = round(0.03*fps);
for ii = npinterpH2+1:length(timeVal)-npinterpH2
    p = polyfit(timeVal(ii-npinterpH2:ii+npinterpH2),...
            cLines(lineNum).wtd(ii-npinterpH2:ii+npinterpH2),1);
    deriv2(ii) = p(1);
end

i8 = i1;
while deriv2(i8) >= 0           % 0 on left side
    i8 = i8-1;
end
if deriv2(i8+1) < abs(deriv2(i8))
    i8 = i8+1;                  % 4th guess using small slope to 0
end
%-----------
deriv3 = zeros(i1,1);
npinterpH2 = round(0.03*fps);
for ii = npinterpH2+1:i1-npinterpH2
    p = polyfit(timeVal(ii-npinterpH2:ii+npinterpH2),...
            cLines(lineNum).wtd(ii-npinterpH2:ii+npinterpH2),1);
    deriv3(ii) = p(1);
end

[~,i9] = min(deriv3);

i10 = i9;
while deriv3(i10) <=0            % 0 on right side
    i10 = i10+1;
end
if abs(deriv3(i10-1)) < abs(deriv1(i10))
    i10 = i10-1;
end

%-----------

%     ifinal = round((i3+i3)/2);
% ifinal = i4;
% ifinal = i6;
ifinal = i10;



try
    delay = timeVal(ifinal);
catch
    delay = 0;
    fprintf('lineNum = %i\n\n\n',lineNum)
end

if debug
    MS = 10;
    figure(lineNum)
    hold on;
    plot(timeVal,cLines(lineNum).wtd)
    plot(timeVal(i1),cLines(lineNum).wtd(i1),'r.','markersize',MS)
    plot(timeVal(i2),cLines(lineNum).wtd(i2),'g.','markersize',MS)

% i2 instead of end
    xx = linspace(timeVal(prei1),timeVal(end),1000);
    plot(xx,polyval([preSlope,preY],xx))

    plot(timeVal(imid),cLines(lineNum).wtd(imid),'b.','markersize',MS)

    plot(timeVal(i3),cLines(lineNum).wtd(i3),'y.','markersize',10)
    
    plot(timeVal(i4),cLines(lineNum).wtd(i4),'c.','markersize',10)

    plot(timeVal(i6),cLines(lineNum).wtd(i6),'m.','markersize',10)

%     xx = linspace(timeVal(round(i1-1.5*(i2-i1))),timeVal(i2),1000);
%     plot(xx,polyval(p,xx),'m')

    plot(timeVal(ifinal),cLines(lineNum).wtd(ifinal),'k.','markersize',MS)

    plot(timeVal(prei2),cLines(lineNum).wtd(prei2),'k.','markersize',MS)
    yline(TEMP)
    yline(TEMP1)
    
%     plot(timeVal,deriv1+90)
%     plot(timeVal,deriv2+90)
%     plot(timeVal(1:length(deriv3)),deriv3+90)

    plot(timeVal(i8),cLines(lineNum).wtd(i8),'r.','markersize',MS)
%     plot(timeVal(i8),deriv2(i8)+90,'r.','markersize',MS)
    plot(timeVal(i10),cLines(lineNum).wtd(i10),'g.','markersize',MS)


    Ltxt = ["Raw Data","Max Slope","0 slope - peak","pre-slope",...
        "Mid-pt","1st guess using log assumption",...
        "2nd guess using left march to pre-slope",...
        "3rd guess using slope match to pre-slope","Final Point"];
    legend(Ltxt,'location','best')



end

end

% ----------------------------------------------------------------------- %

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% An attempt to speed up (but not debloat) findDelay2.
%  NOT TESTED - might not work in its current form
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay3(cLines,lineNum,timeVal,npinterpH,fps,debug)

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
if nargin == 5
    debug = false;
end

deriv1 = zeros(length(timeVal),1);
for ii = npinterpH+1:length(timeVal)-npinterpH
    p = polyfit(timeVal(ii-npinterpH:ii+npinterpH),cLines(lineNum).wtd(ii-npinterpH:ii+npinterpH),1);
    deriv1(ii) = p(1);
end

[~,i1] = max(deriv1);

i2 = find(deriv1(i1:end) < 0,1)+i1-1;       % 0 on right side
if abs(deriv1(i2-1)) < abs(deriv1(i2))
    i2 = i2-1;
end

i7 = find(deriv1(1:i1) < 0,1,'last');       % 0 on left side
if abs(deriv1(i7+1)) < abs(deriv1(i7))
    i7 = i7+1;
end



%----------

i5 = 2*i1-i2;
i3 = i5+npinterpH/2;            % 1st guess using log assumption

ytarget = (deriv1(i1)+deriv1(i7))/2;
[~,imid] = min(abs(deriv1(i7:i1)-ytarget));    % finds y-pos between i1 and i7
imid = imid + i7;
%     imid = round((i1+i7)/2);

%----------
% finding info about pre-pulse
prei1 = i2 - 1.55*fps;
prei2 = prei1+fps;
if prei1 < 1
    prei1 = 1;
end

p = polyfit(timeVal(prei1:prei2),cLines(lineNum).wtd(prei1:prei2),1);
preSlope = p(1);
preY = p(2);

TEMP = preY - 2*std(cLines(lineNum).wtd(prei1:prei2));
TEMP1 = preY - 1.5*std(cLines(lineNum).wtd(prei1:prei2));
%----------

% marching left
i0 = find(deriv1(1:i1) < 0 | deriv1(1:i1) < 1,1,'last');
if abs(deriv1(i0+1)-preSlope) < abs(abs(deriv1(i0))-preSlope)
    i0 = i0+1;
end
i4 = i0 + npinterpH;            % 2nd guess using left march to pre-slope

%----------
% line fit around midpt
irange2H = 25;
p = polyfit(timeVal(imid-irange2H:imid+irange2H),deriv1(imid-irange2H:imid+irange2H),1);

[x,~] = intersect2lines(p(1),p(2),0,preSlope);

[~,i6] = min(abs(timeVal-x));
i6 = i6 + npinterpH;            % 3rd guess using slope match to pre-slope



%----------
deriv2 = zeros(length(timeVal),1);
npinterpH2 = round(0.03*fps);
for ii = npinterpH2+1:length(timeVal)-npinterpH2
    p = polyfit(timeVal(ii-npinterpH2:ii+npinterpH2),...
            cLines(lineNum).wtd(ii-npinterpH2:ii+npinterpH2),1);
    deriv2(ii) = p(1);
end

% 0 on left side
i8 = find(deriv2(1:i1) < 0,1,'last');
if abs(deriv2(i8+1)) < abs(deriv2(i8))
    i8 = i8+1;                  % 4th guess using small slope to 0
end

% ------------

deriv3 = zeros(i1,1);
npinterpH2 = round(0.03*fps);
for ii = npinterpH2+1:i1-npinterpH2
    p = polyfit(timeVal(ii-npinterpH2:ii+npinterpH2),...
            cLines(lineNum).wtd(ii-npinterpH2:ii+npinterpH2),1);
    deriv3(ii) = p(1);
end

[~,i9] = min(deriv3);

% 0 on right side
i10 = find(deriv3(i9:end) > 0,1)+i9-1; 
if abs(deriv3(i10-1)) < abs(deriv1(i10))
    i10 = i10-1;
end

%-----------

%     ifinal = round((i3+i3)/2);
% ifinal = i4;
% ifinal = i6;
ifinal = i10;



try
    delay = timeVal(ifinal);
catch
    delay = 0;
    fprintf('lineNum = %i\n\n\n',lineNum)
end

if debug
    MS = 10;
    figure(lineNum)
    hold on;
    plot(timeVal,cLines(lineNum).wtd)
    plot(timeVal(i1),cLines(lineNum).wtd(i1),'r.','markersize',MS)
    plot(timeVal(i2),cLines(lineNum).wtd(i2),'g.','markersize',MS)

% i2 instead of end
    xx = linspace(timeVal(prei1),timeVal(end),1000);
    plot(xx,polyval([preSlope,preY],xx))

    plot(timeVal(imid),cLines(lineNum).wtd(imid),'b.','markersize',MS)

    plot(timeVal(i3),cLines(lineNum).wtd(i3),'y.','markersize',10)
    
    plot(timeVal(i4),cLines(lineNum).wtd(i4),'c.','markersize',10)

    plot(timeVal(i6),cLines(lineNum).wtd(i6),'m.','markersize',10)

%     xx = linspace(timeVal(round(i1-1.5*(i2-i1))),timeVal(i2),1000);
%     plot(xx,polyval(p,xx),'m')

    plot(timeVal(ifinal),cLines(lineNum).wtd(ifinal),'k.','markersize',MS)

    plot(timeVal(prei2),cLines(lineNum).wtd(prei2),'k.','markersize',MS)
    yline(TEMP)
    yline(TEMP1)
    
%     plot(timeVal,deriv1+90)
%     plot(timeVal,deriv2+90)
%     plot(timeVal(1:length(deriv3)),deriv3+90)

    plot(timeVal(i8),cLines(lineNum).wtd(i8),'r.','markersize',MS)
%     plot(timeVal(i8),deriv2(i8)+90,'r.','markersize',MS)
    plot(timeVal(i10),cLines(lineNum).wtd(i10),'g.','markersize',MS)


    Ltxt = ["Raw Data","Max Slope","0 slope - peak","pre-slope",...
        "Mid-pt","1st guess using log assumption",...
        "2nd guess using left march to pre-slope",...
        "3rd guess using slope match to pre-slope","Final Point"];
    legend(Ltxt,'location','best')



end

end

















