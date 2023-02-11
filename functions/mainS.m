function cLines = mainS(NUMLINES, p1e, p2e, thta, vidName, nMaxFrames, wt)
[height,width,depth] = size(imread(vidName(1)));
if depth==1
    BW = true;          % .tif is black and white
else
    BW = false;         % .tif is color
end

% find the number of frames, limited by the user or the number of images
numFrames = min(length(vidName),nMaxFrames);

cLines = struct('pti',zeros(2,2),'npts',0,'wtd',zeros(1,numFrames));
cLines = repmat(cLines, NUMLINES,1);

for ii = 1:NUMLINES
    [cLines(ii).pti, cLines(ii).npts] = getpts(p1e(ii,:), p2e(ii,:), thta(ii),height,width);
    printProgress(ii, NUMLINES,'Finding Pts to analyze')
end
tic

% - COULD ALSO USE FRAME TIME OR SMTH TO RESET VIDEOREADER

frameReadNum = 1;
% % Read one frame at a time until the end of the video is reached.
while frameReadNum <= numFrames && frameReadNum <= nMaxFrames
    frame = imread(vidName(frameReadNum));  % could also use importdata

    if BW
        % Needed since .tif is b&w
        frame = repmat(frame,[1,1,3]);
    end

    for jj = 1:NUMLINES
        % Picks out all of the values of all of the pixels on a line at
        % once
        % could sum them right away to reduce memory usage, but it seems
        % more clear what's going on this way
        rgb = frame(sub2ind(size(frame),...
            repmat(cLines(jj).pti(:,2),[1,3,1]),...
            repmat(cLines(jj).pti(:,1),[1,3,1]),...
            [1,2,3].*ones(cLines(jj).npts,3)    )  );
        % Sum into a weighted average for each line
        cLines(jj).wtd(frameReadNum) =...
                sum(wt.*sum(rgb,1)) / ...
                        (sqrt(sum(wt.^2)) * cLines(jj).npts );      
    end
    
    printTime(frameReadNum, min(numFrames,nMaxFrames), toc)
    frameReadNum = frameReadNum+1;
end
end