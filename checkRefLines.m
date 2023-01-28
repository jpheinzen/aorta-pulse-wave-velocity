%% parseGraphs
% Allows you to easily parse through the data and pull out reference lines
% and their corresponding data. Use wasd to control. a for decreasing line
% number, d for increasing line numer, p will play the frames as if they
% are a video, and c will change the reference line length. R will run a
% task specified by runTask (needs to be written for any task). Z will undo
% the task run by R. Use L to leave. It will make a plot of image with
% lines when you leave.

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Dec. 27th, 2022
clc
close all

folderName = 'Test7-34in-2000_single_pulse\ts3_000002';
lineLength = 100;

% import video initialization data
[~,vidName, numFrames, type, maxCVal, height, width] = vidInit(folderName);

dispHelp;

frameIndex = 1;

fh = figure();
ah = axes(fh);
hold on;

frame = imread(vidName(frameIndex));  % could also use importdata
Ih = imshow(frame);
% uistack(ph,'bottom');

ph = pltRefLines(skele,lineLength,ah);

repeat = true;
while repeat
    frameIndex = wrapFrameNum(frameIndex,numFrames);

    frame = imread(vidName(frameIndex));  % could also use importdata
    set(Ih,'CData',frame);

    legend(ah,string(frameIndex))

    buttonPressChar = getButton(fh);
    
    switch buttonPressChar
        case {'d','D'}  % go to next line
            frameIndex = frameIndex+1;
        case {'a','A'}  % go to last line
            frameIndex = frameIndex-1;
        case {'p','P'}  % Play video
            frameIndex = playVideo(fh,ah,Ih,vidName,frameIndex,100);
        case {'c','C'}  % Change reference line length
            lineLength = changeRefLength(fh,lineLength);
            delete(ph);
            ph = pltRefLines(skele,lineLength,ah);
        case {'f','F'}  % go to inputted number
            frameIndex = inputLineNum(fh,numFrames,frameIndex);
        case {'r','R'}  % run task
            runOut = runTask(linesToHold, frameIndex, numLinesToHold);
        case {'z','Z'}  % undo task
            undoTask(runOut, linesToHold, frameIndex, numLinesToHold);
        case {'l','L'}  % leave
            % leave loop
            repeat = false;
        otherwise
            dispHelp;
    end
end

close(fh)
%%
function endFrameIndex = playVideo(fh,ah,ph,vidName,frameIndex,skipNumber)
fprintf(['press W or L to stop playing video.\nPress E to go forward',...
    ' in time; Q to go backwards in time.\nS to stop on current frame.\n'])

if nargin < 6
    skipNumber = 1;
end

numFrames = length(vidName);
fh.CurrentCharacter = 'e';
buttonPressChar = fh.CurrentCharacter;
while ~(buttonPressChar == "w" || buttonPressChar == "W" || ...
        buttonPressChar == "l" || buttonPressChar == "L")
    frameIndex = wrapFrameNum(frameIndex,numFrames);
 
    frame = imread(vidName(frameIndex));  % could also use importdata
    set(ph,'CData',frame);
    
    legend(ah,string(frameIndex))
    drawnow

    if buttonPressChar == "q" || buttonPressChar == "Q"
        frameIndex = frameIndex - skipNumber;
    elseif buttonPressChar == "e" || buttonPressChar == "E"
        frameIndex = frameIndex + skipNumber;
    end

    buttonPressChar = fh.CurrentCharacter;
    figure(fh)
end
endFrameIndex = frameIndex;
end

function lineLength = changeRefLength(fh,currentLineLength)
repeat = true;

while repeat
    fprintf(['Press ''C'' to finish inputting number. ', ...
        'Press ''L'' to exit inputting without change.\n'])

    txt = 0;
    indexStr = '';
    buttonPressChar = '';
    while buttonPressChar ~= "c" && buttonPressChar ~= "C" && ...
            buttonPressChar ~= "l" && buttonPressChar ~= "L"
        indexStr = strcat(indexStr,buttonPressChar);
        fprintf(repmat('\b',1,txt))
        txt = fprintf('\t%s\n',indexStr);

        buttonPressChar = getButton(fh);
    end
    
    if buttonPressChar == "l" || buttonPressChar == "L" || indexStr == ""
        lineLength = currentLineLength;
        fprintf('\b%i <--\n',currentLineLength);
        return;
    end

    if isnan(str2double(indexStr))
        fprintf('Entered line index isn''t a number. Try again.\n')
    elseif str2double(indexStr) < 1
        fprintf(['Entered line index is too small. '...
            '\nTry again.\n'])
    else
        lineLength = str2double(indexStr);
        repeat = false;
        fprintf('\b <--\n');
    end
