function PWV = pressurePWV(fileName,pSenseDistM,methodNum,npinterpH,debug,smoothFactor)
arguments
    fileName {mustBeTextScalar(fileName)}
    pSenseDistM (1,1)
    methodNum (1,1) = 1;
    npinterpH (1,1) = 200;
    debug (1,1) {mustBeNumericOrLogical} = false;
    smoothFactor (1,1) {mustBePositive} = 10;
end

% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Dec. 31st, 2022

% TODO:
%   Finish Header

% loading variables
load(fileName,'P_up','P_down')
% finding fps of pressure data
[~,fps] = min(abs(P_up(:,1)-1));

% This is to adjust the fps to the correct one (repeated first value)
fps = fps-2;

% position value
posVal = [0,pSenseDistM];

delay = zeros(1,2);

delay(1) = findDelay(P_up(:,2),1,P_up(:,1),fps,npinterpH,methodNum,debug,smoothFactor);
delay(2) = findDelay(P_down(:,2),2,P_down(:,1),fps,npinterpH,methodNum,debug,smoothFactor);


p = polyfit(posVal,delay,1);
PWV = 1/p(1);
fprintf('PWV = %.3f m/s\n',PWV);

if debug
%     figure(100002)
% 
%     plot(posVal,delay,'k.')
%     hold on
%     xx = linspace(min(posVal),max(posVal),1000);
%     plot(xx,polyval(p,xx))
%     xlabel('distance (m)')
%     ylabel('time(s)')
end
end














