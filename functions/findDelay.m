function delay = findDelay(quantity,lineNum,timeVal,fps,npinterpH,methodNum,debug,smoothFactor)
arguments
    quantity 
    lineNum % Not really used for much besides figure number, and debugging
    timeVal
    fps (1,1) {mustBePositive}
    npinterpH (1,1) = 200;
    methodNum (1,1) = 1;
    debug (1,1) {mustBeNumericOrLogical} = false;
    smoothFactor (1,1) {mustBePositive} = 5;
end

%% Info:
% findDelay - 
% 
% Variables:
% timeVal       (1,numFrames)
%   The time value of each frame in the video.
% numFrames     (1,1)
%   The number of frames in the video.
% NUM      (1,1)
%   The number of the reference line going across the aorta at which 
%   function is being called
% fps           (1,1)
%   The number of frames per second of the video. For our camera this is
%   either 600 or 1200.
% npinterpH           (1,1)
%   Half of the number of points used to caluclated the slopes. 
% flag           (1,1)
%   Number index that is used to call the appropriate variation of the
%   findDelay function.
% debug
%   Boolean variable that can be used to debug the findDelay function. The
%   variable will default to false if not specified. 
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
%   Jan 16th, 2023

% TODO:
%   Finish Header

% This should be a number 1-5 corresponding to one of the 5 sub-methods in
% methods 2 and 3 (not used in 3 because it is not optimized). 
% I recommend using 4 or 5
subMethodNum = 4;   

smoothRange = round(fps*smoothFactor/100);

% 4/6 smooth 1; 4 is slower but generally more accurate than 6
% 5/7 smooth 2; 5 is slower but generally more accurate than 7
switch methodNum
    case 1
        delay = findDelay1(quantity,lineNum,timeVal,fps,npinterpH,debug);
    case 2
        delay = findDelay2(quantity,lineNum,timeVal,fps,npinterpH,debug,subMethodNum);
    case 3      % Pretty bad code now, NOT recommended
        warning('You should REALLY use method 2 instead of 3. This method is NOT optimized like method 2 is')
        delay = findDelay3(quantity,lineNum,timeVal,fps,npinterpH,debug);
    case 4
        % Same as (1), but smoothes the data first - Uses a double
        % derivative method
        delay = findDelay4(quantity,lineNum,timeVal,fps,npinterpH,smoothRange,debug);
    case 5
        % Same as (2), but smoothes the data first - Uses a double
        % derivative method
        delay = findDelay5(quantity,lineNum,timeVal,fps,npinterpH,smoothRange,debug,subMethodNum);
    case 6
        % Same as (1), but smoothes the data first - Uses a mean then
        % derivative method
        delay = findDelay6(quantity,lineNum,timeVal,fps,npinterpH,smoothRange,debug);
    case 7
        % Same as (2), but smoothes the data first - Uses a mean then
        % derivative method
        delay = findDelay7(quantity,lineNum,timeVal,fps,npinterpH,smoothRange,debug,subMethodNum);
    otherwise
        error('findDelay:incorrectmethodNum', ...
            'findDelay methodNum is set to %i, which is not valid.', ...
            methodNum)
end 
end

%% --------------------------------------------------------------------- %%
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% Simplest way to find line delay:
%   Find intersection of preslope and pulse rise slope
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay1(quantity,lineNum,timeVal,fps,npinterpH,debug)
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP

quantity = flipData(quantity,lineNum);

[iMaxSlope, iPeak, ~] = initialValues(timeVal, quantity, npinterpH);

[prei1, prei2, preSlope, preY] = prePulse(timeVal, quantity, fps, iMaxSlope);

ilow = round(iMaxSlope-(iPeak-iMaxSlope)/2);
[ifinal, imid, polyCoeffs, yPt] = ...
    slopeIntersect(timeVal, quantity, fps, prei1, prei2, preSlope, preY, iMaxSlope, ilow);

delay = timeVal(ifinal);

