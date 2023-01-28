function skele = orderPts(skeleim,endpts)
skele = zeros(length(find(skeleim==1)),2);

% [row,col] = find(endpts==1,1,'last');
[row,col] = find(endpts==1,1);
skele(1,:) = [row,col];

skeleim(skele(1,1),skele(1,2)) = 0;

% There has GOT to be a better way to do this, but honestly I'm too lazy to
% change it - this is fast enough to not notice.
for ii = 2:length(skele)
    if skeleim(skele(ii-1,1)-1,skele(ii-1,2)-1)
        skele(ii,:) = [skele(ii-1,1)-1,skele(ii-1,2)-1];
    elseif skeleim(skele(ii-1,1)-1,skele(ii-1,2))
        skele(ii,:) = [skele(ii-1,1)-1,skele(ii-1,2)];
    elseif skeleim(skele(ii-1,1)-1,skele(ii-1,2)+1)
        skele(ii,:) = [skele(ii-1,1)-1,skele(ii-1,2)+1];
    elseif skeleim(skele(ii-1,1),skele(ii-1,2)-1)
        skele(ii,:) = [skele(ii-1,1),skele(ii-1,2)-1];
    elseif skeleim(skele(ii-1,1),skele(ii-1,2)+1)
        skele(ii,:) = [skele(ii-1,1),skele(ii-1,2)+1];
    elseif skeleim(skele(ii-1,1)+1,skele(ii-1,2)-1)
        skele(ii,:) = [skele(ii-1,1)+1,skele(ii-1,2)-1];
    elseif skeleim(skele(ii-1,1)+1,skele(ii-1,2))
        skele(ii,:) = [skele(ii-1,1)+1,skele(ii-1,2)];
    elseif skeleim(skele(ii-1,1)+1,skele(ii-1,2)+1)
        skele(ii,:) = [skele(ii-1,1)+1,skele(ii-1,2)+1];
    else
        error(['Not able to find an order in skeleton - There might be '...
            'a discontinuty...?'])
    end
    skeleim(skele(ii,1),skele(ii,2)) = 0;
end
end