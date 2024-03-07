% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing passive force curves 
% and creates plots of them.
%   
% (string) -> (None)
% Plot passive force curves from file.

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
function plotMtpPassiveForceCurves(resultsDirectory)
analysisDirectory = fullfile(resultsDirectory, "Analysis");

[muscleNames, modelForce] = extractMtpDataFromSto(...
    fullfile(analysisDirectory, "passiveForcesModel"));

muscleNames = strrep(muscleNames, '_', ' ');
meanModelForce = mean(modelForce, 3);
stdModelForce = std(modelForce, [], 3);
maxForce = max(meanModelForce,[], 'all');
numWindows = ceil(sqrt(numel(muscleNames)));

figureWidth = ceil(sqrt(numel(muscleNames)));
figureHeight = ceil(numel(muscleNames)/figureWidth);
figure(Name = strcat(resultsDirectory, " Passive Force Curves"), ...
    Units='normalized', ...
    Position=[0.05 0.05 0.9 0.85])
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
time = 1:1:size(meanModelForce,1);
for i = 1:numel(muscleNames)
    nexttile(i)
    hold on
    plotMeanAndStd(meanModelForce(:,i), stdModelForce(:,i), time, 'b-');
    hold off
    set(gca, fontsize=11)
    axis([time(1) time(end) 0 maxForce])
    title(muscleNames(i), FontSize=12);
    if mod(i,figureWidth) == 1
        ylabel("Force [N]")
    end
    if i>numel(muscleNames)-figureWidth
        xlabel("Time Points")
    end
end

