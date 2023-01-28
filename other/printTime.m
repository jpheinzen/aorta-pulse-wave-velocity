function printTime(count, total, timeTaken, countRem)
%% Info:
% printTime - prints the approximate time remaining for a script.
%
% See also printProgress.

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Oct. 15th, 2022

% TODO:
%   Finish Header
%   Add functionality to 
%       delete previous times
%       to display only time left/only finish time

%% Main
if nargin == 4
    timeLeft = timeTaken/(count)*countRem;
elseif nargin == 3
    timeLeft = timeTaken/(count)*(total-count);
end
fprintf('Remaining Time: %s\tFinish Time:%s\n',...
    duration(0,0,timeLeft,'format','hh:mm:ss'),...
    datestr(datetime('now')+seconds(timeLeft),16));
end

%% Ideas?

% flag: 
% 
% Inputs:
%   flag - defaults to 0
%       0: 
%       1:
%       2: 
%       3:  uses countRem instea
%       4:
%       5:
%   countRem - the number of iterations remaining in script. Can only be
%       provided if flag is set to [~ ~ 1 ~].
% 
% if nargin == 3
%     flag = 0;
% elseif nargin == 4 && (flag ~= 0 || flag ~= 1)
%     if flag == 0
%     error('when flag is 2 or 3, countRem needs to be provided')
% elseif nargin == 5 && (flag ~= 2 || flag ~= 3)
%     warning('when flag is 0 or 1, countRem is not used. Ignoring it...')
% elseif nargin ~= 5 && nargin ~=4
%     error('function printTime needs 3 to 5 inputs.')
% end