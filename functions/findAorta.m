function Lim2 = findAorta(Lim,height,width)
CC = bwconncomp(Lim);
Lim2 = zeros(height,width,1,'logical');

connSize = 0;
for ii = 1:length(CC.PixelIdxList)
    if length(CC.PixelIdxList{ii}) > connSize
        connSize = length(CC.PixelIdxList{ii});
        aortaCC = CC.PixelIdxList{ii};
    end
end

% Sets the data to be true only where the aorta is
Lim2(aortaCC) = 1;
end