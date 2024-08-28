% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads .sto files for experimental and model ground
% reactions and plots them. There is an option to plot multiple model files
% by passing in a list of model file names.
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
% Plot experimental and model ground reactions from file

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
function plotTreatmentOptimizationGroundReactions(trackedDataFile, ...
    modelDataFiles, figureWidth, figureHeight)

import org.opensim.modeling.Storage
trackedDataStorage = Storage(trackedDataFile);
trackedDataLabels = getStorageColumnNames(trackedDataStorage);
trackedData = storageToDoubleMatrix(trackedDataStorage)';
trackedDataTime = findTimeColumn(trackedDataStorage);
if trackedDataTime(1) ~= 0
    trackedDataTime = trackedDataTime - trackedDataTime(1);
end
trackedDataTime = trackedDataTime / trackedDataTime(end);
for j = 1 : numel(modelDataFiles)
    modelDataStorage = Storage(modelDataFiles(j));
    modelData{j} = storageToDoubleMatrix(modelDataStorage)';
    modelDataLabels{j} = getStorageColumnNames(modelDataStorage);
    modelDataTime{j} = findTimeColumn(modelDataStorage);
    if modelDataTime{j} ~= 0
        modelDataTime{j} = modelDataTime{j} - modelDataTime{j}(1);
    end
    modelDataTime{j} = modelDataTime{j} / modelDataTime{j}(end);
end

experimentalMomentIndices = contains(trackedDataLabels, ["_m", "M"]);
experimentalForceIndices = contains(trackedDataLabels, ["_v", "F"]);
experimentalIncludedIndices = experimentalMomentIndices | experimentalForceIndices;
trackedData = trackedData(:, experimentalIncludedIndices);
trackedDataLabels = trackedDataLabels(experimentalIncludedIndices);
experimentalForcePlate1 = contains(trackedDataLabels, "1");
for j = 1 : numel(modelDataFiles)
    modelMomentIndices = contains(modelDataLabels{j}, "_m");
    modelForceIndices = contains(modelDataLabels{j}, "_v");
    modelIncludedIndices = modelMomentIndices | modelForceIndices;
    modelData{j} = modelData{j}(:, modelIncludedIndices);
    modelDataLabels{j} = modelDataLabels{j}(modelIncludedIndices);
    modelForcePlate1 = contains(modelDataLabels{j}, "1");
    if experimentalForcePlate1 ~= modelForcePlate1
        temp = modelData{j};
        modelData{j}(:, ~experimentalForcePlate1) = ...
            modelData{j}(:, experimentalForcePlate1);
        modelData{j}(:, experimentalForcePlate1) = ...
            temp(:, ~experimentalForcePlate1);
    end
end

% Spline experimental time to the same time points as the model.
experimentalSpline = makeGcvSplineSet(trackedDataTime, ...
    trackedData, trackedDataLabels);
resampledExperimentalData = {};
for i = 1 : numel(modelDataFiles)
    resampledExperimentalData{i} = evaluateGcvSplines(experimentalSpline, ...
        trackedDataLabels, modelDataTime{i});
end
if nargin < 3
    figureWidth = 3;
end
if nargin < 4
    figureHeight = 2;
end
figureSize = figureWidth * figureHeight;
figure(Name = "Treatment Optimization Ground Reactions", ...
    Units='normalized', ...
    Position=[0.05 0.05 0.425 0.4])
colors = getPlottingColors();
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Percent Gait Cycle [0-100%]", fontsize=18, FontName="Arial")
% ylabel(t, "Ground Reaction Force [N]", fontsize=15)
titleStrings = ["Ground Force X", "Ground Force Y", "Ground Force Z", ...
    "Ground Moment X", "Ground Moment Y", "Ground Moment Z", ...
    "Ground Force X", "Ground Force Y", "Ground Force Z", ...
    "Ground Moment X", "Ground Moment Y", "Ground Moment Z"];
forceIndices = contains(titleStrings, "Force");
momentIndices = contains(titleStrings, "Moment");
for i=1:numel(trackedDataLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Treatment Optimization Ground Reactions", ...
            Units='normalized', ...
            Position=[0.05 0.05 0.425 0.4])
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Gait Cycle [0-100%]", fontsize=18, FontName="Arial")
        % ylabel(t, "Ground Reaction")
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    hold on
    plot(trackedDataTime(1:end)*100, trackedData(1:end, i), color=colors(1), LineWidth=3);
    for j = 1 : numel(modelDataFiles)
        plot(modelDataTime{j}(1:end)*100, modelData{j}(1:end, i), color=colors(1+j), ...
            LineWidth=3);
    end
    xticks([0 25 50 75 100])
    ax = gca;
    ax.FontSize=15;
    ax.FontName="Arial";
    hold off
    titleString = [titleStrings(i)];
    for j = 1 : numel(modelDataFiles)
        rmse = rms(resampledExperimentalData{j}(:, i) - modelData{j}(:, i));
        titleString(j+1) = sprintf("RMSE: %.4f", rmse);
    end
    title(titleString, fontsize=18, FontName="Arial")
    if subplotNumber == 1
        ylabel("Force [N]", fontsize=18, FontName="Arial")
    elseif subplotNumber == 4
        ylabel("Moment [Nm]", fontsize=18, FontName="Arial")
    end
        
    if subplotNumber==4
        % ylabel("Ground Reaction Moment [Nm]", fontsize=15, position=[-10 -35/2])
        splitFileName = split(trackedDataFile, ["/", "\"]);
        for k = 1 : numel(splitFileName)
            if ~strcmp(splitFileName(k), "..")
                legendValues = sprintf("%s (T)", ...
                    strrep(splitFileName(k), "_", " "));
                break
            end
        end
        for j = 1 : numel(modelDataFiles)
            splitFileName = split(modelDataFiles(j), ["/", "\"]);
            legendValues(j+1) = sprintf("%s (%d)", splitFileName(1), j);
        end
        % legend(legendValues)
    end
    
    if subplotNumber <= 3
        for j = 1 : numel(modelDataFiles)
            maxData(j) = max(modelData{j}(:, forceIndices), [], "all");
            minData(j) = min(modelData{j}(:, forceIndices), [], "all");
        end
        maxData(j+1) = max(trackedData(:, forceIndices), [], "all");
        minData(j+1) = min(trackedData(:, forceIndices), [], "all");
        ylim([-200 1000])
        yticks([0 500 1000])
        % if any(subplotNumber==1 || subplotNumber==4)
        %     yticks([0 500 1000])
        % else
        %     yticks([0 500 1000])
        %     yticklabels({})
        % end
    else
        for j = 1 : numel(modelDataFiles)
            maxData(j) = max(modelData{j}(:, momentIndices), [], "all");
            minData(j) = min(modelData{j}(:, momentIndices), [], "all");
        end
        maxData(j+1) = max(trackedData(:, momentIndices), [], "all");
        minData(j+1) = min(trackedData(:, momentIndices), [], "all");
        ylim([-60 40])
        yticks([-40 0 40])
        % if any(subplotNumber==1 || subplotNumber==4)
        %     yticks([0 500 1000])
        % else
        %     yticks([0 500 1000])
        %     yticklabels({})
        % end
    end

    % if any(subplotNumber==1 || subplotNumber==4)
    %     yticks([])
    % yLimitUpper = max(maxData);
    % yLimitLower = min(minData);
    % ylim([yLimitLower, yLimitUpper])
    xlim("tight")
    subplotNumber = subplotNumber + 1;
end