function printProgress(count, total, descrip)
%% Info:
% printProgress - prints the number of iterations passed
%
% See also printTime.

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Oct. 15th, 2022

% TODO:
%   Finish Header
%   Add functionality to be able to add \n,\t into descrip

%% Main
if nargin < 3
    descrip = "";
else
    descrip = strcat(descrip,": ");
end
if count == 1
    fprintf("%s",descrip)
end

onePerc = round(total/100);
if onePerc == 0     % To make sure this works with totals < 100
    onePerc = 1;
end

if count==total && mod(count,onePerc)~=0 
    txt = length(num2str((round(count/onePerc))*onePerc)) + 2 +...
            length(num2str(total));
    fprintf(repmat('\b',1,txt))
    fprintf('%u/%u\n',count,total);
elseif mod(count,onePerc)==0 
    if count ~= onePerc
        txt = length(num2str((round(count/onePerc)-1)*onePerc)) + 2 +...
            length(num2str(total));
        fprintf(repmat('\b',1,txt))
    end
    fprintf('%u/%u\n',count,total);
end
end