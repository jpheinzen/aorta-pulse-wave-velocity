function [thta,p1e,p2e,NUMLINES] = refLines(skele,lineLength,mov)
% This function is very messy.....

if nargin == 3
    PLOT = true;
else
    PLOT = false;
end

skeleXY = fliplr(skele);
NUMLINES = length(skele);

if PLOT
    color = ["red","green","blue","cyan","magenta","black"];
    lineColor = @(x) color(mod(x-1,length(color))+1);
    lnType = ["-","--","-."];
    lineType = @(x)...
        strcat(lnType(mod(fix((x-1)/length(color)),length(lnType))+1),...
        color(mod(x-1,length(color))+1));

    % %% Fixing Lines
    colorp = ["g.","b.","c.","m.","k.","r."];
    ptType = @(x) colorp(mod(x-1,length(colorp))+1);
    ms = 10;
    fh = figure();
    imshow(mov(1).cdata)
    fh.WindowState = 'maximized';
    hold on
end

p1e = zeros(NUMLINES,2);
p2e = zeros(NUMLINES,2);
thta = zeros(1,NUMLINES);


for ii = 1:NUMLINES
    if ii == NUMLINES
        thta(NUMLINES) = findThetaSkele(skeleXY,NUMLINES-1);
    else
        thta(ii) = findThetaSkele(skeleXY,ii);
    end

    pm = skeleXY(ii,:);

    d = lineLength;

    x = cosd(thta(ii))*d;
    y = sind(thta(ii))*d;

    p1e(ii,:) = round([pm(1)-x,pm(2)+y]);
    p2e(ii,:) = round([pm(1)+x,pm(2)-y]);

    if PLOT
        plot(pm(1),pm(2),ptType(ii),'markersize',ms)
        plot(p1e(ii,1),p1e(ii,2),ptType(ii),'markersize',ms)
        plot(p2e(ii,1),p2e(ii,2),ptType(ii),'markersize',ms)

        plot([p1e(ii,1),p2e(ii,1)],...
            [p1e(ii,2),p2e(ii,2)],...
            lineType(ii),'linewidth',1.5)
    end

    printProgress(ii, NUMLINES,'Finding points on ref. lines')
end
if PLOT
    drawnow
end
end