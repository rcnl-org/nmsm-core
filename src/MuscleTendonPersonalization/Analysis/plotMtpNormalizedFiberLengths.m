% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing normalized fiber
% lengths and creates plots of them.
%
% (string) -> (None)
% Plot normalized fiber lengths from file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Di Ao, Marleny Vega, Robert Salati                           %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %
function plotMtpNormalizedFiberLengths(resultsDirectory, figureWidth, ...
    figureHeight)
analysisDirectory = fullfile(resultsDirectory, "Analysis");
[muscleNames, normalizedFiberLengths] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "normalizedFiberLengths"));
muscleNames = strrep(muscleNames, '_', ' ');
meanFiberLengths = mean(normalizedFiberLengths, 3);
stdFiberLengths = std(normalizedFiberLengths, [], 3);
time = 1:1:size(meanFiberLengths,1);
passiveLower = ones(size(time))*0.7;
passiveUpper = ones(size(time));

if nargin < 2
    figureWidth = ceil(sqrt(numel(muscleNames)));
    figureHeight = ceil(numel(muscleNames)/figureWidth);
elseif nargin < 3
    figureHeight = ceil(sqrt(numel(muscleNames)));
end
figureSize = figureWidth * figureHeight;
subplotNumber = 1;
figureNumber = 1;
figure(Name = strcat(resultsDirectory, ...
        " Normalized Fiber Lengths"), ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
xlabel(t, "Percent Movement [0-100%]")
ylabel(t, "Normalized Fiber Length")
for i=1:numel(muscleNames)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name = strcat(resultsDirectory, ...
                " Normalized Fiber Lengths"), ...
            Units='normalized', ...
            Position=[0.05 0.05 0.9 0.85])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Movement [0-100%]")
        ylabel(t, "Normalized Fiber Length")
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    hold on
    plotMeanAndStd(meanFiberLengths(:,i), stdFiberLengths(:,i), ...
        time, "#0072BD")
    plot(time, passiveUpper, 'r--', LineWidth=2);
    plot(time, passiveLower, 'r--', LineWidth=2);
    hold off
    set(gca, fontsize=11)
    axis([time(1) time(end) 0 1.5])
    title(muscleNames(i), FontSize=12);
    subplotNumber = subplotNumber + 1;
end
end