if debug
    debug1(timeVal, quantity, lineNum,  iMaxSlope, iPeak, prei1, preSlope,...
        preY, imid, polyCoeffs, ifinal, yPt)
end

end

% ----------------------------------------------------------------------- %

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% More Complicated way to find the delay of lines.
%   Many different ways to try to find delay were tried, and left.
% -> Obviously this is very bloated and could be sped up?
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay2(quantity,lineNum,timeVal,fps,npinterpH,debug,subMethodNum)
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP

quantity = flipData(quantity,lineNum);

[iMaxSlope, iPeak, deriv1] = initialValues(timeVal, quantity, npinterpH);

[prei1, prei2, preSlope, preY] = prePulse(timeVal, quantity, fps, iMaxSlope);
%----------


%----------

if debug
    loopInds = 1:5;        % so that you can see all possible methods
else
    % To only run the one you need - speeds up postProcessing a lot
    loopInds = subMethodNum;    
end

for iLoop = loopInds
    switch iLoop
        case 1      % 1st guess using log assumption
            i5 = 2*iMaxSlope-iPeak;
            iLogAssump = i5+npinterpH/2;
% -----------
        case 2      % 2nd guess using left march to pre-slope
            i0 = iMaxSlope;
            while deriv1(i0) >= preSlope && i0 >= 1   % marching left
                i0 = i0-1;
            end
            if abs(deriv1(i0+1)-preSlope) < abs(abs(deriv1(i0))-preSlope)
                i0 = i0+1;
            end
%             iLMPreSlope = i0 + npinterpH;
            iLMPreSlope = i0;
% -----------
        case 3      % 3rd guess using slope match to pre-slope
            ilow = iMaxSlope;
            while deriv1(ilow) > 0           % 0 on left side
                ilow = ilow-1;
            end
            if deriv1(ilow+1) < abs(deriv1(ilow))
                ilow = ilow+1;
            end

            [iIntersect, imid, ~, ~] = ...
                slopeIntersect(timeVal, quantity, fps, prei1, prei2, preSlope, preY, iMaxSlope, ilow);
%             iInterPS = iIntersect + npinterpH;
            iInterPS = iIntersect;
% -----------
        case 4      % 4th guess using fine gradient left-march to 0 from max slope pt
            deriv2 = zeros(iMaxSlope,1);
            npinterpH2 = round(0.03*fps);
            for ii = npinterpH2+1:iMaxSlope-npinterpH2
                p = polyfit(timeVal(ii-npinterpH2:ii+npinterpH2),...
                    quantity(ii-npinterpH2:ii+npinterpH2),1);
                deriv2(ii) = p(1);
            end

            iSSLM20 = iMaxSlope;
            while deriv2(iSSLM20) >= 0           % 0 on left side
                iSSLM20 = iSSLM20-1;
            end
            if deriv2(iSSLM20+1) < abs(deriv2(iSSLM20))
                iSSLM20 = iSSLM20+1;
            end
% -----------
        case 5      % 5th guess using fine gradient right-march to 0
            deriv3 = zeros(iMaxSlope,1);
            npinterpH2 = round(0.03*fps);
            for ii = npinterpH2+1:iMaxSlope-npinterpH2
                p = polyfit(timeVal(ii-npinterpH2:ii+npinterpH2),...
                    quantity(ii-npinterpH2:ii+npinterpH2),1);
                deriv3(ii) = p(1);
            end

            [~,i9] = min(deriv3);

            iSSRM20 = i9;
            while deriv3(iSSRM20) <=0            % 0 on right side
                iSSRM20 = iSSRM20+1;
            end
            if abs(deriv3(iSSRM20-1)) < abs(deriv1(iSSRM20))
                iSSRM20 = iSSRM20-1;
            end
% -----------
        otherwise
            error('subMethodNum need to be between 1 and 5 inclusive. It is set to %i',subMethodNum)
    end
end


