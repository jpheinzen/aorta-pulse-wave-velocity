function [index] = getColor(aortaIndex,means,assignments)
%% Getting the index of the color that associates with the aorta in means
% This is where you could auto-assign weights to wt

if nargin == 3
    Plot = true;
else
    Plot = false;
end

if aortaIndex < 1
    warning(['aortaIndex was incorrectly set to %i (< 0).',...
        ' Resetting to 1'],aortaIndex)
    aortaIndex = 1;
end

[~,inds] = maxk(mean(means,3),aortaIndex);

index = inds(end);

% for ii = 1:min(aortaIndex,size(means,2))
%     [~,index] = max(mean(meanstemp,3));
%     meanstemp(1,index,:) = zeros(1,1,3);
% end

if Plot
    meanstemp = zeros(size(means),class(means));
    meanstemp(1,index,:) = means(1,index,:);
    im3 = makeNewIm(meanstemp,assignments);
    imshow(im3)
end

% automatic wt finding...?
% 1/(mean(means)+std(double(means)))
% mInd = inds(1);
% means(1,[1:mInd-1,mInd+1:end],:)
% 
% [~,mInd] = max(mean(means,3));
% [~,wtInds] = maxk(mean(means,3),2);
% diff(fliplr(means(1,wtInds,:)),1,2);
% double(diff(fliplr(means(1,wtInds,:)),1,2))./std(double(means));
end