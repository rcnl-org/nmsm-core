% This function is part of the NMSM Pipeline, see file for full license.
%
% Plot muscle activations for one trial resulting from Neural Control 
% Personalization from synergy weights and synergy commands output files. 
%
% (string, string, string, double, double) -> (None)
% Plot NCP muscle activations from weights and commands files. 

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function plotNeuralControlPersonalizationActivations(weightsFile, ...
    commandsFile, mtpActivationsFile, figureWidth, figureHeight)
% Define number of 
if nargin < 4
    figureWidth = 8;
end
if nargin < 5
    figureHeight = 8;
end
figureSize = figureWidth * figureHeight;

import org.opensim.modeling.Storage
weightsStorage = Storage(weightsFile);
muscleNames = getStorageColumnNames(weightsStorage);
synergyWeights = storageToDoubleMatrix(weightsStorage);
commandsStorage = Storage(commandsFile);
time = findTimeColumn(commandsStorage);
synergyCommands = storageToDoubleMatrix(commandsStorage);
muscleActivations = synergyWeights * synergyCommands;

if isstring(mtpActivationsFile) || ischar(mtpActivationsFile)
    mtpStorage = Storage(mtpActivationsFile);
    mtpMuscleNames = getStorageColumnNames(mtpStorage);
    mtpActivations = storageToDoubleMatrix(mtpStorage);
else
    mtpMuscleNames = "";
end

figureNumber = 1;
subplotNumber = 1;
hasLegend = false;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
for i = 1:size(muscleActivations, 1)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(figureNumber)
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        subplotNumber = 1;
        hasLegend = false;
    end
    nexttile(subplotNumber)
    mtpIndex = find(muscleNames(i) == mtpMuscleNames);
    if ~isempty(mtpIndex)
        hold on
        plot(time, mtpActivations(mtpIndex, :), 'LineWidth', 2, ...
            Color="#0072BD");
    end
    plot(time, muscleActivations(i, :), 'LineWidth', 2, ...
        Color="#D95319")
    hold off
    if ~hasLegend
        legend("Previous Activations", "NCP Results")
        hasLegend = true;
    end
    title(strrep(muscleNames(i), "_", " "))
    ylim([0 1])
    subplotNumber = subplotNumber + 1;
end
end