switch subMethodNum
    case 1      % 1st guess using log assumption
        ifinal = iLogAssump;
    case 2      % 2nd guess using left march to pre-slope
        ifinal = iLMPreSlope;
    case 3      % 3rd guess using slope match to pre-slope
        ifinal = iInterPS;
    case 4      % 4th guess using fine gradient left-march to 0 from max slope pt
        ifinal = iSSLM20;
    case 5      % 5th guess using fine gradient right-march to 0
        ifinal = iSSRM20;
    otherwise
        error('subMethodNum need to be between 1 and 5 inclusive. It is set to %i',subMethodNum)
end


if ifinal > 0 && ifinal <= length(timeVal)
    delay = timeVal(ifinal);
else
    delay = nan;
    fprintf('lineNum = %i\n\n\n',lineNum)
end

if debug
    debug2(timeVal, quantity, lineNum, iMaxSlope, iPeak, prei1, preSlope,...
        preY, prei2, imid, iLogAssump, iLMPreSlope, iInterPS, iSSLM20, iSSRM20, ifinal);
end
end

% ----------------------------------------------------------------------- %

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% An attempt to speed up (but not debloat) findDelay2.
%  NOT TESTED - might not work in its current form
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay3(quantity,lineNum,timeVal,fps,npinterpH,debug)
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP

quantity = flipData(quantity,lineNum);

deriv1 = zeros(length(timeVal),1);
for ii = npinterpH+1:length(timeVal)-npinterpH
    p = polyfit(timeVal(ii-npinterpH:ii+npinterpH),quantity(ii-npinterpH:ii+npinterpH),1);
    deriv1(ii) = p(1);
end

[~,iMaxSlope] = max(deriv1);

iPeak = find(deriv1(iMaxSlope:end) < 0,1)+iMaxSlope-1;       % 0 on right side
if abs(deriv1(iPeak-1)) < abs(deriv1(iPeak))
    iPeak = iPeak-1;
end

i7 = find(deriv1(1:iMaxSlope) < 0,1,'last');       % 0 on left side
if abs(deriv1(i7+1)) < abs(deriv1(i7))
    i7 = i7+1;
end



%----------

i5 = 2*iMaxSlope-iPeak;
iLogAssump = i5+npinterpH/2;            % 1st guess using log assumption

ytarget = (deriv1(iMaxSlope)+deriv1(i7))/2;
[~,imid] = min(abs(deriv1(i7:iMaxSlope)-ytarget));    % finds y-pos between iMaxSlope and i7
imid = imid + i7;
%     imid = round((iMaxSlope+i7)/2);

%----------
% finding info about pre-pulse
prei1 = iPeak - 1.55*fps;
prei2 = prei1+fps;
if prei1 < 1
    prei1 = 1;
end

p = polyfit(timeVal(prei1:prei2),quantity(prei1:prei2),1);
preSlope = p(1);
preY = p(2);
%----------

% marching left
i0 = find(deriv1(1:iMaxSlope) < 0 | deriv1(1:iMaxSlope) < 1,1,'last');
if abs(deriv1(i0+1)-preSlope) < abs(abs(deriv1(i0))-preSlope)
    i0 = i0+1;
end
iLMPreSlope = i0 + npinterpH;            % 2nd guess using left march to pre-slope

%----------
% line fit around midpt
irange2H = 25;
p = polyfit(timeVal(imid-irange2H:imid+irange2H),deriv1(imid-irange2H:imid+irange2H),1);

[x,~] = intersect2lines(p(1),p(2),0,preSlope);

[~,iInterPS] = min(abs(timeVal-x));
iInterPS = iInterPS + npinterpH;            % 3rd guess using slope match to pre-slope



%----------
deriv2 = zeros(length(timeVal),1);
npinterpH2 = round(0.03*fps);
for ii = npinterpH2+1:length(timeVal)-npinterpH2
    p = polyfit(timeVal(ii-npinterpH2:ii+npinterpH2),...
            quantity(ii-npinterpH2:ii+npinterpH2),1);
    deriv2(ii) = p(1);
end

