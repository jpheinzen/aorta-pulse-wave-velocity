function im = deleteArea(im)
fh = figure();
imshow(im)
fh.WindowState = 'maximized';
h = drawpolyline('Color','green','linewidth',1); %draw line
h.Position(end+1,:) =  h.Position(1,:);     % connects end points
polyPts = h.Position;         % h can disappear if you delete figure - not good
close(fh)

[row,col,~] = find(im(:,:,1));
xq = row;
yq = col;
xv = polyPts(:,2);
yv = polyPts(:,1);

[in,on] = inpolygon(xq,yq,xv,yv);
rowind = xq(in);
colind = yq(in);

for k = 1:length(rowind)            % should probably try to do as a vector and not as a loop...
    im(rowind(k),colind(k),:) = [0;0;0];      % also a little janky to me..
end

imshow(im)
end