% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files created by
% saveMuscleTendonPersonalizationResults.m containing optimized Hill-type
% muscle-tendon model parameters and creates a bar plot of them.
%
% (string) -> (None)
% Plot Hill-Type Muscle-Tendon model parameters from file.

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
function plotMtpHillTypeMuscleParams(resultsDirectory)
params = getPlottingParams();
analysisDirectory = fullfile(resultsDirectory, "Analysis");
[muscleNames, hillTypeParams] = extractMtpDataFromSto( ...
    fullfile(analysisDirectory, "muscleModelParameters"));
muscleNames = strrep(muscleNames, '_', ' ');
figure(Name = strcat(resultsDirectory, " Muscle Model Parameters"), ...
    Units=params.units, ...
    Position=params.figureSize)

if any(hillTypeParams(5, :)<=0) | any(hillTypeParams(6,:)<0)
    paramLabels = ["Activation Time Constant", ...
        "Activation Nonlinearity", ...
        "Electromechanical Time Delay", ...
        "EMG Scaling Factor", ...
        "Optimal Fiber Length Absolute Change", ...
        "Tendon Slack Length Absolute Change"];
else
    paramLabels = ["Activation Time Constant", ...
        "Activation Nonlinearity", ...
        "Electromechanical Time Delay", ...
        "EMG Scaling Factor", ...
        "Optimal Fiber Length Scaling Factor", ...
        "Tendon Slack Length Scaling Factor"];
end
t = tiledlayout(1, 6, ...
    TileSpacing='Compact', Padding='Compact');
hillTypeParams(3, :) = hillTypeParams(3, :) ./ 10;
set(gcf, color=params.plotBackgroundColor)
for i = 1 : numel(paramLabels)
    nexttile(i)

    barh(1:numel(muscleNames), hillTypeParams(i,:), facecolor=params.lineColors(1));
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    title(textwrap(paramLabels(i), 20), fontsize = params.subplotTitleFontSize)
    if i == 1
        yticks(1:numel(muscleNames))
        yticklabels(muscleNames)
    else
        yticks([])
        yticklabels([])
    end
end
end