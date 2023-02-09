%% parseGraphs
% Allows you to easily parse through the data and pull out reference lines
% and their corresponding data. Use wasd to control. a for decreasing line
% number, d for increasing line numer, w to pop line (delete from graph),
% and s to add line to graph. Use q to jump to next smaller plotted line
% number and e to jump to next larger plotted line number. R will run a
% task specified by runTask (needs to be written for any task). Z will undo
% the task run by R. Use L to leave. It will make a plot of image with
% lines when you leave.

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Dec. 13th, 2022
clc
close all

% load('fileName.mat')

im = mov.cdata;
timeVal = (1:numFrames)/fps;

% linesToHold = struct('lnHandle',gobjects(1),'lnNum',0,'objNum',0);
linesToHold = struct('lnHandle',gobjects(1),'lnNum',0);
numLinesToHold = 0;

dispHelp;

lineIndex = 1;
fh = figure();
ah = axes(fh);
hold on;

repeat = true;
while repeat
    if lineIndex < 1
        lineIndex = NUMLINES;
        fprintf("Wrapping to end.\n")
    elseif lineIndex > NUMLINES
        lineIndex = 1;
        fprintf("Wrapping to beginning\n")
    end

    ph = plot(timeVal,cLines(lineIndex).wtd-mean(cLines(lineIndex).wtd));

    if numLinesToHold == 0
        legend(ah,string(lineIndex))
    else
        legend(ah,[string(cell2mat({linesToHold.lnNum})),string(lineIndex)])
    end

    buttonPressChar = getButton(fh);
    
    keepPlot = false;

    switch buttonPressChar
        case {'d','D'}  % go to next line
            lineIndex = lineIndex+1;
        case {'a','A'}  % go to last line
            lineIndex = lineIndex-1;
        case {'s','S'}  % add to figure
            % making sure you can't add a million of the same line
            if all(cell2mat({linesToHold.lnNum}') ~= lineIndex)
                keepPlot = true;
            end
        case {'w','W'}  % pull from figure
            [linesToHold, numLinesToHold] =...
                pullFromFigure(linesToHold,numLinesToHold, lineIndex);
        case {'q','Q'}  % go to last plotted line number
            lineIndex = goToLine(lineIndex,linesToHold, ...
                numLinesToHold, 'backward');
        case {'e','E'}  % go to next plotted line number
            lineIndex = goToLine(lineIndex,linesToHold, ...
                numLinesToHold, 'forward');forward
        case {'f','F'}  % go to inputted number
            lineIndex = inputLineNum(fh,NUMLINES,lineIndex);
        case {'r','R'}  % run task
            runOut = runTask(linesToHold, lineIndex, numLinesToHold);
        case {'z','Z'}  % undo task
            undoTask(runOut, linesToHold, lineIndex, numLinesToHold);
        case {'l','L'}  % leave
            % leave loop
            repeat = false;
        otherwise
            dispHelp;
    end
   
    if ~keepPlot
        delete(ph)
        
    else
        linesToHold(numLinesToHold+1).lnHandle = ph;
        linesToHold(numLinesToHold+1).lnNum = lineIndex;
%         linesToHold(numLinesToHold+1).objNum = length(ah.Children)+1;
        numLinesToHold = numLinesToHold+1;
    end
end

if numLinesToHold > 0
    pltRefLines(skele,lineLength,im,linesToHold)
else
    close(fh)
end
%%

function pltRefLines(skele,lineLength,im,linesToHold)
% ms = 10;
fh = figure();
imshow(im);
fh.WindowState = 'maximized';
hold on

skeleXY = fliplr(skele);
NUMLINES = length(skele);
p1e = zeros(NUMLINES,2);
p2e = zeros(NUMLINES,2);
thta = zeros(1,NUMLINES);

numsToPlot = cell2mat({linesToHold.lnNum});

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
    ph = plot([p1e(ii,1),p2e(ii,1)],...
        [p1e(ii,2),p2e(ii,2)],...
        'linewidth',1.5);
    set(ph,'color',linesToHold(index).lnHandle.Color,...
        'LineStyle',linesToHold(index).lnHandle.LineStyle);
end
end

function lineNum = inputLineNum(fh,NUMLINES,currentLineIndex)
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
    elseif str2double(indexStr) < 1 || str2double(indexStr) > NUMLINES
        fprintf(['Entered line index is too big or too small. '...
            'There are only %i reference lines.\nTry again.\n'],NUMLINES)
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

function [linesToHold, numLinesToHold] =...
    pullFromFigure(linesToHold,numLinesToHold, currentLineNum)
if any(cell2mat({linesToHold.lnNum}') == currentLineNum)
    % find index of Line in struct
    index = find(cell2mat({linesToHold.lnNum}') == currentLineNum);
    % delete from figure
    delete(linesToHold(index).lnHandle)
    % delete from structure
    linesToHold = [linesToHold(1:index-1),linesToHold(index+1:end)];
    numLinesToHold = numLinesToHold - 1;
else
    fprintf('Plot %i is''t plotted. Can''t delete.\n',currentLineNum)
end
end

function lineIndex = goToLine(lineIndex,linesToHold, numLinesToHold, dir)
if numLinesToHold == 0
    fprintf('There are no plotted lines to jump to.\n');
    return
end
if ~isstring(dir) && ~ischar(dir)
    error('goToLine:dirInit', ...
        ['Direction need to be ''forward''/''backward''.', ...
        'it is currently %s'],string(dir));
end

switch dir
    case "forward"
        lineIndex = goToNextLine(lineIndex,linesToHold);
    case "backward"
        lineIndex = goToLastLine(lineIndex,linesToHold);
    otherwise
    error('goToLine:dirInit', ...
        ['Direction need to be ''forward''/''backward''.', ...
        'it is currently %s'],string(dir));
end
end

function lineNum = goToNextLine(currentIndex,linesToHold)
plottedLineNums = cell2mat({linesToHold.lnNum});

lineNum = inf;
for jj = 1:length(plottedLineNums)
    index = plottedLineNums(jj);
    
    if index > currentIndex && ...
            (index - currentIndex) < (lineNum - currentIndex)
        lineNum = index;
    end

end

% no Plotted Line is larger than the current line, so wrapping to smallest
% plotted line number
if lineNum == inf
    lineNum = min(plottedLineNums);
end

end

function lineNum = goToLastLine(currentIndex,linesToHold)
plottedLineNums = cell2mat({linesToHold.lnNum});

lineNum = 0;
for jj = 1:length(plottedLineNums)
    index = plottedLineNums(jj);
    
    if index < currentIndex && ...
            (currentIndex - index) < (currentIndex - lineNum)
        lineNum = index;
    end

end

% no Plotted Line is smaller than the current line, so wrapping to largest
% plotted line number
if lineNum == 0
    lineNum = max(plottedLineNums);
end
end

function dispHelp
fprintf(['Use wasd to control. a for left, d for right, ', ...
         'w to pop, and s to add.\nq/e to go to last/next ', ...
         'plotted line; f to search for line number.\n',...
         'r runs a task; z undos the task.\nUse L to leave\n'])
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




















