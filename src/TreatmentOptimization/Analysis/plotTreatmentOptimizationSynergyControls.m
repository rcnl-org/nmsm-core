% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads one .sto file for treatment optimization synergy
% controls and plots it.
%
% There are 2 optional arguments for figure width and figure height. If no
% optional arguments are given, the figure size is automatically adjusted
% to fit all data on one plot. Giving just figure width and no figure
% height will set figure height to a default value and extra figures will
% be created as needed. If both figure width and figure height are given,
% the figure size will be fixed and extra figures will be created as
% needed.
%
% (string) -> (None)
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
function plotTreatmentOptimizationSynergyControls(...
    trackedActivationsFile, trackedWeightsFile, ...
    resultsActivationsFiles, resultsWeightsFiles, ...
    synergyNormalizationMethod, synergyNormalizationValue, varargin)
% Take synergy activations and controls
% Normalization method and value 
% Use a common y axis. 
import org.opensim.modeling.Storage
if nargin > 6
    options = parseVarargin(varargin);
else
    options = struct();
end
params = getPlottingParams();

trackedActivationsStorage = Storage(trackedActivationsFile);
[trackedActivationsLabels, trackedActivationsTime, trackedActivationsData] = ...
    parseMotToComponents(org.opensim.modeling.Model(), trackedActivationsStorage);
trackedActivationsTime = trackedActivationsTime - trackedActivationsTime(1);
trackedActivationsTime = trackedActivationsTime / trackedActivationsTime(end);

trackedWeightsStorage = Storage(trackedWeightsFile);
[trackedWeightsLabels, trackedWeightsTime, trackedWeightsData] = ...
    parseMotToComponents(org.opensim.modeling.Model(), trackedWeightsStorage);

[trackedActivationsData, trackedWeightsData] = normalizeSynergyData(trackedActivationsData', ...
    trackedWeightsData', synergyNormalizationMethod, synergyNormalizationValue);
% Max tracked synergy activation. Used to set the plot y axis.
maxActivation = [max(trackedActivationsData, [], "all")];

resultsActivationsData = {};
resultsActivationsTime = {};
resultsWeightsData = {};
for i = 1 : numel(resultsActivationsFiles)
    resultsActivationsStorage = Storage(resultsActivationsFiles(i));
    [~, resultsActivationsTime{i}, resultsActivationsData{i}] = ...
        parseMotToComponents(org.opensim.modeling.Model(), resultsActivationsStorage);
    resultsActivationsTime{i} = resultsActivationsTime{i} - resultsActivationsTime{i}(1);
    resultsActivationsTime{i} = resultsActivationsTime{i} / resultsActivationsTime{i}(end);

    resultsWeightsStorage = Storage(resultsWeightsFiles(i));
    [resultsWeightsLabels, resultsWeightsTime, resultsWeightsData{i}] = ...
        parseMotToComponents(org.opensim.modeling.Model(), resultsWeightsStorage);

    [resultsActivationsData{i}, resultsWeightsData{i}] = ...
        normalizeSynergyData(...
            resultsActivationsData{i}', resultsWeightsData{i}', ...
            synergyNormalizationMethod, synergyNormalizationValue);
    % Max results synergy activation. Used to set the plot y axis.
    maxActivation(i+1) = max(resultsActivationsData{i}, [], "all");
end

% Upper y limit for each plot window is the max synergy activation from all
% trials.
upperYLimit = max(maxActivation);

trackedActivationsSpline = makeGcvSplineSet(trackedActivationsTime, ...
    trackedActivationsData, trackedActivationsLabels);
for j = 1 : numel(resultsActivationsFiles)
    resampledTrackedActivations{j}= evaluateGcvSplines(trackedActivationsSpline, ...
        trackedActivationsLabels, resultsActivationsTime{j});
end

if isfield(options, "figureGridSize")
    figureWidth = options.figureGridSize(1);
    figureHeight = options.figureGridSize(2);
else
    figureWidth = ceil(sqrt(numel(trackedActivationsLabels)));
    figureHeight = ceil(numel(trackedActivationsLabels)/figureWidth);
end
figureSize = figureWidth * figureHeight;
figure(Name = "Synergy Controls", ...
    Units=params.units, ...
    Position=params.figureSize)
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Percent Movement [0-100%]", ...
    fontsize=params.axisLabelFontSize)
ylabel(t, "Synergy Control", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)

