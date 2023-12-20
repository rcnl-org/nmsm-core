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
[muscleNames, experimentalForce] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "passiveForcesExperimental"));
if exist(fullfile(analysisDirectory, "passiveForcesModelSynx"), "dir")
    [~, modelForce] = extractMtpDataFromSto(...
        fullfile(analysisDirectory, "passiveForcesModelSynx"));
else
    [~, modelForce] = extractMtpDataFromSto(...
        fullfile(analysisDirectory, "passiveForcesModel"));
end
muscleNames = strrep(muscleNames, '_', ' ');
meanExperimentalForce = mean(experimentalForce, 3);
stdExperimentalForce = std(experimentalForce, [], 3);
meanModelForce = mean(modelForce, 3);
stdModelForce = std(modelForce, [], 3);
maxForce = max( ...
    [max(meanModelForce, [], 'all'), ...
    max(meanExperimentalForce, [], 'all')]);
numWindows = ceil(sqrt(numel(muscleNames)));

figure(Name = "Passive Force Curves", ...
    Units='normalized', ...
    Position=[0.1 0.1 0.8 0.8])
time = 1:1:size(meanExperimentalForce,1);
for i = 1:numel(muscleNames)
    subplot(numWindows, numWindows, i)
    hold on
    plotMeanAndStd(meanExperimentalForce(:,i), stdExperimentalForce(:,i), ...
        time, 'k-')
    plotMeanAndStd(meanModelForce(:,i), stdModelForce(:,i), time, 'r-');
    hold off
    set(gca, fontsize=11)
    axis([1 numel(time) 0 maxForce])
    title(muscleNames(i), FontSize=12);
    if i == 1
        legend("Experimental", "Model")
    end
    if mod(i,3) == 1
        ylabel("Magnitude")
    end
    if i>numel(muscleNames)-numWindows
        xlabel("Time Points")
    end
end