% 0 on left side
iSSLM20 = find(deriv2(1:iMaxSlope) < 0,1,'last');
if abs(deriv2(iSSLM20+1)) < abs(deriv2(iSSLM20))
    iSSLM20 = iSSLM20+1;                  % 4th guess using small slope to 0
end

% ------------

deriv3 = zeros(iMaxSlope,1);
npinterpH2 = round(0.03*fps);
for ii = npinterpH2+1:iMaxSlope-npinterpH2
    p = polyfit(timeVal(ii-npinterpH2:ii+npinterpH2),...
            quantity(ii-npinterpH2:ii+npinterpH2),1);
    deriv3(ii) = p(1);
end

[~,i9] = min(deriv3);

% 0 on right side
iSSRM20 = find(deriv3(i9:end) > 0,1)+i9-1; 
if abs(deriv3(iSSRM20-1)) < abs(deriv1(iSSRM20))
    iSSRM20 = iSSRM20-1;
end

%-----------

%     ifinal = round((iLogAssump+iLogAssump)/2);
% ifinal = iLMPreSlope;
% ifinal = iInterPS;
ifinal = iSSRM20;



try
    delay = timeVal(ifinal);
catch
    delay = 0;
    fprintf('lineNum = %i\n\n\n',lineNum)
end

if debug
    debug2(timeVal, quantity, lineNum, iMaxSlope, iPeak, prei1, preSlope,...
        preY, prei2, imid, iLogAssump, iLMPreSlope, iInterPS, iSSLM20, iSSRM20, ifinal);
end
end

% ----------------------------------------------------------------------- %

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% More Complicated way to find the delay of lines.
%   Many different ways to try to find delay were tried, and left.
% -> Obviously this is very bloated and could be sped up?
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay4(quantity,lineNum,timeVal,fps,npinterpH,smoothRange,debug)
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP

% smooth the quantity
[sTimeVal,sQuantity] = derivSmooth(timeVal,quantity,smoothRange,fps);
[sTimeVal,sQuantity] = derivSmooth(sTimeVal,sQuantity,smoothRange,fps);

delay = findDelay1(sQuantity,lineNum,sTimeVal,fps,npinterpH,debug);
end

% ----------------------------------------------------------------------- %

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% More Complicated way to find the delay of lines.
%   Many different ways to try to find delay were tried, and left.
% -> Obviously this is very bloated and could be sped up?
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay5(quantity,lineNum,timeVal,fps,npinterpH,smoothRange,debug,subMethodNum)
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP

% smooth the quantity
[sTimeVal,sQuantity] = derivSmooth(timeVal,quantity,smoothRange,fps);
[sTimeVal,sQuantity] = derivSmooth(sTimeVal,sQuantity,smoothRange,fps);

delay = findDelay2(sQuantity,lineNum,sTimeVal,fps,npinterpH,debug,subMethodNum);
end

% ----------------------------------------------------------------------- %

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% More Complicated way to find the delay of lines.
%   Many different ways to try to find delay were tried, and left.
% -> Obviously this is very bloated and could be sped up?
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay6(quantity,lineNum,timeVal,fps,npinterpH,smoothRange,debug)
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP

% smooth the quantity
[sTimeVal,sQuantity] = meanSmooth(timeVal,quantity,smoothRange);
[sTimeVal,sQuantity] = derivSmooth(sTimeVal,sQuantity,smoothRange,fps);

delay = findDelay1(sQuantity,lineNum,sTimeVal,fps,npinterpH,debug);
end

% ----------------------------------------------------------------------- %

% WARNING: DO NOT RUN DEBUG MODE IN A LOOP
% More Complicated way to find the delay of lines.
%   Many different ways to try to find delay were tried, and left.
% -> Obviously this is very bloated and could be sped up?
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
function delay = findDelay7(quantity,lineNum,timeVal,fps,npinterpH,smoothRange,debug,subMethodNum)
% NOTE: This method currently assumed 60bpm, but could be easily changed by
% adding another variable
% WARNING: DO NOT RUN DEBUG MODE IN A LOOP

