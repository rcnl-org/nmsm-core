% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads a list of .sto files for treatment optimization 
% controls and plots them. 
%
% There are 2 optional arguments for figure width and figure height. If no
% optional arguments are given, the figure size is automatically adjusted
% to fit all data on one plot. Giving just figure width and no figure
% height will set figure height to a default value and extra figures will
% be created as needed. If both figure width and figure height are given,
% the figure size will be fixed and extra figures will be created as
% needed.
%
% (list string) -> (None)
% Plot joint moment curves from file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function plotTreatmentOptimizationControls(controlsFiles, ...
    figureWidth, figureHeight)
import org.opensim.modeling.Storage
params = getPlottingParams();
controlsData = {};
for j = 1 : numel(controlsFiles)
    controlsStorage = Storage(controlsFiles(j));
    labels = getStorageColumnNames(controlsStorage);
    controlsData{j} = storageToDoubleMatrix(controlsStorage)';
    controlsTime{j} = findTimeColumn(controlsStorage);
    if controlsTime{j}(1) ~= 0
        controlsTime{j} = controlsTime{j} - controlsTime{j}(1);
    end
    controlsTime{j} = controlsTime{j} / controlsTime{j}(end);
end

if numel(controlsFiles) > 1
    firstControlSpline = makeGcvSplineSet(controlsTime{1}, ...
    controlsData{1}, labels);
    resampledFirstControlData = {};
    % Resample the first control file to the time points of all other
    % files. 
    for j = 2 : numel(controlsFiles)
        resampledFirstControlData{j-1}= evaluateGcvSplines(firstControlSpline, ...
            labels, controlsTime{j});
    end
end

if nargin < 2
    figureWidth = ceil(sqrt(numel(labels)));
    figureHeight = ceil(numel(labels)/figureWidth);
elseif nargin < 3
    figureHeight = ceil(sqrt(numel(labels)));
end
figureSize = figureWidth * figureHeight;
if contains(controlsFiles(1), "torque")
    controllerType = "Torque";
elseif contains(controlsFiles(1), "synergy")
    controllerType = "Synergy";
else
    controllerType = "";
end
figureName = strcat(controllerType, " Controls");
figure(Name=figureName, ...
    Units=params.units, ...
    Position=params.figureSize)
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='Compact', Padding='Compact');
xlabel(t, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
if strcmp(controllerType, "Torque")
    ylabel(t, "Torque Controls [Nm]", ...
    fontsize=params.axisLabelFontSize)
elseif strcmp(controllerType, "Synergy")
    ylabel(t, "Synergy Controls", ...
    fontsize=params.axisLabelFontSize)
end
set(gcf, color=params.plotBackgroundColor)
for i=1:numel(labels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name=figureName, ...
            Units=params.units, ...
    Position=params.figureSize)
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
        ylabel(t, "Torque Controls [Nm]", ...
    fontsize=params.axisLabelFontSize)
        set(gcf, color=params.plotBackgroundColor)
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    for j  = 1 : numel(controlsFiles)
        plot(controlsTime{j}*100, controlsData{j}(:, i), ...
                LineWidth=params.linewidth, ...
                Color = params.lineColors(j));
    end
    hold off
    titleString = [sprintf("%s", strrep(labels(i), "_", " "))];
    if numel(controlsFiles) > 1
        for j = 2 : numel(controlsFiles)
            rmse = rms(controlsData{j}(1:end-1, i) - resampledFirstControlData{j-1}(1:end-1, i));
            titleString(j) = sprintf("RMSE %d: %.4f", j-1, rmse);
        end
    end
    title(titleString, fontsize = params.subplotTitleFontSize)
    if subplotNumber==1
        for j = 1 : numel(controlsFiles)
            splitFileName = split(controlsFiles(j), ["/", "\"]);
            legendValues(j) = sprintf("%s", splitFileName(end-1));
        end
        legend(legendValues, fontsize = params.legendFontSize)
    end
    xlim("tight")
    if strcmp(controllerType, "Synergy")
        maxValues = [];
        for j = 1 : numel(controlsData)
            maxValues(j) = max(controlsData{j}, [], "all");
        end
        ylim([0, max(maxValues)])
    end
    subplotNumber = subplotNumber + 1;
end
end

