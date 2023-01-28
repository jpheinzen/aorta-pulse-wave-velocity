function [skeleim, endpts] = findSkeleton(Lim, minBL,growthFactor,Plot)
if nargin < 3
    growthFactor = 2;
    Plot = false;
elseif nargin < 4
    Plot = false;
end

[out, skeleim, endpts] = doubleBWSkel(Lim, minBL);

while length(find(endpts)) > 2
    minBL = round(growthFactor*minBL);
    [out, skeleim, endpts] = doubleBWSkel(Lim, minBL);
end

if Plot
    imshowpair(out,skeleim,'montage')
end
end