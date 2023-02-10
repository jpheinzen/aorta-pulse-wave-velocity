function skele = orderPts(skeleim,endpts)
skele = zeros(length(find(skeleim)),2);

% [row,col] = find(endpts,1,'last');
[row,col] = find(endpts,1);
skele(1,:) = [row,col];

% starting ordering process...
skeleim(skele(1,1),skele(1,2)) = 0;

[iBottom,iRight] = size(skeleim);

% There has GOT to be a better way to do this, but honestly I'm too lazy to
% change it - this is fast enough to not notice.
for ii = 2:length(skele)
    % is the point on the side?
    onEdge = isOnEdge(skele(ii-1,:),iBottom,iRight);
    %[left  ,  top]
    %[bottom , right]
    if ~onEdge(1,1) && skeleim(skele(ii-1,1),skele(ii-1,2)-1)
        % left
        skele(ii,:) = [skele(ii-1,1),skele(ii-1,2)-1];
    elseif ~onEdge(1,2) && skeleim(skele(ii-1,1)-1,skele(ii-1,2))
        % top
        skele(ii,:) = [skele(ii-1,1)-1,skele(ii-1,2)];
    elseif ~onEdge(2,2) && skeleim(skele(ii-1,1),skele(ii-1,2)+1)
        % right
        skele(ii,:) = [skele(ii-1,1),skele(ii-1,2)+1];
    elseif ~onEdge(2,1) && skeleim(skele(ii-1,1)+1,skele(ii-1,2))
        % bottom
        skele(ii,:) = [skele(ii-1,1)+1,skele(ii-1,2)];
    elseif ~onEdge(1,2) && ~onEdge(1,1) && skeleim(skele(ii-1,1)-1,skele(ii-1,2)-1)
        % top left
        skele(ii,:) = [skele(ii-1,1)-1,skele(ii-1,2)-1];
    elseif ~onEdge(1,2) && ~onEdge(2,2) &&skeleim(skele(ii-1,1)-1,skele(ii-1,2)+1)
        % top right
        skele(ii,:) = [skele(ii-1,1)-1,skele(ii-1,2)+1];
    elseif ~onEdge(2,1) && ~onEdge(2,2) && skeleim(skele(ii-1,1)+1,skele(ii-1,2)+1)
        % bottom right
        skele(ii,:) = [skele(ii-1,1)+1,skele(ii-1,2)+1];
    elseif ~onEdge(2,1) && ~onEdge(1,1) && skeleim(skele(ii-1,1)+1,skele(ii-1,2)-1)
        % bottom left
        skele(ii,:) = [skele(ii-1,1)+1,skele(ii-1,2)-1];
    else
        error(['Not able to find an order in skeleton - There might be '...
            'a discontinuty...?'])
    end
    skeleim(skele(ii,1),skele(ii,2)) = 0;
end

if any(skeleim)
    error('There''s a point in skeleim that was left behind.')
end
end


function onEdge = isOnEdge(position,iBottom,iRight)
%[left  ,  top]
%[bottom , right]
onEdge = zeros(2,'logical');
if position(1) == 1             % top edge
    onEdge(1,2) = true;
elseif position(1) == iBottom   % bottom edge
    onEdge(2,1) = true;
end
if position(2) == 1             % left edge
    onEdge(1,1) = true;
elseif position(2) == iRight    % right edge
    onEdge(2,2) = true;
end
end