% smooth the quantity
[sTimeVal,sQuantity] = meanSmooth(timeVal,quantity,smoothRange);
[sTimeVal,sQuantity] = derivSmooth(sTimeVal,sQuantity,smoothRange,fps);

delay = findDelay2(sQuantity,lineNum,sTimeVal,fps,npinterpH,debug,subMethodNum);
end



function quantity = flipData(quantity,lineNum)
% Flipping if the pulse goes down for some reason...
if median(quantity) > mean(quantity)
    fprintf('line %i was flipped\n',lineNum)
    % flipping while maintaining old mean
    quantity = -quantity + 2*mean(quantity);
end
end

function [sTimeVal,sQuantity] = meanSmooth(timeVal,quantity,smoothRange)
% totWidth = 2*smoothRange+1;

% center average
sQuantity = quantity;
for ii = (smoothRange+1):(length(quantity)-smoothRange)
    II = (-smoothRange:smoothRange)+ii;
    sQuantity(ii) = mean(quantity(II));
end

% forward average
% sQuantity = zeros(length(quantity)-smoothRange,1);
% for qi = 1:length(sQuantity)   % Smoothing
%     sQuantity(qi) = mean(quantity(qi:qi+smoothRange));
% end

sTimeVal = timeVal(1:length(sQuantity));
end

function [sTimeVal,sQuantity] = derivSmooth(timeVal,quantity,smoothRange,fps)
totWidth = 2*smoothRange;

% Finding a moving backwards derivative
qderiv = zeros(size(quantity));
for ii = 1:length(quantity)-totWidth
    rI = (1:totWidth)+ii-1;
    pf = polyfit(timeVal(rI),quantity(rI),1);
    qderiv(ii+totWidth) = pf(1);
end

% Using derivative to find value
sQuantity = zeros(size(quantity));
sQuantity(1:totWidth) = mean(quantity(1:totWidth))*ones(1,totWidth);
for ii = totWidth+1:length(quantity)
    dt = timeVal(ii)-timeVal(ii-1);
    sQuantity(ii) = qderiv(ii)*dt + sQuantity(ii-1);
end

% Adjusting time since we used a backwards derivative
sTimeVal = timeVal-(2*smoothRange)/fps;
end


function debug2(timeVal, quantity, lineNum, iMaxSlope, iPeak, prei1, preSlope,...
    preY, prei2, imid, iLogAssump, iLMPreSlope, iInterPS, iSSLM20, iSSRM20, ifinal)
stdDevUp = mean(quantity(prei1:prei2)) + 1.5*std(quantity(prei1:prei2));
stdDevDown = mean(quantity(prei1:prei2)) - 1.5*std(quantity(prei1:prei2));

MS = 10;
figure(lineNum)
hold on;
plot(timeVal,quantity)
plot(timeVal(iMaxSlope),quantity(iMaxSlope),'r.','markersize',MS)
plot(timeVal(iPeak),quantity(iPeak),'g.','markersize',MS)

% iPeak instead of end
xx = linspace(timeVal(prei1),timeVal(end),1000);
plot(xx,polyval([preSlope,preY],xx))
plot(timeVal(prei2),quantity(prei2),'k.','markersize',MS)
yline(stdDevUp)
yline(stdDevDown)

plot(timeVal(imid),quantity(imid),'b.','markersize',MS)

plot(timeVal(iLogAssump),quantity(iLogAssump),'y.','markersize',10)
plot(timeVal(iLMPreSlope),quantity(iLMPreSlope),'c.','markersize',10)
plot(timeVal(iInterPS),quantity(iInterPS),'m.','markersize',10)
plot(timeVal(iSSLM20),quantity(iSSLM20),'r*','markersize',MS)
plot(timeVal(iSSRM20),quantity(iSSRM20),'g*','markersize',MS)
plot(timeVal(ifinal),quantity(ifinal),'k*','markersize',MS)

