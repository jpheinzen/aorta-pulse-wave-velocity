function thta = findThetaSkele(skele,startInd)
ii = startInd;
x1 = skele(ii,1);
x2 = skele(ii+1,1);
y1 = skele(ii,2);
y2 = skele(ii+1,2);

normal = cross([x2-x1;y1-y2;0],[0;0;1]);

thta = atan2d(normal(2),normal(1));
end