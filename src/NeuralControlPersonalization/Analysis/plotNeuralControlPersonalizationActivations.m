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
import org.opensim.modeling.Storage
params = getPlottingParams();
weightsStorage = Storage(weightsFile);
muscleNames = getStorageColumnNames(weightsStorage);
synergyWeights = storageToDoubleMatrix(weightsStorage);
commandsStorage = Storage(commandsFile);
time = findTimeColumn(commandsStorage);
synergyCommands = storageToDoubleMatrix(commandsStorage);
muscleActivations = synergyWeights * synergyCommands;

if time(1) ~= 0
    time = time - time(1);
end
time = time / time(end);

if isstring(mtpActivationsFile) || ischar(mtpActivationsFile)
    mtpStorage = Storage(mtpActivationsFile);
    mtpMuscleNames = getStorageColumnNames(mtpStorage);
    mtpActivations = storageToDoubleMatrix(mtpStorage);
else
    mtpMuscleNames = "";
end

if nargin < 4
    figureWidth = ceil(sqrt(numel(muscleNames)));
    figureHeight = ceil(numel(muscleNames)/figureWidth);
elseif nargin < 5
    figureHeight = ceil(sqrt(numel(muscleNames)));
end
figureSize = figureWidth * figureHeight;
splitFileName = split(commandsFile, "_synergyCommands.sto");
figureName = splitFileName(1);
figure(Name = figureName, ...
    Units=params.units, ...
    Position=params.figureSize)
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
xlabel(t, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(t, "Muscle Activations", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
for i = 1:size(muscleActivations, 1)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name = figureName, ...
            Units=params.units, ...
            Position=params.figureSize)
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Movement [0-100%]", ...
            fontsize=params.axisLabelFontSize)
        ylabel(t, "Muscle Activations", ...
            fontsize=params.axisLabelFontSize)
        set(gcf, color=params.plotBackgroundColor)
        subplotNumber = 1;
    end
    nexttile(subplotNumber)
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    mtpIndex = find(muscleNames(i) == mtpMuscleNames);
    hold on
    if ~isempty(mtpIndex)
        plot(time*100, mtpActivations(mtpIndex, :), ...
            LineWidth=params.linewidth, ...
            Color = params.lineColors(1))
    end
    plot(time*100, muscleActivations(i, :), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(2))
    hold off
    if subplotNumber==1
        if ~isempty(mtpIndex)
            legend("MTP Activations", "NCP Activations", ...
                fontsize = params.legendFontSize)
        else
            legend("NCP Activations", ...
                fontsize = params.legendFontSize)
        end
    end
    title(strrep(muscleNames(i), "_", " "), ...
        fontsize = params.subplotTitleFontSize)
    xlim("tight")
    ylim([0 1])
    subplotNumber = subplotNumber + 1;
end
end