Ltxt = ["Raw Data","Max Slope","0 slope - peak","pre-slope",...
    "Right-most point of pre-slope",...
    "+ 1.5 std dev of pre-slope data",...
    "- 1.5 std dev of pre-slope data",...
    "Mid-pt","1st guess using log assumption",...
    "2nd guess using left march to pre-slope",...
    "3rd guess using slope match to pre-slope",...
    "4th guess using fine gradient left-march to 0 from max slope pt",...
    "5th guess using fine gradient right-march to 0",...
    "Final Point"];
legend(Ltxt,'location','best')
end

function debug1(timeVal, quantity, lineNum,  iMaxSlope, iPeak, prei1, preSlope,...
        preY, imid, polyCoeffs, ifinal, yPt)
MS = 10;
figure(lineNum)
hold on;
plot(timeVal,quantity)
plot(timeVal(iMaxSlope),quantity(iMaxSlope),'r.','markersize',MS)
plot(timeVal(iPeak),quantity(iPeak),'g.','markersize',MS)


xx = linspace(timeVal(prei1),timeVal(iPeak),1000);
plot(xx,polyval([preSlope,preY],xx))

plot(timeVal(imid),quantity(imid),'b.','markersize',MS)


xx = linspace(timeVal(round(iPeak-1.5*(iPeak-iMaxSlope))),timeVal(iPeak),1000);
plot(xx,polyval(polyCoeffs,xx),'m')

plot(timeVal(ifinal),yPt,'k.','markersize',MS)

Ltxt = ["Raw Data","Max Slope","0 slope - peak","pre-slope",...
    "Mid-pt","Front slope","Final Point"];
legend(Ltxt,'location','best')
end


function [x,y] = intersect2lines(m1,y1,m2,y2)
    x = (y2-y1)/(m1-m2);
    y = m1*x+y1;
end

function [iMaxSlope, iPeak, deriv1] = initialValues(timeVal, quantity, npinterpH)
% Finding basic info needed for most methods
deriv1 = zeros(length(timeVal),1);
for ii = npinterpH+1:length(timeVal)-npinterpH
    p = polyfit(timeVal(ii-npinterpH:ii+npinterpH),quantity(ii-npinterpH:ii+npinterpH),1);
    deriv1(ii) = p(1);
end

[~,iMaxSlope] = max(deriv1);

iPeak = iMaxSlope;
while deriv1(iPeak) >=0      % 0 on right side
    iPeak = iPeak+1;
end
if deriv1(iPeak-1) < abs(deriv1(iPeak))
    iPeak = iPeak-1;
end
end

function [prei1, prei2, preSlope, preY] = prePulse(timeVal, quantity, fps, iMaxSlope)
% finding info about pre-pulse
% use peak instead of maxSlope...??
prei1 = iMaxSlope - 1.55*fps;
prei2 = prei1+fps;
if prei1 < 1
    prei1 = 1;
end

p = polyfit(timeVal(prei1:prei2),quantity(prei1:prei2),1);
preSlope = p(1);
preY = p(2);
end

function [iIntersect, imid, polyCoeffs, yPt] = ...
    slopeIntersect(timeVal, quantity, fps, prei1, prei2, preSlope, preY, iMaxSlope, ilow)
% Finding slope on pulse, intersect with pre-pulse slope
ytarget = (mean(quantity(prei1:prei2)) + 3*quantity(iMaxSlope))/4;
[~,imid] = min(abs(quantity(ilow:iMaxSlope)-ytarget));    % finds y-pos between maxSlope and ytarget
imid = imid + ilow;   % Have to do this since the min was indexed from ilow

irange2H = round(0.0208*fps);   % gives 25 for 1200 fps
polyCoeffs = polyfit(timeVal(imid-irange2H:imid+irange2H),quantity(imid-irange2H:imid+irange2H),1);

[xPt,yPt] = intersect2lines(polyCoeffs(1),polyCoeffs(2),preSlope,preY);

[~,iIntersect] = min(abs(timeVal-xPt));
end







