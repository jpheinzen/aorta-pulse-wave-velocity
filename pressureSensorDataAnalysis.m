% ccc
clear
% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Dec. 31st, 2022

% TODO:
%   should maybe put this is postProcessing...?

% filePath of .mat file
filePath = ["20221214 Penrose tests/Run2 - 1in single 1200.mat";...
"20221214 Penrose tests/Run3 - 1in single 2000.mat";...
"20221214 Penrose tests/Run4 - 1in single taped 1200.mat";...
"20221214 Penrose tests/Run6 - 0.75in single 1200.mat";...
"20221214 Penrose tests/Run7 - 0.75in single 2000.mat";...
"20221214 Penrose tests/Run8 - 0.75in single taped 1200.mat";...
"20221214 Penrose tests/Run10 - 0.625in single 1200.mat";...
"20221214 Penrose tests/Run11 - 0.625in single 2000.mat";...
"20221214 Penrose tests/Run12 - 0.625in single taped 1200.mat"];
% pSenseDistM = (31+19.5+19)/100;      % update this with distance in m between sensors
pSenseDistM = (31)/100;      % update this with distance in m between sensors
methodNum = 5;          % 1 to 5 --> different methods
npinterpH = 200;        % probably keep around 200; another switch
debug = false;          % true if you want to see graphs made by findDelay
smoothFactor = 5;       % can change for methods 4 and 5. The larger the 
                        %   number, the more smooth the data. 4-10 is good

PWV = zeros(length(filePath),1);
for ii = 1:length(filePath)
    PWV(ii) = pressurePWV(filePath(ii),pSenseDistM,methodNum,npinterpH,debug,smoothFactor);
end
%%
clear
% close all
% Created by: 
%   John-Paul Heinzen
% Last updated:
%   Dec. 31st, 2022

% TODO:
%   should maybe put this is postProcessing...?

% filePath of .mat file
filePath = ...
    "20221214 Penrose tests/Run2 - 1in single 1200.mat";

%     "20221214 Penrose tests/Run3 - 1in single 2000.mat";
% "20221214 Penrose tests/Run4 - 1in single taped 1200.mat";
% "20221214 Penrose tests/Run6 - 0.75in single 1200.mat";
%     ["20221214 Penrose tests/Run2 - 1in single 1200.mat";
% "20221214 Penrose tests/Run3 - 1in single 2000.mat";...
% "20221214 Penrose tests/Run7 - 0.75in single 2000.mat";...
% "20221214 Penrose tests/Run8 - 0.75in single taped 1200.mat";...
% "20221214 Penrose tests/Run10 - 0.625in single 1200.mat";...
% "20221214 Penrose tests/Run11 - 0.625in single 2000.mat";...
% "20221214 Penrose tests/Run12 - 0.625in single taped 1200.mat"];
% pSenseDistM = (31+19.5+19)/100;      % update this with distance in m between sensors
pSenseDistM = (31)/100;      % update this with distance in m between sensors
methodNum = 4;          % 1 to 5 --> different methods
npinterpH = 200;        % probably keep around 200; another switch
debug = true;           % true if you want to see graphs made by findDelay
smoothFactor = 5;       % can change for methods 4 and 5. The larger the 
                        %   number, the more smooth the data. 4-10 is good

PWV = zeros(length(filePath),1);
for ii = 1:length(filePath)
    PWV(ii) = pressurePWV(filePath(ii),pSenseDistM,methodNum,npinterpH,debug,smoothFactor);
end
