function [inOrder,output] = checkVidOrder(vidNames,errorHandle)
if nargin < 2
    errorHandle = false;
end

w = vidNames(1);
% find where extension starts
pos2 = find(isstrprop(w,'punct'), 1, 'last' );
% remove extension
w = extractBefore(w,pos2);
%   find where start of last number begins
pos1 = find(~isstrprop(w,'digit'), 1, 'last' );

if isempty(pos1) || pos1 < 0
    pos1 = 0;
end
% extract entire array
g = extractBetween(vidNames,pos1+1,pos2-1);
% change to doubles
output = str2double(g);

inOrder = issorted(output,'ascend');

if (errorHandle && ~inOrder)
    error('Array is NOT sorted')
end
end