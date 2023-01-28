function pix2MScaling = findScaling(im,distanceinM)
% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Dec. 31st, 2022

% TODO:
%   Finish Header

pixLength = 0;

fh = figure();
imshow(im)
fh.WindowState = 'maximized';
h = drawpolyline('Color','red','linewidth',1); %draw line
% h.Position(end+1,:) =  h.Position(1,:);     % connects end points
polyPts = h.Position;         % h can disappear if you delete figure - not good
close(fh)

xv = polyPts(:,2);
yv = polyPts(:,1);

for ii = 2:size(polyPts,2)
    pixLength = pixLength + sqrt((xv(ii) - xv(ii-1))^2 + (yv(ii) - yv(ii-1))^2);
end

pix2MScaling = distanceinM/pixLength;

end