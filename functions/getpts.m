function [ptInds, numPts] = getpts(startpt, endpt, theta, height, width)
% y1 = startpt(2); % x1 = startpt(1); % y2 = endpt(2); % x2 = endpt(1);

numPts = 1;
ptInds(1,:) = startpt;
while any(ptInds(numPts,:) ~= endpt)
    x = round(cosd(theta)+ptInds(numPts,1));
    y = round(-sind(theta)+ptInds(numPts,2));
    ptInds(numPts+1,:) = [x,y];
    numPts = numPts+1;
end

% cut all points from the start that aren't in bounds
ii = 1;
while ~ptInBoundary(ptInds(ii,:),height,width)
    ii = ii+1;
end
% cut all points from the end that aren't in bounds
jj = numPts;
while ~ptInBoundary(ptInds(jj,:),height,width)
    jj = jj-1;
end
ptInds = ptInds(ii:jj,:);
numPts = jj-ii+1;
end