function checkSkeleOrder(skele, Lim, type, maxCVal, height, width)
imcheck = zeros(height,width,1,type);
imcheck(Lim) = maxCVal;
imcheck = repmat(imcheck,[1,1,3]);
% imshow(imcheck)

for ii = 1:length(skele) % start is red, end is green
    imcheck(skele(ii,1),skele(ii,2),1) = maxCVal-maxCVal*ii/length(skele);
    imcheck(skele(ii,1),skele(ii,2),2) = maxCVal*ii/length(skele);
    imcheck(skele(ii,1),skele(ii,2),3) = 0;
end

imshow(imcheck)
text(2,3,"'in' side is red, 'out' side is green",'Color','white')
end