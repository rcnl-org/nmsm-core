% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files for experimental and model joint loads
% and plots them. There is an option to plot multiple model files by
% passing in a list of model file names.
%
% There are 2 optional arguments for figure width and figure height. If no
% optional arguments are given, the figure size is automatically adjusted
% to fit all data on one plot. Giving just figure width and no figure
% height will set figure height to a default value and extra figures will
% be created as needed. If both figure width and figure height are given,
% the figure size will be fixed and extra figures will be created as
% needed.
%
% (string) (List of strings) (int), (int) -> (None)
% Plot experimental and model joint loads from file

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
function plotTreatmentOptimizationJointLoads(trackedDataFile, ...
    resultsDataFiles, figureWidth, figureHeight)

import org.opensim.modeling.Storage
params = getPlottingParams();
trackedDataStorage = Storage(trackedDataFile);
jointLoadLabels = getStorageColumnNames(trackedDataStorage);
trackedData = storageToDoubleMatrix(trackedDataStorage)';
trackedDataTime = findTimeColumn(trackedDataStorage);
if trackedDataTime(1) ~= 0
    trackedDataTime = trackedDataTime - trackedDataTime(1);
end
trackedDataTime = trackedDataTime / trackedDataTime(end);
% Crop data to get rid of edge effects
trackedDataTime = trackedDataTime(1:end-1);
trackedData = trackedData(1:end-1, :);

for j=1:numel(resultsDataFiles)
    resultsDataStorage = Storage(resultsDataFiles(j));
    resultsData{j} = storageToDoubleMatrix(resultsDataStorage)';
    resultsDataTime{j} = findTimeColumn(resultsDataStorage);
    if resultsDataTime{j} ~= 0
        resultsDataTime{j} = resultsDataTime{j} - resultsDataTime{j}(1);
    end
    resultsDataTime{j} = resultsDataTime{j} / resultsDataTime{j}(end);
    % Crop data to get rid of edge effects
    resultsDataTime{j} = resultsDataTime{j}(1:end-1);
    resultsData{j} = resultsData{j}(1:end-1, :);
end

% Spline experimental time to the same time points as the model.
trackedDataSpline = makeGcvSplineSet(trackedDataTime, ...
    trackedData, jointLoadLabels);
for j = 1 : numel(resultsDataFiles)
    resampledTrackedData{j}= evaluateGcvSplines(trackedDataSpline, ...
        jointLoadLabels, resultsDataTime{j});
end
if nargin < 3
    figureWidth = ceil(sqrt(numel(jointLoadLabels)));
    figureHeight = ceil(numel(jointLoadLabels)/figureWidth);
elseif nargin < 4
    figureHeight = ceil(sqrt(numel(jointLoadLabels)));
end
figureSize = figureWidth * figureHeight;
figure(Name = "Joint Loads", ...
    Units=params.units, ...
    Position=params.figureSize)
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(t, "Joint Loads", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)
for i=1:numel(jointLoadLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Joint Loads", ...
            Units=params.units, ...
            Position=params.figureSize)
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Movement [0-100%]", ...
            fontsize=params.axisLabelFontSize)
        ylabel(t, "Joint Loads", ...
            fontsize=params.axisLabelFontSize)
        set(gcf, color=params.plotBackgroundColor)
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    plot(trackedDataTime*100, trackedData(:, i), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(1));
    for j = 1 : numel(resultsDataFiles)
        plot(resultsDataTime{j}*100, resultsData{j}(:, i), ...
            LineWidth=params.linewidth, ...
            Color = params.lineColors(j+1));
    end
    hold off
    if contains(jointLoadLabels(i), "moment")
        titleString = [sprintf("%s [Nm]", strrep(jointLoadLabels(i), "_", " "))];
    elseif contains(jointLoadLabels(i), "force")
        titleString = [sprintf("%s [N]", strrep(jointLoadLabels(i), "_", " "))];
    else
        titleString = [sprintf("%s", strrep(jointLoadLabels(i), "_", " "))];
    end
    for j = 1 : numel(resultsDataFiles)
        rmse = rms(resampledTrackedData{j}(1:end-1, i) - ...
            resultsData{j}(1:end-1, i));
        titleString(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
    end
    title(titleString, fontsize = params.subplotTitleFontSize)
    if subplotNumber==1
        splitFileName = split(trackedDataFile, ["/", "\"]);
        for k = 1 : numel(splitFileName)
            if ~strcmp(splitFileName(k), "..")
                legendValues = sprintf("%s (T)", ...
                    strrep(splitFileName(k), "_", " "));
                break
            end
        end
        for j = 1 : numel(resultsDataFiles)
            splitFileName = split(resultsDataFiles(j), ["/", "\"]);
            legendValues(j+1) = sprintf("%s (%d)", splitFileName(1), j);
        end
        legend(legendValues, fontsize = params.legendFontSize)
    end

    xlim("tight")
    maxData = [];
    minData = [];
    for j = 1 : numel(resultsDataFiles)
        maxData(j) = max(resultsData{j}(1:end-1, i), [], "all");
        minData(j) = min(resultsData{j}(1:end-1, i), [], "all");
    end
    maxData(j+1) = max(trackedData(1:end-1, i), [], "all");
    minData(j+1) = min(trackedData(1:end-1, i), [], "all");
    yLimitUpper = max(maxData);
    yLimitLower = min(minData);
    if yLimitUpper - yLimitLower < 10
        ylim([(yLimitUpper+yLimitLower)/2-10, (yLimitUpper+yLimitLower)/2+10])
    else
        ylim([yLimitLower, yLimitUpper]);
    end
    subplotNumber = subplotNumber + 1;
end