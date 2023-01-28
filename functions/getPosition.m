function posVal = getPosition(skele, NUMLINES) 

%% Input Checking
if size(skele,2) ~= 2 || size(skele,1) ~= NUMLINES
    error('skele needs to be size (NUMLINES,2)')
elseif ~isnumeric(skele) || ~isnumeric(NUMLINES)
    error('skele or NUMLINES are not numbers')
elseif ~isscalar(NUMLINES)
    error('NUMLINES needs to be a scalar')
end

%% Running function
% Here I define any diagonal movement as a pixel distance of sqrt(2) and
%   any horizontal movement as a pixel distance of 1.
posVal = zeros(NUMLINES,1);
for ii = 2:NUMLINES
    if all(skele(ii,:) == skele(ii-1,:))        % if both pts are the same
        posVal(ii) = posVal(ii-1);
    elseif all(skele(ii,:) ~= skele(ii-1,:))    % next point is diagonal
        posVal(ii) = posVal(ii-1)+sqrt(2);
    else                                        % next point is horizontal
        posVal(ii) = posVal(ii-1)+1;
    end
end
end