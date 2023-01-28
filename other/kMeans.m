function [means,assignments,nIter] = kMeans(im,k,meanColors)
%% Info:
% kMeans - Standard K-Means algorithm - takes pixels and groups them into
% categories of like colors.
% 
% Functions:
% 
%
% See also

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Nov 12th, 2022

% TODO:
%   Finish Header
%   INPUT CHECKING!!!!! see note below

%% Main
fprintf('kMeans working\n')

[height,width,depth] = size(im);
% NEED TO CHECK SIZE OF meanColors!!!! this could be a real headache. 
% meanColors change input of size (n,3) to (1,n,3) as needed

type = class(im);
maxCVal = 2^str2double(erase(type,'uint'))-1;

nIter = 0;

% Setting Initial Guess
if nargin == 3      % Can set initial guess using meanColors
    if string(class(meanColors)) ~= string(type)
        meanColors = cast(meanColors,type);
    end

    % meanColors is (3,n)
    if size(meanColors,3) == 1 && size(meanColors,1) == 3
        % Reshaping to the correct (1,n,3)
        meanColors = reshape(meanColors',1,[],3);
    end

    % Mean Colors should be of size (1,n,3) where 0 <= n <=k
    if size(meanColors,1) ~= 1 || size(meanColors,3) ~= 3
        error('size of meanColors needs to be (1,n,3) where 0 <= n <=k')
    elseif size(meanColors,2) > k
        error('# of groups k needs to be larger for specified meancolors')
    elseif size(meanColors,2) <= k
        rng('shuffle');
        % Set the rest of the unspecified groups to be random
        means = [meanColors,randi([0,maxCVal],1,k-size(meanColors,2),depth,type)];
    end    
else
    rng('shuffle');
    means = randi([0,maxCVal],1,k,depth,type);
end

assignments = updateAssignments(im,means);
oldAssignments = zeros(height,width,depth);

while any(oldAssignments ~= assignments,'all')
    nIter = nIter+1;
    if (mod(nIter,1)==0)
        fprintf('\b.\n')
    end
    oldAssignments = assignments;

    means = updateMeans(im,assignments,k,type);
    assignments = updateAssignments(im,means);
end
fprintf('done!\n')
end

function assignments = updateAssignments(im,means)
% this function is an artifact of kMeansOld - keep cuz why not?
assignments = assignmentsLabel(im,means);
end

function means = updateMeans(im,assignments,k,type)
depth = size(im,3);
means = zeros(1,k,depth,type);
for ii = 1:k    
    [row,~] = find(assignments==ii);
    assignedColors = zeros(1,length(row),3,type);

    for jj = 1:3
        im1 = im(:,:,jj);
        assignedColors(1,:,jj) = im1(assignments==ii);
    end

    if isempty(assignedColors)
        means(1,ii,:) = zeros(1,1,depth,type);
    else
        means(1,ii,:) = averageColor(assignedColors, type);
    end
end
end

function indexMinDist = assignmentsLabel(color,means)
% to transform means from standard 3xn or 1xnx3 to 1x1x3xn as neededyy
if size(means,1)==3
    means = reshape(means,1,1,3,[]);
elseif size(means,3)==3
    means = reshape(permute(means,[1,3,2]),1,1,3,[]);
end

distance = sqrt(sum((double(means)-double(color)).^2,3));
[~,indexMinDist] = min(distance,[],4);
end

function aveC = averageColor(colors,type)
aveC = cast(mean(colors,2),type);
end