for i=1:numel(trackedActivationsLabels)
    if i > figureSize * figureNumber
        figureNumber = figureNumber + 1;
        figure(Name="Synergy Controls", ...
            Units=params.units, ...
            Position=params.figureSize)
        t = tiledlayout(figureHeight, figureWidth, ...
            TileSpacing='Compact', Padding='Compact');
        xlabel(t, "Percent Movement [0-100%]", ...
            fontsize=params.axisLabelFontSize)
        ylabel(t, "Synergy Control", ...
            fontsize=params.axisLabelFontSize)
        set(gcf, color=params.plotBackgroundColor)
        subplotNumber = 1;
    end
    nexttile(subplotNumber);
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
    hold on
    titleString = [strrep(trackedActivationsLabels(i), "_", " ")];
    plot(trackedActivationsTime*100, trackedActivationsData(:, i), ...
        LineWidth=params.linewidth, ...
        Color = params.lineColors(1))
    for j = 1 : numel(resultsActivationsFiles)
        plot(resultsActivationsTime{j}*100, resultsActivationsData{j}(:, i), ...
            LineWidth=params.linewidth, ...
        Color = params.lineColors(j+1))
        rmse = rms(resampledTrackedActivations{j}(:, i) - ...
            resultsActivationsData{j}(:, i));
        titleString(j+1) = sprintf("RMSE %d: %.4f", j, rmse);
    end
    title(titleString, fontsize = params.subplotTitleFontSize)
    hold off
    if subplotNumber==1
        splitFileName = split(trackedActivationsFile, ["/", "\"]);
        for k = 1 : numel(splitFileName)
            if ~strcmp(splitFileName(k), "..")
                legendValues = sprintf("%s (T)", ...
                    strrep(splitFileName(k), "_", " "));
                break
            end
        end
        for j = 1 : numel(resultsActivationsFiles)
            splitFileName = split(resultsActivationsFiles(j), ["/", "\"]);
            legendValues(j+1) = sprintf("%s (%d)", splitFileName(1), j);
        end
        legend(legendValues, fontsize = params.legendFontSize)
    end
    xlim("tight")
    ylim([0 upperYLimit])
    subplotNumber = subplotNumber + 1;
end


figureHeight = numel(trackedWeightsTime);
figureWidth = 1;
figure(Name = "Synergy Commands", ...
    Units=params.units, ...
    Position=params.figureSize)
subplotNumber = 1;
figureNumber = 1;
t = tiledlayout(figureHeight, figureWidth, ...
    TileSpacing='compact', Padding='compact');
xlabel(t, "Muscle Name", ...
    fontsize=params.axisLabelFontSize)
ylabel(t, "Synergy Command", ...
    fontsize=params.axisLabelFontSize)
set(gcf, color=params.plotBackgroundColor)

for i = 1 : numel(trackedWeightsTime)
    nexttile(i)
    weightsPlottingArray = [trackedWeightsData(i, :)];
    for k = 1 : numel(resultsWeightsData)
        weightsPlottingArray = [weightsPlottingArray; resultsWeightsData{k}(i, :)];
    end
    b = bar(1:numel(trackedWeightsLabels), ...
        weightsPlottingArray);
    b(1).FaceColor = params.lineColors(1);
    for k = 1 : numel(resultsWeightsData)
        b(k).FaceColor = params.lineColors(k);
    end
    title(strrep(trackedActivationsLabels(i), "_", " "))
    if i == figureHeight
        xticks(1:numel(trackedWeightsLabels))
        xticklabels(trackedWeightsLabels)
    else
        xticks([])
        xticklabels([])
    end
    set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
end
end
function options = parseVarargin(varargin)
    options = struct();
    varargin = varargin{1};
    for k = 1 : 2 : numel(varargin)
        options.(varargin{k}) = varargin{k+1};
    end
end

function [synergyActivations, synergyWeights] = normalizeSynergyData(synergyActivations, ...
    synergyWeights, synergyNormalizationMethod, synergyNormalizationValue)
switch synergyNormalizationMethod
    case "sum"
        for i = 1:size(synergyWeights, 1)
            total = sum(synergyWeights(i, :)) / ...
                synergyNormalizationValue;
            synergyWeights(i, :) = ...
                synergyWeights(i, :) / total;
            synergyActivations(:, i) = ...
                synergyActivations(:, i) * total;
        end
    case "magnitude"
        for i = 1:size(synergyWeights, 1)
            total = norm(synergyWeights(i, :)) / ...
                synergyNormalizationValue;
            synergyWeights(i, :) = ...
                synergyWeights(i, :) / total;
            synergyActivations(:, i) = ...
                synergyActivations(:, i) * total;
        end
    otherwise
        throw(MException('', "Only 'sum' and 'magnitude' are " + ...
            "supported synergy normalization methods."))
end
end