end
end

function ph = pltRefLines(skele,lineLength,ah,numsToPlot)
% ms = 10;



skeleXY = fliplr(skele);
NUMLINES = length(skele);
p1e = zeros(NUMLINES,2);
p2e = zeros(NUMLINES,2);
thta = zeros(1,NUMLINES);

if nargin < 4
    numsToPlot = 1:round(NUMLINES/100):NUMLINES;
end

ph = gobjects(length(numsToPlot),1);

for index = 1:length(numsToPlot)
    ii = numsToPlot(index);

    if ii == NUMLINES
        thta(NUMLINES) = findThetaSkele(skeleXY,NUMLINES-1);
    else
        thta(ii) = findThetaSkele(skeleXY,ii);
    end

    pm = skeleXY(ii,:);

    d = lineLength;

    x = cosd(thta(ii))*d;
    y = sind(thta(ii))*d;

    p1e(ii,:) = round([pm(1)-x,pm(2)+y]);
    p2e(ii,:) = round([pm(1)+x,pm(2)-y]);

    %         plot(pm(1),pm(2),ptType(ii),'markersize',ms)
    %         plot(p1e(ii,1),p1e(ii,2),ptType(ii),'markersize',ms)
    %         plot(p2e(ii,1),p2e(ii,2),ptType(ii),'markersize',ms)

%     ph = plot(linspace(p1e(ii,1),p2e(ii,1),1000),...
%         linspace(p1e(ii,2),p2e(ii,2),1000),...
%         'linewidth',1.5);
    ph(index) = plot(ah,[p1e(ii,1),p2e(ii,1)],...
        [p1e(ii,2),p2e(ii,2)],...
        'linewidth',1.5);
%     set(ph,'color',linesToHold(index).lnHandle.Color,...
%         'LineStyle',linesToHold(index).lnHandle.LineStyle);
end
end

function lineNum = inputLineNum(fh,NUMFRAMES,currentLineIndex)
repeat = true;

while repeat
    fprintf(['Press ''f'' to finish inputting number. ', ...
        'Press ''L'' to exit line search.\n'])

    txt = 0;
    indexStr = '';
    buttonPressChar = '';
    while buttonPressChar ~= "f" && buttonPressChar ~= "F" && ...
            buttonPressChar ~= "l" && buttonPressChar ~= "L"
        indexStr = strcat(indexStr,buttonPressChar);
        fprintf(repmat('\b',1,txt))
        txt = fprintf('\t%s\n',indexStr);

        buttonPressChar = getButton(fh);
    end
    
    if buttonPressChar == "l" || buttonPressChar == "L" || indexStr == ""
        lineNum = currentLineIndex;
        fprintf('\b%i <--\n',currentLineIndex);
        return;
    end

    if isnan(str2double(indexStr))
        fprintf('Entered line index isn''t a number. Try again.\n')
    elseif str2double(indexStr) < 1 || str2double(indexStr) > NUMFRAMES
        fprintf(['Entered line index is too big or too small. '...
            'There are only %i reference lines.\nTry again.\n'],NUMFRAMES)
    else
        lineNum = str2double(indexStr);
        repeat = false;
        fprintf('\b <--\n');
    end
end
end

function buttonPressChar = getButton(fh)
buttonPressed = false;
while ~buttonPressed
    buttonPressed = waitforbuttonpress;
    buttonPressChar = fh.CurrentCharacter;
end
end

function dispHelp
fprintf(['Use wasd to control. a for left, d for right.\n', ...
         'p to play video, c to change reference line length.\n'...
         'f to search for line number.\n',...
         'r runs a task; z undos the task.\nUse L to leave\n'])
end

function frameIndex = wrapFrameNum(frameIndex,numFrames)
if frameIndex < 1
    frameIndex = numFrames;
    fprintf("Wrapping to end.\n")
elseif frameIndex > numFrames
    frameIndex = 1;
    fprintf("Wrapping to beginning\n")
end
end

function runOut = runTask(~, ~, ~)
% function that needs to built if you want to run anything.
fprintf(['runTask does nothing until you write the function.\n', ...
            'you also need to write the task''s undo function.\n']);
runOut = nan;
end

function undoTask(~, ~, ~, ~)
% function must undo what runTask does.
fprintf(['undoTask does nothing until you write the function.\n', ...
            'you also need to write the task''s run function.\n']);
end




















